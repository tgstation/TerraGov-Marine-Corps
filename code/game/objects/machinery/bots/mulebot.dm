/obj/machinery/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	density = TRUE
	anchored = TRUE
	animate_movement=1
	max_integrity = 150
	var/atom/movable/load = null		// the loaded crate (usually)
	var/beacon_freq = 1400
	var/control_freq = FREQ_AI

	suffix = ""

	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	var/new_destination = ""	// pending new destination (waiting for beacon response)
	var/destination = ""		// destination description
	var/home_destination = "" 	// tag of home beacon
	req_access = list(ACCESS_CIVILIAN_ENGINEERING) // added robotics access so assembly line drop-off works properly -veyveyr //I don't think so, Tim. You need to add it to the MULE's hidden robot ID card. -NEO
	var/path[] = new()

	var/mode = 0		//0 = idle/ready
						//1 = loading/unloading
						//2 = moving to deliver
						//3 = returning to home
						//4 = blocked
						//5 = computing navigation
						//6 = waiting for nav computation
						//7 = no destination beacon found (or no route)

	var/blockcount	= 0		//number of times retried a blocked path
	var/reached_target = 1 	//true if already reached the target

	var/refresh = 1		// true to refresh dialogue
	var/auto_return = 1	// true if auto return to home beacon after unload
	var/auto_pickup = 1 // true if auto-pickup at beacon

	var/obj/item/cell/cell
						// the installed power cell

	var/list/wire_text	// list of wire colours
	var/list/wire_order	// order of wire indices


	var/bloodiness = 0		// count of bloodiness

/obj/machinery/bot/mulebot/Initialize(mapload, ...)
	. = ..()
	wires = new /datum/wires/mulebot(src)
	botcard = new(src)
	botcard.access = ALL_MARINE_ACCESS
	cell = new(src)
	cell.charge = 2000
	cell.maxcharge = 2000

	if(SSradio)
		SSradio.add_object(src, control_freq, filter = RADIO_MULEBOT)
		SSradio.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

	var/count = 0
	for(var/obj/machinery/bot/mulebot/other in GLOB.machines)
		count++
	if(!suffix)
		suffix = "#[count]"
	name = "Mulebot ([suffix])"


/obj/machinery/bot/mulebot/Destroy()
	QDEL_NULL(wires)
	return ..()


// attack by item
// screwdriver: open/close hatch
// cell: insert it
// other: chance to knock rider off bot
/obj/machinery/bot/mulebot/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/cell) && open && !cell)
		var/obj/item/cell/C = I
		if(!user.transferItemToLoc(C, src))
			return

		cell = C
		updateUsrDialog()

	else if(iswrench(I))
		if(obj_integrity >= max_integrity)
			to_chat(user, "<span class='notice'>[src] does not need a repair!</span>")
			return

		repair_damage(25)
		user.visible_message("<span class='warning'> [user] repairs [src]!</span>", "<span class='notice'> You repair [src]!</span>")

	else if(load && ismob(load))  // chance to knock off rider
		if(!prob(1 + I.force * 2))
			to_chat(user, "You hit [src] with \the [I] but to no effect.")
			return

		unload(0)
		user.visible_message("<span class='warning'> [user] knocks [load] off [src] with \the [I]!</span>", "<span class='warning'> You knock [load] off [src] with \the [I]!</span>")


/obj/machinery/bot/mulebot/ex_act(severity)
	unload(0)
	switch(severity)
		if(EXPLODE_HEAVY)
			wires.cut_all()
		if(EXPLODE_LIGHT)
			wires.cut_random()
	return ..()


/obj/machinery/bot/mulebot/bullet_act()
	if(prob(50) && !isnull(load))
		unload(0)
	if(prob(25))
		visible_message("<span class='warning'> Something shorts out inside [src]!</span>")
		wires.cut_random()
	..()
	return 1


