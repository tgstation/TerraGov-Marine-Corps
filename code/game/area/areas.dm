// Areas.dm



// ===
/area
	var/global/global_uid = 0
	var/uid
	var/can_hellhound_enter = 1
	var/ceiling = CEILING_NONE //the material the ceiling is made of. Used for debris from airstrikes and orbital beacons in ceiling_debris()
	var/fake_zlevel // for multilevel maps in the same z level
	var/gas_type = GAS_TYPE_AIR
	var/temperature = T20C
	var/pressure = ONE_ATMOSPHERE


/area/New()
	..()

	icon_state = "" //Used to reset the icon overlay, I assume.
	layer = AREAS_LAYER
	master = src //moved outside the spawn(1) to avoid runtimes in lighting.dm when it references loc.loc.master ~Carn
	uid = ++global_uid
	related = list(src)
	active_areas += src
	all_areas += src

	initialize_power_and_lighting()

/area/proc/initialize_power_and_lighting(override_power)
	if(requires_power)
		luminosity = 0
		if(override_power) //Reset everything if you want to override.
			power_light = 1
			power_equip = 1
			power_environ = 1
			SetDynamicLighting()
	else
		power_light = 0			//rastaf0
		power_equip = 0			//rastaf0
		power_environ = 0		//rastaf0
		luminosity = 1
		lighting_use_dynamic = 0

	power_change()		// all machines set to current power level, also updates lighting icon
	InitializeLighting()

