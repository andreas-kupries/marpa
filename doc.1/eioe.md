Extended IO event handling

Current setup recognizes:

1.	End of Input
	Trigger: current >= max(input)
	Action:	 Engine exits unrecoverably IO processing.

1.	Stop via user-specified marker at arbitrary input location.
	Trigger: current == marker (before entering char/byte processing)
	Action:	 Signal `stop`, empty event list, via event callback
		 Clear marker

Proposals:

1.	EOI.

	Do:	Change trigger condition to ==.

	Reasoning:
		This enables us to put more content after the primary
		input and process it without fear of the engine
		believing to be at EOI when in the extended area while
		still also being prevented from simply running over
		the end of the primary input into the expansion.

		Without the change we can still add content, but then
		will also have to use the single stop marker to
		prevent the engine from running into the expansion,
		and then force EOI by moving it behind the expansion.

1.	Stop marker.

	Do:	Manage an arbitrary set of named markers, instead of a
		single unnamed marker.

	Do 2:	Attach actions to each marker. Initial set of possible
	   	actions would be:

		- EOI		Trigger EOI, engine exit
		- Stop		Signal reached marker as named stop event
		- Jump N	Move location to character N.

		As before a reached marker is automatically removed.

	Reasoning:
		This enables the processing of nested includes, macros
		where we have multiple levels of input active at the
		same time, each with its own stop location triggering
		a return.

		Note that during processing we only have to know about
		the nearest stop marker reachable from the current
		location, IOW it is not necessary to probe the entire
		(hash)table of stops on each byte/char to process.

		Recalculation of that current marker is only necessary
		when a marker is added, removed, or the current
		location makes non-standard jump.
