
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
	icon_state = "infantry_chest"

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

/obj/item/armor_module/armor/chest/marine
	name = "\improper Jaeger Pattern Infantry chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_chest"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/chest/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_chest"

/obj/item/armor_module/armor/chest/marine/assault
	name = "\improper Jaeger Pattern Assault chestplates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece.."
	icon_state = "assault_chest"


/** Legs pieces */
/obj/item/armor_module/armor/legs
	icon_state = "infantry_legs"

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

/obj/item/armor_module/armor/legs/marine
	name = "\improper Jaeger Pattern Infantry leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_legs"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/legs/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_legs"

/obj/item/armor_module/armor/legs/marine/assault
	name = "\improper Jaeger Pattern Assault leg plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_legs"

/** Arms pieces */
/obj/item/armor_module/armor/arms
	icon_state = "infantry_arms"

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

/obj/item/armor_module/armor/arms/marine
	name = "\improper Jaeger Pattern Infantry arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Infantry armor piece."
	icon_state = "infantry_arms"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/arms/marine/skirmisher
	name = "\improper Jaeger Pattern Skirmisher arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Skirmisher armor piece."
	icon_state = "skirmisher_arms"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1

/obj/item/armor_module/armor/arms/marine/assault
	name = "\improper Jaeger Pattern Assault arm plates"
	desc = "Designed for use with the Jaeger Combat Exoskeleton. It provides protection when attached and is fairly easy to attach and remove from armor. Click on the armor frame to attach it. This armor appears to be marked as a Assault armor piece."
	icon_state = "assault_arms"
	soft_armor = list("melee" = 10, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 10, "acid" = 10)
	slowdown = 0.1
