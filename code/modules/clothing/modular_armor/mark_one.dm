//Old jaeger for old grogs
/obj/item/clothing/head/modular/marine/old
	name = "Jaeger Mk.I Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Infantry markings."
	icon = 'icons/mob/modular/mark_one/helmets.dmi'
	icon_state = "infantry"
	item_state = "infantry"
	item_icons = list(
		slot_head_str = 'icons/mob/modular/mark_one/helmets.dmi',
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
		/obj/item/armor_module/greyscale/badge,
		/obj/item/armor_module/greyscale/visor/marine/old,
		/obj/item/armor_module/greyscale/visor/marine/old/skirmisher,
		/obj/item/armor_module/greyscale/visor/marine/old/scout,
		/obj/item/armor_module/greyscale/visor/marine/old/eva,
		/obj/item/armor_module/greyscale/visor/marine/old/eva/skull,
		/obj/item/armor_module/greyscale/visor/marine/old/eod,
		/obj/item/armor_module/greyscale/visor/marine/old/assault,
		/obj/item/armor_module/module/fire_proof_helmet,
	)

	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/open
	name = "Jaeger Mk.I Pattern Infantry Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	icon_state = "infantryopen"
	item_state = "infantryopen"
	starting_attachments = list(/obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/eva
	name = "Jaeger Mk.I Pattern EVA Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EVA markings."
	icon_state = "eva"
	item_state = "eva"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old/eva, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/eva/skull
	name = "Jaeger Mk.I Pattern EVA 'Skull' Helmet"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old/eva/skull, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/skirmisher
	name = "Jaeger Mk.I Pattern Skirmisher Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Skirmisher markings."
	icon_state = "skirmisher"
	item_state = "skirmisher"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old/skirmisher, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/scout
	name = "Jaeger Mk.I Pattern Scout Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Scout markings"
	icon_state = "scout"
	item_state = "scout"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old/scout, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/assault
	name = "Jaeger Mk.I Pattern Assault Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has Assault markings."
	icon_state = "assault"
	item_state = "assault"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old/assault, /obj/item/armor_module/storage/helmet)

/obj/item/clothing/head/modular/marine/old/eod
	name = "Jaeger Mk.I Pattern EOD Helmet"
	desc = "Usually paired with the Jaeger Combat Exoskeleton. Can mount utility functions on the helmet hard points. Has EOD markings"
	icon_state = "eod"
	item_state = "eod"
	starting_attachments = list(/obj/item/armor_module/greyscale/visor/marine/old/eod, /obj/item/armor_module/storage/helmet)