/obj/machinery/bot/mulebot/interact(mob/user)
	if(open && !isAI(user))
		wires.interact(user)

	var/dat
	dat += "<TT><B>Multiple Utility Load Effector Mk. III</B></TT><BR><BR>"
	dat += "ID: [suffix]<BR>"
	dat += "Power: [on ? "On" : "Off"]<BR>"

	if(!open)

		dat += "Status: "
		switch(mode)
			if(0)
				dat += "Ready"
			if(1)
				dat += "Loading/Unloading"
			if(2)
				dat += "Navigating to Delivery Location"
			if(3)
				dat += "Navigating to Home"
			if(4)
				dat += "Waiting for clear path"
			if(5,6)
				dat += "Calculating navigation path"
			if(7)
				dat += "Unable to locate destination"


		dat += "<BR>Current Load: [load ? load.name : "<i>none</i>"]<BR>"
		dat += "Destination: [!destination ? "<i>none</i>" : destination]<BR>"
		dat += "Power level: [cell ? cell.percent() : 0]%<BR>"

		if(locked && !isAI(user))
			dat += "<HR>Controls are locked <A href='byond://?src=\ref[src];op=unlock'><I>(unlock)</I></A>"
		else
			dat += "<HR>Controls are unlocked <A href='byond://?src=\ref[src];op=lock'><I>(lock)</I></A><BR><BR>"

			dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
			dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"

			if(load)
				dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
			dat += "<HR>The maintenance hatch is closed.<BR>"

	else
		if(!isAI(user))
			dat += "The maintenance hatch is open.<BR><BR>"
			dat += "Power cell: "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinsert'>Removed</A><BR>"
		else
			dat += "The bot is in maintenance mode and cannot be controlled.<BR>"

	var/datum/browser/popup = new(user, "mulebot", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/machinery/bot/mulebot/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["op"])
		if("lock", "unlock")
			if(allowed(usr))
				locked = !locked
				updateUsrDialog()
			else
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return
		if("power")
			if (on)
				turn_off()
			else if (cell && !open)
				if (!turn_on())
					to_chat(usr, "<span class='warning'>You can't switch on [src].</span>")
					return
			else
				return
			visible_message("[usr] switches [on ? "on" : "off"] [src].")
			updateUsrDialog()


		if("cellremove")
			if(open && cell && !usr.get_active_held_item())
				cell.update_icon()
				usr.put_in_active_hand(cell)
				cell = null

				usr.visible_message("<span class='notice'> [usr] removes the power cell from [src].</span>", "<span class='notice'> You remove the power cell from [src].</span>")
				updateUsrDialog()

		if("cellinsert")
			if(open && !cell)
				var/obj/item/cell/C = usr.get_active_held_item()
				if(istype(C))
					if(usr.drop_held_item())
						cell = C
						C.forceMove(src)

						usr.visible_message("<span class='notice'> [usr] inserts a power cell into [src].</span>", "<span class='notice'> You insert the power cell into [src].</span>")
						updateUsrDialog()


		if("stop")
			if(mode >=2)
				mode = 0
				updateUsrDialog()

		if("go")
			if(mode == 0)
				start()
				updateUsrDialog()

		if("home")
			if(mode == 0 || mode == 2)
				start_home()
				updateUsrDialog()

		if("destination")
			refresh=0
			var/new_dest = input("Enter new destination tag", "Mulebot [suffix ? "([suffix])" : ""]", destination) as text|null
			refresh=1
			if(new_dest)
				set_destination(new_dest)


		if("setid")
			refresh=0
			var/new_id = stripped_input(usr, "Enter new bot ID", "Mulebot [suffix ? "([suffix])" : ""]", suffix)
			refresh=1
			if(new_id)
				suffix = new_id
				name = "Mulebot ([suffix])"
				updateUsrDialog()

		if("sethome")
			refresh=0
			var/new_home = stripped_input(usr, "Enter new home tag", "Mulebot [suffix ? "([suffix])" : ""]", home_destination)
			refresh=1
			if(new_home)
				home_destination = new_home
				updateUsrDialog()

		if("unload")
			if(load && mode !=1)
				if(loc == target)
					unload(loaddir)
				else
					unload(0)

		if("autoret")
			auto_return = !auto_return

		if("autopick")
			auto_pickup = !auto_pickup

	updateUsrDialog()



// returns true if the bot has power
/obj/machinery/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && (!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))

// mousedrop a crate to load the bot

