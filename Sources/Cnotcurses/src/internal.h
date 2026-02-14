#ifndef NOTCURSES_INTERNAL_H
#define NOTCURSES_INTERNAL_H

#include "notcurses_compat.h"
#include <termios.h>
#include <sys/ioctl.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>

// ---------------------------------------------------------------------------
// Cell — one character position in a plane buffer
// ---------------------------------------------------------------------------
typedef struct nc_cell {
    char     gcluster[8];   // UTF-8 encoded grapheme (up to 4 bytes + NUL)
    uint32_t fg_rgb;        // Foreground 0x00RRGGBB
    uint32_t bg_rgb;        // Background 0x00RRGGBB
    uint32_t styles;        // NCSTYLE_* bitmask
    bool     fg_set;        // Foreground was explicitly set
    bool     bg_set;        // Background was explicitly set
    bool     written;       // Cell has content
} nc_cell;

// ---------------------------------------------------------------------------
// Full struct definitions (opaque to Swift, visible to .c files)
// ---------------------------------------------------------------------------

struct ncplane {
    nc_cell*          cells;      // Row-major cell buffer
    unsigned          rows;
    unsigned          cols;
    int               y;          // Position relative to parent / screen
    int               x;
    int               cursor_y;
    int               cursor_x;
    uint32_t          fg_rgb;     // Current drawing foreground
    uint32_t          bg_rgb;     // Current drawing background
    uint32_t          styles;     // Current drawing style bits
    bool              fg_set;     // FG has been set via set_fg_rgb
    bool              bg_set;     // BG has been set via set_bg_rgb
    struct ncplane*   parent;     // NULL for stdplane
    struct notcurses* nc;         // Owner context
};

struct notcurses {
    struct ncplane*  stdplane;
    struct termios   original;    // Saved terminal state
    FILE*            fp;          // Output stream
    unsigned         rows;
    unsigned         cols;
    uint64_t         flags;
    bool             alt_screen;  // Alternate screen is active
};

// ---------------------------------------------------------------------------
// Internal helpers (implemented in buffer.c)
// ---------------------------------------------------------------------------
void nc_plane_init_cells(struct ncplane* n);
void nc_plane_free_cells(struct ncplane* n);
void nc_render_plane(struct notcurses* nc, struct ncplane* n);
void nc_get_terminal_size(unsigned* rows, unsigned* cols);

#endif /* NOTCURSES_INTERNAL_H */
