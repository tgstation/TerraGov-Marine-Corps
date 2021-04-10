SUBSYSTEM_DEF(lighting)
	name = "Lighting"
	wait = 2
	init_order = INIT_ORDER_LIGHTING

	var/duplicate_shadow_updates_in_init = 0
	var/total_shadow_calculations = 0

	var/started = FALSE
	var/list/sources_that_need_updating = list()
	var/list/hybrid_light_sources = list()

/datum/controller/subsystem/lighting/Initialize(timeofday)
	started = TRUE
	if(!initialized)
		//Handle static lightnig
		//create_all_lighting_objects()
		//Handle hybrid lighting
		to_chat(world, "<span class='boldannounce'>Generating shadows on [sources_that_need_updating.len] light sources.</span>")
		var/timer = TICK_USAGE
		for(var/atom/movable/lighting_mask/mask AS in sources_that_need_updating)
			mask.calculate_lighting_shadows()
		sources_that_need_updating = null
		to_chat(world, "<span class='boldannounce'>Initial lighting conditions built successfully in [TICK_USAGE_TO_MS(timer)]ms.</span>")
		initialized = TRUE
	fire(FALSE, TRUE)
	return ..()

///Debug admin proc to reebuild all shadows
/datum/controller/subsystem/lighting/proc/build_shadows()
	var/timer = TICK_USAGE
	message_admins("Building [hybrid_light_sources.len] shadows")
	for(var/datum/dynamic_light_source/light AS in hybrid_light_sources)
		light.our_mask.calculate_lighting_shadows()
	message_admins("Shadows built in [TICK_USAGE_TO_MS(timer)]ms ([hybrid_light_sources.len] shadows)")

GLOBAL_LIST_EMPTY(lighting_update_lights) //! List of lighting sources  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_corners) //! List of lighting corners  queued for update.
GLOBAL_LIST_EMPTY(lighting_update_objects) //! List of lighting objects queued for update.

/datum/controller/subsystem/lighting/stat_entry()
	. = ..("Sources: [hybrid_light_sources.len], ShCalcs: [total_shadow_calculations]|L:[GLOB.lighting_update_lights.len]|C:[GLOB.lighting_update_corners.len]|O:[GLOB.lighting_update_objects.len]")

/datum/controller/subsystem/lighting/fire(resumed, init_tick_checks)
	MC_SPLIT_TICK_INIT(3)
	if(!init_tick_checks)
		MC_SPLIT_TICK
	var/updators_num = 0
	for(updators_num in 1 to GLOB.lighting_update_lights.len)
		var/datum/static_light_source/L = GLOB.lighting_update_lights[updators_num]

		L.update_corners()

		L.needs_update = LIGHTING_NO_UPDATE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		GLOB.lighting_update_lights.Cut(1, ++updators_num)
		updators_num = 0
	if(!init_tick_checks)
		MC_SPLIT_TICK

	for(updators_num in 1 to GLOB.lighting_update_corners.len)
		var/datum/static_lighting_corner/C = GLOB.lighting_update_corners[updators_num]

		C.update_objects()
		C.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		GLOB.lighting_update_corners.Cut(1, ++updators_num)
		updators_num = 0
	if(!init_tick_checks)
		MC_SPLIT_TICK

	for(updators_num in 1 to GLOB.lighting_update_objects.len)
		var/atom/movable/static_lighting_object/O = GLOB.lighting_update_objects[updators_num]

		if (QDELETED(O))
			continue
		O.update()
		O.needs_update = FALSE
		if(init_tick_checks)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			break
	if(updators_num)
		GLOB.lighting_update_objects.Cut(1, ++updators_num)


/datum/controller/subsystem/lighting/Recover()
	initialized = SSlighting.initialized
	return ..()
