/datum/game_mode/infestation/crash/zombie
	name = "Zombie Crash"
	config_tag = "Zombie Crash"
	flags_round_type = MODE_XENO_SPAWN_PROTECTION
	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/fieldcommander = 1,
	)
	///How many points can be spent by the zombie overmind
	var/zombie_points = 0
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST, MAP_FORT_PHOBOS)


/datum/game_mode/infestation/crash/zombie/on_nuke_started(datum/source, obj/machinery/nuclearbomb/nuke)
	return

/datum/game_mode/infestation/crash/zombie/on_xeno_evolve(datum/source, mob/living/carbon/xenomorph/new_xeno)
	return

/datum/game_mode/infestation/crash/zombie/balance_scales()
	zombie_points += get_total_joblarvaworth()
