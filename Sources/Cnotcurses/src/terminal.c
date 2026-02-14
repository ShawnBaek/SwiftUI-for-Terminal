#include "internal.h"

// ---------------------------------------------------------------------------
// SIGWINCH handling
// ---------------------------------------------------------------------------

volatile sig_atomic_t g_resize_flag = 0;

static void sigwinch_handler(int sig) {
    (void)sig;
    g_resize_flag = 1;
}

// ---------------------------------------------------------------------------
// notcurses_init
// ---------------------------------------------------------------------------

struct notcurses* notcurses_init(const notcurses_options* opts, FILE* fp) {
    struct notcurses* nc = calloc(1, sizeof(struct notcurses));
    if (!nc) return NULL;

    nc->fp    = fp ? fp : stdout;
    nc->flags = opts ? opts->flags : 0;

    // Query terminal dimensions
    nc_get_terminal_size(&nc->rows, &nc->cols);

    // Save current terminal settings
    if (tcgetattr(STDIN_FILENO, &nc->original) != 0) {
        free(nc);
        return NULL;
    }

    // Enter raw mode
    struct termios raw = nc->original;
    raw.c_iflag &= ~(unsigned long)(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
    raw.c_oflag &= ~(unsigned long)(OPOST);
    raw.c_cflag |= (unsigned long)(CS8);
    raw.c_lflag &= ~(unsigned long)(ECHO | ICANON | IEXTEN | ISIG);
    raw.c_cc[VMIN]  = 0;
    raw.c_cc[VTIME] = 0;
    if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) != 0) {
        free(nc);
        return NULL;
    }

    // Enter alternate screen (unless opted out)
    if (!(nc->flags & NCOPTION_NO_ALTERNATE_SCREEN)) {
        fprintf(nc->fp, "\033[?1049h");
        nc->alt_screen = true;
    }

    // Hide cursor, clear screen
    fprintf(nc->fp, "\033[?25l\033[2J\033[H");
    fflush(nc->fp);

    // Install SIGWINCH handler
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigwinch_handler;
    sa.sa_flags   = SA_RESTART;
    sigaction(SIGWINCH, &sa, NULL);

    // Create the standard plane
    nc->stdplane = calloc(1, sizeof(struct ncplane));
    if (!nc->stdplane) {
        tcsetattr(STDIN_FILENO, TCSAFLUSH, &nc->original);
        free(nc);
        return NULL;
    }
    nc->stdplane->rows   = nc->rows;
    nc->stdplane->cols   = nc->cols;
    nc->stdplane->y      = 0;
    nc->stdplane->x      = 0;
    nc->stdplane->parent = NULL;
    nc->stdplane->nc     = nc;
    nc_plane_init_cells(nc->stdplane);

    return nc;
}

// ---------------------------------------------------------------------------
// notcurses_stop
// ---------------------------------------------------------------------------

int notcurses_stop(struct notcurses* nc) {
    if (!nc) return -1;

    // Reset attributes, show cursor
    fprintf(nc->fp, "\033[0m\033[?25h");

    // Leave alternate screen
    if (nc->alt_screen) {
        fprintf(nc->fp, "\033[?1049l");
    }

    // Clear screen and home cursor so the shell prompt starts cleanly
    fprintf(nc->fp, "\033[2J\033[H");
    fflush(nc->fp);

    // Restore terminal settings
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &nc->original);

    // Free stdplane
    if (nc->stdplane) {
        nc_plane_free_cells(nc->stdplane);
        free(nc->stdplane);
    }

    free(nc);
    return 0;
}

// ---------------------------------------------------------------------------
// notcurses_render
// ---------------------------------------------------------------------------

int notcurses_render(struct notcurses* nc) {
    if (!nc || !nc->stdplane) return -1;

    // Check if terminal was resized; if so, resize stdplane to match
    unsigned new_rows, new_cols;
    nc_get_terminal_size(&new_rows, &new_cols);
    if (new_rows != nc->rows || new_cols != nc->cols) {
        nc->rows = new_rows;
        nc->cols = new_cols;
        nc->stdplane->rows = new_rows;
        nc->stdplane->cols = new_cols;
        nc_plane_free_cells(nc->stdplane);
        nc_plane_init_cells(nc->stdplane);
    }

    nc_render_plane(nc, nc->stdplane);
    return 0;
}

// ---------------------------------------------------------------------------
// notcurses_stdplane
// ---------------------------------------------------------------------------

struct ncplane* notcurses_stdplane(struct notcurses* nc) {
    return nc ? nc->stdplane : NULL;
}

// ---------------------------------------------------------------------------
// notcurses_stddim_yx
// ---------------------------------------------------------------------------

struct ncplane* notcurses_stddim_yx(struct notcurses* nc,
                                     unsigned* rows, unsigned* cols) {
    if (!nc) return NULL;

    // Refresh dimensions from kernel
    nc_get_terminal_size(&nc->rows, &nc->cols);

    if (rows) *rows = nc->rows;
    if (cols) *cols = nc->cols;
    return nc->stdplane;
}
