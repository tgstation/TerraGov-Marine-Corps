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
	anchored = 1
	density = 1
	var/mode = 1 //Item mode 0=off 1=charging 2=charged
	var/flush = 0 //True if flush handle is pulled
	var/obj/structure/disposalpipe/trunk/trunk = null //The attached pipe trunk
	var/flushing = 0 //True if flushing in progress
	var/flush_every_ticks = 30 //Every 30 ticks it will look whether it is ready to flush
	var/flush_count = 0 //This var adds 1 once per tick. When it reaches flush_every_ticks it resets and tries to flush.
	var/last_sound = 0
	active_power_usage = 3500 //The pneumatic pump power. 3 HP ~ 2200W
	idle_power_usage = 100
	var/disposal_pressure = 0

//Create a new disposal, find the attached trunk (if present) and init gas resvr.
/obj/machinery/disposal/New()
	..()
	spawn(5)
		trunk = locate() in loc
		if(!trunk)
			mode = 0
			flush = 0
		else
			trunk.linked = src	//Link the pipe trunk to self

		update()
		start_processing()

//Attack by item places it in to disposal
/obj/machinery/disposal/attackby(var/obj/item/I, var/mob/user)
	if(stat & BROKEN || !I || !user)
		return

	if(isXeno(user)) //No, fuck off. Concerns trashing Marines and facehuggers
		return

	add_fingerprint(user)
	if(mode <= 0) //It's off
		if(istype(I, /obj/item/tool/screwdriver))
			if(contents.len > 0)
				user << "<span class='warning'>Eject the contents first!</span>"
				return
			if(mode == 0) //It's off but still not unscrewed
				mode = -1 //Set it to doubleoff
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user << "<span class='notice'>You remove the screws around the power connection.</span>"
				return
			else if(mode == -1)
				mode = 0
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				user << "<span class='notice'>You attach the screws around the power connection.</span>"
				return
		else if(istype(I, /obj/item/tool/weldingtool) && mode == -1)
			if(contents.len > 0)
				user << "<span class='warning'>Eject the contents first!</span>"
				return
			var/obj/item/tool/weldingtool/W = I
			if(W.remove_fuel(0, user))
				playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
				user << "<span class='notice'>You start slicing the floorweld off the disposal unit.</span>"
				if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
					if(!src || !W.isOn()) return
					user << "<span class='notice'>You sliced the floorweld off the disposal unit.</span>"
					var/obj/structure/disposalconstruct/C = new(loc)
					transfer_fingerprints_to(C)
					C.ptype = 6 //6 = disposal unit
					C.anchored = 1
					C.density = 1
					C.update()
					cdel(src)
			else
				user << "<span class='warning'>You need more welding fuel to complete this task.</span>"
			return

	if(istype(I, /obj/item/storage/bag/trash))
		var/obj/item/storage/bag/trash/T = I
		user << "<span class='notice'>You empty the bag into [src].</span>"
		for(var/obj/item/O in T.contents)
			T.remove_from_storage(O, src)
		T.update_icon()
		update()
		return

	var/obj/item/grab/G = I
	if(istype(G)) //Handle grabbed mob
		if(ismob(G.grabbed_thing) && user.grab_level >= GRAB_AGGRESSIVE)
			var/mob/GM = G.grabbed_thing
			user.visible_message("<span class='warning'>[user] starts putting [GM] into [src].</span>",
			"<span class='warning'>You start putting [GM] into [src].</span>")
			if(do_after(user, 20, TRUE, 5, BUSY_ICON_HOSTILE))
				GM.forceMove(src)
				user.visible_message("<span class='warning'>[user] puts [GM] into [src].</span>",
				"<span class='warning'>[user] puts [GM] into [src].</span>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has placed [GM] ([GM.ckey]) in disposals.</font>")
				GM.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been placed in disposals by [user] ([user.ckey])</font>")
				msg_admin_attack("[user] ([user.ckey]) placed [GM] ([GM.ckey]) in a disposals unit. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				flush()
		return

	if(isrobot(user))
		return
	if(!I)
		return

	if(user.drop_inv_item_to_loc(I, src))
		user.visible_message("<span class='notice'>[user] places [I] into [src].</span>",
		"<span class='notice'>You place [I] into [src].</span>")
	update()

//Mouse drop another mob or self
/obj/machinery/disposal/MouseDrop_T(mob/target, mob/user)
	if(!istype(target) || target.anchored || target.buckled || get_dist(user, src) > 1 || get_dist(user, target) > 1 || user.is_mob_incapacitated(TRUE) || istype(user, /mob/living/silicon/ai) || target.mob_size >= MOB_SIZE_BIG)
		return
	if(isanimal(user) && target != user) return //Animals cannot put mobs other than themselves into disposal
	add_fingerprint(user)
	var/target_loc = target.loc

	if(target == user)
		visible_message("<span class='notice'>[user] starts climbing into the disposal.</span>")
	else
		if(user.is_mob_restrained()) return //can't stuff someone other than you if restrained.
		visible_message("<span class ='warning'>[user] starts stuffing [target] into the disposal.</span>")
	if(!do_after(user, 40, FALSE, 5, BUSY_ICON_HOSTILE))
		return
	if(target_loc != target.loc)
		return
	if(target == user)
		if(user.is_mob_incapacitated(TRUE)) return
		user.visible_message("<span class='notice'>[user] climbs into [src].</span>",
		"<span class ='notice'>You climb into [src].</span>")
	else
		if(user.is_mob_incapacitated()) return
		user.visible_message("<span class ='danger'>[user] stuffs [target] into [src]!</span>",
		"<span class ='warning'>You stuff [target] into [src]!</span>")

		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Has placed [target.name] ([target.ckey]) in disposals.</font>")
		target.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been placed in disposals by [user.name] ([user.ckey])</font>")
		msg_admin_attack("[user] ([user.ckey]) placed [target] ([target.ckey]) in a disposals unit. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

	target.forceMove(src)
	flush()
	update()

//Can breath normally in the disposal
/obj/machinery/disposal/alter_health()
	return get_turf(src)

//Attempt to move while inside
/obj/machinery/disposal/relaymove(mob/user)
	if(user.stat || user.stunned || user.knocked_down || flushing)
		return
	if(user.loc == src)
		go_out(user)

//Leave the disposal
/obj/machinery/disposal/proc/go_out(mob/user)

	if(user.client)
		user.client.eye = user.client.mob
		user.client.perspective = MOB_PERSPECTIVE
	user.forceMove(loc)
	user.stunned = max(user.stunned, 2)  //Action delay when going out of a bin
	user.update_canmove() //Force the delay to go in action immediately
	if(!user.lying)
		user.visible_message("<span class='warning'>[user] suddenly climbs out of [src]!",
		"<span class='warning'>You climb out of [src] and get your bearings!")
		update()

//Monkeys can only pull the flush lever
/obj/machinery/disposal/attack_paw(mob/user as mob)
	if(stat & BROKEN)
		return

	flush = !flush
	update()

//AI as human but can't flush
/obj/machinery/disposal/attack_ai(mob/user as mob)
	interact(user, 1)

//Human interact with machine
/obj/machinery/disposal/attack_hand(mob/user as mob)
	if(user && user.loc == src)
		usr << "\red You cannot reach the controls from inside."
		return

	interact(user, 0)

//User interaction
/obj/machinery/disposal/interact(mob/user, var/ai=0)

	add_fingerprint(user)
	if(stat & BROKEN)
		user.unset_interaction()
		return

	var/dat = "<head><title>Waste Disposal Unit</title></head><body><TT><B>Waste Disposal Unit</B><HR>"

	if(!ai)  //AI can't pull flush handle
		if(flush)
			dat += "Disposal handle: <A href='?src=\ref[src];handle=0'>Disengage</A> <B>Engaged</B>"
		else
			dat += "Disposal handle: <B>Disengaged</B> <A href='?src=\ref[src];handle=1'>Engage</A>"

		dat += "<BR><HR><A href='?src=\ref[src];eject=1'>Eject contents</A><HR>"

	if(mode <= 0)
		dat += "Pump: <B>Off</B> <A href='?src=\ref[src];pump=1'>On</A><BR>"
	else if(mode == 1)
		dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (pressurizing)<BR>"
	else
		dat += "Pump: <A href='?src=\ref[src];pump=0'>Off</A> <B>On</B> (idle)<BR>"

	dat += "Pressure: [disposal_pressure*100/SEND_PRESSURE]%<BR></body>"

	user.set_interaction(src)
	user << browse(dat, "window=disposal;size=360x170")
	onclose(user, "disposal")

//Handle machine interaction
/obj/machinery/disposal/Topic(href, href_list)
	if(usr.loc == src)
		usr << "<span class='warning'>You cannot reach the controls from inside.</span>"
		return

	if(mode == -1 && !href_list["eject"]) // only allow ejecting if mode is -1
		usr << "<span class='warning'>The disposal units power is disabled.</span>"
		return
	..()
	add_fingerprint(usr)
	if(stat & BROKEN)
		return
	if(usr.stat || usr.is_mob_restrained() || flushing)
		return
	if(in_range(src, usr) && istype(src.loc, /turf))
		usr.set_interaction(src)

		if(href_list["close"])
			usr.unset_interaction()
			usr << browse(null, "window=disposal")
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
	else
		usr << browse(null, "window=disposal")
		usr.unset_interaction()
		return

//Eject the contents of the disposal unit
/obj/machinery/disposal/proc/eject()
	for(var/atom/movable/AM in src)
		AM.loc = loc
		AM.pipe_eject(0)
		if(ismob(AM))
			var/mob/M = AM
			M.stunned = max(M.stunned, 2)  //Action delay when going out of a bin
			M.update_canmove() //Force the delay to go in action immediately
			if(!M.lying)
				M.visible_message("<span class='warning'>[M] is suddenly pushed out of [src]!",
				"<span class='warning'>You get pushed out of [src] and get your bearings!")
	update()

//Pipe affected by explosion
/obj/machinery/disposal/ex_act(severity)
	switch(severity)
		if(1)
			cdel(src)
			return
		if(2)
			if(prob(60))
				cdel(src)
			return
		if(3)
			if(prob(25))
				cdel(src)

/obj/machinery/disposal/Dispose()
	if(contents.len)
		eject()
	. = ..()

//Update the icon & overlays to reflect mode & status
/obj/machinery/disposal/proc/update()
	overlays.Cut()
	if(stat & BROKEN)
		icon_state = "disposal-broken"
		mode = 0
		flush = 0
		return

	//Flush handle
	if(flush)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-handle")

	//Only handle is shown if no power
	if(stat & NOPOWER || mode == -1)
		return

	//Check for items in disposal - occupied light
	if(contents.len > 0)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-full")

	//Charging and ready light
	if(mode == 1)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-charge")
	else if(mode == 2)
		overlays += image('icons/obj/pipes/disposal.dmi', "dispover-ready")

//Timed process, charge the gas reservoir and perform flush if ready
/obj/machinery/disposal/process()
	if(stat & BROKEN) //Nothing can happen if broken
		update_use_power(0)
		return

	flush_count++
	if(flush_count >= flush_every_ticks)
		if(contents.len)
			if(mode == 2)
				spawn(0)
					feedback_inc("disposal_auto_flush", 1)
					flush()
		flush_count = 0

	updateDialog()

	if(flush && disposal_pressure >= SEND_PRESSURE) //Flush can happen even without power
		flush()

	if(mode != 1) //If off or ready, no need to charge
		update_use_power(1)
	else if(disposal_pressure >= SEND_PRESSURE)
		mode = 2 //If full enough, switch to ready mode
		update()
	else
		pressurize() //Otherwise charge

/obj/machinery/disposal/proc/pressurize()
	if(disposal_pressure < SEND_PRESSURE)
		disposal_pressure += 5
	return

//Perform a flush
/obj/machinery/disposal/proc/flush()

	flushing = 1
	flick("[icon_state]-flush", src)

	var/wrapcheck = 0
	var/obj/structure/disposalholder/H = new()	//Virtual holder object which actually
												//Travels through the pipes.
	//Hacky test to get drones to mail themselves through disposals.
	for(var/mob/living/silicon/robot/drone/D in src)
		wrapcheck = 1

	for(var/obj/item/smallDelivery/O in src)
		wrapcheck = 1

	if(wrapcheck == 1)
		H.tomail = 1

	sleep(10)
	if(last_sound < world.time + 1)
		playsound(src, 'sound/machines/disposalflush.ogg', 15, 0)
		last_sound = world.time
	sleep(5) //Wait for animation to finish

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
	return

//Called when area power changes
/obj/machinery/disposal/power_change()
	..()	//Do default setting/reset of stat NOPOWER bit
	update()	//Update icon
	return

//Called when holder is expelled from a disposal, should usually only occur if the pipe network is modified
/obj/machinery/disposal/proc/expel(var/obj/structure/disposalholder/H)
	var/turf/target
	playsound(src, 'sound/machines/hiss.ogg', 25, 0)
	if(H) //Somehow, someone managed to flush a window which broke mid-transit and caused the disposal to go in an infinite loop trying to expel null, hopefully this fixes it
		for(var/atom/movable/AM in H)
			target = get_offset_target_turf(loc, rand(5) - rand(5), rand(5) - rand(5))
			AM.loc = loc
			AM.pipe_eject(0)
			if(!istype(AM, /mob/living/silicon/robot/drone)) //Poor drones kept smashing windows and taking system damage being fired out of disposals. ~Z
				spawn(1)
					if(AM)
						AM.throw_at(target, 5, 1)
		cdel(H)

/obj/machinery/disposal/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/item) && mover.throwing)
		var/obj/item/I = mover
		if(istype(I, /obj/item/projectile))
			return
		if(prob(75))
			I.loc = src
			visible_message("<span class='notice'>[I] lands into [src].</span>")
		else
			visible_message("<span class='warning'>[I] bounces off of [src]'s rim!</span>")
		return 0
	else
		return ..()

