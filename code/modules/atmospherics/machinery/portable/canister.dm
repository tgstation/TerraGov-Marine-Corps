#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon_state = "yellow"
	density = TRUE

	var/valve_open = FALSE
	var/obj/machinery/atmospherics/components/binary/passive_gate/pump
	var/release_log = ""

	volume = 1000
	var/filled = 0.5
	var/gas_type
	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)

	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, BIO = 100, "rad" = 100, FIRE = 80, ACID = 50)
	max_integrity = 250
	var/temperature_resistance = 1000 + T0C
	var/starter_temp
	// Prototype vars
	var/prototype = FALSE
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	var/restricted = FALSE
	req_access = list()

	var/update = 0


/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "n2 canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	icon_state = "red"
	gas_type = GAS_TYPE_NITROGEN

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "o2 canister"
	desc = "Oxygen. Necessary for human life."
	icon_state = "blue"
	gas_type = GAS_TYPE_OXYGEN

/obj/machinery/portable_atmospherics/canister/air
	name = "air canister"
	desc = "Pre-mixed air."
	icon_state = "grey"
	gas_type = GAS_TYPE_AIR

/obj/machinery/portable_atmospherics/canister/empty


/obj/machinery/portable_atmospherics/canister/Destroy()
	QDEL_NULL(pump)
	return ..()

/obj/machinery/portable_atmospherics/canister/update_icon()
	if(machine_stat & BROKEN)
		cut_overlays()
		icon_state = "[icon_state]-1"
		return

	var/last_update = update
	update = 0

	if(holding)
		update |= HOLDING
	if(connected_port)
		update |= CONNECTED

	if(update == last_update)
		return

	cut_overlays()
	if(update & HOLDING)
		add_overlay("can-open")
	if(update & CONNECTED)
		add_overlay("can-connector")
	if(update & LOW)
		add_overlay("can-o0")
	else if(update & MEDIUM)
		add_overlay("can-o1")
	else if(update & FULL)
		add_overlay("can-o2")
	else if(update & DANGER)
		add_overlay("can-o3")
#undef HOLDING
#undef CONNECTED
#undef EMPTY
#undef LOW
#undef MEDIUM
#undef FULL
#undef DANGER


/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
		if(!(machine_stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	return ..()


/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	machine_stat |= BROKEN
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
	update_icon()
