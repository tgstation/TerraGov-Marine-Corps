/// Defers MouseEntered inputs to only apply to the most recently hovered over atom in the tick
SUBSYSTEM_DEF(mouse_entered)
	name = "MouseEntered"
	wait = 1
	flags = SS_NO_INIT | SS_TICKER
	priority = FIRE_PRIORITY_MOUSE_ENTERED
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	///List of atoms by client that are being hovered over in the current tick
	var/list/hovers = list()
	///A separate list of weakrefs to the same atoms as hovers, but not nulled in fire() so we can reference them safely
	var/list/hover_refs = list()

/datum/controller/subsystem/mouse_entered/fire()
	for (var/hovering_client in hovers)
		var/atom/hovering_atom = hovers[hovering_client]
		if (isnull(hovering_atom))
			continue

		hovering_atom.on_mouse_enter(hovering_client)

		// This intentionally runs `= null` and not `-= hovering_client`, as we want to prevent the list from shrinking,
		// which could cause problems given the heat of MouseEntered.
		// Lummox has teased this for 515: https://www.byond.com/forum/post/2621745
		// ...though you're most likely reading this on BYOND version 600.
		// -- update, don't have this in 516 >:(
		hovers[hovering_client] = null