//Virtual disposal object, travels through pipes in lieu of actual items
//Contents will be items flushed by the disposal, this allows the gas flushed to be tracked
/obj/structure/disposalholder
	invisibility = 101
	var/active = 0	//True if the holder is moving, otherwise inactive
	dir = 0
	var/count = 2048 //Can travel 2048 steps before going inactive (in case of loops)
	var/has_fat_guy = 0	//True if contains a fat person
	var/destinationTag = "" //Changes if contains a delivery container
	var/tomail = 0 //Changes if contains wrapped package
	var/hasmob = 0 //If it contains a mob

	var/partialTag = "" //Set by a partial tagger the first time round, then put in destinationTag if it goes through again.

/obj/structure/disposalholder/Dispose()
		active = 0
		. = ..()

//initialize a holder from the contents of a disposal unit
/obj/structure/disposalholder/proc/init(var/obj/machinery/disposal/D)

	//Check for any living mobs trigger hasmob.
	//hasmob effects whether the package goes to cargo or its tagged destination.
	for(var/mob/living/M in D)
		if(M && M.stat != DEAD && !istype(M, /mob/living/silicon/robot/drone))
			hasmob = 1

	//Checks 1 contents level deep. This means that players can be sent through disposals...
	//...but it should require a second person to open the package. (i.e. person inside a wrapped locker)
	for(var/obj/O in D)
		if(O.contents)
			for(var/mob/living/M in O.contents)
				if(M && M.stat != 2 && !istype(M, /mob/living/silicon/robot/drone))
					hasmob = 1

	//Now everything inside the disposal gets put into the holder
	//Note AM since can contain mobs or objs
	for(var/atom/movable/AM in D)
		AM.loc = src
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			if(FAT in H.mutations) //Is a human and fat?
				has_fat_guy = 1 //Set flag on holder
		if(istype(AM, /obj/structure/bigDelivery) && !hasmob)
			var/obj/structure/bigDelivery/T = AM
			destinationTag = T.sortTag
		if(istype(AM, /obj/item/smallDelivery) && !hasmob)
			var/obj/item/smallDelivery/T = AM
			destinationTag = T.sortTag
		//Drones can mail themselves through maint.
		if(istype(AM, /mob/living/silicon/robot/drone))
			var/mob/living/silicon/robot/drone/drone = AM
			destinationTag = drone.mail_destination

