// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	if(length(key) > 32)
		log_admin("[key_name(src)] just attempted to send an invalid keypress with length over 32 characters, likely malicious.")
		message_admins("[ADMIN_TPMONTY(mob)] just attempted to send an invalid keypress with length over 32 characters, likely malicious.")
		QDEL_IN(src, 1)
		return


//Focus Chat failsafe. Overrides movement checks to prevent WASD.
	if(prefs.focus_chat && length(_key) == 1)
		winset(src, null, "input.focus=true")
		winset(src, null, "input.text=[url_encode(_key)]")
		return

	keys_held[current_key_address + 1] = _key

	keys_held[_key] = world.time

	current_key_address = ((current_key_address + 1) % 10)

	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !keys_held["Ctrl"])
		next_move_dir_add |= movement



	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	var/AltMod = keys_held["Alt"] ? "Alt-" : ""
	var/CtrlMod = keys_held["Ctrl"] ? "Ctrl-" : ""
	var/ShiftMod = keys_held["Shift"] ? "Shift-" : ""
	var/full_key = "[_key]"
	if (!(_key in list("Alt", "Ctrl", "Shift")))
		full_key = "[AltMod][CtrlMod][ShiftMod][_key]"
	for (var/kb_name in prefs.key_bindings[full_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		if (kb.down(src))
			break

	holder?.key_down(full_key, src)
	mob.focus?.key_down(full_key, src)


/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	for(var/i in 1 to 10)
		if(keys_held[i] == _key)
			keys_held[i] = null
			break

	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	for (var/kb_name in prefs.key_bindings[_key])
		var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
		if (kb.up(src))
			break

	holder?.key_up(_key, src)
	mob.focus?.key_up(_key, src)


// Called every game tick
/client/keyLoop()
	holder?.keyLoop(src)
	mob.focus?.keyLoop(src)
