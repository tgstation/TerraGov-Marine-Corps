/**
 * Excavation event subsystem
 *
 * Goes through a list of areas of a certain map and marks a random tile
 * from several random areas from a list for excavation.
 * - make the excavation-compatible area list be generated once on initialization
 * - make tool for excavation
 * - excavation tiles are marked on minimap
 * - an item (tool for excavation?) makes the excavation sites visible on the minimap
 * - performing an excavation rewards from a list of rewards (rewards datums?)
 */

#define MAX_ACTIVE_EXCAVATIONS 10

SUBSYSTEM_DEF(excavation)
	name = "Excavation"
	init_order = INIT_ORDER_EXCAVATION
	flags = SS_BACKGROUND
	wait = 5 MINUTES

	///Areas that can have an excavation site spawned in them
	var/list/eligible_areas
	///Amount of present excavation landmarks
	var/excavations_count = 0

/datum/controller/subsystem/excavation/Initialize(start_timeofday)
	. = ..()
	EligibleAreasInit()

/datum/controller/subsystem/excavation/fire()
	while (excavations_count < MAX_ACTIVE_EXCAVATIONS && eligible_areas.len > 0)
		pickExcavationTurf()

///Initializes the list of areas that can have an excavation spawned in them
/datum/controller/subsystem/excavation/proc/EligibleAreasInit()
	eligible_areas = list()
	var/map_name = lowertext(SSmapping.configs[GROUND_MAP].map_name)
	var/groundside_areas_base_typepath = text2path("/area/[map_name]")
	for (var/type in subtypesof(groundside_areas_base_typepath))
		eligible_areas += type

///Creates an excavation landmark at a random area from eligible areas
/datum/controller/subsystem/excavation/proc/pickExcavationTurf()
	var/area/area_to_check = pick_n_take(eligible_areas)
	var/list/area_turfs = get_area_turfs(area_to_check)
	if(area_turfs.len == 0)
		return

	var/turf/random_turf = pick(area_turfs)
	if(random_turf.density)
		return

	new /obj/effect/landmark/excavation_site(random_turf)
	excavations_count++

///Excavates an excavation site
/datum/controller/subsystem/excavation/proc/excavate_site(obj/effect/landmark/excavation_site/excavation_landmark)
	eligible_areas += get_area(excavation_landmark)
	excavation_landmark.drop_rewards()
	qdel(excavation_landmark)
	excavations_count--

#undef MAX_ACTIVE_EXCAVATIONS
