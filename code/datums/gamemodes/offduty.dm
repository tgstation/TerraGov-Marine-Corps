/datum/game_mode/offduty
	name = "Off-Duty"
	config_tag = "Off-Duty"
	required_players = 0
	votable = FALSE
	var/operation_start_timer

/datum/game_mode/offduty/announce()
	to_chat(world, "<b>The current game mode is - Off-Duty!</b>")
	to_chat(world, "<b>Just have fun and role-play! Don't do harm to your fellow comrades!</b>")

/datum/game_mode/offduty/post_setup()
	. = ..()
	addtimer(CALLBACK(.proc/start_round_end), 10 SECONDS)

	if(!operation_start_timer)
		return TRUE

/datum/game_mode/offduty/check_finished()
	var/round_end_stage = 0

	if(round_end_stage == 2)
		return TRUE
	return FALSE

	if(world.time < (SSticker.round_start_time + 5 SECONDS))
		return FALSE

/datum/game_mode/offduty/process()
	if(round_finished)
		return FALSE

/datum/game_mode/offduty/declare_completion()
	. = ..()
	to_chat(world, span_round_header("|Round Complete|"))
	to_chat(world, span_round_body("Thus ends the story of the men and women of the [SSmapping.configs[SHIP_MAP].map_name] and their day-off on [SSmapping.configs[GROUND_MAP].map_name]."))
	var/sound/S = sound(pick('sound/theme/neutral_hopeful1.ogg','sound/theme/neutral_hopeful2.ogg'), channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)

	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal xenos spawned: [GLOB.round_statistics.total_xenos_created]\nTotal humans spawned: [GLOB.round_statistics.total_humans_created]")

	announce_medal_awards()
	announce_round_stats()

/datum/game_mode/offduty/proc/start_round_end()
	check_finished(TRUE)
	var/datum/game_mode/offduty/check_finished/round_end_stage = 1

/datum/game_mode/offduty/proc/get_operation_start_countdown()
	if(!operation_start_timer)
		return
	var/eta = timeleft(operation_start_timer) * 0.1
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_zero(num2text(eta % 60), 2)]"
/* Sigh, this part isn't working. - XSlayer300
/datum/game_mode/offduty/proc/announce_deployment(announce_humans = TRUE)
	var/name = "[MAIN_AI_SYSTEM] Signal Decrypted"
	var/input = {"A TGMC distress signal has been decrypted in an unknown location.<br><br>Prepare for deployment and briefing."}

	if(var/round_end_stage == 2)
		priority_announce(input, name, sound = 'sound/AI/bioscan.ogg')*/