//Start the movement process
//Argument is the disposal unit the holder started in
/obj/structure/disposalholder/proc/start(var/obj/machinery/disposal/D)

	if(!D.trunk)
		D.expel(src) //No trunk connected, so expel immediately
		return

	loc = D.trunk
	active = 1
	dir = DOWN
	spawn(1)
		move() //Spawn off the movement process

//Movement process, persists while holder is moving through pipes
/obj/structure/disposalholder/proc/move()

	var/obj/structure/disposalpipe/last
	while(active)
		if(hasmob && prob(3))
			for(var/mob/living/H in src)
				if(!istype(H, /mob/living/silicon/robot/drone)) //Drones use the mailing code to move through the disposal system,
					if(map_tag != MAP_WHISKEY_OUTPOST)
						H.take_overall_damage(20, 0, "Blunt Trauma") //Horribly maim any living creature jumping down disposals.  c'est la vie

		if(has_fat_guy && prob(2)) //Chance of becoming stuck per segment if contains a fat guy
			active = 0
			//Find the fat guys
			for(var/mob/living/carbon/human/H in src)

			break
		sleep(1) //Was 1
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
/obj/structure/disposalholder/proc/findpipe(var/turf/T)

	if(!T)
		return null

	var/fdir = turn(dir, 180) //Flip the movement direction
	for(var/obj/structure/disposalpipe/P in T)
		if(fdir & P.dpdir) //Find pipe direction mask that matches flipped dir
			return P
	//If no matching pipe, return null
	return null

