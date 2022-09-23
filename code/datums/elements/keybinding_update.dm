/// Updates a mob's action keybinding text that shows on its maptext
/datum/element/keybinding_update

/// Activates the functionality defined by the element on the given target datum
/datum/element/keybinding_update/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOB_KEYBINDINGS_UPDATED, .proc/on_keybinding_change)
	RegisterSignal(target, COMSIG_MOB_LOGIN, .proc/on_client_change)

/datum/element/keybinding_update/Detach(datum/source, force)
	UnregisterSignal(source, COMSIG_MOB_KEYBINDINGS_UPDATED)
	UnregisterSignal(source, COMSIG_MOB_LOGIN)
	. = ..()

/// Checks all actions on the mob to see if they match the keybind_signal and updates the trigger key.
/datum/element/proc/on_keybinding_change(mob/current_mob, datum/keybinding/changed_bind)
	SIGNAL_HANDLER
	if(!changed_bind)
		return
	if(!current_mob)
		CRASH("/datum/element/keybinding_update received a mob signal without a mob tied to it")
	if(!current_mob.actions)
		return
	if(!current_mob.client)
		return
	var/client/binder_client = current_mob.client
	for(var/datum/action/user_action AS in current_mob.actions)
		if(user_action.keybind_signal == changed_bind.keybind_signal)
			user_action.update_map_text(changed_bind.get_keys_formatted(binder_client))
			break

/// Triggered when a client enters/gets admin-dragged into a mob. Necesarry since keybindings are done using individual client preferences.
/datum/element/proc/on_client_change(mob/current_mob)
	SIGNAL_HANDLER
	if(!current_mob)
		return
	if(!current_mob.client)
		return
	var/calling_client = current_mob.client
	for(var/datum/action/user_action AS in current_mob.actions)
		if(!user_action.keybind_signal)
			continue
		var/datum/keybinding/keybind = GLOB.keybindings_by_signal[user_action.keybind_signal]
		if(!keybind)
			continue
		if(!calling_client)
			continue
		user_action.update_map_text(keybind.get_keys_formatted(calling_client))


