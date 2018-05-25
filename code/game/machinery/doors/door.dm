
/obj/machinery/door
	name = "\improper Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = 1
	opacity = 1
	density = 1
	layer = DOOR_OPEN_LAYER
	var/open_layer = DOOR_OPEN_LAYER
	var/closed_layer = DOOR_CLOSED_LAYER
	var/id = ""

	var/secondsElectrified = 0
	var/visible = 1
	var/p_open = 0
	var/operating = 0
	var/autoclose = 0
	var/glass = 0
	var/normalspeed = 1
	var/openspeed = 10 //How many seconds does it take to open it? Default 1 second. Use only if you have long door opening animations
	var/heat_proof = 0 // For glass airlocks/opacity firedoors
	var/air_properties_vary_with_direction = 0
	var/turf/filler //Fixes double door opacity issue


	//Multi-tile doors
	dir = EAST
	var/width = 1

	New()
		. = ..()
		if(density)
			layer = closed_layer
			explosion_resistance = initial(explosion_resistance)
			update_flags_heat_protection(get_turf(src))
		else
			layer = open_layer
			explosion_resistance = 0

		handle_multidoor()

	Dispose()
		. = ..()
		if(filler && width > 1)
			filler.SetOpacity(0)// Ehh... let's hope there are no walls there. Must fix this
			filler = null
		density = 0

/obj/machinery/door/proc/handle_multidoor()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
			filler = get_step(src,EAST)
			filler.SetOpacity(opacity)
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size
			filler = get_step(src,NORTH)
			filler.SetOpacity(opacity)

//process()
	//return

/obj/machinery/door/Bumped(atom/AM)
	if(p_open || operating) return
	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= openspeed) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.is_mob_restrained() && M.mob_size > MOB_SIZE_SMALL)
			bumpopen(M)
		return

	if(istype(AM, /obj))
		var/obj/O = AM
		if(O.buckled_mob)
			Bumped(O.buckled_mob)

	if(istype(AM, /obj/machinery/bot))
		var/obj/machinery/bot/bot = AM
		if(src.check_access(bot.botcard))
			if(density)
				open()
		return

	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(density)
			if(mecha.occupant && (src.allowed(mecha.occupant) || src.check_access_list(mecha.operation_req_access)))
				open()
			else
				flick("door_deny", src)


/obj/machinery/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if(operating)	return
	src.add_fingerprint(user)
	if(!src.requiresID())
		user = null

	if(density)
		if(allowed(user))	open()
		else				flick("door_deny", src)
	return

/obj/machinery/door/attack_ai(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_paw(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_hand(mob/user)
	return try_to_activate_door(user)

/obj/machinery/door/attack_tk(mob/user)
	if(requiresID() && !allowed(null))
		return
	..()

/obj/machinery/door/proc/try_to_activate_door(mob/user)
	add_fingerprint(user)
	if(operating || emagged)
		return
	if(!Adjacent(user))
		user = null //so allowed(user) always succeeds
	if(!requiresID())
		user = null //so allowed(user) always succeeds
	if(allowed(user))
		if(density)
			open()
		else
			close()
		return
	if(density)
		flick("door_deny", src)


/obj/machinery/door/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/card/emag))
		if(!operating && density && operable())
			flick("door_spark", src)
			sleep(6)
			open()
			operating = -1
		return 1
	else if(!(I.flags_item & NOBLUDGEON))
		try_to_activate_door(user)
		return 1

/obj/machinery/door/emp_act(severity)
	if(prob(20/severity) && (istype(src,/obj/machinery/door/airlock) || istype(src,/obj/machinery/door/window)) )
		open()
	if(prob(40/severity))
		if(secondsElectrified == 0)
			secondsElectrified = -1
			spawn(300)
				secondsElectrified = 0
	..()


/obj/machinery/door/ex_act(severity)
	if(unacidable) return

	switch(severity)
		if(1.0)
			cdel(src)
		if(2.0)
			if(prob(25))
				cdel(src)
		if(3.0)
			if(prob(80))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()
	return


/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"
	return


/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(p_open)
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(p_open)
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)
	return


/obj/machinery/door/proc/open()
	if(!density)		return 1
	if(operating > 0 || !loc)	return
	if(!ticker)			return 0
	if(!operating)		operating = 1

	do_animate("opening")
	icon_state = "door0"
	src.SetOpacity(0)
	sleep(openspeed)
	src.layer = open_layer
	src.density = 0
	explosion_resistance = 0
	update_icon()
	SetOpacity(0)
	if (filler)
		filler.SetOpacity(0)

	if(operating)	operating = 0

	if(autoclose  && normalspeed)
		spawn(150 + openspeed)
			autoclose()
	if(autoclose && !normalspeed)
		spawn(5)
			autoclose()

	return 1


/obj/machinery/door/proc/close()
	if(density)	return 1
	if(operating > 0 || !loc)	return
	operating = 1

	src.density = 1
	explosion_resistance = initial(explosion_resistance)
	src.layer = closed_layer
	do_animate("closing")
	sleep(openspeed)
	update_icon()
	if(visible && !glass)
		SetOpacity(1)	//caaaaarn!
		if (filler)
			filler.SetOpacity(0)
	operating = 0
	return

/obj/machinery/door/proc/requiresID()
	return 1


/obj/machinery/door/proc/update_flags_heat_protection(var/turf/source)


/obj/machinery/door/proc/autoclose()
	var/obj/machinery/door/airlock/A = src
	if(!A.density && !A.operating && !A.locked && !A.welded && A.autoclose)
		close()
	return

/obj/machinery/door/Move(new_loc, new_dir)
	. = ..()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
			filler.SetOpacity(0)
			filler = (get_step(src,EAST)) //Find new turf
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size
			filler.SetOpacity(0)
			filler = (get_step(src,NORTH)) //Find new turf


/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
