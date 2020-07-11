/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 150 //If you change this, consiter changing ../door/window/brigdoor/ health at the bottom of this .dm file
	soft_armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	visible = FALSE
	use_power = FALSE
	flags_atom = ON_BORDER
	opacity = FALSE
	///Determines sprite and animation variant, according to from which direction it opens.
	var/facing_direction = OPENS_TO_LEFT
	///Icon base state to apply variants.
	var/state_variant = ""
	///When the windoor faces NORTH, the layer becomes this. When it faces another cardinal direction it goes back to its initial value.
	var/north_facing_layer = BELOW_TABLE_LAYER
	///In how long the door tries to close after opening.
	var/closing_time = 5 SECONDS
	///Type of assembly this can be deconstructed into.
	var/assembly_type = /obj/structure/windoor_assembly
	///Circuit to build new of this kind of machine.
	var/obj/item/circuitboard/airlock/electronics = null


/obj/machinery/door/window/Initialize(mapload, set_dir, obj/item/circuitboard/airlock/electronics, facing_direction, state_variant)
	. = ..()

	if(electronics)
		if(electronics.one_access)
			req_access = null
			req_one_access = electronics.conf_access
		else
			req_access = electronics.conf_access
		src.electronics = electronics
		electronics.forceMove(src)

	if(facing_direction)
		src.facing_direction = facing_direction

	if(state_variant)
		src.state_variant = state_variant

	if(set_dir)
		setDir(set_dir) //Icon will be updated here.

	else if(dir == NORTH)
		layer = north_facing_layer


/obj/machinery/door/window/Destroy()
	density = FALSE
	playsound(src, "shatter", 50, TRUE)
	if(electronics)
		QDEL_NULL(electronics)
	return ..()


/obj/machinery/door/window/setDir(newdir)
	. = ..()
	switch(dir)
		if(NORTH)
			layer = north_facing_layer
		if(SOUTH, WEST, EAST)
			layer = initial(layer)


/obj/machinery/door/window/update_icon()
	if(operating)
		return
	icon_state = density ? "[facing_direction][state_variant]" : "[facing_direction][state_variant]open"


/obj/machinery/door/window/proc/open_and_close()
	open()
	if(closing_time)
		addtimer(CALLBACK(src, .proc/close), closing_time)


/obj/machinery/door/window/Bumped(atom/movable/bumper)
	if(operating || !density)
		return
	if(!(isliving(bumper)))
		var/obj/machinery/bot/bot = bumper
		if(istype(bot))
			if(density && check_access(bot.botcard))
				open_and_close()
			else
				do_animate("deny")
		return
	var/mob/living/living_bumper = bumper
	if (living_bumper.mob_size <= MOB_SIZE_SMALL || living_bumper.restrained())
		return
	bumpopen(living_bumper)


/obj/machinery/door/window/bumpopen(mob/user)
	if(operating || !density)
		return
	add_fingerprint(user, "bumpopen")
	if(requiresID() && !allowed(user))
		do_animate("deny")
		return
	open_and_close()


/obj/machinery/door/window/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return TRUE
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return TRUE

