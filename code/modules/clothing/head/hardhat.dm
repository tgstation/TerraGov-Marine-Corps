/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"
	soft_armor = list("melee" = 30, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 10, "rad" = 20, "fire" = 10, "acid" = 10)
	actions_types = list(/datum/action/item_action/toggle)
	siemens_coefficient = 0.9
	flags_inventory = BLOCKSHARPOBJ
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 2
	var/hardhat_color = "yellow" //Determines used sprites: hardhat[on]_[hardhat_color]

/obj/item/clothing/head/hardhat/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in [user.loc]")
		return
	turn_light(user, !light_on)

/obj/item/clothing/head/hardhat/turn_light(mob/user, toggle_on)
	. = ..()
	if(. != CHECKS_PASSED)
		return
	set_light_on(toggle_on)
	if(user == loc)
		var/mob/M = loc
		M.update_inv_head()

	update_action_button_icons()
	update_icon()

/obj/item/clothing/head/hardhat/update_icon()
	. = ..()
	icon_state = "hardhat[light_on]_[hardhat_color]"
	item_state = "hardhat[light_on]_[hardhat_color]"

/obj/item/clothing/head/hardhat/orange
	icon_state = "hardhat0_orange"
	hardhat_color = "orange"

/obj/item/clothing/head/hardhat/red
	icon_state = "hardhat0_red"
	hardhat_color = "red"
	name = "firefighter helmet"
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	hardhat_color = "white"
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	hardhat_color = "dblue"

/obj/item/clothing/head/hardhat/rugged
	name = "rugged hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight. Looks rather robust."
	soft_armor = list("melee" = 50, "bullet" = 40, "laser" = 40, "energy" = 40, "bomb" = 50, "bio" = 40, "rad" = 0, "fire" = 50, "acid" = 50)
