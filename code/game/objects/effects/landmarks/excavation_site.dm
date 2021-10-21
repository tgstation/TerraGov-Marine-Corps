/obj/effect/landmark/excavation_site
	name = "excavation landmark"
	///Spawner the excavation site was spawned by
	var/obj/effect/landmark/excavation_site_spawner/spawner
	///Min amount of rewards the excavation site provides
	var/rewards_min = 1
	///Max amount of rewards the excavation site provides
	var/rewards_max = 4
	///List of rewards for the excavation
	var/list/rewards = list(
		/obj/item/research_resource/money,
		/obj/item/research_resource/xeno/tier_one,
	)

/obj/effect/landmark/excavation_site/New(loc, spawner)
	. = ..()
	src.spawner = spawner
	SSminimaps.add_marker(src, 2, hud_flags = MINIMAP_FLAG_EXCAVATION_ZONE, iconstate = "excavation_site")

///Generates rewards for the excavation
/obj/effect/landmark/excavation_site/proc/drop_rewards()
	var/iterations = rand(rewards_min, rewards_max)
	while(iterations > 0)
		var/typepath = pick(rewards)
		new typepath(spawner.loc)
		iterations--
