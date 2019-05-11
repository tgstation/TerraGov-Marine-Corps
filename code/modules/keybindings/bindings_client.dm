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

	var/list/userkb = prefs.key_bindings
	var/list/kb = list()
	for (var/i in userkb)
		kb[userkb[i]] = i

	var/key_action = kb[_key]

	switch(key_action)
		if("choose-help")
			choosehelp()
			return
		if("screenshot") // Screenshot. Hold shift to choose a name and location to save in
			winset(src, null, "command=.screenshot [!keys_held["shift"] ? "auto" : ""]")
			return
		if("admin-say")
			get_asay()
			return
		if("mentor-say")
			get_msay()
			return
		if("dead-say")
			get_dsay()
			return
		if("toggle-hud") // Toggles minimal HUD
			mob.button_pressed_F12()
			return

	if(holder)
		holder.key_down(_key, src, key_action)

	if(mob.focus)
		mob.focus.key_down(_key, src, key_action)


/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	keys_held -= _key
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	var/list/userkb = prefs.key_bindings
	var/list/kb = list()
	for (var/i in userkb)
		kb[userkb[i]] = i

	var/key_action = kb[_key]

	if(holder)
		holder.key_up(_key, src, key_action)
	if(mob.focus)
		mob.focus.key_up(_key, src, key_action)


// Called every game tick
/client/keyLoop()
	if(holder)
		holder.keyLoop(src)
	if(mob.focus)
		mob.focus.keyLoop(src)