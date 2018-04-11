/* Runtime for C-engine (RTC). Implementation. (Semantic values, and ASTs)
 * - - -- --- ----- -------- ------------- ---------------------
 * (c) 2018 Andreas Kupries
 *
 * Debugging helper. Memory diagnosis.
 * Track all allocated values in a global list (***), plus origin information.
 *
 * (***) Do not use multi-threaded, not mutex protected
 */
#ifdef SEM_REF_DEBUG
#include <environment.h>
#include <sem_int.h>

TRACE_OFF;

#define STD stdout

/*
 * - - -- --- ----- -------- ------------- ---------------------
 * Debugging support.
 * Dummy values anchoring the double-linked in-use list.
 * No special cases for removal, all nodes to remove are in the
 * middle, none at the borders.
 */

static marpatcl_rtc_sv anchor = {0, 0, 0, &anchor, &anchor, 0, 0};

void
marpatcl_rtc_sv_dump (void)
{
    TRACE_FUNC ("%s", "");

    marpatcl_rtc_sv_p sv = anchor.next;
    anchor.prev->next = 0;
    while (sv && sv->ofile) {
	svd_report ("LOST", sv->ofile, sv->oline, sv);
	sv = sv->next;
    }
    anchor.prev->next = &anchor;
    fprintf (STD, "SVX\n");
    TRACE_RETURN_VOID;
}

void
svd_report (const char* tag, const char* ofile, int oline, marpatcl_rtc_sv_p sv)
{
    char* svs;
    int t = T_GET;
    int size = sizeof (*sv);
    if (t == marpatcl_rtc_sv_type_string) {
	size += strlen(STR) + 1; // Count the terminating \0!
    } else if (t == marpatcl_rtc_sv_type_vec) {
	size += VEC->size * sizeof (marpatcl_rtc_sv_p);
    }

    fprintf (STD, "SV %s %p f %s @ %d t %s rc %d sz %d",
	     tag, sv, ofile, oline, sv_type (sv), sv->refCount,
	     size);

    if (t == marpatcl_rtc_sv_type_vec) {
	int k;
	fprintf (STD, " vsz %d [", VEC->size);
	for (k=0; k < VEC->size; k++) {
	    fprintf (STD, " %p", VEC->data [k]);
	}
	fprintf (STD, " ]");
    } else {
	svs = marpatcl_rtc_sv_show (sv, 0);
	fprintf (STD, " str {%s}", svs);
	FREE (svs);
    }

    fprintf (STD, "\n");
    fflush  (STD);
}

void
svd_link (const char* ofile, int oline, marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p)", sv);
    marpatcl_rtc_sv_p first = anchor.next;

    sv->next = first;
    sv->prev = &anchor;
    anchor.next = sv;
    first->prev = sv;

    sv->ofile = ofile;
    sv->oline = oline;

    svd_report ("NEW_", ofile, oline, sv);
    TRACE_RETURN_VOID;
}

void
svd_unlink (const char* ofile, int oline, marpatcl_rtc_sv_p sv)
{
    TRACE_FUNC ("((sv*) %p)", sv);

    svd_report ("DELE", ofile, oline, sv);

    sv->prev->next = sv->next;
    sv->next->prev = sv->prev;
    sv->next = 0;
    sv->prev = 0;

    TRACE_RETURN_VOID;
}

#endif /* SEM_REF_DEBUG */

/*
 * Local Variables:
 * mode: c
 * c-basic-offset: 4
 * fill-column: 78
 * End:
 */
