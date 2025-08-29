/datum/game_mode/infestation/survival
	name = "Survival"
	config_tag = "Survival"
	round_type_flags = MODE_INFESTATION|MODE_DISALLOW_RAILGUN|MODE_PSY_POINTS|MODE_XENO_SPAWN_PROTECT|MODE_SURVIVAL
	xeno_abilities_flags = ABILITY_ALL_GAMEMODE
	factions = list(FACTION_XENO, FACTION_CLF, FACTION_TERRAGOV)
	human_factions = list(FACTION_TERRAGOV, FACTION_CLF)
	valid_job_types = list(
		/datum/job/survivor/assistant = 2,
		/datum/job/survivor/scientist = 1,
		/datum/job/survivor/doctor = 2,
		/datum/job/survivor/liaison = 1,
		/datum/job/survivor/security = 4,
		/datum/job/survivor/civilian = 6,
		/datum/job/survivor/chef = 1,
		/datum/job/survivor/botanist = 1,
		/datum/job/survivor/atmos = 2,
		/datum/job/survivor/chaplain = 1,
		/datum/job/survivor/miner = 2,
		/datum/job/survivor/salesman = 1,
		/datum/job/survivor/marshal = 1,
		/datum/job/survivor/non_deployed_operative = 2,
		/datum/job/survivor/prisoner = 6,
		/datum/job/survivor/stripper = 4,
		/datum/job/survivor/maid = 4,
		/datum/job/clf/standard = 1,
		/datum/job/clf/medic = 1,
		/datum/job/clf/specialist = 1,
		/datum/job/clf/tech = 1,
		/datum/job/clf/leader = 1,
		/datum/job/xenomorph = 2
	)

	shutters_drop_time = 5 SECONDS
	deploy_time_lock = 5 SECONDS
	xenorespawn_time = 2 MINUTES
	whitelist_ground_maps = list(MAP_COLONY1)
	blacklist_ground_maps = null
	whitelist_ship_maps = list(MAP_EAGLE) //since it dont have survivor spawns, they should spawn at colony itself. And can be used to spawn marines later. Eagle is a fast dropship for emergency response.
	bioscan_interval = 0

/datum/game_mode/infestation/survival/post_setup()
	. = ..()

	if(!(round_type_flags & MODE_INFESTATION))
		return

	for(var/i in GLOB.xeno_resin_silo_turfs)
		new /obj/structure/xeno/silo(i)
		new /obj/structure/xeno/pherotower(i)

	for(var/i in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		if(isxenolarva(i)) // Larva
			var/mob/living/carbon/xenomorph/larva/X = i
			X.evolution_stored = X.xeno_caste.evolution_threshold //Immediate roundstart evo for larva.
		else // Handles Shrike etc
			var/mob/living/carbon/xenomorph/X = i
			X.upgrade_stored = X.xeno_caste.upgrade_threshold


/datum/game_mode/infestation/survival/announce()
	to_chat(world, span_round_header("The current map is - [SSmapping.configs[GROUND_MAP].map_name]!"))
	to_chat(world, span_information("The brave colonists from earth were just settling down in this colony in some part of the planet XF-69, Surely nothing will go out of the ordinary this shift. // Stick to roleplay requirements."))
	priority_announce(
		message = "It's the beginning of another profitable shift in [SSmapping.configs[GROUND_MAP].map_name]. Make Ninetails proud!",
		title = "Good morning, crew.",
		type = ANNOUNCEMENT_PRIORITY,
		color_override = "blue"
	)
	var/sound/S = sound(get_sfx(SFX_QUEEN), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	for(var/i in (GLOB.xeno_mob_list + GLOB.observer_list))
		var/mob/M = i
		SEND_SOUND(M, S)
		to_chat(M, assemble_alert(
			title = "Queen Mother Calls.",
			message = "Wake my children. It is time for you to wake from your sleep as new hosts are coming nearby... Capture the hosts and form a new hive out of them.",
			color_override = "purple"
		))
		to_chat(M, span_information("You are a xenomorph, your primary goal is to breed as many hosts as possible while keeping yourself and the larvas in the hosts alive. You must still stick to roleplay standards. There is no time limit in this mode, take your time with erp or whatever rather than spamming impregnate on people. Game ends when all Xenos or Humans die. If you allow the talls to call for help, you will have trouble."))
		to_chat(world, span_boldwarning("Xenos can not see mobs through walls in this mode."))


/datum/game_mode/infestation/survival/check_finished()

	if(world.time < (SSticker.round_start_time + 5 MINUTES))
		return FALSE

	var/list/living_player_list = count_humans_and_xenos(count_flags = COUNT_IGNORE_HUMAN_SSD|COUNT_IGNORE_XENO_SSD)
	var/num_humans = living_player_list[1]
	var/datum/job/xeno_job = SSjob.GetJobType(/datum/job/xenomorph)
	var/num_xenos = xeno_job.total_positions
	if(round_finished)
		if(num_humans > num_xenos)
			message_admins("Round finished: NTC Minor Victory.") //there were more humans than xenos left when round ended.
			round_finished = MODE_INFESTATION_M_MINOR
		else if (num_humans >= 1 && num_humans < num_xenos)
			message_admins("Round finished: [MODE_INFESTATION_X_MINOR]") //there are survivors but xeno numbers are higher than humans.
			round_finished = MODE_INFESTATION_X_MINOR
			return TRUE
		to_chat(world, span_round_body("There were [num_humans] (non ssd) humans and [num_xenos] xenomorphs alive at round end."))
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
		message_admins("Round finished: NTC Major Victory.") //marines win big
		round_finished = MODE_INFESTATION_M_MAJOR
		return TRUE
