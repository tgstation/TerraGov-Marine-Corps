/// Creates and sorts all the keybinding datums
/proc/init_keybindings()
	for(var/KB in subtypesof(/datum/keybinding))
		var/datum/keybinding/keybinding = KB
		if(!initial(keybinding.keybind_signal))
			continue
		add_keybinding(new keybinding)
	init_emote_keybinds()
		

/// Adds an instanced keybinding to the global tracker
/proc/add_keybinding(datum/keybinding/instance)
	if(!instance.name)
		return
	GLOB.keybindings_by_name[instance.name] = instance

	// Classic
	if(LAZYLEN(instance.classic_keys))
		for(var/bound_key in instance.classic_keys)
			LAZYADD(GLOB.classic_keybinding_list_by_key[bound_key], list(instance.name))

	// Hotkey
	if(LAZYLEN(instance.hotkey_keys))
		for(var/bound_key in instance.hotkey_keys)
			LAZYADD(GLOB.hotkey_keybinding_list_by_key[bound_key], list(instance.name))

/// Create a keybind for each datum/emote
/proc/init_emote_keybinds()
	for(var/i in subtypesof(/datum/emote))
		var/datum/emote/faketype = i
		if(!initial(faketype.key) || initial(faketype.flags_emote) & NO_KEYBIND)
			continue
		var/datum/keybinding/emote/emote_kb = new
		emote_kb.link_to_emote(faketype)
		add_keybinding(emote_kb)
	for(var/i in 1 to CUSTOM_EMOTE_SLOTS)
		var/datum/keybinding/custom_emote/emote_kb = new
		emote_kb.set_id(i)
		add_keybinding(emote_kb)
