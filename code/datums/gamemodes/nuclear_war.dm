/datum/game_mode/infestation/distress/nuclear_war
	name = "Nuclear War"
	config_tag = "Nuclear War"
	silo_scaling = 3

/datum/game_mode/infestation/distress/nuclear_war/post_setup()
	. = ..()
	for(var/i in GLOB.nuke_spawn_locs)
		new /obj/machinery/nuclearbomb(i)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, .proc/on_nuclear_explosion)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, .proc/on_nuclear_diffuse)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, .proc/on_nuke_started)

/datum/game_mode/infestation/distress/nuclear_war/siloless_hive_collapse()
	return

/datum/game_mode/infestation/distress/nuclear_war/get_siloless_collapse_countdown()
	return
