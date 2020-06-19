/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	resistance_flags = XENO_DAMAGEABLE
	var/base_state = "left"
	max_integrity = 150 //If you change this, consiter changing ../door/window/brigdoor/ health at the bottom of this .dm file
	soft_armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	visible = FALSE
	use_power = FALSE
	flags_atom = ON_BORDER
	opacity = FALSE
	var/obj/item/circuitboard/airlock/electronics = null


/obj/machinery/door/window/Initialize(mapload, set_dir)
	. = ..()
	if(set_dir)
		setDir(set_dir)
	if(length(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state


/obj/machinery/door/window/Destroy()
	density = FALSE
	playsound(src, "shatter", 50, 1)
	. = ..()


/obj/machinery/door/window/update_icon()
	if(operating)
		return
	icon_state = density ? base_state : "[base_state]open"


/obj/machinery/door/window/proc/open_and_close()
	open()
	if(check_access(null))
		sleep(5 SECONDS)
	else //secure doors close faster
		sleep(2 SECONDS)
	close()


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
	if(!requiresID())
		user = null

	if(allowed(user))
		open_and_close()
	else
		do_animate("deny")


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
	icon_state = "[base_state]open"
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
	icon_state = base_state
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

		var/obj/structure/windoor_assembly/WA = new(loc)

		if(istype(src, /obj/machinery/door/window/brigdoor))
			WA.secure = "secure_"
			WA.name = "Secure Wired Windoor Assembly"
		else
			WA.name = "Wired Windoor Assembly"

		if(base_state == "right" || base_state == "rightsecure")
			WA.facing = "r"

		WA.setDir(dir)
		WA.state = "02"
		WA.update_icon()

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
			flick("[base_state]opening", src)
		if("closing")
			flick("[base_state]closing", src)
		if("deny")
			flick("[base_state]deny", src)


/obj/machinery/door/window/brigdoor
	name = "Secure Door"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "leftsecure"
	base_state = "leftsecure"
	req_access = list(ACCESS_MARINE_BRIG)
	max_integrity = 300 //Stronger doors for prison (regular window door health is 200)


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
	base_state = "right"

/obj/machinery/door/window/northright/briefing
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright/briefing
	req_access = list(ACCESS_MARINE_BRIG)

/obj/machinery/door/window/eastright/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

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
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/eastright
	dir = EAST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/westright
	dir = WEST
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/brigdoor/southright
	dir = SOUTH
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/mainship/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
