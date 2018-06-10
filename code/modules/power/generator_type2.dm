/obj/machinery/power/generator_type2
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1
	use_power = 0

	var/obj/machinery/atmospherics/unary/generator_input/input1
	var/obj/machinery/atmospherics/unary/generator_input/input2

	var/lastgen = 0
	var/lastgenlev = -1


/obj/machinery/power/generator_type2/New()
	..()
	spawn(5)
		input1 = locate(/obj/machinery/atmospherics/unary/generator_input) in get_step(src,turn(dir, 90))
		input2 = locate(/obj/machinery/atmospherics/unary/generator_input) in get_step(src,turn(dir, -90))
		if(!input1 || !input2)
			stat |= BROKEN
		updateicon()
		start_processing()


/obj/machinery/power/generator_type2/proc/updateicon()

	if(stat & (NOPOWER|BROKEN))
		overlays.Cut()
	else
		overlays.Cut()

		if(lastgenlev != 0)
			overlays += image('icons/obj/power.dmi', "teg-op[lastgenlev]")

#define GENRATE 800		// generator output coefficient from Q


/obj/machinery/power/generator_type2/process()
	if(!input1 || !input2)
		return

	lastgen = 0

	var/genlev = max(0, min( round(11*lastgen / 100000), 11))
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()

	src.updateDialog()


/obj/machinery/power/generator_type2/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)


/obj/machinery/power/generator_type2/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)


/obj/machinery/power/generator_type2/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!istype(user, /mob/living/silicon/ai)))
		user.unset_interaction()
		user << browse(null, "window=teg")
		return

	user.set_interaction(src)

	var/t = "<PRE><B>Thermo-Electric Generator</B><HR>"

	t += "Output : [round(lastgen)] W<BR><BR>"

	t += "<B>Cold loop</B><BR>"
	t += "Temperature: [round(input1.temperature, 0.1)] K<BR>"
	t += "Pressure: [round(input1.pressure, 0.1)] kPa<BR>"

	t += "<B>Hot loop</B><BR>"
	t += "Temperature: [round(input2.temperature, 0.1)] K<BR>"
	t += "Pressure: [round(input2.pressure, 0.1)] kPa<BR>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</PRE>"
	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1


/obj/machinery/power/generator_type2/Topic(href, href_list)
	..()

	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.unset_interaction()
		return 0

	return 1


/obj/machinery/power/generator_type2/power_change()
	..()
	updateicon()
