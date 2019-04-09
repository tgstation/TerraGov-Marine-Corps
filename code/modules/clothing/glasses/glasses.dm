
/obj/item/clothing/glasses
	name = "glasses"
	icon = 'icons/obj/clothing/glasses.dmi'
	w_class = 2.0
	var/vision_flags = 0
	var/darkness_view = 0//Base human is 2
	var/see_invisible = 0
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/eyes.dmi')
	var/prescription = 0
	var/toggleable = 0
	var/active = 1
	flags_inventory = COVEREYES
	flags_equip_slot = ITEM_SLOT_EYES
	flags_armor_protection = EYES
	var/deactive_state = "degoggles"
	var/fullscreen_vision


/obj/item/clothing/glasses/update_clothing_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_glasses()


/obj/item/clothing/glasses/attack_self(mob/user)
	if(toggleable)
		if(active)
			active = 0
			icon_state = deactive_state
			user.update_inv_glasses()
			to_chat(user, "You deactivate the optical matrix on [src].")
		else
			active = 1
			icon_state = initial(icon_state)
			user.update_inv_glasses()
			to_chat(user, "You activate the optical matrix on [src].")

		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.glasses == src)
				H.update_tint()
				H.update_sight()

		update_action_button_icons()



/obj/item/clothing/glasses/science
	name = "science goggles"
	desc = "The goggles do nothing! Can be used as safety googles."
	icon_state = "purple"
	item_state = "glasses"

/obj/item/clothing/glasses/eyepatch
	name = "eyepatch"
	desc = "Yarr."
	icon_state = "eyepatch"
	item_state = "eyepatch"
	flags_armor_protection = 0

/obj/item/clothing/glasses/monocle
	name = "monocle"
	desc = "Such a dapper eyepiece!"
	icon_state = "monocle"
	item_state = "headset" // lol
	flags_armor_protection = 0

/obj/item/clothing/glasses/material
	name = "optical material scanner"
	desc = "Very confusing glasses."
	icon_state = "material"
	item_state = "glasses"
	actions_types = list(/datum/action/item_action/toggle)
	origin_tech = "magnets=3;engineering=3"
	toggleable = 1
	vision_flags = SEE_OBJS

/obj/item/clothing/glasses/regular
	name = "marine RPG glasses"
	desc = "The Corps may call them Regulation Prescription Glasses but you know them as Rut Prevention Glasses."
	icon_state = "mBCG"
	item_state = "mBCG"
	prescription = 1

/obj/item/clothing/glasses/regular/hipster
	name = "prescription glasses"
	desc = "Made by Uncool. Co."
	icon_state = "hipster_glasses"
	item_state = "hipster_glasses"

/obj/item/clothing/glasses/threedglasses
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	item_state = "3d"
	flags_armor_protection = 0

/obj/item/clothing/glasses/gglasses
	name = "green glasses"
	desc = "Forest green glasses, like the kind you'd wear when hatching a nasty scheme."
	icon_state = "gglasses"
	item_state = "gglasses"
	flags_armor_protection = 0

/obj/item/clothing/glasses/mgoggles
	name = "marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	icon_state = "mgoggles"
	item_state = "mgoggles"
	flags_equip_slot = ITEM_SLOT_EYES|ITEM_SLOT_MASK

/obj/item/clothing/glasses/mgoggles/prescription
	name = "prescription marine ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet. Contains prescription lenses in case you weren't sure if they were lame or not."
	icon_state = "mgoggles"
	item_state = "mgoggles"
	prescription = 1

/obj/item/clothing/glasses/m42_goggles
	name = "\improper M42 scout sight"
	desc = "A headset and goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	vision_flags = SEE_TURFS
	toggleable = 1
	actions_types = list(/datum/action/item_action/toggle)



//welding goggles

/obj/item/clothing/glasses/welding
	name = "welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	icon_state = "welding-g"
	item_state = "welding-g"
	actions_types = list(/datum/action/item_action/toggle)
	flags_inventory = COVEREYES
	flags_inv_hide = HIDEEYES
	eye_protection = 2
	tint = TINT_HEAVY

/obj/item/clothing/glasses/welding/attack_self()
	toggle()


