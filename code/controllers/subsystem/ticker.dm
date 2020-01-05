SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP	//State of current round used by process()
	var/force_ending = FALSE					//Round was ended by admin intervention
	var/bypass_checks = FALSE 				//Bypass mode init checks
	var/setup_failed = FALSE 				//If the setup has failed at any point

	var/start_immediately = FALSE //If true, there is no lobby phase, the game starts immediately.
	var/setup_done = FALSE //All game setup done including mode post setup and

	var/datum/game_mode/mode = null

	var/login_music							//Music played in pregame lobby

	var/delay_end = FALSE					//If set true, the round will not restart on it's own
	var/admin_delay_notice = ""				//A message to display to anyone who tries to restart the world after a delay

	var/time_left							//Pre-game timer
	var/start_at

	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/list/round_start_events
	var/list/round_end_events

	var/tipped = FALSE
	var/selected_tip

	var/graceful = FALSE //Will this server gracefully shut down?

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap


/datum/controller/subsystem/ticker/Initialize(timeofday)
	load_mode()

	login_music = pick(
		'sound/music/SpaceHero.ogg',
		'sound/music/ManOfWar.ogg',
		'sound/music/PraiseTheLord.ogg',
		'sound/music/BloodUponTheRisers.ogg',
		'sound/music/DawsonChristian.ogg',
		'sound/music/Bomber.ogg',
	)

	return ..()


/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in && !length(GLOB.clients))
				return
			if(isnull(start_at))
				start_at = time_left || world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients)
				window_flash(C)
			to_chat(world, "<span class='round_body'>Welcome to the pre-game lobby of [CONFIG_GET(string/server_name)]!</span>")
			to_chat(world, "<span class='role_body'>Please, setup your character and select ready. Game will start in [round(time_left / 10) || CONFIG_GET(number/lobby_countdown)] seconds.</span>")
			current_state = GAME_STATE_PREGAME
			fire()

		if(GAME_STATE_PREGAME)
			if(isnull(time_left))
				time_left = max(0, start_at - world.time)
			if(start_immediately)
				time_left = 0

			if(time_left <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			//countdown
			if(time_left < 0)
				return
			time_left -= wait

			if(time_left <= 0)
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			setup_failed = !setup()
			if(setup_failed)
				current_state = GAME_STATE_STARTUP
				time_left = null
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
				start_immediately = FALSE
				Master.SetRunLevel(RUNLEVEL_LOBBY)

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()

			if(!roundend_check_paused && mode.check_finished(force_ending) || force_ending)
				current_state = GAME_STATE_FINISHED
				GLOB.ooc_allowed = TRUE
				GLOB.dooc_allowed = TRUE
				mode.declare_completion(force_ending)
				addtimer(CALLBACK(SSvote, /datum/controller/subsystem/vote.proc/initiate_vote, "shipmap", "SERVER"), 2 SECONDS)
				addtimer(CALLBACK(SSvote, /datum/controller/subsystem/vote.proc/initiate_vote, "groundmap", "SERVER"), 63 SECONDS)
				addtimer(CALLBACK(src, .proc/Reboot), 63 SECONDS)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)


/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, "<span class='boldnotice'><b>Enjoy the game!</b></span>")
	var/init_start = world.timeofday
	//Create and announce mode
	mode = config.pick_mode(GLOB.master_mode)

	CHECK_TICK
	if(!mode.can_start(bypass_checks))
		to_chat(world, "Reverting to pre-game lobby.")
		QDEL_NULL(mode)
		SSjob.ResetOccupations()
		return FALSE

	CHECK_TICK
	if(!mode.pre_setup() && !bypass_checks)
		QDEL_NULL(mode)
		to_chat(world, "<b>Error in pre-setup for [GLOB.master_mode].</b> Reverting to pre-game lobby.")
		SSjob.ResetOccupations()
		return FALSE

	CHECK_TICK
	if(!mode.setup() && !bypass_checks)
		QDEL_NULL(mode)
		to_chat(world, "<b>Error in setup for [GLOB.master_mode].</b> Reverting to pre-game lobby.")
		SSjob.ResetOccupations()
		return FALSE

	CHECK_TICK
	mode.announce()

	if(CONFIG_GET(flag/autooocmute))
		GLOB.ooc_allowed = TRUE

	CHECK_TICK
	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)
	CHECK_TICK

	GLOB.datacore.manifest()

	log_world("Game start took [(world.timeofday - init_start) / 10]s")
	round_start_time = world.time
	SSdbcore.SetRoundStart()

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	CHECK_TICK
	PostSetup()
	return TRUE


