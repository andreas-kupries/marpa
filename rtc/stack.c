/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Stack
 */

#include <stack.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <tcl.h>

#define MARPA_RTC_STK_INIT 10

#define SZ  (s->n)
#define CAP (s->max)
#define STK (s->data)

/*
 */

void
marpa_rtc_stack_init (marpa_rtc_stack* s)
{
    SZ  = 0;
    CAP = MARPA_RTC_STK_INIT;
    STK = NALLOC (int, CAP);
}

void
marpa_rtc_stack_release (marpa_rtc_stack* s)
{
    FREE (STK); STK = 0;
    SZ = CAP = 0;
}

void
marpa_rtc_stack_clear (marpa_rtc_stack* s)
{
    SZ = 0;
}

void
marpa_rtc_stack_push (marpa_rtc_stack* s, int v)
{
    if (SZ == CAP) {
	CAP += CAP;
	STK = REALLOC (STK, int, CAP);
    }
    STK [SZ] = v;
    SZ ++;
}

int
marpa_rtc_stack_pop (marpa_rtc_stack* s)
{
    ASSERT (SZ > 0, "Pop from empty stack");
    SZ --;
    return STK [SZ];
}

int 
marpa_rtc_stack_size (marpa_rtc_stack* s)
{
    return SZ;
}

void
marpa_rtc_stack_move (marpa_rtc_stack* dst, marpa_rtc_stack* src, int n)
{
    int v;
    while (n) {
	v = marpa_rtc_stack_pop (src);
	marpa_rtc_stack_push (dst, v);
    }
}


/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
