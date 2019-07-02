/obj/machinery/door
	name = "\improper Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = TRUE
	opacity = TRUE
	density = TRUE
	layer = DOOR_OPEN_LAYER
	var/open_layer = DOOR_OPEN_LAYER
	var/closed_layer = DOOR_CLOSED_LAYER
	var/id
	armor = list("melee" = 30, "bullet" = 30, "laser" = 20, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 70)
	var/secondsElectrified = 0
	var/visible = TRUE
	var/operating = FALSE
	var/autoclose = FALSE
	var/glass = FALSE
	var/normalspeed = TRUE
	var/locked = FALSE
	var/welded = FALSE
	var/not_weldable = FALSE // stops people welding the door if true
	var/openspeed = 10 //How many seconds does it take to open it? Default 1 second. Use only if you have long door opening animations
	var/list/fillers

	//Multi-tile doors
	dir = EAST
	var/width = 1

/obj/machinery/door/Initialize()
	. = ..()
	if(density)
		layer = closed_layer
		update_flags_heat_protection(get_turf(src))
	else
		layer = open_layer

	if(width > 1)
		handle_multidoor()

/obj/machinery/door/Destroy()
	. = ..()
	for(var/o in fillers)
		qdel(o)
	density = FALSE

/obj/machinery/door/proc/handle_multidoor()
	fillers = list()

	if(dir in list(EAST, WEST))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size

	var/turf/T = get_turf(src)
	for(var/i = 2 to width)
		T = get_step(T,dir)
		fillers += new /obj/effect/opacifier(T, opacity)

/obj/machinery/door/Bumped(atom/AM)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) || operating)
		return

	if(ismob(AM))
		var/mob/M = AM
		if(world.time - M.last_bumped <= openspeed) return	//Can bump-open one airlock per second. This is to prevent shock spam.
		M.last_bumped = world.time
		if(!M.restrained() && M.mob_size > MOB_SIZE_SMALL)
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


/obj/machinery/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return !opacity
	return !density

/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if(operating)
		return

	if(!src.requiresID())
		user = null

	if(density)
		if(allowed(user))
			open()
		else
			flick("door_deny", src)

/obj/machinery/door/attack_ai(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_paw(mob/user)
	return src.attack_hand(user)


/obj/machinery/door/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	return try_to_activate_door(user)

/obj/machinery/door/proc/try_to_activate_door(mob/user)
	if(operating || CHECK_BITFIELD(obj_flags, EMAGGED))
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


/obj/machinery/door/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/emag))
		if(!operating && density && is_operational())
			flick("door_spark", src)
			sleep(6)
			open()
		return TRUE

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
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(25))
				qdel(src)
		if(3.0)
			if(prob(80))
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(2, 1, src)
				s.start()


/obj/machinery/door/update_icon()
	if(density)
		icon_state = "door1"
	else
		icon_state = "door0"

/obj/machinery/door/proc/do_animate(animation)
	switch(animation)
		if("opening")
			if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
				flick("o_doorc0", src)
			else
				flick("doorc0", src)
		if("closing")
			if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
				flick("o_doorc1", src)
			else
				flick("doorc1", src)
		if("deny")
			flick("door_deny", src)


/obj/machinery/door/proc/open()
	if(!density)
		return TRUE
	if(operating > 0 || !loc)
		return
	if(!SSticker)
		return FALSE
	if(!operating)
		operating = TRUE

	do_animate("opening")
	icon_state = "door0"
	set_opacity(FALSE)
	for(var/t in fillers)
		var/obj/effect/opacifier/O = t
		O.set_opacity(FALSE)
	sleep(openspeed)
	layer = open_layer
	density = FALSE
	update_icon()

	if(operating)
		operating = FALSE

	if(autoclose)
		addtimer(CALLBACK(src, .proc/autoclose), normalspeed ? 150 + openspeed : 5)

	return TRUE


/obj/machinery/door/proc/close()
	if(density)
		return TRUE
	if(operating > 0 || !loc)
		return
	operating = TRUE

	density = TRUE
	layer = closed_layer
	do_animate("closing")
	sleep(openspeed)
	update_icon()
	if(visible && !glass)
		set_opacity(TRUE)	//caaaaarn!
		for(var/t in fillers)
			var/obj/effect/opacifier/O = t
			O.set_opacity(TRUE)
	operating = FALSE

/obj/machinery/door/proc/requiresID()
	return TRUE

/obj/machinery/door/proc/hasPower()
	return !CHECK_BITFIELD(machine_stat, NOPOWER)

/obj/machinery/door/proc/update_flags_heat_protection(turf/source)

/obj/machinery/door/proc/autoclose()
	if(!density && !operating && !locked && !welded && autoclose)
		close()

/obj/machinery/door/Move(new_loc, new_dir)
	. = ..()

	if(width > 1)
		var/turf/T = get_turf(src)
		var/expansion_dir = initial(dir)

		for(var/t in fillers)
			var/obj/effect/opacifier/O = t
			T = get_step(T,expansion_dir)
			O.loc = T

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
