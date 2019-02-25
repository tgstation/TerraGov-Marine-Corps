#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP	//State of current round used by process()
	var/force_ending = 0					//Round was ended by admin intervention

	var/start_immediately = FALSE //If true, there is no lobby phase, the game starts immediately.
	var/setup_done = FALSE //All game setup done including mode post setup and

	var/hide_mode = FALSE
	var/datum/game_mode/mode = null

	var/login_music							//Music played in pregame lobby
	var/round_end_sound						//Music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE			//If all clients have loaded it

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.
	var/datum/mind/liaison

	var/delay_end = FALSE					//If set true, the round will not restart on it's own
	var/admin_delay_notice = ""				//A message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE			//All roundend preparation done with, all that's left is reboot

	var/tipped = FALSE						//Did we broadcast the tip of the day yet?
	var/selected_tip						//What will be the tip of the day?

	var/time_left							//Pre-game timer
	var/start_at

	var/gametime_offset = 432000			//Deciseconds to add to world.time for station time.

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/late_join_disabled = FALSE

	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"


/datum/controller/subsystem/ticker/Initialize(timeofday)
	load_mode()

	login_music = pick(
	'sound/music/SpaceHero.ogg',
	'sound/music/ManOfWar.ogg',
	'sound/music/PraiseTheLord.ogg',
	'sound/music/BloodUponTheRisers.ogg',
	'sound/music/DawsonChristian.ogg')

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	return ..()


/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in)
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			to_chat(world, "<span class='boldnotice'>Welcome to the pre-game lobby of [CONFIG_GET(string/server_name)]!</span>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [time_left] seconds")
			current_state = GAME_STATE_PREGAME
			fire()
		if(GAME_STATE_PREGAME)
			if(isnull(time_left))
				time_left = max(0,start_at - world.time)
			if(start_immediately)
				time_left = 0

			//countdown
			if(time_left < 0)
				return
			time_left -= wait

			if(time_left <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(time_left <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
				time_left = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)

			if(!roundend_check_paused && mode.check_finished(force_ending) || force_ending)
				current_state = GAME_STATE_FINISHED
				GLOB.ooc_allowed = TRUE
				GLOB.dooc_allowed = TRUE
				mode.declare_completion(force_ending)
				addtimer(CALLBACK(SSvote, /datum/controller/subsystem/vote.proc/initiate_vote, "map", "SERVER"), 15 SECONDS)
				addtimer(CALLBACK(src, .proc/Reboot), 16 SECONDS)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)


/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, "<span class='boldnotice'><b>Enjoy the game!</b></span>")
	var/init_start = world.timeofday
		//Create and announce mode
	var/list/datum/game_mode/runnable_modes
	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = config.get_runnable_modes()

		if(GLOB.master_mode == "secret")
			hide_mode = 1
			if(GLOB.secret_force_mode != "secret")
				var/datum/game_mode/smode = config.pick_mode(GLOB.secret_force_mode)
				if(!smode.can_start())
					message_admins("<span class='danger'>Unable to force secret [GLOB.secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.</span>")
				else
					mode = smode

		if(!mode)
			if(!length(runnable_modes))
				to_chat(world, "<b>Unable to choose playable game mode.</b> Reverting to pre-game lobby.")
				return FALSE
			mode = pickweight(runnable_modes)
			if(!mode)	//too few roundtypes all run too recently
				mode = pick(runnable_modes)

	else
		mode = config.pick_mode(GLOB.master_mode)
		if(!mode.can_start())
			to_chat(world, "<b>Unable to start [mode.name].</b> Not enough players, [mode.required_players] players and [mode.required_enemies] eligible antagonists needed. Reverting to pre-game lobby.")
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return FALSE

	CHECK_TICK
	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	can_continue = src.mode.pre_setup()		//Choose antagonists
	CHECK_TICK
	SSjob.DivideOccupations() 				//Distribute jobs
	CHECK_TICK

	if(!GLOB.Debug2)
		if(!can_continue)
			QDEL_NULL(mode)
			to_chat(world, "<b>Error setting up [GLOB.master_mode].</b> Reverting to pre-game lobby.")
			SSjob.ResetOccupations()
			return FALSE
	else
		message_admins("<span class='notice'>DEBUG: Bypassing prestart checks...</span>")

	CHECK_TICK
	if(hide_mode)
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		to_chat(world, "<b>The gamemode is: secret!\nPossibilities:</B> [english_list(modes)]")
	else
		mode.announce()

	if(CONFIG_GET(flag/autooocmute))
		GLOB.ooc_allowed = TRUE

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters
	collect_minds()
	reset_squads()
	equip_characters()

	data_core.manifest()

	transfer_characters()	//transfer keys to the new mobs

	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)

	supply_controller.process()

	log_world("Game start took [(world.timeofday - init_start) / 10]s")
	round_start_time = world.time
	SSdbcore.SetRoundStart()

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	PostSetup()
	return TRUE


