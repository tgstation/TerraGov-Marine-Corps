SUBSYSTEM_DEF(events)
	name = "Events"
	init_order = INIT_ORDER_EVENTS
	runlevels = RUNLEVEL_GAME

	var/list/control = list()	//list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/running = list()	//list of all existing /datum/round_event
	var/list/currentrun = list()

	var/scheduled = 0			//The next world.time that a naturally occuring random event can be selected.
	var/frequency_lower = 1800	//3 minutes lower bound.
	var/frequency_upper = 6000	//10 minutes upper bound. Basically an event will happen every 3 to 10 minutes.

	var/list/holidays			//List of all holidays occuring today or null if no holidays
	var/wizardmode = FALSE

/datum/controller/subsystem/events/fire(resumed = 0)
	var/i = 1
	while(i<=events.len)
		var/datum/event/Event = events[i]
		if(Event)
			Event.process()
			i++
			continue
		events.Cut(i,i+1)
	checkEvent()
