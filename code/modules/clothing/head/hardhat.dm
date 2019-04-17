/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	var/hardhat_color = "yellow" //Determines used sprites: hardhat[on]_[hardhat_color]
	armor = list("melee" = 30, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 20, "bio" = 10, "rad" = 20, "fire" = 10, "acid" = 10)
	actions_types = list(/datum/action/item_action/toggle)
	siemens_coefficient = 0.9
	flags_inventory = BLOCKSHARPOBJ

/obj/item/clothing/head/hardhat/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "You cannot turn the light on while in [user.loc]")
		return
	on = !on
	icon_state = "hardhat[on]_[hardhat_color]"
	item_state = "hardhat[on]_[hardhat_color]"

	if(user == loc)
		var/mob/M = loc
		M.update_inv_head()

	update_brightness(user)
	update_action_button_icons()

/obj/item/clothing/head/hardhat/proc/turn_off_light(mob/bearer)
	if(on)
		on = FALSE
		update_brightness(bearer)
		update_action_button_icons()
		return TRUE
	return FALSE

/obj/item/clothing/head/hardhat/proc/update_brightness(var/mob/user = null)
	if(on)
		if(loc && loc == user)
			user.SetLuminosity(brightness_on)
		else if(isturf(loc))
			SetLuminosity(brightness_on)
	else
		icon_state = initial(icon_state)
		if(loc && loc == user)
			user.SetLuminosity(-brightness_on)
		else if(isturf(loc))
			SetLuminosity(0)

/obj/item/clothing/head/hardhat/pickup(mob/user)
	if(on && loc != user)
		user.SetLuminosity(brightness_on)
		SetLuminosity(0)
	return ..()

/obj/item/clothing/head/hardhat/dropped(mob/user)
	if(on && loc != user)
		user.SetLuminosity(-brightness_on)
		SetLuminosity(brightness_on)
	return ..()

/obj/item/clothing/head/hardhat/Destroy()
	if(ismob(loc))
		loc.SetLuminosity(-brightness_on)
	SetLuminosity(0)
	. = ..()


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

