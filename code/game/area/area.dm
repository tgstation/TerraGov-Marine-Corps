/area
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREAS_LAYER
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING

	var/flags_alarm_state = NONE

	var/unique = TRUE

	var/powerupdate = 10
	
	var/requires_power = TRUE
	var/always_unpowered = FALSE

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE

	var/used_equip = 0
	var/used_light = 0
	var/used_environ = 0

	var/has_gravity = TRUE

	var/global/global_uid = 0
	var/uid

	var/atmos = TRUE
	var/atmosalm = FALSE
	var/poweralm = TRUE
	var/lightswitch = TRUE

	var/gas_type = GAS_TYPE_AIR
	var/pressure = ONE_ATMOSPHERE
	var/temperature = T20C

	var/ceiling = CEILING_NONE //the material the ceiling is made of. Used for debris from airstrikes and orbital beacons in ceiling_debris()
	var/fake_zlevel // for multilevel maps in the same z level

	var/list/cameras
	var/list/all_doors = list()		//Added by Strumpetplaya - Alarm Change - Contains a list of doors adjacent to this area
	var/air_doors_activated = FALSE
	var/list/ambience = list('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', \
		'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg', 'sound/ambience/ambigen8.ogg',\
		'sound/ambience/ambigen9.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg', 'sound/ambience/ambigen12.ogg',\
		'sound/ambience/ambigen14.ogg')


	
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

		if(dynamic_lighting == DYNAMIC_LIGHTING_FORCED)
			dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
			luminosity = 0
		else
			dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

	. = ..()

	blend_mode = BLEND_MULTIPLY // Putting this in the constructor so that it stops the icons being screwed up in the map editor.

	if(!IS_DYNAMIC_LIGHTING(src))
		add_overlay(/obj/effect/fullbright)

	reg_in_areas_in_z()

	return INITIALIZE_HINT_LATELOAD


/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon



/area/Destroy()
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	STOP_PROCESSING(SSobj, src)
	return ..()


/area/Entered(atom/movable/AM)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, AM)
	SEND_SIGNAL(AM, COMSIG_ENTER_AREA, src) //The atom that enters the area
	if(!isliving(AM))
		return

	var/mob/living/L = AM
	if(!L.ckey)
		return

	if(!L.client || !(L.client.prefs.toggles_sound & SOUND_AMBIENCE))
		return

	if(!prob(35))
		return

	var/sound = pick(ambience)

	if(!L.client.played)
		SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = 1018))
		L.client.played = TRUE
		addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)


/client/proc/ResetAmbiencePlayed()
	played = FALSE



/area/Exited(atom/movable/M)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, M)
	SEND_SIGNAL(M, COMSIG_EXIT_AREA, src) //The atom that exits the area


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
	if(state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for(var/obj/machinery/computer/station_alert/a in GLOB.machines)
				if(a.z == source.z)
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)


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
	for(var/obj/machinery/door/firedoor/E in all_doors)
		if(E.blocked)
			continue

		if(E.operating)
			E.nextstate = OPEN
		else if(!E.density)
			spawn(0)
				E.close()


/area/proc/air_doors_open()
	for(var/obj/machinery/door/firedoor/E in all_doors)
		if(E.blocked)
			continue

		if(E.operating)
			E.nextstate = OPEN
		else if(E.density)
			spawn(0)
				E.open()


/area/proc/firealert()
	if(name == "Space") //no fire alarms in space
		return
	if(!(flags_alarm_state & ALARM_WARNING_FIRE))
		flags_alarm_state |= ALARM_WARNING_FIRE
		update_icon()
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = FIREDOOR_CLOSED
				else if(!D.density)
					spawn()
						D.close()
		var/list/cameras = list()
		for (var/obj/machinery/computer/station_alert/a in GLOB.machines)
			a.triggerAlarm("Fire", src, cameras, src)


/area/proc/firereset()
	if(flags_alarm_state & ALARM_WARNING_FIRE)
		flags_alarm_state &= ~ALARM_WARNING_FIRE
		mouse_opacity = 0
		update_icon()

		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()

		for(var/obj/machinery/computer/station_alert/a in GLOB.machines)
			a.cancelAlarm("Fire", src, src)


/area/proc/update_icon()
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
