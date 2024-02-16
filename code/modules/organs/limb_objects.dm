
/obj/item/limb
	icon = 'icons/mob/human_races/r_human.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/bodyparts_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/bodyparts_right.dmi',
	)

/obj/item/limb/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	//Forming icon for the limb

	//Setting base icon for this mob's race
	var/icon/base
	if(H.species && H.species.icobase)
		base = icon(H.species.icobase)
	else
		base = icon('icons/mob/human_races/r_human.dmi')


	icon = base
	var/datum/ethnicity/E = GLOB.ethnicities_list[H.ethnicity]

	var/e_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	icon_state = "[get_limb_icon_name(H.species, H.gender, name, e_icon)]"
	setDir(SOUTH)
	transform = turn(transform, rand(70,130))



/obj/item/limb/l_arm
	name = "left arm"
	icon_state = "l_arm"

/obj/item/limb/l_foot
	name = "left foot"
	icon_state = "l_foot"

/obj/item/limb/l_hand
	name = "left hand"
	icon_state = "l_hand"

/obj/item/limb/l_leg
	name = "left leg"
	icon_state = "l_leg"

/obj/item/limb/r_arm
	name = "right arm"
	icon_state = "r_arm"

/obj/item/limb/r_foot
	name = "right foot"
	icon_state = "r_foot"

/obj/item/limb/r_hand
	name = "right hand"
	icon_state = "r_hand"

/obj/item/limb/r_leg
	name = "right leg"
	icon_state = "r_leg"

/obj/item/limb/head
	name = "head"
	icon_state = "head_m"
	resistance_flags = UNACIDABLE
	var/mob/living/brain/brainmob
	var/brain_item_type = /obj/item/organ/brain
	var/braindeath_on_decap = 1 //whether the brainmob dies when head is decapitated (used by synthetics)

/obj/item/limb/head/Initialize(mapload, mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return

	if(H.species.species_flags & HAS_NO_HAIR)
		return
	//Add (facial) hair.
	if(H.f_style)
		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[H.f_style]
		if(facial_hair_style)
			var/icon/facial = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)

			overlays.Add(facial) // icon.Blend(facial, ICON_OVERLAY)

	if(H.h_style && !(H.head && (H.head.flags_inv_hide & HIDETOPHAIR)))
		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_list[H.h_style]
		if(hair_style)
			var/icon/hair = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)

			overlays.Add(hair) //icon.Blend(hair, ICON_OVERLAY)

	transfer_identity(H)

	name = "[H.real_name]'s head"

	H.regenerate_icons()

	if(braindeath_on_decap)
		brainmob.death()

	GLOB.head_list += src

/obj/item/limb/head/Destroy()
	GLOB.head_list -= src
	return ..()

/obj/item/limb/head/proc/transfer_identity(mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.faction = H.faction
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src
	brainmob.copy_known_languages_from(H, TRUE)
	brainmob.job = H.job

//synthetic head, allowing brain mob inside to talk
/obj/item/limb/head/synth
	brain_item_type = null
	braindeath_on_decap = 0

/obj/item/limb/head/robotic
	brain_item_type = null
	braindeath_on_decap = 0
