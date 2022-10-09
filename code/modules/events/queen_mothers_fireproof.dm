/datum/round_event_control/queen_mothers_fireproof
	name = "Queen Mother's Fireproofing"
	typepath = /datum/round_event/queen_mothers_fireproof
	weight = 5
	earliest_start = 60 MINUTES
	max_occurrences = 2

	gamemode_blacklist = list("Combat Patrol","Civil War")

/datum/round_event_control/queen_mothers_fireproof/can_spawn_event(players_amt, gamemode)
	if(length(GLOB.alive_xeno_list) <= 8)
		return FALSE
	return ..()

/datum/round_event/queen_mothers_fireproof/start()
	xeno_message("The Queen Mother has temporarily reinforced our armor with fireproof coating, strike before it wears off!")
	priority_announce("Sensors have detected a malevolent psychic force hovering over the battlefield, surely this doesn't bode well for us...")
	for(var/mob/living/carbon/xenomorph/X in (GLOB.alive_xeno_list))
		if(isminion(X))
			continue
		fireproof_xeno(X)

/datum/round_event/queen_mothers_fireproof/proc/fireproof_xeno(mob/living/carbon/xenomorph/X)
	X.apply_status_effect(STATUS_EFFECT_RESIN_JELLY_COATING)
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS)
	for(var/mob/living/carbon/xenomorph/T in (GLOB.alive_xeno_list))
		SEND_SOUND(T, queen_sound)
