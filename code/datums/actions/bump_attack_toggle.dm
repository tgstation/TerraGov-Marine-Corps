// Toggle Bumpattacks
/datum/action/bump_attack_toggle
	name = "Toggle Bump Attacks"
	var/static/atom/movable/vis_obj/action/bump_attack_active
	var/static/atom/movable/vis_obj/action/bump_attack_inactive

/datum/action/bump_attack_toggle/New()
    . = ..()
    button.overlays.Cut()

/datum/action/bump_attack_toggle/update_button_icon(active)
    if(isnull(active)
        return 
    if(active)
		button.vis_contents -= bump_attack_inactive
		button.vis_contents += bump_attack_active
	else
		button.vis_contents -= bump_attack_active
		button.vis_contents += bump_attack_inactive
