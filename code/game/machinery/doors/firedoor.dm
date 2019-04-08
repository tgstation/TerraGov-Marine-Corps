// Door open and close constants
/var/const
	CLOSED = 2

#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
#define FIREDOOR_MAX_TEMP 50 // °C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT      1
#define FIREDOOR_ALERT_COLD     2


/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(ACCESS_CIVILIAN_ENGINEERING)
	opacity = FALSE
	density = FALSE
	layer = FIREDOOR_OPEN_LAYER
	open_layer = FIREDOOR_OPEN_LAYER // Just below doors when open
	closed_layer = FIREDOOR_CLOSED_LAYER // Just above doors when closed
	power_channel = ENVIRON
	use_power = TRUE
	idle_power_usage = 5

	var/blocked = FALSE
	var/lockdown = FALSE // When the door has detected a problem, it locks.
	var/pdiff_alert = FALSE
	var/pdiff = FALSE
	var/nextstate = null
	var/net_id
	var/list/areas_added
	var/list/users_to_open = new
	var/next_process_time = 0

	var/list/tile_info[4]
	var/list/dir_alerts[4] // 4 dirs, bitflags

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

/obj/machinery/door/firedoor/Initialize()
	. = ..()
	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			flags_atom |= INITIALIZED
			return INITIALIZE_HINT_QDEL
	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			A.all_doors.Add(src)
			areas_added += A

/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	. = ..()


/obj/machinery/door/firedoor/examine(mob/user)
	..()
	if(get_dist(src, user) > 1 && !isAI(user))
		return

	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		to_chat(user, "<span class='warning'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>")

	to_chat(user, "<b>Sensor readings:</b>")
	for(var/index = 1; index <= tile_info.len; index++)
		var/o = "&nbsp;&nbsp;"
		switch(index)
			if(1)
				o += "NORTH: "
			if(2)
				o += "SOUTH: "
			if(3)
				o += "EAST: "
			if(4)
				o += "WEST: "
		if(tile_info[index] == null)
			o += "<span class='warning'>DATA UNAVAILABLE</span>"
			to_chat(user, o)
			continue
		var/celsius = convert_k2c(tile_info[index][1])
		var/pressure = tile_info[index][2]
		if(dir_alerts[index] & (FIREDOOR_ALERT_HOT|FIREDOOR_ALERT_COLD))
			o += "<span class='warning'>"
		else
			o += "<span style='color:blue'>"
		o += "[celsius]&deg;C</span> "
		o += "<span style='color:blue'>"
		o += "[pressure]kPa</span></li>"
		to_chat(user, o)

	if(islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		to_chat(user, "These people have opened \the [src] during an alert: [users_to_open_string].")

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)
		return
	if(!density)
		return ..()
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if(mecha.occupant)
			var/mob/M = mecha.occupant
			if(world.time - M.last_bumped <= 10)
				return //Can bump-open one airlock per second. This is to prevent popup message spam.
			M.last_bumped = world.time
			attack_hand(M)
	return FALSE

