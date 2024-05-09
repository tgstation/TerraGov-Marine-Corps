//Jaeger Mk.II

//Medium
/obj/item/clothing/suit/modular/jaeger
	name = "\improper Jaeger Infantry medium exoskeleton"
	desc = "A Infantry-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_MEDIUM
	icon_state = "chest"
	worn_icon_state = "chest"
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
		/obj/item/armor_module/armor/badge,
	)

	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

	greyscale_config = /datum/greyscale_config/armor_mk2/infantry
	colorable_allowed = PRESET_COLORS_ALLOWED
	colorable_colors = SECONDARY_COLORS
	greyscale_colors = ARMOR_PALETTE_DRAB


	allowed_uniform_type = /obj/item/clothing/under

/obj/item/clothing/suit/modular/jaeger/hodgrenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/jaeger/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/jaeger/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/lightgeneral
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/jaeger/mimir
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/jaeger/mimirinjector
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/injector,
	)

/obj/item/clothing/suit/modular/jaeger/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/shield_overclocked/medic
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/jaeger/shield_overclocked/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/jaeger/valk
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/eva
	name = "\improper Jaeger EVA medium exoskeleton"
	desc = "A EVA-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2/eva

/obj/item/clothing/suit/modular/jaeger/helljumper
	name = "\improper Jaeger Hell Jumper medium exoskeleton"
	desc = "A Hell-Jumper-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2/helljumper

/obj/item/clothing/suit/modular/jaeger/ranger
	name = "\improper Jaeger Ranger medium exoskeleton"
	desc = "A Ranger-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a moderate amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2/ranger

// Light

/obj/item/clothing/suit/modular/jaeger/light
	name = "\improper Jaeger Scout light exoskeleton"
	desc = "A Scout-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a light amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_LIGHT
	slowdown = SLOWDOWN_ARMOR_LIGHT
	greyscale_config = /datum/greyscale_config/armor_mk2/scout

/obj/item/clothing/suit/modular/jaeger/light/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/light/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/light/shield_overclocked/medic
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/jaeger/light/shield_overclocked/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/jaeger/light/lightmedical
	starting_attachments = list(
		/obj/item/armor_module/module/better_shoulder_lamp,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/light/skirmisher
	name = "\improper Jaeger Skirmisher light exoskeleton"
	desc = "A Skirmisher-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a light amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2/skirmisher

/obj/item/clothing/suit/modular/jaeger/light/trooper
	name = "\improper Jaeger Trooper light exoskeleton"
	desc = "A Trooper-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a light amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2/trooper

// Heavy
/obj/item/clothing/suit/modular/jaeger/heavy
	name = "\improper Jaeger Gungnir heavy exoskeleton"
	desc = "A Gungnir-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a high amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	soft_armor = MARINE_ARMOR_HEAVY
	slowdown = SLOWDOWN_ARMOR_HEAVY
	greyscale_config = /datum/greyscale_config/armor_mk2/gugnir

/obj/item/clothing/suit/modular/jaeger/heavy/assault
	name = "\improper Jaeger Assault heavy exoskeleton"
	desc = "A Assault-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a high amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2

/obj/item/clothing/suit/modular/jaeger/heavy/eod
	name = "\improper Jaeger EOD heavy exoskeleton"
	desc = "A EOD-pattern Jaeger combat exoskeleton made to work with modular attachments for the ability to function in many enviroments. This one seems to have a high amount of armor plating. Alt-Click to remove attached items. Use it to toggle the built-in flashlight."
	greyscale_config = /datum/greyscale_config/armor_mk2/eod

/obj/item/clothing/suit/modular/jaeger/heavy/mimirengi
	starting_attachments = list(
		/obj/item/armor_module/module/mimir_environment_protection/mark1,
		/obj/item/armor_module/storage/engineering,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/leader
	starting_attachments = list(
		/obj/item/armor_module/module/valkyrie_autodoc,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/tyr_onegeneral
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/tyr_one
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor/mark1,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/tyr_two
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/grenadier //Literally grenades
	starting_attachments = list(
		/obj/item/armor_module/module/ballistic_armor,
		/obj/item/armor_module/storage/grenade,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/surt
	starting_attachments = list(
		/obj/item/armor_module/module/fire_proof,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/shield
	starting_attachments = list(
		/obj/item/armor_module/module/eshield,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/shield_overclocked
	starting_attachments = list(
		/obj/item/armor_module/module/eshield/overclocked,
		/obj/item/armor_module/storage/medical,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/tyr_two/corpsman
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/general,
	)

/obj/item/clothing/suit/modular/jaeger/heavy/tyr_two/engineer
	starting_attachments = list(
		/obj/item/armor_module/module/tyr_extra_armor,
		/obj/item/armor_module/storage/engineering,
	)

//jaeger hats
/obj/item/clothing/head/modular/marine
	name = "Jaeger Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items/items_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/items_right.dmi',
	)
	icon_state = "helmet"
	worn_icon_state = "helmet"
	icon_override = null
	soft_armor = MARINE_ARMOR_HEAVY

	greyscale_colors = ARMOR_PALETTE_DRAB
	colorable_allowed = PRESET_COLORS_ALLOWED
	colorable_colors = SECONDARY_COLORS
	greyscale_config = /datum/greyscale_config/armor_mk2/infantry


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
		/obj/item/armor_module/module/night_vision,
		/obj/item/armor_module/storage/helmet,
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/armor/visor/marine,
		/obj/item/armor_module/armor/visor/marine/skirmisher,
		/obj/item/armor_module/armor/visor/marine/scout,
		/obj/item/armor_module/armor/visor/marine/eva,
		/obj/item/armor_module/armor/visor/marine/eva/skull,
		/obj/item/armor_module/armor/visor/marine/gungnir,
		/obj/item/armor_module/armor/visor/marine/eod,
		/obj/item/armor_module/armor/visor/marine/assault,
		/obj/item/armor_module/armor/visor/marine/helljumper,
		/obj/item/armor_module/armor/visor/marine/ranger,
		/obj/item/armor_module/armor/visor/marine/traditional,
		/obj/item/armor_module/armor/visor/marine/mjolnir_open,
		/obj/item/armor_module/armor/visor/marine/trooper,
	)

	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet)

	item_map_variant_flags = ITEM_JUNGLE_VARIANT|ITEM_ICE_VARIANT|ITEM_DESERT_VARIANT

/obj/item/clothing/head/modular/marine/open
	name = "Jaeger Pattern Infantry Open Helmet"
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	visorless_offset_y = 0
	greyscale_config = /datum/greyscale_config/armor_mk2/infantry/open

/obj/item/clothing/head/modular/marine/hod
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/hod_head)

/obj/item/clothing/head/modular/marine/freyr
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/artemis)

/obj/item/clothing/head/modular/marine/antenna
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/antenna)

