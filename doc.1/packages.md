# System Classes

Table of all classes, important commands, and other code in the
current `marpa`.  These are grouped into packages according to the
system architecture.

|Class                          |File                   |Part/Package           |
|---                            |---                    |---                    |
|Marpa Types                    |c/type_conversions.tcl |marpa::c               |
|marpa::Bocage                  |c/bocage.tcl           |marpa::c               |
|marpa::Grammar                 |c/grammar.tcl          |marpa::c               |
|marpa::Recognizer              |c/recognizer.tcl       |marpa::c               |
|marpa::check-version           |c/context.tcl          |marpa::c               |
|marpa::version                 |c/context.tcl          |marpa::c               |
|marpatcl_context               |c/context.tcl          |marpa::c               |
|marpatcl_ecode                 |c/errors.tcl           |marpa::c               |
|marpatcl_error                 |c/errors.tcl           |marpa::c               |
|marpatcl_event                 |c/events.tcl           |marpa::c               |
|marpatcl_step                  |c/steps.tcl            |marpa::c               |
|marpatcl_steptype              |c/steps.tcl            |marpa::c               |
|marpatcl_throw/result          |c/support.tcl          |marpa::c               |
|~~~                            |~~~                    |~~~                    |
|marpa::location:*              |generic/location.tcl   |marpa::util            |
|marpa::sequencing::*           |generic/sequencing.tcl |marpa::util            |
|method-benchmarking            |generic/timing.tcl     |marpa::util            |
|marpa:*                        |generic/support.tcl    |marpa::util            |
|~~~                            |~~~                    |~~~                    |
|marpa::engine::tcl::parser     |<ET>/rt_parse.tcl      |marpa::rt::tcl         |
|marpa::engine::tcl::lex        |<ET>/rt_lex.tcl        |marpa::rt::tcl         |
|marpa::parser                  |<ET>/parser.tcl        |marpa::rt::tcl         |
|marpa::lexer                   |<ET>/lexer.tcl         |marpa::rt::tcl         |
|marpa::engine                  |<ET>/engine.tcl        |marpa::rt::tcl         |
|marpa::engine::debug           |<ET>/engine_debug.tcl  |marpa::rt::tcl         |
|marpa::gate                    |<ET>/gate.tcl          |marpa::rt::tcl         |
|marpa::inbound                 |<ET>/inbound.tcl       |marpa::rt::tcl         |
|marpa::semcore                 |<ET>/semcore.tcl       |marpa::rt::tcl         |
|marpa::semstd::*               |<ET>/semstd.tcl        |marpa::rt::tcl         |
|marpa::semstore                |<ET>/semstore.tcl      |marpa::rt::tcl         |
|~~~                            |~~~                    |~~~                    |
|rtc/*.[ch]                     |rtc/*.[ch]             |marpa::rt::c           |
|rtc/????                       |rtc/*.tcl              |marpa::rt::c           |
|~~~                            |~~~                    |~~~                    |
|marpa::slif::semantics         |slif/semantics/*.tcl   |marpa::slif::semantics |
|marpa::slif::semantics::*      |-"-                    |marpa::slif::semantics |
| literal_util - split out ?!   |                       |                       |
|~~~                            |~~~                    |~~~                    |
|marpa::slif::parser            |slif/boot_parser.tcl   |marpa::slif::parser    |
|~~~                            |~~~                    |~~~                    |
|marpa::export::gc              |export/gc.tcl          |marpa::export::gc      |
|marpa::export::gc-compact      |export/gc_compact.tcl  |marpa::export::gc-compact|
|marpa::export::tparse          |export/tparse.tcl      |marpa::export::tparse  |
|marpa::export::tlex            |export/tlex.tcl        |marpa::export::tlex    |
|marpa::export::cparse-critcl   |export/cparse-critcl.tcl|marpa::export::cparse-critcl|
|marpa::export::cparse-raw      |export/cparse-raw.tcl  |marpa::export::cparse-raw|
|marpa::export::clex-critcl     |export/clex-critcl.tcl |marpa::export::clex-critcl|
|~~~                            |~~~                    |~~~                    |
|marpa::export::core::tcl       |export/core/tcl.tcl    |marpa::export::rt::tcl |
|marpa::export::core::rtc       |export/core/rtc.tcl    |marpa::export::rt::c   |
|~~~                            |~~~                    |~~~                    |
|marpa::export::config          |export/config.tcl      |marpa::export::config  |
|~~~                            |~~~                    |~~~                    |

<ET> = engine/tcl





|~~~                            |~~~                    |~~~                    |
|marpa::unicode::2asbr          |c/asbr_objtype.tcl     |marpa::unicode         |
|marpa::unicode::negate-class   |c/cc_objtype.tcl       |marpa::unicode         |
|marpa::unicode::norm-class     |c/cc_objtype.tcl       |marpa::unicode         |
|marpatcl_asbr/scr_...          |c/unicode.tcl          |marpa::unicode         |
|marpa::unicode:*               |generic/unicode.tcl    |marpa::unicode         |
|CT generate-tables             |c/utilities.tcl        |marpa::unicode         |


|~~~                            |~~~                    |~~~                    |
|marpa::slif::container         |slif/container/*.tcl   |marpa::slif::container |
|marpa::slif::container::*      |-"-                    |marpa::slif::container |
