/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox0"
	name = "ore box"
	desc = "A heavy box used for storing ore."
	density = TRUE
	anchored = FALSE
	resistance_flags = XENO_DAMAGEABLE
	interaction_flags = INTERACT_OBJ_DEFAULT|INTERACT_POWERLOADER_PICKUP_ALLOWED
	max_integrity = 100
	soft_armor = list(MELEE = 0, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