//Merge two holder objects
//Used when a a holder meets a stuck holder
/obj/structure/disposalholder/proc/merge(var/obj/structure/disposalholder/other)
	for(var/atom/movable/AM in other)
		AM.loc = src //Move everything in other holder to this one
		if(ismob(AM))
			var/mob/M = AM
			if(M.client) //If a client mob, update eye to follow this holder
				M.client.eye = src

	if(other.has_fat_guy)
		has_fat_guy = 1
	cdel(other)

/obj/structure/disposalholder/proc/settag(var/new_tag)
	destinationTag = new_tag

/obj/structure/disposalholder/proc/setpartialtag(var/new_tag)
	if(partialTag == new_tag)
		destinationTag = new_tag
		partialTag = ""
	else
		partialTag = new_tag


//Called when player tries to move while in a pipe
/obj/structure/disposalholder/relaymove(mob/user as mob)

	if(!isliving(user))
		return

	var/mob/living/U = user

	if(U.stat || U.last_special <= world.time)
		return

	U.last_special = world.time + 100

	playsound(src.loc, 'sound/effects/clang.ogg', 25, 0)


//Disposal pipes
/obj/structure/disposalpipe
	icon = 'icons/obj/pipes/disposal.dmi'
	name = "disposal pipe"
	desc = "An underfloor disposal pipe."
	anchored = 1
	density = 0

	level = 1			//Underfloor only
	var/dpdir = 0		//Bitmask of pipe directions
	dir = 0				//dir will contain dominant direction for junction pipes
	var/health = 10 	//Health points 0-10
	layer = DISPOSAL_PIPE_LAYER //Slightly lower than wires and other pipes
	var/base_icon_state	//Initial icon state on map

	//New pipe, set the icon_state as on map
	New()
		..()
		base_icon_state = icon_state
		return


