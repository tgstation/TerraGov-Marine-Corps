/datum/action/toggle_action
	name = "Generic Toggle Action"
	var/atom/movable/vis_obj/action/active_icon
	var/atom/movable/vis_obj/action/inactive_icon


/datum/action/toggle_action/New(Target, action_name, active_icon, inactive_icon)
	. = ..()
	name = action_name
	button.overlays.Cut()
	src.active_icon = active_icon
	src.inactive_icon = inactive_icon


/datum/action/bump_attack_toggle/update_button_icon(active)
	if(isnull(active))
		return
	if(active)
		button.vis_contents -= inactive_icon
		button.vis_contents += active_icon
	else
		button.vis_contents -= active_icon
		button.vis_contents += inactive_icon
