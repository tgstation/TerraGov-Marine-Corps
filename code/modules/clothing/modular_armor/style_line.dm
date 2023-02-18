// ***************************************
// *********** Modular Style Line
// ***************************************
/obj/item/clothing/suit/modular/style
	name = "\improper Drip"
	desc = "They got that drip, doe."
	flags_item_map_variant = NONE
	allowed_uniform_type = /obj/item/clothing/under
	icon = 'icons/obj/clothing/cm_suits.dmi'
	attachments_allowed = list(
// Armor Modules
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/module/mimir_environment_protection,
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/module/hlin_explosive_armor,
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/module/chemsystem,
		/obj/item/armor_module/module/eshield,
// Storage Modules
		/obj/item/armor_module/storage/general,
		/obj/item/armor_module/storage/ammo_mag,
		/obj/item/armor_module/storage/engineering,
		/obj/item/armor_module/storage/medical,
		/obj/item/armor_module/storage/medical/basic,
		/obj/item/armor_module/storage/injector,
		/obj/item/armor_module/storage/grenade,
		/obj/item/armor_module/storage/integrated,
		/obj/item/armor_module/greyscale/badge,
// Equalizer Modules
		/obj/item/armor_module/module/style/light_armor,
		/obj/item/armor_module/module/style/medium_armor,
		/obj/item/armor_module/module/style/heavy_armor,
	)

	var/codex_info = {"<BR>This item is part of the <b>Style Line.</b><BR>
	<BR>The <b>Style Line</b> is a line of equipment designed to provide as much style as possible without compromising the user's protection.
	This line of equipment accepts <b>Equalizer modules</b>, which allow the user to alter any given piece of equipment's protection according to their preferences.<BR>"}

/obj/item/clothing/suit/modular/style/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/clothing/suit/modular/style/leather_jacket
	name = "\improper leather jacket"
	desc = "A fashionable jacket. Get them with style."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "leather_jacket"
	item_state = "leather_jacket"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state_variants = list(
		"normal",
		"webbing",
	)
	current_variant = "normal"

/obj/item/clothing/suit/modular/style/duster
	name = "\improper duster"
	desc = "A light, loose-fitting colorable long coat, for those that want to have more style."
	icon_state = "duster"
	item_state = "duster"
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/suit_1.dmi',
	)
	icon_state_variants = list(
		"drab",
		"snow",
		"black",
		"desert",
		"red",
		"blue",
		"purple",
		"gold",
	)
	current_variant = "black"

// ***************************************
//  Modular hats
/obj/item/clothing/head/modular/style
	name = "\improper Nice Hat"
	desc = "Nice hat bro. How did you find this?"
	flags_item_map_variant = NONE
	icon = 'icons/mob/modular/style_hats.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/style_hats.dmi',
	)
	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
	)

	flags_inv_hide = NONE

	soft_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 10, BIO = 5, FIRE = 5, ACID = 5)


//marine hats
/obj/item/clothing/head/modular/style/beret
	name = "TGMC Beret"
	desc = "A hat used by the TGMC, typically considered the most iconic military headgear. Typically reserved for higher ranking officers, they occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon_state = "tgmc_beret_icon"
	item_state = "tgmc_beret"

	icon_state_variants = list(
		"drab",
		"snow",
		"black",
		"desert",
		"red",
		"blue",
		"purple",
		"gold",
	)

	current_variant = "black"
