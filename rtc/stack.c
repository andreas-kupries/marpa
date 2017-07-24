/* Runtime for C-engine (RTC). Implementation. (Stacks of ints)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <stack_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Shorthands
 */

#define DEFAULT_INITIAL_CAPACITY 10

#define SZ  (s->size)
#define CAP (s->capacity)
#define VAL (s->data)

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * API
 */

marpatcl_rtc_stack_p
marpatcl_rtc_stack_cons (int initial_capacity)
{
    marpatcl_rtc_stack_p s = ALLOC (marpatcl_rtc_stack);

    if (initial_capacity < 0) {
	initial_capacity = DEFAULT_INITIAL_CAPACITY;
    }
    
    SZ  = 0;
    CAP = initial_capacity;
    VAL = NALLOC (int, initial_capacity);
    return s;
}

void
marpatcl_rtc_stack_destroy (marpatcl_rtc_stack_p s)
{
    FREE (VAL);
    FREE (s);
}

int 
marpatcl_rtc_stack_size (marpatcl_rtc_stack_p s)
{
    return SZ;
}

void
marpatcl_rtc_stack_push (marpatcl_rtc_stack_p s, int v)
{
    if (SZ == CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, int, CAP);
    }
    VAL [SZ] = v;
    SZ ++;
}

int
marpatcl_rtc_stack_pop (marpatcl_rtc_stack_p s)
{
    ASSERT (SZ > 0, "Pop from empty stack");
    SZ --;
    return VAL [SZ];
}

void
marpatcl_rtc_stack_clear (marpatcl_rtc_stack_p s)
{
    SZ = 0;
}

void
marpatcl_rtc_stack_move (marpatcl_rtc_stack_p dst, marpatcl_rtc_stack_p src, int n)
{
    while (n) {
	marpatcl_rtc_stack_push (dst, marpatcl_rtc_stack_pop (src));
	n--;
    }
}

/*
 * - - -- --- ----- -------- ------------- ---------------------
 */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
