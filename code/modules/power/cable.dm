// attach a wire to a power machine - leads from the turf you are standing on

/obj/machinery/power/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/stack/cable_coil))

		var/obj/item/stack/cable_coil/coil = W

		var/turf/T = user.loc

		if(T.intact_tile || !istype(T, /turf/open/floor))
			return

		if(get_dist(src, user) > 1)
			return

		if(!directwired)		// only for attaching to directwired machines
			return

		coil.turf_place(T, user)
		return
	else
		..()
	return

// the power cable object
/obj/structure/cable
	level = 1
	anchored =1
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond_white.dmi'
	icon_state = "0-1"
	var/d1 = 0
	var/d2 = 1
	layer = WIRE_LAYER
	color = COLOR_RED
	var/obj/machinery/power/breakerbox/breaker_box
	explosion_resistance = 150 //Fixes ground map stuff. Can't have them blow up all the time.
	unacidable = 1
	var/id

/obj/structure/cable/yellow
	color = "#ffe28a"

/obj/structure/cable/green
	color = "#589471"

/obj/structure/cable/blue
	color = "#a8c1dd"

/obj/structure/cable/pink
	color = "#6fcb9f"

/obj/structure/cable/orange
	color = "#ff9845"

/obj/structure/cable/cyan
	color = "#a8c1dd"

/obj/structure/cable/white
	color = "#666547"

/obj/structure/cable/New()
	..()


	// ensure d1 & d2 reflect the icon_state for entering and exiting cable

	var/dash = findtext(icon_state, "-")

	d1 = text2num( copytext( icon_state, 1, dash ) )

	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = src.loc			// hide if turf is not intact

	if(level==1) hide(T.intact_tile)
	cable_list += src
	update_icon()


/obj/structure/cable/Dispose()					// called when a cable is deleted
	if(!defer_powernet_rebuild)					// set if network will be rebuilt manually
		if(powernet)
			powernet.cut_cable(src)				// update the powernets
	cable_list -= src
	. = ..()									// then go ahead and delete the cable

/obj/structure/cable/hide(var/i)

	if(level == 1 && istype(loc, /turf))
		invisibility = i ? 101 : 0
	updateicon()

/obj/structure/cable/proc/updateicon()
	icon_state = "[d1]-[d2]"
	alpha = invisibility ? 127 : 255


// returns the powernet this cable belongs to
/obj/structure/cable/proc/get_powernet()			//TODO: remove this as it is obsolete
	return powernet

/obj/structure/cable/attack_tk(mob/user)
	return

/obj/structure/cable/attackby(obj/item/W, mob/user)

	var/turf/T = src.loc
	if(T.intact_tile)
		return

	if(istype(W, /obj/item/tool/wirecutters))

///// Z-Level Stuff
		if(src.d1 == 12 || src.d2 == 12)
			user << "<span class='warning'>You must cut this cable from above.</span>"
			return

		if(src.d1 == 11 || src.d2 == 11)
			return

		if(src.d1 == 12 || src.d2 == 12)
			return

///// Z-Level Stuff

		if(breaker_box)
			user << "\red This cable is connected to nearby breaker box. Use breaker box to interact with it."
			return

		if (shock(user, 50))
			return

		if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
			new/obj/item/stack/cable_coil(T, 2, color)
		else
			new/obj/item/stack/cable_coil(T, 1, color)

		for(var/mob/O in viewers(src, null))
			O.show_message("<span class='warning'>[user] cuts the cable.</span>", 1)
		log_admin("[key_name(user)] cut a wire at ([x],[y],[z])")
		message_admins("[key_name(user)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) cut a wire at ([x],[y],[z]) - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>")

		cdel(src)

		return	// not needed, but for clarity


	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/device/multitool))

		var/datum/powernet/PN = get_powernet()		// find the powernet

		if(PN && (PN.avail > 0))		// is it powered?
			user << "<span class='warning'>[PN.avail]W in power network.</span>"

		else
			user << "<span class='warning'>The cable is not powered.</span>"

		shock(user, 5, 0.2)

	else
		if (W.flags_atom & CONDUCT)
			shock(user, 50, 0.7)

	src.add_fingerprint(user)

// shock the user with probability prb

/obj/structure/cable/proc/shock(mob/user, prb, var/siemens_coeff = 1.0)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0

/obj/structure/cable/ex_act(severity)
	if(src.z == 1 && layer < 2) //ground map - no blowie. They are buried underground.
		return

	if(src.d1 == 11 || src.d2 == 11)
		return

	if(src.d1 == 12 || src.d2 == 12)
		return

	switch(severity)
		if(1.0)
			cdel(src)
		if(2.0)
			if (prob(50))
				new/obj/item/stack/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				cdel(src)

		if(3.0)
			if (prob(25))
				new/obj/item/stack/cable_coil(src.loc, src.d1 ? 2 : 1, color)
				cdel(src)
	return


/obj/structure/cable/proc/mergeConnectedNetworks(var/direction)
	var/turf/TB
	if(!(d1 == direction || d2 == direction))
		return
	TB = get_step(src, direction)

	for(var/obj/structure/cable/TC in TB)

		if(!TC)
			continue

		if(src == TC)
			continue

		var/fdir = (!direction)? 0 : turn(direction, 180)

		if(TC.d1 == fdir || TC.d2 == fdir)

			if(!TC.powernet)
				TC.powernet = new()
				powernets += TC.powernet
				TC.powernet.cables += TC

			if(powernet)
				merge_powernets(powernet,TC.powernet)
			else
				powernet = TC.powernet
				powernet.cables += src




/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	if(!powernet)
		powernet = new()
		powernets += powernet
		powernet.cables += src

	for(var/AM in loc)
		if(istype(AM,/obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.powernet == powernet)	continue
			if(C.d2 != d1 && C.d2 != d2 && C.d1 != d1 && C.d1 != d2) //not connected if they have no common direction
				continue
			if(C.powernet)
				merge_powernets(powernet, C.powernet)
			else
				C.powernet = powernet
				powernet.cables += C

		else if(istype(AM,/obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)	continue
			if(N.terminal.powernet)
				merge_powernets(powernet, N.terminal.powernet)
			else
				N.terminal.powernet = powernet
				powernet.nodes[N.terminal] = N.terminal

		else if(istype(AM,/obj/machinery/power))
			var/obj/machinery/power/M = AM
			if(M.powernet == powernet)	continue
			if(M.powernet)
				merge_powernets(powernet, M.powernet)
			else
				M.powernet = powernet
				powernet.nodes[M] = M


obj/structure/cable/proc/cableColor(var/colorC)
	var/color_n = "#DD0000"
	if(colorC)
		color_n = colorC
	color = color_n
