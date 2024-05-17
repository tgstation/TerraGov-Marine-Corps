/obj/item/mecha_parts/mecha_equipment/armor
	equipment_slot = MECHA_ARMOR
	///short protection name to display in the UI
	var/protect_name = "you're mome"
	///icon in armor.dmi that shows in the UI
	var/iconstate_name
	///how much the armor of the mech is modified by
	var/list/armor_mod = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/mecha_parts/mecha_equipment/armor/attach(obj/vehicle/sealed/mecha/M, attach_right)
	. = ..()
	chassis.soft_armor = chassis.soft_armor.modifyRating(arglist(armor_mod))

/obj/item/mecha_parts/mecha_equipment/armor/detach(atom/moveto)
	var/list/removed_armor = armor_mod.Copy()
	for(var/armor_type in removed_armor)
		removed_armor[armor_type] = -removed_armor[armor_type]
	chassis.soft_armor = chassis.soft_armor.modifyRating(arglist(removed_armor))
	return ..()

/obj/item/mecha_parts/mecha_equipment/armor/melee
	name = "melee armor booster"
	desc = "Increases armor against melee attacks by 15%."
	icon_state = "armor_melee"
	iconstate_name = "armor_melee"
	protect_name = "Melee Armor"
	slowdown = 0.5
	armor_mod = list(MELEE = 15)

/obj/item/mecha_parts/mecha_equipment/armor/acid
	name = "caustic armor booster"
	desc = "Increases armor against acid attacks by 15%."
	icon_state = "armor_acid"
	iconstate_name = "armor_acid"
	protect_name = "Caustic Armor"
	slowdown = 0.4
	armor_mod = list(ACID = 15)

/obj/item/mecha_parts/mecha_equipment/armor/explosive
	name = "explosive armor booster"
	desc = "Increases armor against explosions by 25%."
	icon_state = "armor_explosive"
	iconstate_name = "armor_explosive"
	protect_name = "Explosive Armor"
	slowdown = 0.3
	armor_mod = list(BOMB = 25)

/obj/item/mecha_parts/mecha_equipment/generator
	name = "plasma engine"
	desc = "An exosuit module that generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	range = MECHA_MELEE
	equipment_slot = MECHA_POWER
	activated = FALSE
	/// axtual stack of fuel to consume
	var/obj/item/stack/sheet/fuel
	///max fuel material count allowed
	var/max_fuel = 150000
	/// Fuel used per second while idle, not generating
	var/fuelrate_idle = 5
	/// Fuel used per second while actively generating
	var/fuelrate_active = 50
	/// Energy recharged per second
	var/rechargerate = 10

/obj/item/mecha_parts/mecha_equipment/generator/Initialize(mapload)
	. = ..()
	generator_init()

/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/proc/generator_init()
	fuel = new /obj/item/stack/sheet/mineral/phoron(src, 0)

/obj/item/mecha_parts/mecha_equipment/generator/detach()
	STOP_PROCESSING(SSobj, src)
	activated = FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/get_snowflake_data()
	return list(
		"active" = activated,
		"fuel" = fuel.amount,
	)

/obj/item/mecha_parts/mecha_equipment/generator/ui_act(action, list/params)
	. = ..()
	if(action == "toggle")
		if(activated)
			to_chat(usr, "[icon2html(src, usr)][span_warning("Power generation enabled.")]")
			START_PROCESSING(SSobj, src)
			log_message("Activated.", LOG_MECHA)
		else
			to_chat(usr, "[icon2html(src, usr)][span_warning("Power generation disabled.")]")
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.", LOG_MECHA)
		return TRUE

/obj/item/mecha_parts/mecha_equipment/generator/attackby(weapon, mob/user, params)
	. = ..()
	if(.)
		return
	load_fuel(weapon, user)

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/P, mob/user)
	if(istype(P, fuel.type) && P.amount > 0)
		var/to_load = max(max_fuel - fuel.amount*MINERAL_MATERIAL_AMOUNT,0)
		if(to_load)
			var/units = min(max(round(to_load / MINERAL_MATERIAL_AMOUNT),1),P.amount)
			fuel.amount += units
			P.use(units)
			to_chat(user, "[icon2html(src, user)][span_notice("[units] unit\s of [fuel] successfully loaded.")]")
			return units
		else
			to_chat(user, "[icon2html(src, user)][span_notice("Unit is full.")]")
			return 0
	else
		to_chat(user, "[icon2html(src, user)][span_warning("[fuel] traces in target minimal! [P] cannot be used as fuel.")]")
		return

/obj/item/mecha_parts/mecha_equipment/generator/process(delta_time)
	if(!chassis)
		activated = FALSE
		return PROCESS_KILL
	if(fuel.amount<=0)
		activated = FALSE
		log_message("Deactivated - no fuel.", LOG_MECHA)
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("Fuel reserves depleted.")]")
		return PROCESS_KILL
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge))
		activated = FALSE
		to_chat(chassis.occupants, "[icon2html(src, chassis.occupants)][span_notice("No power cell detected.")]")
		log_message("Deactivated.", LOG_MECHA)
		return PROCESS_KILL
	var/use_fuel = fuelrate_idle
	if(cur_charge < chassis.cell.maxcharge)
		use_fuel = fuelrate_active
		chassis.give_power(rechargerate * delta_time)
	fuel.amount -= min(delta_time * use_fuel / MINERAL_MATERIAL_AMOUNT, fuel.amount)

/obj/item/mecha_parts/mecha_equipment/generator/greyscale
	name = "phoron engine"
	desc = "An advanced Nanotrasen phoron engine core prototype designed for TGMC advanced mech exosuits. Uses solid phoron as fuel, click engine to refuel. The lightest engine mechs can use at a cost of recharge rate and max fuel capacity."
	icon_state = "phoron_engine"
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

/obj/item/mecha_parts/mecha_equipment/ability/dash
	name = "actuator safety override"
	desc = "A haphazard collection of electronics that allows the user to override standard safety inputs to increase speed, at the cost of extremely high power usage."
	icon_state = "booster"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_overload_mode
	///sound to loop when the dash is activated
	var/datum/looping_sound/mech_overload/sound_loop

/obj/item/mecha_parts/mecha_equipment/ability/dash/Initialize(mapload)
	. = ..()
	sound_loop = new

/obj/item/mecha_parts/mecha_equipment/ability/zoom
	name = "enhanced zoom"
	desc = "A magnifying module that allows the pilot to see much further than with the standard optics. Night vision not included."
	icon_state = "zoom"
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
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /datum/effect_system/smoke_spread/plasmaloss

/obj/item/mecha_parts/mecha_equipment/ability/smoke/cloak_smoke
	name = "smoke generator"
	desc = "A multiple launch module that generates a large amount of cloaking smoke to disguise nearby friendlies. Sadly, huge robots are too difficult to hide with it."
	icon_state = "smoke_gas"
	ability_to_grant = /datum/action/vehicle/sealed/mecha/mech_smoke
	smoke_type = /datum/effect_system/smoke_spread/tactical
