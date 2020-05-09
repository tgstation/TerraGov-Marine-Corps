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
	max_integrity = 150
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 40, "acid" = 0)
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

/obj/machinery/meter/proc/status()
	if (target)
		. = "The sensor error light is blinking."
	else
		. = "The connect error light is blinking."

/obj/machinery/meter/examine(mob/user)
	..()
	to_chat(user, status())


/obj/machinery/meter/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(iswrench(I))
		return wrench_act(user, I)

/obj/machinery/meter/wrench_act(mob/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")
	if(do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
		user.visible_message(
			"[user] unfastens \the [src].",
			"<span class='notice'>You unfasten \the [src].</span>",
			"<span class='italics'>You hear ratchet.</span>")
		deconstruct()
	return TRUE

/obj/machinery/meter/deconstruct(disassembled = TRUE)
	if(!(flags_atom & NODECONSTRUCT))
		new /obj/item/pipe_meter(loc)
	return ..()


// TURF METER - REPORTS A TILE'S AIR CONTENTS
//	why are you yelling?
/obj/machinery/meter/turf

/obj/machinery/meter/turf/reattach_to_layer()
	target = loc
