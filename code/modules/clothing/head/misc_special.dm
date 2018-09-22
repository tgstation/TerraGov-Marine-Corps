/*
 * Contents:
 *		Welding mask
 *		Cakehat
 *		Ushanka
 *		Pumpkin head
 *		Kitty ears
 *
 */

/*
 * Welding mask
 */
/obj/item/clothing/head/welding
	name = "welding helmet"
	desc = "A head-mounted face cover designed to protect the wearer completely from space-arc eye."
	icon_state = "welding"
	item_state = "welding"
	matter = list("metal" = 3000, "glass" = 1000)
	var/up = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	flags_atom = CONDUCT
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE
	flags_armor_protection = HEAD|FACE|EYES
	actions_types = list(/datum/action/item_action/toggle)
	siemens_coefficient = 0.9
	w_class = 3
	anti_hug = 2
	eye_protection = 2
	var/hug_memory = 0 //Variable to hold the "memory" of how many anti-hugs remain.  Because people were abusing the fuck out of it.

/obj/item/clothing/head/welding/attack_self()
	toggle()


/obj/item/clothing/head/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.is_mob_restrained())
		if(up)
			flags_inventory |= COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
			flags_inv_hide |= HIDEEARS|HIDEEYES|HIDEFACE
			icon_state = initial(icon_state)
			eye_protection = initial(eye_protection)
			to_chat(usr, "You flip the [src] down to protect your eyes.")
			anti_hug = hug_memory //This will reset the hugged var, but ehh. More efficient than making a new var for it.
		else
			flags_inventory &= ~(COVEREYES|COVERMOUTH|BLOCKSHARPOBJ)
			flags_inv_hide &= ~(HIDEEARS|HIDEEYES|HIDEFACE)
			icon_state = "[initial(icon_state)]up"
			eye_protection = 0
			to_chat(usr, "You push the [src] up out of your face.")
			hug_memory = anti_hug
			anti_hug = 0
		up = !up

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.head == src)
				H.update_tint()

		update_clothing_icon()	//so our mob-overlays update

		for(var/X in actions)
			var/datum/action/A = X
			A.update_button_icon()

/*
 * Cakehat
 */
/obj/item/clothing/head/cakehat
	name = "cake-hat"
	desc = "It's tasty looking!"
	icon_state = "cake0"
	flags_inventory = COVEREYES
	var/onfire = 0.0
	var/status = 0
	var/fire_resist = T0C+1300	//this is the max temp it can stand before you start to cook. although it might not burn away, you take damage
	var/processing = 0 //I dont think this is used anywhere.
	flags_armor_protection = EYES

/obj/item/clothing/head/cakehat/process()
	if(!onfire)
		processing_objects.Remove(src)
		return

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		processing_objects.Add(src)
	else
		src.force = null
		src.damtype = "brute"
		src.icon_state = "cake0"
	return


/*
 * Pumpkin head
 */
/obj/item/clothing/head/pumpkinhead
	name = "carved pumpkin"
	desc = "A jack o' lantern! Believed to ward off evil spirits."
	icon_state = "hardhat0_pumpkin"//Could stand to be renamed
	item_state = "hardhat0_pumpkin"
	flags_inventory = COVEREYES|COVERMOUTH
	flags_inv_hide = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEALLHAIR
	flags_armor_protection = HEAD|EYES
	var/brightness_on = 2 //luminosity when on
	var/on = 0
	w_class = 3
	anti_hug = 1

	attack_self(mob/user)
		if(!isturf(user.loc))
			to_chat(user, "You cannot turn the light on while in [user.loc]")
			return
		on = !on
		icon_state = "hardhat[on]_pumpkin"

		if(on)	user.SetLuminosity(brightness_on)
		else	user.SetLuminosity(-brightness_on)

	pickup(mob/user)
		..()
		if(on)
			user.SetLuminosity(brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(0)

	dropped(mob/user)
		..()
		if(on)
			user.SetLuminosity(-brightness_on)
//			user.UpdateLuminosity()
			SetLuminosity(brightness_on)

	Dispose()
		if(ismob(src.loc))
			src.loc.SetLuminosity(-brightness_on)
		else
			SetLuminosity(0)
		. = ..()
/*
 * Kitty ears
 */
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	flags_armor_protection = 0
	var/icon/mob
	var/icon/mob2
	siemens_coefficient = 1.5
/*
	update_icon(var/mob/living/carbon/human/user)
		if(!istype(user)) return
		mob = new/icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kitty")
		mob2 = new/icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kitty2")
		mob.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
		mob2.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)

		var/icon/earbit = new/icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kittyinner")
		var/icon/earbit2 = new/icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kittyinner2")
		mob.Blend(earbit, ICON_OVERLAY)
		mob2.Blend(earbit2, ICON_OVERLAY)*/