# -*- tcl -*-
##
# (c) 2015 Andreas Kupries http://wiki.tcl.tk/andreas%20kupries
#                          http://core.tcl.tk/akupries/
##
# This code is BSD-licensed.

# READ online DSL.pod
# - http://search.cpan.org/~jkegl/Marpa-R2-3.000000/pod/Scanless/DSL.pod#Event_name
# Differs from local DSL.pod

# Grammar container for SLIF. Able to directly ingest a SLIF AST.
# Accessor methods to all stored data allow a generator to get all the
# information they need for their operation.

# NOTE: TODO Recognize blessings, ignore them, print warnings.
# NOTE: TODO New ADA 'end' (location)
# NOTE: TODO New global G1 adverb 'action-prefix' or similar - shared cmd
#       prefix for actions. Replaces blessings

# # ## ### ##### ######## #############
## Requisites

package require Tcl 8.5
package require TclOO         ;# Implies Tcl 8.5 requirement.
package require debug
package require debug::caller
package require oo::util      ;# mymethod

debug define marpa/grammar
#debug prefix marpa/grammar {[debug caller] | }

# # ## ### ##### ######## #############
## 

oo::class create marpa::grammar {
    # Data structures.

    variable __indent ; # debug narrative, indentation
    variable mypass   ; # pass information for statements/0, statement/*, see SKIP

    constructor {ast} {
	debug.marpa/grammar {[marpa::D {
	    set __indent {}
	}][debug caller 2] | }
	# Shortcut access to all methods (implicit "my")

	global/init
	l0/init
	g1/init

	foreach m [info class methods [self class] -private] {
	    link [list $m $m]
	}

	# This needs the methods as immediately accessible commands.
	eval $ast

	debug.marpa/grammar {[debug caller 2] | /ok}
	return
    }

    # # ## ### ##### ######## #############
    ## AST processing methods

    method statements/0 {children} { # OK <statement>...
	# MultiPass ... Pull global information first, then run the dependent parts.
	IS {
	    set mypass global ; EVAL
	    set mypass other  ; EVAL
	}
    }
    method statement/0 {children} { # OK <start rule>
	IS { SKIP global ; EVAL }
    }
    method statement/1 {children} { # OK <empty rule>
	IS { SKIP global ; EVAL }
    }
    method statement/2 {children} { # OK <null statement>
	IS ; # Ignore, do nothing
    }
    method statement/3 {children} { # OK <statement group>
	IS { SKIP global ; EVAL }
    }
    method statement/4 {children} { # OK <priority rule>
	IS { SKIP global ; EVAL }
    }
    method statement/5 {children} { # OK <quantified rule>
	IS { SKIP global ; EVAL }
    }
    method statement/6 {children} { # OK <discard rule>
	IS { SKIP global ; EVAL }
    }
    method statement/7 {children} { # OK <default rule>
	IS { SKIP global ; EVAL }
    }
    method statement/8 {children} { # OK <lexeme default statement>
	IS { SKIP other ; EVAL }
    }
    method statement/9 {children} { # FAIL NODOC <discard default statement>
	IS { SKIP other ; error "undocumented" }
    }
    method statement/10 {children} { # OK <lexeme rule>
	IS { SKIP global ; EVAL }
    }
    method statement/10 {children} { # OK <completion event declaration>
	IS { SKIP other ; EVAL }
    }
    method statement/12 {children} { # OK <nulled event declaration>
	IS { SKIP other ; EVAL }
    }
    method statement/13 {children} { # OK <predicted event declaration>
	IS { SKIP other ; EVAL }
    }
    method statement/14 {children} { # FAIL NODOC <current lexer statement>
	IS { SKIP other ; error "undocumented" }
    }
    method statement/15 {children} { # OK <inaccessible statement>
	IS { SKIP other ; EVAL }
    }

    # Executing the statements in order updates the grammar ...

    # DSL.pod - By default, the start symbol of the grammar is the LHS
    #           of the first G1 rule. This default can be made
    #           explicit or overriden by using an explicit start
    #           rule. The LHS of this rule is the :start pseudo-
    #           symbol. Only one RHS alternative is allowed. This RHS
    #           alternative must contain only one symbol name, and
    #           that symbol will be the start symbol of the G1
    #           grammar. No adverbs should be associated with the RHS
    #           alternative. Start rules must be G1 rules.

    method {start rule/0} {children} { # OK <symbol>
	# start rule (see statement/0)
	ISX { g1/start [PASS1] yes }
    }
    method {start rule/1} {children} { # OK <symbol>
	# start rule (see statement/0)
	ISX { g1/start [PASS1] yes }
    }

    method {null statement/0} {children} { # OK ()
	error "cannot be called" ; # (see statement/2)
    }

    # DSL.pod - Statements can be grouped, using curly braces. These
    #           do not create scopes -- the curly braces serve merely
    #           to group and to separate groups of statements.

    method {statement group/0} {children} { # OK <statement>...
	# Recurse into the grouping. No scope changes.
	IS { EVAL }
    }

    # DSL.pod - The purpose of the default pseudo-rule is to change
    #           the defaults for rule adverbs. Technically, it has one
    #           RHS alternative, but this must always contain zero RHS
    #           primaries. Default pseudo-rules do not affect the
    #           defaults for L0 rules or for lexemes. There may be
    #           more than one default pseudo-rule. The scope of
    #           default pseudo-rules is lexical, applying only to
    #           rules that appear afterwards in the DSL source.
    #
    #           Currently only the action and bless adverbs can be
    #           specified in a default pseudo-rule. Each default
    #           pseudo-rule creates a completely new set of defaults
    #           -- if an adverb is not specified, the default is reset
    #           to its implicit value, the value which it had prior to
    #           any explicit settings.

    method {default rule/0} {children} { # OK <adverb list>
	IS {
	    set adverbs [PASS1]
	    g1/default/reset
	    ADV adverbs action g1/default ;# <action/0>
	    ADV adverbs bless  g1/default ;# <blessing/0>
	    ADX adverb {lexeme default}
	}
    }

    # DSL.pod - The lexeme default statement changes the defaults for
    #           lexeme adverbs. It only changes the defaults for
    #           lexemes, and does not affect rules. Only the defaults
    #           for the action, bless, and latm adverbs can be
    #           specified in a lexeme default statement. Only one
    #           lexeme default statement is allowed in a grammar.

    method {lexeme default statement/0} {children} { # OK <adverb list> /GLOBAL
	IS {
	    global/lock {lexeme default} ;# stop more than one use
	    set adverbs [PASS1]
	    ADV adverbs action l0/default ;# <action/0>
	    ADV adverbs bless  l0/default ;# <blessing/0>
	    ADV adverbs latm   l0/default ;# <latm specification/*>
	    ADX adverb {lexeme default}
	}
    }

    method {discard default statement/0} {children} { # TODO NODOC /GLOBAL
	error "undocumented"
	# <adverb list>
	IS {
	    global/lock {discard default} ;# stop more than one use
	    set adverbs [PASS1]
	    ADV adverbs event  ... ;# :discard default - <event init>, ':symbol' pause?
	    ADX adverb {discard default}
	}
    }

    method {priority rule/0} {children} { # OK <lhs> <op declare> <priorities>
	# <lhs> <op declare> <priorities>
	#  \- symbol name    \- alternatives each with adverb information
	#
	# Push information (lhs, decl) down to the <alternative>, do
	# adverb and precedence processing there, not here.
	IS {
	    global/context lhs  [set lhs     [PASS1 0]]
	    global/context decl [set declare [PASS1 1]]
	    global/context prec [expr {[llength $children]-2}]
	    EVALR 2 end
	    ${declare}/start $lhs
	}
    }

    # DSL.pod - An empty rule is a rule with an empty RHS. The empty
    #           RHS, technically, is a RHS alternative, one with zero
    #           RHS primaries. The action and bless adverbs are
    #           allowed for the empty RHS alternative, but no
    #           others. A empty rule makes its LHS symbol a nullable
    #           symbol.

    method {empty rule/0} {children} { # OK <lhs> <op declare> <adverb list>
	# <lhs> <op declare> <adverb list>
	#  \- symbol name     |
	#                     |
	# Accepted adverbs (see statement/1):
	# - action    -- <action>
	# - bless     -- <blessing>
	# - name      -- <naming>                     -- DOC MISMATCH
	# - rank      -- <rank specification>         -- DOC MISMATCH
	# - null rank -- <null ranking specification> -- DOC MISMATCH (g1 only)
	IS {
	    set lhs     [PASS1 0]
	    set declare [PASS1 1]
	    set adverbs [PASS1 2]

	    ${declare}/start $lhs

	    set id [${declare}/sym/alter $lhs]

	    ADV adverbs action ${declare}/rule/set $id
	    ADV adverbs bless  ${declare}/rule/set $id
	    ADV adverbs name   ${declare}/rule/set $id
	    ADV adverbs rank   ${declare}/rule/set $id
	    if {$declare eq "g1"} {
		ADV adverbs 0rank ${declare}/rule/set $id
	    }
	    ADX adverbs {empty rule}
	}
    }

    # DSL.pod - A quantified rule has only one RHS alternative, which
    #           is followed by a quantifier. The RHS alternative must
    #           consist of a single RHS primary. This RHS primary must
    #           be a symbol name or a character class. The quantifer
    #           is either a star ("*"), or a plus sign ("+")
    #           indicating, respectively, that the sequence rule has a
    #           minimum length of 0 or 1.
    #
    #           Adverbs may be associated with the RHS alternative.
    #           The adverb list must follow the quantifier. The
    #           adverbs allowed are action, bless, proper and
    #           separator.

    method {quantified rule/0} {children} { # OK <lhs> <op decl> <rhs> <quant> <adverbs>
	# <lhs> <op declare> <rhs> <quantifier> <adverbs>
	#  |     g1/l0        |     */+          /
	#  \- symbol name     \ single symbol /-/
	#                                    /
	# Accepted adverbs (see statement/5):
	# - action    -- <action>                     -- DOC MISMATCH
	# - bless     -- <blessing>
	# - proper    -- <proper specification>
	# - separator -- <separator specification>
	# - name      -- <naming>                     -- DOC MISMATCH
	# - rank      -- <rank specification>         -- DOC MISMATCH
	# - null rank -- <null ranking specification> -- DOC MISMATCH (g1 only)
	IS {
	    set lhs        [PASS1 0]
	    set declare    [PASS1 1]
	    set rhs        [PASS1 2]
	    set quantifier [PASS1 3]
	    set adverbs    [PASS1 4]

	    ${declare}/start $lhs

	    set id [${declare}/sym/quant $lhs $quantifier $rhs]

	    ADV adverbs proper    ${declare}/rule/set $id
	    ADV adverbs separator ${declare}/rule/set $id
	    ADV adverbs action    ${declare}/rule/set $id
	    ADV adverbs bless     ${declare}/rule/set $id
	    ADV adverbs name      ${declare}/rule/set $id
	    ADV adverbs rank      ${declare}/rule/set $id
	    if {$declare eq "g1"} {
		ADV adverbs 0rank ${declare}/rule/set $id
	    }
	    ADX adverbs {quantified rule}
	}
    }

    # DSL.pod - A discard pseudo-rule is a rule whose LHS is the
    #           :discard pseudo-symbol, and which has only one RHS
    #           alternative. The RHS alternative must contain exactly
    #           one symbol name, called the discarded symbol. Discard
    #           pseudo-rules indicate that the discarded symbol is a
    #           top-level L0 symbol, but one which is not a lexeme.
    #           When a discarded symbol is recognized, it is not
    #           passed as a lexeme to the G1 parser, but is (as the
    #           name suggests) discarded. Discard pseudo-rules must be
    #           L0 rules. No adverbs are allowed.

    method {discard rule/0} {children} { # OK <single symbol> <adverb list>
	# No adverbs allowed (see statement/6)
	# FAIL :: Contradicted by syntax, see above.
	IS {
	    set lhs     [PASS1]
	    set adverbs [PASS1 1]
	    ADV adverbs event  ... ;# :- discard default re events: <event init>, ':symbol' pause?
	    ADX adverbs {discard rule}

	    l0/sym/set $lhs discard yes
	}
    }

    # DSL.pod - The purpose of the :lexeme pseudo-rule is to allow
    #           adverbs to change the treatment of a lexeme. This
    #           pseudo-rule always has exactly one RHS alternative,
    #           and that RHS alternative must contain exactly one
    #           symbol. This RHS symbol identifies the lexeme which
    #           the adverbs will affect. The only adverbs allowed in a
    #           :lexeme rule are event, pause, and priority.
    #
    #           As a side effect, a :lexeme pseudo-rule declares that
    #           its RHS symbol is expected to be a lexeme. This
    #           declaration does not "force" lexeme status -- if the
    #           symbol does not meet the criteria for a lexeme based
    #           on its use in L0 and G1 rules, the result will be a
    #           fatal error. Applications may find this ability to
    #           "declare" lexemes useful for debugging, and for
    #           documenting grammars.

    method {lexeme rule/0} {children} { # OK <symbol> <adverb list>
	# Accepted adverbs (see statement/10):
	# - event    -- <event specification>    -- Default: empty
	# - pause    -- <pause specification>    -- Default: no
	# - priority -- <priority specification> -- Default: 0
	# - latm     -- <latm specification>     -- Default: off - DOC MISMATCH
	#
	# event => pause, else fatal         (TODO: check after collecting everything)
	# pause => event, else unnamed event

	IS {
	    set lhs     [PASS1]
	    set adverbs [PASS1 1]
	    ADV adverbs event    l0/sym/set $lhs ;# !!value is event initializer
	    ADV adverbs pause    l0/sym/set $lhs
	    ADV adverbs priority l0/sym/set $lhs
	    ADV adverbs latm     l0/sym/set $lhs
	    ADX adverbs {lexeme rule}

	    # Mark explicitly as lexeme
	    l0/sym/set $lhs lexeme yes
	}
    }

    # DSL.pod - The named event statement sets up a SLIF parse
    #           event. The name of an event may be either a bare name,
    #           or enclosed in single quotes. A bare event name must
    #           be one or more word characters, starting with an
    #           alphabetic character. A single quoted event name may
    #           contain any character except a single quote or
    #           vertical space. The whitespace in single quoted event
    #           names is normalized in similar fashion to the
    #           normalization of symbol names -- leading and trailing
    #           whitespace is removed, and all sequences of internal
    #           whitespace are changed to a single ASCII space
    #           character.

    method {completion event declaration/0} {children} { # OK <event init> <symbol name>
	IS { global/event/process completed $children }
    }
    method {nulled event declaration/0}     {children} { # OK <event init> <symbol name>
	IS { global/event/process nulled $children }
    }
    method {prediction event declaration/0} {children} { # OK <event init> <symbol name>
	IS { global/event/process predicted $children }
    }

    method {current lexer statement/0} {children} { # TODO NODOC /GLOBAL
	error "cannot be called"
    }

    # DSL.pod - Inaccessible symbols are symbols which cannot be
    #           reached from the start symbol. Often, they are the
    #           result of an error in grammar writing. But
    #           inaccessible symbols can also occur for legitimate
    #           reasons -- for example, you may have rules and symbols
    #           in grammar intended for future use.
    #
    #           The default can be specified or changed, where where
    #           TREATMENT is one of warn, ok, or fatal.
    #
    #           * fatal indicates that an inaccessible symbol should
    #             be a fatal error.
    #           * warn indicates that Marpa should print a warning
    #             message, but proceed with the parse.
    #           * ok indicates that the parse should proceed without
    #             warning messages.
    #
    #           warn is the default.

    method {inaccessible statement/0} {children} { # OK <inaccessible treatment>
	IS { g1/default inacc [PASS1] }
    }

    # Adverb processing, generates a dict of the adverbs
    method {adverb list/0}       {children} { PASS }
    method {adverb list items/0} {children} { FLAT } ;# Squash parts into single dict

    #                                                           Defaults
    method {adverb item/0}  {children} { PASS1 } ;# action      l0 [values] g1 undef
    method {adverb item/1}  {children} { PASS1 } ;# left  assoc \* left
    method {adverb item/2}  {children} { PASS1 } ;# right assoc |
    method {adverb item/3}  {children} { PASS1 } ;# group assoc /
    method {adverb item/4}  {children} { PASS1 } ;# separator   undef
    method {adverb item/5}  {children} { PASS1 } ;# proper      no
    method {adverb item/6}  {children} { PASS1 } ;# rank        ?
    method {adverb item/7}  {children} { PASS1 } ;# null rank   ?
    method {adverb item/8}  {children} { PASS1 } ;# priority    0
    method {adverb item/9}  {children} { PASS1 } ;# pause       undef
    method {adverb item/10} {children} { PASS1 } ;# event       undef
    method {adverb item/11} {children} { PASS1 } ;# latm        no
    method {adverb item/12} {children} { PASS1 } ;# bless       undef
    method {adverb item/13} {children} { PASS1 } ;# name        undef
    method {adverb item/14} {children} { PASS1 } ;# null        N/A

    # Adverb parts ...
    method {null adverb/0} {children} { CONST } ; # OK

    # DSL.pod - The action adverb is allowed for
    #
    #     * An RHS alternative, in which the action is for the
    #       alternative.
    #     * The default pseudo-rule, in which case the action is for
    #       all rules which do not have their own action explicitly
    #       specified.
    #     * The lexeme default statement, in which case the action is
    #       for all lexemes.
    #
    # => <alternative>, <empty rule>
    # => <default rule>
    # => <lexeme default statement>
    #
    #     The action adverb is not allowed for L0 rules. The possible
    #     values of actions are described, along with other details of
    #     the semantics, in a separate document.

    # Array Descriptor Actions (ADA)
    # Name   | L0                           G1
    # ----   | --                           --
    # length | Length of Lexeme             Length of Rule (G1)    Unit: characters.
    # lhs    | LHS symbol id of rule        LHS symbol id of the rule
    # ----   | --                           --
    # name   | lexeme => symbol name        Name of rule,
    #        | Name of rule                 \unnamed => LHS symbol name
    #        | \unnamed => LHS symbol name
    # ----   | --                           --
    # rule   | Rule id, undef for non-rules Rule id, undef for non-rules
    # start  | Start offset of lexeme       Start offset of rule instance
    # ----   | --                           --
    # symbol | Rule:   LHS symbol name      Rule:   LHS symbol name
    #        | Lexeme: Lexeme symbol name   Lexeme: Lexeme symbol name
    #        | Nulling: Nulling symbol name Nulling: Nulling symbol name
    # ----   | --                           --
    # value  | String value of lexeme       List of child values, left to right
    # values | See vale, synonym
    # ----   | --                           --
    # Local extensions
    # ----   | --                           --
    # end    | End offset of lexeme         End offset of rule instance
    # ----   | --                           --

    # Rserved names
    # ::action <=> [value]
    # ::first  <=> SV is first child's SV. G1 only, L0 FAIL
    # ::undef  <=> SV is undef. G1: Default

    method action/0        {children} { CONST action [PASS1] }
    method {action name/0} {children} { CONST cmd   [STRING] }
    method {action name/1} {children} { CONST cmd   [STRING] }
    method {action name/2} {children} { CONST array [STRING] }

    # DSL.pod - The assoc adverb is only valid in a prioritized
    #           rule. Its value must be one of left, right or group.
    #
    # => alternative
    #
    # For the purpose of precedence, an operand is an occurrence of
    # the LHS symbol in an RHS alternative. Anything else on the RHS
    # is an operator. The arity is the number of operands in the
    # RHS. There are no limits an arities except those imposed by
    # system limits, i.e. available memory, largest file size, etc.
    #
    # Example:                                                  Arity
    #   Expression ::= Number                                    0
    #               | '(' Expression ')'         assoc => group   1
    #              || Expression '**' Expression assoc => right  2
    #              || Expression '*' Expression                  2
    #               | Expression '/' Expression                  2
    #              || Expression '+' Expression                  2
    #               | Expression '-' Expression                  2
    #
    # Arity Naming  Precedence             Associativity
    # ----- ------  ----------             -------------
    #  0    nullary meaning-less, ignored  meaning-less, ignored
    #  1    unary   has effect             meaning-less, ignored
    #  2    binary  has effect             traditional way
    # >2    n-ary   has effect             left/right-most operand
    #                                      associates, all others
    #                                      are next tightest
    # ----- ------  ----------             -------------
    #
    # "group" associativity. All operands associate at the loosest
    # (lowest) priority. Each operand may be a full expression of the
    # kind defined by the prioritized rule. This is meaningless for
    # nullary alternatives, and ignored.

    # In a <priority rule > the alternatives are listed top to bottom
    # from tightest to loosest precedence.
    #
    # loosest == 0, tighter increments to higher numbers.
    #
    # For x, a precedence:
    #   looser(x) == x-1, if x > 0                | Step down
    #   looser(0) == 0                            |
    # and
    #   tighter(x)        == x+1, if x < tightest | Step up
    #   tighter(tightest) == tightest             |
    #
    # Side note: Numerical order is reverse of lexical order in the input

    # Start: List of all alternatives, with associated associativity,
    #        and precedence. Sorted by precedence, numerical
    #        ascending, i.e. loosest to tightest.
    #

    # ==> precedence-rewrite

    method {left association/0}  {children} { CONST assoc left  }
    method {right association/0} {children} { CONST assoc right }
    method {group association/0} {children} { CONST assoc group }

    # DSL.pod - The separator keyword is only valid for a quantified
    #           right side, and its value must be a single symbol --
    #           either a single symbol name, or a character class. If
    #           specified, the separator must separate items of the
    #           sequence. A separator may not be nullable.
    #
    # => <quantified rule>

    method {separator specification/0} {children} { # OK <single symbol>
	# RHS-SV: unbox, drop mask, keep symbol
	CONST sep [lindex [rhs/get-sym [PASS1]] 0]
    }

    # DSL.pod - The proper keyword is only valid for a quantified
    #           right side, and its value must be a boolean, in the
    #           form of a binary digit (0 or 1). It is only relevant
    #           if a separator is defined and is 1 if proper
    #           separation is required, and 0 if Perl separation is
    #           allowed. "Perl separation" allows a final
    #           separator. "Proper separation" is so called, because
    #           it requires that separators be "proper" in the sense
    #           that they must actually separate sequence items.
    #
    # => <quantified rule>

    method {proper specification/0} {children} { CONST proper [STRING] }

    # DSL.pod - Usage in rules and rule alternatives (implied by example)
    #
    # => <empty rule>
    # => <quantified rule>
    # => <alternative>

    method {rank specification/0} {children} { CONST rank [STRING] }

    # DSL.pod - The priority adverb is only allowed in a :lexeme
    #           pseudo-rule. It sets the lexeme priority for the
    #           lexeme. The priority must be an integer, but it may be
    #           negative. An increase in numerical value means a
    #           higher priority.
    #
    # => <lexeme rule>

    method {priority specification/0} {children} { CONST prio [PASS1] } ; # OK

    # DSL.pod - The pause adverb applies only to lexemes and is only
    #           allowed in a :lexeme pseudo-rule. The pause adverb
    #           declares a SLIF parse event. The event adverb names
    #           the SLIF parse event declared by the pause adverb.
    #
    #           When an event declared with the the pause adverb is
    #           not named using the event adverb, an unnamed event
    #           results. An unnamed event cannot be accessed by normal
    #           methods and the use of unnamed events is strongly
    #           discouraged.
    #
    # => lexeme rule

    method {pause specification/0} {children} { CONST pause [STRING] }

    # DSL.pod - The event adverb applies only to lexemes and is only
    #           allowed in a :lexeme pseudo-rule. It names the event
    #           specified by the pause adverb. It is a fatal error to
    #           specify the event adverb if the pause adverb is not
    #           also specified.
    #
    # => lexeme rule
    # TODO check event name

    method {event specification/0} {children} { CONST event [PASS1]  }

    # DSL.pod - The null-ranking adverb applies only to G1 rules (L0
    #           rules do not have a semantics)
    #
    # => <empty rule>
    # => <quantified rule>
    # => <alternative>

    method {null ranking specification/0} {children} { CONST 0rank [PASS1]  } ; # OK
    method {null ranking specification/1} {children} { CONST 0rank [PASS1]  } ; # OK

    method {null ranking constant/0} {children} { CONST low  } ; # OK
    method {null ranking constant/1} {children} { CONST high } ; # OK

    #

    method {event initialization/0} {children} { PASS }
    method {event initializer/0}    {children} { PASS1 }
    method {on or off/0}            {children} { CONST on  }
    method {on or off/1}            {children} { CONST off }

    method {event name/0} {children} { STRING } ; # TODO normalize ?
    method {event name/1} {children} { STRING } ; # TODO normalize ?
    method {event name/2} {children} { STRING } ; # TODO normalize ?

    # DSL.pod - The latm adverb applies only to lexemes and is only
    #           allowed in a :lexeme pseudo-rule and a lexeme default
    #           statement.
    #
    #           Its value is a boolean. If the boolean is
    #           set it indicates that a token is LATM. A value of 1 is
    #           recommended, which indicates that a token is LATM. The
    #           default value is 0, for reasons of backward
    #           compatibility.
    #
    # => <lexeme rule>	      
    # => <lexeme default statement>

    method {latm specification/0} {children} { CONST latm [STRING] } ; # OK
    method {latm specification/1} {children} { CONST latm [STRING] } ; # OK

    # DSL.pod - The bless adverb causes the result of the semantics to
    #           be blessed into the class indicated by the value of
    #           the adverb. Details of its use may be found in the
    #           semantics document.

    method {blessing/0}      {children} { PASS1 }                ; # OK
    method {blessing name/0} {children} { CONST bless [STRING] } ; # OK
    method {blessing name/1} {children} { CONST bless [STRING] } ; # OK

    # DSL.pod - The name adverb applies only to rules and rule
    #           alternatives. When specified, it defines a name for
    #           that rule alternative.
    #
    # => <empty rule>
    # => <quantified rule>
    # => <alternative>

    method {naming/0} {children} { CONST name [PASS1] }

    # See <inaccessible statement>

    method {inaccessible treatment/0} {children} { CONST warn  } ; # OK
    method {inaccessible treatment/1} {children} { CONST ok    } ; # OK
    method {inaccessible treatment/2} {children} { CONST fatal } ; # OK

    method quantifier/0 {children} { CONST * }
    method quantifier/1 {children} { CONST + }

    method {op declare/0} {children} { CONST g1 }
    method {op declare/1} {children} { CONST l0 }

    method priorities/0 {children} { # OK <alternatives> <op loosen> ...
	IS {
	    set children [DESEQ $children]      ; # Strip out separator
	    EVALP {global/context/incr prec -1} ; # Do alternatives,
						  # reduce precedence
						  # from element to
						  # element
	}
    }
    method alternatives/0 {children} { # OK <alternative> <op equal priority> ...
	IS {
	    set children [DESEQ $children] ; # Strip out separator
	    EVAL                           ; # Do each alternate
	}
    }
    method alternative/0  {children} { # TODO enter&config alternate, adverbs
	# <rhs> <adverb list>
	# Available context: lhs, decl, prec
	# See <quantified rule>

	# - action    -- <action>
	# - bless     -- <blessing>
	# - name      -- <naming>                     -- DOC MISMATCH
	# - rank      -- <rank specification>         -- DOC MISMATCH
	# - null rank -- <null ranking specification> -- DOC MISMATCH (g1 only)
	# - assoc     -- <* association>              -- See DSL.pod Precedence
	error "todo"
    }

    method {alternative name/0} {children} { PASS1 }
    method {alternative name/1} {children} { PASS1 }

    method {lexer name/0} {children} { PASS1 }
    method {lexer name/1} {children} { PASS1 }
    method lhs/0          {children} { PASS1 } ; # OK

    # The SV of the RHS is a tuple (mask, symbols), vectors of equal
    # length, boolean mask flag and symbol names. A mask bit of false
    # hides the respective symbol from the semantics.

    method rhs/0 {children} { # OK <rhs>+
	# RHS-SV: merge mask and symbol vectors of all children
	IS { return [rhs/merge {*}[PASS]] }
    }
    method {rhs primary/0} {children} { # OK <single symbol>
	# RHS-SV: single child, pass
	PASS1
    }
    method {rhs primary/1} {children} { # OK <single quoted string>
	# Internal lexer symbol, rhs leaf up
	IS { return [rhs/leaf [l0/string [STRING]]] }
    }
    method {rhs primary/2} {children} { # OK <parenthesized rhs primary list>
	# RHS-SV: single child, pass
	PASS1
    }
    method {parenthesized rhs primary list/0} {children} { # OK <rhs primary list>
	# RHS-SV : single child - replace mask vector to hide them all
	IS { return [rhs/hide [PASS1]] }
    }
    method {rhs primary list/0} {children} { # OK <rhs>+
	# RHS-SV: merge mask and symbol vectors of all children
	IS { return [rhs/merge {*}[PASS]] }
    }

    # users: quantified rule, discard rule, separator spec, rhs primary/0
    method {single symbol/0} {children} { # OK <symbol>
	IS { return [rhs/leaf [PASS1]] }
    }
    method {single symbol/1} {children} { # OK <character class>
	# <single quoted string> : lexeme
	IS { return [rhs/leaf [l0/class [STRING]]] }
    }

    method symbol/0        {children} { PASS1  } ; # OK
    method {symbol name/0} {children} { STRING } ; # OK
    method {symbol name/1} {children} { STRING } ; # OK

    # # ## ### ##### ######## #############

    method SKIP {pass} {
	if {$mypass eq $pass} { return -code return }
	return
    }

    # # ## ### ##### ######## #############

    method EVAL {} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	foreach c $children {
	    # The side-effects are important, not the result.
	    eval $c
	}
	debug.marpa/grammar {[debug caller] | [AT] /ok}
	return
    }

    method EVALP {script} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	foreach c $children {
	    # The side-effects are important, not the result.
	    eval $c
	    # post element operation
	    uplevel 1 $script
	}
	debug.marpa/grammar {[debug caller] | [AT] /ok}
	return
    }

    method EVALR {from to} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	foreach c [lrange $children $from $to] {
	    # The side-effects are important, not the result.
	    eval $c
	}
	debug.marpa/grammar {[debug caller] | [AT] /ok}
	return
    }

    method PASS1 {{index 0}} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children

	#debug.marpa/grammar {[debug caller] | [AT]: ([join $children )\n(])}

	set child [lindex $children $index]
	#debug.marpa/grammar {[debug caller] | [AT]: $child}

	set r [eval $child]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method LEX {args} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	set r [lindex $children {*}$args]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method STRING {{index 0}} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	set r [lindex $children $index 2]
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method CONST {args} {
	debug.marpa/grammar {[debug caller] | [AT]}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($args)}
	return $args
    }

    method PASS {} {
	debug.marpa/grammar {[uplevel 1 {debug caller}]}
	upvar 1 children children
	set r {}
	foreach c $children {
	    #debug.marpa/grammar {[debug caller] | [AT]: $c}
	    lappend r [eval $c]
	}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method FLAT {} {
	debug.marpa/grammar {[debug caller] | [AT]}
	upvar 1 children children
	set r {}
	foreach c $children {
	    #debug.marpa/grammar {[debug caller] | [AT]: $c}
	    lappend r {*}[eval $c]
	}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method DESEQ {svlist {initial yes}} {
	# Strip the separator elements from a list of semantic values.
	# initial == yes (default): result contains the even elements (0, 2, ...)
	# initial == no: result contains the odd elements (1, 3, ...)
	debug.marpa/grammar {[debug caller] | [AT]}
	set r {}
	set add $initial
	foreach c $svlist {
	    #debug.marpa/grammar {[debug caller] | [AT]: $c}
	    if {$add} { lappend r $c }
	    set add [expr {!$add}]
	}
	debug.marpa/grammar {[debug caller] | [AT] DEF ($r)}
	return $r
    }

    method ADV {dictv key args} {
	upvar 1 $dictv dict
	if {![dict exists $dict $key]} return
	set v [dict get $dict $key]
	dict unset dict $key
	lappend args $key $v
	uplevel 1 $args
	return
    }
    method ADX {dictv context} {
	upvar 1 $dictv dict
	if {![dict size $dict]} return
	error "Invalid adverbs [dict keys $dict] in $context"
    }

    method IS {{script {}}} {
	debug.marpa/grammar {[debug caller 1] | [AT][INDENT]}
	upvar 1 children children
	set r [uplevel 1 $script]
	debug.marpa/grammar {[UNDENT][debug caller] | [AT] DEF ($r)}
	return $r
    }

    method ISX {{script {}}} {
	debug.marpa/grammar {[debug caller 1] | [AT][INDENT]}
	upvar 1 children children
	set r [uplevel 1 $script]
	debug.marpa/grammar {[UNDENT][debug caller 1] | [AT] DEF ($r)}
	return $r
    }

    # # ## ### ##### ######## #############

    method AT {} {
	return ${__indent}<[lindex [info level -2] 1]>
    }

    method INDENT {} {
	upvar 1 __indent_bak ib
	set ib $_indent
	append __indent {  }
	return
    }

    method UNDENT {} {
	upvar 1 __indent_bak ib
	set _indent $ib
	return
    }

    method CHECK {v label args} {
	upvar 1 $v var
	if {[dict exists $var {*}$args]} return
	error [format $label [lindex $args end]]
    }

    method CHKDUP {v label args} {
	upvar 1 $v var
	if {![dict exists $var {*}$args]} return
	error [format $label [lindex $args end]]
    }

    # # ## ### ##### ######## #############
    ## Accessor methods for data retrieval

    # # ## ### ##### ######## #############
    ## Methods for direct/bulk loading of grammar information


    # # ## ### ##### ######## #############
    ## Helper methods for low-level grammar updates.

    # rule rhs semantic value = tuple (mask, symbols)
    # mask    = list (bool)   - true: hidden symbol
    # symbols = list (symbol) - 
    # assert |mask| == |symbols|

    method rhs/get-sym {sv} { lindex $sv 1 }

    method rhs/merge {args} {
	foreach b [lassign $args a] {
	    set a [rhs/merge2 $a $b]
	}
	return $a
    }

    method rhs/merge2 {a b} {
	lassign $a amask asymbols
	lassign $b bmask bsymbols
	lappend amask    {*}$bmask
	lappend asymbols {*}$bsymbols
	return [list $amask $asymbols]
    }

    method rhs/hide {sv} {
	# sv :: list (mask, symbols) :: |mask| == |symbols|
	# Replace mask with hide-mask for all elements.
	lassign $sv mask symbols
	set mask [lrepeat [llength $mask] 1]
	return [list $mask $symbols]
    }

    method rhs/leaf {symbol} {
	# result :: list (mask, symbols) :: |mask| == |symbols| == 1
	return [list 0 [list $symbol]]
    }

    # # ## ### ##### ######## #############
    ## Activate for processing of an input per the loaded grammar.

    # # ## ### ##### ######## #############
    ## Global data structures, constructors and accessors

    variable mylock    ;# key -> .           : Record seen keys
    variable mycontext ;# key -> value       : Priority rule context, and others
    variable myevent   ;# name -> event-data : Declared events

    method global/init {} {
	set mylock    {}
	set mycontext {lhs {} decl {} prec {}}
	# lhs  - lhs symbol of the current priorities and alternatives
	# decl - match mode: l0, g1
	# prec - current precedence level
	return
    }

    method global/lock {key} {
	if {[dict exists $mylock $key]} { error "Duplicate use of $key" }
	dict set mylock $key .
	return
    }

    method global/context {key value} {
	CHECK mycontext "Bad global context %s" $key
	dict set mycontext $key $value
    }

    method global/context/get {key} {
	CHECK mycontext "Bad global context %s" $key
	set v [dict get $mylock $key]
	if {$v eq {}} { error "Undefined global context $key" }
	return $v
    }

    method global/context/incr {key {incr 1}} {
	set v [global/context/get $key]
	incr v
	global/context $key $v
    }

    # event-data = <
    #     state  -> bool
    #     type   -> {completed,predicted,nulled}
    #     symbol -> string
    # >

    method global/event/process {type children} {
	# OK <event initialization> <symbol name>
	#  \- tuple (name, bool)
	set einit  [PASS1 0]
	set symbol [PASS1 1]
	lassign $einit name state

	# TODO: normalize names specified through <single quoted
	# string>, like bracketed symbols

	if {$state eq {}} { set state on }

	global/event/def $name $state $type $symbol
	return
    }

    method global/event/def {name state type symbol} {
	CHKDUP myevent "Duplicate event %s" $key
	dict set myevent $name state  $state
	dict set myevent $name type   $type
	dict set myevent $name symbol $symbol
    }

    # # ## ### ##### ######## #############
    ## G1 data structures, constructors and accessors

    variable mystart         ;# start symbol
    variable mygrsym         ;# symbol -> symbol-data
    variable mygrrule        ;# id     -> rule-data
    variable mygrrulecounter ;# rule generation counter
    variable mygradverb      ;# Adverb information, G1 global
                              # - action : Standard SV action
                              # - bless
                              # - inacc  : Handling of inaccessible statements

    method g1/init {} {
	set mystart         {} ;# undefined
	set mygrsym         {}
	set mygrrule        {}
	set mygrrulecounter 0

	# G1 global adverb information
	set mygradverb {
	    action  {cmd ::undef}
	    bless   {}
	    inacc   warn
	}
	return
    }

    method g1/default/reset {} {
	dict set mygradverb action {cmd ::undef}
	dict set mygradverb bless  {}
	return
    }

    method g1/default {key value} {
	CHECK mygradverb "Unknown g1 global adverb %s" $key
	dict set mygradverb $key $v
	return
    }

    method g1/default/get {key} {
	CHECK mygradverb "Unknown g1 global adverb %s" $key
	return [dict get $mygradverb $key]
    }

    method g1/start {symbol {force no}} {
	if {$mystart eq {}} {
	    set mystart $symbol
	} elseif {$force} {
	    set mystart $symbol
	}
    }

    # symbol-data = <
    #     rules    -> list (rule-id)        initial: empty
    #     rtype    -> {undef, bnf, quant}   initial: undef
    # >

    method g1/sym/get {symbol} {
	if {![dict exists $mysymlex $symbol]} {
	    dict set mysymlex $symbol {
		rules    {}
		rtype    undef
	    }
	}
	return [dict get $mygrsym $symbol]
    }

    method g1/sym/set {symbol key value} {
	g1/sym/get $symbol
	CHECK mygrsym "Unknown g1 symbol attribute %s" $symbol $key
	dict set mygrsym $symbol $key $value
	return
    }

    method g1/sym/lappend {symbol key value} {
	g1/sym/get $symbol
	CHECK mygrsym "Unknown g1 symbol attribute %s" $symbol $key
	dict lappend mygrsym $symbol $key $value
	return
    }

    method g1/sym/rhs {lhs args} {
	# Generate rhs symbols, no-op if already known.
	foreach rhs $args {
	    g1/sym/get $rhs
	}
	return
    }

    method g1/sym/quant {lhs min rhs} {
	set def [g1/sym/get $lhs]

	switch -exact -- [dict get $def rtype] {
	    undef {}
	    bnf {
		error "syntax error, bad rule, mix /TODO"
	    }
	    quant {
		error "syntax error, bad quant again /TODO"
	    }
	}

	set rule [g1/rule/quant/new $lhs $min $rhs]
	g1/sym/lappend $lhs rules $rule
	g1/sym/set     $lhs rtype quant
	return
    }

    method g1/sym/alter {lhs args} {
	# TODO: reject if duplicate present

	set def [g1/sym/get $lhs]
	if {[dict get $def rtype] eq "quant"} {
	    error "syntax error, bad rule /TODO"
	}

	set rule [g1/rule/bnf/new $lhs $args]
	g1/sym/lappend $lhs rules $rule
	g1/sym/set     $lhs rtype bnf
	return
    }

    # rule-data = <
    #    type       -> {bnf, quant}
    ##
    #    rhs        -> list (symbol) /bnf
    #    mask       -> list (bool)   /bnf
    ##
    #    rhs        -> symbol        /quant
    #    proper     -> bool          /quant initial: no
    #    separator  -> symbol,       /quant initial: {}
    #    mincount   -> {0,1},        /quant
    #
    #    action     -> tuple (type, details) initial: l0 global adverb
    #    bless      -> any                   initial: l0 global adverb
    #    name       -> string                initial: {}
    #    rank       -> int                   initial: {}
    #    0rank      -> string                initial: {}
    # >

    method g1/rule/bnf/new {lhs rhssv} {
	set id [g1/rule/new]

	lassign $rhssv mask symbols

	# Attribute definitions
	dict set mygrrule $id type bnf
	dict set mygrrule $id rhs  $symbols
	dict set mygrrule $id mask $mask

	g1/sym/rhs $lhs {*}$symbols
	return $id
    }

    method g1/rule/quant/new {lhs min rhssv} {
	set id [g1/rule/new]

	lassign $rhssv mask symbols
	set rhs [lindex $symbols 0]
	# Ignore mask for quantified

	if {$min eq "*"} { set min 0 }
	if {$min eq "+"} { set min 1 }

	# Attribute definitions
	dict set mygrrule $id type      quant
	dict set mygrrule $id rhs       $rhs
	dict set mygrrule $id proper    no
	dict set mygrrule $id separator {}
	dict set mygrrule $id mincount  $min

	g1/sym/rhs $lhs $rhs
	return $id
    }

    method g1/rule/new {} {
	set id [incr mygrrulecounter]
	dict set mygrrule $id {
	    name  {}
	    rank  {}
	    0rank {}
	}
	dict set mygrrule $id action [g1/default/get action]
	dict set mygrrule $id bless  [g1/default/get bless]
	return $id
    }

    method g1/rule/set {id key value} {
	CHECK mygrrule "Unknown g1 rule attribute %s" $id $key
	dict set mygrrule $id $key $value
	return
    }

    # # ## ### ##### ######## #############
    ## L0 data structures, constructors and accessors

    variable mylexstrcounter  ;# counter for generated l0 symbols,
			       # strings
    variable mylexcccounter   ;# ditto, char classes
    variable mylexrulecounter ;# ditto, rules
    variable mylexstr         ;# string -> symbol, memoize
    variable mylexcc          ;# class  -> symbol, memoize
    variable mylexchar        ;# char   -> symbol, memoize
    variable mylexsym         ;# symbol -> symbol-data
    variable mylexrule        ;# id     -> rule-data
    variable mylexadverb      ;# Adverb information, L0 global
                               # - action : Standard SV action
                               # - bless
                               # - latm

    method l0/init {} {
	set mylexstrcounter  0
	set mylexcccounter   0
	set mylexrulecounter 0
	set mylexstr         {}
	set mylexcc          {}
	set mylexchar        {}
	set mylexsym         {}
	set mylexrule        {}

	# L0 global adverb information
	set mylexadverb {
	    action {array values}
	    bless  undef
	    latm   off
	}
	return
    }

    method l0/start {symbol {force no}} {
	# NO OP method to make callers simpler, i.e. non-conditional.
    }

    method l0/default {key value} {
	CHECK mylexadverb "Unknown l0 global adverb %s" $key
	dict set mylexadverb $key $v
	return
    }

    method l0/default/get {key} {
	CHECK mylexadverb "Unknown l0 global adverb %s" $key
	return [dict get $mylexadverb $key]
    }

    method l0/char/symbol {c} {
	return @l0:char[scan $char %c]:[char quote string $char]
    }

    method l0/string/symbol {string} {
	return @l0:str[incr mylexstrcounter]:[char quote string $string]
    }

    method l0/cc/symbol {ccdef} {
	return @l0:cc[incr mylexcccounter]:[char quote string $ccdef]
    }

    # symbol-data = <
    #     is       -> {class,char,rule}     initial: {}
    #     rules    -> list (rule-id)        initial: empty
    #     rtype    -> {undef, bnf, quant}   initial: undef
    #     discard  -> bool                  initial: no
    #     toplevel -> bool                  initial: yes
    #     event    -> string                initial: {}
    #     pause    -> {no,before,after}     initial: no
    #     priority -> int                   initial: {}
    #     users    -> list (symbol)         initial: {}
    #     lexeme   -> bool                  initial: no
    #     latm     -> bool                  initial: no
    # >
    #
    # is class = char class, possible expansion into set of
    #            alternatives, no rules initially
    # is char  = single character, no rules
    # is rule  = described by rules, set of alternatives
    #
    # users is for diagnostics, i.e. to anser the question of why foo
    # is not a toplevel symbol

    method l0/string {string} {	if {[dict exists $mylexstr $string]} {
	    return [dict get $mylexstr $string]
	}

	set symbol [l0/string/symbol $string]

	# Determine modifier.
	set nocase no
	if {[string match {*:i} $string]} {
	    set nocase yes
	    set string [string range $string 0 end-2]
	} elseif {[string match {*:ic} $string]} {
	    set nocase yes
	    set string [string range $string 0 end-3]
	}

	# Trim bracketing
	set string [string range $string 1 end-1]

	set rhs {}
	if {$nocase} {
	    # Generate character symbols, in both upper and lower
	    # case. The string is a series of intermediate
	    # symbols aggregating the letter-cases.
	    foreach c [split $string] {
		set cup [l0/char [string toupper $c]]
		set clw [l0/char [string tolower $c]]
		set c   ${cup}:ic

		l0/sym/alter $c $cup
		l0/sym/alter $c $clw
		lappend rhs $c
	    }
	} else {
	    # Generate character symbols
	    foreach c [split $string] {
		lappend rhs [l0/char $c]
	    }
	}

	l0/sym/alter $symbol {*}$rhs

	dict set mylexstr $string $symbol

	return $symbol
    }

    method l0/char {char} {
	if {[dict exists $mylexchar $char]} {
	    return [dict get $mylexchar $char]
	}

	set symbol [l0/char/symbol $char]

	l0/sym/get $symbol
	l0/sym/set $symbol is char
	dict set mylexchar $char $symbol

	return $symbol
    }

    method l0/class {ccdef} {
	# TODO: Consider char modifiers!

	if {[dict exists $mylexcc $ccdef]} {
	    return [dict get $mylexcc $ccdef]
	}

	set symbol [l0/cc/symbol $ccdef]

	l0/sym/get $symbol
	l0/sym/set $symbol is class
	dict set mylexcc $ccdef $symbol

	# TODO: determine positive/negated class
	# TODO: determine explicit/implicit set of characters
	# TODO: determine class modifiers (:i, :ic)

	return $symbol
    }

    method l0/sym/get {symbol} {
	if {![dict exists $mysymlex $symbol]} {
	    dict set mysymlex $symbol {
		rules    {}	rtype    undef
		discard  no	toplevel yes
		event    {}	pause    no
		priority {}     is       {}
		users    {}     lexeme   no
	    }
	    dict set mysymlex $symbol latm [l0/default/get latm]
	}
	return [dict get $mylexsym $symbol]
    }

    method l0/sym/set {symbol key value} {
	l0/sym/get $symbol
	CHECK mylexsym "Unknown l0 symbol attribute %s" $symbol $key
	dict set mylexsym $symbol $key $value
	return
    }

    method l0/sym/lappend {symbol key value} {
	l0/sym/get $symbol
	CHECK mylexsym "Unknown l0 symbol attribute %s" $symbol $key
	dict lappend mylexsym $symbol $key $value
	return
    }

    method l0/sym/rhs {lhs args} {
	# Generate rhs symbols, no-op if already known.
	# Force them as !toplevel
	# Remember the LHS as user, for diagnostics
	foreach rhs $args {
	    l0/sym/get     $rhs
	    l0/sym/set     $rhs toplevel no 
	    l0/sym/lappend $rhs users    $lhs
	}
	return
    }

    method l0/sym/quant {lhs min rhs} {
	# At L0 masking is irrelevant, and ignored
	set rhs [rhs/get-sym $rhs]
	set def [l0/sym/get $lhs]

	switch -exact -- [dict get $def rtype] {
	    undef {}
	    bnf {
		error "syntax error, bad rule, mix /TODO"
	    }
	    quant {
	    error "syntax error, bad quant again /TODO"
	    }
	}

	set rule [l0/rule/quant/new $lhs $min $rhs]
	l0/sym/lappend $lhs rules $rule
	l0/sym/set     $lhs rtype quant
	l0/sym/set     $lhs is    rule
	return
    }

    method l0/sym/alter {lhs args} {
	# TODO: reject if duplicate present

	set def [l0/sym/get $lhs]
	if {[dict get $def rtype] eq "quant"} {
	    error "syntax error, bad rule /TODO"
	}

	set rule [l0/rule/bnf/new $lhs $args]
	l0/sym/lappend $lhs rules $rule
	l0/sym/set     $lhs rtype bnf
	l0/sym/set     $lhs is    rule
	return $rule
    }

    # rule-data = <
    #    type       -> {bnf, quant}
    #    rhs        -> list (symbol) /bnf
    #               -> symbol        /quant
    #    proper     -> bool          /quant initial: no
    #    separator  -> symbol,       /quant initial: {}
    #    mincount   -> {0,1},        /quant
    #
    #    action     -> tuple (type, details) initial: l0 global adverb
    #    bless      -> any                   initial: l0 global adverb
    #    name       -> string                initial: {}
    #    rank       -> int                   initial: {}
    # >

    method l0/rule/bnf/new {lhs rhslist} {
	set id [l0/rule/new]

	# Attribute definitions
	dict set mylexrule $id type bnf
	dict set mylexrule $id rhs $rhslist

	l0/sym/rhs $lhs {*}$rhslist
	return $id
    }

    method l0/rule/quant/new {lhs min rhs} {
	set id [l0/rule/new]

	if {$min eq "*"} { set min 0 }
	if {$min eq "+"} { set min 1 }

	# Attribute definitions
	dict set mylexrule $id type      quant
	dict set mylexrule $id rhs       $rhs
	dict set mylexrule $id proper    no
	dict set mylexrule $id separator {}
	dict set mylexrule $id mincount  $min

	l0/sym/rhs $lhs $rhs
	return $id
    }

    method l0/rule/new {} {
	set id [incr mylexrulecounter]
	dict set mylexrule $id {
	    name {}
	    rank {}
	}
	dict set mylexrule $id action [l0/default/get action]
	dict set mylexrule $id bless  [l0/default/get bless]
	return $id
    }

    method l0/rule/set {id key value} {
	CHECK mylexrule "Unknown l0 rule attribute %s" $id $key
	dict set mylexrule $id $key $value
	return
    }

    # # ## ### ##### ######## #############
}

# # ## ### ##### ######## #############
return
