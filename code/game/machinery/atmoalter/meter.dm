/obj/machinery/meter
	name = "meter"
	desc = "It measures something."
	icon = 'icons/obj/meter.dmi'
	icon_state = "meterX"
	var/obj/machinery/atmospherics/pipe/target = null
	anchored = 1.0
	power_channel = ENVIRON
	var/frequency = 0
	var/id
	use_power = 1
	idle_power_usage = 15

/obj/machinery/meter/New()
	..()
	src.target = locate(/obj/machinery/atmospherics/pipe) in loc
	return 1

/obj/machinery/meter/Dispose()
	target = null
	. = ..()

/obj/machinery/meter/initialize()
	if (!target)
		src.target = locate(/obj/machinery/atmospherics/pipe) in loc

/obj/machinery/meter/process()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0


	var/env_pressure = target.return_pressure()
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
		var/datum/radio_frequency/radio_connection = radio_controller.return_frequency(frequency)

		if(!radio_connection) return

		var/datum/signal/signal = new
		signal.source = src
		signal.transmission_method = 1
		signal.data = list(
			"tag" = id,
			"device" = "AM",
			"pressure" = round(env_pressure),
			"sigtype" = "status"
		)
		radio_connection.post_signal(src, signal)

/obj/machinery/meter/examine(mob/user)
	var/t = "A gas flow meter. "

	if(get_dist(user, src) > 3 && !(istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead)))
		t += "\blue <B>You are too far away to read it.</B>"

	else if(stat & (NOPOWER|BROKEN))
		t += "\red <B>The display is off.</B>"

	else if(target)
		if(target.return_pressure())
			t += "The pressure gauge reads [round(target.return_pressure(), 0.01)] kPa; [round(target.return_temperature(),0.01)]K ([round(target.return_temperature()-T0C,0.01)]&deg;C)"
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."

	user << t

/obj/machinery/meter/clicked(var/mob/user)
	..()

	if(istype(user, /mob/living/silicon/ai)) // ghosts can call ..() for examine
		examine(user)
		return 1

/obj/machinery/meter/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if (!istype(W, /obj/item/tool/wrench))
		return ..()
	playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
	user.visible_message("<span class='notice'>[user] begins to unfasten [src].</span>",
	"<span class='notice'>You begin to unfasten [src].</span>")
	if(do_after(user, 40, TRUE, 5, BUSY_ICON_BUILD))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] unfastens [src].</span>",
		"<span class='notice'>You unfasten [src].</span>")
		new /obj/item/pipe_meter(loc)
		cdel(src)

// TURF METER - REPORTS A TILE'S AIR CONTENTS

/obj/machinery/meter/turf/New()
	..()
	src.target = loc
	return 1


/obj/machinery/meter/turf/initialize()
	if (!target)
		src.target = loc

/obj/machinery/meter/turf/attackby(var/obj/item/W as obj, var/mob/user as mob)
	return