/area/proc/poweralert(var/state, var/obj/source as obj)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for (var/area/RA in related)
				for (var/obj/machinery/camera/C in RA)
					cameras += C
					if(state == 1)
						C.network.Remove("Power Alarms")
					else
						C.network.Add("Power Alarms")
			for (var/mob/living/silicon/aiPlayer in player_list)
				if(aiPlayer.z == source.z)
					if (state == 1)
						aiPlayer.cancelAlarm("Power", src, source)
					else
						aiPlayer.triggerAlarm("Power", src, cameras, source)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(a.z == source.z)
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/atmosalert(danger_level)
//	if(type==/area) //No atmos alarms in space
//		return 0 //redudant

	//Check all the alarms before lowering atmosalm. Raising is perfectly fine.
	for (var/area/RA in related)
		for (var/obj/machinery/alarm/AA in RA)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				danger_level = max(danger_level, AA.danger_level)

	if(danger_level != atmosalm)
		if (danger_level < 1 && atmosalm >= 1)
			//closing the doors on red and opening on green provides a bit of hysteresis that will hopefully prevent fire doors from opening and closing repeatedly due to noise
			air_doors_open()

		if (danger_level < 2 && atmosalm >= 2)
			for(var/area/RA in related)
				for(var/obj/machinery/camera/C in RA)
					C.network.Remove("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.cancelAlarm("Atmosphere", src, src)

		if (danger_level >= 2 && atmosalm < 2)
			var/list/cameras = list()
			for(var/area/RA in related)
				//updateicon()
				for(var/obj/machinery/camera/C in RA)
					cameras += C
					C.network.Add("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.triggerAlarm("Atmosphere", src, cameras, src)
			air_doors_close()

		atmosalm = danger_level
		for(var/area/RA in related)
			for (var/obj/machinery/alarm/AA in RA)
				AA.update_icon()

		return 1
	return 0

/area/proc/air_doors_close()
	if(!src.master.air_doors_activated)
		src.master.air_doors_activated = 1
		for(var/obj/machinery/door/firedoor/E in src.master.all_doors)
			if(!E:blocked)
				if(E.operating)
					E:nextstate = OPEN
				else if(!E.density)
					spawn(0)
						E.close()

/area/proc/air_doors_open()
	if(src.master.air_doors_activated)
		src.master.air_doors_activated = 0
		for(var/obj/machinery/door/firedoor/E in src.master.all_doors)
			if(!E:blocked)
				if(E.operating)
					E:nextstate = OPEN
				else if(E.density)
					spawn(0)
						E.open()


/area/proc/firealert()
	if(name == "Space") //no fire alarms in space
		return
	if(!(flags_alarm_state & ALARM_WARNING_FIRE))
		flags_alarm_state |= ALARM_WARNING_FIRE
		master.flags_alarm_state |= ALARM_WARNING_FIRE		//used for firedoor checks
		updateicon()
		mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = CLOSED
				else if(!D.density)
					spawn()
						D.close()
		var/list/cameras = list()
		for(var/area/RA in related)
			for (var/obj/machinery/camera/C in RA)
				cameras.Add(C)
				C.network.Add("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			a.triggerAlarm("Fire", src, cameras, src)

/area/proc/firereset()
	if(flags_alarm_state & ALARM_WARNING_FIRE)
		flags_alarm_state &= ~ALARM_WARNING_FIRE
		master.flags_alarm_state &= ~ALARM_WARNING_FIRE		//used for firedoor checks
		mouse_opacity = 0
		updateicon()
		for(var/obj/machinery/door/firedoor/D in all_doors)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()
		for(var/area/RA in related)
			for (var/obj/machinery/camera/C in RA)
				C.network.Remove("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			a.cancelAlarm("Fire", src, src)

/area/proc/readyalert()
	if(!(flags_alarm_state & ALARM_WARNING_READY))
		flags_alarm_state |= ALARM_WARNING_READY
		updateicon()

/area/proc/readyreset()
	if(flags_alarm_state & ALARM_WARNING_READY)
		flags_alarm_state &= ~ALARM_WARNING_READY
		updateicon()
/*
/area/proc/toggle_evacuation() //toggles lights and creates an overlay.
	flags_alarm_state ^= ALARM_WARNING_EVAC
	master.flags_alarm_state ^= ALARM_WARNING_EVAC
	//if(flags_alarm_state & ALARM_WARNING_EVAC)
	//	master.lightswitch = FALSE
		//lightswitch = FALSE //Lights going off.
//	else
	//	master.lightswitch = TRUE
		//lightswitch = TRUE //Coming on.
	master.updateicon()

	//master.power_change()


/area/proc/toggle_shut_down()
	flags_alarm_state ^= ALARM_WARNING_DOWN
	updateicon()

/area/proc/destroy_area() //Just overlays for now to make it seem like nothing is left.
	flags_alarm_state = NOFLAGS
	active_areas -= src //So it doesn't process anymore.
	icon_state = "area_destroyed"
*/

/area/proc/updateicon()
	var/I //More important == bottom. Fire normally takes priority over everything.
	if(flags_alarm_state && (!requires_power || power_environ)) //It either doesn't require power or the environment is powered. And there is an alarm.
		if(flags_alarm_state & ALARM_WARNING_READY) I = "alarm_ready" //Area is ready for something.
		if(flags_alarm_state & ALARM_WARNING_EVAC) I = "alarm_evac" //Evacuation happening.
		if(flags_alarm_state & ALARM_WARNING_ATMOS) I = "alarm_atmos"	//Atmos breach.
		if(flags_alarm_state & ALARM_WARNING_FIRE) I = "alarm_fire" //Fire happening.
		if(flags_alarm_state & ALARM_WARNING_DOWN) I = "alarm_down" //Area is shut down.

	if(icon_state != I) icon_state = I //If the icon state changed, change it. Otherwise do nothing.

/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!master.requires_power)
		return 1
	if(master.always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return master.power_equip
		if(LIGHT)
			return master.power_light
		if(ENVIRON)
			return master.power_environ

	return 0

// called when power status changes

/area/proc/power_change()
	master.powerupdate = 2
	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)
		if(flags_alarm_state)
			RA.updateicon()

/area/proc/usage(var/chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += master.used_light
		if(EQUIP)
			used += master.used_equip
		if(ENVIRON)
			used += master.used_environ
		if(TOTAL)
			used += master.used_light + master.used_equip + master.used_environ

	return used

/area/proc/clear_usage()
	master.used_equip = 0
	master.used_light = 0
	master.used_environ = 0

/area/proc/use_power(var/amount, var/chan)

	switch(chan)
		if(EQUIP)
			master.used_equip += amount
		if(LIGHT)
			master.used_light += amount
		if(ENVIRON)
			master.used_environ += amount


/area/Entered(A,atom/OldLoc)
	var/musVolume = 20
	var/sound = 'sound/ambience/ambigen1.ogg'

	if(istype(A, /obj/machinery))
		var/area/newarea = get_area(A)
		var/area/oldarea = get_area(OldLoc)
		oldarea.master.area_machines -= A
		newarea.master.area_machines += A
		return

	if(!istype(A,/mob/living))	return

	var/mob/living/L = A
	if(!L.ckey)	return

	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (L.m_intent == MOVE_INTENT_RUN)) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)
		L.make_floating(0)

	L.lastarea = newarea

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(!(L && L.client && (L.client.prefs.toggles_sound & SOUND_AMBIENCE)))	return

	if(!L.client.ambience_playing)
		L.client.ambience_playing = 1
		L << sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 30, channel = 2)

	if(src.ambience.len && prob(35))
		sound = pick(ambience)

		if(world.time > L.client.played + 900)
			L << sound(sound, repeat = 0, wait = 0, volume = musVolume, channel = 1)
			L.client.played = world.time

/area/proc/gravitychange(var/gravitystate = 0, var/area/A)

	A.has_gravity = gravitystate

	for(var/area/SubA in A.related)
		SubA.has_gravity = gravitystate

		if(gravitystate)
			for(var/mob/living/carbon/human/M in SubA)
				thunk(M)
			for(var/mob/M1 in SubA)
				M1.make_floating(0)
		else
			for(var/mob/M in SubA)
				if(M.Check_Dense_Object() && istype(src,/mob/living/carbon/human/))
					var/mob/living/carbon/human/H = src
					if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags_inventory & NOSLIPPING))  //magboots + dense_object = no floaty effect
						H.make_floating(0)
					else
						H.make_floating(1)
				else
					M.make_floating(1)

/area/proc/thunk(mob)
	if(istype(mob,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		if((istype(mob:shoes, /obj/item/clothing/shoes/magboots) && (mob:shoes.flags_inventory & NOSLIPPING)))
			return

	if(istype(get_turf(mob), /turf/open/space)) // Can't fall onto nothing.
		return

	if((istype(mob,/mob/living/carbon/human/)) && (mob:m_intent == MOVE_INTENT_RUN)) // Only clumbsy humans can fall on their asses.
		mob:AdjustStunned(5)
		mob:AdjustKnockeddown(5)

	else if (istype(mob,/mob/living/carbon/human/))
		mob:AdjustStunned(2)
		mob:AdjustKnockeddown(2)

	mob << "Gravity!"





//atmos related procs

/area/return_air()
	return list(gas_type, temperature, pressure)

/area/return_pressure()
	return pressure

/area/return_temperature()
	return temperature

/area/return_gas()
	return gas_type