/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	mode.post_setup()

	setup_done = TRUE

	for(var/i in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = i
		if(istype(S))							//we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")


//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()


//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)


/datum/controller/subsystem/ticker/proc/station_explosion_detonation(atom/bomb)
	if(bomb)	//BOOM
		var/turf/epi = bomb.loc
		qdel(bomb)
		if(epi)
			explosion(epi, 0, 256, 512, 0, TRUE, TRUE, 0, TRUE)


/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in GLOB.player_list)
		if(player.ready && player.mind)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/new_player/P in GLOB.player_list)
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless = TRUE
	for(var/mob/new_player/N in GLOB.player_list)
		var/mob/living/carbon/human/player = N.new_character
		if(istype(player) && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Commander")
				captainless = FALSE
			if(player.mind.assigned_role)
				SSjob.EquipRank(N, player.mind.assigned_role, 0)
		CHECK_TICK
	if(captainless)
		for(var/mob/new_player/N in GLOB.player_list)
			if(N.new_character)
				to_chat(N, "Marine Commander position not forced on anyone.")
			CHECK_TICK


/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/new_player/player in GLOB.mob_list)
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			living.notransform = TRUE
			livings += living
	if(length(livings))
		addtimer(CALLBACK(src, .proc/release_characters, livings), 30, TIMER_CLIENT_TIME)


/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.notransform = FALSE


/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = world.file2list("strings/tips.txt")
		var/list/memetips = world.file2list("strings/sillytips.txt")
		if(randomtips.len && prob(95))
			m = pick(randomtips)
		else if(memetips.len)
			m = pick(memetips)

	if(m)
		to_chat(world, "<font color='purple'><b>Tip of the round: </b>[html_encode(m)]</font>")


/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending
	hide_mode = SSticker.hide_mode
	mode = SSticker.mode

	login_music = SSticker.login_music
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	delay_end = SSticker.delay_end

	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	time_left = SSticker.time_left

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	round_start_time = SSticker.round_start_time

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players

	switch(current_state)
		if(GAME_STATE_SETTING_UP)
			Master.SetRunLevel(RUNLEVEL_SETUP)
		if(GAME_STATE_PLAYING)
			Master.SetRunLevel(RUNLEVEL_GAME)
		if(GAME_STATE_FINISHED)
			Master.SetRunLevel(RUNLEVEL_POSTGAME)


/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.time_left))
		return round(max(0, start_at - world.time) / 10)
	return round(time_left / 10)


/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(time_left))	//remember, negative means delayed
		start_at = world.time + newtime
	else
		time_left = newtime


/datum/controller/subsystem/ticker/proc/load_mode()
	var/mode = trim(file2text("data/mode.txt"))
	if(mode)
		GLOB.master_mode = mode
	else
		GLOB.master_mode = "extended"
	log_game("Saved mode is '[GLOB.master_mode]'")


/datum/controller/subsystem/ticker/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)


/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE


/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE

	if(usr && !check_rights(R_SERVER))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldnotice'>An admin has delayed the round end.</span>")
		return

	to_chat(world, "<span class='boldnotice'>Rebooting World in [DisplayTimeText(delay)]. [reason]</span>")

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2))	//don't wait forever
	sleep(delay - (world.time - start_wait))

	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldnotice'>Reboot was cancelled by an admin.</span>")
		return
	if(end_string)
		end_state = end_string

	log_game("<span class='boldnotice'>Rebooting World. [reason]</span>")
	to_chat(world, "<span class='boldnotice'>Rebooting...</span>")

	world.Reboot(TRUE)