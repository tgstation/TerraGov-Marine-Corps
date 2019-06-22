GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = "#ffff00",
	"green" = "#00aa00",
	"blue" = "#1919c8",
	"pink" = "#ff3cc8",
	"orange" = "#ff8000",
	"cyan" = "#00ffff",
	"white" = "#ffffff",
	"red" = "#ff0000"
))

// the power cable object

/* Cable directions (d1 and d2)

//  9   1   5
//    \ | /
//  8 - 0 - 4
//    / | \
//  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/cable
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer"
	icon = 'icons/obj/power_cond_white.dmi'
	icon_state = "0-1"
	level = 1
	layer = WIRE_LAYER
	anchored = TRUE
	resistance_flags = UNACIDABLE

	var/datum/powernet/powernet
	var/obj/item/stack/cable_coil/stored

	var/d1 = CABLE_NODE
	var/d2 = NORTH
	var/cable_color = "red"
	var/id //used for up/down cables
	//var/obj/machinery/power/breakerbox/breaker_box



/obj/structure/cable/yellow
	cable_color = "yellow"
	color = "#ffe28a"

/obj/structure/cable/green
	cable_color = "green"
	color = "#589471"

/obj/structure/cable/blue
	cable_color = "blue"
	color = "#a8c1dd"

/obj/structure/cable/pink
	cable_color = "pink"
	color = "#6fcb9f"

/obj/structure/cable/orange
	cable_color = "orange"
	color = "#ff9845"

/obj/structure/cable/cyan
	cable_color = "cyan"
	color = "#a8c1dd"

/obj/structure/cable/white
	cable_color = "white"
	color = "#666547"

/obj/structure/cable/Initialize(mapload, param_color)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num( copytext( icon_state, 1, dash ) )
	d2 = text2num( copytext( icon_state, dash+1 ) )

	var/turf/T = get_turf(src)			// hide if turf is not intact
	if(level==1)
		hide(T.intact_tile)
	SSmachines.cable_list += src //add it to the global cable list
	if(d2 == UP_OR_DOWN)
		SSmachines.zlevel_cables += src

	var/list/cable_colors = GLOB.cable_colors
	cable_color = param_color || cable_color || pick(cable_colors)
	if(cable_colors[cable_color])
		color = cable_colors[cable_color]

	if(d1 != CABLE_NODE)
		stored = new/obj/item/stack/cable_coil(null,2,cable_color)
	else
		stored = new/obj/item/stack/cable_coil(null,1,cable_color)

	update_icon()

/obj/structure/cable/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets

	SSmachines.cable_list -= src				//remove it from global cable list
	if(d2 == UP_OR_DOWN)
		SSmachines.zlevel_cables -= src

	return ..() // then go ahead and delete the cable

/obj/structure/cable/proc/deconstruct(disassembled = TRUE)
	if(d1 == UP_OR_DOWN || d2 == UP_OR_DOWN)
		return
	var/turf/T = loc
	stored.forceMove(T)
	qdel(src)

///////////////////////////////////
// General procedures
///////////////////////////////////

//If underfloor, hide the cable
/obj/structure/cable/hide(i)

	if(level == 1 && isturf(loc))
		invisibility = i ? INVISIBILITY_MAXIMUM : 0
	update_icon()

/obj/structure/cable/update_icon()
	icon_state = "[d1]-[d2]"
	color = GLOB.cable_colors[cable_color]

/obj/structure/cable/proc/handlecable(obj/item/I, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact_tile)
		return

	if(iswirecutter(I))
		/*if(breaker_box)
			to_chat(user, "<span class='warning'>This cable is connected to nearby breaker box. Use breaker box to interact with it.</span>")
			return*/

		if(d1 == UP_OR_DOWN || d2 == UP_OR_DOWN)
			to_chat(user,"<span class='warning'>Despite your best efforts, you can't even make a dent on this cable heavy coating.</span>")
			return

		if (shock(user, 50))
			return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		deconstruct()
		return

	else if(iscablecoil(I))
		var/obj/item/stack/cable_coil/coil = I
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	else if(ismultitool(I))
		if(powernet && (powernet.avail > 0))		// is it powered?
			to_chat(user, "<span class='danger'>Total power: [powernet.avail]\nLoad: [powernet.load]\nExcess power: [surplus()]</span>")
			//to_chat(user, "<span class='danger'>Total power: [DisplayPower(powernet.avail)]\nLoad: [DisplayPower(powernet.load)]\nExcess power: [DisplayPower(surplus())]</span>")
		else
			to_chat(user, "<span class='danger'>The cable is not powered.</span>")

	if (I.flags_atom & CONDUCT)
		shock(user, 5, 0.7)


