SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = INIT_ORDER_EVENTS
	runlevels = RUNLEVEL_GAME

	///list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/control = list()
	///list of all existing /datum/round_event
	var/list/running = list()
	var/list/currentrun = list()

	///The next world.time that a naturally occuring random event can be selected.
	var/scheduled = 0
	///Lower bound for how frequently events will occur
	var/frequency_lower = 5 MINUTES
	///the latest an event can happen after a previous event
	var/frequency_upper = 15 MINUTES

/datum/controller/subsystem/events/Initialize()
	if(CONFIG_GET(flag/events_disallowed))
		can_fire = 0
	for(var/type in typesof(/datum/round_event_control))
		var/datum/round_event_control/E = new type()
		if(!E.typepath)
			continue				//don't want this one! leave it for the garbage collector
		control += E				//add it to the list of all events (controls)
	reschedule()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/events/fire(resumed = 0)
	if(!resumed)
		check_event() //only check these if we aren't resuming a paused fire
		src.currentrun = running.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/datum/thing = currentrun[length(currentrun)]
		currentrun.len--
		if(thing)
			thing.process()
		else
			running.Remove(thing)
		if (MC_TICK_CHECK)
			return

///checks if we should select a random event yet, and reschedules if necessary
/datum/controller/subsystem/events/proc/check_event()
	if(scheduled <= world.time)
		spawn_event()
		reschedule()

///decides which world.time we should select another random event at.
/datum/controller/subsystem/events/proc/reschedule()
	scheduled = world.time + rand(frequency_lower, max(frequency_lower,frequency_upper))

///selects a random event based on whether it can occur and it's 'weight'(probability)
/datum/controller/subsystem/events/proc/spawn_event()
	set waitfor = FALSE	//for the admin prompt

	var/gamemode = SSticker.mode.config_tag
	var/players_amt = get_active_player_count(alive_check = TRUE, afk_check = TRUE)
	// Only alive, non-AFK human players count towards this.

	var/sum_of_weights = 0
	for(var/datum/round_event_control/E in control)
		if(!E.can_spawn_event(players_amt, gamemode))
			continue
		if(E.weight < 0)						//for round-start events etc.
			var/res = trigger_event(E)
			if(res == EVENT_INTERRUPTED)
				continue	//like it never happened
			if(res == EVENT_CANT_RUN)
				return
		sum_of_weights += E.weight

	sum_of_weights = rand(0,sum_of_weights)	//reusing this variable. It now represents the 'weight' we want to select

	for(var/datum/round_event_control/E in control)
		if(!E.can_spawn_event(players_amt, gamemode))
			continue
		sum_of_weights -= E.weight

		if(sum_of_weights <= 0)				//we've hit our goal
			if(trigger_event(E))
				return

/datum/controller/subsystem/events/proc/trigger_event(datum/round_event_control/E)
	. = E.pre_run_event()
	if(. == EVENT_CANT_RUN)//we couldn't run this event for some reason, set its max_occurrences to 0
		E.max_occurrences = 0
	else if(. == EVENT_READY)
		E.run_event(not_forced = TRUE)

ADMIN_VERB(force_event, R_FUN, "Trigger Event", "Force a selected Event", ADMIN_CATEGORY_FUN)
	user.holder.force_event()

/datum/admins/proc/force_event()
	var/dat = ""
	var/normal = ""

	for(var/datum/round_event_control/E in SSevents.control)
		dat = "<BR><A href='byond://?src=[REF(src)];[HrefToken()];force_event=[REF(E)]'>[E]</A>"
		normal 	+= dat

	dat = normal

	var/datum/browser/popup = new(usr, "force_event", "Force Random Event", 300, 750)
	popup.set_content(dat)
	popup.open()

ADMIN_VERB(toggle_events, R_FUN, "Toggle Events Subsystem", "Toggle SSevents on and off", ADMIN_CATEGORY_FUN)
	SSevents.can_fire = !SSevents.can_fire
	message_admins("[key_name_admin(user)] has toggled the events subsystem [SSevents.can_fire == 1 ? "on" : "off"]")
	log_admin("[key_name(user)] has toggled the events subsystem [SSevents.can_fire == 1 ? "on" : "off"]")
