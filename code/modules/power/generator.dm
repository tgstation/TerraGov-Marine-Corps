
/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	density = TRUE
	anchored = FALSE

	use_power = IDLE_POWER_USE
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/obj/machinery/atmospherics/components/binary/circulator/circ1
	var/obj/machinery/atmospherics/components/binary/circulator/circ2

	var/lastgen = 0
	var/lastgenlev = -1

/obj/machinery/power/generator/Initialize(mapload)
	. = ..()

	reconnect()
	start_processing()

//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/generator/proc/reconnect()
	circ1 = null
	circ2 = null
	if(src.loc && anchored)
		if(src.dir & (EAST|WEST))
			circ1 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,EAST)
			circ2 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,WEST)

			if(circ1 && circ2)
				if(circ1.dir != SOUTH || circ2.dir != NORTH)
					circ1 = null
					circ2 = null

		else if(src.dir & (NORTH|SOUTH))
			circ1 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,NORTH)
			circ2 = locate(/obj/machinery/atmospherics/components/binary/circulator) in get_step(src,SOUTH)

			if(circ1 && circ2 && (circ1.dir != EAST || circ2.dir != WEST))
				circ1 = null
				circ2 = null

/obj/machinery/power/generator/update_overlays()
	. = ..()
	if(lastgenlev != 0)
		. += image('icons/obj/power.dmi', "teg-op[lastgenlev]")

/obj/machinery/power/generator/process()
	if(!circ1 || !circ2 || !anchored || machine_stat & (BROKEN|NOPOWER))
		return

	updateUsrDialog()

	// update icon overlays and power usage only if displayed level has changed
	if(lastgen > 250000 && prob(10))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(3, 1, src)
		s.start()
		lastgen *= 0.5
	var/genlev = max(0, min( round(11*lastgen / 250000), 11))
	if(lastgen > 100 && genlev == 0)
		genlev = 1
	if(genlev != lastgenlev)
		lastgenlev = genlev
		update_icon()
	add_avail(lastgen)


/obj/machinery/power/generator/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswrench(I))
		anchored = !anchored
		to_chat(user, span_notice("You [anchored ? "secure" : "unsecure"] the bolts holding [src] to the floor."))
		use_power = anchored
		reconnect()


/obj/machinery/power/generator/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat

	if(circ1 && circ2)
		dat += "Output : [round(lastgen)] W<BR><BR>"
	else
		dat += "Unable to connect to circulators.<br>"
		dat += "Ensure both are in position and wrenched into place."

	var/datum/browser/popup = new(user, "teg", "<div align='center'>Thermo-Electric Generator</div>", 460, 300)
	popup.set_content(dat)
	popup.open()


/obj/machinery/power/generator/verb/rotate_clock()
	set category = "IC.Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	setDir(turn(src.dir, 90))

/obj/machinery/power/generator/verb/rotate_anticlock()
	set category = "IC.Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.stat || usr.restrained()  || anchored)
		return

	setDir(turn(src.dir, -90))