// Items usable on a cable :
/obj/structure/cable/attackby(obj/item/I, mob/user, params)
	handlecable(I, user, params)

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return FALSE
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		//do_sparks(5, TRUE, src)
		return TRUE
	else
		return FALSE

/obj/structure/cable/proc/update_stored(length = 1, colorC = "red")
	stored.amount = length
	stored.color = GLOB.cable_colors[colorC]
	stored.item_color = colorC
	stored.update_icon()

/obj/structure/cable/ex_act(severity)
	if(is_ground_level(z) && layer < 2) //ground map - no blowie. They are buried underground.
		return

	if(d1 == UP_OR_DOWN || d2 == UP_OR_DOWN)
		return

	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if (prob(50))
				new/obj/item/stack/cable_coil(loc, d1 ? 2 : 1, cable_color)
				qdel(src)

		if(3.0)
			if (prob(25))
				new/obj/item/stack/cable_coil(loc, d1 ? 2 : 1, cable_color)
				qdel(src)

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return CLAMP(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail()
	if(powernet)
		return powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return CLAMP(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/cable/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	//then from the second direction component (east/west)
	for(var/flipflag in list(NORTH|SOUTH, EAST|WEST))
		var/turf/T  = get_step(src, direction & flipflag)

		for(var/obj/structure/cable/C in T)

			if(!C || src == C)
				continue

			if(C.d1 == (direction ^ flipflag) || C.d2 == (direction ^ flipflag)) //we've got a diagonally matching cable
				if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
					var/datum/powernet/newPN = new()
					newPN.add_cable(C)

				if(powernet) //if we already have a powernet, then merge the two powernets
					merge_powernets(powernet,C.powernet)
				else
					C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : turn(direction, 180) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C || src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(iscable(AM))
			var/obj/structure/cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(isAPC(AM))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet)
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(ispowermachinery(AM)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = TRUE, will only get connections without powernet
/obj/structure/cable/proc/get_connections(powernetless_only = FALSE)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step(src, d1)
		if(T)
			. += power_list(T, src, turn(d1, 180), powernetless_only) //get adjacents matching cables

	if(ISDIAGONALDIR(d1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step(src,NSCOMPONENT(d1)) // go north/south
		if(T)
			. += power_list(T, src, NSDIRFLIP(d1), powernetless_only) //get diagonally matching cables
		T = get_step(src,EWCOMPONENT(d1)) // go east/west
		if(T)
			. += power_list(T, src, EWDIRFLIP(d1), powernetless_only) //get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	//ZLevel check
	if(d2 == UP_OR_DOWN)
		if(id)
			for(var/obj/structure/cable/C in SSmachines.zlevel_cables)
				if(C == src)
					continue
				if(id == C.id && d2 == UP_OR_DOWN)
					T = get_turf(C)
					if(T)
						. += power_list(T, src, UP_OR_DOWN, powernetless_only)
					break
	//(x,y) directions
	else
		T = get_step(src, d2)
		if(T)
			. += power_list(T, src, turn(d2, 180), powernetless_only) //get adjacents matching cables

		if(ISDIAGONALDIR(d2)) //diagonal direction, must check the 4 possibles adjacents tiles
			T = get_step(src,NSCOMPONENT(d2)) // go north/south
			if(T)
				. += power_list(T, src, NSDIRFLIP(d2), powernetless_only) //get diagonally matching cables
			T = get_step(src,EWCOMPONENT(d2)) // go east/west
			if(T)
				. += power_list(T, src, EWDIRFLIP(d1), powernetless_only) //get diagonally matching cables
		. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,CABLE_NODE,FALSE) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

/obj/structure/cable/proc/auto_propagate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/powernet/newPN = new()// creates a new powernet...
		propagate_network(O, newPN)//... and propagates it to the other side of the cable

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step(T1, d1)
		P_list = power_list(T1, src, turn(d1,180),FALSE,cable_only = TRUE)	// what adjacently joins on to cut cable...

	P_list += power_list(loc, src, d1, FALSE, cable_only = TRUE)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		loc = null
	powernet.remove_cable(src) //remove the cut cable from its powernet

	addtimer(CALLBACK(O, .proc/auto_propagate_cut_cable, O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

	// Disconnect machines connected to nodes
	if(d1 == CABLE_NODE) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network


