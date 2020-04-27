

/obj/item/armor_module/armor
	name = "modular armor - armor module"
	icon = 'icons/mob/modular/modular.dmi'
	/// The additional armor provided by equipping this piece.
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/// Chest pieces
/obj/item/armor_module/armor/chest
	icon_state = "mod_chest"

/obj/item/armor_module/armor/chest/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_chest = src
	parent.update_overlays()

/obj/item/armor_module/armor/chest/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_chest = null
	return ..()


/// Arm pieces
/obj/item/armor_module/armor/arms
	icon_state = "mod_arms"

/obj/item/armor_module/armor/arms/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_arms = src
	parent.update_overlays()

/obj/item/armor_module/armor/arms/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_arms = null
	return ..()


/// Leg pieces
/obj/item/armor_module/armor/legs
	icon_state = "mod_legs"

/obj/item/armor_module/armor/legs/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent)
	. = ..()
	parent.slot_legs = src
	parent.update_overlays()


/obj/item/armor_module/armor/legs/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent)
	parent.slot_legs = null
	return ..()

/** Chest pieces */
/obj/item/armor_module/armor/chest/light
	name = "light chest armor module"
	armor = list("melee" = 10)

/obj/item/armor_module/armor/chest/medium
	name = "medium chest armor module"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/chest/heavy
	name = "heavy chest armor module"
	armor = list("melee" = 50)

/** Legs pieces */
/obj/item/armor_module/armor/legs/light
	name = "light leg armor module"
	armor = list("melee" = 10)

/obj/item/armor_module/armor/legs/medium
	name = "medium leg armor module"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/legs/heavy
	name = "heavy leg armor module"
	armor = list("melee" = 50)


/** Arms pieces */
/obj/item/armor_module/armor/arms/light
	name = "light arm armor module"
	armor = list("melee" = 10)

/obj/item/armor_module/armor/arms/medium
	name = "medium arm armor module"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/arms/heavy
	name = "heavy arm armor module"
	armor = list("melee" = 50)
