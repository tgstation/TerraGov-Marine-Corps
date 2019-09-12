/datum/game_mode/extended
	name = "Ball"
	config_tag = "Ball"
	required_players = 0
	votable = FALSE


/datum/game_mode/extended/announce()
	to_chat(world, "<span class='round_header'>The Ball is officially starting!</span>")
	to_chat(world, "<span class='round_body'>Remember to have fun and follow the rules!</span>")


/datum/game_mode/extended/check_finished()
	if(!round_finished)
		return FALSE
	return TRUE


/datum/game_mode/extended/declare_completion()
	. = ..()
	to_chat(world, "<span class='round_header'>Thank you for attending the TGMC Ball!</span>")
	to_chat(world, "<span class='round_body'>We hope you had as much fun as we did, who knows, we may do it again in the future!</span>")
	
	var/sound/S = sound('sound/music/StillAlive.ogg', channel = CHANNEL_CINEMATIC)
	SEND_SOUND(world, S)
