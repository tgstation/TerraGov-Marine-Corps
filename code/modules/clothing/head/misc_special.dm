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
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	flags_atom = CONDUCT
	flags_inventory = COVEREYES|COVERMOUTH|BLOCKSHARPOBJ
	flags_inv_hide = HIDEEARS|HIDEEYES|HIDEFACE
	flags_armor_protection = HEAD|FACE|EYES
	actions_types = list(/datum/action/item_action/toggle)
	siemens_coefficient = 0.9
	w_class = 3
	anti_hug = 2
	eye_protection = 2
	tint = TINT_HEAVY
	var/hug_memory = 0 //Variable to hold the "memory" of how many anti-hugs remain.  Because people were abusing the fuck out of it.

/obj/item/clothing/head/welding/attack_self(mob/user)
	toggle(user)


/obj/item/clothing/head/welding/verb/verbtoggle()
	set category = "Object"
	set name = "Adjust welding mask"
	set src in usr

	if(!usr.incapacitated())
		toggle(usr)

/obj/item/clothing/head/welding/proc/toggle(mob/user)
	up = !up
	icon_state = "[initial(icon_state)][up ? "up" : ""]"
	if(up)
		DISABLE_BITFIELD(flags_inventory, COVEREYES|COVERMOUTH|BLOCKSHARPOBJ)
		DISABLE_BITFIELD(flags_inv_hide, HIDEEARS|HIDEEYES|HIDEFACE)
		eye_protection = 0
		tint = TINT_NONE
		hug_memory = anti_hug
		anti_hug = 0
	else
		ENABLE_BITFIELD(flags_inventory, COVEREYES|COVERMOUTH|BLOCKSHARPOBJ)
		ENABLE_BITFIELD(flags_inv_hide, HIDEEARS|HIDEEYES|HIDEFACE)
		eye_protection = initial(eye_protection)
		tint = initial(tint)
		anti_hug = hug_memory
	if(user)
		to_chat(usr, "You [up ? "push [src] up out of your face" : "flip [src] down to protect your eyes"].")


	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(H.head == src)
			H.update_tint()

	update_clothing_icon()	//so our mob-overlays update

	update_action_button_icons()

/obj/item/clothing/head/welding/flipped //spawn in flipped up.

/obj/item/clothing/head/welding/flipped/Initialize(mapload)
	. = ..()
	toggle()

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
		STOP_PROCESSING(SSobj, src)
		return

/obj/item/clothing/head/cakehat/attack_self(mob/user as mob)
	if(status > 1)	return
	src.onfire = !( src.onfire )
	if (src.onfire)
		src.force = 3
		src.damtype = "fire"
		src.icon_state = "cake1"
		START_PROCESSING(SSobj, src)
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
	w_class = 3
	anti_hug = 1


/*
* Kitty ears
*/
/obj/item/clothing/head/kitty
	name = "kitty ears"
	desc = "A pair of kitty ears. Meow!"
	icon_state = "kitty"
	flags_armor_protection = 0
	siemens_coefficient = 1.5
	var/icon/ears = new /icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kitty")
	var/icon/earbit = new /icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kittyinner")

/obj/item/clothing/head/kitty/update_icon(mob/living/carbon/human/user, remove = FALSE)
	if(!istype(user))
		return

	ears = new /icon("icon" = 'icons/mob/head_0.dmi', "icon_state" = "kitty")
	ears.Blend(rgb(user.r_hair, user.g_hair, user.b_hair), ICON_ADD)
	ears.Blend(earbit, ICON_OVERLAY)

	if(user.head && istype(user.head, /obj/item/clothing/head/kitty) && !remove)
		user.overlays.Add(ears)
	else
		user.overlays.Remove(ears)

/obj/item/clothing/head/kitty/dropped(mob/living/carbon/human/user)
	update_icon(user, remove = TRUE)

/obj/item/clothing/head/kitty/equipped(mob/living/carbon/human/user)
	if(user.head && istype(user.head, /obj/item/clothing/head/kitty))
		update_icon(user)