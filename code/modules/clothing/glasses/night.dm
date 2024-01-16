
// nightvision goggles

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/glasses.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/glasses_bravada.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/glasses_charlit.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/glasses_alpharii.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/glasses_deltad.dmi')
	icon_state = "night"
	item_state = "glasses"
	darkness_view = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE


/obj/item/clothing/glasses/night/tx8
	name = "\improper BR-8 battle sight"
	desc = "A headset and night vision goggles system for the BR-8 Battle Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	vision_flags = SEE_TURFS
	darkness_view = 12
	toggleable = 1
	actions_types = list(/datum/action/item_action/toggle)


/obj/item/clothing/glasses/night/m42_night_goggles
	name = "\improper M42 scout sight"
	desc = "A headset and night vision goggles system for the M42 Scout Rifle. Allows highlighted imaging of surroundings. Click it to toggle."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	vision_flags = SEE_TURFS
	darkness_view = 24
	toggleable = 1
	actions_types = list(/datum/action/item_action/toggle)


/obj/item/clothing/glasses/night/m42_night_goggles/upp
	name = "\improper Type 9 elite goggles"
	desc = "A headset and night vision goggles system used by USL forces. Allows highlighted imaging of surroundings. Click it to toggle."
	icon_state = "upp_goggles"
	deactive_state = "upp_goggles_0"

/obj/item/clothing/glasses/night/sectoid
	name = "alien lens"
	desc = "A thick, black coating over an alien's eyes, allowing them to see in the dark."
	icon_state = "alien_lens"
	item_state = "alien_lens"
	darkness_view = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	flags_item = DELONDROP

/obj/item/clothing/glasses/night/sectoid/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SECTOID_TRAIT)

/obj/item/clothing/glasses/night/m56_goggles
	name = "\improper KTLD head mounted sight"
	desc = "A headset and goggles system made to pair with any KTLD weapon, such as the SG type weapons. Has a low-res short range imager, allowing for view of terrain."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56_goggles"
	deactive_state = "m56_goggles_0"
	darkness_view = 5
	toggleable = TRUE
	actions_types = list(/datum/action/item_action/toggle)
	vision_flags = SEE_TURFS

/obj/item/clothing/glasses/night/sunglasses
	name = "\improper KTLD sunglasses"
	desc = "A pair of designer sunglasses. This pair has been fitted with a KTLD head mounted sight."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "m56sunglasses"
	item_state = "m56sunglasses"
	deactive_state = "degoggles_mesonsunglasses"
	darkness_view = 5
	toggleable = TRUE
	actions_types = list(/datum/action/item_action/toggle)
	vision_flags = SEE_TURFS
	prescription = TRUE

/obj/item/clothing/glasses/night/optgoggles
	name = "\improper Optical imager ballistic goggles"
	desc = "Standard issue TGMC goggles. This pair has been fitted with an internal optical imaging scanner."
	icon_state = "optgoggles"
	item_state = "optgoggles"
	deactive_state = "degoggles_optgoggles"
	darkness_view = 2
	toggleable = TRUE
	actions_types = list(/datum/action/item_action/toggle)
	species_exception = list(/datum/species/robot)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/glasses.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/glasses_bravada.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/glasses_charlit.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/glasses_alpharii.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/glasses_deltad.dmi')
	flags_equip_slot = ITEM_SLOT_EYES
	goggles = TRUE

/obj/item/clothing/glasses/night/optgoggles/prescription
	name = "\improper Optical imager prescription ballistic goggles"
	desc = "Standard issue TGMC prescription goggles. This pair has been fitted with an internal optical imaging scanner."
	prescription = TRUE
