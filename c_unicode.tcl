# -*- tcl -*-
##
# (c) 2017 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# # ## ### ##### ######## #############
## Unicode structures and utilities.

# Char class as sequence of codepoints and ranges (SCR)
# - Constructor
# - Destructor
# - Normalization
# - Negation
# - Expansion of case-equivalent codepoints (future)
#   (Requires access to unicode tables ... Requires tables in C, currently Tcl)
# - Structures
#   CR   :: Codepoint Range
#   SCR  :: Set of CR
#   NSCR :: Normalized SCR (ordered, no overlapping ranges)

# Char class as Alternation of Sequences of Byte Ranges (ASBR)
# - Constructor
# - Destructor
# - Compile SCR to ASBR
# - Structures
#   BR   :: Byte Range
#   SBR  :: Sequence of BRs (max length 6 - full utf character)
#   ASBR :: Alternations of SBR (char class as utf8 automaton/trie)

critcl::ccode {
    #include <assert.h>
    #include <string.h> /* memcopy */

    #ifndef UNI_MAX
    #define UNI_MAX 65535 /* BMP by default */
    #endif

    #undef  MAX
    #define MAX(a,b) (((a) > (b)) ? (a) : (b))

    /*
    ** Char class as sequence of codepoints and ranges
    */

    typedef struct CR {
	int start; /* First uni(code)point in the range */
	int end;   /* Last  uni(code)point in the range */
    } CR;

    typedef struct SCR {
	int n;     /* #ranges in the class */
	int max;   /* Allocated #ranges (n <= max) */
	int canon; /* Boolean flag, class is normalized, in canonical form */
	CR  cr[1]; /* Ranges allocated as part of the structure */
    } SCR;

    /*
    ** Char class as Alternation of Sequences of Byte Ranges
    */

    typedef struct BR {
	unsigned char start; /* First byte in the range */
	unsigned char end;   /* Last  byte in the range */
    } BR;

    typedef struct SBR {
	unsigned char n;      /* Length of the sequence */
	BR  br[6];            /* Ranges of the sequence */
    } SBR;

    typedef struct ccSBR {
	unsigned char closed; /* Bool flag. True stops further merging */
	struct ccSBR* next;   /* Next item in the stack */
	SBR           sbr;    /* SBR to handle */
    } ccSBR;

    typedef struct ASBR {
	int n;      /* Number of alternates in the class */
	SBR sbr[1]; /* Alternates allocated as part of structure */
    } ASBR;

    /*
    ** SCR
    ** - construct
    ** - destroy
    ** - extend
    ** - normalize
    ** - negate/complement
    */

    static SCR*
    marpa_scr_new (int n) {
	SCR* scr;

	if (n < 1) { n = 1; }

	scr = (SCR*) ckalloc (sizeof(SCR) + n*sizeof(CR));
	scr->n     = 0;   /* Nothing stored yet */
	scr->max   = n+1; /* Space for one more because of 'cr[1]' in SCR itself */
	scr->canon = 0;   /* Not normalized */
	return scr;
    }

    static void
    marpa_scr_destroy (SCR* scr) {
	/* Trivial because the ranges are allocated as part of the structure */
	ckfree ((char*) scr);
    }

    static void
    marpa_scr_add_range (SCR** pscr, int first, int last) {
	/* SCR** because the structure might be reallocated to make space */
	SCR* scr = *pscr;

	if (scr->n == scr->max) {
	    /* Double the space */
	    SCR* new = marpa_scr_new(2 * scr->max);
	    new->n = scr->n;

	    /* Copy content over */
	    memcpy (new->cr, scr->cr, scr->n * sizeof(CR));

	    /* Release old structure */
	    marpa_scr_destroy(scr);
	    scr = *pscr = new;
	}

	{
	    CR* cr = &scr->cr[scr->n - 1];
	    cr->start = first;
	    cr->end   = last;
	    scr->n ++;
	}

	scr->canon = 0; /* If it was normalized before it may not be anymore */
    }

    static void
    marpa_scr_add_code (SCR** scr, int codepoint) {
	/* SCR** because the structure might be reallocated to make space */
	marpa_scr_add_range (scr, codepoint, codepoint);
    }

    static int
    scr_compare (const void* ain, const void* bin) {
	CR* a = (CR*) ain;
	CR* b = (CR*) bin;

	/*
	** Sort by starting point first
	*/
	if (a->start < b->start) { return -1 ; }
	if (a->start > b->start) { return  1 ; }

	/*
	** For equal starting points sort by the end points, i.e the
	** shorter range comes before the longer
	*/
	if (a->end < b->end) { return -1 ; }
	if (a->end > b->end) { return  1 ; }

	/* Fully the same */
	return 0;
    }

    static void
    marpa_scr_norm (SCR* scr) {
	/* Normalization is done in place.
	** The resulting class cannot use more ranges than the input, making this possible.
	** It may have strictly less, when overlapping ranges are merged.
	**
	** Operation in 2 phases
	** - Sort the ranges in ascending order
	** - Iterate over the range and merge overlapping/adjacent ones.
	**
	** Of course, an already normalized class is not changed at all.
	** And a single-element class is canonical by definition.
	*/

	if (scr->canon) return;

	if (scr->n > 1) {
	    CR *previous, *current, *sentinel;
	    #define PS previous->start
	    #define CS current->start
	    #define PE previous->end
	    #define CE current->end

	    qsort (&scr->cr, scr->n, sizeof(CR), scr_compare);
	    /* Assertions, for all cr[i], cr[i+1] (P, C)
	    ** (P->start <= C->start)
	    ** (P->start == C->start) ==> (P->end <= C->end)
	    **
	    ** This means the ranges in question can have the
	    ** following relative locations to each other:
	    **
	    ** (1a) |--------|    \   P is a subset of C, or identical
	    **      |--------|     \  Extend it to be C.
	    **                      >
	    ** (1b) |--------|     /
	    **      |-----------| /
	    **
	    ** (2a) |--------|            \   C is contained in P,
	    **         |---|               \  or extends it at the end.
	    **                              |
	    ** (2b) |--------|              | Extend P to the max of (PE,CE)
	    **         |-----|              |
	    **                              > This is for CS <= PE+1
	    ** (2c) |--------|              | (== in that means adjacent)
	    **         |---------|          |
	    **                              |
	    ** (2d) |--------|             /
	    **                |---------| /
	    **
	    ** (3)  |--------|            \ C is after P, with a non-empty gap.
	    **                 |---|      / P is final, C can be shifted as the next P
	    */

	    for (
		 previous = &scr->cr[0],
		 current  = &scr->cr[1],
		 sentinel = &scr->cr[scr->n];
		 current != sentinel;
		 current ++) {
		if (PS == CS) {
		    /* (1a), (1b) above. */
		    PE = CE;
		    continue;
		}

		/* PS < CS ==> 2* or 3 */
		if (CS <= (PE+1)) {
		    /* (2a,b,c,d) */
		    PE = MAX (PE, CE);
		    continue;
		}

		/* (3) ((PE+1)) < CS <=> ((CS-PE) > 1), gap */
		previous ++;
		*previous = *current;
	    }

	    scr->n = previous - &scr->cr[0];
	    #undef PS
	    #undef PE
	    #undef CS
	    #undef CE
	}

	scr->canon = 1;
    }

    static SCR*
    marpa_scr_complement (SCR* scr) {
	/* NOTE: unicode max from a generated c_unidata.tcl file (tools/unidata.tcl)
	** New script ? (tools/unidata_c.tcl ?)
	*/
	int nc;
	SCR* ncr;
	int cmin, cmax;
	CR *current, *sentinel, *store;

	if (!scr->canon) marpa_scr_norm (scr);

	/*
	** For n ranges the complement has n-1 to n+1 ranges. This
	** depends on which of unicode limits are touched by the
	** class, or not.
	*/

	nc = scr->n + 1;
	if (scr->cr[0].start      ==       0) nc --;
	if (scr->cr[scr->n-1].end == UNI_MAX) nc --;

	ncr = marpa_scr_new (nc);
	cmin = 0;
	cmax = UNI_MAX;

	for (current  = &scr->cr[0],
	     sentinel = &scr->cr[scr->n-1],
	     store    = &ncr->cr[0];
	     current != sentinel;
	     current ++) {
	    if (current->start > cmin) {
		store->start = cmin;
		store->end   = current->start - 1;
		store ++;
	    }
	    cmin = current->end + 1;
	}

	if (cmin < cmax) {
	    store->start = cmin;
	    store->end   = cmax;
	    store ++;
	}
	
	ncr->n = store - &ncr->cr[0];
	ncr->canon = 1;

	assert (ncr->n == nc);
	return ncr;
    }

    /*
    ** ASBR
    ** - construct
    ** - destroy
    */

    static ASBR*
    marpa_asbr_new (SCR* scr) {
    }

    static void
    marpa_asbr_destroy (ASBR* asbr) {
	/* Trivial because the alternates are allocated as part of the structure */
	ckfree ((char*) asbr);
    }

}

# # ## ### ##### ######## #############
return
