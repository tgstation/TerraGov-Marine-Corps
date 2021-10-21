/obj/effect/landmark/excavation_site_spawner
	name = "excavation site spawner"
	icon_state = "clockwork_orange"
	///Excavation site to be spawned
	var/obj/effect/landmark/excavation_site/spawned_site

/obj/effect/landmark/excavation_site_spawner/Initialize()
	. = ..()
	SSexcavation.excavation_site_spawners += src

///Spawn an excavation site
/obj/effect/landmark/excavation_site_spawner/proc/spawn_excavation_site()
	spawned_site = new(src.loc)
	spawned_site.spawner = src

///Escavates the spawner's excavation site
/obj/effect/landmark/excavation_site_spawner/proc/excavate_site()
	var/obj/effect/landmark/excavation_site/site_to_delete = spawned_site
	spawned_site = null
	site_to_delete.drop_rewards()
	qdel(site_to_delete)
