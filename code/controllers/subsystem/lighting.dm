SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING

	//debug var for tracking updates before init is complete
	var/duplicate_shadow_updates_in_init = 0
	///Total times shadows were updated, debug
	var/total_shadow_calculations = 0

	///Whether the SS has begun setting up yet
	var/started = FALSE

	var/static/list/static_sources_queue = list() //! List of static lighting sources queued for update.
	var/static/list/corners_queue = list() //! List of lighting corners queued for update.
	var/static/list/objects_queue = list() //! List of lighting objects queued for update.

	var/static/list/mask_queue = list() //! List of hybrid lighting sources queued for update.

/datum/controller/subsystem/lighting/Initialize()
	started = TRUE
	if(!initialized)
		//Handle static lightnig
		create_all_lighting_objects()
	fire(FALSE, TRUE)
	return SS_INIT_SUCCESS


/datum/controller/subsystem/lighting/stat_entry(msg)
	msg = "ShCalcs:[total_shadow_calculations]|SourcQ:[length(static_sources_queue)]|CcornQ:[length(corners_queue)]|ObjQ:[length(objects_queue)]|HybrQ:[length(mask_queue)]"
	return ..()

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/updators_num = 0
	for(var/datum/static_light_source/L AS in static_sources_queue)
		updators_num++
		L.update_corners()
		if(QDELETED(L))
			updators_num--

		L.needs_update = LIGHTING_NO_UPDATE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		static_sources_queue.Cut(1, ++updators_num)
		updators_num = 0
	if(!init_tick_checks)
		MC_SPLIT_TICK

	updators_num = 0
	for(var/datum/static_lighting_corner/C AS in corners_queue)
		updators_num++
		C.needs_update = FALSE //update_objects() can call qdel if the corner is storing no data
		C.update_objects()
		if(QDELETED(C))
			updators_num--
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		corners_queue.Cut(1, ++updators_num)
		updators_num = 0
	if(!init_tick_checks)
		MC_SPLIT_TICK

	updators_num = 0
	for(var/datum/static_lighting_object/O AS in objects_queue)
		updators_num++
		if (QDELETED(O))
			updators_num--
			continue
		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		objects_queue.Cut(1, ++updators_num)
		updators_num = 0
	if(!init_tick_checks)
		MC_SPLIT_TICK

	updators_num = 0
	for(var/atom/movable/lighting_mask/mask_to_update AS in mask_queue)
		updators_num++

		mask_to_update.calculate_lighting_shadows()
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		mask_queue.Cut(1, ++updators_num)

/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	return ..()

///sets up light objects for a particular z level. Used for late loading
/datum/controller/subsystem/lighting/proc/create_lighting_objects_for_z(z_level)
	for(var/area/new_area in world)
		if(new_area.z != z_level)
			continue
		if(!new_area.static_lighting)
			continue

		for(var/turf/T in new_area)
			new/datum/static_lighting_object(T)
			CHECK_TICK
		CHECK_TICK
