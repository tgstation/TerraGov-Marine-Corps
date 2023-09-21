/obj/item/clothing/glasses/night/imager_goggles
	name = "optical imager goggles"
	desc = "Uses image scanning to increase visibility of even the most dimly lit surroundings except total darkness"
	icon_state = "securityhud"
	deactive_state = "degoggles_sec"
	darkness_view = 2
	toggleable = TRUE
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/night/imager_goggles/sunglasses
	name = "\improper Optical imager sunglasses"
	desc = "A pair of designer sunglasses. This pair has been fitted with an internal optical imager scanner."
	icon_state = "optsunglasses"
	item_state = "optsunglasses"
	deactive_state = "degoggles_optsunglasses"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list("Combat Robot" = 'icons/mob/species/robot/glasses.dmi')
	prescription = TRUE

/obj/item/clothing/glasses/night/imager_goggles/eyepatch
	name = "\improper Meson eyepatch"
	desc = "An eyepatch fitted with the optical imager interface. For the disabled and/or edgy Marine."
	icon_state = "optpatch"
	deactive_state = "degoggles_medpatch"
	toggleable = TRUE
