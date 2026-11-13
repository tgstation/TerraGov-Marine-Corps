/**
 *
 *  Chestplates
 *
 */
/obj/item/armor_module/armor/chest
	icon_state = "chest"
	slot = ATTACHMENT_SLOT_CHESTPLATE
	greyscale_config = /datum/greyscale_config/armor_mk1/infantry

/obj/item/armor_module/armor/chest/marine
	name = "\improper Jaeger Pattern Medium Infantry chestplates"
	gender = PLURAL
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	soft_armor = list(MELEE = 25, BULLET = 45, LASER = 45, ENERGY = 35, BOMB = 30, BIO = 30, FIRE = 30, ACID = 35)
	slowdown = 0.3


/obj/item/armor_module/armor/chest/marine/skirmisher
	name = "\improper Jaeger Pattern Light Skirmisher chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	soft_armor = list(MELEE = 15, BULLET = 35, LASER = 35, ENERGY = 25, BOMB = 25, BIO = 25, FIRE = 25, ACID = 25)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/armor_mk1/skirmisher

/obj/item/armor_module/armor/chest/marine/skirmisher/scout
	name = "\improper Jaeger Pattern Light Scout chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/scout

/obj/item/armor_module/armor/chest/marine/skirmisher/trooper
	name = "\improper Jaeger Pattern Trooper chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Trooper armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/trooper

/obj/item/armor_module/armor/chest/marine/assault
	name = "\improper Jaeger Pattern Heavy Assault chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	soft_armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 40, BOMB = 35, BIO = 35, FIRE = 35, ACID = 40)
	slowdown = 0.5
	greyscale_config = /datum/greyscale_config/armor_mk1

/obj/item/armor_module/armor/chest/marine/eva
	name = "\improper Jaeger Pattern Medium EVA chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/eva

/obj/item/armor_module/armor/chest/marine/assault/eod
	name = "\improper Jaeger Pattern Heavy EOD chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/eod

/obj/item/armor_module/armor/chest/marine/helljumper
	name = "\improper Jaeger Pattern Hell Jumper chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Hell Jumper armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/helljumper

/obj/item/armor_module/armor/chest/marine/ranger
	name = "\improper Jaeger Pattern Ranger chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Ranger armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/ranger

/obj/item/armor_module/armor/chest/marine/mjolnir
	name = "\improper Jaeger Pattern Mjolnir chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Mjolnir armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/mjolnir

// Hardsuit Chest Plates
/obj/item/armor_module/armor/chest/marine/hardsuit
	icon_state_variants = list(
		"normal",
		"webbing",
	)
	current_variant = "normal"
	greyscale_colors = ARMOR_PALETTE_BLACK
	colorable_colors = LEGACY_ARMOR_PALETTES_LIST
	colorable_allowed = ICON_STATE_VARIANTS_ALLOWED|PRESET_COLORS_ALLOWED
	starting_attachments = list(/obj/item/armor_module/armor/secondary_color/chest/webbing)

/obj/item/armor_module/armor/chest/marine/hardsuit/syndicate_markfive
	name = "\improper FleckTex Mark V Breacher chestplates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark V armor piece."
	soft_armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 40, BOMB = 35, BIO = 35, FIRE = 35, ACID = 40)
	slowdown = 0.5
	greyscale_config = /datum/greyscale_config/hardsuit_variant/syndicate_markfive

/obj/item/armor_module/armor/chest/marine/hardsuit/syndicate_markthree
	name = "\improper FleckTex Mark III Marauder chestplates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark III armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant/syndicate_markthree

/obj/item/armor_module/armor/chest/marine/hardsuit/syndicate_markone
	name = "\improper FleckTex Mark I Raider chestplates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark I armor piece."
	soft_armor = list(MELEE = 15, BULLET = 35, LASER = 35, ENERGY = 25, BOMB = 25, BIO = 25, FIRE = 25, ACID = 25)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/hardsuit_variant

//VSD Hardsuits
/obj/item/armor_module/armor/chest/marine/vsd_hardsuit
	name = "\improper Crasher Super-Heavy MT/41 'Phobos' chestplate"
	desc = "Designed for use with the CrashCore MT/P Exoskeleton. It provides a very good amount protection, with the cost of encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. Meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a 'Phobos' armor piece."
	soft_armor = list(MELEE = 50, BULLET = 60, LASER = 60, ENERGY = 50, BOMB = 45, BIO = 45, FIRE = 45, ACID = 50)
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	greyscale_config = /datum/greyscale_config/vsd_hardsuit
	starting_attachments = list(/obj/item/armor_module/armor/secondary_color/chest/visor_color)

/obj/item/armor_module/armor/chest/marine/vsd_hardsuit/clementia
	name = "\improper Crasher Super-Heavy MT/41 'Clementia' chestplate"
	desc = "Designed for use with the CrashCore MT/P Exoskeleton. It provides a very good amount protection, with the cost of encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. Meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a 'Clementia' armor piece."
	greyscale_config = /datum/greyscale_config/vsd_hardsuit/alt
	starting_attachments = list(/obj/item/armor_module/armor/secondary_color/chest)

/obj/item/armor_module/armor/chest/marine/vsd_hardsuit/hephaestus
	name = "\improper Crasher Super-Heavy MT/41 'Hephaestus' chestplate"
	desc = "Designed for use with the CrashCore MT/P Exoskeleton. It provides a very good amount protection, with the cost of encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. Meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a 'Hephaestus' armor piece."
	greyscale_config = /datum/greyscale_config/vsd_hardsuit/alt_two
	starting_attachments = list(/obj/item/armor_module/armor/secondary_color/chest)
