#ifndef CNOTCURSES_SHIM_H
#define CNOTCURSES_SHIM_H

#include <locale.h>
#include <notcurses/notcurses.h>

// Re-export NCKEY constants as static inline functions
// because the preterunicode() macro isn't importable by Swift.
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

#endif /* CNOTCURSES_SHIM_H */
