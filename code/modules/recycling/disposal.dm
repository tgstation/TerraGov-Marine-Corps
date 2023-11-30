//Disposal bin, holds items for disposal into pipe system. Draws air from turf, gradually charges internal reservoir
//Once full (~1 atm), uses air resv to flush items into the pipes. Automatically recharges air (unless off), will flush when ready if pre-set
//Can hold items and human size things, no other draggables
//Toilets are a type of disposal bin for small objects only and work on magic. By magic, I mean torque rotation
#define SEND_PRESSURE 50 //kPa
#define PRESSURE_TANK_VOLUME 70	//L - a 0.3 m diameter * 1 m long cylindrical tank. Happens to be the same volume as the regular oxygen tanks, so seems appropriate.
#define PUMP_MAX_FLOW_RATE 50	//L/s - 8 m/s using a 15 cm by 15 cm inlet

/obj/machinery/disposal
	name = "disposal unit"
	desc = "A pneumatic waste disposal unit."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "disposal"
	anchored = TRUE
	density = TRUE
	active_power_usage = 3500 //The pneumatic pump power. 3 HP ~ 2200W
	idle_power_usage = 100
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE
	var/mode = 1 //Item mode 0=off 1=charging 2=charged
	var/flush = 0 //True if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null //The attached pipe trunk
	var/flushing = 0 //True if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //This var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0
	var/disposal_pressure = 0

//Create a new disposal, find the attached trunk (if present) and init gas resvr.
/obj/machinery/disposal/Initialize(mapload)
	. = ..()
	set_trunk(locate(/obj/structure/disposalpipe/trunk) in loc)
	if(!trunk)
		mode = 0
		flush = 0
	else
		trunk.set_linked(src)	//Link the pipe trunk to self


	update()
	start_processing()


/obj/machinery/disposal/Destroy()
	if(length(contents))
		eject()
	if(trunk)
		if(trunk.linked == src)
			trunk.linked = null
			trunk.update()
		trunk = null
	return ..()

///Set the trunk of the disposal
/obj/machinery/disposal/proc/set_trunk(obj/future_trunk)
	if(trunk)
		UnregisterSignal(trunk, COMSIG_QDELETING)
	trunk = null
	if(future_trunk)
		trunk = future_trunk
		RegisterSignal(trunk, COMSIG_QDELETING, PROC_REF(clean_trunk))

///Signal handler to clean trunk to prevent harddel
/obj/machinery/disposal/proc/clean_trunk()
	SIGNAL_HANDLER
	set_trunk(null)

