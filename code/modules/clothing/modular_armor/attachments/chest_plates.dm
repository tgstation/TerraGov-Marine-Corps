/**
 *
 *  Chestplates
 *
 */
/obj/item/armor_module/armor/chest
	icon = 'icons/mob/modular/mark_one/chest_plates.dmi'
	icon_state = "infantry"
	slot = ATTACHMENT_SLOT_CHESTPLATE

/obj/item/armor_module/armor/chest/marine
	name = "\improper Jaeger Pattern Medium Infantry chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry"
	soft_armor = list(MELEE = 25, BULLET = 45, LASER = 45, ENERGY = 35, BOMB = 30, BIO = 30, FIRE = 30, ACID = 35)
	slowdown = 0.3

/obj/item/armor_module/armor/chest/marine/skirmisher
	name = "\improper Jaeger Pattern Light Skirmisher chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher"
	soft_armor = list(MELEE = 20, BULLET = 40, LASER = 40, ENERGY = 30, BOMB = 30, BIO = 30, FIRE = 30, ACID = 30)
	slowdown = 0.1

/obj/item/armor_module/armor/chest/marine/skirmisher/scout
	name = "\improper Jaeger Pattern Light Scout chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides minor protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Scout armor piece."
	icon_state = "scout"

/obj/item/armor_module/armor/chest/marine/assault
	name = "\improper Jaeger Pattern Heavy Assault chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault"
	soft_armor = list(MELEE = 30, BULLET = 50, LASER = 50, ENERGY = 40, BOMB = 30, BIO = 30, FIRE = 30, ACID = 40)
	slowdown = 0.5

/obj/item/armor_module/armor/chest/marine/eva
	name = "\improper Jaeger Pattern Medium EVA chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides moderate protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EVA armor piece."
	icon_state = "eva"

/obj/item/armor_module/armor/chest/marine/assault/eod
	name = "\improper Jaeger Pattern Heavy EOD chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides high protection and encumbrance when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a EOD armor piece."
	icon_state = "eod"
