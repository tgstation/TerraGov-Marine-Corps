
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
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

	/// Addititve Slowdown of this armor piece
	slowdown = 0

/obj/item/armor_module/armor/Initialize()
	. = ..()
	icon_state = "[initial(icon_state)]_icon"
	item_state = initial(icon_state)


/obj/item/armor_module/armor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, /obj/item/facepaint))
		return FALSE

	var/obj/item/facepaint/paint = I
	if(paint.uses < 1)
		to_chat(user, "<span class='warning'>\the [paint] is out of color!</span>")
		return TRUE
	paint.uses--

	var/new_color = input(user, "Pick a color", "Pick color", "") in list(
		"black", "snow", "desert", "gray", "brown", "red", "blue", "yellow", "green", "aqua", "purple", "orange"
	)

	if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
		return TRUE

	icon_state = "[initial(icon_state)]_[new_color]_icon"
	item_state = "[initial(icon_state)]_[new_color]"

	return TRUE


/obj/item/armor_module/armor/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.soft_armor = parent.soft_armor.attachArmor(soft_armor)
	parent.hard_armor = parent.hard_armor.attachArmor(hard_armor)
	parent.slowdown += slowdown

/obj/item/armor_module/armor/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.soft_armor = parent.soft_armor.detachArmor(soft_armor)
	parent.hard_armor = parent.hard_armor.detachArmor(hard_armor)
	parent.slowdown -= slowdown
	return ..()



/** Chest pieces */
/obj/item/armor_module/armor/chest
	icon_state = "medium_chest"

/obj/item/armor_module/armor/chest/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(parent.slot_chest)
		if(!silent)
			to_chat(user, "<span class='notice'>There is already an armor piece installed in that slot.</span>")
		return FALSE

/obj/item/armor_module/armor/chest/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_chest = src

/obj/item/armor_module/armor/chest/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_chest = null
	return ..()

/obj/item/armor_module/armor/chest/light
	name = "\improper Jaeger Pattern light chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_chest"
	soft_armor = list("melee" = 19, "bullet" = 19, "laser" = 19, "energy" = 19, "bomb" = 19, "bio" = 19, "rad" = 19, "fire" = 19, "acid" = 19)
	slowdown = 0.15


/obj/item/armor_module/armor/chest/medium
	name = "\improper Jaeger Pattern medium chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_chest"
	soft_armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 25, "bio" = 25, "rad" = 25, "fire" = 25, "acid" = 25)
	slowdown = 0.3


/obj/item/armor_module/armor/chest/heavy
	name = "\improper Jaeger Pattern heavy chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_chest"
	soft_armor = list("melee" = 31, "bullet" = 31, "laser" = 31, "energy" = 31, "bomb" = 31, "bio" = 31, "rad" = 31, "fire" = 31, "acid" = 31)
	slowdown = 0.6



/** Legs pieces */
/obj/item/armor_module/armor/legs
	icon_state = "medium_legs"

/obj/item/armor_module/armor/legs/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(parent.slot_legs)
		if(!silent)
			to_chat(user, "<span class='notice'>There is already an armor piece installed in that slot.</span>")
		return FALSE

/obj/item/armor_module/armor/legs/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_legs = src

/obj/item/armor_module/armor/legs/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_legs = null
	return ..()

/obj/item/armor_module/armor/legs/light
	name = "\improper Jaeger Pattern light leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_legs"
	soft_armor = list("melee" = 8, "bullet" = 8, "laser" = 8, "energy" = 8, "bomb" = 8, "bio" = 8, "rad" = 8, "fire" = 8, "acid" = 8)
	slowdown = 0.05

/obj/item/armor_module/armor/legs/medium
	name = "\improper Jaeger Pattern medium leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_legs"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/legs/heavy
	name = "\improper Jaeger Pattern heavy leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_legs"
	soft_armor = list("melee" = 12, "bullet" = 12, "laser" = 12, "energy" = 12, "bomb" = 12, "bio" = 12, "rad" = 12, "fire" = 12, "acid" = 12)
	slowdown = 0.2


/** Arms pieces */
/obj/item/armor_module/armor/arms
	icon_state = "medium_arms"

/obj/item/armor_module/armor/arms/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent = FALSE)
	. = ..()
	if(!.)
		return
	if(parent.slot_arms)
		if(!silent)
			to_chat(user, "<span class='notice'>There is already an armor piece installed in that slot.</span>")
		return FALSE

/obj/item/armor_module/armor/arms/do_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_arms = src

/obj/item/armor_module/armor/arms/do_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_arms = null
	return ..()

/obj/item/armor_module/armor/arms/light
	name = "\improper Jaeger Pattern light arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a light amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides somewhat minimal defensive qualities, but has very little impact on the users mobility."
	icon_state = "light_arms"
	soft_armor = list("melee" = 8, "bullet" = 8, "laser" = 8, "energy" = 8, "bomb" = 8, "bio" = 8, "rad" = 8, "fire" = 8, "acid" = 8)
	slowdown = 0.05

/obj/item/armor_module/armor/arms/medium
	name = "\improper Jaeger Pattern medium arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a medium amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides moderate defensive qualities, with a moderate impact on the users mobility."
	icon_state = "medium_arms"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/arms/heavy
	name = "\improper Jaeger Pattern heavy arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides a heavy amount of protection and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor provides heavy defensive qualities, with a notable impact on the users mobility."
	icon_state = "heavy_arms"
	soft_armor = list("melee" = 12, "bullet" = 12, "laser" = 12, "energy" = 12, "bomb" = 12, "bio" = 12, "rad" = 12, "fire" = 12, "acid" = 12)
	slowdown = 0.2
