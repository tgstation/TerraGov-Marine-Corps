

/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular_armor.dmi'
	/// The additional armor provided by equipping this piece.
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/armor_module/armor/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.armor = parent.armor.attachArmor(src.armor)

/obj/item/armor_module/armor/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.armor = parent.armor.detachArmor(src.armor)
	return ..()


/// Chest pieces
/obj/item/armor_module/armor/chest
	icon_state = "medium_chest"
	item_state = "medium_chest_icon"


/obj/item/armor_module/armor/chest/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent)
	. = ..()
	if(!.)
		return

	if(parent.slot_chest)
		if(!silent)
			to_chat(user, "<span class='notice'>There is already something in that slot.</span>")
		return FALSE


/obj/item/armor_module/armor/chest/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_chest = src
	parent.update_overlays()

/obj/item/armor_module/armor/chest/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_chest = null
	return ..()


/// Arm pieces
/obj/item/armor_module/armor/arms
	icon_state = "medium_arms"
	item_state = "medium_arms_icon"


/obj/item/armor_module/armor/arms/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent)
	. = ..()
	if(!.)
		return

	if(parent.slot_arms)
		if(!silent)
			to_chat(user, "<span class='notice'>There is already something in that slot.</span>")
		return FALSE


/obj/item/armor_module/armor/arms/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_arms = src
	parent.update_overlays()

/obj/item/armor_module/armor/arms/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_arms = null
	return ..()


/// Leg pieces
/obj/item/armor_module/armor/legs
	icon_state = "medium_legs"
	item_state = "medium_legs_icon"


/obj/item/armor_module/armor/legs/can_attach(mob/living/user, obj/item/clothing/suit/modular/parent, silent)
	. = ..()
	if(!.)
		return

	if(parent.slot_legs)
		if(!silent)
			to_chat(user, "<span class='notice'>There is already something in that slot.</span>")
		return FALSE



/obj/item/armor_module/armor/legs/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_legs = src
	parent.update_overlays()


/obj/item/armor_module/armor/legs/on_detach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_legs = null
	return ..()

/** Chest pieces */
/obj/item/armor_module/armor/chest/light
	name = "light chest armor module"
	icon_state = "light_chest"
	armor = list("melee" = 10)

/obj/item/armor_module/armor/chest/medium
	name = "medium chest armor module"
	icon_state = "medium_chest"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/chest/heavy
	name = "heavy chest armor module"
	icon_state = "heavy_chest"
	armor = list("melee" = 50)

/** Legs pieces */
/obj/item/armor_module/armor/legs/light
	name = "light leg armor module"
	icon_state = "light_legs"
	armor = list("melee" = 10)

/obj/item/armor_module/armor/legs/medium
	name = "medium leg armor module"
	icon_state = "medium_legs"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/legs/heavy
	name = "heavy leg armor module"
	icon_state = "heavy_legs"
	armor = list("melee" = 50)


/** Arms pieces */
/obj/item/armor_module/armor/arms/light
	name = "light arm armor module"
	icon_state = "light_arms"
	armor = list("melee" = 10)

/obj/item/armor_module/armor/arms/medium
	name = "medium arm armor module"
	icon_state = "medium_arms"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/arms/heavy
	name = "heavy arm armor module"
	icon_state = "heaavy_arms"
	armor = list("melee" = 50)
