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

	switch(_key)
		if("F1")
			choosehelp()
			return
		if("F2") // Screenshot. Hold shift to choose a name and location to save in
			winset(src, null, "command=.screenshot [!keys_held["shift"] ? "auto" : ""]")
			return
		if("F3")
			get_asay()
			return
		if("F4")
			get_msay()
			return
		if("F5")
			get_dsay()
			return
		if("F12") // Toggles minimal HUD
			mob.button_pressed_F12()
			return

	holder?.key_down(_key, src)
	mob.focus?.key_down(_key, src)


/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held -= _key
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	holder?.key_up(_key, src)
	mob.focus?.key_up(_key, src)


// Called every game tick
/client/keyLoop()
	holder?.keyLoop(src)
	mob.focus?.keyLoop(src)