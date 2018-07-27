/* Runtime for C-engine (RTC). Implementation. (Stacks of bytes)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018-present Andreas Kupries
 *
 * Requirements - Note, assertions, allocations and tracing via an external environment header.
 */

#include <environment.h>
#include <bytestack_int.h>

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

marpatcl_rtc_bytestack_p
marpatcl_rtc_bytestack_cons (int initial_capacity)
{
    marpatcl_rtc_bytestack_p s;
    TRACE_FUNC ("(initial_capacity %d)", initial_capacity);
    
    s = ALLOC (marpatcl_rtc_bytestack);

    if (initial_capacity < 0) {
	initial_capacity = DEFAULT_INITIAL_CAPACITY;
    }
    TRACE ("initial_capacity %d", initial_capacity);
    
    SZ  = 0;
    CAP = initial_capacity;
    VAL = NALLOC (unsigned char, initial_capacity);

    TRACE_RETURN ("(bytestack*) %p", s);
}

void
marpatcl_rtc_bytestack_destroy (marpatcl_rtc_bytestack_p s)
{
    TRACE_FUNC ("(bytestack*) %p)", s);

    FREE (VAL);
    FREE (s);

    TRACE_RETURN_VOID;
}

int 
marpatcl_rtc_bytestack_size (marpatcl_rtc_bytestack_p s)
{
    TRACE_FUNC ("(bytestack*) %p)", s);
    TRACE_RETURN ("%d", SZ);
}

void
marpatcl_rtc_bytestack_push (marpatcl_rtc_bytestack_p s, int v)
{
    TRACE_FUNC ("(bytestack*) %p, v %d)", s, v);

    if (SZ == CAP) {
	CAP += CAP;
	VAL = REALLOC (VAL, unsigned char, CAP);
    }
    VAL [SZ] = v;
    SZ ++;

    TRACE_RETURN_VOID;
}

int
marpatcl_rtc_bytestack_pop (marpatcl_rtc_bytestack_p s)
{
    TRACE_FUNC ("(bytestack*) %p)", s);
    ASSERT (SZ > 0, "Pop from empty bytestack");

    SZ --;

    TRACE_RETURN ("%d", VAL [SZ]);
}

int
marpatcl_rtc_bytestack_get (marpatcl_rtc_bytestack_p s, int at)
{
    TRACE_FUNC ("(bytestack*) %p, at %d)", s, at);
    ASSERT_BOUNDS (at, SZ);
    TRACE_RETURN ("%d", VAL [at]);
}

void
marpatcl_rtc_bytestack_clear (marpatcl_rtc_bytestack_p s)
{
    TRACE_FUNC ("(bytestack*) %p)", s);

    SZ = 0;

    TRACE_RETURN_VOID;
}

void
marpatcl_rtc_bytestack_move (marpatcl_rtc_bytestack_p dst, marpatcl_rtc_bytestack_p src, int n)
{
    TRACE_FUNC ("(bytestack*) dst %p <- (bytestack*) src %p [n %d])", dst, src, n);

    while (n) {
	// TODO: inline, move checks and expansion done by push out of the loop
	marpatcl_rtc_bytestack_push (dst, marpatcl_rtc_bytestack_pop (src));
	n--;
    }

    TRACE_RETURN_VOID;
}

unsigned char*
marpatcl_rtc_bytestack_data (marpatcl_rtc_bytestack_p s, int* sz)
{
    TRACE_FUNC ("(bytestack*) %p, (int*) sz %p)", s, sz);

    *sz = SZ;

    TRACE_RETURN ("(int*)", VAL);
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
