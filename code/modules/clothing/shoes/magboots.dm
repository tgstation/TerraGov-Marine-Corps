/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	species_restricted = null
	var/magpulse = 0
	actions_types = list(/datum/action/item_action/toggle)
//	flags = NOSLIP //disabled by default

	attack_self(mob/user)
		if(magpulse)
			flags_inventory &= ~NOSLIPPING
			slowdown = SHOES_SLOWDOWN
			magpulse = 0
			icon_state = "magboots0"
			to_chat(user, "You disable the mag-pulse traction system.")
		else
			flags_inventory |= NOSLIPPING
			slowdown = 2
			magpulse = 1
			icon_state = "magboots1"
			to_chat(user, "You enable the mag-pulse traction system.")
		user.update_inv_shoes()	//so our mob-overlays update

		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()


	examine(mob/user)
		..()
		var/state = "disabled"
		if(flags_inventory&NOSLIPPING)
			state = "enabled"
		to_chat(user, "Its mag-pulse traction system appears to be [state].")