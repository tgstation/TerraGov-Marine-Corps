SUBSYSTEM_DEF(vote)
	name = "Vote"
	wait = 10

	flags = SS_KEEP_TIMING|SS_NO_INIT

	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	var/initiator = null
	var/started_time = null
	var/time_remaining = 0
	var/mode = null
	var/question = null
	var/list/choices = list()
	var/list/voted = list()
	var/list/voting = list()
	var/list/generated_actions = list()


/datum/controller/subsystem/vote/fire()
	if(mode)
		time_remaining = round((started_time + CONFIG_GET(number/vote_period) - world.time)/10)

		if(time_remaining < 0)
			result()
			for(var/client/C in voting)
				C << browse(null, "window=vote;can_close=0")
			reset()
		else
			var/datum/browser/client_popup
			for(var/client/C in voting)
				client_popup = new(C, "vote", "Voting Panel")
				client_popup.set_window_options("can_close=0")
				client_popup.set_content(interface(C))
				client_popup.open(FALSE)


/datum/controller/subsystem/vote/proc/reset()
	initiator = null
	time_remaining = 0
	mode = null
	question = null
	choices.Cut()
	voted.Cut()
	voting.Cut()


/datum/controller/subsystem/vote/proc/get_result()
	var/greatest_votes = 0
	var/total_votes = 0
	for(var/option in choices)
		var/votes = choices[option]
		total_votes += votes
		if(votes > greatest_votes)
			greatest_votes = votes
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
	return .


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
			text += "<br><b>[choices[i]]:</b> [votes]"
		if(mode != "custom")
			if(length(winners) > 1)
				text = "<br><b>Vote Tied Between:</b>"
				for(var/option in winners)
					text += "<br>[GLOB.TAB][option]"
			. = pick(winners)
			text += "<br><b>Vote Result: [.]</b>"
		else
			text += "<br><b>Did not vote:</b> [length(GLOB.clients) - length(voted)]"
	else
		text += "<b>Vote Result: Inconclusive - No Votes!</b>"
	log_vote(text)
	to_chat(world, "<br><font color='purple'>[text]</font>")
	return .


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
			if("map")
				var/datum/map_config/VM = config.maplist[.]
				SSmapping.changemap(VM)
	if(restart)
		var/active_admins = 0
		for(var/client/C in GLOB.admins)
			if(!C.is_afk() && check_other_rights(C, R_SERVER, FALSE))
				active_admins = TRUE
				break
		if(!active_admins)
			SSticker.Reboot("Restart vote successful.", "restart vote")
		else
			to_chat(world, "<span style='boltnotice'>Notice:Restart vote will not restart the server automatically because there are active admins on.</span>")
			message_admins("A restart vote has passed, but there are active admins on with +SERVER, so it has been canceled. If you wish, you may restart the server.")

	return .


/datum/controller/subsystem/vote/proc/submit_vote(vote)
	if(mode)
		if(CONFIG_GET(flag/no_dead_vote) && usr.stat == DEAD && !check_other_rights(usr.client, R_ADMIN, FALSE))
			return FALSE
		if(!(usr.ckey in voted))
			if(vote && 1 <= vote && vote <= length(choices))
				voted += usr.ckey
				choices[choices[vote]]++
				return vote
	return FALSE


/datum/controller/subsystem/vote/proc/initiate_vote(vote_type, initiator_key)
	if(!mode)
		if(started_time)
			var/next_allowed_time = (started_time + CONFIG_GET(number/vote_delay))
			if(mode)
				to_chat(usr, "<span class='warning'>There is already a vote in progress! please wait for it to finish.</span>")
				return FALSE

			var/admin = FALSE
			var/ckey = ckey(initiator_key)
			if(GLOB.admin_datums[ckey] || initiator_key == "SERVER")
				admin = TRUE

			if(next_allowed_time > world.time && !admin)
				to_chat(usr, "<span class='warning'>A vote was initiated recently, you must wait [DisplayTimeText(next_allowed_time-world.time)] before a new vote can be started!</span>")
				return FALSE

		reset()
		switch(vote_type)
			if("restart")
				choices.Add("Restart Round", "Continue Playing")
			if("gamemode")
				choices.Add(config.votable_modes)
			if("map")
				var/list/maps = list()
				for(var/i in config.maplist)
					var/datum/map_config/VM = config.maplist[i]
					if(!VM.voteweight)
						continue
					maps += i
				choices.Add(maps)
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
		var/text = "[capitalize(mode)] vote started by [initiator]."
		if(mode == "custom")
			text += "<br>[question]"
		log_vote(text)
		var/vp = CONFIG_GET(number/vote_period)
		SEND_SOUND(world, 'sound/ambience/alarm4.ogg')
		to_chat(world, "<br><font color='purple'><b>[text]</b><br>Type <b>vote</b> or click <a href='?src=[REF(src)]'>here</a> to place your votes.<br>You have [DisplayTimeText(vp)] to vote.</font>")
		time_remaining = round(vp/10)
		return TRUE
	return FALSE


