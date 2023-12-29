/**
 *  Leg Pieces
*/

/obj/item/armor_module/armor/legs
	icon_state = "leg"
	greyscale_config = /datum/greyscale_config/armor_mk1/infantry
	slot = ATTACHMENT_SLOT_KNEE


/obj/item/armor_module/armor/legs/marine
	name = "\improper Jaeger Pattern Infantry leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Infantry armor piece."
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/legs/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Skirmisher armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/skirmisher

/obj/item/armor_module/armor/legs/marine/scout
	name = "\improper Jaeger Pattern Scout leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Scout armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/scout

/obj/item/armor_module/armor/legs/marine/assault
	name = "\improper Jaeger Pattern Assault leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Assault armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1

/obj/item/armor_module/armor/legs/marine/eva
	name = "\improper Jaeger Pattern EVA leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a EVA armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/eva

/obj/item/armor_module/armor/legs/marine/eod
	name = "\improper Jaeger Pattern EOD leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a EOD armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/eod

/obj/item/armor_module/armor/legs/marine/helljumper
	name = "\improper Jaeger Pattern Hell Jumper leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Hell Jumper armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/helljumper

/obj/item/armor_module/armor/legs/marine/ranger
	name = "\improper Jaeger Pattern Ranger leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Ranger armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/ranger

/obj/item/armor_module/armor/legs/marine/trooper
	name = "\improper Jaeger Pattern Trooper leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All leg plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Trooper armor piece."
	greyscale_config = /datum/greyscale_config/armor_mk1/trooper

// Hardsuit Leg Plates

// Base Hardsuit Legs
/obj/item/armor_module/armor/legs/marine/hardsuit_legs
	name = "\improper FleckTex Base leg plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Base armor piece."
	starting_attachments = list(/obj/item/armor_module/armor/secondary_color/leg)
	greyscale_config = /datum/greyscale_config/hardsuit_variant

/obj/item/armor_module/armor/legs/marine/hardsuit_legs/syndicate_markfive
	name = "\improper FleckTex Mark V Breacher leg plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark V armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant/syndicate_markfive

/obj/item/armor_module/armor/legs/marine/hardsuit_legs/syndicate_markthree
	name = "\improper FleckTex Mark III Marauder leg plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark III armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant/syndicate_markthree

/obj/item/armor_module/armor/legs/marine/hardsuit_legs/syndicate_markone
	name = "\improper FleckTex Mark I Raider leg plates"
	desc = "Designed for use with the FleckTex WY-01 Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. All arm plates have the same armor and slowdown, meaning that only changing the chestplate makes significant armor difference. This armor appears to be marked as a Mark I armor piece."
	greyscale_config = /datum/greyscale_config/hardsuit_variant
