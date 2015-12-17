
#r gr-27 { :start does not allow any adverbs } syntax enforced
#r gr-5 { G1 start symbol must not occur as RHS ?! }
r ad-00 { G1 BNF rule accepts adverb action (default ?) }
r ad-01 { G1 BNF rule allows adverb bless (default ?) }
r ad-02 { G1 empty BNF rule allows no other adverb }
r ad-03 { G1 non-empty BNF rule allows adverb assoc (default ?) }
r ad-04 { G1 BNF rule allows no other adverb }
r ad-05 { G1 QU rule accepts adverb action  (default ?) }
r ad-06 { G1 QU rule allows adverb bless (default ?)}
r ad-07 { G1 QU rule allows adverb proper (default ?) }
r ad-08 { G1 QU rule allows adverb separator (default none) }
r ad-09 { G1 QU rule allows no other adverb }
r gl-00 { Grammar rewriting in the script layer is to be kept completely invisible from the user (Changes.pod) }
r gl-01 { Action callbacks (AC) go into a named closure. Ensemble, command prefix ... }
r gl-02 { action callback are called with a scratch object (per tree), children's SV as separate args, in order. }
r gr-00 { G1 symbols have leaf status (default yes) }
r gr-01 { G1 symbol is leaf if used on RHS and not as LHS, nor start }
r gr-02 { G1 symbol is token <=> leaf }
r gr-03 { |G1 tokens| != |L1 lexeme| => error }
r gr-04 { G1 has a start symbol }
r gr-06 { G1 symbol may have rules }
r gr-07 { G1 symbol with rules is not leaf } gr-1
r gr-08 { G1 rules are BNF or QU(ant) }
r gr-09 { G1 symbol may have more than one BNF rule }
r gr-10 { G1 symbol may have at most one QU rule }
r gr-11 { G1 symbol must not have BNF and QU rules }
r gr-12 { G1 symbol has rule-type (RT) status (none, bnf, quant) }
r gr-13 { G1 symbol RT(none) allows addition of any rule, switches to type of rule }
r gr-14 { G1 symbol RT(bnf) rejects addition of QU rules } gr-11
r gr-15 { G1 symbol RT(quant) rejects addition of BNF rules } gr-11
r gr-16 { G1 symbol RT(quant) rejects addition of QU rules } gr-10
r gr-17 { G1 symbol RT(bnf) rejects duplicate BNF rule }
r gr-18 { G1 BNF rules A, B identical/duplicates <=> same LHS, same length, same RHS, same order, masking irrelevant } gr-17
r gr-19 { G1 symbol may have only one set prioritized rules }
r gr-20 { G1 symbol has 'priority allowed' (PA) status (bool, default yes) }
r gr-21 { G1 symbol PA(yes) allows QU rule, goes PA(no), implied, P-rules are BNF } gr-15
r gr-22 { G1 symbol PA(yes) allows non-prio BNF rule, goes PA(no) } gr-19
r gr-23 { G1 symbol PA(yes) allows prio BNF rule, goes PA(no) } gr-19
r gr-24 { G1 start symbol default is LHS of first rule }
r gr-25 { :start can override implicit default }
r gr-26 { implicit default cannot override :start }
r gr-28 { :default may occur multiple times }
r gr-29 { :default affects only rules after it }
r gr-30 { :default allows adverb action }
r gr-31 { :default allows adverb bless }
r gr-32 { :default allows no other adverb }
r gr-32 { :default unspecified adverbs reset to global default }
r lex-00 { L0 symbols have a 'discard'-status (default no) }
r lex-01 { L0 symbols have a 'toplevel'-status (implied by the grammar, should be explicitly stored for ease of use) (default yes) }
r lex-02 { L0 symbol is toplevel if used as LHS, but not as RHS }
r lex-03 { L0 symbol is lexeme <=> toplevel && !discard }
r lex-04 { :discard L0 symbol set discard true }
r lex-05 { L0 symbol discarded && !toplevel => error }
r lex-06 { L0 :lexeme allows adverb event }
r lex-07 { L0 :lexeme allows adverb pause }
r lex-08 { L0 :lexeme allows adverb priority }
r lex-09 { L0 :lexeme allows no other adverbs }
r lex-10 { L0 symbol may have events (default none) } lex-6
r lex-11 { L0 symbol may pause (default no) } lex-7
r lex-12 { L0 symbol has priority (default 0) } lex-8
r lex-13
r lex-14
r lex-15
r lex-16
r lex-17
