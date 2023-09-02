//Old jaeger for old grogs
/obj/item/clothing/head/modular/marine/old
	name = "Jaeger Mk.I Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	icon_state = "helmet"
	item_state = "helmet"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/items_righthand_1.dmi',
	)

	attachments_allowed = list(
		/obj/item/armor_module/module/tyr_head,
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
		/obj/item/armor_module/armor/badge,
		/obj/item/armor_module/armor/visor/marine/old,
		/obj/item/armor_module/armor/visor/marine/old/skirmisher,
		/obj/item/armor_module/armor/visor/marine/old/scout,
		/obj/item/armor_module/armor/visor/marine/old/eva,
		/obj/item/armor_module/armor/visor/marine/old/eva/skull,
		/obj/item/armor_module/armor/visor/marine/old/eod,
		/obj/item/armor_module/armor/visor/marine/old/assault,
		/obj/item/armor_module/module/fire_proof_helmet,
	)

	greyscale_config = /datum/greyscale_config/armor_mk1/infantry
	greyscale_colors = ARMOR_PALETTE_DRAB
	colorable_colors = ARMOR_PALETTES_LIST
	colorable_allowed = PRESET_COLORS_ALLOWED


	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/open
	name = "Jaeger Mk.I Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points."
	starting_attachments = list(/obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk1/infantry/old
	visorless_offset_y = 0

/obj/item/clothing/head/modular/marine/old/eva
	name = "Jaeger Mk.I Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old/eva, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk1/eva

/obj/item/clothing/head/modular/marine/old/eva/skull
	name = "Jaeger Mk.I Pattern EVA 'Skull' Helmet"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old/eva/skull, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/skirmisher
	name = "Jaeger Mk.I Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old/skirmisher, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk1/skirmisher

/obj/item/clothing/head/modular/marine/old/scout
	name = "Jaeger Mk.I Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old/scout, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk1/scout

/obj/item/clothing/head/modular/marine/old/assault
	name = "Jaeger Mk.I Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old/assault, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk1

/obj/item/clothing/head/modular/marine/old/eod
	name = "Jaeger Mk.I Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	starting_attachments = list(/obj/item/armor_module/armor/visor/marine/old/eod, /obj/item/armor_module/storage/helmet)
	greyscale_config = /datum/greyscale_config/armor_mk1/eod