//Pipe is deleted
//Ensure if holder is present, it is expelled
/obj/structure/disposalpipe/Dispose()
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
			cdel(H)
			..()
			return

		//Otherwise, do normal expel from turf
		if(H)
			expel(H, T, 0)
	. = ..()

//Returns the direction of the next pipe object, given the entrance dir by default, returns the bitmask of remaining directions
/obj/structure/disposalpipe/proc/nextdir(var/fromdir)
	return dpdir & (~turn(fromdir, 180))

//Transfer the holder through this pipe segment, overriden for special behaviour
/obj/structure/disposalpipe/proc/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir
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
	hide(T.intact_tile && !istype(T, /turf/open/space)) //Space never hides pipes

//Hide called by levelupdate if turf intact status changes, change visibility status and force update of icon
/obj/structure/disposalpipe/hide(var/intact)
	invisibility = intact ? 101: 0	// hide if floor is intact
	updateicon()

//Update actual icon_state depending on visibility, if invisible, append "f" to icon_state to show faded version, this will be revealed if a T-scanner is used
//If visible, use regular icon_state
/obj/structure/disposalpipe/proc/updateicon()

	icon_state = base_icon_state

//Expel the held objects into a turf. called when there is a break in the pipe
/obj/structure/disposalpipe/proc/expel(var/obj/structure/disposalholder/H, var/turf/T, var/direction)

	var/turf/target

	if(T.density) //Dense ouput turf, so stop holder
		H.active = 0
		H.loc = src
		return
	if(istype(T, /turf/open/floor)) //intact floor, pop the tile
		var/turf/open/floor/F = T
		if(!F.is_plating())
			if(!F.broken && !F.burnt)
				new F.floor_tile.type(H)//Add to holder so it will be thrown with other stuff
			F.make_plating()

	if(direction) //Direction is specified
		if(istype(T, /turf/open/space)) //If ended in space, then range is unlimited
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
			cdel(H)

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

			cdel(H)

