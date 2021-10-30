/** 
 *  Arms pieces 
*/

/obj/item/armor_module/armor/arms
	icon = null
	icon_state = "infantry_arms"
	greyscale_config = /datum/greyscale_config/modulararms_infantry
	slot = ATTACHMENT_SLOT_SHOULDER

/obj/item/armor_module/armor/arms/marine
	name = "\improper Jaeger Pattern Infantry arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_arms"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1
	greyscale_config = /datum/greyscale_config/modulararms_infantry

/obj/item/armor_module/armor/arms/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_arms"
	greyscale_config = /datum/greyscale_config/modulararms_skirmisher

/obj/item/armor_module/armor/arms/marine/scout
	name = "\improper Jaeger Pattern Scout arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance  when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout_arms"
	greyscale_config = /datum/greyscale_config/modulararms_scout

/obj/item/armor_module/armor/arms/marine/assault
	name = "\improper Jaeger Pattern Assault arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_arms"
	greyscale_config = /datum/greyscale_config/modulararms_assault

/obj/item/armor_module/armor/arms/marine/eva
	name = "\improper Jaeger Pattern EVA arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva_arms"
	greyscale_config = /datum/greyscale_config/modulararms_eva

/obj/item/armor_module/armor/arms/marine/eod
	name = "\improper Jaeger Pattern EOD arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod_arms"
	greyscale_config = /datum/greyscale_config/modulararms_eod