//Attack by item places it in to disposal
/obj/machinery/disposal/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(machine_stat & BROKEN)
		return

	else if(isxeno(user))
		return

	else if(mode <= 0)
		if(isscrewdriver(I))
			if(length(contents))
				to_chat(user, span_warning("Eject the contents first!"))
				return
			if(mode == 0) //It's off but still not unscrewed
				mode = -1 //Set it to doubleoff
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, span_notice("You remove the screws around the power connection."))
				return
			else if(mode == -1)
				mode = 0
				playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
				to_chat(user, span_notice("You attach the screws around the power connection."))
				return
		else if(iswelder(I) && mode == -1)
			if(length(contents))
				to_chat(user, span_warning("Eject the contents first!"))
				return
			var/obj/item/tool/weldingtool/W = I
			if(!W.remove_fuel(0, user))
				to_chat(user, span_warning("You need more welding fuel to complete this task."))
				return

			playsound(loc, 'sound/items/welder2.ogg', 25, 1)
			to_chat(user, span_notice("You start slicing the floorweld off the disposal unit."))
			if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(W, /obj/item/tool/weldingtool/proc/isOn)))
				return

			to_chat(user, span_notice("You sliced the floorweld off the disposal unit."))
			var/obj/structure/disposalconstruct/C = new(loc)
			C.ptype = 6 //6 = disposal unit
			C.anchored = TRUE
			C.density = TRUE
			C.update()
			qdel(src)

	if(istype(I, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/T = I
		to_chat(user, span_notice("You empty the bag into [src]."))
		for(var/obj/item/O in T.contents)
			T.remove_from_storage(O, src, user)
		T.update_icon()
		update()

	var/obj/item/grab/G = I
	if(istype(G)) //Handle grabbed mob
		if(!ismob(G.grabbed_thing) || user.grab_state < GRAB_AGGRESSIVE)
			return

		var/mob/GM = G.grabbed_thing
		user.visible_message(span_warning("[user] starts putting [GM] into [src]."),
		span_warning("You start putting [GM] into [src]."))

		if(!do_after(user, 20, NONE, src, BUSY_ICON_HOSTILE) || G.grabbed_thing != GM)
			return

		GM.forceMove(src)
		user.visible_message(span_warning("[user] puts [GM] into [src]."),
		span_warning("[user] puts [GM] into [src]."))
		log_combat(user, GM, "placed", addition="into disposals")
		message_admins("[ADMIN_TPMONTY(usr)] placed [ADMIN_TPMONTY(GM)] in a disposals unit.")
		flush()

	else if(user.transferItemToLoc(I, src))
		user.visible_message(span_notice("[user] places [I] into [src]."),
		span_notice("You place [I] into [src]."))

	update()

//Mouse drop another mob or self
/obj/machinery/disposal/MouseDrop_T(mob/target, mob/user)
	. = ..()
	// Check the user, if they can do all the things, are they close, alive?
	if(isAI(user) || isxeno(user) || !isliving(user) || get_dist(user, target) > 1 || !in_range(user, src) || user.incapacitated(TRUE))
		return
	// Check the target, are they valid, small enough, and not tied down
	if(!istype(target) || target.anchored || target.buckled || target.mob_size >= MOB_SIZE_BIG)
		return
	if(target != user && (isanimal(user) || user.restrained()))
		return //Animals cannot put mobs other than themselves into disposal

	if(target == user)
		visible_message(span_notice("[user] starts climbing into the disposal."))
	else
		visible_message("<span class ='warning'>[user] starts stuffing [target] into the disposal.</span>")

	if(!do_after(user, 4 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_HOSTILE))
		return

	if(target == user)
		user.visible_message(span_notice("[user] climbs into [src]."),
		"<span class ='notice'>You climb into [src].</span>")
	else
		user.visible_message("<span class ='danger'>[user] stuffs [target] into [src]!</span>",
		"<span class ='warning'>You stuff [target] into [src]!</span>")

		log_combat(user, target, "placed", addition="into disposals")
		message_admins("[ADMIN_TPMONTY(usr)] placed [ADMIN_TPMONTY(target)] in a disposals unit.")

	target.forceMove(src)
	flush()
	update()

//Attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user)
	if(!isliving(user))
		return
	var/mob/living/L = user
	if(L.stat || L.IsStun() || L.IsParalyzed() || flushing)
		return
	if(L.loc == src)
		go_out(L)

//Leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)

	if(user.client)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	user.forceMove(loc)
	if(isliving(user))
		var/mob/living/L = user
		L.Stun(4 SECONDS)
	if(!user.lying_angle)
		user.visible_message("<span class='warning'>[user] suddenly climbs out of [src]!",
		"<span class='warning'>You climb out of [src] and get your bearings!")
		update()


/obj/machinery/disposal/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(user?.loc == src)
		to_chat(usr, span_warning("You cannot reach the controls from inside."))
		return FALSE

	return TRUE


/obj/machinery/disposal/interact(mob/user)
	. = ..()
	if(.)
		return
	var/dat = "<B>Status</B><HR>"

	if(!isAI(user))  //AI can't pull flush handle
		if(flush)
			dat += "Disposal handle: <A href='?src=[text_ref(src)];handle=0'>Disengage</A> <B>Engaged</B>"
		else
			dat += "Disposal handle: <B>Disengaged</B> <A href='?src=[text_ref(src)];handle=1'>Engage</A>"

		dat += "<BR><HR><A href='?src=[text_ref(src)];eject=1'>Eject contents</A><HR>"

	if(mode <= 0)
		dat += "Pump: <B>Off</B> On</A><BR>"
	else if(mode == 1)
		dat += "Pump: <B>On</B> (pressurizing)<BR>"
	else
		dat += "Pump: <B>On</B> (idle)<BR>"

	dat += "Pressure: [disposal_pressure*100/SEND_PRESSURE]%<BR>"

	var/datum/browser/popup = new(user, "disposal", "<div align='center'>Waste Disposal Unit</div>", 360, 220)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "disposal")

//Handle machine interaction
/obj/machinery/disposal/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(usr.loc == src)
		to_chat(usr, span_warning("You cannot reach the controls from inside."))
		return

	if(mode == -1 && !href_list["eject"]) // only allow ejecting if mode is -1
		to_chat(usr, span_warning("The disposal units power is disabled."))
		return
	if(flushing)
		return

	if(href_list["pump"])
		if(text2num(href_list["pump"]))
			mode = 1
		else
			mode = 0
		update()

	if(href_list["handle"])
		flush = text2num(href_list["handle"])
		update()

	if(href_list["eject"])
		eject()

//Eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = loc
		AM.pipe_eject(0)
		if(isliving(AM))
			var/mob/M = AM
			if(!M.lying_angle)
				M.visible_message("<span class='warning'>[M] is suddenly pushed out of [src]!",
				"<span class='warning'>You get pushed out of [src] and get your bearings!")
			if(isliving(M))
				var/mob/living/L = M
				L.Stun(4 SECONDS)
	update()

//Pipe affected by explosion
/obj/machinery/disposal/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(60))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(25))
				qdel(src)

