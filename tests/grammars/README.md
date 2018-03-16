# Grammar Test cases - Directory structure

Here we describe the files the directory `FOO` of a test case `FOO`
may contain, and their relation ships.

   * `slif` : A SLIF grammar definition.

      * Its existence triggers testing by everything going through
      	`common/parser-core`, i.e. `slif-builtin-parser`,
      	`zeta-tcl-parser`, and `zeta-rtc-parser`. These tests
      	require/presume the existence of `ast` and variants
      	(`ast_rtc`, `ast_tcl`).

      * Its existence further triggers testing by everything going
      	through `common/lexer-core`, i.e. `zeta-tcl-lexer`, and
      	`zeta-rtc-lexer`. These tests are further conditional on the
      	presence of `lexaction_*` files for the various semantic array
      	actions for lexemes, and the two runtimes.

      * Lastly its existence triggers testing by everything going
      	through `common/semantics-core`, i.e.
      	`slif-builtin-semantics`, `zeta-tcl-semantics`, and
      	`zeta-rtc-semantics`. These tests require/presume the
      	existence of `ctrace` and variants (`ctrace_rtc`,
      	`ctrace_tcl`).

   * `ast*` : An abstract syntax tree in a textual representation.

      * Human-readable representation of the abstract syntax tree
       	generated when parsing the SLIF grammar held in `slif`.

      * Expected to be present when `slif` is present, see above.
      	`ast` indicates a tree independent of the runtime, whereas
      	`ast_tcl` and `ast_rtc` indicate trees specific to the
      	referenced runtime.

   * `ctrace*` :

      * Textual and semi human-readable representation of the trace of
    	actions taken by the SLIF semantics when processing the SLIF
    	grammar held in `slif`. Expected to be present when `slif` is
    	present, see above. `ctrace` indicates a trace independent of
    	the runtime, whereas `crace_tcl` and `ctrace_rtc` indicate
    	traces specific to the referenced runtime.

      * Its presence also triggers testing by `slif-tcontainer`,
      	except if the contents indicate a parse error of any
      	kind. These tests require/presume the existence of `gcstate`.

  * `gcstate` : Textual dump of a SLIF gammar container.

      * Expected to be present when `ctrace` is present, except if the
    	contents of `ctrace` indicate any kind of parse error.

      * Presence of this file may trigger testing by
      	`slif-tcontainer`. These tests are conditional on `gcstate`
      	containing a Grammar with a L0 component, and on the existence
      	of `gcr_{c,tcl}` files.

      * Presence of this file triggers testing by
      	`generate_slif`. These tests assume the existence of
      	`generated_slif`. See `generate_*` below for more information.

  * `gcr_*` : Textual dump of a SLIF gammar container.

     * They represent the grammar contained in the `gcstate` sibling
       file, after reduction of the literals to simpler forms, per the
       intended runtime. See `slif-tcontainer`.

   * `lexaction_*` : Lexer dumps

      * Output of a SLIF lexer operating on the grammar contained in
    	the `slif` sibling file, per the lexer's runtime and chosen
    	semantic action.

   * `prewrite` : Textual dump of a SLIF gammar container.

      * They represent the grammar contained in the gcstate` sibling
    	file (presumed/required to exist), after rewriting precedenced
    	priority rules into an equivalent set of priority rules
    	without precedences. See `slif-tcontainer`.

      * Presence of this file triggers testing by
	`slif-tcontainer`. These tests require/presume a `gcstate`
	file.

   * `generated_*` : Generator output

      * Presence of a `generated_FOO` file triggers tests in the
        associated `generate_FOO` test suite. A sibling file `gcstate`
        is assumed to exit and contains the grammar fed through the
        generator FOO. An exception are `generated_slif`, see
        `gcstate` for their handling.
		
   * `rt_example` : A SLIF grammar definition

      * Its existence triggers testing by everything going through
      	`common/runtime-core`, i.e. `zeta-tcl-runtime`, and
      	`zeta-rtc-runtime`. These tests assume the existence of
      	`example` files, and of `r_ast`, `ast`, and their variants
      	(`(r_)ast_rtc`, `(r_)ast_tcl`).

      * The tests triggered by the above generate a parser from the
        `rt_example`, fed it the `example` input and match the
        resulting AST against the associated `(r_)ast` file or variant.

   * `example` : Arbitrary string

      * These files are associated with `rt_example` above, see there
        for more information.

   * `r_ast*` : An abstract syntax tree in a textual representation.

      * Human-readable representation of the abstract syntax tree
       	generated when parsing the SLIF grammar held in `slif`.

      * May be present when `rt_example` is present, see above.
      	`r_ast` indicates a tree independent of the runtime, whereas
      	`r_ast_tcl` and `r_ast_rtc` indicate trees specific to the
      	referenced runtime.
