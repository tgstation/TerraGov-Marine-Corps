
/**
 *  Leg Pieces
*/

/obj/item/armor_module/armor/legs
	icon = null
	icon_state = "infantry_legs"
	greyscale_config = /datum/greyscale_config/modularlegs
	slot = ATTACHMENT_SLOT_KNEE

/obj/item/armor_module/armor/legs/marine
	name = "\improper Jaeger Pattern Infantry leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_legs"
	soft_armor = list(MELEE = 10, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, BIO = 10, "rad" = 10, FIRE = 10, ACID = 10)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modularlegs

/obj/item/armor_module/armor/legs/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_legs"
	greyscale_config = /datum/greyscale_config/modularlegs/skirmisher

/obj/item/armor_module/armor/legs/marine/scout
	name = "\improper Jaeger Pattern Scout leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_legs"
	greyscale_config = /datum/greyscale_config/modularlegs/scout

/obj/item/armor_module/armor/legs/marine/assault
	name = "\improper Jaeger Pattern Assault leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_legs"
	greyscale_config = /datum/greyscale_config/modularlegs/assault

/obj/item/armor_module/armor/legs/marine/eva
	name = "\improper Jaeger Pattern EVA leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_legs"
	greyscale_config = /datum/greyscale_config/modularlegs/eva

/obj/item/armor_module/armor/legs/marine/eod
	name = "\improper Jaeger Pattern EOD leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_legs"
	greyscale_config = /datum/greyscale_config/modularlegs/eva

/obj/item/armor_module/armor/legs/marine/helljumper
	name = "\improper Jaeger Pattern Helljumper leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Helljumper armor piece."
	icon_state = "helljumper_legs"
	greyscale_config = /datum/greyscale_config/modularlegs/helljumper
