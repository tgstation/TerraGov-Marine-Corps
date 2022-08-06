
// Teleporter, Wormhole generator, Gravitational catapult, Armor booster modules,
// Repair droid, Tesla Energy relay, Generators

//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////
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

/obj/item/mecha_parts/mecha_equipment/armor/anticcw_armor_booster
	name = "armor booster module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against melee attacks"
	icon_state = "mecha_abooster_ccw"
	iconstate_name = "melee"
	protect_name = "Melee Armor"
	armor_mod = list(MELEE = 15, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster
	name = "armor booster module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots."
	icon_state = "mecha_abooster_proj"
	iconstate_name = "range"
	protect_name = "Ranged Armor"
	armor_mod = list(MELEE = 0, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)


////////////////////////////////// REPAIR DROID //////////////////////////////////////////////////


/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "exosuit repair droid"
	desc = "An automated repair droid for exosuits. Scans for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	energy_drain = 50
	range = 0
	activated = FALSE
	equipment_slot = MECHA_UTILITY
	/// Repaired health per second
	var/health_boost = 0.5
	///overlay to show on the mech
	var/image/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	STOP_PROCESSING(SSobj, src)
	chassis?.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach(obj/vehicle/sealed/mecha/M, attach_right = FALSE)
	. = ..()
	droid_overlay = image(icon, icon_state = "repair_droid")
	M.add_overlay(droid_overlay)

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach()
	chassis.cut_overlay(droid_overlay)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(action != "toggle")
		return
	chassis.cut_overlay(droid_overlay)
	if(activated)
		START_PROCESSING(SSobj, src)
		droid_overlay = image(icon, icon_state = "repair_droid_a")
		log_message("Activated.", LOG_MECHA)
	else
		STOP_PROCESSING(SSobj, src)
		droid_overlay = image(icon, icon_state = "repair_droid")
		log_message("Deactivated.", LOG_MECHA)
	chassis.add_overlay(droid_overlay)


/obj/item/mecha_parts/mecha_equipment/repair_droid/process(delta_time)
	if(!chassis)
		return PROCESS_KILL
	var/h_boost = health_boost * delta_time
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost *= -2
	if(h_boost<0 || chassis.obj_integrity < chassis.max_integrity)
		chassis.repair_damage(h_boost)
		repaired = TRUE
	if(repaired)
		if(!chassis.use_power(energy_drain))
			activated = FALSE
			return PROCESS_KILL
	else //no repair needed, we turn off
		chassis.cut_overlay(droid_overlay)
		droid_overlay = image(icon, icon_state = "repair_droid")
		chassis.add_overlay(droid_overlay)
		activated = FALSE
		return PROCESS_KILL


/////////////////////////////////////////// GENERATOR /////////////////////////////////////////////


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
	var/fuelrate_idle = 12.5
	/// Fuel used per second while actively generating
	var/fuelrate_active = 100
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
	load_fuel(weapon, user)

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/P, mob/user)
	if(P.type == fuel.type && P.amount > 0)
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

/obj/item/mecha_parts/mecha_equipment/generator/attackby(weapon,mob/user, params)
	load_fuel(weapon)

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
