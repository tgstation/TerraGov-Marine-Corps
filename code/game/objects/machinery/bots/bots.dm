// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	use_power = NO_POWER_USE
	resistance_flags = XENO_DAMAGEABLE
	var/obj/item/card/id/botcard			// the ID card that the bot "holds"
	var/on = TRUE
	var/open = FALSE //Maint panel
	var/locked = TRUE

/obj/machinery/bot/Destroy()
	QDEL_NULL(botcard)
	return ..()


/obj/machinery/bot/proc/turn_on()
	if(machine_stat)
		return FALSE
	on = TRUE
	set_light(initial(luminosity))
	return TRUE

/obj/machinery/bot/proc/turn_off()
	on = FALSE
	set_light(0)


/obj/machinery/bot/examine(mob/user)
	. = ..()
	if(obj_integrity < max_integrity)
		if(obj_integrity > max_integrity/3)
			to_chat(user, span_warning("[src]'s parts look loose."))
		else
			to_chat(user, span_danger("[src]'s parts look very loose!"))

/obj/machinery/bot/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(isscrewdriver(I))
		if(locked)
			return
		open = !open
		to_chat(user, span_notice("Maintenance panel is now [src.open ? "opened" : "closed"]."))

	else if(iswelder(I))
		if(obj_integrity >= max_integrity)
			to_chat(user, span_notice("[src] does not need a repair."))
			return

		if(!open)
			to_chat(user, span_notice("Unable to repair with the maintenance panel closed."))
			return

		repair_damage(10)
		user.visible_message(span_warning(" [user] repairs [src]!"),span_notice(" You repair [src]!"))


/obj/machinery/bot/emp_act(severity)
	var/was_on = on
	machine_stat |= EMPED
	new /obj/effect/overlay/temp/emp_sparks (loc)
	if(on)
		turn_off()
	spawn(severity*300)
		machine_stat &= ~EMPED
		if(was_on)
			turn_on()


/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(obj/item/card/id/ID)
	var/L[] = new()

	for(var/d in GLOB.cardinals)
		var/turf/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L

// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/card/id/ID)

	if(A == null || B == null)
		return TRUE
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return FALSE

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return FALSE
		return TRUE

	if(DirBlockedWithAccess(A,adir, ID))
		return TRUE

	if(DirBlockedWithAccess(B,rdir, ID))
		return TRUE

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flags_atom & ON_BORDER))
			return TRUE

	return FALSE

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc, dir, obj/item/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.dir == SOUTHWEST)
			return TRUE
		if(D.dir == dir)
			return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)
			continue
		if(istype(D, /obj/machinery/door/window))
			if( dir & D.dir )
				return !D.check_access(ID)

			//if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return !D.check_access(ID)
			//if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return !D.check_access(ID)
		else return !D.check_access(ID)	// it's a real, air blocking door
	return FALSE
