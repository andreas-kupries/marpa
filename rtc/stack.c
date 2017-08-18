/* Runtime for C-engine (RTC). Implementation. (Stacks of ints)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017 Andreas Kupries
 *
 * Requirements
 */

#include <stack_int.h>
#include <critcl_alloc.h>
#include <critcl_assert.h>
#include <critcl_trace.h>

TRACE_ON;

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
    marpatcl_rtc_stack_p s;
    TRACE_FUNC ("(initial_capacity %d)", initial_capacity);
    
    s = ALLOC (marpatcl_rtc_stack);

    if (initial_capacity < 0) {
	initial_capacity = DEFAULT_INITIAL_CAPACITY;
    }
    TRACE ("initial_capacity %d", initial_capacity);
    
    SZ  = 0;
    CAP = initial_capacity;
    VAL = NALLOC (int, initial_capacity);

    TRACE_RETURN ("(stack*) %p", s);
}

void
marpatcl_rtc_stack_destroy (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("(stack*) %p)", s);

    FREE (VAL);
    FREE (s);

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_stack_size (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("(stack*) %p)", s);
    TRACE_RETURN ("%d", SZ);
}

void
marpatcl_rtc_stack_push (marpatcl_rtc_stack_p s, int v)
{
    TRACE_FUNC ("(stack*) %p, v %d)", s, v);

    if (SZ == CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, int, CAP);
    }
    VAL [SZ] = v;
    SZ ++;

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_stack_pop (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("(stack*) %p)", s);
    ASSERT (SZ > 0, "Pop from empty stack");

    SZ --;

    TRACE_RETURN ("%d", VAL [SZ]);
}

void
marpatcl_rtc_stack_clear (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("(stack*) %p)", s);

    SZ = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_stack_move (marpatcl_rtc_stack_p dst, marpatcl_rtc_stack_p src, int n)
{
    TRACE_FUNC ("(stack*) dst %p <- (stack*) src %p [n %d])", dst, src, n);

    while (n) {
	// TODO: inline, move checks and expansion done by push out of the loop
	marpatcl_rtc_stack_push (dst, marpatcl_rtc_stack_pop (src));
	n--;
    }

    TRACE_RETURN_VOID;
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
