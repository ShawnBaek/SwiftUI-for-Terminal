#include "internal.h"
#include <sys/select.h>
#include <errno.h>

// Defined in terminal.c
extern volatile sig_atomic_t g_resize_flag;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Wait for data on stdin.  Returns 1 if data ready, 0 on timeout, -1 error.
static int wait_for_input(const struct timespec* ts) {
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);

    struct timeval tv;
    struct timeval* tvp = NULL;
    if (ts) {
        tv.tv_sec  = ts->tv_sec;
        tv.tv_usec = (int)(ts->tv_nsec / 1000);
        tvp = &tv;
    }

    int ret;
    do {
        ret = select(STDIN_FILENO + 1, &fds, NULL, NULL, tvp);
    } while (ret == -1 && errno == EINTR && !g_resize_flag);

    return ret;
}

// Try to read one byte from stdin (non-blocking).
// Returns the byte (0-255) or -1 if nothing available.
static int read_byte_nonblock(void) {
    unsigned char ch;
    ssize_t n = read(STDIN_FILENO, &ch, 1);
    return (n == 1) ? (int)ch : -1;
}

// Wait briefly (50 ms) for more bytes — used for ESC disambiguation.
static int read_byte_brief(void) {
    struct timespec ts = { .tv_sec = 0, .tv_nsec = 50000000 }; // 50 ms
    if (wait_for_input(&ts) <= 0) return -1;
    return read_byte_nonblock();
}

// Decode modifier from xterm parameter:  modifier = 1 + (shift?1:0) + (alt?2:0) + (ctrl?4:0)
static void decode_modifier(int mod, ncinput* ni) {
    if (!ni) return;
    mod -= 1;
    ni->shift = (mod & 1) != 0;
    ni->alt   = (mod & 2) != 0;
    ni->ctrl  = (mod & 4) != 0;
}

// ---------------------------------------------------------------------------
// CSI sequence parser:  ESC [ <params> <final>
// Called after ESC [ has been consumed.
// ---------------------------------------------------------------------------

static uint32_t parse_csi(ncinput* ni) {
    // Read parameter bytes and the final byte.
    // Parameters are digits and semicolons; final byte is 0x40-0x7E.
    int params[4] = {0, 0, 0, 0};
    int nparam = 0;
    bool have_digit = false;

    for (;;) {
        int ch = read_byte_brief();
        if (ch < 0) return 0;  // Timeout — incomplete sequence

        if (ch >= '0' && ch <= '9') {
            if (nparam == 0 && !have_digit) nparam = 1;
            if (nparam <= 4) params[nparam - 1] = params[nparam - 1] * 10 + (ch - '0');
            have_digit = true;
        } else if (ch == ';') {
            if (nparam < 4) nparam++;
            have_digit = false;
        } else {
            // ch is the final byte
            // Apply modifier if present (param index 1, i.e. second parameter)
            if (nparam >= 2) decode_modifier(params[1], ni);

            switch (ch) {
                case 'A': return NCKEY_UP;
                case 'B': return NCKEY_DOWN;
                case 'C': return NCKEY_RIGHT;
                case 'D': return NCKEY_LEFT;
                case 'H': return NCKEY_HOME;
                case 'F': return NCKEY_END;
                case '~':
                    // Tilde sequences: number ~ (e.g. ESC[2~)
                    switch (params[0]) {
                        case 2: return NCKEY_INS;
                        case 3: return NCKEY_DEL;
                        case 5: return NCKEY_PGUP;
                        case 6: return NCKEY_PGDOWN;
                        default: return 0;
                    }
                default:
                    return 0;  // Unknown CSI
            }
        }
    }
}

// ---------------------------------------------------------------------------
// SS3 sequence parser:  ESC O <char>
// ---------------------------------------------------------------------------

static uint32_t parse_ss3(void) {
    int ch = read_byte_brief();
    if (ch < 0) return 0;
    switch (ch) {
        case 'A': return NCKEY_UP;
        case 'B': return NCKEY_DOWN;
        case 'C': return NCKEY_RIGHT;
        case 'D': return NCKEY_LEFT;
        case 'H': return NCKEY_HOME;
        case 'F': return NCKEY_END;
        default:  return 0;
    }
}

// ---------------------------------------------------------------------------
// Read a single UTF-8 codepoint from stdin (first byte already read).
// ---------------------------------------------------------------------------

static uint32_t read_utf8(int first_byte) {
    uint32_t cp;
    int remaining;

    if (first_byte < 0xE0) {
        cp = (uint32_t)(first_byte & 0x1F);
        remaining = 1;
    } else if (first_byte < 0xF0) {
        cp = (uint32_t)(first_byte & 0x0F);
        remaining = 2;
    } else {
        cp = (uint32_t)(first_byte & 0x07);
        remaining = 3;
    }

    for (int i = 0; i < remaining; i++) {
        int b = read_byte_brief();
        if (b < 0 || (b & 0xC0) != 0x80) return NCKEY_INVALID;
        cp = (cp << 6) | (uint32_t)(b & 0x3F);
    }

    return cp;
}

// ---------------------------------------------------------------------------
// notcurses_get — main input entry point
//
// Returns 0 on timeout, or the key code (Unicode codepoint / NCKEY_*).
// ---------------------------------------------------------------------------

uint32_t notcurses_get(struct notcurses* nc,
                       const struct timespec* ts, ncinput* ni) {
    if (!nc) return 0;

    // Zero out ncinput
    if (ni) memset(ni, 0, sizeof(ncinput));

    // Check resize flag first
    if (g_resize_flag) {
        g_resize_flag = 0;
        uint32_t key = NCKEY_RESIZE;
        if (ni) ni->id = key;
        return key;
    }

    // Wait for input (or timeout)
    int ready = wait_for_input(ts);
    if (ready <= 0) {
        // Check resize flag again (signal may have arrived during select)
        if (g_resize_flag) {
            g_resize_flag = 0;
            uint32_t key = NCKEY_RESIZE;
            if (ni) ni->id = key;
            return key;
        }
        return 0;  // Timeout
    }

    int byte = read_byte_nonblock();
    if (byte < 0) return 0;

    uint32_t key = 0;

    if (byte == 27) {
        // ESC — could be escape key or start of escape sequence
        int next = read_byte_brief();
        if (next < 0) {
            // No follow-up byte → bare Escape key
            key = NCKEY_ESC;
        } else if (next == '[') {
            key = parse_csi(ni);
            if (key == 0) key = NCKEY_ESC;  // Unrecognized sequence
        } else if (next == 'O') {
            key = parse_ss3();
            if (key == 0) key = NCKEY_ESC;
        } else {
            // Alt + key
            if (ni) ni->alt = true;
            if (next >= 0x80) {
                key = read_utf8(next);
            } else {
                key = (uint32_t)next;
            }
        }
    } else if (byte == 13 || byte == 10) {
        key = NCKEY_ENTER;
    } else if (byte == 127 || byte == 8) {
        key = NCKEY_BACKSPACE;
    } else if (byte == 9) {
        key = NCKEY_TAB;
    } else if (byte >= 0x80) {
        // UTF-8 multibyte
        key = read_utf8(byte);
    } else {
        // Regular ASCII
        key = (uint32_t)byte;
    }

    if (ni) ni->id = key;
    return key;
}
