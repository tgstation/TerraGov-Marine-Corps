/obj/item/mecha_parts/mecha_equipment/armor/booster
	name = "medium booster"
	desc = "Determines boosting speed and power. Balanced option. Sets dash consumption to 200 and dash range to 3, and boost consumption per step to 50."
	icon_state = "armor_melee"
	iconstate_name = "armor_melee"
	protect_name = "Medium Booster"
	mech_flags = EXOSUIT_MODULE_GREYSCALE|EXOSUIT_MODULE_VENDABLE
	armor_mod = list()
	slowdown = 0
	weight = 65
	///move delay we remove from the mech when sprinting with actuator overload
	var/speed_mod = 1
	/// How much energy we use when we dash
	var/dash_consumption = 200
	/// How many tiles our dash carries us
	var/dash_range = 3
	/// how much energy we use per step when boosting
	var/boost_consumption = 55
	///cooldown between dash activations
	var/dash_cooldown = 4 SECONDS

/obj/item/mecha_parts/mecha_equipment/armor/booster/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	chassis.overload_step_energy_drain_min = boost_consumption
	chassis.leg_overload_coeff = 0 // forces min usage
	chassis.dash_power_consumption = dash_consumption
	chassis.dash_range = dash_range
	chassis.speed_mod = speed_mod
	chassis.dash_cooldown = dash_cooldown

/obj/item/mecha_parts/mecha_equipment/armor/booster/detach(atom/moveto)
	chassis.overload_step_energy_drain_min = initial(chassis.overload_step_energy_drain_min)
	chassis.leg_overload_coeff = initial(chassis.leg_overload_coeff)
	chassis.dash_power_consumption = initial(chassis.dash_power_consumption)
	chassis.dash_range = initial(chassis.dash_range)
	chassis.speed_mod = 0
	chassis.dash_cooldown = initial(chassis.dash_cooldown)
	return ..()


/obj/item/mecha_parts/mecha_equipment/armor/booster/lightweight
	name = "lightweight booster"
	desc = "Determines boosting speed and power. Lightweight option. Sets dash consumption to 300 and dash range to 4, and boost consumption per step to 25. Provides about half the speed boost."
	icon_state = "armor_acid"
	iconstate_name = "armor_acid"
	protect_name = "Lightweight Booster"
	weight = 30
	dash_consumption = 300
	speed_mod = 0.5
	dash_range = 5
	boost_consumption = 35
	dash_cooldown = 7 SECONDS

/obj/item/mecha_parts/mecha_equipment/generator/greyscale
	name = "phoron engine"
	desc = "An advanced Nanotrasen phoron engine core prototype designed for TGMC advanced mech exosuits. Optimimized for energy storage."
	icon_state = "phoron_engine"
	mech_flags = EXOSUIT_MODULE_GREYSCALE|EXOSUIT_MODULE_VENDABLE
	rechargerate = 0
	slowdown = 0
	max_fuel = 0
	weight = 180
	/// cell type to attach. this does the actual passive energy regen, if we have it
	var/cell_type = /obj/item/cell/mecha

/obj/item/mecha_parts/mecha_equipment/generator/greyscale/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	M.add_cell(new cell_type)

/obj/item/mecha_parts/mecha_equipment/generator/greyscale/detach(atom/moveto)
	chassis.add_cell() //replaces with a standard high cap that does not have built in recharge
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/greyscale/heavy
	name = "fusion engine"
	desc = "A highly experimental phoron fusion core. Optimized for energy generation."
	icon_state = "phoron_engine_adv"
	weight = 110
	cell_type = /obj/item/cell/mecha/medium

/obj/item/mecha_parts/mecha_equipment/melee_core
	name = "melee core"
	desc = "A bluespace orion-sperkov converter. Through science you can't be bothered to understand, makes mechs faster and their weapons able to draw more power, making them more dangerous. However this comes at the cost of not being able to use projectile and laser weaponry."
	icon_state = "melee_core"
	mech_flags = EXOSUIT_MODULE_GREYSCALE
	equipment_slot = MECHA_UTILITY

/obj/item/mecha_parts/mecha_equipment/melee_core/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	ADD_TRAIT(M, TRAIT_MELEE_CORE, REF(src))

/obj/item/mecha_parts/mecha_equipment/melee_core/detach(atom/moveto)
	REMOVE_TRAIT(chassis, TRAIT_MELEE_CORE, REF(src))
	return ..()


/obj/item/mecha_parts/mecha_equipment/ability
	name = "generic mech ability"
	desc = "You shouldnt be seeing this"
	equipment_slot = MECHA_UTILITY
	///if given, a single flag of who we want this ability to be granted to
	var/flag_controller = NONE
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

/obj/item/mecha_parts/mecha_equipment/ability/assault_armor
	name = "assault armor"
	desc = "A laser core that allows a core purge to emit a burst of lasers around the mecha. Slows mecha while charging."
	weight = 80
	icon_state = "assaultarmor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE|EXOSUIT_MODULE_VENDABLE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/assault_armor

/obj/item/mecha_parts/mecha_equipment/ability/cloak
	name = "cloak module"
	desc = "A mech stealth cloaking device. Cannot fire while cloaked, and cloaking drains energy."
	weight = 70
	icon_state = "cloak"
	mech_flags = EXOSUIT_MODULE_GREYSCALE|EXOSUIT_MODULE_VENDABLE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/cloak

/obj/item/mecha_parts/mecha_equipment/ability/overboost
	name = "overboost module"
	desc = "A mech overboost device. Allows overloading the leg accumulators to dash in a direction, throwing back anyone hit by the mech."
	weight = 70
	icon_state = "overboost"
	mech_flags = EXOSUIT_MODULE_GREYSCALE|EXOSUIT_MODULE_VENDABLE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/overboost

/obj/item/mecha_parts/mecha_equipment/ability/pulsearmor
	name = "pulse armor module"
	desc = "A mech module that when activated, creates a shield that slowly decays. Costs energy to activate."
	weight = 70
	icon_state = "pulsearmor"
	mech_flags = EXOSUIT_MODULE_GREYSCALE|EXOSUIT_MODULE_VENDABLE
	ability_to_grant = /datum/action/vehicle/sealed/mecha/pulsearmor
