/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magpulse = 0
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		inventory_flags &= ~NOSLIPPING
		slowdown = SHOES_SLOWDOWN
		magpulse = 0
		icon_state = "magboots0"
		to_chat(user, "You disable the mag-pulse traction system.")
	else
		inventory_flags |= NOSLIPPING
		slowdown = 2
		magpulse = 1
		icon_state = "magboots1"
		to_chat(user, "You enable the mag-pulse traction system.")
	user.update_inv_shoes()	//so our mob-overlays update

	update_action_button_icons()


/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	var/state = "disabled"
	if(inventory_flags&NOSLIPPING)
		state = "enabled"
	. += "Its mag-pulse traction system appears to be [state]."
