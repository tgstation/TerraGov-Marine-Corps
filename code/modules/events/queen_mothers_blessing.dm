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
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	for(var/mob/living/carbon/xenomorph/target_xeno in shuffle(GLOB.alive_xeno_list))
		if(isxenolarva(target_xeno) || isminion(target_xeno))
			continue
		for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list)
			SEND_SOUND(receiving_xeno, queen_sound)
		bless_xeno(target_xeno)
		return

/datum/round_event/queen_mothers_blessing/proc/bless_xeno(mob/living/carbon/xenomorph/target_xeno)
	target_xeno.evolution_stored = target_xeno.xeno_caste.evolution_threshold
	if(target_xeno.tier != XENO_UPGRADE_FOUR || XENO_UPGRADE_THREE)
		target_xeno.upgrade_xeno(XENO_UPGRADE_THREE)
	target_xeno.adjustBruteLoss(-QM_HEAL_AMOUNT)
	target_xeno.adjustFireLoss(-QM_HEAL_AMOUNT, updating_health = TRUE)
	target_xeno.adjust_sunder(-QM_HEAL_AMOUNT/20)
	xeno_message("The Queen Mother has blessed [target_xeno], may they do great things for the hive.")

#undef QM_HEAL_AMOUNT
