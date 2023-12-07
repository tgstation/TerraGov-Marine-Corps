#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
#define FIREDOOR_MAX_TEMP 50 // °C
#define FIREDOOR_MIN_TEMP 0

// Bitflags
#define FIREDOOR_ALERT_HOT 1
#define FIREDOOR_ALERT_COLD 2


/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(ACCESS_CIVILIAN_ENGINEERING)
	opacity = FALSE
	density = FALSE
	obj_flags = CAN_BE_HIT
	allow_pass_flags = NONE
	layer = FIREDOOR_OPEN_LAYER
	open_layer = FIREDOOR_OPEN_LAYER // Just below doors when open
	closed_layer = FIREDOOR_CLOSED_LAYER // Just above doors when closed
	power_channel = ENVIRON
	use_power = TRUE
	idle_power_usage = 5
	active_power_usage = 360

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

/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			flags_atom |= INITIALIZED
			return INITIALIZE_HINT_QDEL
	var/area/A = get_area(src)
	ASSERT(istype(A))

	LAZYADD(A.all_fire_doors, src)
	areas_added = list(A)

	for(var/direction in GLOB.cardinals)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			LAZYADD(A.all_fire_doors, src)
			areas_added += A

/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		LAZYREMOVE(A.all_fire_doors, src)
	return ..()


/obj/machinery/door/firedoor/examine(mob/user) // todo remove the shitty o vars
	. = ..()
	if(get_dist(src, user) > 1 && !isAI(user))
		return

	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		. += span_warning("WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!")

	. += "<b>Sensor readings:</b>"
	for(var/index = 1; index <= length(tile_info); index++)
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
			o += span_warning("DATA UNAVAILABLE")
			. += o
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
		. += o

	if(islist(users_to_open) && length(users_to_open))
		var/users_to_open_string = users_to_open[1]
		if(length(users_to_open) >= 2)
			for(var/i = 2 to length(users_to_open))
				users_to_open_string += ", [users_to_open[i]]"
		. += "These people have opened \the [src] during an alert: [users_to_open_string]."

/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) || operating)
		return
	if(!density)
		return ..()
	return FALSE

