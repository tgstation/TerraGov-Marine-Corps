/datum/action/toggle_action
	name = "Generic Toggle Action"


/datum/action/toggle_action/New(Target, action_name, button_icon)
	. = ..()
	name = action_name
	action_icon_state = button_icon
	button.name = name


/datum/action/toggle_action/set_button_icon()
	button.icon = icon(background_icon, background_icon_state)


/datum/action/bump_attack_toggle/update_button_icon(active)
	if(isnull(active))
		return
	if(active)
		button.vis_contents += selected_frame
	else
		button.vis_contents -= selected_frame
