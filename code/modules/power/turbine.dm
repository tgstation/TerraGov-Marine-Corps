/obj/machinery/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "compressor"
	anchored = 1
	density = 1
	var/obj/machinery/power/turbine/turbine
	var/turf/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "turbine"
	anchored = 1
	density = 1
	var/obj/machinery/compressor/compressor
	directwired = 1
	var/turf/outturf
	var/lastgen

/obj/machinery/computer/turbine_computer
	name = "Gas turbine control computer"
	desc = "A computer to remotely control a gas turbine"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "turbinecomp"
	circuit = /obj/item/circuitboard/computer/turbine_control
	anchored = 1
	density = 1
	var/list/obj/machinery/compressor/compressors = list()
	var/list/obj/machinery/door/poddoor/doors = list()
	var/id = 0
	var/door_status = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/compressor/New()
	..()

	inturf = get_step(src, dir)

	spawn(5)
		for(var/dr in cardinal)
			turbine = locate() in get_step(src,dr)
			if(turbine)
				break

		if(!turbine)
			stat |= BROKEN
		else
			turbine.stat &= ~BROKEN
			turbine.compressor = src


#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800

/obj/machinery/compressor/process()
	if(!starter)
		return
	overlays.Cut()
	if(stat & BROKEN)
		return
	if(!turbine)
		stat |= BROKEN
		return
	rpm = 0.9* rpm + 0.1 * rpmtarget

	rpm = max(0, rpm - (rpm*rpm)/COMPFRICTION)


	if(starter && !(stat & NOPOWER))
		use_power(2800)
		if(rpm<1000)
			rpmtarget = 1000
	else
		if(rpm<1000)
			rpmtarget = 0



	if(rpm>50000)
		overlays += image('icons/obj/pipes.dmi', "comp-o4", FLY_LAYER)
	else if(rpm>10000)
		overlays += image('icons/obj/pipes.dmi', "comp-o3", FLY_LAYER)
	else if(rpm>2000)
		overlays += image('icons/obj/pipes.dmi', "comp-o2", FLY_LAYER)
	else if(rpm>500)
		overlays += image('icons/obj/pipes.dmi', "comp-o1", FLY_LAYER)
	 //TODO: DEFERRED

/obj/machinery/power/turbine/New()
	..()

	outturf = get_step(src, dir)

	spawn(5)
		for(var/dr in cardinal)
			compressor = locate() in get_step(src,dr)
			if(compressor)
				break

		if(!compressor)
			stat |= BROKEN
		else
			compressor.stat &= ~BROKEN
			compressor.turbine = src


#define TURBPRES 9000000
#define TURBGENQ 20000
#define TURBGENG 0.8

/obj/machinery/power/turbine/process()
	if(!compressor)
		stat |= BROKEN
		return
	if(!compressor.starter)
		return
	overlays.Cut()
	if(stat & BROKEN)
		return
	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) *TURBGENQ

	add_avail(lastgen)

	if(lastgen > 100)
		overlays += image('icons/obj/pipes.dmi', "turb-o", FLY_LAYER)


	for(var/mob/M in viewers(1, src))
		if ((M.client && M.interactee == src))
			attack_hand(M)
	AutoUpdateAI(src)

/obj/machinery/power/turbine/attack_hand(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (NOPOWER|BROKEN)) && (!istype(user, /mob/living/silicon/ai)) )
		user.unset_interaction()
		user << browse(null, "window=turbine")
		return

	user.set_interaction(src)

	var/t = "<TT><B>Gas Turbine Generator</B><HR><PRE>"

	t += "Generated power : [round(lastgen)] W<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user << browse(t, "window=turbine")
	onclose(user, "turbine")

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	..()
	if(stat & BROKEN)
		return
	if (usr.is_mob_incapacitated() || usr.is_mob_restrained() )
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		if(!istype(usr, /mob/living/silicon/ai))
			usr << "\red You don't have the dexterity to do this!"
			return

	if (( usr.interactee==src && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))


		if( href_list["close"] )
			usr << browse(null, "window=turbine")
			usr.unset_interaction()
			return

		else if( href_list["str"] )
			compressor.starter = !compressor.starter

		spawn(0)
			for(var/mob/M in viewers(1, src))
				if ((M.client && M.interactee == src))
					src.interact(M)

	else
		usr << browse(null, "window=turbine")
		usr.unset_interaction()

	return





/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/computer/turbine_computer/New()
	..()
	spawn(5)
		for(var/obj/machinery/compressor/C in machines)
			if(id == C.comp_id)
				compressors += C
		for(var/obj/machinery/door/poddoor/P in machines)
			if(P.id == id)
				doors += P

/*
/obj/machinery/computer/turbine_computer/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/tool/screwdriver))
		playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				new /obj/item/shard( src.loc )
				var/obj/item/circuitboard/computer/turbine_control/M = new /obj/item/circuitboard/computer/turbine_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.anchored = 1
				cdel(src)
			else
				user << "\blue You disconnect the monitor."
				var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
				var/obj/item/circuitboard/computer/turbine_control/M = new /obj/item/circuitboard/computer/turbine_control( A )
				for (var/obj/C in src)
					C.loc = src.loc
				M.id = src.id
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.anchored = 1
				cdel(src)
	else
		src.attack_hand(user)
	return
*/

/obj/machinery/computer/turbine_computer/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/turbine_computer/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/turbine_computer/attack_hand(mob/user as mob)
	user.set_interaction(src)
	var/dat
	var/turbineav = 0
	var/gastempav = 0
	var/rpmav = 0
	var/i = 1
	var/started = 0

	if(compressors.len)
		for(var/obj/machinery/compressor/C in compressors)
			if(!istype(C)) //What the
				compressors.Remove(C)
				continue

			if(C.turbine)
				turbineav += C.turbine.lastgen

			rpmav += C.rpm
			i++
			started = C.starter

		if(!i) i = 1 //i cannot ever be 0
		gastempav = gastempav / i
		rpmav = rpmav / i

		dat += {"<BR><B>Gas turbine remote control system</B><HR>
		\nTurbine status: [started ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]
		\n<BR>
		\nTurbine average: [rpmav]rpm<BR>
		\nPower currently being generated: [turbineav]W<BR>
		\nInternal gas temperature: [gastempav]K<BR>
		\nVent doors: [ src.door_status ? "<A href='?src=\ref[src];doors=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];doors=1'>Open</A>"]
		\n</PRE><HR><A href='?src=\ref[src];view=1'>View</A>
		\n</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>
		\n<BR>
		\n"}
	else
		dat += "\red<B>No compatible attached compressor found."

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")
	return



/obj/machinery/computer/turbine_computer/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_interaction(src)

		if( href_list["view"] )
			if(compressors.len)
				for(var/obj/machinery/compressor/C in compressors)
					usr.client.eye = C
					break
		else if( href_list["str"] )
			if(compressors.len)
				for(var/obj/machinery/compressor/C in compressors)
					C.starter = !C.starter
		else if (href_list["doors"])
			for(var/obj/machinery/door/poddoor/D in src.doors)
				if (door_status == 0)
					spawn( 0 )
						D.open()
						door_status = 1
				else
					spawn( 0 )
						D.close()
						door_status = 0
		else if( href_list["close"] )
			usr << browse(null, "window=computer")
			usr.unset_interaction()
			return

		src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return