
// thermal goggles

/obj/item/clothing/glasses/thermal
	name = "Optical Thermal Scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	worn_icon_state = "glasses"
	toggleable = 1
	vision_flags = SEE_MOBS // todo replace with tgs TRAIT_THERMAL_VISION
	lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
	eye_protection = -1
	deactive_state = "goggles_off"

/obj/item/clothing/glasses/thermal/emp_act(severity)
	. = ..()
	if(ishuman(loc))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, span_warning("The Optical Thermal Scanner overloads and blinds you!"))
		if(M.glasses == src)
			M.blind_eyes(3)
			M.blur_eyes(5)
			M.disabilities |= NEARSIGHTED
			spawn(100)
				M.disabilities &= ~NEARSIGHTED

/obj/item/clothing/glasses/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	actions_types = list(/datum/action/item_action/toggle)


/obj/item/clothing/glasses/thermal/monocle
	name = "Thermoncle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	atom_flags = null //doesn't protect eyes because it's a monocle, duh
	toggleable = 0
	armor_protection_flags = NONE

/obj/item/clothing/glasses/thermal/eyepatch
	name = "Optical Thermal Eyepatch"
	desc = "An eyepatch with built-in thermal optics"
	icon_state = "eyepatch"
	worn_icon_state = "eyepatch"
	toggleable = 0
	armor_protection_flags = NONE

/obj/item/clothing/glasses/thermal/jensen
	name = "Optical Thermal Implants"
	desc = "A set of implantable lenses designed to augment your vision"
	icon_state = "thermalimplants"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/containers_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/containers_right.dmi',
	)
	worn_icon_state = "syringe_kit"
	toggleable = 0

/obj/item/clothing/glasses/thermal/m64_thermal_goggles
	name = "\improper M64 tracker sight"
	desc = "A headset and thermal vision goggles system for the tracker specialization. Allows thermal imaging of living creatures. Click it to toggle."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	actions_types = list(/datum/action/item_action/toggle)