/obj/machinery/bot/mulebot/MouseDrop_T(atom/movable/C, mob/user)

	if(user.stat)
		return

	if (!on || !istype(C)|| C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
		return

	if(load)
		return

	load(C)


// called to load a crate
/obj/machinery/bot/mulebot/proc/load(atom/movable/C)
	if(!wires.is_cut(WIRE_LOADCHECK) && !istype(C,/obj/structure/closet/crate))
		visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, 0)
		return

	//I'm sure someone will come along and ask why this is here... well people were dragging screen items onto the mule, and that was not cool.
	//So this is a simple fix that only allows a selection of item types to be considered. Further narrowing-down is below.
	if(!istype(C,/obj/item) && !istype(C,/obj/machinery) && !istype(C,/obj/structure) && !ismob(C))
		return
	if(!isturf(C.loc)) //To prevent the loading from stuff from someone's inventory, which wouldn't get handled properly.
		return

	if(get_dist(C, src) > 1 || load || !on)
		return
	for(var/obj/structure/plasticflaps/P in loc)//Takes flaps into account
		if(!CanPass(C,P))
			return
	mode = 1

	// if a create, close before loading
	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	C.loc = loc
	sleep(2)
	if(C.loc != loc) //To prevent you from going onto more thano ne bot.
		return
	C.loc = src
	load = C

	C.pixel_y += 9
	if(C.layer < layer)
		C.layer = layer + 0.1
	overlays += C

	if(ismob(C))
		var/mob/M = C
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

	mode = 0
	send_status()

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/obj/machinery/bot/mulebot/proc/unload(dirn = 0)
	if(!load)
		return

	mode = 1
	overlays.Cut()

	load.loc = loc
	load.pixel_y -= 9
	load.layer = initial(load.layer)
	if(ismob(load))
		var/mob/M = load
		if(M.client)
			M.client.perspective = MOB_PERSPECTIVE
			M.client.eye = src


	if(dirn)
		var/turf/T = loc
		T = get_step(T,dirn)
		if(CanPass(load,T))//Can't get off onto anything that wouldn't let you pass normally
			step(load, dirn)
		else
			load.loc = loc//Drops you right there, so you shouldn't be able to get yourself stuck

	load = null

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		if(AM == cell || AM == botcard) continue

		AM.loc = loc
		AM.layer = initial(AM.layer)
		AM.pixel_y = initial(AM.pixel_y)
		if(ismob(AM))
			var/mob/M = AM
			if(M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = src
	mode = 0


/obj/machinery/bot/mulebot/process()
	if(!has_power())
		on = 0
		return
	if(!on)
		return

	var/speed = (wires.is_cut(WIRE_MOTOR1) ? 0 : 1) + (wires.is_cut(WIRE_MOTOR2) ? 0 : 2)
	switch(speed)
		if(0)
			// do nothing
		if(1)
			process_bot()
			spawn(2)
				process_bot()
				sleep(2)
				process_bot()
				sleep(2)
				process_bot()
				sleep(2)
				process_bot()
		if(2)
			process_bot()
			spawn(4)
				process_bot()
		if(3)
			process_bot()

	if(refresh)
		updateUsrDialog()

/obj/machinery/bot/mulebot/proc/process_bot()
	//if(mode) to_chat(world, "Mode: [mode]")
	switch(mode)
		if(0)		// idle
			icon_state = "mulebot0"
			return
		if(1)		// loading/unloading
			return
		if(2,3,4)		// navigating to deliver,home, or blocked

			if(loc == target)		// reached target
				at_target()
				return

			else if(path.len > 0 && target)		// valid path

				var/turf/next = path[1]
				reached_target = 0
				if(next == loc)
					path -= next
					return


				if(istype( next, /turf))
					//to_chat(world, "at ([x],[y]) moving to ([next.x],[next.y])")


					if(bloodiness)
						var/obj/effect/decal/cleanable/blood/tracks/B = new(loc)
						var/newdir = get_dir(next, loc)
						if(newdir == dir)
							B.setDir(newdir)
						else
							newdir = newdir|dir
							if(newdir == 3)
								newdir = 1
							else if(newdir == 12)
								newdir = 4
							B.setDir(newdir)
						bloodiness--



					var/moved = step_towards(src, next)	// attempt to move
					if(cell) cell.use(1)
					if(moved)	// successful move
						//to_chat(world, "Successful move.")
						blockcount = 0
						path -= loc


						if(mode==4)
							INVOKE_NEXT_TICK(src, .proc/send_status)

						if(destination == home_destination)
							mode = 3
						else
							mode = 2

					else		// failed to move

						//to_chat(world, "Unable to move.")



						blockcount++
						mode = 4
						if(blockcount == 3)
							visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
							playsound(loc, 'sound/machines/buzz-two.ogg', 25, 0)

						if(blockcount > 5)	// attempt 5 times before recomputing
							// find new path excluding blocked turf
							visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
							playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, 0)

							spawn(2)
								calc_path(next)
								if(path.len > 0)
									visible_message("[src] makes a delighted ping!", "You hear a ping.")
									playsound(loc, 'sound/machines/ping.ogg', 25, 0)
								mode = 4
							mode =6
							return
						return
				else
					visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
					playsound(loc, 'sound/machines/buzz-two.ogg', 25, 0)
					//to_chat(world, "Bad turf.")
					mode = 5
					return
			else
				//to_chat(world, "No path.")
				mode = 5
				return

		if(5)		// calculate new path
			//to_chat(world, "Calc new path.")
			mode = 6
			spawn(0)

				calc_path()

				if(path.len > 0)
					blockcount = 0
					mode = 4
					visible_message("[src] makes a delighted ping!", "You hear a ping.")
					playsound(loc, 'sound/machines/ping.ogg', 25, 0)

				else
					visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
					playsound(loc, 'sound/machines/buzz-sigh.ogg', 25, 0)

					mode = 7
		//if(6)
			//to_chat(world, "Pending path calc.")
		//if(7)
			//to_chat(world, "No dest / no route.")


// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/mulebot/proc/calc_path(turf/avoid = null)
	path = AStar(loc, target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, id=botcard, exclude=avoid)
	if(!path)
		path = list()


// sets the current destination
// signals all beacons matching the delivery code
// beacons will return a signal giving their locations
/obj/machinery/bot/mulebot/proc/set_destination(new_dest)
	spawn(0)
		new_destination = new_dest
		post_signal(beacon_freq, "findbeacon", "delivery")
		updateUsrDialog()

// starts bot moving to current destination
/obj/machinery/bot/mulebot/proc/start()
	if(destination == home_destination)
		mode = 3
	else
		mode = 2

// starts bot moving to home
// sends a beacon query to find
/obj/machinery/bot/mulebot/proc/start_home()
	spawn(0)
		set_destination(home_destination)
		mode = 4

// called when bot reaches current target
/obj/machinery/bot/mulebot/proc/at_target()
	if(!reached_target)
		visible_message("[src] makes a chiming sound!", "You hear a chime.")
		playsound(loc, 'sound/machines/chime.ogg', 25, 0)
		reached_target = 1

		if(load)		// if loaded, unload at target
			unload(loaddir)
		else
			// not loaded
			if(auto_pickup)		// find a crate
				var/atom/movable/AM
				if(wires.is_cut(WIRE_LOADCHECK))
					for(var/atom/movable/A in get_step(loc, loaddir))
						if(!A.anchored)
							AM = A
							break
				else			// otherwise, look for crates only
					AM = locate(/obj/structure/closet/crate) in get_step(loc,loaddir)
				if(AM)
					load(AM)
		// whatever happened, check to see if we return home

		if(auto_return && destination != home_destination)
			// auto return set and not at home already
			start_home()
			mode = 4
		else
			mode = 0	// otherwise go idle

	send_status()	// report status to anyone listening


// called when bot bumps into anything
/obj/machinery/bot/mulebot/Bump(atom/A)
	if(!wires.is_cut(WIRE_AVOIDANCE))		//usually just bumps, but if avoidance disabled knock over mobs
		return ..()

	if(!isliving(A))
		return ..()

	var/mob/living/L = A
	visible_message("<span class='warning'>[src] knocks over [L]!</span>")
	L.stop_pulling()
	L.Paralyze(10 SECONDS)


