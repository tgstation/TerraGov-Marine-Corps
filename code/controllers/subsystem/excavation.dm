/**
 * Excavation event subsystem
 */

#define MAX_ACTIVE_EXCAVATIONS 10

SUBSYSTEM_DEF(excavation)
	name = "Excavation"
	init_order = INIT_ORDER_EXCAVATION
	flags = SS_BACKGROUND | SS_NO_INIT
	wait = 5 MINUTES

	///Landmarks that can spawn excavation sites
	var/list/excavation_site_spawners = list()
	///Landmarks that have active excavation sites
	var/list/active_spawners = list()
	///Amount of present excavation landmarks
	var/excavations_count = 0

/datum/controller/subsystem/excavation/fire()
	if(excavation_site_spawners.len <= 0)
		return
	var/spawn_count = min(MAX_ACTIVE_EXCAVATIONS - excavations_count, excavation_site_spawners.len)
	for(var/i in 0 to spawn_count - 1)
		spawnExcavation()

///Creates an excavation landmark at a random area from eligible areas
/datum/controller/subsystem/excavation/proc/spawnExcavation()
	var/obj/effect/landmark/excavation_site_spawner/site_spawner = pick_n_take(excavation_site_spawners)
	active_spawners += site_spawner
	site_spawner.spawn_excavation_site()
	excavations_count++

///Excavates an excavation site
/datum/controller/subsystem/excavation/proc/excavate_site(obj/effect/landmark/excavation_site_spawner/site_spawner)
	active_spawners -= site_spawner
	excavation_site_spawners += site_spawner
	site_spawner.excavate_site()
	excavations_count--

#undef MAX_ACTIVE_EXCAVATIONS
