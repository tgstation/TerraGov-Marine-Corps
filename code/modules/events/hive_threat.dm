//A human groundside is identified as a threat to the hive, and the hive is rewarded for draining this target
/datum/round_event_control/hive_threat
	name = "Hive threat"
	typepath = /datum/round_event/hive_threat
	weight = 10
	earliest_start = 30 MINUTES

	gamemode_blacklist = list("Crash", "Combat Patrol", "Sensor Capture", "Campaign", "Zombie Crash")

	///The human target for the next instance of this event
	var/mob/living/carbon/human/hive_target

/datum/round_event_control/hive_threat/can_spawn_event(players_amt, gamemode, force = FALSE)
	. = ..()
	if(!.)
		return
	if(hive_target?.client?.prefs?.be_special & BE_HIVE_TARGET)
		return TRUE
	var/list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND))
	var/list/eligible_targets = list()
	for(var/z in z_levels)
		for(var/mob/living/carbon/human/possible_target in GLOB.humans_by_zlevel["[z]"])
			if(!istype(possible_target) || !possible_target.client)
				continue
			if(!(possible_target.client?.prefs?.be_special & BE_HIVE_TARGET))
				continue
			eligible_targets += possible_target
	if(!length(eligible_targets))
		hive_target = null
		return FALSE //everyone is dead or evac'd
	hive_target = pick(eligible_targets)
	return TRUE

/datum/round_event/hive_threat
	///The human target for this event
	var/mob/living/carbon/human/hive_target

/datum/round_event/hive_threat/start()
	var/datum/round_event_control/hive_threat/hive_control = control
	if(!istype(hive_control))
		hive_control = new
	if(!(hive_target?.client?.prefs?.be_special & BE_HIVE_TARGET))
		if(!hive_control.can_spawn_event(force = TRUE))
			qdel(src)
			return
	set_target(hive_control.hive_target)
	hive_control.hive_target = null

///sets the target for this event, and notifies the hive
/datum/round_event/hive_threat/proc/set_target(mob/living/carbon/human/target)
	hive_target = target
	ADD_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target.med_hud_set_status()
	hive_target.log_message("was marked as a hive target.", LOG_GAME)
	RegisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED, PROC_REF(handle_reward))
	for(var/hivenumber in GLOB.hive_datums)
		var/message = "You sense that [hive_target] is a valuable target for breeding. Fuck or psydrain them for a blessing for your hive!"
		if(hivenumber == XENO_HIVE_NORMAL)
			message = "The Queen Mother senses that [hive_target] is the breeding target of the hive. Fuck or psydrain them for the Queen Mother's blessing!"
		GLOB.hive_datums[hivenumber].xeno_message(message, force=TRUE, target = hive_target, sound = get_sfx(SFX_QUEEN), arrow_color = "ff00b0", report_distance = TRUE)

//manages the hive reward and clean up
/datum/round_event/hive_threat/proc/handle_reward(datum/source, mob/living/carbon/xenomorph/drainer, mob/living/drained)
	SIGNAL_HANDLER
	if(drained != hive_target)
		return
	var/message = "[drainer] has gleaned the secrets from the mind of [hive_target], helping ensure the future of the hive. Our hive is empowered by our success!"
	if(drainer.get_xeno_hivenumber() == XENO_HIVE_NORMAL)
		message = "[drainer] has gleaned the secrets from the mind of [hive_target], helping ensure the future of the hive. The Queen Mother empowers us for our success!"
	drainer.get_hive().xeno_message(message, force = TRUE)
	log_combat(drainer, drained, "obtained a hive target reward from")
	bless_hive(drainer)
	REMOVE_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target.med_hud_set_status()
	hive_target = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED)

///Actually applies the buff to the hive
/datum/round_event/hive_threat/proc/bless_hive(mob/living/carbon/xenomorph/drainer)
	for(var/mob/living/carbon/xenomorph/receiving_xeno AS in GLOB.alive_xeno_list_hive[drainer.get_xeno_hivenumber()])
		receiving_xeno.add_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE, TRUE, 0, NONE, TRUE, -0.2)
		receiving_xeno.gain_plasma(receiving_xeno.xeno_caste.plasma_max)
		receiving_xeno.salve_healing()
		if(receiving_xeno == drainer)
			receiving_xeno.evolution_stored = receiving_xeno.xeno_caste.evolution_threshold
			receiving_xeno.upgrade_stored += 1000
		SEND_SOUND(receiving_xeno, sound(get_sfx(SFX_QUEEN), channel = CHANNEL_ANNOUNCEMENTS, volume = 50))
	addtimer(CALLBACK(src, PROC_REF(remove_blessing), drainer.get_hive()), 2 MINUTES)

///debuffs the hive when the blessing expires
/datum/round_event/hive_threat/proc/remove_blessing(datum/hive_status/hive)
	var/message = "We feel the hive target blessing fade"
	if(hive.hivenumber == XENO_HIVE_NORMAL)
		message = "We feel the Queen Mother's blessing fade"
	hive.xeno_message(message, force = TRUE)
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list_hive[hive.hivenumber])
		receiving_xeno.remove_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE)
	qdel(src)

/datum/round_event/hive_threat/Destroy(force, ...)
	. = ..()
	if(hive_target)
		REMOVE_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
		hive_target.med_hud_set_status()
		hive_target = null

