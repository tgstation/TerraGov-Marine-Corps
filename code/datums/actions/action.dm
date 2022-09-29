
/datum/action
	var/name = "Generic Action"
	var/desc
	var/datum/target = null
	var/obj/screen/action_button/button = null
	var/mob/owner
	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "default"
	var/background_icon = 'icons/mob/actions.dmi'
	var/background_icon_state = "template"
	// holds a set of misc visual references to use with the overlay API
	var/list/visual_references = list(
		VREF_MUTABLE_LINKED_OBJ = null,
		VREF_MUTABLE_ACTION_STATE = null,
		VREF_MUTABLE_MAPTEXT = null,
		VREF_MUTABLE_SELECTED_FRAME = null,
		VREF_IMAGE_ONTOP = null
	)
	///Main keybind signal for the action
	var/keybind_signal
	///Alternative keybind signal, to use the action differently
	var/alternate_keybind_signal

/datum/action/New(Target)
	target = Target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clean_action)
	button = new
	if(isobj(target))
		var/obj/target_obj = target
		var/mutable_appearance/obj_appeareance = target_obj.appearance
		visual_references[VREF_MUTABLE_LINKED_OBJ] = obj_appeareance
		button.add_overlay(obj_appeareance)
	button.icon = icon(background_icon, background_icon_state)
	button.source_action = src
	button.name = name
	if(desc)
		button.desc = desc
	var/mutable_appearance/maptext_appearence = mutable_appearance()
	maptext_appearence.layer = ABOVE_HUD_LAYER // above selected/empowered frame
	visual_references[VREF_MUTABLE_MAPTEXT] = maptext_appearence
	var/mutable_appearance/selected_appeareance = mutable_appearance('icons/mob/actions.dmi', "selected_frame")
	selected_appeareance.layer = HUD_LAYER
	visual_references[VREF_MUTABLE_SELECTED_FRAME] = selected_appeareance
	var/mutable_appearance/action_appearence =	mutable_appearance(action_icon, action_icon_state)
	action_appearence.layer = HUD_LAYER
	visual_references[VREF_MUTABLE_ACTION_STATE] = action_appearence

/datum/action/Destroy()
	if(owner)
		remove_action(owner)
	QDEL_NULL(button)
	target = null
	return ..()

/datum/action/proc/clean_action()
	SIGNAL_HANDLER
	qdel(src)

/datum/action/proc/should_show()
	return TRUE

/// A handler used to update the maptext and show the change immediately.
/datum/action/proc/update_map_text(key_string)
	// The cutting needs to be done /BEFORE/ the string maptext gets changed
	// Since byond internally recognizes it as a different image, and doesn't cut it properly
	button.cut_overlay(visual_references[VREF_MUTABLE_MAPTEXT])
	var/image/maptext_image = visual_references[VREF_MUTABLE_MAPTEXT]
	maptext_image.maptext = MAPTEXT(key_string)
	button.add_overlay(visual_references[VREF_MUTABLE_MAPTEXT])

/datum/action/proc/update_button_icon()
	if(!button)
		return

	button.name = name
	button.desc = desc

	if(action_icon && action_icon_state)
		button.cut_overlay(visual_references[VREF_MUTABLE_ACTION_STATE])
		var/mutable_appearance/action_appearence = visual_references[VREF_MUTABLE_ACTION_STATE]
		action_appearence.icon = action_icon
		action_appearence.icon_state = action_icon_state
		//visual_references[VREF_MUTABLE_ACTION_STATE] = action_appearence
		button.add_overlay(visual_references[VREF_MUTABLE_ACTION_STATE])
	if(background_icon_state)
		button.icon_state = background_icon_state

	handle_button_status_visuals()


	return TRUE

/// A proc called on update button action for  additional visuals beyond the very base
/datum/action/proc/handle_button_status_visuals()
	if(can_use_action())
		button.color = rgb(255, 255, 255, 255)
	else
		button.color = rgb(128, 0, 0, 128)


/datum/action/proc/action_activate()
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

///Signal Handler for main action
/datum/action/proc/keybind_activation()
	SIGNAL_HANDLER
	if(can_use_action())
		INVOKE_ASYNC(src, .proc/action_activate)
	return COMSIG_KB_ACTIVATED

///Signal Handler for alternate actions
/datum/action/proc/alternate_action_activate()
	SIGNAL_HANDLER
	return

/datum/action/proc/fail_activate()
	return

/datum/action/proc/add_selected_frame()
	button.add_overlay(visual_references[VREF_MUTABLE_SELECTED_FRAME])

/datum/action/proc/remove_selected_frame()
	button.cut_overlay(visual_references[VREF_MUTABLE_SELECTED_FRAME])

/datum/action/proc/can_use_action()
	if(!QDELETED(owner))
		return TRUE

/datum/action/proc/give_action(mob/M)
	if(owner)
		if(owner == M)
			return
		remove_action(owner)
	owner = M
	owner.actions += src
	if(owner.client)
		owner.client.screen += button
	owner.update_action_buttons()
	owner.actions_by_path[type] = src
	if(keybind_signal)
		RegisterSignal(owner, keybind_signal, .proc/keybind_activation)
		var/datum/keybinding/our_kb = GLOB.keybindings_by_signal[keybind_signal]
		if(M.client && our_kb)
			update_map_text(our_kb.get_keys_formatted(M.client))

	if(alternate_keybind_signal)
		RegisterSignal(owner, alternate_keybind_signal, .proc/alternate_action_activate)
	SEND_SIGNAL(M, ACTION_GIVEN)

/datum/action/proc/remove_action(mob/M)
	if(keybind_signal)
		UnregisterSignal(M, keybind_signal)
	if(M.client)
		M.client.screen -= button
	M.actions_by_path[type] = null
	M.actions -= src
	M.update_action_buttons()
	owner = null
	SEND_SIGNAL(M, ACTION_REMOVED)

//Should a AI element occasionally see if this ability should be used?
/datum/action/proc/ai_should_start_consider()
	return FALSE

//When called, see if based on the surroundings should the AI use this ability
/datum/action/proc/ai_should_use(target)
	return FALSE

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_version == HUD_STYLE_NOHUD)
		return

	var/button_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/A in actions)
			A.button.screen_loc = null
			if(reload_screen)
				client.screen += A.button
	else
		for(var/datum/action/A in actions)
			if(A.should_show())
				A.update_button_icon()
				button_number++
				var/obj/screen/action_button/B = A.button
				B.screen_loc = B.get_button_screen_loc(button_number)
				if(reload_screen)
					client.screen += B
			else
				A.button.screen_loc = null
				if(reload_screen)
					client.screen += A.button

		if(!button_number)
			hud_used.hide_actions_toggle.screen_loc = null
			if(reload_screen)
				client.screen += hud_used.hide_actions_toggle
			return

	hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.get_button_screen_loc(button_number+1)

	if(reload_screen)
		client.screen += hud_used.hide_actions_toggle
