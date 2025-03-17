
//meson goggles

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used to shield the user's eyes from harmful electromagnetic emissions, also used as general safety goggles. Not adequate as welding protection."
	icon_state = "meson"
	worn_icon_state = "meson"
	deactive_state = "degoggles_meson"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/glasses.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/glasses_bravada.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/glasses_charlit.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/glasses_alpharii.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/glasses_deltad.dmi')
	actions_types = list(/datum/action/item_action/toggle)
	toggleable = 1
	vision_flags = SEE_TURFS // todo replace with tgs TRAIT_MESON_VISION


/obj/item/clothing/glasses/meson/prescription
	name = "prescription optical meson scanner"
	desc = "Used for shield the user's eyes from harmful electromagnetic emissions, can also be used as safety googles. Contains prescription lenses."
	prescription = 1

/obj/item/clothing/glasses/meson/enggoggles
	name = "\improper Optical meson ballistic goggles"
	desc = "Standard issue TGMC goggles. This pair has been fitted with an internal optical meson scanner."
	icon_state = "enggoggles"
	worn_icon_state = "enggoggles"
	deactive_state = "degoggles_enggoggles"
	equip_slot_flags = ITEM_SLOT_EYES
	goggles = TRUE

/obj/item/clothing/glasses/meson/enggoggles/prescription
	name = "\improper Optical meson prescription ballistic goggles"
	desc = "Standard issue TGMC prescription goggles. This pair has been fitted with an internal optical meson scanner."
	prescription = TRUE

/obj/item/clothing/glasses/meson/eyepatch
	name = "\improper Meson eyepatch"
	desc = "An eyepatch fitted with the meson scanner interface. For the disabled and/or edgy Engineer."
	icon_state = "patchmeson"
	deactive_state = "degoggles_medpatch"
	species_exception = list(/datum/species/robot)
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/glasses.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/glasses_bravada.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/glasses_charlit.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/glasses_alpharii.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/glasses_deltad.dmi')
	toggleable = TRUE
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/meson/sunglasses
	name = "\improper Meson sunglasses"
	desc = "A pair of designer sunglasses. This pair has been fitted with an optical meson scanner."
	icon_state = "mesonsunglasses"
	worn_icon_state = "mesonsunglasses"
	deactive_state = "degoggles_mesonsunglasses"
	prescription = TRUE
