/obj/machinery/door
	name = "\improper Door"
	desc = "It opens and closes."
	icon = 'icons/obj/doors/Doorint.dmi'
	icon_state = "door1"
	anchored = TRUE
	opacity = TRUE
	density = TRUE
	allow_pass_flags = NONE
	move_resist = MOVE_FORCE_VERY_STRONG
	layer = DOOR_OPEN_LAYER
	explosion_block = 2
	resistance_flags = DROPSHIP_IMMUNE
	minimap_color = MINIMAP_DOOR
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 100, FIRE = 80, ACID = 70)
	var/open_layer = DOOR_OPEN_LAYER
	var/closed_layer = DOOR_CLOSED_LAYER
	var/id
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
	//used for determining emergency access
	var/emergency = FALSE

	//Multi-tile doors
	dir = EAST
	var/width = 1

/obj/machinery/door/Initialize(mapload)
	. = ..()
	if(density)
		layer = closed_layer
		update_flags_heat_protection(get_turf(src))
	else
		layer = open_layer

	if(width > 1)
		handle_multidoor()
	var/turf/current_turf = get_turf(src)
	current_turf.flags_atom &= ~ AI_BLOCKED

	if(glass)
		allow_pass_flags |= PASS_GLASS

/obj/machinery/door/Destroy()
	for(var/o in fillers)
		qdel(o)
	return ..()

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
		if(TIMER_COOLDOWN_CHECK(M, COOLDOWN_BUMP))
			return	//This is to prevent shock spam.
		TIMER_COOLDOWN_START(M, COOLDOWN_BUMP, openspeed)
		if(!M.restrained() && M.mob_size > MOB_SIZE_SMALL)
			bumpopen(M)
		return

	if(isuav(AM))
		try_to_activate_door(AM)
		return

	if(isobj(AM))
		var/obj/O = AM
		for(var/m in O.buckled_mobs)
			Bumped(m)

/obj/machinery/door/proc/bumpopen(mob/user as mob)
	if(operating)
		return

	if(!src.requiresID())
		user = null

	if(density)
		if(allowed(user) || emergency)
			open()
		else
			flick("door_deny", src)


/obj/machinery/door/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	return try_to_activate_door(user)

/obj/machinery/door/proc/try_to_activate_door(atom/user)
	if(operating)
		return
	var/can_open = !Adjacent(user) || !requiresID() || ismob(user) && allowed(user)
	if(!Adjacent(user))
		can_open = TRUE
	if(!requiresID())
		can_open = TRUE
	if(ismob(user) && allowed(user))
		can_open = TRUE
	if(isuav(user))
		can_open = TRUE
	if(can_open)
		if(density)
			open()
		else
			close()
	else if(density)
		flick("door_deny", src)


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
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(25))
				qdel(src)
		if(EXPLODE_LIGHT)
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
	SIGNAL_HANDLER_DOES_SLEEP
	if(operating || welded || locked || !loc)
		return FALSE
	operating = TRUE
	do_animate("opening")
	icon_state = "door0"
	set_opacity(FALSE)
	for(var/t in fillers)
		var/obj/effect/opacifier/O = t
		O.set_opacity(FALSE)
	addtimer(CALLBACK(src, PROC_REF(finish_open)), openspeed)
	return TRUE

/obj/machinery/door/proc/finish_open()
	layer = open_layer
	density = FALSE
	update_icon()

	if(operating)
		operating = FALSE

	if(autoclose)
		addtimer(CALLBACK(src, PROC_REF(autoclose)), normalspeed ? 150 + openspeed : 5)

/obj/machinery/door/proc/close()
	SIGNAL_HANDLER_DOES_SLEEP
	if(density)
		return TRUE
	if(operating)
		return FALSE
	operating = TRUE

	density = TRUE
	layer = closed_layer
	do_animate("closing")
	addtimer(CALLBACK(src, PROC_REF(finish_close)), openspeed)

/obj/machinery/door/proc/finish_close()
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

/obj/machinery/door/morgue
	icon = 'icons/obj/doors/doormorgue.dmi'