/obj/machinery/door/firedoor/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	var/turf/cur_loc = X.loc
	if(blocked)
		to_chat(X, span_warning("\The [src] is welded shut."))
		return FALSE
	if(!istype(cur_loc))
		return FALSE //Some basic logic here
	if(!density)
		to_chat(X, span_warning("\The [src] is already open!"))
		return FALSE

	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	X.visible_message(span_warning("\The [X] digs into \the [src] and begins to pry it open."), \
	span_warning("We dig into \the [src] and begin to pry it open."), null, 5)

	if(do_after(X, 30, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
		if(blocked)
			to_chat(X, span_warning("\The [src] is welded shut."))
			return FALSE
		if(density) //Make sure it's still closed
			spawn(0)
				open(1)
				X.visible_message(span_danger("\The [X] pries \the [src] open."), \
				span_danger("We pry \the [src] open."), null, 5)

/obj/machinery/door/firedoor/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(operating)
		return//Already doing something.

	if(blocked)
		to_chat(user, span_warning("\The [src] is welded solid!"))
		return

	var/alarmed = lockdown
	for(var/area/A in areas_added)		//Checks if there are fire alarms in any areas associated with that firedoor
		if(A.flags_alarm_state & ALARM_WARNING_FIRE || A.air_doors_activated)
			alarmed = TRUE

	var/answer = tgui_alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density ? "\nNote that by doing so, you acknowledge any damages from opening this\n[src.name] as being your own fault, and you will be held accountable under the law." : ""]",\
	"\The [src]", list("Yes, [density ? "open" : "close"]", "No"))
	if(answer == "No" || !answer)
		return
	if(user.incapacitated() || (!user.canmove && !isAI(user)) || (get_dist(src, user) > 1  && !isAI(user)))
		to_chat(user, "Sorry, you must remain able bodied and close to \the [src] in order to use it.")
		return
	if(density && (machine_stat & (BROKEN|NOPOWER))) //can still close without power
		to_chat(user, "\The [src] is not functioning, you'll have to force it open manually.")
		return

	if(alarmed && density && lockdown && !allowed(user))
		to_chat(user, span_warning("Access denied.  Please wait for authorities to arrive, or for the alert to clear."))
		return
	else
		user.visible_message(span_notice("\The [src] [density ? "open" : "close"]s for \the [user]."),\
		"\The [src] [density ? "open" : "close"]s.",\
		"You hear a beep, and a door opening.")

	var/needs_to_close = FALSE
	if(density)
		if(alarmed)
			// Accountability!
			users_to_open |= user.name
			needs_to_close = TRUE
		open()
	else
		close()

	if(needs_to_close)
		spawn(50)
			alarmed = FALSE
			for(var/area/A in areas_added)		//Just in case a fire alarm is turned off while the firedoor is going through an autoclose cycle
				if(A.flags_alarm_state & ALARM_WARNING_FIRE || A.air_doors_activated)
					alarmed = TRUE
			if(alarmed)
				nextstate = FIREDOOR_CLOSED
				close()

/obj/machinery/door/firedoor/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(operating)
		return

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/W = I
		if(!W.remove_fuel(0, user))
			return

		balloon_alert_to_viewers("Starts [blocked ? "unwelding" : "welding"]")
		if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_GENERIC))
			balloon_alert_to_viewers("Stops welding")
			return

		blocked = !blocked
		balloon_alert_to_viewers("[blocked ? "welds" : "unwelds"] the firedoor")
		user.visible_message(span_danger("\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W]."),\
		"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
		"You hear something being welded.")
		playsound(src, 'sound/items/welder.ogg', 25, 1)
		update_icon()

	else if(blocked)
		user.visible_message(span_danger("\The [user] pries at \the [src] with \a [I], but \the [src] is welded in place!"),\
		"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
		"You hear someone struggle and metal straining.")

	else if(I.pry_capable)
		user.visible_message(span_danger("\The [user] starts to force \the [src] [density ? "open" : "closed"] with \a [I]!"),\
				span_notice("You start forcing \the [src] [density ? "open" : "closed"] with \the [I]!"),\
				"You hear metal strain.")
		var/old_density = density

		if(!do_after(user, 30, NONE, src, BUSY_ICON_HOSTILE))
			return

		if(blocked || density != old_density)
			return

		user.visible_message(span_danger("\The [user] forces \the [blocked ? "welded " : "" ][name] [density ? "open" : "closed"] with \a [I]!"),\
			span_notice("You force \the [blocked ? "welded " : ""][name] [density ? "open" : "closed"] with \the [I]!"),\
			"You hear metal strain and groan, and a door [density ? "opening" : "closing"].")

		if(density)
			open(TRUE)
		else
			close()


/obj/machinery/door/firedoor/try_to_activate_door(mob/user)
	return


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || !nextstate)
		return
	switch(nextstate)
		if(FIREDOOR_OPEN)
			nextstate = null
			open()
		if(FIREDOOR_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/close()
	latetoggle()
	return ..()

/obj/machinery/door/firedoor/open(forced = 0)
	if(!forced)
		if(machine_stat & (BROKEN|NOPOWER))
			return //needs power to open unless it was forced
		else
			use_power(active_power_usage)
	latetoggle()
	return ..()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	playsound(loc, 'sound/machines/emergency_shutter.ogg', 25)


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
				var/cdir = GLOB.cardinals[d]
				for(var/i=1;i<=length(ALERT_STATES);i++)
					if(dir_alerts[d] & (1<<(i-1)))
						overlays += new/icon(icon,"alert_[ALERT_STATES[i]]", dir=cdir)
	else
		icon_state = "door_open"
		if(blocked)
			overlays += "welded_open"


/obj/machinery/door/firedoor/mainship
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/mainship/purinadoor.dmi'
	icon_state = "door_open"
	openspeed = 4


/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2


/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags_atom = ON_BORDER
	allow_pass_flags = PASS_GLASS

/obj/machinery/door/firedoor/border_only/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_try_exit)
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE
