#include "internal.h"

// ---------------------------------------------------------------------------
// Cell buffer management
// ---------------------------------------------------------------------------

void nc_plane_init_cells(struct ncplane* n) {
    size_t count = (size_t)n->rows * n->cols;
    n->cells = calloc(count, sizeof(nc_cell));
}

void nc_plane_free_cells(struct ncplane* n) {
    free(n->cells);
    n->cells = NULL;
}

// ---------------------------------------------------------------------------
// Query terminal size via ioctl
// ---------------------------------------------------------------------------

void nc_get_terminal_size(unsigned* rows, unsigned* cols) {
    struct winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0) {
        *rows = ws.ws_row;
        *cols = ws.ws_col;
    } else {
        *rows = 24;
        *cols = 80;
    }
}

// ---------------------------------------------------------------------------
// Render a plane to ANSI output
// ---------------------------------------------------------------------------

// Rough upper bound per cell: SGR reset(4) + bold(4) + italic(4) + underline(4)
// + struck(4) + fg(20) + bg(20) + char(4) = ~64 bytes.  Round up to 80.
#define BYTES_PER_CELL 80

void nc_render_plane(struct notcurses* nc, struct ncplane* n) {
    FILE* fp = nc->fp;
    const unsigned rows = n->rows;
    const unsigned cols = n->cols;

    // Allocate render buffer
    size_t buf_cap = (size_t)rows * cols * BYTES_PER_CELL + 256;
    char* buf = malloc(buf_cap);
    if (!buf) return;
    size_t pos = 0;

    // Helper: append formatted text to buffer
    #define EMIT(...) do { \
        pos += (size_t)snprintf(buf + pos, buf_cap - pos, __VA_ARGS__); \
    } while (0)

    EMIT("\033[?25l");   // Hide cursor
    EMIT("\033[H");      // Home cursor

    uint32_t cur_fg     = 0xFFFFFFFF;  // Sentinel: not set
    uint32_t cur_bg     = 0xFFFFFFFF;
    uint32_t cur_styles = 0xFFFFFFFF;

    for (unsigned r = 0; r < rows; r++) {
        for (unsigned c = 0; c < cols; c++) {
            nc_cell* cell = &n->cells[r * cols + c];

            // --- Styles ---
            uint32_t want_styles = cell->written ? cell->styles : 0;
            if (want_styles != cur_styles) {
                EMIT("\033[0m");
                cur_fg = 0xFFFFFFFF;
                cur_bg = 0xFFFFFFFF;
                cur_styles = want_styles;
                if (cur_styles & NCSTYLE_BOLD)      EMIT("\033[1m");
                if (cur_styles & NCSTYLE_ITALIC)    EMIT("\033[3m");
                if (cur_styles & NCSTYLE_UNDERLINE) EMIT("\033[4m");
                if (cur_styles & NCSTYLE_STRUCK)    EMIT("\033[9m");
            }

            // --- Foreground ---
            if (cell->written && cell->fg_set) {
                if (cell->fg_rgb != cur_fg) {
                    cur_fg = cell->fg_rgb;
                    EMIT("\033[38;2;%u;%u;%um",
                         (cur_fg >> 16) & 0xFF,
                         (cur_fg >> 8) & 0xFF,
                         cur_fg & 0xFF);
                }
            } else if (cur_fg != 0xFFFFFFFF) {
                EMIT("\033[39m");   // Default FG
                cur_fg = 0xFFFFFFFF;
            }

            // --- Background ---
            if (cell->written && cell->bg_set) {
                if (cell->bg_rgb != cur_bg) {
                    cur_bg = cell->bg_rgb;
                    EMIT("\033[48;2;%u;%u;%um",
                         (cur_bg >> 16) & 0xFF,
                         (cur_bg >> 8) & 0xFF,
                         cur_bg & 0xFF);
                }
            } else if (cur_bg != 0xFFFFFFFF) {
                EMIT("\033[49m");   // Default BG
                cur_bg = 0xFFFFFFFF;
            }

            // --- Character ---
            if (cell->written && cell->gcluster[0] != '\0') {
                // Copy gcluster bytes directly
                for (int i = 0; cell->gcluster[i] && i < 7; i++) {
                    if (pos < buf_cap - 1) buf[pos++] = cell->gcluster[i];
                }
            } else {
                if (pos < buf_cap - 1) buf[pos++] = ' ';
            }
        }
        // Newline between rows (except after the last row)
        if (r < rows - 1) {
            EMIT("\r\n");
        }
    }

    EMIT("\033[0m");     // Reset all attributes
    EMIT("\033[?25h");   // Show cursor
    #undef EMIT

    fwrite(buf, 1, pos, fp);
    fflush(fp);
    free(buf);
}
