/datum/action
	var/name = "Generic Action"
	var/desc
	var/obj/target = null
	var/obj/screen/action_button/button = null
	var/mob/owner
	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "default"
	var/background_icon = 'icons/mob/actions.dmi'
	var/background_icon_state = "template"
	var/static/atom/movable/vis_obj/action/selected_frame/selected_frame = new

/datum/action/New(Target)
	target = Target
	button = new
	if(target)
		var/image/IMG
		if(ispath(target))
			IMG = image(initial(target.icon), button, initial(target.icon_state))
		else
			IMG = image(target.icon, button, target.icon_state)
		IMG.pixel_x = 0
		IMG.pixel_y = 0
		button.overlays += IMG
	button.icon = icon(background_icon, background_icon_state)
	button.source_action = src
	button.name = name
	if(desc)
		button.desc = desc

/datum/action/Destroy()
	if(owner)
		remove_action(owner)
	QDEL_NULL(button)
	target = null
	return ..()

/datum/action/proc/should_show()
	return TRUE

/datum/action/proc/update_button_icon()
	if(!button)
		return

	button.name = name
	button.desc = desc

	if(action_icon && action_icon_state)
		button.cut_overlays(TRUE)
		button.add_overlay(mutable_appearance(action_icon, action_icon_state))

	if(background_icon_state)
		button.icon_state = background_icon_state

	if(can_use_action())
		button.color = rgb(255, 255, 255, 255)
	else
		button.color = rgb(128, 0, 0, 128)

	return TRUE

/datum/action/proc/action_activate()
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

///Signal Handler for alternate actions
/datum/action/proc/alternate_action_activate()
	SIGNAL_HANDLER
	return

/datum/action/proc/fail_activate()
	return

/datum/action/proc/add_selected_frame()
	button.vis_contents += selected_frame

/datum/action/proc/remove_selected_frame()
	button.vis_contents -= selected_frame

/datum/action/proc/can_use_action()
	if(!QDELETED(owner))
		return TRUE

/datum/action/proc/give_action(mob/M)
	if(owner)
		if(owner == M)
			return
		remove_action(owner)
	owner = M
	M.actions += src
	if(M.client)
		M.client.screen += button
	M.update_action_buttons()
	M.actions_by_path[type] = src
	SEND_SIGNAL(M, ACTION_GIVEN)

/datum/action/proc/remove_action(mob/M)
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
