/datum/game_mode/infestation/distress/warhammer
	name = "Warhammer 40k"
	config_tag = "Warhammer 40k"
	silo_scaling = 2
	evolve_scaling = 2
	maturity_scaling = 2
	valid_job_types = list(
		/datum/job/imperial/skitarii = 3,
		/datum/job/imperial/tech_priest = 2,
		/datum/job/imperial/squad/sergeant = 4,
		/datum/job/imperial/squad/veteran = 2,
		/datum/job/imperial/squad/medicae = 8,
		/datum/job/imperial/squad/standard = -1,
		/datum/job/imperial/commissar = 1,
		/datum/job/xenomorph = FREE_XENO_AT_START,
		/datum/job/xenomorph/queen = 1
	)
	whitelist_ship_maps = list(MAP_BATTLEMACE_OF_FURY)
	/// Timer used to calculate how long till next respawn wave
	var/wave_timer
	///The length of time until next respawn wave.
	var/wave_timer_length = 10 MINUTES
	shutters_drop_time = 3 MINUTES

/datum/game_mode/infestation/distress/warhammer/post_setup()
	. = ..()
	for(var/i in GLOB.nuke_spawn_locs)
		new /obj/machinery/nuclearbomb(i)
	for(var/turf/T AS in GLOB.comms_tower)
		new /obj/structure/comms_tower(T)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_EXPLODED, .proc/on_nuclear_explosion)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_DIFFUSED, .proc/on_nuclear_diffuse)
	RegisterSignal(SSdcs, COMSIG_GLOB_NUKE_START, .proc/on_nuke_started)

/datum/game_mode/infestation/distress/warhammer/scale_roles()
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/imperial/squad/veteran)
	scaled_job.job_points_needed = 5 //For every 5 non vet late joins, 1 extra veteran

/datum/game_mode/infestation/distress/warhammer/setup_blockers()
	. = ..()
	var/datum/game_mode/infestation/distress/warhammer/D = SSticker.mode
	addtimer(CALLBACK(D, /datum/game_mode/infestation/distress/warhammer.proc/respawn_wave), SSticker.round_start_time + shutters_drop_time) //starts wave respawn on shutter drop and begins timer
	addtimer(CALLBACK(D, /datum/game_mode/infestation/distress/warhammer.proc/intro_sequence), SSticker.round_start_time + shutters_drop_time - 10 SECONDS) //starts intro sequence 10 seconds before shutter drop

/datum/game_mode/infestation/distress/warhammer/set_valid_squads()
	SSjob.active_squads[FACTION_IMP] = list()
	for(var/key in SSjob.squads)
		var/datum/squad/squad = SSjob.squads[key]
		if(squad.faction == FACTION_IMP)
			SSjob.active_squads[squad.faction] += squad
	return TRUE

///plays the intro sequence
/datum/game_mode/infestation/distress/warhammer/proc/intro_sequence()
	var/op_name = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name]</u></span><br>" + "[SSmapping.configs[GROUND_MAP].map_name]<br>" + "40092-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "20th Cadian Regiment<br>" + "[human.job.title], [human]<br>", /obj/screen/text/screen_text/picture/cadia)
		SEND_SOUND(human, 'sound/theme/stringstormtts.ogg')

/datum/game_mode/infestation/distress/warhammer/proc/respawn_wave()
	var/datum/game_mode/infestation/distress/warhammer/D = SSticker.mode
	D.wave_timer = addtimer(CALLBACK(D, /datum/game_mode/combat_patrol.proc/respawn_wave), wave_timer_length, TIMER_STOPPABLE)

	for(var/i in GLOB.observer_list)
		var/mob/dead/observer/M = i
		GLOB.key_to_time_of_role_death[M.key] -= respawn_time
		M.playsound_local(M, 'sound/ambience/votestart.ogg', 75, 1)
		M.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>RESPAWN WAVE AVAILABLE</u></span><br>" + "YOU CAN NOW RESPAWN.", /obj/screen/text/screen_text/command_order)
		to_chat(M, "<br><font size='3'>[span_attack("Reinforcements are gathering to join the fight, you can now respawn to join!")]</font><br>")

/datum/game_mode/infestation/distress/warhammer/wave_countdown()
	if(!wave_timer)
		return
	var/eta = timeleft(wave_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

/datum/game_mode/infestation/distress/warhammer/check_finished()
	if(round_finished)
		return TRUE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

	var/living_player_list[] = count_humans_and_xenos(count_flags = COUNT_IGNORE_ALIVE_SSD|COUNT_IGNORE_XENO_SPECIAL_AREA)
	var/num_humans = living_player_list[1]
	var/num_xenos = living_player_list[2]
	var/num_humans_ship = living_player_list[3]

	if(SSevacuation.dest_status == NUKE_EXPLOSION_FINISHED)
		message_admins("Round finished: [MODE_GENERIC_DRAW_NUKE]") //ship blows, no one wins
		round_finished = MODE_GENERIC_DRAW_NUKE
		return TRUE

	if(planet_nuked == INFESTATION_NUKE_COMPLETED)
		message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines managed to nuke the colony
		round_finished = MODE_INFESTATION_M_MINOR
		return TRUE

	if(!num_humans)
		if(!num_xenos)
			message_admins("Round finished: [MODE_INFESTATION_DRAW_DEATH]") //everyone died at the same time, no one wins
			round_finished = MODE_INFESTATION_DRAW_DEATH
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped out ALL the marines without hijacking, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	if(!num_xenos)
		if(round_stage == INFESTATION_MARINE_CRASHING)
			message_admins("Round finished: [MODE_INFESTATION_M_MINOR]") //marines lost the ground operation but managed to wipe out Xenos on the ship at a greater cost, minor victory
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines win big
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
	if(round_stage == INFESTATION_MARINE_CRASHING && !num_humans_ship)
		if(SSevacuation.human_escaped > SSevacuation.initial_human_on_ship * 0.5)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //xenos have control of the ship, but most marines managed to flee
			round_finished = MODE_INFESTATION_X_MINOR
			return
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped our marines, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	return FALSE

/datum/game_mode/infestation/distress/warhammer/siloless_hive_collapse()
	return

/datum/game_mode/infestation/distress/warhammer/get_siloless_collapse_countdown()
	return
