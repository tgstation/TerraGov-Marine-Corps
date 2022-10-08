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


/obj/item/mecha_parts/mecha_equipment/ability
	name = "generic mech ability"
	desc = "You shouldnt be seeing this"
	equipment_slot = MECHA_UTILITY
	///if given, a single flag of who we want this ability to be granted to
	var/flag_controller
	///typepath of ability we want to grant
	var/ability_to_grant

/obj/item/mecha_parts/mecha_equipment/ability/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	if(flag_controller)
		M.initialize_controller_action_type(ability_to_grant, flag_controller)
	else
		M.initialize_passenger_action_type(ability_to_grant)

/obj/item/mecha_parts/mecha_equipment/ability/detach(atom/moveto)
	if(flag_controller)
		chassis.destroy_controller_action_type(ability_to_grant, flag_controller)
	else
		chassis.destroy_passenger_action_type(ability_to_grant)
	return ..()

/obj/item/mecha_parts/mecha_equipment/ability/dash
	name = "actuator safety override"
	desc = "A haphazard collection of electronics that allows the user to override standard safety inputs to increase speed, at the cost of extremely high power usage."
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_overload_mode

/obj/item/mecha_parts/mecha_equipment/ability/zoom
	name = "enhanced zoom"
	desc = "A magnifying module that allows the pilot to see much further than with the standard optics. Night vision not included."
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_zoom

/obj/item/mecha_parts/mecha_equipment/ability/smoke
	name = "generic smoke module"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	///smoke type to spawn when this ability is activated
	var/smoke_type
	///size of smoke cloud that spawns
	var/size = 6
	///duration of smoke cloud that spawns
	var/duration = 8

/obj/item/mecha_parts/mecha_equipment/ability/smoke/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new smoke_type
	smoke.set_up(size, M, duration)
	smoke.attach(M)
	M.smoke_system = smoke
	M.smoke_charges = initial(M.smoke_charges)

/obj/item/mecha_parts/mecha_equipment/ability/smoke/detach(atom/moveto)
	var/datum/effect_system/smoke_spread/bad/oldsmoke = new
	oldsmoke.set_up(3, chassis)
	oldsmoke.attach(chassis)
	chassis.smoke_system = oldsmoke
	return ..()

/obj/item/mecha_parts/mecha_equipment/ability/smoke/tanglefoot
	name = "tanglefoot generator"
	desc = "A tanglefoot smoke generator capable of dispensing large amounts of non-lethal gas that saps the energy from any xenoform creatures it touches."
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /datum/effect_system/smoke_spread/plasmaloss

/obj/item/mecha_parts/mecha_equipment/ability/smoke/cloak_smoke
	name = "smoke generator"
	desc = "A multiple launch module that generates a large amount of cloaking smoke to disguise nearby friendlies. Sadly, huge robots are too difficult to hide with it."
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /obj/effect/particle_effect/smoke/tactical