//Update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	overlays.Cut()
	if(machine_stat & BROKEN)
		icon_state = "disposal-broken"
		mode = 0
		flush = 0
		return

	//Flush handle
	if(flush)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-handle")

	//Only handle is shown if no power
	if(machine_stat & NOPOWER || mode == -1)
		return

	//Check for items in disposal - occupied light
	if(length(contents) > 0)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-full")

	//Charging and ready light
	if(mode == 1)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-charge")
	else if(mode == 2)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-ready")

//Timed process, charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	if(machine_stat & BROKEN) //Nothing can happen if broken
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(length(contents))
			if(mode == 2)
				INVOKE_ASYNC(src, PROC_REF(flush))
		flush_count = 0

	updateUsrDialog()

	if(flush && disposal_pressure >= SEND_PRESSURE) //Flush can happen even without power
		flush()

	if(mode == 1 && disposal_pressure >= SEND_PRESSURE)
		mode = 2 //If full enough, switch to ready mode
		update()
	else
		pressurize() //Otherwise charge

/obj/machinery/disposal/proc/pressurize()
	if(disposal_pressure < SEND_PRESSURE)
		disposal_pressure += 5


//Perform a flush
/obj/machinery/disposal/proc/flush()

	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	//Virtual holder object which actually
												//Travels through the pipes.

	for(var/obj/item/smallDelivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1

	sleep(1 SECONDS)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 15, 0)
		last_sound = world.time
	sleep(0.5 SECONDS) //Wait for animation to finish

	disposal_pressure = 0

	if(H)
		H.init(src)	//Copy the contents of disposer to holder

		H.start(src) //Start the holder processing movement
	flushing = 0
	//Now reset disposal state
	flush = 0
	if(mode == 2)	//If was ready,
		mode = 1	//Switch to charging
	update()


//Called when area power changes
/obj/machinery/disposal/power_change()
	..()	//Do default setting/reset of stat NOPOWER bit
	update()	//Update icon


//Called when holder is expelled from a disposal, should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(obj/structure/disposalholder/H)
	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', 25, 0)
	if(H) //Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(loc, rand(5) - rand(5), rand(5) - rand(5))
			AM.loc = loc
			AM.pipe_eject(0)
			spawn(1)
				AM?.throw_at(target, 5, 1)

		qdel(H)

/obj/machinery/disposal/CanAllowThrough(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(prob(75))
			I.loc = src
			visible_message(span_notice("[I] lands into [src]."))
		else
			visible_message(span_warning("[I] bounces off of [src]'s rim!"))
		return FALSE
	else
		return ..()

//Virtual disposal object, travels through pipes in lieu of actual items
//Contents will be items flushed by the disposal, this allows the gas flushed to be tracked
/obj/structure/disposalholder
	invisibility = INVISIBILITY_MAXIMUM
	var/active = 0	//True if the holder is moving, otherwise inactive
	dir = 0
	var/count = 2048 //Can travel 2048 steps before going inactive (in case of loops)
	var/destinationTag = "" //Changes if contains a delivery container
	var/tomail = 0 //Changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

	var/partialTag = "" //Set by a partial tagger the first time round, then put in destinationTag if it goes through again.

/obj/structure/disposalholder/Destroy()
	active = 0
	return ..()

//initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(obj/machinery/disposal/D)

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M?.stat != DEAD)
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M.stat != DEAD)
					hasmob = 1

	//Now everything inside the disposal gets put into the holder
	//Note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		SEND_SIGNAL(AM, COMSIG_MOVABLE_DISPOSING, src, D)
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			destinationTag = T.sortTag

