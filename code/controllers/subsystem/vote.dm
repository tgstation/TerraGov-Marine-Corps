SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 10

	flags = SS_KEEP_TIMING|SS_NO_INIT

	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	/// Available choices in the vote
	var/list/choices = list()
	/// What choice each player took, if any
	var/list/choice_by_ckey = list()
	/// Who started the vote
	var/initiator
	/// On what subject the vote is about
	var/mode
	/// The question that will be asked
	var/question
	/// When the vote was started
	var/started_time
	/// How long till the vote is resolved
	var/time_remaining
	/// Who already voted
	var/list/voted = list()
	/// Who can vote
	var/list/voting = list()
	/// If a vote is currently taking place
	var/vote_happening = FALSE

// Called by master_controller
/datum/controller/subsystem/vote/fire()
	if(!mode)
		return
	time_remaining = round((started_time + CONFIG_GET(number/vote_period) - world.time)/10)
	if(time_remaining < 0)
		result()
		SStgui.close_uis(src)
		reset()

/// Stop the current vote and reset everything
/datum/controller/subsystem/vote/proc/reset()
	choices.Cut()
	choice_by_ckey.Cut()
	initiator = null
	mode = null
	question = null
	time_remaining = 0
	voted.Cut()
	voting.Cut()
	vote_happening = FALSE

	remove_action_buttons()


/// Tally the results and give the winner
/datum/controller/subsystem/vote/proc/get_result()
	//get the highest number of votes
	var/greatest_votes = 0
	var/total_votes = 0
	for(var/option in choices)
		var/votes = choices[option]
		total_votes += votes
		if(votes > greatest_votes)
			greatest_votes = votes
	//default-vote for everyone who didn't vote
	if(!CONFIG_GET(flag/default_no_vote) && length(choices))
		var/list/non_voters = GLOB.directory.Copy()
		non_voters -= voted
		for (var/non_voter_ckey in non_voters)
			var/client/C = non_voters[non_voter_ckey]
			if(!C || C.is_afk())
				non_voters -= non_voter_ckey
		if(length(non_voters) > 0)
			if(mode == "restart")
				choices["Continue Playing"] += length(non_voters)
				if(choices["Continue Playing"] >= greatest_votes)
					greatest_votes = choices["Continue Playing"]
			else if(mode == "gamemode")
				if(GLOB.master_mode in choices)
					choices[GLOB.master_mode] += length(non_voters)
					if(choices[GLOB.master_mode] >= greatest_votes)
						greatest_votes = choices[GLOB.master_mode]
	. = list()
	if(greatest_votes)
		for(var/option in choices)
			if(choices[option] == greatest_votes)
				. += option


/// Announce the votes tally to everyone
/datum/controller/subsystem/vote/proc/announce_result()
	var/list/winners = get_result()
	var/text
	if(length(winners) > 0)
		if(question)
			text += "<b>[question]</b>"
		else
			text += "<b>[capitalize(mode)] Vote</b>"
		for(var/i = 1 to length(choices))
			var/votes = choices[choices[i]]
			if(!votes)
				votes = 0
			text += "\n<b>[choices[i]]:</b> [votes]"
		if(mode != "custom")
			if(length(winners) > 1)
				text = "\n<b>Vote Tied Between:</b>"
				for(var/option in winners)
					text += "\n\t[option]"
			. = pick(winners)
			text += "\n<b>Vote Result: [.]</b>"
		else
			text += "\n<b>Did not vote:</b> [length(GLOB.clients) - length(voted)]"
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	log_vote(text)
	vote_happening = FALSE
	remove_action_buttons()
	to_chat(world, "\n<font color='purple'>[text]</font>")


/// Apply the result of the vote if it's possible
/datum/controller/subsystem/vote/proc/result()
	. = announce_result()
	var/restart = FALSE
	if(.)
		switch(mode)
			if("restart")
				if(. == "Restart Round")
					restart = TRUE
			if("gamemode")
				if(GLOB.master_mode != .)
					SSticker.save_mode(.)
					if(SSticker.HasRoundStarted())
						restart = TRUE
					else
						GLOB.master_mode = .
			if("groundmap")
				var/datum/map_config/VM = config.maplist[GROUND_MAP][.]
				SSmapping.changemap(VM, GROUND_MAP)
			if("shipmap")
				var/datum/map_config/VM = config.maplist[SHIP_MAP][.]
				SSmapping.changemap(VM, SHIP_MAP)
	if(restart)
		var/active_admins = FALSE
		for(var/client/C in GLOB.admins)
			if(!C.is_afk() && check_rights_for(C, R_SERVER))
				active_admins = TRUE
				break
		if(!active_admins)
			// No delay in case the restart is due to lag
			SSticker.Reboot("Restart vote successful.", "restart vote", 1)
		else
			to_chat(world, "<span style='boltnotice'>Notice:Restart vote will not restart the server automatically because there are active admins on.</span>")
			message_admins("A restart vote has passed, but there are active admins on with +SERVER, so it has been canceled. If you wish, you may restart the server.")



