/obj/item/mecha_parts/mecha_equipment/armor/melee
	name = "melee armor booster"
	desc = "Increases armor against melee attacks by 15%."
	icon_state = "armor_melee"
	iconstate_name = "armor_melee"
	protect_name = "Melee Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = 0.5
	armor_mod = list(MELEE = 15)

/obj/item/mecha_parts/mecha_equipment/armor/acid
	name = "caustic armor booster"
	desc = "Increases armor against acid attacks by 15%."
	icon_state = "armor_acid"
	iconstate_name = "armor_acid"
	protect_name = "Caustic Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = 0.4
	armor_mod = list(ACID = 15)

/obj/item/mecha_parts/mecha_equipment/armor/explosive
	name = "explosive armor booster"
	desc = "Increases armor against explosions by 50%."
	icon_state = "armor_explosive"
	iconstate_name = "armor_explosive"
	protect_name = "Explosive Armor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = 0.3
	armor_mod = list(BOMB = 50)


/obj/item/mecha_parts/mecha_equipment/generator/greyscale
	name = "phoron engine"
	desc = "An advanced Nanotrasen phoron engine core prototype designed for TGMC advanced mech exosuits. Uses solid phoron as fuel, click engine to refuel. The increased power generation comes at a cost to speed due to the weight."
	icon_state = "phoron_engine"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	rechargerate = 100
	slowdown = 0.2

/obj/item/mecha_parts/mecha_equipment/generator/greyscale/upgraded
	name = "fusion engine"
	desc = "A highly experimental phoron fusion core. Generates more power at the same consumption rate, but slows you down even more than the standard phoron engine. Uses solid phoron as fuel, click engine to refuel. Nanotrasen does not take any responsibility in case of detonation."
	icon_state = "phoron_engine_adv"
	slowdown = 0.4

/obj/item/mecha_parts/mecha_equipment/energy_optimizer
	name = "energy optimizer"
	desc = "A Nanotrasen-brand computer that uses predictive algorithms to reduce the power consumption of all steps by 75%."
	icon_state = "optimizer"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	equipment_slot = MECHA_POWER
	slowdown = 0.3

/obj/item/mecha_parts/mecha_equipment/energy_optimizer/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.normal_step_energy_drain *= 0.75
	M.step_energy_drain *= 0.75
	M.overload_step_energy_drain_min *= 0.75

/obj/item/mecha_parts/mecha_equipment/energy_control/detach(atom/moveto)
	chassis.normal_step_energy_drain /= 0.75
	chassis.step_energy_drain /= 0.75
	chassis.overload_step_energy_drain_min /= 0.75
	return ..()



/obj/item/mecha_parts/mecha_equipment/ability
	name = "generic mech ability"
	desc = "You shouldnt be seeing this"
	equipment_slot = MECHA_UTILITY
	///if given, a single flag of who we want this ability to be granted to
	var/flag_controller = NONE
	///typepath of ability we want to grant
	var/ability_to_grant
	///reference to image that is used as an overlay
	var/image/overlay

/obj/item/mecha_parts/mecha_equipment/ability/Initialize()
	. = ..()
	if(icon_state)
		overlay = image('icons/mecha/mecha_ability_overlays.dmi', icon_state = icon_state, layer = 10)

/obj/item/mecha_parts/mecha_equipment/ability/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.add_overlay(overlay)
	if(flag_controller)
		M.initialize_controller_action_type(ability_to_grant, flag_controller)
	else
		M.initialize_passenger_action_type(ability_to_grant)

/obj/item/mecha_parts/mecha_equipment/ability/detach(atom/moveto)
	chassis.cut_overlay(overlay)
	if(flag_controller)
		chassis.destroy_controller_action_type(ability_to_grant, flag_controller)
	else
		chassis.destroy_passenger_action_type(ability_to_grant)
	return ..()

/obj/item/mecha_parts/mecha_equipment/ability/dash
	name = "actuator safety override"
	desc = "A haphazard collection of electronics that allows the user to override standard safety inputs to increase speed, at the cost of extremely high power usage."
	icon_state = "booster"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_overload_mode
	///sound to loop when the dash is activated
	var/datum/looping_sound/mech_overload/sound_loop

/obj/item/mecha_parts/mecha_equipment/ability/dash/Initialize()
	. = ..()
	sound_loop = new

/obj/item/mecha_parts/mecha_equipment/ability/zoom
	name = "enhanced zoom"
	desc = "A magnifying module that allows the pilot to see much further than with the standard optics. Night vision not included."
	icon_state = "zoom"
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
	icon_state = "tfoot_gas"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /datum/effect_system/smoke_spread/plasmaloss

/obj/item/mecha_parts/mecha_equipment/ability/smoke/cloak_smoke
	name = "smoke generator"
	desc = "A multiple launch module that generates a large amount of cloaking smoke to disguise nearby friendlies. Sadly, huge robots are too difficult to hide with it."
	icon_state = "smoke_gas"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /obj/effect/particle_effect/smoke/tactical
