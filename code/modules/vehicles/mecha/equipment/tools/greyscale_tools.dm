/obj/vehicle/sealed/mecha
	/// How much energy we use per mech dash
	var/dash_power_consumption = 500
	/// dash_range
	var/dash_range = 1

/obj/item/mecha_parts/mecha_equipment/armor/booster
	name = "medium booster"
	desc = "Determines boosting speed and power. Balanced option. Sets dash consumption to 200 and dash range to 3, and boost consumption per step to 50."
	icon_state = "armor_melee"
	iconstate_name = "armor_melee"
	protect_name = "Medium Booster"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	slowdown = -2.0
	armor_mod = list()
	/// How much energy we use when we dash
	var/dash_consumption = 200
	/// How many tiles our dash carries us
	var/dash_range = 3
	/// how much energy we use per step when boosting
	var/boost_consumption = 50

/obj/item/mecha_parts/mecha_equipment/armor/booster/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	chassis.overload_step_energy_drain_min = boost_consumption
	chassis.leg_overload_coeff = 0 // forces min usage
	chassis.dash_power_consumption = dash_consumption
	chassis.dash_range = dash_range

/obj/item/mecha_parts/mecha_equipment/armor/booster/detach(atom/moveto)
	chassis.overload_step_energy_drain_min = initial(chassis.overload_step_energy_drain_min)
	chassis.leg_overload_coeff = initial(chassis.leg_overload_coeff)
	chassis.dash_power_consumption = initial(chassis.dash_power_consumption)
	chassis.dash_range = initial(chassis.dash_range)
	return ..()


/obj/item/mecha_parts/mecha_equipment/armor/booster/lightweight
	name = "lightweight booster"
	desc = "Determines boosting speed and power. Lightweight option. Sets dash consumption to 300 and dash range to 4, and boost consumption per step to 25."
	icon_state = "armor_acid"
	iconstate_name = "armor_acid"
	protect_name = "Lightweight Booster"
	dash_consumption = 300
	dash_range = 4
	boost_consumption = 25

/obj/item/mecha_parts/mecha_equipment/generator/greyscale
	name = "phoron engine"
	desc = "An advanced Nanotrasen phoron engine core prototype designed for TGMC advanced mech exosuits. Uses solid phoron as fuel, click engine to refuel. The lightest engine mechs can use at a cost of recharge rate and max fuel capacity."
	icon_state = "phoron_engine"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	rechargerate = 5
	slowdown = 0.3
	max_fuel = 30000

/obj/item/mecha_parts/mecha_equipment/generator/greyscale/upgraded
	name = "fusion engine"
	desc = "A highly experimental phoron fusion core. Generates more power at the same consumption rate, but slows you down even more than the standard phoron engine. Uses solid phoron as fuel, click engine to refuel. The heaviest engine mechs can use at a cost of speed due to weight."
	icon_state = "phoron_engine_adv"
	rechargerate = 10
	slowdown = 0.6
	max_fuel = 60000

/obj/item/mecha_parts/mecha_equipment/energy_optimizer
	name = "energy optimizer"
	desc = "A Nanotrasen-brand computer that uses predictive algorithms to reduce the power consumption of all steps by 50%."
	icon_state = "optimizer"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	equipment_slot = MECHA_POWER
	slowdown = 0.3

/obj/item/mecha_parts/mecha_equipment/energy_optimizer/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.normal_step_energy_drain *= 0.50
	M.step_energy_drain *= 0.50
	M.overload_step_energy_drain_min *= 0.50

/obj/item/mecha_parts/mecha_equipment/energy_control/detach(atom/moveto)
	chassis.normal_step_energy_drain /= 0.50
	chassis.step_energy_drain /= 0.50
	chassis.overload_step_energy_drain_min /= 0.50
	return ..()

/obj/item/mecha_parts/mecha_equipment/melee_core
	name = "melee core"
	desc = "A bluespace orion-sperkov converter. Through science you can't be bothered to understand, makes mechs faster and their weapons able to draw more power, making them more dangerous. However this comes at the cost of not being able to use projectile and laser weaponry."
	icon_state = "melee_core"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	equipment_slot = MECHA_UTILITY
	///speed amount we modify the mech by
	var/speed_mod

/obj/item/mecha_parts/mecha_equipment/melee_core/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	ADD_TRAIT(M, TRAIT_MELEE_CORE, REF(src))
	speed_mod = min(chassis.move_delay-1, round(chassis.move_delay * 0.5))
	M.move_delay -= speed_mod

/obj/item/mecha_parts/mecha_equipment/melee_core/detach(atom/moveto)
	REMOVE_TRAIT(chassis, TRAIT_MELEE_CORE, REF(src))
	chassis.move_delay += speed_mod
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

/obj/item/mecha_parts/mecha_equipment/ability/Initialize(mapload)
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
	smoke_type = /datum/effect_system/smoke_spread/tactical
