//A human groundside is identified as a threat to the hive, and the hive is rewarded for draining this target
/datum/round_event_control/hive_threat
	name = "Hive threat"
	typepath = /datum/round_event/hive_threat
	weight = 10
	earliest_start = 30 MINUTES

	gamemode_blacklist = list("Crash", "Combat Patrol", "Sensor Capture", "Campaign")

/datum/round_event/hive_threat
	///The human target for this event
	var/mob/living/carbon/human/hive_target

/datum/round_event/hive_threat/start()
	var/list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND))
	var/list/eligible_targets = list()
	for(var/z in z_levels)
		for(var/mob/living/carbon/human/possible_target in GLOB.humans_by_zlevel["[z]"])
			if(!possible_target.client || issynth(possible_target) || possible_target.faction == FACTION_NEUTRAL)
				continue
			eligible_targets += possible_target
	if(!length(eligible_targets))
		return //everyone is dead or evac'd
	set_target(pick(eligible_targets))

///sets the target for this event, and notifies the hive
/datum/round_event/hive_threat/proc/set_target(mob/living/carbon/human/target)
	hive_target = target
	ADD_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target.med_hud_set_status()
	RegisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED, PROC_REF(handle_reward))
	xeno_message("The Queen Mother senses that [hive_target] is a deadly threat to the hive. Psydrain them for the Queen Mother's blessing!", force = TRUE)
	for(var/mob/living/carbon/xenomorph/xeno_sound_reciever in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		SEND_SOUND(xeno_sound_reciever, sound(get_sfx(SFX_QUEEN), channel = CHANNEL_ANNOUNCEMENTS, volume = 50))

//manages the hive reward and clean up
/datum/round_event/hive_threat/proc/handle_reward(datum/source, mob/living/carbon/xenomorph/drainer)
	SIGNAL_HANDLER
	xeno_message("[drainer] has gleaned the secrets from the mind of [hive_target], helping ensure the future of the hive. The Queen Mother empowers us for our success!", force = TRUE)
	bless_hive(drainer)
	REMOVE_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target.med_hud_set_status()
	hive_target = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED)

///Actually applies the buff to the hive
/datum/round_event/hive_threat/proc/bless_hive(mob/living/carbon/xenomorph/drainer)
	for(var/mob/living/carbon/xenomorph/receiving_xeno AS in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		receiving_xeno.add_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE, TRUE, 0, NONE, TRUE, -0.2)
		receiving_xeno.gain_plasma(receiving_xeno.xeno_caste.plasma_max)
		receiving_xeno.salve_healing()
		if(receiving_xeno == drainer)
			receiving_xeno.evolution_stored = receiving_xeno.xeno_caste.evolution_threshold
			receiving_xeno.upgrade_stored += 1000
	for(var/mob/living/carbon/xenomorph/xeno_sound_reciever in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		SEND_SOUND(xeno_sound_reciever, sound(get_sfx(SFX_QUEEN), channel = CHANNEL_ANNOUNCEMENTS, volume = 50))
	addtimer(CALLBACK(src, PROC_REF(remove_blessing)), 2 MINUTES)

///debuffs the hive when the blessing expires
/datum/round_event/hive_threat/proc/remove_blessing()
	xeno_message("We feel the Queen Mother's blessing fade", force = TRUE)
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list_hive[XENO_HIVE_NORMAL])
		receiving_xeno.remove_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE)
