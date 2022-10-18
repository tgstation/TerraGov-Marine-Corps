/**
 *  Arms pieces
*/

/obj/item/armor_module/armor/arms
	icon = null
	icon_state = "infantry_arms"
	greyscale_config = /datum/greyscale_config/modulararms
	slot = ATTACHMENT_SLOT_SHOULDER

/obj/item/armor_module/armor/arms/marine
	name = "\improper Jaeger Pattern Infantry arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_arms"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, FIRE = 10, ACID = 10)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modulararms

/obj/item/armor_module/armor/arms/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_arms"
	greyscale_config = /datum/greyscale_config/modulararms/skirmisher

/obj/item/armor_module/armor/arms/marine/scout
	name = "\improper Jaeger Pattern Scout arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_arms"
	greyscale_config = /datum/greyscale_config/modulararms/scout

/obj/item/armor_module/armor/arms/marine/assault
	name = "\improper Jaeger Pattern Assault arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_arms"
	greyscale_config = /datum/greyscale_config/modulararms/assault

/obj/item/armor_module/armor/arms/marine/eva
	name = "\improper Jaeger Pattern EVA arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_arms"
	greyscale_config = /datum/greyscale_config/modulararms/eva

/obj/item/armor_module/armor/arms/marine/eod
	name = "\improper Jaeger Pattern EOD arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_arms"
	greyscale_config = /datum/greyscale_config/modulararms/eod

/obj/item/armor_module/armor/arms/marine/helljumper
	name = "\improper Jaeger Pattern Helljumper arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Helljumper armor piece."
	icon_state = "helljumper_arms"
	greyscale_config = /datum/greyscale_config/modulararms/helljumper