//Start the movement process
//Argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(obj/machinery/disposal/D)

	if(!D.trunk)
		D.expel(src) //No trunk connected, so expel immediately
		return

	loc = D.trunk
	active = 1
	setDir(DOWN)
	INVOKE_NEXT_TICK(src, PROC_REF(move)) //Spawn off the movement process

//Movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()

	var/obj/structure/disposalpipe/last
	while(active)
		if(hasmob && prob(3))
			for(var/mob/living/H in src)
				H.take_overall_damage(20) //Horribly maim any living creature jumping down disposals.  c'est la vie
				UPDATEHEALTH(H)

		sleep(0.1 SECONDS) //Was 1
		var/obj/structure/disposalpipe/curr = loc
		last = curr
		curr = curr.transfer(src)
		if(!curr && loc)
			last.expel(src, loc, dir)

		if(!(count--))
			active = 0

//Find the turf which should contain the next pipe
/obj/structure/disposalholder/proc/nextloc()
	return get_step(loc, dir)

//Find a matching pipe on a turf
/obj/structure/disposalholder/proc/findpipe(turf/T)

	if(!T)
		return null

	var/fdir = REVERSE_DIR(dir) //Flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir) //Find pipe direction mask that matches flipped dir
			return P
	//If no matching pipe, return null
	return null

//Merge two holder objects
//Used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src //Move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client) //If a client mob, update eye to follow this holder
				M.client.eye = src

	qdel(other)

/obj/structure/disposalholder/proc/settag(new_tag)
	destinationTag = new_tag

/obj/structure/disposalholder/proc/setpartialtag(new_tag)
	if(partialTag == new_tag)
		destinationTag = new_tag
		partialTag = ""
	else
		partialTag = new_tag


//Called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user)

	if(!isliving(user))
		return

	var/mob/living/living_user = user

	if(living_user.stat || TIMER_COOLDOWN_CHECK(living_user, COOLDOWN_DISPOSAL))
		return

	TIMER_COOLDOWN_START(living_user, COOLDOWN_DISPOSAL, 10 SECONDS)

	playsound(loc, 'sound/effects/clang.ogg', 25)


//Disposal pipes
/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = TRUE
	density = FALSE

	level = 1			//Underfloor only
	var/dpdir = 0		//Bitmask of pipe directions
	dir = 0				//dir will contain dominant direction for junction pipes
	max_integrity = 10 	//Health points 0-10
	layer = DISPOSAL_PIPE_LAYER //Slightly lower than wires and other pipes
	plane = FLOOR_PLANE
	resistance_flags = RESIST_ALL

	//New pipe, set the icon_state as on map
/obj/structure/disposalpipe/Initialize(mapload)
	. = ..()
	base_icon_state = icon_state
	GLOB.disposal_list += src
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)


//Pipe is deleted
//Ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Destroy()
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		//Holder was present
		H.active = 0
		var/turf/T = loc
		if(T.density)
			//Deleting pipe is inside a dense turf (wall), this is unlikely, but just dump out everything into the turf in case

			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			qdel(H)
			..()
			return

		//Otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	GLOB.disposal_list -= src
	return ..()

//Returns the direction of the next pipe object, given the entrance dir by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(fromdir)
	return dpdir & (~REVERSE_DIR(fromdir))

//Transfer the holder through this pipe segment, overriden for special behaviour
/obj/structure/disposalpipe/proc/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.setDir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else //If wasn't a pipe, then set loc to turf
		H.loc = T
		return null
	return P

//Update the icon_state to reflect hidden status
/obj/structure/disposalpipe/proc/update()
	var/turf/T = loc
	hide(T.intact_tile && !isspaceturf(T)) //Space never hides pipes

//Hide called by levelupdate if turf intact status changes, change visibility status and force update of icon
/obj/structure/disposalpipe/hide(intact)
	invisibility = intact ? INVISIBILITY_MAXIMUM: 0	// hide if floor is intact
	updateicon()

//Update actual icon_state depending on visibility, if invisible, append "f" to icon_state to show faded version, this will be revealed if a T-scanner is used
//If visible, use regular icon_state
/obj/structure/disposalpipe/proc/updateicon()

	icon_state = base_icon_state

