// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held[_key] = world.time
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !keys_held["Ctrl"])
		next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	for (var/i in prefs.key_bindings[_key])
		var/datum/keybinding/kb = i
		if (kb.down(src))
			break

	holder?.key_down(_key, src)
	mob.focus?.key_down(_key, src)


/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held -= _key
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	for (var/i in prefs.key_bindings[_key])
		var/datum/keybinding/kb = i
		if (kb.up(src))
			break

	holder?.key_up(_key, src)
	mob.focus?.key_up(_key, src)


// Called every game tick
/client/keyLoop()
	holder?.keyLoop(src)
	mob.focus?.keyLoop(src)