/obj/machinery/door/firedoor/attack_alien(mob/living/carbon/Xenomorph/M)
	var/turf/cur_loc = M.loc
	if(blocked)
		to_chat(M, "<span class='warning'>\The [src] is welded shut.</span>")
		return FALSE
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(!density)
		to_chat(M, "<span class='warning'>\The [src] is already open!</span>")
		return FALSE

	playsound(src.loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	M.visible_message("<span class='warning'>\The [M] digs into \the [src] and begins to pry it open.</span>", \
	"<span class='warning'>You dig into \the [src] and begin to pry it open.</span>", null, 5)

	if(do_after(M, 30, FALSE, 5, BUSY_ICON_HOSTILE))
		if(M.loc != cur_loc)
			return FALSE //Make sure we're still there
		if(blocked)
			to_chat(M, "<span class='warning'>\The [src] is welded shut.</span>")
			return FALSE
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)
				M.visible_message("<span class='danger'>\The [M] pries \the [src] open.</span>", \
				"<span class='danger'>You pry \the [src] open.</span>", null, 5)

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	var/alarmed = lockdown
	for(var/area/A in areas_added)		//Checks if there are fire alarms in any areas associated with that firedoor
		if(A.flags_alarm_state & ALARM_WARNING_FIRE || A.air_doors_activated)
			alarmed = TRUE

	var/answer = alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density ? "\nNote that by doing so, you acknowledge any damages from opening this\n[src.name] as being your own fault, and you will be held accountable under the law." : ""]",\
	"\The [src]", "Yes, [density ? "open" : "close"]", "No")
	if(answer == "No")
		return
	if(user.incapacitated() || (!user.canmove && !isAI(user)) || (get_dist(src, user) > 1  && !isAI(user)))
		to_chat(user, "Sorry, you must remain able bodied and close to \the [src] in order to use it.")
		return
	if(density && (machine_stat & (BROKEN|NOPOWER))) //can still close without power
		to_chat(user, "\The [src] is not functioning, you'll have to force it open manually.")
		return

	if(alarmed && density && lockdown && !allowed(user))
		to_chat(user, "<span class='warning'>Access denied.  Please wait for authorities to arrive, or for the alert to clear.</span>")
		return
	else
		user.visible_message("<span class='notice'>\The [src] [density ? "open" : "close"]s for \the [user].</span>",\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")

	var/needs_to_close = FALSE
	if(density)
		if(alarmed)
			// Accountability!
			users_to_open |= user.name
			needs_to_close = TRUE
		spawn()
			open()
	else
		spawn()
			close()

	if(needs_to_close)
		spawn(50)
			alarmed = FALSE
			for(var/area/A in areas_added)		//Just in case a fire alarm is turned off while the firedoor is going through an autoclose cycle
				if(A.flags_alarm_state & ALARM_WARNING_FIRE || A.air_doors_activated)
					alarmed = TRUE
			if(alarmed)
				nextstate = CLOSED
				close()

/obj/machinery/door/firedoor/attackby(obj/item/C as obj, mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.
	if(iswelder(C))
		var/obj/item/tool/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message("<span class='danger'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].</span>",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			update_icon()
			return

	else if(C.pry_capable)
		if(operating)
			return

		if(blocked)
			user.visible_message("<span class='danger'>\The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!</span>",\
			"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
			"You hear someone struggle and metal straining.")
			return

		user.visible_message("<span class='danger'>\The [user] starts to force \the [src] [density ? "open" : "closed"] with \a [C]!</span>",\
				"<span class='notice'>You start forcing \the [src] [density ? "open" : "closed"] with \the [C]!</span>",\
				"You hear metal strain.")
		var/old_density = density
		if(do_after(user,30, TRUE, 5, BUSY_ICON_HOSTILE))
			if(blocked || density != old_density)
				return
			user.visible_message("<span class='danger'>\The [user] forces \the [blocked ? "welded " : "" ][name] [density ? "open" : "closed"] with \a [C]!</span>",\
				"<span class='notice'>You force \the [blocked ? "welded " : ""][name] [density ? "open" : "closed"] with \the [C]!</span>",\
				"You hear metal strain and groan, and a door [density ? "opening" : "closing"].")
			spawn(0)
				if(density)
					open(1)
				else
					close()
		return TRUE //no afterattack call
	else
		if(blocked)
			to_chat(user, "<span class='danger'>\The [src] is welded solid!</span>")
			return
	if(istype(C, /obj/item/weapon/zombie_claws))
		if(operating)
			return
		user.visible_message("<span class='danger'>\The zombie starts to force \the [src] [density ? "open" : "closed"] with it's claws!!!</span>",\
				"You start forcing \the [src] [density ? "open" : "closed"] with your claws!",\
				"You hear metal strain.")
		if(do_after(user,150, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='danger'>\The [user] forces \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \a [C]!</span>",\
			"You force \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \the [C]!",\
			"You hear metal strain and groan, and a door [density ? "opening" : "closing"].")
			if(density)
				spawn(0)
					open(1)
			else
				spawn(0)
					close()
			return

/obj/machinery/door/firedoor/try_to_activate_door(mob/user)
	return


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || !nextstate)
		return
	switch(nextstate)
		if(OPEN)
			nextstate = null
			open()
		if(CLOSED)
			nextstate = null
			close()
	return

/obj/machinery/door/firedoor/close()
	latetoggle()
	return ..()

/obj/machinery/door/firedoor/open(var/forced = 0)
	if(!forced)
		if(machine_stat & (BROKEN|NOPOWER))
			return //needs power to open unless it was forced
		else
			use_power(360)
	else
		log_admin("[key_name(usr)] has forced open an emergency shutter at [AREACOORD(usr.loc)].")
		message_admins("[ADMIN_TPMONTY(usr)] has forced open an emergency shutter.")
	latetoggle()
	return ..()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	playsound(loc, 'sound/machines/emergency_shutter.ogg', 25)
	return


/obj/machinery/door/firedoor/update_icon()
	overlays.Cut()
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += "welded"
		if(pdiff_alert)
			overlays += "palert"
		if(dir_alerts)
			for(var/d=1;d<=4;d++)
				var/cdir = cardinal[d]
				for(var/i=1;i<=ALERT_STATES.len;i++)
					if(dir_alerts[d] & (1<<(i-1)))
						overlays += new/icon(icon,"alert_[ALERT_STATES[i]]", dir=cdir)
	else
		icon_state = "door_open"
		if(blocked)
			overlays += "welded_open"
	return


/obj/machinery/door/firedoor/theseus
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/almayer/purinadoor.dmi'
	icon_state = "door_open"
	openspeed = 4


/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2


/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags_atom = ON_BORDER


/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE


/obj/machinery/door/firedoor/border_only/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.checkpass(PASSGLASS)))
		return TRUE
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		return !density
	else
		return TRUE


/obj/machinery/door/firedoor/border_only/CheckExit(atom/movable/mover as mob|obj, turf/target)
	if(istype(mover) && (mover.checkpass(PASSGLASS)))
		return TRUE
	if(get_dir(loc, target) == dir)
		return !density
	else
		return TRUE