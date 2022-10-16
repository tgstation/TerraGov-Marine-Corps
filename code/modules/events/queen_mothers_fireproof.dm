/datum/round_event_control/queen_mothers_fireproof
	name = "Queen Mother's Fireproofing"
	typepath = /datum/round_event/queen_mothers_fireproof
	weight = 5
	earliest_start = 60 MINUTES
	max_occurrences = 2

	gamemode_blacklist = list("Combat Patrol","Civil War","Sensor Capture")

/datum/round_event_control/queen_mothers_fireproof/can_spawn_event(players_amt, gamemode)
	if(length(GLOB.alive_xeno_list) <= 8)
		return FALSE
	return ..()

/datum/round_event/queen_mothers_fireproof/start()
	xeno_message("The Queen Mother has temporarily reinforced our armor with fireproof coating, strike before it wears off!")
	for(var/mob/living/carbon/xenomorph/fireproofed_xeno in GLOB.alive_xeno_list)
		if(isminion(fireproofed_xeno))
			continue
		fireproof_xeno(fireproofed_xeno)

/datum/round_event/queen_mothers_fireproof/proc/fireproof_xeno(mob/living/carbon/xenomorph/fireproofed_xeno)
	fireproofed_xeno.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	SEND_SOUND(fireproofed_xeno, queen_sound)
