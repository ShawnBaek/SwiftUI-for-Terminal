#ifndef NOTCURSES_COMPAT_H
#define NOTCURSES_COMPAT_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <locale.h>
#include <time.h>

// ---------------------------------------------------------------------------
// Opaque types — forward-declared only.
// Swift imports pointers to these as OpaquePointer.
// ---------------------------------------------------------------------------
struct notcurses;
struct ncplane;

// ---------------------------------------------------------------------------
// Transparent structs — fully defined so Swift can construct them.
// ---------------------------------------------------------------------------

typedef struct notcurses_options {
    uint64_t flags;
} notcurses_options;

typedef struct ncplane_options {
    int y;
    int x;
    unsigned rows;
    unsigned cols;
} ncplane_options;

typedef struct ncinput {
    uint32_t id;
    int y;
    int x;
    bool shift;
    bool ctrl;
    bool alt;
} ncinput;

// ---------------------------------------------------------------------------
// Option flags (match real notcurses values)
// ---------------------------------------------------------------------------
#define NCOPTION_NO_ALTERNATE_SCREEN  0x0040ull
#define NCOPTION_SUPPRESS_BANNERS     0x0020ull

// ---------------------------------------------------------------------------
// Style flags (match real notcurses values)
// ---------------------------------------------------------------------------
#define NCSTYLE_BOLD       0x0020u
#define NCSTYLE_ITALIC     0x0010u
#define NCSTYLE_UNDERLINE  0x0008u
#define NCSTYLE_STRUCK     0x0200u

// ---------------------------------------------------------------------------
// Key constants (supplementary private use area, matching notcurses)
// ---------------------------------------------------------------------------
#define NCKEY_INVALID   0x100000u
#define NCKEY_RESIZE    0x100001u
#define NCKEY_UP        0x100002u
#define NCKEY_RIGHT     0x100003u
#define NCKEY_DOWN      0x100004u
#define NCKEY_LEFT      0x100005u
#define NCKEY_INS       0x100006u
#define NCKEY_DEL       0x100007u
#define NCKEY_BACKSPACE 0x100008u
#define NCKEY_PGDOWN    0x100009u
#define NCKEY_PGUP      0x10000au
#define NCKEY_HOME      0x10000bu
#define NCKEY_END       0x10000cu
#define NCKEY_ENTER     0x100079u
#define NCKEY_ESC       0x100082u
#define NCKEY_TAB       0x100083u

// ---------------------------------------------------------------------------
// Shim functions — expose NCKEY_* constants to Swift
// (Swift cannot import C preprocessor macros that aren't simple literals)
// ---------------------------------------------------------------------------
static inline uint32_t nckey_invalid(void)   { return NCKEY_INVALID; }
static inline uint32_t nckey_resize(void)    { return NCKEY_RESIZE; }
static inline uint32_t nckey_up(void)        { return NCKEY_UP; }
static inline uint32_t nckey_right(void)     { return NCKEY_RIGHT; }
static inline uint32_t nckey_down(void)      { return NCKEY_DOWN; }
static inline uint32_t nckey_left(void)      { return NCKEY_LEFT; }
static inline uint32_t nckey_ins(void)       { return NCKEY_INS; }
static inline uint32_t nckey_del(void)       { return NCKEY_DEL; }
static inline uint32_t nckey_backspace(void) { return NCKEY_BACKSPACE; }
static inline uint32_t nckey_pgdown(void)    { return NCKEY_PGDOWN; }
static inline uint32_t nckey_pgup(void)      { return NCKEY_PGUP; }
static inline uint32_t nckey_home(void)      { return NCKEY_HOME; }
static inline uint32_t nckey_end(void)       { return NCKEY_END; }
static inline uint32_t nckey_enter(void)     { return NCKEY_ENTER; }
static inline uint32_t nckey_esc(void)       { return NCKEY_ESC; }
static inline uint32_t nckey_tab(void)       { return NCKEY_TAB; }

// ---------------------------------------------------------------------------
// Function prototypes
// ---------------------------------------------------------------------------

// Lifecycle
struct notcurses* notcurses_init(const notcurses_options* opts, FILE* fp);
int notcurses_stop(struct notcurses* nc);
int notcurses_render(struct notcurses* nc);
struct ncplane* notcurses_stdplane(struct notcurses* nc);
struct ncplane* notcurses_stddim_yx(struct notcurses* nc,
                                     unsigned* rows, unsigned* cols);

// Input
uint32_t notcurses_get(struct notcurses* nc,
                       const struct timespec* ts, ncinput* ni);

// Plane operations
struct ncplane* ncplane_create(struct ncplane* parent,
                               const ncplane_options* opts);
int ncplane_destroy(struct ncplane* n);
int ncplane_putstr(struct ncplane* n, const char* s);
int ncplane_cursor_move_yx(struct ncplane* n, int y, int x);
int ncplane_set_fg_rgb(struct ncplane* n, unsigned channel);
int ncplane_set_bg_rgb(struct ncplane* n, unsigned channel);
void ncplane_set_styles(struct ncplane* n, unsigned styles);
void ncplane_off_styles(struct ncplane* n, unsigned styles);
void ncplane_erase(struct ncplane* n);
void ncplane_dim_yx(const struct ncplane* n,
                    unsigned* rows, unsigned* cols);

#endif /* NOTCURSES_COMPAT_H */
