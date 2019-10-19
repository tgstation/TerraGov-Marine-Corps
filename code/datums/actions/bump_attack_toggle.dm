// Toggle Bumpattacks
/datum/action/bump_attack_toggle
	name = "Toggle Bump Attacks"
	var/bump_active = COMPONENT_BUMPATTACK_INACTIVE
	var/static/atom/movable/vis_obj/action/bump_attack_active
	var/static/atom/movable/vis_obj/action/bump_attack_inactive

/datum/action/bump_attack_toggle/New()
    . = ..()
    button.overlays.Cut()
    action_activate()

/datum/action/bump_attack_toggle/action_activate()
	bump_active = SendSignal(owner, the_signal)
	update_button_icon(bump_active)

/datum/action/bump_attack_toggle/update_button_icon(new_status)
    if(isnull(new_status) || new_status == bump_active)
        return 
	switch(bump_active)
    	if(COMPONENT_BUMPATTACK_INACTIVE)
			button.vis_contents -= bump_attack_inactive
			button.vis_contents += bump_attack_active
		if(COMPONENT_BUMPATTACK_ACTIVE)
			button.vis_contents -= bump_attack_active
			button.vis_contents += bump_attack_inactive
