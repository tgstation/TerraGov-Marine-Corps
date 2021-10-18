/obj/effect/landmark/excavation_site
	name = "excavation landmark"
	var/rewards_count = 1
	var/list/rewards = list()

/obj/effect/landmark/excavation_site/Initialize()
	. = ..()
	SSminimaps.add_marker(src, z, hud_flags = MINIMAP_FLAG_EXCAVATION_ZONE, iconstate = "excavation_site")

/obj/effect/landmark/excavation_site/proc/drop_rewards()
	var/iterations = rewards_count
	while (iterations > 0)
		var/typepath = rewards[rand(0, rewards.len)]
		var/obj/reward = new typepath
		reward.forceMove(get_turf(src))
		iterations--
