// Adds a timer that ticks down based on the timer datums
/datum/element/hud_timer
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 3
	var/list/users = list()
	var/datum/weakref/callback_target_ref
	var/style_start = "<span class='maptext' style=font-size:16pt;text-align:center; align='top'>"
	// <span class='maptext' style=font-size:16pt;text-align:center;color=red align='top'>
	var/style_end = "</span>"
	var/timer_text
	// The list of timers that are currently being displayed
	var/list/timers = list()
	// The list of signals that will start the timer
	var/start_signals = list()
	var/stop_signals = list()
	// The callback to call using the signals. Should return a timer ID
	var/callback
	var/global_signals_registered = FALSE

/datum/element/hud_timer/Attach(mob/target, time_to_display, text, start_signals, stop_signals, signal_callback, callback_target, start_immediately = TRUE)
	if(!ismob(target))
		return COMPONENT_INCOMPATIBLE
	if(!length(start_signals))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	users.Add(WEAKREF(target))
	// The reason for the conditionals is so we can use default values here
	if(text)
		timer_text = text
	if(signal_callback)
		callback = signal_callback
	if(callback_target)
		callback_target_ref = WEAKREF(callback_target)
	else 
		callback_target_ref = WEAKREF(src)
	if(length(start_signals))
		start_signals = start_signals
	if(length(stop_signals))
		stop_signals = stop_signals
	if(start_immediately && target?.client && time_to_display)
		add_timer(time_to_display)
	// the signal lists are laid out like this: [COMSIG_FOO: WEAKREF(src)]
	for(var/signal in start_signals)
		handle_signal(start_signals[signal], signal, PROC_REF(timer_start_signal))

	for(var/signal in stop_signals)
		handle_signal(stop_signals[signal], signal, PROC_REF(timer_stop_signal))
	// We don't want to re-register global comsigs twice, as that causes runtimes.
	// This is only a problem because elements have one instance per type
	global_signals_registered = TRUE

/datum/element/hud_timer/Detach(datum/source)
	for(var/datum/weakref/weakref in users)
		var/mob/user = weakref.resolve()
		if(user == source)
			users.Remove(weakref)
			break

	var/list/signals_to_remove = list()
	signals_to_remove.Add(start_signals, stop_signals)

	// Here we *hopefully* only unregister the global signals
	for(var/signal in signals_to_remove)
		if(is_global_signal(signals_to_remove[signal]))
			handle_signal(signals_to_remove[signal], signal, register = FALSE)
	return ..()

/datum/element/hud_timer/Destroy(force)
	. = ..()
	var/list/signals_to_remove = list()
	signals_to_remove.Add(start_signals, stop_signals)
	for(var/signal in signals_to_remove)
		if(is_global_signal(signals_to_remove[signal]))
			return
		handle_signal(signals_to_remove[signal], signal, register = FALSE)

/datum/element/hud_timer/proc/handle_signal(datum/weakref/weakref_target, signal, callback, register = TRUE)
	var/resolved = weakref_target.resolve()
	if(global_signals_registered && istype(resolved, /datum/controller/subsystem/processing/dcs))
		return
	if(register)
		RegisterSignal(resolved, signal, callback)
	else
		UnregisterSignal(resolved, signal)
	global_signals_registered = TRUE	

/datum/element/hud_timer/proc/is_global_signal(datum/weakref/signal_target)
	var/resolved = signal_target.resolve()
	return global_signals_registered && istype(resolved, /datum/controller/subsystem/processing/dcs)

/datum/element/hud_timer/proc/add_timer(time_to_display)
	if(time_to_display in timers)
		return
	timers.Add(time_to_display)
	add_new_timer(time_to_display)

/datum/element/hud_timer/proc/timer_start_signal(...)
	SIGNAL_HANDLER
	var/timer = handle_callback()
	if(!timer)
		return
	add_timer(timer)

/datum/element/hud_timer/proc/timer_stop_signal(...)
	SIGNAL_HANDLER
	var/timer_to_stop = handle_callback()
	if(!timer_to_stop)
		return
	remove_timers()
	timers.Remove(timer_to_stop)
	add_all_timers()

/datum/element/hud_timer/proc/handle_callback()
	var/callback_target = resolve_ref(callback_target_ref)
	if(!callback_target)
		return FALSE
	var/timer_to_stop = call(callback_target, callback)(arglist(args))
	if(!timer_to_stop)
		return FALSE
	return timer_to_stop