//Expel the held objects into a turf. called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(obj/structure/disposalholder/H, turf/T, direction)

	var/turf/target

	if(T.density) //Dense ouput turf, so stop holder
		H.active = 0
		H.loc = src
		return
	if(isfloorturf(T)) //intact floor, pop the tile
		var/turf/open/floor/F = T
		if(F.has_tile())
			F.remove_tile()

	if(direction) //Direction is specified
		if(isspaceturf(T)) //If ended in space, then range is unlimited
			target = get_edge_target_turf(T, direction)
		else //Otherwise limit to 10 tiles
			target = get_ranged_target_turf(T, direction, 10)

		playsound(src, 'sound/machines/hiss.ogg', 25, 0)
		if(H)
			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(direction)
				spawn(1)
					if(AM)
						AM.throw_at(target, 100, 1)
			qdel(H)

	else //No specified direction, so throw in random direction

		playsound(src, 'sound/machines/hiss.ogg', 25, 0)
		if(H)
			for(var/atom/movable/AM in H)
				target = get_offset_target_turf(T, rand(5) - rand(5), rand(5) - rand(5))

				AM.loc = T
				AM.pipe_eject(0)
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)

			qdel(H)

//Pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(rand(5, 15), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(0, 15), BRUTE, BOMB)

//Attack by item. Weldingtool: unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/turf/T = loc
	if(T.intact_tile)
		return //Prevent interaction with T-scanner revealed pipes

	if(iswelder(I))
		var/obj/item/tool/weldingtool/W = I

		if(!W.remove_fuel(0, user))
			to_chat(user, span_warning("You need more welding fuel to cut [src]."))
			return

		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		//Check if anything changed over 2 seconds
		var/turf/uloc = user.loc
		var/atom/wloc = I.loc
		user.visible_message(span_notice("[user] starts slicing [src]."),
		span_notice("You start slicing [src]."))
		sleep(3 SECONDS)
		if(!W.isOn() || user.loc != uloc || wloc != I.loc)
			to_chat(user, span_warning("You must stay still while welding [src]."))
			return

		welded()

//Called when pipe is cut with blowtorch
/obj/structure/disposalpipe/proc/welded()

	var/obj/structure/disposalconstruct/C = new(loc)
	switch(base_icon_state)
		if("pipe-s")
			C.ptype = 0
		if("pipe-c")
			C.ptype = 1
		if("pipe-j1")
			C.ptype = 2
		if("pipe-j2")
			C.ptype = 3
		if("pipe-y")
			C.ptype = 4
		if("pipe-t")
			C.ptype = 5
		if("pipe-j1s")
			C.ptype = 9
		if("pipe-j2s")
			C.ptype = 10
		//Z-Level stuff
		if("pipe-u")
			C.ptype = 11
		if("pipe-d")
			C.ptype = 12
		//Z-Level stuff
		if("pipe-tagger")
			C.ptype = 13
		if("pipe-tagger-partial")
			C.ptype = 14
	C.setDir(dir)
	C.density = FALSE
	C.anchored = TRUE
	C.update()
	qdel(src)

//A straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"


/obj/structure/disposalpipe/segment/Initialize(mapload)
	. = ..()

	if(icon_state == "pipe-s")
		dpdir = dir|REVERSE_DIR(dir)
	else
		dpdir = dir|turn(dir, -90)
	update()

/obj/structure/disposalpipe/segment/corner
	icon_state = "pipe-c"

//Z-Level stuff
/obj/structure/disposalpipe/up
	icon_state = "pipe-u"


/obj/structure/disposalpipe/up/Initialize(mapload)
	. = ..()
	dpdir = dir
	update()

/obj/structure/disposalpipe/up/nextdir(fromdir)
	var/nextdir
	if(fromdir == 11)
		nextdir = dir
	else
		nextdir = 12
	return nextdir

/obj/structure/disposalpipe/up/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.setDir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 12)
		H.loc = loc
		return

	else
		T = get_step(loc, H.dir)
		P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else //If wasn't a pipe, then set loc to turf
		H.loc = T
		return null
	return P

/obj/structure/disposalpipe/down
	icon_state = "pipe-d"


/obj/structure/disposalpipe/down/Initialize(mapload)
	. = ..()
	dpdir = dir
	update()

/obj/structure/disposalpipe/down/nextdir(fromdir)
	var/nextdir
	if(fromdir == 12)
		nextdir = dir
	else
		nextdir = 11
	return nextdir

