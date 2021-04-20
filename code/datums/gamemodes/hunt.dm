/datum/game_mode/infestation/hunt
	name = "Hunt party"
	config_tag = "Hunt"
	required_players = 2
	flags_round_type = MODE_INFESTATION|MODE_LZ_SHUTTERS|MODE_XENO_RULER
	flags_landmarks = MODE_LANDMARK_SPAWN_XENO_TUNNELS|MODE_LANDMARK_SPAWN_MAP_ITEM
	flags_xeno_abilities = XACT_HUNT
	round_end_states = list(MODE_INFESTATION_X_MAJOR, MODE_INFESTATION_M_MAJOR, MODE_INFESTATION_X_MINOR, MODE_INFESTATION_M_MINOR, MODE_INFESTATION_DRAW_DEATH)

	valid_job_types = list(
		/datum/job/terragov/command/captain = 1,
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/command/staffofficer = 4,
		/datum/job/terragov/command/pilot = 2,
		/datum/job/terragov/engineering/chief = 1,
		/datum/job/terragov/engineering/tech = 2,
		/datum/job/terragov/requisitions/officer = 1,
		/datum/job/terragov/medical/professor = 1,
		/datum/job/terragov/medical/medicalofficer = 6,
		/datum/job/terragov/medical/researcher = 2,
		/datum/job/terragov/civilian/liaison = 1,
		/datum/job/terragov/silicon/synthetic = 1,
		/datum/job/terragov/silicon/ai = 1,
		/datum/job/terragov/squad/engineer = 8,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 1,
		/datum/job/terragov/squad/leader = 1,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/xenomorph = 2,
		/datum/job/xenomorph/queen = 1
	)

/datum/game_mode/infestation/hunt/post_setup()
	. = ..()
	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/structure/resin/silo(i)
	scale_gear()
	addtimer(CALLBACK(src, .proc/announce_bioscans, FALSE, 1), 5 MINUTES)

/datum/game_mode/infestation/hunt/check_finished()
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

	if(round_stage == INFESTATION_DROPSHIP_CAPTURED_XENOS)
		message_admins("Round finished: [MODE_INFESTATION_X_MINOR]")
		round_finished = MODE_INFESTATION_X_MINOR
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
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //marines lost the ground operation but managed to wipe out Xenos on the ship at a greater cost, minor victory
			round_finished = MODE_INFESTATION_M_MINOR
			return TRUE
		message_admins("Round finished: [MODE_INFESTATION_M_MAJOR]") //marines win big
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
	if(round_stage == INFESTATION_MARINE_CRASHING && !num_humans_ship)
		message_admins("Round finished: [MODE_INFESTATION_X_MAJOR]") //xenos wiped our marines, xeno major victory
		round_finished = MODE_INFESTATION_X_MAJOR
		return TRUE
	return FALSE


/datum/game_mode/infestation/hunt/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")

	to_chat(world, "<span class='round_body'>Thus ends the story of the brave men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their struggle on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	var/sound/xeno_track
	var/sound/human_track
	var/sound/ghost_track
	switch(round_finished)
		if(MODE_INFESTATION_X_MAJOR)
			xeno_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			human_track = pick('sound/theme/sad_loss1.ogg', 'sound/theme/sad_loss2.ogg')
			ghost_track = xeno_track
		if(MODE_INFESTATION_M_MAJOR)
			xeno_track = pick('sound/theme/sad_loss1.ogg', 'sound/theme/sad_loss2.ogg')
			human_track = pick('sound/theme/winning_triumph1.ogg', 'sound/theme/winning_triumph2.ogg')
			ghost_track = human_track
		if(MODE_INFESTATION_X_MINOR)
			xeno_track = pick('sound/theme/neutral_hopeful1.ogg', 'sound/theme/neutral_hopeful2.ogg')
			human_track = pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg')
			ghost_track = xeno_track
		if(MODE_INFESTATION_M_MINOR)
			xeno_track = pick('sound/theme/neutral_melancholy1.ogg', 'sound/theme/neutral_melancholy2.ogg')
			human_track = pick('sound/theme/neutral_hopeful1.ogg', 'sound/theme/neutral_hopeful2.ogg')
			ghost_track = human_track
		if(MODE_INFESTATION_DRAW_DEATH)
			ghost_track = pick('sound/theme/nuclear_detonation1.ogg', 'sound/theme/nuclear_detonation2.ogg')
			xeno_track = ghost_track
			human_track = ghost_track

	xeno_track = sound(xeno_track)
	xeno_track.channel = CHANNEL_CINEMATIC
	human_track = sound(human_track)
	human_track.channel = CHANNEL_CINEMATIC
	ghost_track = sound(ghost_track)
	ghost_track.channel = CHANNEL_CINEMATIC

	for(var/i in GLOB.xeno_mob_list)
		var/mob/M = i
		SEND_SOUND(M, xeno_track)

	for(var/i in GLOB.human_mob_list)
		var/mob/M = i
		SEND_SOUND(M, human_track)

	for(var/i in GLOB.observer_list)
		var/mob/M = i
		if(ishuman(M.mind.current))
			SEND_SOUND(M, human_track)
			continue

		if(isxeno(M.mind.current))
			SEND_SOUND(M, xeno_track)
			continue

		SEND_SOUND(M, ghost_track)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_xenomorphs()
	announce_medal_awards()
	announce_round_stats()
	addtimer(CALLBACK(SSvote, /datum/controller/subsystem/vote/proc/automatic_vote), 1 MINUTES)


/datum/game_mode/infestation/hunt/scale_roles(initial_players_assigned)
	. = ..()
	if(!.)
		return
	var/datum/job/scaled_job = SSjob.GetJobType(/datum/job/xenomorph) //Xenos
	scaled_job.job_points_needed  = CONFIG_GET(number/hunt_larvapoints_required)


/datum/game_mode/infestation/hunt/proc/scale_gear()
	var/marine_pop_size = 0

	for(var/i in GLOB.alive_human_list)
		var/mob/living/carbon/human/H = i
		if(ismarinefaction(H))
			marine_pop_size++

	var/scale = max(marine_pop_size / MARINE_GEAR_SCALING, 1) //This gives a decimal value representing a scaling multiplier. Cannot go below 1

	//Scale the amount of cargo points through a direct multiplier
	SSpoints.scale_supply_points(scale)


/datum/game_mode/infestation/hunt/proc/announce_xenomorphs()
	var/datum/hive_status/normal/HN = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(!HN.living_xeno_ruler)
		return

	var/dat = "<span class='round_body'>The surviving xenomorph ruler was:<br>[HN.living_xeno_ruler.key] as <span class='boldnotice'>[HN.living_xeno_ruler]</span></span>"

	to_chat(world, dat)


/datum/game_mode/infestation/hunt/orphan_hivemind_collapse()
	if(round_finished)
		return
	if(round_stage == INFESTATION_MARINE_CRASHING)
		round_finished = MODE_INFESTATION_X_MINOR
		return
	round_finished = MODE_INFESTATION_M_MAJOR


/datum/game_mode/infestation/hunt/get_hivemind_collapse_countdown()
	if(!orphan_hive_timer)
		return
	var/eta = timeleft(orphan_hive_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"
