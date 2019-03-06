/obj/machinery/meter
	name = "gas flow meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	layer = GAS_PUMP_LAYER
	power_channel = ENVIRON
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	//max_integrity = 150
	//armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 0)
	var/frequency = 0
	var/atom/target
	var/id_tag
	var/target_layer = PIPING_LAYER_DEFAULT

/obj/machinery/meter/Destroy()
	SSair.atmos_machinery -= src
	target = null
	return ..()

/obj/machinery/meter/Initialize(mapload, new_piping_layer)
	if(!isnull(new_piping_layer))
		target_layer = new_piping_layer
	SSair.atmos_machinery += src
	if(!target)
		reattach_to_layer()
	return ..()

/obj/machinery/meter/proc/reattach_to_layer()
	var/obj/machinery/atmospherics/candidate
	for(var/obj/machinery/atmospherics/pipe/pipe in loc)
		if(pipe.piping_layer == target_layer)
			candidate = pipe
			if(pipe.level == 2)
				break
	if(candidate)
		target = candidate
		setAttachLayer(candidate.piping_layer)

/obj/machinery/meter/proc/setAttachLayer(new_layer)
	target_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, target_layer)
/*
/obj/machinery/meter/process_atmos()
	if(!target)
		icon_state = "meterX"
		return 0

	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(frequency)
		var/datum/radio_frequency/radio_connection = SSradio.return_frequency(frequency)

		if(!radio_connection)
			return

		var/datum/signal/signal = new(list(
			"id_tag" = id_tag,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		))
		radio_connection.post_signal(src, signal)
*/
/obj/machinery/meter/proc/status()
	if (target)
//		var/datum/gas_mixture/environment = target.return_air()
//		if(environment)
//			. = "The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature,0.01)] K ([round(environment.temperature-T0C,0.01)]&deg;C)."
//		else
		. = "The sensor error light is blinking."
	else
		. = "The connect error light is blinking."

/obj/machinery/meter/examine(mob/user)
	..()
	to_chat(user, status())

/obj/machinery/meter/attackby(obj/item/W, mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.is_mob_incapacitated())
		return FALSE
	if(iswrench(W))
		. = wrench_act(user, W)
	if(!.)
		return ..()

/obj/machinery/meter/proc/wrench_act(mob/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
		user.visible_message(
			"[user] unfastens \the [src].",
			"<span class='notice'>You unfasten \the [src].</span>",
			"<span class='italics'>You hear ratchet.</span>")
		deconstruct()
	return TRUE

/obj/machinery/meter/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
		new /obj/item/pipe_meter(loc)
	qdel(src)

/obj/machinery/meter/interact(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	else
		to_chat(user, status())

// TURF METER - REPORTS A TILE'S AIR CONTENTS
//	why are you yelling?
/obj/machinery/meter/turf

/obj/machinery/meter/turf/reattach_to_layer()
	target = loc