/datum/element/hud_timer/proc/add_all_timers()
	for(var/timer in timers)
		add_new_timer(timer)

/datum/element/hud_timer/proc/add_new_timer(timer_to_add)
	for(var/owner_weakref in users)
		var/datum/weakref/weakref = owner_weakref
		var/displays
		var/mob/owner = resolve_ref(weakref)
		if(!owner || !owner.client)
			continue
		for(var/atom/movable/screen/text/screen_timer/display in owner.client?.screen)
			displays += 1
		if(displays > 5)
			return

		var/atom/movable/screen/text/screen_timer/screen_timer = new(0, owner.client, timer_to_add, "[style_start][timer_text][style_end]")
		screen_timer.maptext_y = clamp(screen_timer.maptext_y - displays * 12, -130, -70)

/datum/element/hud_timer/proc/remove_timers()
	for(var/owner_weakref in users)
		var/datum/weakref/weakref = owner_weakref
		var/mob/owner = resolve_ref(weakref)
		if(!owner)
			continue
		for(var/atom/movable/screen/text/screen_timer/display in owner.client?.screen)
			var/timer = display.timer_id
			if(timer in timers)
				display.stop_timer()

// Helps for typing
/datum/element/hud_timer/proc/resolve_ref(datum/weakref/ref)
	return ref.resolve()

// Ready made timers with no configuration neccesary.
// Implementation had to be a little odd due to having to use weakrefs

/datum/element/hud_timer/nuke
	timer_text = "NUKE ACTIVE: ${timer}"

// /datum/element/hud_timer/nuke/New()
// 	. = ..()
// 	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, PROC_REF(timer_start_signal))
// 	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_STOP, PROC_REF(timer_stop_signal))

/datum/element/hud_timer/nuke/Attach(mob/target, time_to_display, text, start_signals, stop_signals, signal_callback, callback_target, start_immediately = TRUE)
	start_signals = list(
		COMSIG_GLOB_NUKE_START = WEAKREF(SSdcs),
		COMSIG_MOB_LOGIN = WEAKREF(target),
	)
	stop_signals = list(
		COMSIG_GLOB_NUKE_STOP = WEAKREF(SSdcs),
		COMSIG_MOB_GHOST = WEAKREF(target),
		COMSIG_MOB_LOGOUT = WEAKREF(target),
	)
	callback = PROC_REF(get_nuke_callback)
	. = ..()

/datum/element/hud_timer/nuke/proc/get_nuke_callback(source, obj/machinery/nuclearbomb/possible_nuke)
	SIGNAL_HANDLER
	if(istype(possible_nuke, /obj/machinery/nuclearbomb))
		return possible_nuke.timer
	else if(length(GLOB.active_nuke_list))
		possible_nuke = GLOB.active_nuke_list[length(GLOB.active_nuke_list)]
	else
		return null
	return possible_nuke.timer

// /datum/element/hud_timer/nuke/Destroy(force)
// 	. = ..()
// 	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_START)
// 	UnregisterSignal(SSdcs, COMSIG_GLOB_NUKE_STOP)

/datum/element/hud_timer/hive_collapse
	timer_text = "HIVE COLLAPSE: ${timer}"

// /datum/element/hud_timer/hive_collapse/New()
// 	. = ..()
// 	RegisterSignal(SSdcs, COMSIG_GLOB_HIVE_COLLAPSING, PROC_REF(timer_start_signal))
// 	RegisterSignal(SSdcs, COMSIG_GLOB_HIVE_COLLAPSE_END, PROC_REF(timer_stop_signal))

/datum/element/hud_timer/hive_collapse/Attach(mob/target, time_to_display, text, start_signals, stop_signals, signal_callback, callback_target, start_immediately = TRUE)
	start_signals = list(
		COMSIG_GLOB_HIVE_COLLAPSING = WEAKREF(SSdcs),
		COMSIG_MOB_LOGIN = WEAKREF(target),
	)
	stop_signals = list(
		COMSIG_GLOB_HIVE_COLLAPSE_END = WEAKREF(SSdcs),
		COMSIG_MOB_GHOST = WEAKREF(target),
		COMSIG_MOB_LOGOUT = WEAKREF(target),
	)
	callback = PROC_REF(get_hive_collapse_callback)
	. = ..()

/datum/element/hud_timer/hive_collapse/proc/get_hive_collapse_callback(source, hive_timer)
	SIGNAL_HANDLER
	return hive_timer
