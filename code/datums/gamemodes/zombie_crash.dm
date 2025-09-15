/datum/game_mode/infestation/crash/zombie
	name = "Zombie Crash"
	config_tag = "Zombie Crash"
	required_players = 1
	valid_job_types = list(
		/datum/job/terragov/squad/standard = -1,
		/datum/job/terragov/squad/robot = -1,
		/datum/job/terragov/squad/engineer = 1,
		/datum/job/terragov/squad/corpsman = 1,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/command/fieldcommander = 1,
	)
	job_points_needed_by_job_type = list(
		/datum/job/terragov/squad/smartgunner = 20,
		/datum/job/terragov/squad/corpsman = 5,
		/datum/job/terragov/squad/engineer = 5,
	)
	blacklist_ground_maps = list(MAP_WHISKEY_OUTPOST, MAP_OSCAR_OUTPOST)

	round_type_flags = NONE

/datum/game_mode/infestation/crash/zombie/post_setup()
	. = ..()
	for(var/obj/effect/landmark/corpsespawner/corpse AS in GLOB.corpse_landmarks_list)
		corpse.create_zombie()

	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/effect/ai_node/spawner/zombie(i)

/datum/game_mode/infestation/crash/zombie/on_nuke_started(datum/source, obj/machinery/nuclearbomb/nuke)
	return

/datum/game_mode/infestation/crash/zombie/proc/count_humans_and_zombies(list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_MARINE_MAIN_SHIP, ZTRAIT_GROUND, ZTRAIT_RESERVED)), count_flags)
	var/num_humans = 0
	var/num_zombies

	for(var/z in z_levels)
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H)) // Small fix?
				continue
			if(H.faction == FACTION_ZOMBIE)
				num_zombies++
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client && H.afk_status == MOB_DISCONNECTED)
				continue
			if(H.status_flags & XENO_HOST)
				continue
			if(isspaceturf(H.loc))
				continue
			num_humans++
	return list(num_humans, num_zombies)

/datum/game_mode/infestation/crash/zombie/balance_scales()
	var/list/living_player_list = count_humans_and_zombies(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]
	var/num_zombies = living_player_list[2]
	if(num_zombies * 0.1 <= num_humans) // if there's too much zombies, don't spawn even more
		for(var/obj/effect/ai_node/spawner/zombie/spawner AS in GLOB.zombie_spawners)
			spawner.max_amount = 0
		return
	for(var/obj/effect/ai_node/spawner/zombie/spawner AS in GLOB.zombie_spawners)
		spawner.max_amount = clamp(num_humans, 5, 20)

/datum/game_mode/infestation/crash/zombie/get_adjusted_jobworth_list(list/jobworth_list)
	return jobworth_list

/datum/game_mode/infestation/crash/zombie/check_finished(force_end)
	if(round_finished)
		return TRUE

	if(!shuttle_landed && !force_end)
		return FALSE

	if(!length(GLOB.zombie_spawners))
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines destroyed all zombie spawners
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD)
	var/num_humans = living_player_list[1]
	if(num_humans && planet_nuked == INFESTATION_NUKE_NONE && marines_evac == CRASH_EVAC_NONE && !force_end)
		return FALSE

	switch(planet_nuked)
		if(INFESTATION_NUKE_NONE)
			if(!num_humans)
				message_admins("Round finished: [MODE_ZOMBIE_Z_MAJOR]") //xenos wiped out ALL the marines
				round_finished = MODE_ZOMBIE_Z_MAJOR
				return TRUE
			if(marines_evac == CRASH_EVAC_COMPLETED || (!length(GLOB.active_nuke_list) && marines_evac != CRASH_EVAC_NONE))
				message_admins("Round finished: [MODE_ZOMBIE_Z_MINOR]") //marines evaced without a nuke
				round_finished = MODE_ZOMBIE_Z_MINOR
				return TRUE

		if(INFESTATION_NUKE_COMPLETED)
			if(marines_evac == CRASH_EVAC_NONE)
				message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines nuked the planet but didn't evac
				round_finished = MODE_INFESTATION_M_MINOR
				return TRUE
			message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines nuked the planet and managed to evac
			round_finished = MODE_INFESTATION_M_MAJOR
			return TRUE

		if(INFESTATION_NUKE_COMPLETED_SHIPSIDE, INFESTATION_NUKE_COMPLETED_OTHER)
			message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]") //marines nuked themselves somehow
			round_finished = MODE_GENERIC_DRAW_NUKE
			return TRUE
	return FALSE

/datum/game_mode/infestation/crash/zombie/announce()
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))
	priority_announce("Высадка запланирована через 10 минут. Приготовьтесь к посадке. Предварительное сканирование показывает наличие агрессивных форм биологической жизни. Ваша следующая миссия - заполучить коды доступа и активировать ядерную боеголовку. Альтернативная миссия - уничтожить все места появления агрессивных существ.", title = "Доброе утро, товарищи!", type = ANNOUNCEMENT_PRIORITY, sound = 'sound/AI/crash_start.ogg', color_override = "red")
