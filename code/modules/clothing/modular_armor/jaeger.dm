//Jaeger Mk.II

//Medium
/obj/item/clothing/suit/modular/jaeger
	name = "\improper Jaeger Infantry medium exoskeleton"
	desc = "A Infantry-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 45, BULLET = 65, LASER = 65, ENERGY = 55, BOMB = 50, BIO = 50, FIRE = 50, ACID = 55)
	icon = 'icons/mob/modular/jaeger_armor.dmi'
	item_icons = list(slot_wear_suit_str = 'icons/mob/modular/jaeger_armor.dmi')
	icon_state = "infantry"
	item_state = "infantry"
	slowdown = SLOWDOWN_ARMOR_MEDIUM

	attachments_allowed = list(
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
	)

	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT
	icon_state_variants = list(
		"black",
		"jungle",
		"desert",
		"snow",
		"alpha",
		"bravo",
		"charlie",
		"delta",
	)

	current_variant = "black"

	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/jaeger/eva
	name = "\improper Jaeger EVA medium exoskeleton"
	desc = "A EVA-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "eva"
	item_state = "eva"

/obj/item/clothing/suit/modular/jaeger/helljumper
	name = "\improper Jaeger Hell Jumper medium exoskeleton"
	desc = "A Hell-Jumper-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "helljumper"
	item_state = "helljumper"

/obj/item/clothing/suit/modular/jaeger/ranger
	name = "\improper Jaeger Ranger medium exoskeleton"
	desc = "A Ranger-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "ranger"
	item_state = "ranger"

// Light

/obj/item/clothing/suit/modular/jaeger/light
	name = "\improper Jaeger Scout light exoskeleton"
	desc = "A Scout-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a light amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 35, BULLET = 55, LASER = 55, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 45, ACID = 45)
	icon_state = "scout"
	item_state = "scout"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/modular/jaeger/light/skirmisher
	name = "\improper Jaeger Skirmisher light exoskeleton"
	desc = "A Skirmisher-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a light amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "skirmisher"
	item_state = "skirmisher"

// Heavy

/obj/item/clothing/suit/modular/jaeger/heavy
	name = "\improper Jaeger Gungnir heavy exoskeleton"
	desc = "A Gungnir-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a high amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)
	icon_state = "gungnir"
	item_state = "gungnir"
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/modular/jaeger/heavy/assault
	name = "\improper Jaeger Assault heavy exoskeleton"
	desc = "A Assault-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a high amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "assault"
	item_state = "assault"

/obj/item/clothing/suit/modular/jaeger/heavy/eod
	name = "\improper Jaeger EOD heavy exoskeleton"
	desc = "A EOD-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a high amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	icon_state = "eod"
	item_state = "eod"

//jaeger hats
/obj/item/clothing/head/modular/marine
	name = "Jaeger Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	icon = 'icons/mob/modular/jaeger_helmets.dmi'
	item_icons = list(
		slot_head_str = 'icons/mob/modular/jaeger_helmets.dmi',
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)
	icon_state = "infantry"
	item_state = "infantry"
	icon_override = null
	soft_armor = list(MELEE = 50, BULLET = 70, LASER = 70, ENERGY = 60, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)


	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
		/obj/item/armor_module/module/fire_proof_helmet,
		/obj/item/armor_module/module/hod_head,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet,
		/obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1,
		/obj/item/armor_module/module/welding,
		/obj/item/armor_module/module/welding/superior,
		/obj/item/armor_module/module/binoculars,
		/obj/item/armor_module/module/binoculars/artemis_mark_two,
		/obj/item/armor_module/module/artemis,
		/obj/item/armor_module/module/antenna,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/greyscale/badge,
		/obj/item/armor_module/greyscale/visor/marine,
		/obj/item/armor_module/greyscale/visor/marine/skirmisher,
		/obj/item/armor_module/greyscale/visor/marine/scout,
		/obj/item/armor_module/greyscale/visor/marine/eva,
		/obj/item/armor_module/greyscale/visor/marine/eva/skull,
		/obj/item/armor_module/greyscale/visor/marine/gungnir,
		/obj/item/armor_module/greyscale/visor/marine/eod,
		/obj/item/armor_module/greyscale/visor/marine/assault,
		/obj/item/armor_module/greyscale/visor/marine/helljumper,
		/obj/item/armor_module/greyscale/visor/marine/ranger,
		/obj/item/armor_module/greyscale/visor/marine/traditional,
	)

	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine, /obj/item/armor_module/storage/helmet)

	flags_item_map_variant = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

	icon_state_variants = list(
		"black",
		"jungle",
		"desert",
		"snow",
		"alpha",
		"bravo",
		"charlie",
		"delta",
	)

	current_variant = "black"

/obj/item/clothing/head/modular/marine/eva
	name = "Jaeger Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	icon_state = "eva"
	item_state = "eva"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/eva, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eva/skull
	name = "Jaeger Pattern EVA 'Skull' Helmet"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/eva/skull, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/skirmisher
	name = "Jaeger Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	icon_state = "skirmisher"
	item_state = "skirmisher"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/skirmisher, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/scout
	name = "Jaeger Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	icon_state = "scout"
	item_state = "scout"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/scout, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/gungnir
	name = "Jaeger Pattern Gungnir Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Gungnir markings"
	icon_state = "gungnir"
	item_state = "gungnir"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/gungnir, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/assault
	name = "Jaeger Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	icon_state = "assault"
	item_state = "assault"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/assault, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/eod
	name = "Jaeger Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	icon_state = "eod"
	item_state = "eod"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/eod, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/helljumper
	name = "Jaeger Pattern Helljumper Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Helljumper markings"
	icon_state = "helljumper"
	item_state = "helljumper"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/helljumper, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/ranger
	name = "Jaeger Pattern Ranger Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Ranger markings"
	icon_state = "ranger"
	item_state = "ranger"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/ranger, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/traditional
	name = "Jaeger Pattern Traditional Ranger Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has traditional Ranger markings"
	icon_state = "traditional"
	item_state = "traditional"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/traditional, /obj/item/armor_module/storage/helmet)