//Call to break the pipe, will expel any holder inside at the time then delete the pipe
//Remains : set to leave broken pipe pieces in place
/obj/structure/disposalpipe/proc/broken(var/remains = 0)
	if(remains)
		for(var/D in cardinal)
			if(D & dpdir)
				var/obj/structure/disposalpipe/broken/P = new(loc)
				P.dir = D

	invisibility = 101	//Make invisible (since we won't delete the pipe immediately)
	var/obj/structure/disposalholder/H = locate() in src
	if(H)
		//Holder was present
		H.active = 0
		var/turf/T = src.loc
		if(T.density)
			//Broken pipe is inside a dense turf (wall)
			//This is unlikely, but just dump out everything into the turf in case
			for(var/atom/movable/AM in H)
				AM.loc = T
				AM.pipe_eject(0)
			cdel(H)
			return

		//Otherwise, do normal expel from turf
		if(H && H.loc)
			expel(H, T, 0)

	spawn(2) //Delete pipe after 2 ticks to ensure expel proc finished
		cdel(src)

//Pipe affected by explosion
/obj/structure/disposalpipe/ex_act(severity)

	switch(severity)
		if(1)
			broken(0)
			return
		if(2)
			health -= rand(5, 15)
			healthcheck()
			return
		if(3)
			health -= rand(0, 15)
			healthcheck()
			return

//Test health for brokenness
/obj/structure/disposalpipe/proc/healthcheck()
	if(health < -2)
		broken(0)
	else if(health < 1)
		broken(1)

//Attack by item. Weldingtool: unfasten and convert to obj/disposalconstruct
/obj/structure/disposalpipe/attackby(var/obj/item/I, var/mob/user)

	var/turf/T = loc
	if(T.intact_tile)
		return //Prevent interaction with T-scanner revealed pipes
	add_fingerprint(user)
	if(istype(I, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/W = I

		if(W.remove_fuel(0, user))
			playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
			//Check if anything changed over 2 seconds
			var/turf/uloc = user.loc
			var/atom/wloc = W.loc
			user.visible_message("<span class='notice'>[user] starts slicing [src].</span>",
			"<span class='notice'>You start slicing [src].</span>")
			sleep(30)
			if(!W.isOn()) return
			if(user.loc == uloc && wloc == W.loc)
				welded()
			else
				user << "<span class='warning'>You must stay still while welding [src].</span>"
		else
			user << "<span class='warning'>You need more welding fuel to cut [src].</span>"

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
	transfer_fingerprints_to(C)
	C.dir = dir
	C.density = 0
	C.anchored = 1
	C.update()
	cdel(src)

//A straight or bent segment
/obj/structure/disposalpipe/segment
	icon_state = "pipe-s"

	New()
		..()
		if(icon_state == "pipe-s")
			dpdir = dir|turn(dir, 180)
		else
			dpdir = dir|turn(dir, -90)
		update()

//Z-Level stuff
/obj/structure/disposalpipe/up
	icon_state = "pipe-u"

	New()
		..()
		dpdir = dir
		update()

/obj/structure/disposalpipe/up/nextdir(var/fromdir)
	var/nextdir
	if(fromdir == 11)
		nextdir = dir
	else
		nextdir = 12
	return nextdir

/obj/structure/disposalpipe/up/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir

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

	New()
		..()
		dpdir = dir
		update()

/obj/structure/disposalpipe/down/nextdir(var/fromdir)
	var/nextdir
	if(fromdir == 12)
		nextdir = dir
	else
		nextdir = 11
	return nextdir

/obj/structure/disposalpipe/down/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir

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

// *** special cased almayer stuff because its all one z level ***

/obj/structure/disposalpipe/up/almayer
	var/id

/obj/structure/disposalpipe/down/almayer
	var/id

/obj/structure/disposalpipe/up/almayer/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 12)
		for(var/obj/structure/disposalpipe/down/almayer/F in structure_list)
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

/obj/structure/disposalpipe/down/almayer/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.dir = nextdir

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 11)
		for(var/obj/structure/disposalpipe/up/almayer/F in structure_list)
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

// *** end special cased almayer stuff ***

//Z-Level stuff
//A three-way junction with dir being the dominant direction
/obj/structure/disposalpipe/junction
	icon_state = "pipe-j1"

	New()
		..()
		if(icon_state == "pipe-j1")
			dpdir = dir|turn(dir, -90)|turn(dir, 180)
		else if(icon_state == "pipe-j2")
			dpdir = dir|turn(dir, 90)|turn(dir, 180)
		else //Pipe-y
			dpdir = dir|turn(dir,90)|turn(dir, -90)
		update()

