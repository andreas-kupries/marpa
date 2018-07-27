/* Runtime for C-engine (RTC). Implementation. (Stacks of ints)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2017-present Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <stack_int.h>

TRACE_OFF;

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

    TRACE ("(int*) data %p", VAL);
    TRACE_RETURN ("((stack*) %p)", s);
}

void
marpatcl_rtc_stack_destroy (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("((stack*) %p, (int*) data %p)", s, VAL);

    FREE (VAL);
    FREE (s);

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_stack_size (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("((stack*) %p, (int*) data %p)", s, VAL);
    TRACE_RETURN ("%d", SZ);
}

void
marpatcl_rtc_stack_push (marpatcl_rtc_stack_p s, int v)
{
    TRACE_FUNC ("((stack*) %p, (int*) data %p [%d] = v %d)", s, VAL, SZ, v);

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
    TRACE_FUNC ("((stack*) %p, (int*) data %p)", s, VAL);
    ASSERT (SZ > 0, "Pop from empty stack");

    SZ --;

    TRACE_RETURN ("%d", VAL [SZ]);
}

int
marpatcl_rtc_stack_get (marpatcl_rtc_stack_p s, int at)
{
    TRACE_FUNC ("((stack*) %p, (int*) data %p, at %d)", s, VAL, at);
    ASSERT_BOUNDS (at, SZ);
    TRACE_RETURN ("%d", VAL [at]);
}

void
marpatcl_rtc_stack_clear (marpatcl_rtc_stack_p s)
{
    TRACE_FUNC ("((stack*) %p, (int*) data %p)", s, VAL);

    SZ = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_stack_move (marpatcl_rtc_stack_p dst, marpatcl_rtc_stack_p src, int n)
{
    TRACE_FUNC ("((stack*) dst %p <- (stack*) src %p [n %d])", dst, src, n);

    while (n) {
	// TODO: inline, move checks and expansion done by push out of the loop
	marpatcl_rtc_stack_push (dst, marpatcl_rtc_stack_pop (src));
	n--;
    }

    TRACE_RETURN_VOID;
}

int*
marpatcl_rtc_stack_data (marpatcl_rtc_stack_p s, int* sz)
{
    TRACE_FUNC ("((stack*) %p, (int*) sz %p)", s, sz);

    *sz = SZ;

    TRACE_RETURN ("(int*) %p", VAL);
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
