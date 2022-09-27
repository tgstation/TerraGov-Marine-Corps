/obj/item/mecha_parts/mecha_equipment/armor/melee
	name = "melee armor booster"
	desc = "Boosts exosuit armor against melee attacks."
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Melee Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	armor_mod = list(MELEE = 15, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/mecha_parts/mecha_equipment/armor/acid
	name = "acid armor booster"
	desc = "Boosts exosuit armor against acid attacks."
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Melee Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	armor_mod = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 15)

/obj/item/mecha_parts/mecha_equipment/armor/explosive
	name = "explosive armor booster"
	desc = "Boosts exosuit armor against explosions."
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Melee Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	armor_mod = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 50, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/mecha_parts/mecha_equipment/generator/plasma
	mech_flags = EXOSUIT_MODULE_GREYSCALE