/obj/structure/disposalpipe/down/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.setDir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 11)
		H.loc = loc
		return

	else
		T = get_step(loc, H.dir)
		P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else //If wasn't a pipe, then set loc to turf
		H.loc = T
		return null
	return P

// *** special cased marine ship stuff because its all one z level ***

/obj/structure/disposalpipe/up/mainship
	var/id

/obj/structure/disposalpipe/down/mainship
	var/id

/obj/structure/disposalpipe/up/mainship/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.setDir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 12)
		for(var/obj/structure/disposalpipe/down/mainship/F AS in GLOB.disposal_list)
			if(id == F.id)
				P = F
				break // stop at first found match
	else
		T = get_step(loc, H.dir)
		P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else //If wasn't a pipe, then set loc to turf
		H.loc = loc
		return null
	return P

/obj/structure/disposalpipe/down/mainship/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.setDir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 11)
		for(var/obj/structure/disposalpipe/up/mainship/F AS in GLOB.disposal_list)
			if(id == F.id)
				P = F
				break // stop at first found match
	else
		T = get_step(loc, H.dir)
		P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else //If wasn't a pipe, then set loc to turf
		H.loc = loc
		return null
	return P

// *** end special cased marine ship stuff ***

//Z-Level stuff
//A three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"


/obj/structure/disposalpipe/junction/Initialize(mapload)
	. = ..()
	if(icon_state == "pipe-j1")
		dpdir = dir|turn(dir, -90)|REVERSE_DIR(dir)
	else if(icon_state == "pipe-j2")
		dpdir = dir|turn(dir, 90)|REVERSE_DIR(dir)
	else //Pipe-y
		dpdir = dir|turn(dir,90)|turn(dir, -90)
	update()

/obj/structure/disposalpipe/junction/flipped
	icon_state = "pipe-j2"

/obj/structure/disposalpipe/junction/yjunc
	icon_state = "pipe-y"

//Next direction to move, if coming in from secondary dirs, then next is primary dir, if coming in from primary dir, then next is equal chance of other dirs
/obj/structure/disposalpipe/junction/nextdir(fromdir)
	var/flipdir = REVERSE_DIR(fromdir)
	if(flipdir != dir)	//Came from secondary dir
		return dir		//So exit through primary
	else				//Came from primary
						//So need to choose either secondary exit
		var/mask = ..(fromdir)

		//Find a bit which is set
		var/setbit = 0
		if(mask & NORTH)
			setbit = NORTH
		else if(mask & SOUTH)
			setbit = SOUTH
		else if(mask & EAST)
			setbit = EAST
		else
			setbit = WEST

		if(prob(50)) //50% chance to choose the found bit or the other one
			return setbit
		else
			return mask & (~setbit)

/obj/structure/disposalpipe/tagger
	name = "package tagger"
	icon_state = "pipe-tagger"
	var/sort_tag = ""
	var/partial = 0

/obj/structure/disposalpipe/tagger/Initialize(mapload)
	. = ..()
	dpdir = dir|REVERSE_DIR(dir)
	if(sort_tag)
		GLOB.tagger_locations |= sort_tag
	updatename()
	updatedesc()
	update()

/obj/structure/disposalpipe/tagger/proc/updatedesc()
	desc = initial(desc)
	if(sort_tag)
		desc += "\nIt's tagging objects with the '[sort_tag]' tag."

/obj/structure/disposalpipe/tagger/proc/updatename()
	if(sort_tag)
		name = "[initial(name)] ([sort_tag])"
	else
		name = initial(name)

/obj/structure/disposalpipe/tagger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I

		if(!O.currTag) //Tag set
			return

		sort_tag = O.currTag
		playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)
		to_chat(user, span_notice("Changed tag to '[sort_tag]'."))
		updatename()
		updatedesc()

/obj/structure/disposalpipe/tagger/transfer(obj/structure/disposalholder/H)
	if(sort_tag)
		if(partial)
			H.setpartialtag(sort_tag)
		else
			H.settag(sort_tag)
	return ..()

/obj/structure/disposalpipe/tagger/partial //Needs two passes to tag
	name = "partial package tagger"
	icon_state = "pipe-tagger-partial"
	partial = 1

//A three-way junction that sorts objects
/obj/structure/disposalpipe/sortjunction
	name = "sorting junction"
	icon_state = "pipe-j1s"
	desc = "An underfloor disposal pipe with a package sorting mechanism."

	var/sortType = ""
	var/posdir = 0
	var/negdir = 0
	var/sortdir = 0

