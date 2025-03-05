
/datum/controller/subsystem
	// Metadata; you should define these.

	/// Name of the subsystem - you must change this
	name = "fire coderbus"

	/// Order of initialization. Higher numbers are initialized first, lower numbers later. Use or create defines such as [INIT_ORDER_DEFAULT] so we can see the order in one file.
	var/init_order = INIT_ORDER_DEFAULT

	/// Time to wait (in deciseconds) between each call to fire(). Must be a positive integer.
	var/wait = 20

	/// Priority Weight: When mutiple subsystems need to run in the same tick, higher priority subsystems will be given a higher share of the tick before MC_TICK_CHECK triggers a sleep, higher priority subsystems also run before lower priority subsystems
	var/priority = FIRE_PRIORITY_DEFAULT

	/// [Subsystem Flags][SS_NO_INIT] to control binary behavior. Flags must be set at compile time or before preinit finishes to take full effect. (You can also restart the mc to force them to process again)
	var/flags = NONE

	/// Which stage does this subsystem init at. Earlier stages can fire while later stages init.
	var/init_stage = INITSTAGE_MAIN

	/// This var is set to TRUE after the subsystem has been initialized.
	var/initialized = FALSE

	/// Set to 0 to prevent fire() calls, mostly for admin use or subsystems that may be resumed later
	/// use the [SS_NO_FIRE] flag instead for systems that never fire to keep it from even being added to list that is checked every tick
	var/can_fire = TRUE

	///Bitmap of what game states can this subsystem fire at. See [RUNLEVELS_DEFAULT] for more details.
	var/runlevels = RUNLEVELS_DEFAULT //points of the game at which the SS can fire

	/**
	 * boolean set by admins. if TRUE then this subsystem will stop the world profiler after ignite() returns and start it again when called.
	 * used so that you can audit a specific subsystem or group of subsystems' synchronous call chain.
	 */
	var/profiler_focused = FALSE

	/*
	 * The following variables are managed by the MC and should not be modified directly.
	 */

	///last world.time we called fire()
	var/last_fire = 0
	///scheduled world.time for next fire()
	var/next_fire = 0
	///average time to execute
	var/cost = 0
	///average time to execute
	var/tick_usage = 0
	///average tick usage
	var/tick_overrun = 0
	/// Flat list of usage and time, every odd index is a log time, every even index is a usage
	var/list/rolling_usage = list()
	/// How much of a tick (in percents of a tick) were we allocated last fire.
	var/tick_allocation_last = 0
	/// How much of a tick (in percents of a tick) do we get allocated by the mc on avg.
	var/tick_allocation_avg = 0
	///tracks the current state of the ss, running, paused, etc.
	var/state = SS_IDLE
	/// Tracks how many times a subsystem has ever slept in fire().
	var/slept_count = 0
	///ticks this ss is taking to run right now.
	var/paused_ticks = 0
	///total tick_usage of all of our runs while pausing this run
	var/paused_tick_usage
	///how many ticks does this ss take to run on avg.
	var/ticks = 1
	///number of times we have called fire()
	var/times_fired = 0
	///time we entered the queue, (for timing and priority reasons)
	var/queued_time = 0
	///we keep a running total to make the math easier, if priority changes mid-fire that would break our running total, so we store it here
	var/queued_priority
	/// Next subsystem in the queue of subsystems to run this tick
	var/datum/controller/subsystem/queue_next
	/// Previous subsystem in the queue of subsystems to run this tick
	var/datum/controller/subsystem/queue_prev

	var/static/list/failure_strikes //How many times we suspect a subsystem type has crashed the MC, 3 strikes and you're out!

	/// String to store an applicable error message for a subsystem crashing, used to help debug crashes in contexts such as Continuous Integration/Unit Tests
	var/initialization_failure_message = null

	//Do not blindly add vars here to the bottom, put it where it goes above
	//If your var only has two values, put it in as a flag.

//Do not override
///datum/controller/subsystem/New()

// Used to initialize the subsystem BEFORE the map has loaded
// Called AFTER Recover if that is called
// Prefer to use Initialize if possible
/datum/controller/subsystem/proc/PreInit()
	return

///This is used so the mc knows when the subsystem sleeps. do not override.
/datum/controller/subsystem/proc/ignite(resumed = 0)
	set waitfor = 0
	. = SS_IDLE

	tick_allocation_last = Master.current_ticklimit-(TICK_USAGE)
	tick_allocation_avg = MC_AVERAGE(tick_allocation_avg, tick_allocation_last)

	. = SS_SLEEPING
	fire(resumed)
	. = state
	if (state == SS_SLEEPING)
		slept_count++
		state = SS_IDLE
	if (state == SS_PAUSING)
		slept_count++
		var/QT = queued_time
		enqueue()
		state = SS_PAUSED
		queued_time = QT

///previously, this would have been named 'process()' but that name is used everywhere for different things!
///fire() seems more suitable. This is the procedure that gets called every 'wait' deciseconds.
///Sleeping in here prevents future fires until returned..
/datum/controller/subsystem/proc/fire(resumed = 0)
	flags |= SS_NO_FIRE
	throw EXCEPTION("Subsystem [src]([type]) does not fire() but did not set the SS_NO_FIRE flag. Please add the SS_NO_FIRE flag to any subsystem that doesn't fire so it doesn't get added to the processing list and waste cpu.")

