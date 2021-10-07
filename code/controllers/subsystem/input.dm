SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_set

/datum/controller/subsystem/input/Initialize()
	setup_default_macro_sets()

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()

// This is for when macro sets are eventualy datumized
/datum/controller/subsystem/input/proc/setup_default_macro_sets()
	macro_set = list(
		"Any" = "\"KeyDown \[\[*\]\]\"",
		"Any+UP" = "\"KeyUp \[\[*\]\]\"",
		"Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
		"Tab" = "\".winset \\\"input.focus=true ? map.focus=true : input.focus=true\\\"\"",
		"Escape" = "Reset-Held-Keys",
	)


/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to length(clients))
		var/client/user = clients[i]
		user.set_macros()
		user.update_movement_keys()

/datum/controller/subsystem/input/fire()
	for(var/mob/user as anything in GLOB.player_list)
		user.focus?.keyLoop(user.client)
