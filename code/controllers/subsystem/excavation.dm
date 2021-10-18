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

#define MAX_EXCAVATION_TILES 10

SUBSYSTEM_DEF(excavation)
	name = "Excavation"
	init_order = INIT_ORDER_EXCAVATION
	flags = SS_KEEP_TIMING
	wait = 5 MINUTES

	///Areas that can have an excavation site spawned in them
	var/list/eligible_areas
	///Tiles with an excavation site spawned on them
	var/list/active_excavation_areas

/datum/controller/subsystem/excavation/Initialize(start_timeofday)
	. = ..()
	eligible_areas = getEligibleAreas()
	active_excavation_areas = list()

/datum/controller/subsystem/excavation/fire()
	if (active_excavation_areas.len >= MAX_EXCAVATION_TILES)
		return

	while (active_excavation_areas.len < 10)
		getExcavationTurf()

/datum/controller/subsystem/excavation/proc/getEligibleAreas()
	//is this the best way to get the ground map's turfs? :mothdonk:
	var/map_name = lowertext(SSmapping.configs[GROUND_MAP].map_name)
	var/groundside_areas_base_typepath = text2path("/area/[map_name]")
	var/list/eligible_areas = list()
	for (var/type in subtypesof(groundside_areas_base_typepath))
		eligible_areas[type] = list()
		eligible_areas[type] = get_area_turfs(type)
	return eligible_areas

/datum/controller/subsystem/excavation/proc/getExcavationTurf()
	for (var/area_to_check in eligible_areas)
		if (LAZYACCESS(active_excavation_areas, area_to_check))
			continue
		var/list/area_turfs = eligible_areas[area_to_check]

		var/random_index = rand(0, area_turfs.len)
		var/turf/random_turf = area_turfs[random_index]
		var/obj/effect/landmark/excavation_site/new_site = new
		new_site.forceMove(random_turf.loc)
		active_excavation_areas[area_to_check] = new_site

/datum/controller/subsystem/excavation/proc/excavate_area(area/area_to_escavate)
	if (!LAZYACCESS(active_excavation_areas, area_to_escavate))
		return
	var/obj/effect/landmark/excavation_site/landmark_to_remove = active_excavation_areas[area_to_escavate]
	LAZYREMOVE(active_excavation_areas, area_to_escavate)
	landmark_to_remove.drop_rewards()
	qdel(landmark_to_remove)


#undef MAX_EXCAVATION_TILES
