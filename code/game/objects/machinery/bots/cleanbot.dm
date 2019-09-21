
//Cleanbot
/obj/machinery/bot/cleanbot
	name = "Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	density = FALSE
	anchored = FALSE
	//weight = 1.0E7
	max_integrity = 25
	var/cleaning = 0
	var/screwloose = 0
	var/oddbutton = 0
	var/blood = 1
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/obj/effect/decal/cleanable/oldtarget
	var/oldloc = null
	req_access = list(ACCESS_CIVILIAN_ENGINEERING)
	var/path[] = new()
	var/patrol_path[] = null
	var/beacon_freq = 1445		// navigation beacon frequency
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/should_patrol
	var/next_dest
	var/next_dest_loc

/obj/machinery/bot/cleanbot/Initialize()
	. = ..()
	get_targets()
	icon_state = "cleanbot[on]"

	should_patrol = 1

	botcard = new /obj/item/card/id(src)
	botcard.access = ALL_MARINE_ACCESS

	locked = 0 // Start unlocked so roboticist can set them to patrol.

	if(SSradio)
		SSradio.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

	start_processing()


/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	icon_state = "cleanbot[on]"
	updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	if(!isnull(target))
		target.targeted_by = null
	target = null
	oldtarget = null
	oldloc = null
	icon_state = "cleanbot[on]"
	path = new()
	updateUsrDialog()


/obj/machinery/bot/cleanbot/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat
	dat += text({"
<TT><B>Automatic Station Cleaner v1.0</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel is [open ? "opened" : "closed"]"},
text("<A href='?src=\ref[src];operation=start'>[on ? "On" : "Off"]</A>"))
	if(!locked || issilicon(user))
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[should_patrol ? "Yes" : "No"]</A>"))
	//	dat += text({"<BR>Beacon frequency: []<BR>"}, text("<A href='?src=\ref[src];operation=freq'>[beacon_freq]</A>"))
	if(open && !locked)
		dat += text({"
Odd looking screw twiddled: []<BR>
Weird button pressed: []"},
text("<A href='?src=\ref[src];operation=screw'>[screwloose ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=oddbutton'>[oddbutton ? "Yes" : "No"]</A>"))


	var/datum/browser/popup = new(user, "cleanbot", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/bot/cleanbot/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["operation"])
		if("start")
			if (on)
				turn_off()
			else
				turn_on()
		if("blood")
			blood =!blood
			get_targets()
			updateUsrDialog()
		if("patrol")
			should_patrol =!should_patrol
			patrol_path = null
			updateUsrDialog()
		if("freq")
			var/freq = text2num(input("Select frequency for  navigation beacons", "Frequnecy", num2text(beacon_freq / 10))) * 10
			if (freq > 0)
				beacon_freq = freq
			updateUsrDialog()
		if("screw")
			screwloose = !screwloose
			to_chat(usr, "<span class='notice>You twiddle the screw.</span>")
			updateUsrDialog()
		if("oddbutton")
			oddbutton = !oddbutton
			to_chat(usr, "<span class='notice'>You press the weird button.</span>")
	
	updateUsrDialog()


/obj/machinery/bot/cleanbot/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/card/id))
		if(allowed(user) && !open)
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>")
		else if(open)
			to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
		else
			to_chat(user, "<span class='notice'>This [src] doesn't seem to respect your authority.</span>")


/obj/machinery/bot/cleanbot/process()
	set background = 1

	if(!on)
		return
	if(cleaning)
		return

	if(!screwloose && !oddbutton && prob(5))
		visible_message("[src] makes an excited beeping booping sound!")

	if(screwloose && prob(5))
		if(isturf(loc))
			var/turf/T = loc
			T.wet_floor(FLOOR_WET_WATER)
	if(oddbutton && prob(5))
		visible_message("Something flies out of [src]. He seems to be acting oddly.")
		var/obj/effect/decal/cleanable/blood/gibs/gib = new /obj/effect/decal/cleanable/blood/gibs(loc)
		//gib.streak(list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		oldtarget = gib
	if(!target || target == null)
		for (var/obj/effect/decal/cleanable/D in view(7,src))
			for(var/T in target_types)
				if(isnull(D.targeted_by) && (D.type == T || D.parent_type == T) && D != oldtarget)   // If the mess isn't targeted
					oldtarget = D								 // or if it is but the bot is gone.
					target = D									 // and it's stuff we clean?  Clean it.
					D.targeted_by = src	// Claim the mess we are targeting.
					return

	if(!target || target == null)
		if(loc != oldloc)
			oldtarget = null

		if (!should_patrol)
			return

		if (!patrol_path || patrol_path.len < 1)
			var/datum/radio_frequency/frequency = SSradio.return_frequency(beacon_freq)

			if(!frequency) return

			closest_dist = 9999
			closest_loc = null
			next_dest_loc = null

			var/datum/signal/signal = new()
			signal.source = src
			signal.transmission_method = 1
			signal.data = list("findbeacon" = "patrol")
			frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
			spawn(5)
				if (!next_dest_loc)
					next_dest_loc = closest_loc
				if (next_dest_loc)
					patrol_path = AStar(loc, next_dest_loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=null)
		else
			patrol_move()

		return

	if(target && path.len == 0)
		spawn(0)
			if(!src || !target) return
			path = AStar(loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 30, id=botcard)
			if (!path) path = list()
			if(path.len == 0)
				oldtarget = target
				target.targeted_by = null
				target = null
		return
	if(path.len > 0 && target && (target != null))
		step_to(src, path[1])
		path -= path[1]
	else if(path.len == 1)
		step_to(src, target)

	if(target && (target != null))
		patrol_path = null
		if(loc == target.loc)
			clean(target)
			path = new()
			target = null
			return

	oldloc = loc

/obj/machinery/bot/cleanbot/proc/patrol_move()
	if (patrol_path.len <= 0)
		return

	var/next = patrol_path[1]
	patrol_path -= next
	if (next == loc)
		return

	var/moved = step_towards(src, next)
	if (!moved)
		failed_steps++
	if (failed_steps > 4)
		patrol_path = null
		next_dest = null
		failed_steps = 0
	else
		failed_steps = 0

/obj/machinery/bot/cleanbot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	var/dist = get_dist(src, signal.source.loc)
	if (dist < closest_dist && signal.source.loc != loc)
		closest_dist = dist
		closest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

	if (recv == next_dest)
		next_dest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

/obj/machinery/bot/cleanbot/proc/get_targets()
	target_types = new/list()

	target_types += /obj/effect/decal/cleanable/blood/oil
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/liquid_fuel
	target_types += /obj/effect/decal/cleanable/mucus
	target_types += /obj/effect/decal/cleanable/dirt

	if(blood)
		target_types += /obj/effect/decal/cleanable/blood/

/obj/machinery/bot/cleanbot/proc/clean(obj/effect/decal/cleanable/target)
	anchored = TRUE
	icon_state = "cleanbot-c"
	visible_message("<span class='warning'> [src] begins to clean up the [target]</span>")
	cleaning = 1
	var/cleantime = 50
	if(istype(target,/obj/effect/decal/cleanable/dirt))		// Clean Dirt much faster
		cleantime = 10
	spawn(cleantime)
		cleaning = 0
		qdel(target)
		icon_state = "cleanbot[on]"
		anchored = FALSE
		target = null

/obj/machinery/bot/cleanbot/deconstruct(disassembled = TRUE)
	new /obj/item/reagent_container/glass/bucket(loc)
	new /obj/item/assembly/prox_sensor(loc)
	if(prob(50))
		new /obj/item/robot_parts/l_arm(loc)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	return ..()
