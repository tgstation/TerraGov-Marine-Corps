/area
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = AREA_LAYER
	plane = AREA_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = INVISIBILITY_LIGHTING
	minimap_color = null

	/// List of all turfs currently inside this area as nested lists indexed by zlevel.
	/// Acts as a filtered version of area.contents For faster lookup
	/// (area.contents is actually a filtered loop over world)
	/// Semi fragile, but it prevents stupid so I think it's worth it
	var/list/list/turf/turfs_by_zlevel = list() // TODO someone needs to go through and check that this is being used properly when it shoudld be

	/// turfs_by_z_level can hold MASSIVE lists, so rather then adding/removing from it each time we have a problem turf
	/// We should instead store a list of turfs to REMOVE from it, then hook into a getter for it
	/// There is a risk of this and contained_turfs leaking, so a subsystem will run it down to 0 incrementally if it gets too large
	/// This uses the same nested list format as turfs_by_zlevel
	var/list/list/turf/turfs_to_uncontain_by_zlevel = list()

	var/alarm_state_flags = NONE

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

	var/area_flags = NONE
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

	///string used to determine specific icon variants when structures are used in an area
	var/area_flavor = AREA_FLAVOR_NONE

/area/New()
	// This interacts with the map loader, so it needs to be set immediately
	// rather than waiting for atoms to initialize.
	if(unique)
		GLOB.areas_by_type[type] = src
	GLOB.areas += src
	return ..()


/area/Initialize(mapload, ...)
	icon_state = "" //Used to reset the icon overlay, I assume.
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

	if(area_flags & CANNOT_NUKE | area_flags & NEAR_FOB)
		if(get_area_name(src) in GLOB.nuke_ineligible_site)
			return
		GLOB.nuke_ineligible_site += get_area_name(src)

	return INITIALIZE_HINT_LATELOAD


/area/LateInitialize()
	power_change()		// all machines set to current power level, also updates icon


/area/Destroy() // todo this doesnt clean up everything it should
	if(GLOB.areas_by_type[type] == src)
		GLOB.areas_by_type[type] = null
	//this is not initialized until get_sorted_areas() is called so we have to do a null check
	if(!isnull(GLOB.sorted_areas))
		GLOB.sorted_areas -= src
	//just for sanity sake cause why not
	if(!isnull(GLOB.areas))
		GLOB.areas -= src
	STOP_PROCESSING(SSobj, src)
	//turf cleanup
	turfs_by_zlevel = null
	turfs_to_uncontain_by_zlevel = null
	return ..()


/area/Entered(atom/movable/arrived, atom/old_loc)
	set waitfor = FALSE
	SEND_SIGNAL(src, COMSIG_AREA_ENTERED, arrived, old_loc)
	SEND_SIGNAL(arrived, COMSIG_ENTER_AREA, src, old_loc,) //The atom that enters the area


/area/Exited(atom/movable/leaver, direction)
	SEND_SIGNAL(src, COMSIG_AREA_EXITED, leaver, direction)
	SEND_SIGNAL(leaver, COMSIG_EXIT_AREA, src, direction) //The atom that exits the area



/// Returns the highest zlevel that this area contains turfs for
/area/proc/get_highest_zlevel()
	for (var/area_zlevel in length(turfs_by_zlevel) to 1 step -1)
		if (length(turfs_to_uncontain_by_zlevel) >= area_zlevel)
			if (length(turfs_by_zlevel[area_zlevel]) - length(turfs_to_uncontain_by_zlevel[area_zlevel]) > 0)
				return area_zlevel
		else
			if (length(turfs_by_zlevel[area_zlevel]))
				return area_zlevel
	return 0

/// Returns a nested list of lists with all turfs split by zlevel.
/// only zlevels with turfs are returned. The order of the list is not guaranteed.
/area/proc/get_zlevel_turf_lists()
	if(length(turfs_to_uncontain_by_zlevel))
		cannonize_contained_turfs()

	var/list/zlevel_turf_lists = list()

	for (var/list/zlevel_turfs as anything in turfs_by_zlevel)
		if (length(zlevel_turfs))
			zlevel_turf_lists += list(zlevel_turfs)

	return zlevel_turf_lists

/// Returns a list with all turfs in this zlevel.
/area/proc/get_turfs_by_zlevel(zlevel)
	if (length(turfs_to_uncontain_by_zlevel) >= zlevel && length(turfs_to_uncontain_by_zlevel[zlevel]))
		cannonize_contained_turfs_by_zlevel(zlevel)

	if (length(turfs_by_zlevel) < zlevel)
		return list()

	return turfs_by_zlevel[zlevel]


