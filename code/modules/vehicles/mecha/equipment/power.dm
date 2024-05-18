/obj/item/mecha_equipment/generator
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

/obj/item/mecha_equipment/generator/Initialize(mapload)
	. = ..()
	generator_init()

/obj/item/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_equipment/generator/proc/generator_init()
	fuel = new /obj/item/stack/sheet/mineral/phoron(src, 0)

/obj/item/mecha_equipment/generator/detach()
	STOP_PROCESSING(SSobj, src)
	activated = FALSE
	return ..()

/obj/item/mecha_equipment/generator/get_snowflake_data()
	return list(
		"active" = activated,
		"fuel" = fuel.amount,
	)

/obj/item/mecha_equipment/generator/ui_act(action, list/params)
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

/obj/item/mecha_equipment/generator/attackby(weapon, mob/user, params)
	. = ..()
	if(.)
		return
	load_fuel(weapon, user)

/obj/item/mecha_equipment/generator/proc/load_fuel(obj/item/stack/sheet/P, mob/user)
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

/obj/item/mecha_equipment/generator/process(delta_time)
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
