// ***************************************
// *********** Modular Style Line
// ***************************************
/obj/item/clothing/suit/modular/style
	name = "\improper Drip"
	desc = "They got that drip, doe."
	flags_item_map_variant = NONE
	allowed_uniform_type = /obj/item/clothing/under
	icon = 'icons/obj/clothing/suits/marine_suits.dmi'
	item_icons = list(
		slot_wear_suit_str = 'icons/mob/clothing/suits/marine_suits.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
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
		/obj/item/armor_module/storage/general/som,
		/obj/item/armor_module/storage/engineering/som,
		/obj/item/armor_module/storage/medical/som,
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
	icon_state = "leather_jacket"
	item_state = "leather_jacket"
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
	icon = 'icons/obj/clothing/headwear/style_hats.dmi'
	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	item_icons = list(
		slot_head_str = 'icons/mob/modular/style_hats_mob.dmi',
	)
	attachments_allowed = list(
		/obj/item/armor_module/greyscale/badge,
		/obj/item/armor_module/storage/helmet,
	)

	flags_inv_hide = NONE

	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 50, BIO = 50, FIRE = 50, ACID = 60)
	starting_attachments = list(/obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/style/update_item_sprites()
	switch(SSmapping.configs[GROUND_MAP].armor_style)
		if(MAP_ARMOR_STYLE_JUNGLE)
			if(flags_item_map_variant & ITEM_JUNGLE_VARIANT)
				current_variant = "drab"
		if(MAP_ARMOR_STYLE_ICE)
			if(flags_item_map_variant & ITEM_ICE_VARIANT)
				current_variant = "snow"
		if(MAP_ARMOR_STYLE_PRISON)
			if(flags_item_map_variant & ITEM_PRISON_VARIANT)
				current_variant = "black"
		if(MAP_ARMOR_STYLE_DESERT)
			if(flags_item_map_variant & ITEM_DESERT_VARIANT)
				current_variant = "desert"


//marine hats
/obj/item/clothing/head/modular/style/beret
	name = "TGMC beret"
	desc = "A hat used by the TGMC, typically considered the most iconic military headgear. Often reserved for higher ranking officers, they occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts."
	icon_state = "tgmc_beret"

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

/obj/item/clothing/head/modular/style/classic_beret
	name = "TGMC beret (classic)"
	desc = "A hat used by the TGMC, typically considered the most iconic military headgear. Often reserved for higher ranking officers, they occasionally they find their way down the ranks into the hands of squad-leaders and decorated grunts. This one is in a classic style."
	icon_state = "classic_beret"

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

/obj/item/clothing/head/modular/style/boonie
	name = "TGMC boonie"
	desc = "A boonie hat used by the TGMC, purpose made for operations in enviroments with a lot of sun, or dense vegetation."
	icon_state = "boonie"

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

/obj/item/clothing/head/modular/style/cap
	name = "TGMC cap"
	desc = "A common patrol cap used by the TGMC, stylish and comes in many colors. Mostly useful to keep the sun and officers away."
	icon_state = "tgmccap"

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

/obj/item/clothing/head/modular/style/slouchhat
	name = "TGMC slouch hat"
	desc = "A slouch hat, makes you feel down under, doesn't it? Has 'PROPERTY OF THE TGMC' markings under the hat."
	icon_state = "slouchhat"

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

/obj/item/clothing/head/modular/style/ushanka
	name = "TGMC ushanka"
	desc = "A comfortable ushanka used by the TGMC. Will keep you warm in even the most harshest artic enviroments."
	icon_state = "tgmcushanka"

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

/obj/item/clothing/head/modular/style/campaignhat
	name = "TGMC campaign hat"
	desc = "A campaign hat, you can feel the menacing aura that this hat erodes just by looking at it."
	icon_state = "campaignhat"

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

/obj/item/clothing/head/modular/style/beanie
	name = "TGMC beanie"
	desc = "A beanie, just looking at it makes you feel like an 'Oussama', or in better terms- A modern phenomenon of people suddenly needing to bench once they put on a beanie."
	icon_state = "beanie"

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

/obj/item/clothing/head/modular/style/headband
	name = "TGMC headband"
	desc = "A headband. Will keep the sweat off your eyes and also keep you looking cool."
	icon_state = "headband"

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

/obj/item/clothing/head/modular/style/bandana
	name = "TGMC bandana"
	desc = "A bandana that goes on your head. Has TGMC markings on the back tie, and it seems that the knot will never come undone somehow."
	icon_state = "headbandana"

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

// style masks
/obj/item/clothing/mask/gas/modular/skimask
	name = "ski mask"
	desc = "A stylish skimask, can be recolored. Makes you feel like an operator just looking at it."
	icon_state = "skimask"
	item_state = "skimask"
	flags_inv_hide = HIDEALLHAIR|HIDEEARS
	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

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

/obj/item/clothing/mask/gas/modular/coofmask
	name = "combat face cloth covering"
	desc = "The CFCC is a prime and readied, yet stylish facemask ready to... cover your face."
	icon_state = "coofmask"
	item_state = "coofmask"
	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

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
