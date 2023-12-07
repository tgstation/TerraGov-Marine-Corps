/obj/machinery/door/window
	name = "interior door"
	desc = "A strong door."
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "left"
	layer = ABOVE_WINDOW_LAYER
	resistance_flags = XENO_DAMAGEABLE
	obj_flags = CAN_BE_HIT
	var/base_state = "left"
	max_integrity = 50
	soft_armor = list(MELEE = 20, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 100, FIRE = 70, ACID = 100)
	visible = FALSE
	use_power = FALSE
	flags_atom = ON_BORDER
	allow_pass_flags = PASS_GLASS
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
	if(dir == NORTH)
		add_overlay(image(icon, "rwindow_overlay", layer = WINDOW_LAYER))
		layer = ABOVE_TABLE_LAYER
	if(set_dir)
		setDir(set_dir)
	if(length(req_access))
		icon_state = "[icon_state]"
		base_state = icon_state
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit)
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/door/window/Destroy()
	density = FALSE
	playsound(src, "shatter", 50, 1)
	return ..()


/obj/machinery/door/window/update_icon()
	if(operating)
		return
	icon_state = density ? base_state : "[base_state]open"


/obj/machinery/door/window/proc/open_and_close()
	open()
	var/time_to_close = check_access(null) ? 5 SECONDS : 2 SECONDS
	addtimer(CALLBACK(src, PROC_REF(close)), time_to_close)

/obj/machinery/door/window/Bumped(atom/movable/bumper)
	if(operating || !density)
		return
	if(!isliving(bumper))
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
	addtimer(CALLBACK(src, PROC_REF(finish_open)), 1 SECONDS)
	return TRUE

/obj/machinery/door/window/finish_open()
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

	addtimer(CALLBACK(src, PROC_REF(finish_close)), 1 SECONDS)
	return TRUE

/obj/machinery/door/window/finish_close()
	operating = FALSE


/obj/machinery/door/window/attack_ai(mob/living/silicon/ai/AI)
	return try_to_activate_door(AI)


/obj/machinery/door/window/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(operating)
		return TRUE

	else if(operating == -1 && iscrowbar(I))
		playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
		user.visible_message("[user] starts to remove the electronics from the windoor.", "You start to remove electronics from the windoor.")

		if(!do_after(user, 40, NONE, src, BUSY_ICON_BUILD))
			return TRUE

		to_chat(user, span_notice("You removed the windoor electronics!"))

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



/obj/machinery/door/window/right
	icon_state = "right"
	base_state = "right"

// Secure Doors
/obj/machinery/door/window/secure/right
	icon_state = "rightsecure"
	base_state = "rightsecure"

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
/obj/machinery/door/window/secure/bridge
	req_access = list(ACCESS_MARINE_BRIDGE)

/obj/machinery/door/window/secure/bridge/right
	icon_state = "rightsecure"
	base_state = "rightsecure"

/obj/machinery/door/window/secure/bridge/aidoor //special door with similar integrity to protective ai glass
	max_integrity = 1200

// Req Doors
/obj/machinery/door/window/secure/req
	req_one_access = list(ACCESS_MARINE_LOGISTICS, ACCESS_MARINE_CARGO)

/obj/machinery/door/window/secure/req/right
	icon_state = "rightsecure"
	base_state = "rightsecure"

// Engi Doors
/obj/machinery/door/window/secure/engineering
	req_access = list(ACCESS_MARINE_ENGINEERING)

/obj/machinery/door/window/secure/engineering/right
	icon_state = "rightsecure"
	base_state = "rightsecure"

// Med Doors
/obj/machinery/door/window/secure/medical
	req_access = list(ACCESS_MARINE_CHEMISTRY)
