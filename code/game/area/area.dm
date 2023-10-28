/area
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREAS_LAYER
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	minimap_color = null

	var/flags_alarm_state = NONE

	var/unique = TRUE

	var/requires_power = TRUE
	var/always_unpowered = FALSE

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE

	var/used_equip = FALSE
	var/used_light = FALSE
	var/used_environ = FALSE

	var/global/global_uid = 0
	var/uid

	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/lightswitch = TRUE

	var/gas_type = GAS_TYPE_AIR
	var/pressure = ONE_ATMOSPHERE
	var/temperature = T20C

	var/parallax_movedir = 0

	///the material the ceiling is made of. Used for debris from airstrikes and orbital beacons in ceiling_debris()
	var/ceiling = CEILING_NONE
	///Used in designating the "level" of maps pretending to be multi-z one Z
	var/fake_zlevel
	///Is this area considered inside or outside
	var/outside = TRUE

	var/flags_area = NONE
	///Cameras in this area
	var/list/cameras
	///Keeps a lit of adjacent firelocks, used for alarms/ZAS
	var/list/all_fire_doors
	var/air_doors_activated = FALSE
	var/list/ambience = list('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', \
		'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg', 'sound/ambience/ambigen8.ogg',\
		'sound/ambience/ambigen9.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg', 'sound/ambience/ambigen12.ogg',\
		'sound/ambience/ambigen14.ogg', 'sound/ambience/ambiatmos.ogg', 'sound/ambience/ambiatmos2.ogg')
	///Used to decide what the minimum time between ambience is
	var/min_ambience_cooldown = 40 SECONDS
	///Used to decide what the maximum time between ambience is
	var/max_ambience_cooldown = 120 SECONDS

	///Boolean to limit the areas (subtypes included) that atoms in this area can smooth with. Used for shuttles.
	var/area_limited_icon_smoothing = FALSE

/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if(unique)
		GLOB.areas_by_type[type] = src
	return ..()


/area/Initialize(mapload, ...)
	icon_state = "" //Used to reset the icon overlay, I assume.
	layer = AREAS_LAYER
	uid = ++global_uid

	if(requires_power)
		luminosity = 0
	else
		power_light = TRUE
		power_equip = TRUE
		power_environ = TRUE

	. = ..()

	if(!static_lighting)
		blend_mode = BLEND_MULTIPLY

	reg_in_areas_in_z()

	update_base_lighting()

	return INITIALIZE_HINT_LATELOAD


/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon


/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	STOP_PROCESSING(SSobj, src)
	return ..()


/area/Entered(atom/movable/arrived, atom/old_loc)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, old_loc)
	SEND_SIGNAL(arrived, COMSIG_ENTER_AREA, src, old_loc,) //The atom that enters the area


/area/Exited(atom/movable/leaver, direction)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, leaver, direction)
	SEND_SIGNAL(leaver, COMSIG_EXIT_AREA, src, direction) //The atom that exits the area


/area/proc/reg_in_areas_in_z()
	if(!length(contents))
		return

	var/list/areas_in_z = SSmapping.areas_in_z
	var/z
	for(var/i in contents)
		var/atom/thing = i
		if(!thing)
			continue
		z = thing.z
		break
	if(!z)
		WARNING("No z found for [src]")
		return
	if(!areas_in_z["[z]"])
		areas_in_z["[z]"] = list()
	areas_in_z["[z]"] += src



// A hook so areas can modify the incoming args
/area/proc/PlaceOnTopReact(list/new_baseturfs, turf/fake_turf_type, flags)
	return flags


/area/proc/poweralert(state, obj/source)
	if(state == poweralm)
		return

	poweralm = state

	for(var/i in GLOB.alert_consoles)
		var/obj/machinery/computer/station_alert/SA = i
		if(SA.z != source.z)
			continue
		if(state == 1)
			SA.cancelAlarm("Power", src, source)
		else
			SA.triggerAlarm("Power", src, null, source)


/area/proc/atmosalert(danger_level)
	if(danger_level != atmosalm)
		if (danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()

		if (danger_level < 2 && atmosalm >= 2)
			for(var/obj/machinery/computer/station_alert/a in GLOB.machines)
				a.cancelAlarm("Atmosphere", src, src)

		if (danger_level >= 2 && atmosalm < 2)
			var/list/cameras = list()
			for(var/obj/machinery/computer/station_alert/a in GLOB.machines)
				a.triggerAlarm("Atmosphere", src, cameras, src)
			air_doors_close()

		atmosalm = danger_level

		return TRUE
	return FALSE


/area/proc/air_doors_close()
	for(var/obj/machinery/door/firedoor/E in all_fire_doors)
		if(E.blocked)
			continue

		if(E.operating)
			E.nextstate = OPEN
		else if(!E.density)
			E.close()


/area/proc/air_doors_open()
	for(var/obj/machinery/door/firedoor/E in all_fire_doors)
		if(E.blocked)
			continue

		if(E.operating)
			E.nextstate = OPEN
		else if(E.density)
			E.open()


/area/proc/firealert()
	if(name == "Space") //no fire alarms in space
		return
	if(!(flags_alarm_state & ALARM_WARNING_FIRE))
		flags_alarm_state |= ALARM_WARNING_FIRE
		update_icon()
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		for(var/obj/machinery/door/firedoor/D in all_fire_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_CLOSED
				else if(!D.density)
					D.close()
		var/list/cameras = list()
		for (var/obj/machinery/computer/station_alert/a in GLOB.machines)
			a.triggerAlarm("Fire", src, cameras, src)


/area/proc/firereset()
	if(flags_alarm_state & ALARM_WARNING_FIRE)
		flags_alarm_state &= ~ALARM_WARNING_FIRE
		mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		update_icon()

		for(var/obj/machinery/door/firedoor/D in all_fire_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					D.open()

		for(var/obj/machinery/computer/station_alert/a in GLOB.machines)
			a.cancelAlarm("Fire", src, src)


/area/update_icon()
	var/I //More important == bottom. Fire normally takes priority over everything.
	if(flags_alarm_state && (!requires_power || power_environ)) //It either doesn't require power or the environment is powered. And there is an alarm.
		if(flags_alarm_state & ALARM_WARNING_READY) I = "alarm_ready" //Area is ready for something.
		if(flags_alarm_state & ALARM_WARNING_EVAC) I = "alarm_evac" //Evacuation happening.
		if(flags_alarm_state & ALARM_WARNING_ATMOS) I = "alarm_atmos"	//Atmos breach.
		if(flags_alarm_state & ALARM_WARNING_FIRE) I = "alarm_fire" //Fire happening.
		if(flags_alarm_state & ALARM_WARNING_DOWN) I = "alarm_down" //Area is shut down.

	if(icon_state != I) icon_state = I //If the icon state changed, change it. Otherwise do nothing.


/area/proc/powered(chan)
	if(!requires_power)
		return TRUE

	if(always_unpowered)
		return FALSE

	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return FALSE


/area/proc/power_change()
	for(var/obj/machinery/M in src)
		M.power_change()
	update_icon()


/area/proc/usage(chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += used_light
		if(EQUIP)
			used += used_equip
		if(ENVIRON)
			used += used_environ
		if(TOTAL)
			used += used_light + used_equip + used_environ
	return used


/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0


/area/proc/use_power(amount, chan)
	switch(chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount



/area/return_air()
	return list(gas_type, temperature, pressure)


/area/return_pressure()
	return pressure


/area/return_temperature()
	return temperature


/area/return_gas()
	return gas_type