/// Register the vote of one player
/datum/controller/subsystem/vote/proc/submit_vote(vote)
	if(!mode)
		return FALSE
	if(CONFIG_GET(flag/no_dead_vote) && usr.stat == DEAD && !usr.client.holder)
		return FALSE
	if(!vote || vote < 1 || vote > length(choices))
		return FALSE
	// If user has already voted, remove their specific vote
	if(usr.ckey in voted)
		choices[choices[choice_by_ckey[usr.ckey]]]--
	else
		voted += usr.ckey
	choice_by_ckey[usr.ckey] = vote
	choices[choices[vote]]++
	return vote

/// Start the vote, and prepare the choices to send to everyone
/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, initiator_key, ignore_delay = FALSE)
	//Server is still intializing.
	if(!Master.current_runlevel)
		to_chat(usr, "<span class='warning'>Cannot start vote, server is not done initializing.</span>")
		return FALSE
	var/lower_admin = FALSE
	if(initiator_key)
		var/ckey = ckey(initiator_key)
		if(GLOB.admin_datums[ckey])
			lower_admin = TRUE

	if(!mode)
		if(started_time && !ignore_delay)
			var/next_allowed_time = (started_time + CONFIG_GET(number/vote_delay))
			if(mode)
				to_chat(usr, "<span class='warning'>There is already a vote in progress! please wait for it to finish.</span>")
				return FALSE
			if(next_allowed_time > world.time && !lower_admin)
				to_chat(usr, "<span class='warning'>A vote was initiated recently, you must wait [DisplayTimeText(next_allowed_time-world.time)] before a new vote can be started!</span>")
				return FALSE

		reset()
		switch(vote_type)
			if("restart")
				choices.Add("Restart Round", "Continue Playing")
			if("gamemode")
				choices.Add(config.votable_modes)
			if("groundmap")
				if(!lower_admin && SSmapping.groundmap_voted)
					to_chat(usr, "<span class='warning'>The next ground map has already been selected.</span>")
					return FALSE
				var/list/maps = list()
				for(var/map in config.maplist[GROUND_MAP])
					var/datum/map_config/VM = config.maplist[GROUND_MAP][map]
					if(!VM.voteweight)
						continue
					if(VM.config_max_users || VM.config_min_users)
						var/players = length(GLOB.clients)
						if(VM.config_max_users && players > VM.config_max_users)
							continue
						if(VM.config_min_users && players < VM.config_min_users)
							continue
					maps += VM.map_name
					shuffle_inplace(maps)
				for(var/valid_map in maps)
					choices.Add(valid_map)
			if("shipmap")
				if(!lower_admin && SSmapping.shipmap_voted)
					to_chat(usr, "<span class='warning'>The next ship map has already been selected.</span>")
					return FALSE
				var/list/maps = list()
				for(var/map in config.maplist[SHIP_MAP])
					var/datum/map_config/VM = config.maplist[SHIP_MAP][map]
					if(!VM.voteweight)
						continue
					if(VM.config_max_users || VM.config_min_users)
						var/players = length(GLOB.clients)
						if(VM.config_max_users && players > VM.config_max_users)
							continue
						if(VM.config_min_users && players < VM.config_min_users)
							continue
					maps += VM.map_name
					shuffle_inplace(maps)
				for(var/valid_map in maps)
					choices.Add(valid_map)
			if("custom")
				question = stripped_input(usr, "What is the vote for?")
				if(!question)
					return FALSE
				for(var/i = 1 to 10)
					var/option = capitalize(stripped_input(usr, "Please enter an option or hit cancel to finish"))
					if(!option || mode || !usr.client)
						break
					choices.Add(option)
			else
				return FALSE
		mode = vote_type
		initiator = initiator_key
		started_time = world.time
		var/text = "[capitalize(mode)] vote started by [initiator ? initiator : "server"]."
		if(mode == "custom")
			text += "<br>[question]"
		log_vote(text)
		var/vp = CONFIG_GET(number/vote_period)
		SEND_SOUND(world, sound('sound/ambience/votestart.ogg', channel = CHANNEL_NOTIFY))
		to_chat(world, "<br><font color='purple'><b>[text]</b><br>Type <b>vote</b> or click on vote action (top left) to place your votes.<br>You have [DisplayTimeText(vp)] to vote.</font>")
		time_remaining = round(vp/10)
		vote_happening = TRUE
		for(var/c in GLOB.clients)
			var/client/C = c
			var/datum/action/innate/vote/V = new
			if(question)
				V.name = "Vote: [question]"
			C.player_details.player_actions += V
			V.give_action(C.mob)
		return TRUE
	return FALSE

/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"
	SSvote.ui_interact(usr)

///Starts the automatic map vote at the end of each round
/datum/controller/subsystem/vote/proc/automatic_vote()
	initiate_vote("groundmap", null, TRUE)
	addtimer(CALLBACK(src, .proc/initiate_vote, "shipmap", null, TRUE), 65 SECONDS)

/datum/controller/subsystem/vote/ui_state()
	return GLOB.always_state

/datum/controller/subsystem/vote/ui_interact(mob/user, datum/tgui/ui)
	// Tracks who is voting
	if(!(user.client?.ckey in voting))
		voting += user.client?.ckey
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Vote")
		ui.open()

/datum/controller/subsystem/vote/ui_data(mob/user)
	var/list/data = list(
		"choices" = list(),
		"lower_admin" = !!user.client?.holder,
		"mode" = mode,
		"question" = question,
		"selected_choice" = choice_by_ckey[user.client?.ckey],
		"time_remaining" = time_remaining,
		"upper_admin" = check_rights_for(user.client, R_ADMIN),
		"voting" = list(),
		"allow_vote_groundmap" = CONFIG_GET(flag/allow_vote_groundmap),
		"allow_vote_shipmap" = CONFIG_GET(flag/allow_vote_shipmap),
		"allow_vote_mode" = CONFIG_GET(flag/allow_vote_mode),
		"allow_vote_restart" = CONFIG_GET(flag/allow_vote_restart),
		"vote_happening" = vote_happening,
	)

	if(!!user.client?.holder)
		data["voting"] = voting

	for(var/key in choices)
		data["choices"] += list(list(
			"name" = key,
			"votes" = choices[key] || 0
		))

	return data

/datum/controller/subsystem/vote/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/upper_admin = FALSE
	if(usr.client.holder)
		if(check_rights_for(usr.client, R_ADMIN))
			upper_admin = TRUE

	switch(action)
		if("cancel")
			if(usr.client.holder)
				usr.log_message("[key_name_admin(usr)] cancelled a vote.", LOG_ADMIN)
				message_admins("[key_name_admin(usr)] has cancelled the current vote.")
				reset()
		if("toggle_restart")
			if(usr.client.holder && upper_admin)
				CONFIG_SET(flag/allow_vote_restart, !CONFIG_GET(flag/allow_vote_restart))
		if("toggle_gamemode")
			if(usr.client.holder && upper_admin)
				CONFIG_SET(flag/allow_vote_mode, !CONFIG_GET(flag/allow_vote_mode))
		if("toggle_groundmap")
			if(usr.client.holder && upper_admin)
				CONFIG_SET(flag/allow_vote_groundmap, !CONFIG_GET(flag/allow_vote_groundmap))
		if("toggle_shipmap")
			if(usr.client.holder && upper_admin)
				CONFIG_SET(flag/allow_vote_shipmap, !CONFIG_GET(flag/allow_vote_shipmap))
		if("restart")
			if(CONFIG_GET(flag/allow_vote_restart) || usr.client.holder)
				initiate_vote("restart",usr.key)
		if("gamemode")
			if(CONFIG_GET(flag/allow_vote_mode) || usr.client.holder)
				initiate_vote("gamemode",usr.key)
		if("groundmap")
			if(CONFIG_GET(flag/allow_vote_groundmap) || usr.client.holder)
				initiate_vote("groundmap",usr.key)
		if("shipmap")
			if(CONFIG_GET(flag/allow_vote_shipmap) || usr.client.holder)
				initiate_vote("shipmap",usr.key)
		if("custom")
			if(usr.client.holder)
				initiate_vote("custom",usr.key)
		if("vote")
			submit_vote(round(text2num(params["index"])))
	return TRUE

/datum/controller/subsystem/vote/proc/remove_action_buttons()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_REMOVE_VOTE_BUTTON)

/datum/controller/subsystem/vote/ui_close(mob/user)
	voting -= user.client?.ckey

/datum/action/innate/vote
	name = "Vote!"
	action_icon_state = "vote"

/datum/action/innate/vote/give_action(mob/M)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_REMOVE_VOTE_BUTTON, .proc/remove_vote_action)

/datum/action/innate/vote/proc/remove_vote_action(datum/source)
	SIGNAL_HANDLER

	if(remove_from_client())
		remove_action(owner)
	qdel(src)

/datum/action/innate/vote/action_activate()
	owner.vote()

/datum/action/innate/vote/proc/remove_from_client()
	if(!owner)
		return FALSE
	if(owner.client)
		owner.client.player_details.player_actions -= src
	else if(owner.ckey)
		var/datum/player_details/P = GLOB.player_details[owner.ckey]
		if(P)
			P.player_actions -= src
	return TRUE
