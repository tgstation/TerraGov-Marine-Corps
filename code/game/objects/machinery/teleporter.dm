/obj/machinery/computer/teleporter
	name = "Teleporter"
	desc = "Used to control a linked teleportation Hub and Station."
	icon_state = "teleport"
	circuit = "/obj/item/circuitboard/computer/teleporter"
	dir = 4
	var/obj/item/locked = null
	var/id = null
	var/one_time_use = 0 //Used for one-time-use teleport cards (such as clown planet coordinates.)
							//Setting this to 1 will set src.locked to null after a player enters the portal and will not allow hand-teles to open portals to that location.

/obj/machinery/computer/teleporter/New()
	src.id = "[rand(1000, 9999)]"
	..()
	underlays.Cut()
	underlays += image('icons/obj/stationobjs.dmi', icon_state = "telecomp-wires")
	return

/obj/machinery/computer/teleporter/Initialize()
	. = ..()
	var/obj/machinery/teleport/station/station = locate(/obj/machinery/teleport/station, get_step(src, dir))
	var/obj/machinery/teleport/hub/hub
	if(station)
		hub = locate(/obj/machinery/teleport/hub, get_step(station, dir))

	if(istype(station))
		station.com = hub
		station.setDir(dir)

	if(istype(hub))
		hub.com = src
		hub.setDir(dir)

/obj/machinery/computer/teleporter/attackby(I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/card/data/))
		var/obj/item/card/data/C = I
		if(machine_stat & (NOPOWER|BROKEN) & (C.function != "teleporter"))
			src.attack_hand()

		var/obj/L = null

		for(var/obj/effect/landmark/sloc in GLOB.landmarks_list)
			if(sloc.name != C.data) continue
			if(locate(/mob/living) in sloc.loc) continue
			L = sloc
			break

		if(!L)
			L = locate("landmark*[C.data]") // use old stype


		if(istype(L, /obj/effect/landmark/) && istype(L.loc, /turf))
			to_chat(usr, "You insert the coordinates into the machine.")
			to_chat(usr, "A message flashes across the screen reminding the traveller that the nuclear authentication disk is to remain on the station at all times.")
			user.drop_held_item()
			qdel(I)

			if(C.data == "Clown Land")
				//whoops
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='warning'> Incoming bluespace portal detected, unable to lock in.</span>", 2)

				for(var/obj/machinery/teleport/hub/H in range(1))
					var/amount = rand(2,5)
					for(var/i=0;i<amount;i++)
						new /mob/living/simple_animal/hostile/carp(get_turf(H))
				//
			else
				for(var/mob/O in hearers(src, null))
					O.show_message("<span class='notice'> Locked In</span>", 2)
				src.locked = L
				one_time_use = 1

	else
		..()

	return

/obj/machinery/computer/teleporter/attack_paw()
	src.attack_hand()

/obj/machinery/teleport/station/attack_ai()
	src.attack_hand()

/obj/machinery/computer/teleporter/attack_hand()
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		return

	var/list/L = list()
	var/list/areaindex = list()

	for(var/obj/item/radio/beacon/R in GLOB.beacon_list)
		var/turf/T = get_turf(R)
		if (!T)
			continue
		if(is_centcom_level(T.z) || T.z > 7)
			continue
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		L[tmpname] = R

	var/desc = input("Please select a location to lock in.", "Locking Computer") in L|null
	if(!desc)
		return
	if(get_dist(src, usr) > 1 && !issilicon(usr))
		return

	src.locked = L[desc]
	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='notice'> Locked In</span>", 2)
	return

/obj/machinery/computer/teleporter/verb/set_id(t as text)
	set category = "Object"
	set name = "Set teleporter ID"
	set src in oview(1)
	set desc = "ID Tag:"

	if(machine_stat & (NOPOWER|BROKEN) || !istype(usr,/mob/living))
		return
	if (t)
		src.id = t
	return

/proc/find_loc(obj/R as obj)
	if (!R)	return null
	var/turf/T = R.loc
	while(!istype(T, /turf))
		T = T.loc
		if(!T || istype(T, /area))	return null
	return T

