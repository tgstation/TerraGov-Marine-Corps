SUBSYSTEM_DEF(input)
	name = "Input"
	wait = 1 //SS_TICKER means this runs every tick
	init_order = INIT_ORDER_INPUT
	flags = SS_TICKER
	priority = FIRE_PRIORITY_INPUT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/macro_set
	var/list/movement_keys


/datum/controller/subsystem/input/Initialize()
	macro_set = list("Any" = "\"KeyDown \[\[*\]\]\"", "Any+UP" = "\"KeyUp \[\[*\]\]\"", "Back" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",
		"Tab" = "\".winset \\\"input.focus=true?map.focus=true:input.focus=true\\\"\"", "Escape" = "\".winset \\\"input.text=\\\"\\\"\\\"\"",)

	movement_keys = list("W" = NORTH, "A" = WEST, "S" = SOUTH, "D" = EAST,// WASD
		"North" = NORTH, "West" = WEST, "South" = SOUTH, "East" = EAST)	// Arrow keys & Numpad

	initialized = TRUE

	refresh_client_macro_sets()

	return ..()


/datum/controller/subsystem/input/proc/refresh_client_macro_sets()
	var/list/clients = GLOB.clients
	for(var/i in 1 to length(clients))
		var/client/user = clients[i]
		user.set_macros()


/datum/controller/subsystem/input/fire()
	var/list/clients = GLOB.clients //Cache, makes it faster.
	for(var/i in 1 to length(clients))
		var/client/C = clients[i]
		C.keyLoop()