//Next direction to move, if coming in from secondary dirs, then next is primary dir, if coming in from primary dir, then next is equal chance of other dirs
/obj/structure/disposalpipe/junction/nextdir(var/fromdir)
	var/flipdir = turn(fromdir, 180)
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

	New()
		. = ..()
		dpdir = dir|turn(dir, 180)
		if(sort_tag) tagger_locations |= sort_tag
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

/obj/structure/disposalpipe/tagger/attackby(var/obj/item/I, var/mob/user)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag) //Tag set
			sort_tag = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)
			user << "<span class='notice'>Changed tag to '[sort_tag]'.</span>"
			updatename()
			updatedesc()

/obj/structure/disposalpipe/tagger/transfer(var/obj/structure/disposalholder/H)
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

	New()
		. = ..()
		if(sortType) tagger_locations |= sortType

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
	negdir = turn(posdir, 180)

	if(icon_state == "pipe-j1s")
		sortdir = turn(posdir, -90)
	else if(icon_state == "pipe-j2s")
		sortdir = turn(posdir, 90)

	dpdir = sortdir|posdir|negdir

/obj/structure/disposalpipe/sortjunction/attackby(var/obj/item/I, var/mob/user)
	if(..())
		return

	if(istype(I, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = I

		if(O.currTag) //Tag set
			sortType = O.currTag
			playsound(loc, 'sound/machines/twobeep.ogg', 25, 1)
			user << "<span class='notice'>Changed filter to '[sortType]'.</span>"
			updatename()
			updatedesc()

/obj/structure/disposalpipe/sortjunction/proc/divert_check(var/checkTag)
	return sortType == checkTag

//Next direction to move, if coming in from negdir, then next is primary dir or sortdir, if coming in from posdir, then flip around and go back to posdir, if coming in from sortdir, go to posdir
/obj/structure/disposalpipe/sortjunction/nextdir(var/fromdir, var/sortTag)
	if(fromdir != sortdir) //Probably came from the negdir
		if(divert_check(sortTag))
			return sortdir
		else
			return posdir
	else //Came from sortdir so go with the flow to positive direction
		return posdir

/obj/structure/disposalpipe/sortjunction/transfer(var/obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir, H.destinationTag)
	H.dir = nextdir
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

/obj/structure/disposalpipe/sortjunction/wildcard/divert_check(var/checkTag)
	return checkTag != ""

//Junction that filters all untagged items
/obj/structure/disposalpipe/sortjunction/untagged
	name = "untagged sorting junction"
	desc = "An underfloor disposal pipe which filters all untagged items."

/obj/structure/disposalpipe/sortjunction/untagged/divert_check(var/checkTag)
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

/obj/structure/disposalpipe/trunk/New()
	..()
	dpdir = dir
	spawn(1)
		getlinked()
	update()

/obj/structure/disposalpipe/trunk/proc/getlinked()
	linked = null
	var/obj/machinery/disposal/D = locate() in loc
	if(D)
		linked = D
		if(!D.trunk)
			D.trunk = src

	var/obj/structure/disposaloutlet/O = locate() in loc
	if(O)
		linked = O
	update()

//Override attackby so we disallow trunkremoval when somethings ontop
/obj/structure/disposalpipe/trunk/attackby(var/obj/item/I, var/mob/user)

	//Disposal constructors
	var/obj/structure/disposalconstruct/C = locate() in loc
	if(C && C.anchored)
		return
	var/turf/T = loc
	if(T.intact_tile)
		return //Prevent interaction with T-scanner revealed pipes
	add_fingerprint(user)
	if(istype(I, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/W = I
		if(W.remove_fuel(0, user))
			playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
			//Check if anything changed over 2 seconds
			var/turf/uloc = user.loc
			var/atom/wloc = W.loc
			user.visible_message("<span class='notice'>[user] starts slicing [src].</span>",
			"<span class='notice'>You start slicing [src].</span>")
			sleep(30)
			if(!W.isOn()) return
			if(user.loc == uloc && wloc == W.loc)
				welded()
			else
				user << "<span class='warning'>You must stay still while welding the pipe.</span>"
		else
			user << "<span class='warning'>You need more welding fuel to cut the pipe.</span>"

//Would transfer to next pipe segment, but we are in a trunk. If not entering from disposal bin, transfer to linked object (outlet or bin)
/obj/structure/disposalpipe/trunk/transfer(var/obj/structure/disposalholder/H)

	if(H.dir == DOWN) //We just entered from a disposer
		return ..() //So do base transfer proc
	//Otherwise, go to the linked object
	if(linked)
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O) && H && H.loc)
			O.expel(H) //Expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			if(H && H.loc)
				D.expel(H) //Expel at disposal
	else
		if(H && H.loc)
			src.expel(H, loc, 0) //Expel at turf
	return null

/obj/structure/disposalpipe/trunk/nextdir(var/fromdir)
	if(fromdir == DOWN)
		return dir
	else
		return 0

//A broken pipe
/obj/structure/disposalpipe/broken
	icon_state = "pipe-b"
	dpdir = 0 //Broken pipes have dpdir = 0 so they're not found as 'real' pipes i.e. will be treated as an empty turf
	desc = "A broken piece of disposal pipe."

	New()
		..()
		update()

//Called when welded, for broken pipe, remove and turn into scrap
/obj/structure/disposalpipe/broken/welded()
	cdel(src)

//The disposal outlet machine
/obj/structure/disposaloutlet
	name = "disposal outlet"
	desc = "An outlet for the pneumatic disposal system."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "outlet"
	density = 1
	anchored = 1
	var/active = 0
	var/turf/target	//This will be where the output objects are 'thrown' to.
	var/mode = 0

	New()
		..()

		spawn(1)
			target = get_ranged_target_turf(src, dir, 10)
			var/obj/structure/disposalpipe/trunk/trunk = locate() in loc
			if(trunk)
				trunk.linked = src	//Link the pipe trunk to self

//Expel the contents of the holder object, then delete it. Called when the holder exits the outlet
/obj/structure/disposaloutlet/proc/expel(var/obj/structure/disposalholder/H)

	flick("outlet-open", src)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 25, 0)
	sleep(20) //Wait until correct animation frame
	playsound(src, 'sound/machines/hiss.ogg', 25, 0)

	if(H)
		for(var/atom/movable/AM in H)
			AM.loc = src.loc
			AM.pipe_eject(dir)
			if(!istype(AM, /mob/living/silicon/robot/drone)) //Drones keep smashing windows from being fired out of chutes. Bad for the station. ~Z
				spawn(5)
					AM.throw_at(target, 3, 1)
		cdel(H)

/obj/structure/disposaloutlet/attackby(var/obj/item/I, var/mob/user)
	if(!I || !user)
		return
	add_fingerprint(user)
	if(istype(I, /obj/item/tool/screwdriver))
		if(mode == 0)
			mode = 1
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			user << "<span class='notice'>You remove the screws around the power connection.</span>"
		else if(mode == 1)
			mode = 0
			playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
			user << "<span class='notice'>You attach the screws around the power connection.</span>"
	else if(istype(I, /obj/item/tool/weldingtool) && mode == 1)
		var/obj/item/tool/weldingtool/W = I
		if(W.remove_fuel(0, user))
			playsound(loc, 'sound/items/Welder2.ogg', 25, 1)
			user << "<span class='notice'>You start slicing the floorweld off the disposal outlet.</span>"
			if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
				if(!src || !W.isOn()) return
				user << "<span class='notice'>You sliced the floorweld off the disposal outlet.</span>"
				var/obj/structure/disposalconstruct/C = new(loc)
				transfer_fingerprints_to(C)
				C.ptype = 7 //7 =  outlet
				C.update()
				C.anchored = 1
				C.density = 1
				cdel(src)
		else
			user << "<span class='warning'>You need more welding fuel to complete this task.</span>"

/obj/structure/disposaloutlet/retrieval
	name = "retrieval outlet"
	desc = "An outlet for the pneumatic disposal system."
	unacidable = 1

/obj/structure/disposaloutlet/retrieval/attackby(var/obj/item/I, var/mob/user)
	return

//Called when movable is expelled from a disposal pipe or outlet, by default does nothing, override for special behaviour
/atom/movable/proc/pipe_eject(var/direction)
	return

//Check if mob has client, if so restore client view on eject
/mob/pipe_eject(var/direction)
	if(client)
		client.perspective = MOB_PERSPECTIVE
		client.eye = src

/obj/effect/decal/cleanable/blood/gibs/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	streak(dirs)

/obj/effect/decal/cleanable/blood/gibs/robot/pipe_eject(var/direction)
	var/list/dirs
	if(direction)
		dirs = list( direction, turn(direction, -45), turn(direction, 45))
	else
		dirs = alldirs.Copy()

	streak(dirs)
