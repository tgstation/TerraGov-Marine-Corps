/**
 *  Arms pieces
*/

/obj/item/armor_module/armor/arms
	icon_state = "arm"
	slot = ATTACHMENT_SLOT_SHOULDER
	greyscale_config = /datum/greyscale_config/armor_mk1/infantry
	colorable_colors = ARMOR_PALETTES_LIST

/obj/item/armor_module/armor/arms/marine
	name = "\improper Jaeger Pattern Infantry arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Infantry armor piece."
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/arms/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Skirmisher armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/skirmisher

/obj/item/armor_module/armor/arms/marine/scout
	name = "\improper Jaeger Pattern Scout arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Scout armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/scout

/obj/item/armor_module/armor/arms/marine/assault
	name = "\improper Jaeger Pattern Assault arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Assault armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1

/obj/item/armor_module/armor/arms/marine/eva
	name = "\improper Jaeger Pattern EVA arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a EVA armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/eva

/obj/item/armor_module/armor/arms/marine/eod
	name = "\improper Jaeger Pattern EOD arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a EOD armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/eod

/obj/item/armor_module/armor/arms/marine/helljumper
	name = "\improper Jaeger Pattern Hell Jumper arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Hell Jumper armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/helljumper

/obj/item/armor_module/armor/arms/marine/ranger
	name = "\improper Jaeger Pattern Ranger arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Ranger armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/ranger

/obj/item/armor_module/armor/arms/marine/trooper
	name = "\improper Jaeger Pattern Trooper arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Trooper armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/trooper

/obj/item/armor_module/armor/arms/marine/kabuto
	name = "\improper Style Pattern Kabuto arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Kabuto armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/kabuto

/obj/item/armor_module/armor/arms/marine/hotaru
	name = "\improper Style Pattern Hotaru arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Hotaru armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/hotaru

/obj/item/armor_module/armor/arms/marine/dashe
	name = "\improper Style Pattern Dashe arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Dashe armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/dashe

// Hardsuit Arm Plates
/obj/item/armor_module/armor/arms/marine/hardsuit_arms
	name = "\improper FleckTex Base arm plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Base armor piece."
	starting_attachments = list(/obj/item/armor_module/armor/secondary_color/arm)
	attachments_allowed = list(/obj/item/armor_module/armor/secondary_color/arm)
	attachments_by_slot = list(ATTACHMENT_SLOT_ARM_SECONDARY_COLOR)
	greyscale_config = /datum/greyscale_config/hardsuit_variant

/obj/item/armor_module/armor/arms/marine/hardsuit_arms/syndicate_markfive
	name = "\improper FleckTex Mark V Breacher arm plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark V armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant/syndicate_markfive

/obj/item/armor_module/armor/arms/marine/hardsuit_arms/syndicate_markthree
	name = "\improper FleckTex Mark III marauder arm plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark III armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant/syndicate_markthree

/obj/item/armor_module/armor/arms/marine/hardsuit_arms/syndicate_markone
	name = "\improper FleckTex Mark I raider arm plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark I armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant



