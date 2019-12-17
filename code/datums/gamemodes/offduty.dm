/datum/game_mode/offduty
	name = "Off-Duty"
	config_tag = "Off-Duty"
	required_players = 0
	votable = FALSE


/datum/game_mode/offduty/announce()
	to_chat(world, "<b>The current game mode is - Off-Duty!</b>")
	to_chat(world, "<b>Just have fun and role-play! Don't do harm to your fellow comrades!</b>")

/datum/game_mode/offduty/proc/announce_deployment(announce_humans = TRUE)
	var/name = "[MAIN_AI_SYSTEM] Signal Decrypted"
	var/input = {"A TGMC distress signal has been decrypted in an unknown location.<br><br>Prepare for deployment and briefing."}

	if(announce_humans)
		priority_announce(input, name, sound = 'sound/AI/bioscan.ogg')

/datum/game_mode/offduty/proc/post_setup()
	var/message = ""
	addtimer(CALLBACK(src, .proc/announce_deployment, message, ""), 290 SECONDS)
	addtimer(CALLBACK(src, .proc/display_roundstart_logout_report), ROUNDSTART_LOGOUT_REPORT_TIME)
	if(!SSdbcore.Connect())
		return
	var/sql
	if(SSticker.mode)
		sql += "game_mode = '[SSticker.mode]'"
	if(GLOB.revdata.originmastercommit)
		if(sql)
			sql += ", "
		sql += "commit_hash = '[GLOB.revdata.originmaste	rcommit]'"
	if(sql)
		var/datum/DBQuery/query_round_game_mode = SSdbcore.NewQuery("UPDATE [format_table_name("round")] SET [sql] WHERE id = [GLOB.round_id]")
		query_round_game_mode.Execute()
		qdel(query_round_game_mode)
		addtimer(CALLBACK(./proc/declare_completion), 300 SECONDS)

/datum/game_mode/offduty/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE

/datum/game_mode/offduty/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>|Round Complete|</span>")
	to_chat(world, "<span class='round_body'>Thus ends the story of the men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their day-off on [SSmapping.configs[GROUND_MAP].map_name].</span>")
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()
