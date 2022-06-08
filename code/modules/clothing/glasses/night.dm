
// nightvision goggles

/obj/item/clothing/glasses/night
	name = "night vision goggles"
	desc = "You can totally see in the dark now!"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
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
	flags_item = NODROP|DELONDROP

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

/obj/item/clothing/glasses/night/imager_goggles
	name = "optical imager goggles"
	desc = "Uses image scanning to increase visibility of even the most dimly lit surroundings except total darkness"
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	darkness_view = 2
	toggleable = TRUE
	actions_types = list(/datum/action/item_action/toggle)