/obj/machinery/door/window/CheckExit(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return TRUE
	if(get_dir(loc, target) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/window/open(forced = DOOR_NOT_FORCED)
	if(operating)
		return FALSE
	switch(forced)
		if(DOOR_NOT_FORCED)
			if(!hasPower())
				return FALSE
	if(!operating)
		operating = TRUE
	icon_state = "[facing_direction][state_variant]open"
	do_animate("opening")
	playsound(src, 'sound/machines/windowdoor.ogg', 25, 1)
	sleep(1 SECONDS)

	density = FALSE

	if(operating)
		operating = FALSE
	return TRUE


/obj/machinery/door/window/close(forced = DOOR_NOT_FORCED)
	if(operating)
		return FALSE
	switch(forced)
		if(DOOR_NOT_FORCED)
			if(!hasPower())
				return FALSE
	operating = TRUE
	icon_state = "[facing_direction][state_variant]"
	do_animate("closing")
	playsound(src, 'sound/machines/windowdoor.ogg', 25, 1)

	density = TRUE

	sleep(1 SECONDS)

	operating = FALSE
	return TRUE


/obj/machinery/door/window/attack_ai(mob/living/silicon/ai/AI)
	return try_to_activate_door(AI)


/obj/machinery/door/window/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(operating)
		return TRUE

	else if(operating == -1 && iscrowbar(I))
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		user.visible_message("[user] starts to remove the electronics from the windoor.", "You start to remove electronics from the windoor.")

		if(!do_after(user, 40, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

		to_chat(user, "<span class='notice'>You removed the windoor electronics!</span>")

		new assembly_type(loc, dir, facing_direction, WINDOOR_ASSEMBLY_WIRED)

		var/obj/item/circuitboard/airlock/E
		if(!electronics)
			E = new(loc)
			if(!req_access)
				check_access()
			if(length(req_access))
				E.conf_access = req_access
			else if(length(req_one_access))
				E.conf_access = req_one_access
				E.one_access = TRUE
		else
			E = electronics
			electronics = null
			E.forceMove(loc)

		E.icon_state = "door_electronics_smoked"
		operating = 0
		qdel(src)


/obj/machinery/door/window/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[facing_direction][state_variant]opening", src)
		if("closing")
			flick("[facing_direction][state_variant]closing", src)
		if("deny")
			flick("[facing_direction][state_variant]deny", src)


/obj/machinery/door/window/right
	icon_state = "right"
	facing_direction = OPENS_TO_RIGHT


/obj/machinery/door/window/brigdoor
	name = "Secure Door"
	icon_state = "leftsecure"
	state_variant = "secure"
	req_access = list(ACCESS_MARINE_BRIG)
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)
	assembly_type = /obj/structure/windoor_assembly/secure
	closing_time = 2 SECONDS


// Main ship brig doors
/obj/machinery/door/window/brigdoor/mainship
	name = "Cell"
	id = "Cell"
	max_integrity = 500

/obj/machinery/door/window/brigdoor/mainship/cell_1
	name = "Cell 1"
	id = "Cell 1"

/obj/machinery/door/window/brigdoor/mainship/cell_2
	name = "Cell 2"
	id = "Cell 2"

/obj/machinery/door/window/brigdoor/mainship/cell_3
	name = "Cell 3"
	id = "Cell 3"

/obj/machinery/door/window/brigdoor/mainship/cell_4
	name = "Cell 4"
	id = "Cell 4"

/obj/machinery/door/window/brigdoor/mainship/cell_5
	name = "Cell 5"
	id = "Cell 5"

/obj/machinery/door/window/brigdoor/mainship/cell_6
	name = "Cell 6"
	id = "Cell 6"

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/northleft/brig
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/northleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/eastleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)

/obj/machinery/door/window/eastleft/brig
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/westleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/window/westleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/window/westleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)


/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/southleft/brig
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/southleft/briefing
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/northright/briefing
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/eastright/briefing
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/eastright/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/brigdoor/northleft
	dir = NORTH

/obj/machinery/door/window/brigdoor/eastleft
	dir = EAST

/obj/machinery/door/window/brigdoor/westleft
	dir = WEST

/obj/machinery/door/window/brigdoor/southleft
	dir = SOUTH

/obj/machinery/door/window/brigdoor/northright
	dir = NORTH
	icon_state = "rightsecure"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	facing_direction = OPENS_TO_RIGHT


/obj/machinery/door/window/mainship/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)


/obj/machinery/door/window/short
	icon_state = "leftshort"
	state_variant = "short"
	north_facing_layer = ABOVE_WINDOW_LAYER
	assembly_type = /obj/structure/windoor_assembly/short

/obj/machinery/door/window/short/right
	icon_state = "rightshort"
	state_variant = "short"
	facing_direction = OPENS_TO_RIGHT

/obj/machinery/door/window/short/secure
	name = "Secure Door"
	icon_state = "leftshortsecure"
	state_variant = "shortsecure"
	max_integrity = 300
	assembly_type = /obj/structure/windoor_assembly/short/secure
	closing_time = 2 SECONDS

/obj/machinery/door/window/short/secure/right
	icon_state = "rightshortsecure"
	state_variant = "shortsecure"
	facing_direction = OPENS_TO_RIGHT