/obj/structure/disposalpipe/sortjunction/Initialize(mapload)
	. = ..()
	if(sortType)
		GLOB.tagger_locations |= sortType

	updatedir()
	updatename()
	updatedesc()
	update()

/obj/structure/disposalpipe/sortjunction/proc/updatedesc()
	desc = initial(desc)
	if(sortType)
		desc += "\nIt's filtering objects with the '[sortType]' tag."

/obj/structure/disposalpipe/sortjunction/proc/updatename()
	if(sortType)
		name = "[initial(name)] ([sortType])"
	else
		name = initial(name)

/obj/structure/disposalpipe/sortjunction/proc/updatedir()
	posdir = dir
	negdir = REVERSE_DIR(posdir)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else if(icon_state == "pipe-j2s")
		sortdir = turn(posdir, 90)

	dpdir = sortdir|posdir|negdir

/obj/structure/disposalpipe/sortjunction/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/destTagger))
		var/obj/item/destTagger/O = I

		if(!O.currTag)
			return

		sortType = O.currTag
		playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)
		to_chat(user, span_notice("Changed filter to '[sortType]'."))
		updatename()
		updatedesc()

/obj/structure/disposalpipe/sortjunction/proc/divert_check(checkTag)
	return sortType == checkTag

//Next direction to move, if coming in from negdir, then next is primary dir or sortdir, if coming in from posdir, then flip around and go back to posdir, if coming in from sortdir, go to posdir
/obj/structure/disposalpipe/sortjunction/nextdir(fromdir, sortTag)
	if(fromdir != sortdir) //Probably came from the negdir
		if(divert_check(sortTag))
			return sortdir
		else
			return posdir
	else //Came from sortdir so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.setDir(nextdir)
	var/turf/T = H.nextloc()
	var/obj/structure/disposalpipe/P = H.findpipe(T)

	if(P)
		//Find other holder in next loc, if inactive merge it with current
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.loc = P
	else //If wasn't a pipe, then set loc to turf
		H.loc = T
		return null
	return P

//A three-way junction that filters all wrapped and tagged items
/obj/structure/disposalpipe/sortjunction/wildcard
	name = "wildcard sorting junction"
	desc = "An underfloor disposal pipe which filters all wrapped and tagged items."

/obj/structure/disposalpipe/sortjunction/wildcard/divert_check(checkTag)
	return checkTag != ""

//Junction that filters all untagged items
/obj/structure/disposalpipe/sortjunction/untagged
	name = "untagged sorting junction"
	desc = "An underfloor disposal pipe which filters all untagged items."

/obj/structure/disposalpipe/sortjunction/untagged/divert_check(checkTag)
	return checkTag == ""

/obj/structure/disposalpipe/sortjunction/flipped //For easier and cleaner mapping
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/wildcard/flipped
	icon_state = "pipe-j2s"

/obj/structure/disposalpipe/sortjunction/untagged/flipped
	icon_state = "pipe-j2s"

//A trunk joining to a disposal bin or outlet on the same turf
/obj/structure/disposalpipe/trunk
	icon_state = "pipe-t"
	var/obj/linked 	//The linked obj/machinery/disposal or obj/disposaloutlet

/obj/structure/disposalpipe/trunk/Initialize(mapload)
	. = ..()
	dpdir = dir
	getlinked()
	update()

///Set the linked atom
/obj/structure/disposalpipe/trunk/proc/set_linked(obj/to_link)
	if(linked)
		UnregisterSignal(linked, COMSIG_QDELETING)
	linked = null
	if(to_link)
		linked = to_link
		RegisterSignal(linked, COMSIG_QDELETING, PROC_REF(clean_linked))

///Signal handler to clean linked from harddeling
/obj/structure/disposalpipe/trunk/proc/clean_linked()
	SIGNAL_HANDLER
	set_linked(null)

/obj/structure/disposalpipe/trunk/proc/getlinked()
	var/obj/machinery/disposal/D = locate() in loc
	if(D)
		set_linked(D)
		if(!D.trunk)
			D.set_trunk(src)

	var/obj/structure/disposaloutlet/O = locate() in loc
	if(O)
		set_linked(O)
	update()

//Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(obj/item/I, mob/user, params)
	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in loc
	if(C?.anchored)
		return

	var/turf/T = loc
	if(T.intact_tile)
		return //Prevent interaction with T-scanner revealed pipes

	. = ..()

	if(iswelder(I))
		var/obj/item/tool/weldingtool/W = I
		if(!W.remove_fuel(0, user))
			to_chat(user, span_warning("You need more welding fuel to cut the pipe."))
			return

		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		//Check if anything changed over 2 seconds
		var/turf/uloc = user.loc
		var/atom/wloc = I.loc
		user.visible_message(span_notice("[user] starts slicing [src]."),
		span_notice("You start slicing [src]."))
		sleep(3 SECONDS)
		if(!W.isOn() || user.loc != uloc && wloc != I.loc)
			to_chat(user, span_warning("You must stay still while welding the pipe."))
			return

		welded()

//Would transfer to next pipe segment, but we are in a trunk. If not entering from disposal bin, transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(obj/structure/disposalholder/H)

	if(H.dir == DOWN) //We just entered from a disposer
		return ..() //So do base transfer proc
	//Otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && H && H.loc)
			O.expel(H) //Expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H?.loc)
				D.expel(H) //Expel at disposal
	else
		if(H?.loc)
			src.expel(H, loc, 0) //Expel at turf
	return null

/obj/structure/disposalpipe/trunk/nextdir(fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

//A broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0 //Broken pipes have dpdir = 0 so they're not found as 'real' pipes i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

/obj/structure/disposalpipe/broken/Initialize(mapload)
	. = ..()
	update()

//Water Pipe, just for decor
/obj/structure/disposalpipe/water_pipe
	icon_state = "water_pipe"
	dpdir = 0 //Makes this not a real pipe
	desc = "A inlet or outlet for fluids."


//Called when welded, for broken pipe, remove and turn into scrap
/obj/structure/disposalpipe/broken/welded()
	qdel(src)

//The disposal outlet machine
/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = TRUE
	anchored = TRUE
	var/active = 0
	var/turf/target	//This will be where the output objects are 'thrown' to.
	var/mode = 0

/obj/structure/disposaloutlet/Initialize(mapload)
	. = ..()

	target = get_ranged_target_turf(src, dir, 10)
	var/obj/structure/disposalpipe/trunk/trunk = locate() in loc
	if(trunk)
		trunk.set_linked(src)	//Link the pipe trunk to self

//Expel the contents of the holder object, then delete it. Called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(obj/structure/disposalholder/H)

	flick("outlet-open", src)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 25, 0)
	sleep(2 SECONDS) //Wait until correct animation frame
	playsound(src, 'sound/machines/hiss.ogg', 25, 0)

	if(H)
		for(var/atom/movable/AM in H)
			AM.loc = src.loc
			AM.pipe_eject(dir)
			spawn(5)
				AM.throw_at(target, 3, 1)
		qdel(H)

/obj/structure/disposaloutlet/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		mode = !mode
		if(mode)
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, span_notice("You remove the screws around the power connection."))
		else
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, span_notice("You attach the screws around the power connection."))

	else if(iswelder(I) && mode)
		var/obj/item/tool/weldingtool/W = I
		if(!W.remove_fuel(0, user))
			to_chat(user, span_warning("You need more welding fuel to complete this task."))
			return

		playsound(loc, 'sound/items/welder2.ogg', 25, 1)
		to_chat(user, span_notice("You start slicing the floorweld off the disposal outlet."))

		if(!do_after(user, 20, NONE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(W, /obj/item/tool/weldingtool/proc/isOn)))
			return

		to_chat(user, span_notice("You sliced the floorweld off the disposal outlet."))
		var/obj/structure/disposalconstruct/C = new(loc)
		C.ptype = 7 //7 = outlet
		C.update()
		C.anchored = TRUE
		C.density = TRUE
		qdel(src)


/obj/structure/disposaloutlet/retrieval
	name = "retrieval outlet"
	desc = "An outlet for the pneumatic disposal system."
	resistance_flags = UNACIDABLE

/obj/structure/disposaloutlet/retrieval/attackby(obj/item/I, mob/user, params)
	return

//Called when movable is expelled from a disposal pipe or outlet, by default does nothing, override for special behaviour
/atom/movable/proc/pipe_eject(direction)
	return

//Check if mob has client, if so restore client view on eject
/mob/pipe_eject(direction)
	if(client)
		client.perspective = MOB_PERSPECTIVE
		client.eye = src

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/robot/pipe_eject(direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = GLOB.alldirs.Copy()

	streak(dirs)