/datum/controller/subsystem/vote/proc/interface(client/C)
	if(!C)
		return
	var/admin = FALSE
	if(check_other_rights(C, R_ADMIN, FALSE))
		admin = TRUE
	voting |= C

	if(mode)
		if(question)
			. += "<h2>Vote: '[question]'</h2>"
		else
			. += "<h2>Vote: [capitalize(mode)]</h2>"
		. += "Time Left: [time_remaining] s<hr><ul>"
		for(var/i = 1 to length(choices))
			var/votes = choices[choices[i]]
			if(!votes)
				votes = 0
			. += "<li><a href='?src=[REF(src)];vote=[i]'>[choices[i]]</a> ([votes] votes)</li>"
		. += "</ul><hr>"
		if(admin)
			. += "(<a href='?src=[REF(src)];vote=cancel'>Cancel Vote</a>) "
	else
		. += "<h2>Start a vote:</h2><hr><ul><li>"

		var/avr = CONFIG_GET(flag/allow_vote_restart)
		if(avr)
			. += "<a href='?src=[REF(src)];vote=restart'>Restart</a>"
		else
			. += "<font color='grey'>Restart (Disallowed)</font>"
		if(admin)
			. += "[GLOB.TAB](<a href='?src=[REF(src)];vote=toggle_restart'>[avr ? "Allowed" : "Disallowed"]</a>)"
		. += "</li><li>"

		var/avm = CONFIG_GET(flag/allow_vote_mode)
		if(avm)
			. += "<a href='?src=[REF(src)];vote=gamemode'>GameMode</a>"
		else
			. += "<font color='grey'>GameMode (Disallowed)</font>"
		if(admin)
			. += "[GLOB.TAB](<a href='?src=[REF(src)];vote=toggle_gamemode'>[avm ? "Allowed" : "Disallowed"]</a>)"

		. += "</li>"
		if(admin)
			. += "<li><a href='?src=[REF(src)];vote=map'>Map Vote</a></li>"
			. += "<li><a href='?src=[REF(src)];vote=custom'>Custom</a></li>"
		. += "</ul><hr>"
	. += "<a href='?src=[REF(src)];vote=close' style='position:absolute;right:50px'>Close</a>"
	return .


/datum/controller/subsystem/vote/Topic(href, href_list[], hsrc)
	. = ..()
	if(.)
		return
	if(!usr || !usr.client)
		return

	switch(href_list["vote"])
		if("close")
			voting -= usr.client
			usr << browse(null, "window=vote")
			return
		if("cancel")
			if(check_other_rights(usr.client, R_ADMIN, FALSE))
				reset()
		if("toggle_restart")
			if(check_other_rights(usr.client, R_ADMIN, FALSE))
				CONFIG_SET(flag/allow_vote_restart, !CONFIG_GET(flag/allow_vote_restart))
		if("toggle_gamemode")
			if(check_other_rights(usr.client, R_ADMIN, FALSE))
				CONFIG_SET(flag/allow_vote_mode, !CONFIG_GET(flag/allow_vote_mode))
		if("restart")
			if(CONFIG_GET(flag/allow_vote_restart) || check_other_rights(usr.client, R_ADMIN, FALSE))
				initiate_vote("restart", usr.key)
		if("gamemode")
			if(CONFIG_GET(flag/allow_vote_mode) || check_other_rights(usr.client, R_ADMIN, FALSE))
				initiate_vote("gamemode", usr.key)
		if("custom")
			if(check_other_rights(usr.client, R_ADMIN, FALSE))
				initiate_vote("custom", usr.key)
		if("map")
			if(check_other_rights(usr.client, R_ADMIN, FALSE))
				initiate_vote("map", usr.key)
		else
			submit_vote(round(text2num(href_list["vote"])))
	usr.vote()


/mob/verb/vote()
	set category = "OOC"
	set name = "Vote"

	var/datum/browser/popup = new(src, "vote", "Voting Panel")
	popup.set_window_options("can_close=0")
	popup.set_content(SSvote.interface(client))
	popup.open(FALSE)