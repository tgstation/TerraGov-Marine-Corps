// Adds a timer that ticks down based on the timer datums
/datum/component/hud_timer
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/mob/owner
	var/timer_text
	// The list of timers that are currently being displayed
	var/list/timers = list()
	// The list of signals that will start the timer
	var/start_signals = list()
	var/stop_signals = list()
	// The callback to call using the signals. Should return a timer ID
	var/callback
// I wonder if it'd be better to make this into two elements, one for nuke and the other for hive orphaning
/datum/component/hud_timer/Initialize(time_to_display, text, start_signals, stop_signals, signal_callback, start_immediately = TRUE)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	if(!length(start_signals))
		return COMPONENT_INCOMPATIBLE
	owner = parent
	timer_text = text
	callback = signal_callback
	start_signals = start_signals
	stop_signals = stop_signals
	if(start_immediately && owner?.client && time_to_display)
		AddTimer(time_to_display)
	// the signal lists are laid out like this: [COMSIG_FOO: src]
	for(var/signal in start_signals)
		var/resolved = resolve_ref(start_signals[signal])
		RegisterSignal(resolved, signal, PROC_REF(timer_start_signal))

	for(var/signal in stop_signals)
		var/resolved = resolve_ref(stop_signals[signal])
		RegisterSignal(resolved, signal, PROC_REF(timer_stop_signal))

/datum/component/hud_timer/UnregisterFromParent()
	. = ..()
	owner = null
	for(var/signal in start_signals)
		var/resolved = resolve_ref(start_signals[signal])
		UnregisterSignal(resolved, signal)

	for(var/signal in stop_signals)
		var/resolved = resolve_ref(stop_signals[signal])
		UnregisterSignal(resolved, signal)

/datum/component/hud_timer/proc/AddTimer(time_to_display)
	timers.Add(time_to_display)
	if(owner?.client)
		add_new_timer(time_to_display)

/datum/component/hud_timer/proc/timer_start_signal(...)
	var/timer = call(owner, callback)(arglist(args))
	if(!timer)
		return

	AddTimer(timer)

/datum/component/hud_timer/proc/timer_stop_signal(...)
	var/timer_to_stop = call(owner, callback)(arglist(args))
	if(!timer_to_stop)
		return

	remove_timers()
	timers.Remove(timer_to_stop)
	add_all_timers()

/datum/component/hud_timer/proc/add_all_timers()
	for(var/timer in timers)
		add_new_timer(timer)

/datum/component/hud_timer/proc/add_new_timer(timer_to_add)
	var/displays = length(timers)
	for(var/atom/movable/screen/text/screen_timer/display in owner.client?.screen)
		displays += 1
	if(displays > 5)
		return

	var/atom/movable/screen/text/screen_timer/screen_timer = new(0, owner.client, timer_to_add, timer_text)
	screen_timer.maptext_y = clamp(screen_timer.maptext_y - displays * 12, -130, -70)

/datum/component/hud_timer/proc/remove_timers()
	for(var/atom/movable/screen/text/screen_timer/display in owner.client?.screen)
		var/timer = display.timer_id
		if(timer in timers)
			display.stop_timer()

// Helps for typing
/datum/component/hud_timer/proc/resolve_ref(datum/weakref/ref)
	return ref.resolve()
