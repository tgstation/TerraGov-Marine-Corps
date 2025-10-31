/obj/effect/ai_node/spawner/zombie
	name = "tunnel"
	desc = "It reeks of rotten flesh and has stains of old blood and scratches."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "hole"
	invisibility = 0
	resistance_flags = UNACIDABLE|PLASMACUTTER_IMMUNE|PROJECTILE_IMMUNE
	spawntypes = list(
		/mob/living/carbon/human/species/zombie/ai/patrol = 70,
		/mob/living/carbon/human/species/zombie/ai/fast/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/tank/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/smoker/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/hunter/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/strong/patrol = 5,
		/mob/living/carbon/human/species/zombie/ai/stay = 10 // defenders, and lets player zombies build hordes from a central location
	)
	spawnamount = 2
	spawndelay = 8 SECONDS
	maxamount = 15

	var/datum/proximity_monitor/proximity_monitor
	COOLDOWN_DECLARE(proxy_alert_cooldown)

/obj/effect/ai_node/spawner/zombie/Initialize(mapload)
	. = ..()
	GLOB.zombie_spawners += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "zombie_spawner"))
	proximity_monitor = new(src, ZOMBIE_STRUCTURE_DETECTION_RANGE)

/obj/effect/ai_node/spawner/zombie/Destroy()
	. = ..()
	GLOB.zombie_spawners -= src
	SSminimaps.remove_marker(src)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_ZOMBIE_TUNNEL_DESTROYED)
	QDEL_NULL(proximity_monitor)

/obj/effect/ai_node/spawner/zombie/plastique_act()
	playsound(loc, 'sound/effects/meteorimpact.ogg', 35, 1)
	qdel(src)

/obj/effect/ai_node/spawner/zombie/examine(mob/user)
	. = ..()
	. += span_notice("It seems like you could collapse it with a plastique explosive.")

///Called by a proximity alert, spawns defenders when a threat is detected
/obj/effect/ai_node/spawner/zombie/proc/spawn_defenders()
	for(var/i in 1 to ZOMBIE_DEFENDER_AMOUNT)
		var/spawntype = pickweight(spawntypes)
		new spawntype(loc)

/obj/effect/ai_node/spawner/zombie/HasProximity(atom/movable/hostile)
	if(!COOLDOWN_FINISHED(src, proxy_alert_cooldown) || iszombie(hostile))
		return
	spawn_defenders()

	COOLDOWN_START(src, proxy_alert_cooldown, ZOMBIE_STRUCTURE_DETECTION_COOLDOWN)
