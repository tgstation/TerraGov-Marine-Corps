

/obj/item/armor_module/armor
	name = "modular armor - armor module"
	/// The additional armor provided by equipping this piece.
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/// Chest pieces
/obj/item/armor_module/armor/chest/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent_armor)
	. = ..()
	parent_armor.slot_chest = src

/obj/item/armor_module/armor/chest/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent_armor)
	parent_armor.slot_chest = null
	return ..()


/// Arm pieces
/obj/item/armor_module/armor/arms/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent_armor)
	. = ..()
	parent_armor.slot_arms = src

/obj/item/armor_module/armor/arms/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent_armor)
	parent_armor.slot_arms = null
	return ..()


/// Leg pieces
/obj/item/armor_module/armor/legs/on_attach(mob/living/user, obj/item/clothing/suit/modular/parent_armor)
	. = ..()
	parent_armor.slot_legs = src

/obj/item/armor_module/armor/legs/on_deattach(mob/living/user, obj/item/clothing/suit/modular/parent_armor)
	parent_armor.slot_legs = null
	return ..()


/obj/item/armor_module/armor/chest/light
	name = "light chest armor module"
	armor = list("melee" = 10)


/obj/item/armor_module/armor/chest/medium
	name = "medium chest armor module"
	armor = list("melee" = 25)

/obj/item/armor_module/armor/chest/heavy
	name = "heavy chest armor module"
	armor = list("melee" = 50)