/datum/controller/subsystem/Destroy()
	dequeue()
	can_fire = 0
	flags |= SS_NO_FIRE
	if(Master)
		Master.subsystems -= src
	return ..()

///Queue it to run.
/// (we loop thru a linked list until we get to the end or find the right point)
/// (this lets us sort our run order correctly without having to re-sort the entire already sorted list)
/datum/controller/subsystem/proc/enqueue()
	var/SS_priority = priority
	var/SS_flags = flags
	var/datum/controller/subsystem/queue_node
	var/queue_node_priority
	var/queue_node_flags

	for (queue_node = Master.queue_head; queue_node; queue_node = queue_node.queue_next)
		queue_node_priority = queue_node.queued_priority
		queue_node_flags = queue_node.flags

		if (queue_node_flags & (SS_TICKER|SS_BACKGROUND) == SS_TICKER)
			if ((SS_flags & (SS_TICKER|SS_BACKGROUND)) != SS_TICKER)
				continue
			if (queue_node_priority < SS_priority)
				break

		else if (queue_node_flags & SS_BACKGROUND)
			if (!(SS_flags & SS_BACKGROUND))
				break
			if (queue_node_priority < SS_priority)
				break

		else
			if (SS_flags & SS_BACKGROUND)
				continue
			if (SS_flags & SS_TICKER)
				break
			if (queue_node_priority < SS_priority)
				break

	queued_time = world.time
	queued_priority = SS_priority
	state = SS_QUEUED
	if (SS_flags & SS_BACKGROUND) //update our running total
		Master.queue_priority_count_bg += SS_priority
	else
		Master.queue_priority_count += SS_priority

	queue_next = queue_node
	if (!queue_node)//we stopped at the end, add to tail
		queue_prev = Master.queue_tail
		if (Master.queue_tail)
			Master.queue_tail.queue_next = src
		else //empty queue, we also need to set the head
			Master.queue_head = src
		Master.queue_tail = src

	else if (queue_node == Master.queue_head)//insert at start of list
		Master.queue_head.queue_prev = src
		Master.queue_head = src
		queue_prev = null
	else
		queue_node.queue_prev.queue_next = src
		queue_prev = queue_node.queue_prev
		queue_node.queue_prev = src


/datum/controller/subsystem/proc/dequeue()
	if (queue_next)
		queue_next.queue_prev = queue_prev
	if (queue_prev)
		queue_prev.queue_next = queue_next
	if (Master && (src == Master.queue_tail))
		Master.queue_tail = queue_prev
	if (Master && (src == Master.queue_head))
		Master.queue_head = queue_next
	queued_time = 0
	if (state == SS_QUEUED)
		state = SS_IDLE


/datum/controller/subsystem/proc/pause()
	. = 1
	switch(state)
		if(SS_RUNNING)
			state = SS_PAUSED
		if(SS_SLEEPING)
			state = SS_PAUSING

/// Called after the config has been loaded or reloaded.
/datum/controller/subsystem/proc/OnConfigLoad()


//used to initialize the subsystem AFTER the map has loaded
/datum/controller/subsystem/Initialize()
	return SS_INIT_NONE

//hook for printing stats to the "MC" statuspanel for admins to see performance and related stats etc.
/datum/controller/subsystem/stat_entry(msg)
	if(can_fire && !(SS_NO_FIRE & flags) && init_stage <= Master.init_stage_completed)
		msg = "[round(cost,1)]ms|[round(tick_usage,1)]%([round(tick_overrun,1)]%)|[round(ticks,0.1)]\t[msg]"
	else
		msg = "OFFLINE\t[msg]"
	return msg

/datum/controller/subsystem/proc/state_letter()
	switch (state)
		if (SS_RUNNING)
			. = "R"
		if (SS_QUEUED)
			. = "Q"
		if (SS_PAUSED, SS_PAUSING)
			. = "P"
		if (SS_SLEEPING)
			. = "S"
		if (SS_IDLE)
			. = "  "

//could be used to postpone a costly subsystem for (default one) var/cycles, cycles
//for instance, during cpu intensive operations like explosions
/datum/controller/subsystem/proc/postpone(cycles = 1)
	if(next_fire - world.time < wait)
		next_fire += (wait*cycles)

/// Prunes out of date entries in our rolling usage list
/datum/controller/subsystem/proc/prune_rolling_usage()
	var/list/rolling_usage = src.rolling_usage
	var/cut_to = 0
	while(cut_to + 2 <= length(rolling_usage) && rolling_usage[cut_to + 1] < DS2TICKS(world.time - Master.rolling_usage_length))
		cut_to += 2
	if(cut_to)
		rolling_usage.Cut(1, cut_to + 1)

//usually called via datum/controller/subsystem/New() when replacing a subsystem (i.e. due to a recurring crash)
//should attempt to salvage what it can from the old instance of subsystem
/datum/controller/subsystem/Recover()

/datum/controller/subsystem/vv_edit_var(var_name, var_value)
	switch (var_name)
		if ("can_fire")
			//this is so the subsystem doesn't rapid fire to make up missed ticks causing more lag
			if (var_value)
				next_fire = world.time + wait
		if ("queued_priority") //editing this breaks things.
			return 0
	. = ..()
