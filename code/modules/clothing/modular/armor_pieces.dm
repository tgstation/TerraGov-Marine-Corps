/**
	Modular armor pieces

	These are straight armor attachments that equip into 1 of 3 slots on modular armor
	There are chest arms and leg variants, each with their own light medium and heavy armor (not mentioning special types)

	Each armor will merge its armor with the modular armor on attachment and remove it when detached, similar with other stats like slowdown.
*/
/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular_armor.dmi'

	/// The additional armor provided by equipping this piece.
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	/// Addititve Slowdown of this armor piece
	slowdown = 0

/obj/item/armor_module/armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(armor)
	parent.slowdown += slowdown

/obj/item/armor_module/armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(armor)
	parent.slowdown -= slowdown
	return ..()



/** Chest pieces */
/obj/item/armor_module/armor/chest
	icon_state = "medium_chest_icon"
	item_state = "medium_chest"

/obj/item/armor_module/armor/chest/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_chest = src
	parent.update_overlays()

/obj/item/armor_module/armor/chest/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_chest = null
	return ..()

/obj/item/armor_module/armor/chest/light
	name = "Jaeger Pattern light Chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_chest_icon"
	item_state = "light_chest"
	armor = list("melee" = 19, "bullet" = 19, "laser" = 19, "energy" = 19, "bomb" = 19, "bio" = 19, "rad" = 19, "fire" = 19, "acid" = 19)
	slowdown = 0.15


/obj/item/armor_module/armor/chest/medium
	name = "Jaeger Pattern medium Chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_chest_icon"
	item_state = "medium_chest"
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 25, "bio" = 25, "rad" = 25, "fire" = 25, "acid" = 25)
	slowdown = 0.3


/obj/item/armor_module/armor/chest/heavy
	name = "Jaeger Pattern heavy Chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_chest_icon"
	item_state = "heavy_chest"
	armor = list("melee" = 31, "bullet" = 31, "laser" = 31, "energy" = 31, "bomb" = 31, "bio" = 31, "rad" = 31, "fire" = 31, "acid" = 31)
	slowdown = 0.4



/** Legs pieces */
/obj/item/armor_module/armor/legs
	icon_state = "medium_legs_icon"
	item_state = "medium_legs"

/obj/item/armor_module/armor/legs/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_legs = src
	parent.update_overlays()

/obj/item/armor_module/armor/legs/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_legs = null
	return ..()

/obj/item/armor_module/armor/legs/light
	name = "Jaeger Pattern light Leg Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_legs_icon"
	item_state = "light_legs"
	armor = list("melee" = 8, "bullet" = 8, "laser" = 8, "energy" = 8, "bomb" = 8, "bio" = 8, "rad" = 8, "fire" = 8, "acid" = 8)
	slowdown = 0.05

/obj/item/armor_module/armor/legs/medium
	name = "Jaeger Pattern medium Leg Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_legs_icon"
	item_state = "medium_legs"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/legs/heavy
	name = "Jaeger Pattern heavy Leg Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_legs_icon"
	item_state = "heavy_legs"
	armor = list("melee" = 12, "bullet" = 12, "laser" = 12, "energy" = 12, "bomb" = 12, "bio" = 12, "rad" = 12, "fire" = 12, "acid" = 12)
	slowdown = 0.2


/** Arms pieces */
/obj/item/armor_module/armor/arms
	icon_state = "medium_arms_icon"
	item_state = "medium_arms"

/obj/item/armor_module/armor/arms/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_arms = src
	parent.update_overlays()

/obj/item/armor_module/armor/arms/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_arms = null
	return ..()

/obj/item/armor_module/armor/arms/light
	name = "Jaeger Pattern light Arm Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_arms_icon"
	item_state = "light_arms"
	armor = list("melee" = 8, "bullet" = 8, "laser" = 8, "energy" = 8, "bomb" = 8, "bio" = 8, "rad" = 8, "fire" = 8, "acid" = 8)
	slowdown = 0.05

/obj/item/armor_module/armor/arms/medium
	name = "Jaeger Pattern medium Arm Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_arms_icon"
	item_state = "medium_arms"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/arms/heavy
	name = "Jaeger Pattern heavy Arm Plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_arms_icon"
	item_state = "heavy_arms"
	armor = list("melee" = 12, "bullet" = 12, "laser" = 12, "energy" = 12, "bomb" = 12, "bio" = 12, "rad" = 12, "fire" = 12, "acid" = 12)
	slowdown = 0.2
