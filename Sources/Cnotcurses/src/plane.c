#include "internal.h"

// ---------------------------------------------------------------------------
// ncplane_create
// ---------------------------------------------------------------------------

struct ncplane* ncplane_create(struct ncplane* parent,
                               const ncplane_options* opts) {
    if (!parent || !opts) return NULL;

    struct ncplane* n = calloc(1, sizeof(struct ncplane));
    if (!n) return NULL;

    n->rows   = opts->rows > 0 ? opts->rows : 1;
    n->cols   = opts->cols > 0 ? opts->cols : 1;
    n->y      = opts->y;
    n->x      = opts->x;
    n->parent = parent;
    n->nc     = parent->nc;
    nc_plane_init_cells(n);

    return n;
}

// ---------------------------------------------------------------------------
// ncplane_destroy
// ---------------------------------------------------------------------------

int ncplane_destroy(struct ncplane* n) {
    if (!n) return -1;
    nc_plane_free_cells(n);
    free(n);
    return 0;
}

// ---------------------------------------------------------------------------
// ncplane_putstr — write a string starting at the cursor position
// Returns the number of columns written, or -1 on error.
// ---------------------------------------------------------------------------

int ncplane_putstr(struct ncplane* n, const char* s) {
    if (!n || !s) return -1;

    int written = 0;
    const unsigned char* p = (const unsigned char*)s;

    while (*p) {
        if (n->cursor_y < 0 || (unsigned)n->cursor_y >= n->rows ||
            n->cursor_x < 0 || (unsigned)n->cursor_x >= n->cols) {
            break;  // Out of bounds
        }

        nc_cell* cell = &n->cells[n->cursor_y * n->cols + n->cursor_x];

        // Determine UTF-8 byte length for this codepoint
        int byte_len;
        if (*p < 0x80)       byte_len = 1;
        else if (*p < 0xE0)  byte_len = 2;
        else if (*p < 0xF0)  byte_len = 3;
        else                 byte_len = 4;

        // Copy bytes into cell gcluster
        int i;
        for (i = 0; i < byte_len && p[i]; i++) {
            cell->gcluster[i] = (char)p[i];
        }
        cell->gcluster[i] = '\0';

        // Apply current plane state to cell
        cell->fg_rgb  = n->fg_rgb;
        cell->bg_rgb  = n->bg_rgb;
        cell->styles  = n->styles;
        cell->fg_set  = n->fg_set;
        cell->bg_set  = n->bg_set;
        cell->written = true;

        p += byte_len;
        n->cursor_x++;
        written++;
    }

    return written;
}

// ---------------------------------------------------------------------------
// ncplane_cursor_move_yx
// ---------------------------------------------------------------------------

int ncplane_cursor_move_yx(struct ncplane* n, int y, int x) {
    if (!n) return -1;
    n->cursor_y = y;
    n->cursor_x = x;
    return 0;
}

// ---------------------------------------------------------------------------
// ncplane_set_fg_rgb / ncplane_set_bg_rgb
// ---------------------------------------------------------------------------

int ncplane_set_fg_rgb(struct ncplane* n, unsigned channel) {
    if (!n) return -1;
    n->fg_rgb = channel;
    n->fg_set = true;
    return 0;
}

int ncplane_set_bg_rgb(struct ncplane* n, unsigned channel) {
    if (!n) return -1;
    n->bg_rgb = channel;
    n->bg_set = true;
    return 0;
}

// ---------------------------------------------------------------------------
// ncplane_set_styles / ncplane_off_styles
// ---------------------------------------------------------------------------

void ncplane_set_styles(struct ncplane* n, unsigned styles) {
    if (n) n->styles = styles;
}

void ncplane_off_styles(struct ncplane* n, unsigned styles) {
    if (n) n->styles &= ~styles;
}

// ---------------------------------------------------------------------------
// ncplane_erase — clear all cells and reset cursor
// ---------------------------------------------------------------------------

void ncplane_erase(struct ncplane* n) {
    if (!n) return;
    size_t count = (size_t)n->rows * n->cols;
    memset(n->cells, 0, count * sizeof(nc_cell));
    n->cursor_y = 0;
    n->cursor_x = 0;
    n->fg_set   = false;
    n->bg_set   = false;
    n->styles   = 0;
}

// ---------------------------------------------------------------------------
// ncplane_dim_yx
// ---------------------------------------------------------------------------

void ncplane_dim_yx(const struct ncplane* n, unsigned* rows, unsigned* cols) {
    if (!n) return;
    if (rows) *rows = n->rows;
    if (cols) *cols = n->cols;
}