/obj/item/clothing/head/modular/marine/welding
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding)

/obj/item/clothing/head/modular/marine/superiorwelding
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/welding/superior)

/obj/item/clothing/head/modular/marine/mimir
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1)

/obj/item/clothing/head/modular/marine/tyr
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head)

/obj/item/clothing/head/modular/marine/surt
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/fire_proof_helmet)

/obj/item/clothing/head/modular/marine/leader
	name = "\improper Jaeger Pattern Infantry leader Helmet"
	desc = "A slightly fancier helmet for marine leaders. This one has cushioning to project your fragile brain."
	soft_armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 65, BOMB = 55, BIO = 55, FIRE = 55, ACID = 60)

/obj/item/clothing/head/modular/marine/eva
	name = "Jaeger Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eva, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/eva

/obj/item/clothing/head/modular/marine/eva/skull
	name = "Jaeger Pattern EVA 'Skull' Helmet"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eva/skull, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/skirmisher
	name = "Jaeger Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/skirmisher, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/skirmisher

/obj/item/clothing/head/modular/marine/scout
	name = "Jaeger Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/scout, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/scout

/obj/item/clothing/head/modular/marine/gungnir
	name = "Jaeger Pattern Gungnir Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Gungnir markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/gungnir, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/gugnir

/obj/item/clothing/head/modular/marine/gungnir/hod
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/gungnir, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/hod_head)

/obj/item/clothing/head/modular/marine/gungnir/antenna
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/gungnir, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/antenna)

/obj/item/clothing/head/modular/marine/gungnir/mimir
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/gungnir, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/mimir_environment_protection/mimir_helmet/mark1)

/obj/item/clothing/head/modular/marine/gungnir/tyr
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/gungnir, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/tyr_head)

/obj/item/clothing/head/modular/marine/gungnir/surt
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/gungnir, /obj/item/armor_module/storage/helmet, /obj/item/armor_module/module/fire_proof_helmet)

/obj/item/clothing/head/modular/marine/assault
	name = "Jaeger Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/assault, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2

/obj/item/clothing/head/modular/marine/eod
	name = "Jaeger Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/eod, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/eod

/obj/item/clothing/head/modular/marine/helljumper
	name = "Jaeger Pattern Helljumper Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Helljumper markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/helljumper, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/helljumper
	visorless_offset_y = 0

/obj/item/clothing/head/modular/marine/ranger
	name = "Jaeger Pattern Ranger Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Ranger markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/ranger, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/ranger

/obj/item/clothing/head/modular/marine/traditional
	name = "Jaeger Pattern Traditional Ranger Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has traditional Ranger markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/traditional, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/traditional

/obj/item/clothing/head/modular/marine/trooper
	name = "Jaeger Pattern Trooper Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Trooper markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/trooper, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/trooper

/obj/item/clothing/head/modular/marine/mjolnir_open
	name = "Jaeger Mk.I Pattern Open Mjolnir Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Mjolnir markings but explosing the lower jaw."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/mjolnir_open, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk2/mjolnir_open

