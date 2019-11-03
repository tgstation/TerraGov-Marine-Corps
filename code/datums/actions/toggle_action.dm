/datum/action/toggle_action
	name = "Generic Toggle Action"


/datum/action/toggle_action/New(Target, action_name, active_state_icon)
	. = ..()
	name = action_name
	button.overlays.Cut()
	button.icon_state = active_state_icon


/datum/action/bump_attack_toggle/update_button_icon(active)
	if(isnull(active))
		return
	if(active)
		button.vis_contents += selected_frame
	else
		button.vis_contents -= selected_frame
