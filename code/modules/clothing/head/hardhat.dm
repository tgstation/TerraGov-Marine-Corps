/obj/item/clothing/head/hardhat
	name = "hard hat"
	desc = "A piece of headgear used in dangerous working conditions to protect the head. Comes with a built-in flashlight."
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	var/hardhat_color = "yellow" //Determines used sprites: hardhat[on]_[hardhat_color]
	armor = list(melee = 30, bullet = 5, laser = 20,energy = 10, bomb = 20, bio = 10, rad = 20)
	actions_types = list(/datum/action/item_action/toggle)
	siemens_coefficient = 0.9
	flags_inventory = BLOCKSHARPOBJ

	attack_self(mob/user)
		if(!isturf(user.loc))
			to_chat(user, "You cannot turn the light on while in [user.loc]")
			return
		on = !on
		icon_state = "hardhat[on]_[hardhat_color]"
		item_state = "hardhat[on]_[hardhat_color]"

		if(on)	user.SetLuminosity(brightness_on)
		else	user.SetLuminosity(-brightness_on)

		if(ismob(loc))
			var/mob/M = loc
			M.update_inv_head()

		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

	pickup(mob/user)
		if(on)
			user.SetLuminosity(brightness_on)
//			user.UpdateLuminosity()	//TODO: Carn
			SetLuminosity(0)
		..()

	dropped(mob/user)
		if(on)
			user.SetLuminosity(-brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(brightness_on)
		..()

	Dispose()
		if(ismob(src.loc))
			src.loc.SetLuminosity(-brightness_on)
		else
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
	max_heat_protection_temperature = FIRE_HELMET_max_heat_protection_temperature

/obj/item/clothing/head/hardhat/white
	icon_state = "hardhat0_white"
	hardhat_color = "white"
	flags_inventory = NOPRESSUREDMAGE|BLOCKSHARPOBJ
	flags_heat_protection = HEAD
	max_heat_protection_temperature = FIRE_HELMET_max_heat_protection_temperature

/obj/item/clothing/head/hardhat/dblue
	icon_state = "hardhat0_dblue"
	hardhat_color = "dblue"

