/datum/action
	var/name = "Generic Action"
	var/desc
	var/obj/target = null
	var/obj/screen/action_button/button = null
	var/mob/owner

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
	button.source_action = src
	button.name = name
	if(desc)
		button.desc = desc

/datum/action/Destroy()
	if(owner)
		remove_action(owner)
	qdel(button)
	button = null
	target = null

/datum/action/proc/should_show()
	return TRUE

/datum/action/proc/update_button_icon()
	return

/datum/action/proc/action_activate()
	return

/datum/action/proc/fail_activate()
	return

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

/datum/action/proc/remove_action(mob/M)
	if(M.client)
		M.client.screen -= button
	M.actions_by_path[type] = null
	M.actions -= src
	M.update_action_buttons()
	owner = null


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

