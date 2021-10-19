/obj/effect/landmark/excavation_site
	name = "excavation landmark"
	///Amount of rewards that the excavation site provides
	var/rewards_count = 1
	///Min amount of rewards the excavation site provides
	var/rewards_min = 1
	///Max amount of rewards the excavation site provides
	var/rewards_max = 4
	///List of rewards for the excavation
	var/list/rewards = list(
		/obj/item/research_resource/money,
		/obj/item/research_resource/xeno/tier_one,
	)

/obj/effect/landmark/excavation_site/Initialize()
	. = ..()
	SSminimaps.add_marker(src, 2, hud_flags = MINIMAP_FLAG_EXCAVATION_ZONE, iconstate = "excavation_site")
	rewards_count = rand(rewards_min, rewards_max)

///Generates rewards for the excavation
/obj/effect/landmark/excavation_site/proc/drop_rewards()
	var/iterations = rewards_count
	while (iterations > 0)
		var/typepath = pick(rewards)
		var/obj/reward = new typepath
		reward.forceMove(get_turf(src))
		iterations--
