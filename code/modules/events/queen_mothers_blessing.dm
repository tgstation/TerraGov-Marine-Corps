#define QM_HEAL_AMOUNT 250

/datum/round_event_control/queen_mothers_blessing
	name = "Queen Mother's Blessing"
	typepath = /datum/round_event/queen_mothers_blessing
	weight = 15
	earliest_start = 10 MINUTES

	gamemode_blacklist = list("Combat Patrol","Civil War","Sensor Capture")

/datum/round_event_control/queen_mothers_blessing/can_spawn_event(players_amt, gamemode)
	if(length(GLOB.alive_xeno_list) <= 4)
		return FALSE
	return ..()

/datum/round_event/queen_mothers_blessing/start()
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS)
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list)
		SEND_SOUND(receiving_xeno, queen_sound)
	for(var/mob/living/carbon/xenomorph/X in shuffle(GLOB.alive_xeno_list))
		if(isxenolarva(X))
			continue
		else if(isminion(X))
			continue
		bless_xeno(X)
		break

/datum/round_event/queen_mothers_blessing/proc/bless_xeno(mob/living/carbon/xenomorph/X)
	X.evolution_stored = X.xeno_caste.evolution_threshold
	if(X.tier != XENO_UPGRADE_FOUR) //larva do not have proper caste datums, trying to force one results in a runtime
		X.upgrade_xeno(XENO_UPGRADE_THREE)
	X.adjustBruteLoss(-QM_HEAL_AMOUNT)
	X.adjustFireLoss(-QM_HEAL_AMOUNT, updating_health = TRUE)
	X.adjust_sunder(-QM_HEAL_AMOUNT/20)
	xeno_message("The Queen Mother has blessed [X], may they do great things for the hive.")

#undef QM_HEAL_AMOUNT
