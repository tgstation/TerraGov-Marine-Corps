/datum/ammo/energy
	ping = "ping_s"
	sound_hit 	 	= "energy_hit"
	sound_miss		= "energy_miss"
	sound_bounce	= "energy_bounce"

	damage_type = BURN
	flags_ammo_behavior = AMMO_ENERGY
	armor_type = "energy"
	accuracy = 20

/datum/ammo/energy/plasmarifle
	name = "plasma rifle bolt"
	icon_state = "Plasmarifle shot"
	armor_type = "energy"
	flags_ammo_behavior = AMMO_ENERGY
	accurate_range = 15
	damage = 20
	penetration = 10
	max_range = 30
	accuracy_var_low = 3
	accuracy_var_high = 3