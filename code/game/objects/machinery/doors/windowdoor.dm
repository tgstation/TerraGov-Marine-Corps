/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	resistance_flags = XENO_DAMAGEABLE
	var/base_state = "left"
	max_integrity = 50
	soft_armor = list("melee" = 20, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 70, "acid" = 100)
	visible = FALSE
	use_power = FALSE
	flags_atom = ON_BORDER
	opacity = FALSE
	var/obj/item/circuitboard/airlock/electronics = null

/obj/machinery/door/window/secure
	name = "Secure Door"
	desc = "A strong, secure door."
	icon_state = "leftsecure"
	base_state = "leftsecure"
	max_integrity = 100


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


/obj/machinery/door/window/CanAllowThrough(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return TRUE
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return ..()
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

		if(istype(src, /obj/machinery/door/window/secure))
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

/obj/machinery/door/window/northleft
	dir = NORTH

/obj/machinery/door/window/eastleft
	dir = EAST

/obj/machinery/door/window/westleft
	dir = WEST

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/southleft
	dir = SOUTH

/obj/machinery/door/window/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

// Secure Doors
/obj/machinery/door/window/secure/northleft
	dir = NORTH

/obj/machinery/door/window/secure/eastleft
	dir = EAST

/obj/machinery/door/window/secure/westleft
	dir = WEST

/obj/machinery/door/window/secure/southleft
	dir = SOUTH

/obj/machinery/door/window/secure/southleft
	dir = SOUTH

/obj/machinery/door/window/secure/southleft
	dir = SOUTH

/obj/machinery/door/window/secure/northright
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/eastright
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/westright
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/southright
	dir = SOUTH
	icon_state = "right"
	base_state = "right"


// Main ship brig doors
/obj/machinery/door/window/secure/brig
	req_access = list(ACCESS_MARINE_BRIG)
	name = "Cell"
	id = "Cell"

/obj/machinery/door/window/secure/brig/cell_1
	name = "Cell 1"
	id = "Cell 1"

/obj/machinery/door/window/secure/brig/cell_2
	name = "Cell 2"
	id = "Cell 2"

/obj/machinery/door/window/secure/brig/cell_3
	name = "Cell 3"
	id = "Cell 3"

/obj/machinery/door/window/secure/brig/cell_4
	name = "Cell 4"
	id = "Cell 4"

/obj/machinery/door/window/secure/brig/cell_5
	name = "Cell 5"
	id = "Cell 5"

/obj/machinery/door/window/secure/brig/cell_6
	name = "Cell 6"
	id = "Cell 6"


// Bridge Doors
/obj/machinery/door/window/secure/northleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = NORTH

/obj/machinery/door/window/secure/eastleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = EAST

/obj/machinery/door/window/secure/westleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = WEST

/obj/machinery/door/window/secure/southleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = SOUTH

/obj/machinery/door/window/secure/southleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = SOUTH

/obj/machinery/door/window/secure/southleft/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = SOUTH

/obj/machinery/door/window/secure/northright/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/eastright/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/westright/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/southright/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

// Req Doors
/obj/machinery/door/window/secure/northleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = NORTH

/obj/machinery/door/window/secure/eastleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = EAST

/obj/machinery/door/window/secure/westleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = WEST

/obj/machinery/door/window/secure/southleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = SOUTH

/obj/machinery/door/window/secure/southleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = SOUTH

/obj/machinery/door/window/secure/southleft/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = SOUTH

/obj/machinery/door/window/secure/northright/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/eastright/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/westright/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/secure/southright/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)
	dir = SOUTH
	icon_state = "right"
	base_state = "right"

// Engi Doors
/obj/machinery/door/window/northleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = NORTH

/obj/machinery/door/window/eastleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = EAST

/obj/machinery/door/window/westleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = WEST

/obj/machinery/door/window/southleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = SOUTH

/obj/machinery/door/window/southleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = SOUTH

/obj/machinery/door/window/southleft/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = SOUTH

/obj/machinery/door/window/northright/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = NORTH
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/eastright/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = EAST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/westright/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = WEST
	icon_state = "right"
	base_state = "right"

/obj/machinery/door/window/southright/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)
	dir = SOUTH
	icon_state = "right"
	base_state = "right"