/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	mode.post_setup()

	setup_done = TRUE

	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
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

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING


/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending
	mode = SSticker.mode

	login_music = SSticker.login_music

	delay_end = SSticker.delay_end

	time_left = SSticker.time_left

	tipped = SSticker.tipped

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
		GLOB.master_mode = "Extended"
	log_game("Saved mode is '[GLOB.master_mode]'")


/datum/controller/subsystem/ticker/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)


/datum/controller/subsystem/ticker/proc/Reboot(reason, delay)
	set waitfor = FALSE

	if(usr && !check_rights(R_SERVER))
		return

	if(istype(GLOB.tgs, /datum/tgs_api/v3210))
		var/datum/tgs_api/v3210/API = GLOB.tgs
		if(API.reboot_mode == 2)
			graceful = TRUE
	else if(istype(GLOB.tgs, /datum/tgs_api/v4))
		var/datum/tgs_api/v4/API = GLOB.tgs
		if(API.reboot_mode == 1)
			graceful = TRUE

	if(graceful)
		to_chat_immediate(world, "<h3><span class='boldnotice'>Shutting down...</span></h3>")
		world.Reboot(FALSE)
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldnotice'>An admin has delayed the round end.</span>")
		return

	to_chat(world, "<span class='boldnotice'>Rebooting World in [DisplayTimeText(delay)]. [reason]</span>")

	var/start_wait = world.time
	sleep(delay - (world.time - start_wait))

	if(delay_end && !skip_delay)
		to_chat(world, "<span class='boldnotice'>Reboot was cancelled by an admin.</span>")
		return

	log_game("Rebooting World. [reason]")
	to_chat_immediate(world, "<h3><span class='boldnotice'>Rebooting...</span></h3>")

	world.Reboot(TRUE)


/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/tip

	if(selected_tip)
		tip = selected_tip
	else if(prob(95) && length(ALLTIPS))
		tip = pick(ALLTIPS)
	else if(length(SSstrings.get_list_from_file("tips/meme")))
		tip = pick(SSstrings.get_list_from_file("tips/meme"))

	if(tip)
		to_chat(world, "<br><span class='tip'>[html_encode(tip)]</span><br>")


/datum/controller/subsystem/ticker/proc/check_queue()
	if(!length(queued_players))
		return
	var/hpc = CONFIG_GET(number/hard_popcap)
	if(!hpc)
		listclearnulls(queued_players)
		for(var/mob/new_player/NP in queued_players)
			to_chat(NP, "<span class='userdanger'>The alive players limit has been released!<br><a href='?src=[REF(NP)];lobby_choice=late_join;override=1'>[html_encode(">>Join Game<<")]</a></span>")
			SEND_SOUND(NP, sound('sound/misc/notice1.ogg', channel = CHANNEL_NOTIFY))
			NP.LateChoices()
		queued_players.Cut()
		queue_delay = 0
		return

	queue_delay++
	var/mob/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			listclearnulls(queued_players)
			if(living_player_count() < hpc)
				if(next_in_line?.client)
					to_chat(next_in_line, "<span class='userdanger'>A slot has opened! You have approximately 20 seconds to join. <a href='?src=[REF(next_in_line)];lobby_choice=latejoin;override=1'>\>\>Join Game\<\<</a></span>")
					SEND_SOUND(next_in_line, sound('sound/misc/notice1.ogg', channel = CHANNEL_NOTIFY))
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, "<span class='danger'>No response received. You have been removed from the line.</span>")
			queued_players -= next_in_line
			queue_delay = 0
