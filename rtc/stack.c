/*
 * RunTime C
 * Implementation
 *
 * C-based semi-equivalent to rt_parse.tcl and subordinate objects.
 *
 * Part: Stack
 */

#include <stack.h>

#define MARPA_RTC_STK_INIT 10

void
marpa_rtc_stack_init (marpa_rtc_stack* s)
{
    s->n    = 0;
    s->max  = MARPA_RTC_STK_INIT;
    s->data = (int*) ckalloc (s->max * sizeof(int));
}

void
marpa_rtc_stack_clear (marpa_rtc_stack* s)
{
    s->n = 0;
}

void
marpa_rtc_stack_push (marpa_rtc_stack* s, int v)
{
    if (s->n == s->max) {
	s->max += s->max;
	s->data = (int*) ckrealloc ((char*) s->data, s->max * sizeof(int));
    }
    s->data[s->n] = v;
    s->n ++;
}

int
marpa_rtc_stack_pop (marpa_rtc_stack* s)
{
    // assert: n > 0
    s->n --;
    // assert: n >= 0
    return s->data[s->n];
}

int 
marpa_rtc_stack_size (marpa_rtc_stack* s)
{
    return s->n;
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
