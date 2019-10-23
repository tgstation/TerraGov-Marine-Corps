// Toggle Bumpattacks
/datum/action/bump_attack_toggle
	name = "Toggle Bump Attacks"
	var/static/atom/movable/vis_obj/action/bump_attack_active/active_icon = new
	var/static/atom/movable/vis_obj/action/bump_attack_inactive/inactive_icon = new
	

/datum/action/bump_attack_toggle/New()
	. = ..()
	button.overlays.Cut()

/datum/action/bump_attack_toggle/update_button_icon(active)
	if(isnull(active))
		return
	if(active)
		button.vis_contents -= inactive_icon
		button.vis_contents += active_icon
	else
		button.vis_contents -= active_icon
		button.vis_contents += inactive_icon