/obj/item/clothing/glasses/welding/verb/toggle()
	set category = "Object"
	set name = "Adjust welding goggles"
	set src in usr

	if(usr.canmove && !usr.stat && !usr.restrained())
		if(active)
			active = 0
			flags_inventory &= ~COVEREYES
			flags_inv_hide &= ~HIDEEYES
			flags_armor_protection &= ~EYES
			icon_state = "[initial(icon_state)]up"
			eye_protection = 0
			tint = TINT_NONE
			to_chat(usr, "You push [src] up out of your face.")
		else
			active = 1
			flags_inventory |= COVEREYES
			flags_inv_hide |= HIDEEYES
			flags_armor_protection |= EYES
			icon_state = initial(icon_state)
			eye_protection = initial(eye_protection)
			tint = initial(tint)
			to_chat(usr, "You flip [src] down to protect your eyes.")


		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.glasses == src)
				H.update_tint()

		update_clothing_icon()

		update_action_button_icons()


/obj/item/clothing/glasses/welding/superior
	name = "superior welding goggles"
	desc = "Welding goggles made from more expensive materials, strangely smells like potatoes."
	icon_state = "rwelding-g"
	item_state = "rwelding-g"
	tint = TINT_MILD



//sunglasses

/obj/item/clothing/glasses/sunglasses
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	name = "sunglasses"
	icon_state = "sun"
	item_state = "sunglasses"
	tint = TINT_MILD
	eye_protection = 1

/obj/item/clothing/glasses/sunglasses/blindfold
	name = "blindfold"
	desc = "Covers the eyes, preventing sight."
	icon_state = "blindfold"
	item_state = "blindfold"
	tint = TINT_BLIND
	eye_protection = 2

/obj/item/clothing/glasses/sunglasses/prescription
	name = "prescription sunglasses"
	prescription = 1

/obj/item/clothing/glasses/sunglasses/big
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Larger than average enhanced shielding blocks many flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/big/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake
	desc = "A pair of designer sunglasses. Doesn't seem like it'll block flashes."
	tint = TINT_NONE
	eye_protection = 0

/obj/item/clothing/glasses/sunglasses/fake/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/fake/big
	desc = "A pair of larger than average designer sunglasses. Doesn't seem like it'll block flashes."
	icon_state = "bigsunglasses"
	item_state = "bigsunglasses"

/obj/item/clothing/glasses/sunglasses/fake/big/prescription
	name = "prescription sunglasses"
	prescription = TRUE

/obj/item/clothing/glasses/sunglasses/sa
	name = "spatial agent's sunglasses"
	desc = "Glasses worn by a spatial agent."
	eye_protection = 2
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	var/hud_type = MOB_HUD_MEDICAL_OBSERVER|MOB_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/sunglasses/sa/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLASSES)
		user.see_invisible = SEE_INVISIBLE_MINIMUM
		user.see_in_dark = 8

/obj/item/clothing/glasses/sunglasses/sa/dropped(mob/living/carbon/human/user)
	user.see_invisible = initial(user.see_invisible)
	user.see_in_dark = initial(user.see_in_dark)

/obj/item/clothing/glasses/sunglasses/sechud
	name = "HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	var/hud_type = MOB_HUD_SECURITY_ADVANCED

/obj/item/clothing/glasses/sunglasses/sechud/eyepiece
	name = "Security HUD Sight"
	desc = "A standard eyepiece, but modified to display security information to the user visually. This makes it commonplace among military police, though other models exist."
	icon_state = "securityhud"
	item_state = "securityhud"


/obj/item/clothing/glasses/sunglasses/sechud/equipped(mob/living/carbon/human/user, slot)
	if(slot == SLOT_GLASSES)
		var/datum/mob_hud/H = huds[hud_type]
		H.add_hud_to(user)
	..()

/obj/item/clothing/glasses/sunglasses/sechud/dropped(mob/living/carbon/human/user)
	if(istype(user))
		if(src == user.glasses) //dropped is called before the inventory reference is updated.
			var/datum/mob_hud/H = huds[hud_type]
			H.remove_hud_from(user)
	..()


/obj/item/clothing/glasses/sunglasses/sechud/tactical
	name = "tactical HUD"
	desc = "Flash-resistant goggles with inbuilt combat and security information."
	icon_state = "swatgoggles"