// called from mob/living/carbon/human/Crossed()
// when mulebot is in the same loc
/obj/machinery/bot/mulebot/proc/RunOver(mob/living/carbon/human/H)
	visible_message("<span class='warning'> [src] drives over [H]!</span>")
	playsound(loc, 'sound/effects/splat.ogg', 25, 1)

	var/damage = rand(5,15)
	H.apply_damage(2*damage, BRUTE, "head")
	H.apply_damage(2*damage, BRUTE, "chest")
	H.apply_damage(0.5*damage, BRUTE, "l_leg")
	H.apply_damage(0.5*damage, BRUTE, "r_leg")
	H.apply_damage(0.5*damage, BRUTE, "l_arm")
	H.apply_damage(0.5*damage, BRUTE, "r_arm")
	UPDATEHEALTH(H)
	H.add_splatter_floor(loc, 1)
	bloodiness += 4

// player on mulebot attempted to move
/obj/machinery/bot/mulebot/relaymove(mob/user)
	if(user.incapacitated(TRUE)) return
	if(load == user)
		unload(0)


// receive a radio signal
// used for control and beacon reception

/obj/machinery/bot/mulebot/receive_signal(datum/signal/signal)

	if(!on)
		return

	/*
	to_chat(world, "rec signal: [signal.source]")
	for(var/x in signal.data)
		to_chat(world, "* [x] = [signal.data[x]]")
	*/
	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status" && !wires.is_cut(WIRE_RX))
		send_status()


	recv = signal.data["command [suffix]"]
	if(!wires.is_cut(WIRE_RX))
		// process control input
		switch(recv)
			if("stop")
				mode = 0
				return

			if("go")
				start()
				return

			if("target")
				set_destination(signal.data["destination"] )
				return

			if("unload")
				if(loc == target)
					unload(loaddir)
				else
					unload(0)
				return

			if("home")
				start_home()
				return

			if("bot_status")
				send_status()
				return

			if("autoret")
				auto_return = text2num(signal.data["value"])
				return

			if("autopick")
				auto_pickup = text2num(signal.data["value"])
				return

	// receive response from beacon
	recv = signal.data["beacon"]
	if(!wires.is_cut(WIRE_RX))
		if(recv == new_destination)	// if the recvd beacon location matches the set destination
									// the we will navigate there
			destination = new_destination
			target = signal.source.loc
			var/direction = signal.data["dir"]	// this will be the load/unload dir
			if(direction)
				loaddir = text2num(direction)
			else
				loaddir = 0
			icon_state = "mulebot[!wires.is_cut(WIRE_AVOIDANCE)]"
			calc_path()
			updateUsrDialog()

// send a radio signal with a single data key/value pair
/obj/machinery/bot/mulebot/proc/post_signal(freq, key, value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/mulebot/proc/post_signal_multiple(freq, list/keyval)

	if(freq == beacon_freq && wires.is_cut(WIRE_TX))
		return
	if(freq == control_freq && wires.is_cut(WIRE_TX))
		return

	var/datum/radio_frequency/frequency = SSradio.return_frequency(freq)

	if(!frequency) return



	var/datum/signal/signal = new()
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
	signal.data = keyval
		//to_chat(world, "sent [key],[keyval[key]] on [freq]")
	if (signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if (signal.data["type"] == "mulebot")
		frequency.post_signal(src, signal, filter = RADIO_MULEBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/mulebot/proc/send_status()
	var/list/kv = list(
		"type" = "mulebot",
		"name" = suffix,
		"loca" = (loc ? loc.loc : "Unknown"),	// somehow loc can be null and cause a runtime - Quarxink
		"mode" = mode,
		"powr" = (cell ? cell.percent() : 0),
		"dest" = destination,
		"home" = home_destination,
		"load" = load,
		"retn" = auto_return,
		"pick" = auto_pickup,
	)
	post_signal_multiple(control_freq, kv)

/obj/machinery/bot/mulebot/emp_act(severity)
	if (cell)
		cell.emp_act(severity)
	if(load)
		load.emp_act(severity)
	..()


/obj/machinery/bot/mulebot/deconstruct(disassembled = TRUE)
	new /obj/item/assembly/prox_sensor(loc)
	new /obj/item/stack/rods(loc)
	new /obj/item/stack/rods(loc)
	new /obj/item/stack/cable_coil/cut(loc)

	if(cell)
		cell.forceMove(loc)
		cell.update_icon()

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	new /obj/effect/decal/cleanable/blood/oil(loc)
	unload(FALSE)
	return ..()
