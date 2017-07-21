/*
 * RunTime C - Implementation
 * Helper: Stacks of integers.
 */

#include <stack_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <tcl.h>

#define MARPA_RTC_STACK_DEFAULT_INITIAL_CAP 10

#define SZ  (s->size)
#define CAP (s->capacity)
#define VAL (s->data)

/*
 */

marpa_rtc_stack_p
marpa_rtc_stack_cons (int initial_capacity)
{
    marpa_rtc_stack_p s = ALLOC (marpa_rtc_stack);
    if (initial_capacity < 0) {
	initial_capacity = MARPA_RTC_STACK_DEFAULT_INITIAL_CAP;
    }
    
    SZ  = 0;
    CAP = initial_capacity;
    VAL = NALLOC (int, initial_capacity);
    return s;
}

void
marpa_rtc_stack_destroy (marpa_rtc_stack_p s)
{
    FREE (VAL);
    FREE (s);
}

int 
marpa_rtc_stack_size (marpa_rtc_stack_p s)
{
    return SZ;
}

void
marpa_rtc_stack_push (marpa_rtc_stack_p s, int v)
{
    if (SZ == CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, int, CAP);
    }
    VAL [SZ] = v;
    SZ ++;
}

int
marpa_rtc_stack_pop (marpa_rtc_stack_p s)
{
    ASSERT (SZ > 0, "Pop from empty stack");
    SZ --;
    return VAL [SZ];
}

void
marpa_rtc_stack_clear (marpa_rtc_stack_p s)
{
    SZ = 0;
}

void
marpa_rtc_stack_move (marpa_rtc_stack_p dst, marpa_rtc_stack_p src, int n)
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
