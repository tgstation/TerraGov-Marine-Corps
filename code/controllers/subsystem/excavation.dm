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
	wait = 10 SECONDS

	///Areas that can have an excavation site spawned in them
	var/list/eligible_areas
	///Areas that can't have an excavation site spawned in them
	var/list/ineligible_areas
	///Tiles with an excavation site spawned on them
	var/list/active_excavation_areas

/datum/controller/subsystem/excavation/Initialize(start_timeofday)
	. = ..()
	eligible_areas = getEligibleAreas()
	ineligible_areas = list()
	active_excavation_areas = list()

/datum/controller/subsystem/excavation/fire()
	if (active_excavation_areas.len >= MAX_EXCAVATION_TILES)
		return

	while (active_excavation_areas.len < 10 && eligible_areas.len > 0)
		getExcavationTurf()

/datum/controller/subsystem/excavation/proc/getEligibleAreas()
	//is this the best way to get the ground map's turfs? :mothdonk:
	var/map_name = lowertext(SSmapping.configs[GROUND_MAP].map_name)
	var/groundside_areas_base_typepath = text2path("/area/[map_name]")
	var/list/eligible_areas = list()
	for (var/type in subtypesof(groundside_areas_base_typepath))
		eligible_areas[type] = list()
		var/list/area_turfs = get_area_turfs(type)
		if(area_turfs.len == 0)
			continue
		eligible_areas[type] = area_turfs
	return eligible_areas

/datum/controller/subsystem/excavation/proc/getExcavationTurf()
	var/area_to_check = pick(eligible_areas)
	var/list/area_turfs = eligible_areas[area_to_check]
	var/turf/random_turf = pick(area_turfs)

	var/obj/effect/landmark/excavation_site/new_site = new
	new_site.forceMove(random_turf.loc)
	active_excavation_areas[area_to_check] = new_site
	make_area_ineligible(area_to_check)

/datum/controller/subsystem/excavation/proc/excavate_area(area/area_to_escavate)
	if(!LAZYACCESS(active_excavation_areas, area_to_escavate.type))
		return
	var/obj/effect/landmark/excavation_site/landmark_to_remove = active_excavation_areas[area_to_escavate.type]
	LAZYREMOVE(active_excavation_areas, area_to_escavate)
	landmark_to_remove.drop_rewards()
	qdel(landmark_to_remove)
	make_area_eligible(area_to_escavate)

///Makes an area able to be considered for area-related functions
/datum/controller/subsystem/excavation/proc/make_area_eligible(area_to_check)
	LAZYADDASSOC(eligible_areas, area_to_check, ineligible_areas[area_to_check])
	LAZYREMOVEASSOC(ineligible_areas, area_to_check, ineligible_areas[area_to_check])

///Makes an area unable to be considered for area-related functions
/datum/controller/subsystem/excavation/proc/make_area_ineligible(area_to_check)
	LAZYADDASSOC(ineligible_areas, area_to_check, eligible_areas[area_to_check])
	LAZYREMOVEASSOC(eligible_areas, area_to_check, eligible_areas[area_to_check])

#undef MAX_EXCAVATION_TILES
