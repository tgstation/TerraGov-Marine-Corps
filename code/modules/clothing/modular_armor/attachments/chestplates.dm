/**
 *
 *  Chestplates
 *
 */
/obj/item/armor_module/armor/chest
	icon_state = "infantry_chest"
	greyscale_config = /datum/greyscale_config/modularchest
	slot = ATTACHMENT_SLOT_CHESTPLATE

/obj/item/armor_module/armor/chest/marine
	name = "\improper Jaeger Pattern Medium Infantry chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_chest"
	soft_armor = list(MELEE = 25, BULLET = 45, LASER = 45, ENERGY = 35, BOMB = 30, BIO = 30, "rad" = 30, FIRE = 30, ACID = 35)
	slowdown = 0.3
	greyscale_config = /datum/greyscale_config/modularchest

/obj/item/armor_module/armor/chest/marine/skirmisher
	name = "\improper Jaeger Pattern Light Skirmisher chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_chest"
	soft_armor = list(MELEE = 20, BULLET = 40, LASER = 40, ENERGY = 30, BOMB = 30, BIO = 30, "rad" = 30, FIRE = 30, ACID = 30)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modularchest/skirmisher

/obj/item/armor_module/armor/chest/marine/skirmisher/scout
	name = "\improper Jaeger Pattern Light Scout chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_chest"
	greyscale_config = /datum/greyscale_config/modularchest/scout

/obj/item/armor_module/armor/chest/marine/assault
	name = "\improper Jaeger Pattern Heavy Assault chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_chest"
	soft_armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 40, BOMB = 30, BIO = 30, "rad" = 30, FIRE = 30, ACID = 40)
	slowdown = 0.5
	greyscale_config = /datum/greyscale_config/modularchest/assault

/obj/item/armor_module/armor/chest/marine/eva //Medium armor alt look
	name = "\improper Jaeger Pattern Medium EVA chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_chest"
	greyscale_config = /datum/greyscale_config/modularchest/eva

/obj/item/armor_module/armor/chest/marine/assault/eod //Heavy armor alt look
	name = "\improper Jaeger Pattern Heavy EOD chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_chest"
	greyscale_config = /datum/greyscale_config/modularchest/eod

/obj/item/armor_module/armor/chest/marine/helljumper
	name = "\improper Jaeger Pattern Medium Helljumper chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Helljumper armor piece."
	icon_state = "helljumper_chest"
	greyscale_config = /datum/greyscale_config/modularchest/helljumper
