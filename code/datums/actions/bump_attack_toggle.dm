// Toggle Bumpattacks
/datum/action/bump_attack_toggle
	name = "Toggle Bump Attacks"

/*
/datum/action/bump_attack_toggle/New()
	. = ..()
	button.overlays.Cut()
*/

/datum/action/bump_attack_toggle/update_button_icon(active)
	action_icon_state = active ? "bumpattack_on" : "bumpattack_off"
	..()

