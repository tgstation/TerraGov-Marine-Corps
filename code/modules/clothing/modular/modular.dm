/** 
	Modular armor
*/
/obj/item/clothing/suit/modular
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	allowed = list(/obj/item/tank/emergency_oxygen)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	flags_equip_slot = ITEM_SLOT_OCLOTHING
	w_class = WEIGHT_CLASS_NORMAL

	var/allowed_modules = list(
		/obj/item/armor_module,
	) ///List of allowed types [/obj/item/armor_module] that can be installed into this modular armor.
	var/installed_modules = list() ///List of currently installed types that are installed into this modular armor.


/obj/item/clothing/suit/modular/attackby(obj/item/I, mob/living/user, def_zone)
	. = ..()


/**
	Update a light modifier that ultimately calls .proc/set_light
*/
/obj/item/clothing/suit/modular/proc/update_light_mod(amount)
	light_mod += amount
	set_light(light_mod)

	