/// Merges a list containing all of the turfs zlevel lists from get_zlevel_turf_lists inside one list. Use get_zlevel_turf_lists() or get_turfs_by_zlevel() unless you need all the turfs in one list to avoid generating large lists
/area/proc/get_turfs_from_all_zlevels()
	. = list()
	for (var/list/zlevel_turfs as anything in get_zlevel_turf_lists())
		. += zlevel_turfs

/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs_by_zlevel(zlevel_to_clean, _autoclean = TRUE)
	// This is massively suboptimal for LARGE removal lists
	// Try and keep the mass removal as low as you can. We'll do this by ensuring
	// We only actually add to contained turfs after large changes (Also the management subsystem)
	// Do your damndest to keep turfs out of /area/space as a stepping stone
	// That sucker gets HUGE and will make this take actual seconds
	if (zlevel_to_clean <= length(turfs_by_zlevel) && zlevel_to_clean <= length(turfs_to_uncontain_by_zlevel))
		turfs_by_zlevel[zlevel_to_clean] -= turfs_to_uncontain_by_zlevel[zlevel_to_clean]

	if (!_autoclean) // Removes empty lists from the end of this list
		turfs_to_uncontain_by_zlevel[zlevel_to_clean] = list()
		return

	var/new_length = length(turfs_to_uncontain_by_zlevel)
	// Walk backwards thru the list
	for (var/i in length(turfs_to_uncontain_by_zlevel) to 0 step -1)
		if (i && length(turfs_to_uncontain_by_zlevel[i]))
			break // Stop the moment we find a useful list
		new_length = i

	if (new_length < length(turfs_to_uncontain_by_zlevel))
		turfs_to_uncontain_by_zlevel.len = new_length

	if (new_length >= zlevel_to_clean)
		turfs_to_uncontain_by_zlevel[zlevel_to_clean] = list()


/// Ensures that the contained_turfs list properly represents the turfs actually inside us
/area/proc/cannonize_contained_turfs()
	for (var/area_zlevel in 1 to length(turfs_to_uncontain_by_zlevel))
		cannonize_contained_turfs_by_zlevel(area_zlevel, _autoclean = FALSE)

	turfs_to_uncontain_by_zlevel = list()


/// Returns TRUE if we have contained turfs, FALSE otherwise
/area/proc/has_contained_turfs()
	for (var/area_zlevel in 1 to length(turfs_by_zlevel))
		if (length(turfs_to_uncontain_by_zlevel) >= area_zlevel)
			if (length(turfs_by_zlevel[area_zlevel]) - length(turfs_to_uncontain_by_zlevel[area_zlevel]) > 0)
				return TRUE
		else
			if (length(turfs_by_zlevel[area_zlevel]))
				return TRUE
	return FALSE

/**
 * Register this area as belonging to a z level
 *
 * Ensures the item is added to the SSmapping.areas_in_z list for this z
 */
/area/proc/reg_in_areas_in_z()
	if(!has_contained_turfs())
		return
	var/list/areas_in_z = SSmapping.areas_in_z
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
	if(!(alarm_state_flags & ALARM_WARNING_FIRE))
		alarm_state_flags |= ALARM_WARNING_FIRE
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
	if(alarm_state_flags & ALARM_WARNING_FIRE)
		alarm_state_flags &= ~ALARM_WARNING_FIRE
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

/area/update_overlays()
	. = ..()
	var/I //More important == bottom. Fire normally takes priority over everything.
	if(alarm_state_flags && (!requires_power || power_environ)) //It either doesn't require power or the environment is powered. And there is an alarm.
		if(alarm_state_flags & ALARM_WARNING_READY)
			I = "alarm_ready" //Area is ready for something.
		if(alarm_state_flags & ALARM_WARNING_EVAC)
			I = "alarm_evac" //Evacuation happening.
		if(alarm_state_flags & ALARM_WARNING_ATMOS)
			I = "alarm_atmos"	//Atmos breach.
		if(alarm_state_flags & ALARM_WARNING_FIRE)
			I = "alarm_fire" //Fire happening.
		if(alarm_state_flags & ALARM_WARNING_DOWN)
			I = "alarm_down" //Area is shut down.
	for(var/offset in 0 to SSmapping.max_plane_offset)
		. += mutable_appearance('icons/turf/areas.dmi', I, plane=ABOVE_LIGHTING_PLANE, alpha=60, offset_const = offset)

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