/obj/machinery/teleport
	name = "teleport"
	icon = 'icons/obj/stationobjs.dmi'
	density = TRUE
	anchored = TRUE
	var/lockeddown = 0


/obj/machinery/teleport/hub
	name = "teleporter hub"
	desc = "It's the hub of a teleporting machine."
	icon_state = "tele0"
	dir = 4
	var/accurate = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/computer/teleporter/com

/obj/machinery/teleport/hub/New()
	..()
	underlays.Cut()
	underlays += image('icons/obj/stationobjs.dmi', icon_state = "tele-wires")

/obj/machinery/teleport/hub/Bumped(M as mob|obj)
	spawn()
		if (src.icon_state == "tele1")
			teleport(M)
			use_power(5000)
	return

/obj/machinery/teleport/hub/proc/teleport(atom/movable/M as mob|obj)
	if (!com)
		return
	if (!com.locked)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='warning'> Failure: Cannot authenticate locked on coordinates. Please reinstate coordinate matrix.</span>")
		return
	if (ismovableatom(M))
		if(prob(5) && !accurate) //oh dear a problem, put em in deep space
			do_teleport(M, locate(rand((2*TRANSITIONEDGE), world.maxx - (2*TRANSITIONEDGE)), rand((2*TRANSITIONEDGE), world.maxy - (2*TRANSITIONEDGE)), 3), 2)
		else
			do_teleport(M, com.locked) //dead-on precision

		if(com.one_time_use) //Make one-time-use cards only usable one time!
			com.one_time_use = 0
			com.locked = null
	else
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		accurate = 1
		spawn(3000)	accurate = 0 //Accurate teleporting for 5 minutes
		for(var/mob/B in hearers(src, null))
			B.show_message("<span class='notice'> Test fire completed.</span>")
	return


/obj/machinery/teleport/station
	name = "station"
	desc = "It's the station thingy of a teleport thingy." //seriously, wtf.
	icon_state = "controller"
	dir = 4
	var/active = 0
	var/engaged = 0
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 2000
	var/obj/machinery/teleport/hub/com

/obj/machinery/teleport/station/New()
	..()
	overlays.Cut()
	overlays += image('icons/obj/stationobjs.dmi', icon_state = "controller-wires")

/obj/machinery/teleport/station/attackby(obj/item/I, mob/user, params)
	. = ..()
	return attack_hand()

/obj/machinery/teleport/station/attack_paw(mob/living/user)
	attack_hand(user)

/obj/machinery/teleport/station/attack_ai(mob/living/silicon/ai/AI)
	attack_hand(AI)

/obj/machinery/teleport/station/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(engaged)
		disengage()
	else
		engage()

/obj/machinery/teleport/station/proc/engage()
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if (com)
		com.icon_state = "tele1"
		use_power(5000)
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'> Teleporter engaged!</span>", 2)
	src.engaged = 1
	return

/obj/machinery/teleport/station/proc/disengage()
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if (com)
		com.icon_state = "tele0"
		com.accurate = 0
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'> Teleporter disengaged!</span>", 2)
	src.engaged = 0
	return

/obj/machinery/teleport/station/verb/testfire()
	set name = "Test Fire Teleporter"
	set category = "Object"
	set src in oview(1)

	if(machine_stat & (BROKEN|NOPOWER) || !istype(usr,/mob/living))
		return

	if (com && !active)
		active = 1
		for(var/mob/O in hearers(src, null))
			O.show_message("<span class='notice'> Test firing!</span>", 2)
		com.teleport()
		use_power(5000)

		spawn(30)
			active=0

	return

/obj/machinery/teleport/station/update_icon()
	if(machine_stat & NOPOWER)
		icon_state = "controller-p"

		if(com)
			com.icon_state = "tele0"
	else
		icon_state = "controller"




/obj/effect/laser
	name = "laser"
	desc = "IT BURNS!!!"
	icon = 'icons/obj/items/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0


/obj/effect/laser/Bump()
	src.range--
	return

/obj/effect/laser/Move()
	src.range--
	return

/atom/proc/laserhit(L as obj)
	return 1
