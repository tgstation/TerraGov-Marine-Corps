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
		/mob/living/carbon/human/species/zombie/ai/tank/patrol = 4,
		/mob/living/carbon/human/species/zombie/ai/smoker/patrol = 4,
		/mob/living/carbon/human/species/zombie/ai/hunter/patrol = 4,
		/mob/living/carbon/human/species/zombie/ai/boomer/patrol = 4,
		/mob/living/carbon/human/species/zombie/ai/strong/patrol = 4,
		/mob/living/carbon/human/species/zombie/ai/stay = 10 // defenders, and lets player zombies build hordes from a central location
	)
	spawnamount = 2
	spawndelay = 15 SECONDS
	maxamount = 50
	var/threat_warning = FALSE

	var/datum/proximity_monitor/proximity_monitor
	COOLDOWN_DECLARE(proxy_alert_cooldown)
	COOLDOWN_DECLARE(defender_spawn_cooldown)

/obj/effect/ai_node/spawner/zombie/Initialize(mapload)
	. = ..()
	GLOB.zombie_spawners += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "zombie_spawner_clear"))
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
	if(iszombie(hostile))
		return

	if(!iscarbon(hostile) && !isvehicle(hostile))
		return

	if(iscarbon(hostile))
		var/mob/living/carbon/carbon_triggerer = hostile
		if(carbon_triggerer.stat == DEAD)
			return

	if(COOLDOWN_FINISHED(src, proxy_alert_cooldown))
		threat_warning = TRUE
		addtimer(CALLBACK(src, PROC_REF(clear_warning)), ZOMBIE_STRUCTURE_DETECTION_COOLDOWN)
		update_minimap_icon()

	if(COOLDOWN_FINISHED(src, defender_spawn_cooldown))
		spawn_defenders()
		COOLDOWN_START(src, defender_spawn_cooldown, ZOMBIE_STRUCTURE_DEFENDER_COOLDOWN)

///Clears any threat warnings
/obj/effect/ai_node/spawner/zombie/proc/clear_warning()
	threat_warning = FALSE
	update_minimap_icon()

///Updates minimap icon when a threat is detected
/obj/effect/ai_node/spawner/zombie/proc/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips_large.dmi', null, "zombie_spawner[threat_warning ? "_warn" : "_clear"]"))
