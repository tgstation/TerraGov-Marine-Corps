
/obj/structure/xeno/spawner
	name = "spawner"
	desc = "A slimy, oozy resin bed filled with foul-looking egg-like ...things."
	icon = 'icons/Xeno/3x3building.dmi'
	icon_state = "spawner"
	bound_width = 96
	bound_height = 96
	max_integrity = 500
	resistance_flags = UNACIDABLE | DROPSHIP_IMMUNE
	xeno_structure_flags = IGNORE_WEED_REMOVAL|CRITICAL_STRUCTURE|XENO_STRUCT_WARNING_RADIUS
	///For minimap icon change if silo takes damage or nearby hostile
	var/warning
	COOLDOWN_DECLARE(spawner_damage_alert_cooldown)
	COOLDOWN_DECLARE(spawner_proxy_alert_cooldown)
	var/linked_minions = list()

/obj/structure/xeno/spawner/Initialize(mapload, _hivenumber)
	. = ..()
	LAZYADDASSOC(GLOB.xeno_spawners_by_hive, hivenumber, src)
	SSspawning.registerspawner(src, INFINITY, GLOB.xeno_ai_spawnable, 0, 0, CALLBACK(src, PROC_REF(on_spawn)))
	SSspawning.spawnerdata[src].required_increment = max(45 SECONDS, 3 MINUTES - SSmonitor.maximum_connected_players_count * SPAWN_RATE_PER_PLAYER)/SSspawning.wait
	SSspawning.spawnerdata[src].max_allowed_mobs = max(2, MAX_SPAWNABLE_MOB_PER_PLAYER * SSmonitor.maximum_connected_players_count)
	update_minimap_icon()

/obj/structure/xeno/spawner/examine(mob/user)
	. = ..()
	var/current_integrity = (obj_integrity / max_integrity) * 100
	switch(current_integrity)
		if(0 to 20)
			. += span_warning("It's barely holding, there's leaking oozes all around, and most eggs are broken. Yet it is not inert.")
		if(20 to 40)
			. += span_warning("It looks severely damaged, its movements slow.")
		if(40 to 60)
			. += span_warning("It's quite beat up, but it seems alive.")
		if(60 to 80)
			. += span_warning("It's slightly damaged, but still seems healthy.")
		if(80 to 100)
			. += span_info("It appears in good shape, pulsating healthily.")


/obj/structure/xeno/spawner/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	spawner_damage_alert()

///Alert if spawner is receiving damage
/obj/structure/xeno/spawner/proc/spawner_damage_alert()
	if(!COOLDOWN_CHECK(src, spawner_damage_alert_cooldown))
		warning = FALSE
		return
	warning = TRUE
	update_minimap_icon()
	GLOB.hive_datums[hivenumber].xeno_message("Our [name] at [AREACOORD_NO_Z(src)] is under attack! It has [obj_integrity]/[max_integrity] Health remaining.", "xenoannounce", 5, FALSE, src, 'sound/voice/alien/help1.ogg',FALSE, null, /atom/movable/screen/arrow/silo_damaged_arrow)
	COOLDOWN_START(src, spawner_damage_alert_cooldown, XENO_SILO_HEALTH_ALERT_COOLDOWN) //set the cooldown.
	addtimer(CALLBACK(src, PROC_REF(clear_warning)), XENO_SILO_DETECTION_COOLDOWN) //clear warning

/obj/structure/xeno/spawner/Destroy()
	GLOB.xeno_spawners_by_hive[hivenumber] -= src
	return ..()

///Change minimap icon if spawner is under attack or not
/obj/structure/xeno/spawner/update_minimap_icon()
	SSminimaps.remove_marker(src)
	SSminimaps.add_marker(src, MINIMAP_FLAG_XENO, image('icons/UI_icons/map_blips.dmi', null, "spawner[warning ? "_warn" : "_passive"]", ABOVE_FLOAT_LAYER))

/// Transfers the spawned minion to the silo's hivenumber.
/obj/structure/xeno/spawner/proc/on_spawn(list/newly_spawned_things)
	for(var/mob/living/carbon/xenomorph/spawned_minion AS in newly_spawned_things)
		spawned_minion.transfer_to_hive(hivenumber)
		linked_minions += spawned_minion
		if(hivenumber == XENO_HIVE_FALLEN) //snowflake so valhalla isnt filled with minions after you're done
			RegisterSignal(src, COMSIG_QDELETING, PROC_REF(kill_linked_minions))

/obj/structure/xeno/spawner/proc/kill_linked_minions()
	for(var/mob/living/carbon/xenomorph/linked in linked_minions)
		linked.death(TRUE)
	UnregisterSignal(src, COMSIG_QDELETING)
