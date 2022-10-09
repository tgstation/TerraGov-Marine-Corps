/datum/round_event_control/queen_mothers_plasma_boost
	name = "Queen Mother's Plasma Boost"
	typepath = /datum/round_event/queen_mothers_plasma_boost
	weight = 7
	earliest_start = 45 MINUTES
	max_occurrences = 2

	gamemode_blacklist = list("Combat Patrol","Civil War")

/datum/round_event_control/queen_mothers_plasma_boost/can_spawn_event(players_amt, gamemode)
	if(length(GLOB.alive_xeno_list) <= 8)
		return FALSE
	return ..()

/datum/round_event/queen_mothers_plasma_boost/start()
	xeno_message("The Queen Mother has refilled the empty plasma stores of our hive. She expects great things, do not fail her.")
	priority_announce("Sensors have detected a malevolent psychic force hovering over the battlefield, surely this doesn't bode well for us...")
	for(var/mob/living/carbon/xenomorph/X in (GLOB.alive_xeno_list))
		if(isminion(X))
			continue
		if(!(X.xeno_caste.can_flags & CASTE_CAN_BE_GIVEN_PLASMA))
			continue
		plasma_boost_xeno(X)

/datum/round_event/queen_mothers_plasma_boost/proc/plasma_boost_xeno(mob/living/carbon/xenomorph/X)
	X.add_filter("transfer_plasma_outline", 3, outline_filter(1, COLOR_STRONG_MAGENTA))
	addtimer(CALLBACK(X, /atom.proc/remove_filter, "transfer_plasma_outline"), 7 SECONDS) //Failsafe blur removal
	X.plasma_stored = X.xeno_caste.plasma_max
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS)
	for(var/mob/living/carbon/xenomorph/T in (GLOB.alive_xeno_list))
		SEND_SOUND(T, queen_sound)
