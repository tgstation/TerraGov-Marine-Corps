//A human groundside is identified as a threat to the hive, and the hive is rewarded for draining this target
/datum/round_event_control/hive_threat
	name = "Hive target"
	typepath = /datum/round_event/hive_threat
	weight = 15
	earliest_start = 10 MINUTES

	gamemode_blacklist = list("Combat Patrol","Civil War","Sensor Capture")

/datum/round_event_control/hive_threat/can_spawn_event(players_amt, gamemode)
	for(var/mob/living/carbon/human/human in GLOB.alive_human_list)
		if(HAS_TRAIT(human, TRAIT_HIVE_TARGET))
			return FALSE //only one target at a time. Although maybe this isn't needed.
	return ..()

/datum/round_event/hive_threat
	///The human target for this event
	var/mob/living/carbon/human/hive_target

/datum/round_event/hive_threat/start()
	var/list/z_levels = SSmapping.levels_by_any_trait(list(ZTRAIT_GROUND))
	var/list/eligible_targets
	for(var/z in z_levels)
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/possible_target = i
			if(!istype(possible_target) || !possible_target.client)
				continue
			eligible_targets += possible_target
	if(!length(eligible_targets))
		return //everyone is dead or evac'd
	set_target(pick(eligible_targets))

///sets the target for this event, and notifies the hive
/datum/round_event/hive_threat/proc/set_target(mob/living/carbon/human/target)
	hive_target = target
	ADD_TRAIT(target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	//probs add some xenohud overlay to the target so we can keep track of the nerd
	RegisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED, .proc/bless_hive)
	var/sound/queen_sound = sound(get_sfx("queen"), channel = CHANNEL_ANNOUNCEMENTS, volume = 50)
	xeno_message("The Queen Mother senses that [target] is a deadly threat to the hive. Psydrain them for the Queen Mother's blessing!")
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list)
		SEND_SOUND(receiving_xeno, queen_sound)

///buffs the hive when the target has been drained
/datum/round_event/hive_threat/proc/bless_hive(datum/source, mob/living/carbon/human/target)
	SIGNAL_HANDLER
	xeno_message("The Queen Mother has gleaned the secrets from the mind of [target], helping ensure the future of the hive. The Queen Mother empowers us for our success.")
	//better than the below, would to grant the hive leadership access to a one use ability to trigger the below on demand. I laz tho.
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list)
		receiving_xeno.add_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE, TRUE, 0, NONE, TRUE, 0.18) //placeholder buff. gotta go fast.
	addtimer(CALLBACK(src, .proc/remove_blessing), 2 MINUTES)
	REMOVE_TRAIT(hive_target, TRAIT_HIVE_TARGET, TRAIT_HIVE_TARGET)
	hive_target = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_HIVE_TARGET_DRAINED)

///debuffs the hive when the blessing expires
/datum/round_event/hive_threat/proc/remove_blessing()
	for(var/mob/living/carbon/xenomorph/receiving_xeno in GLOB.alive_xeno_list)
		receiving_xeno.remove_movespeed_modifier(MOVESPEED_ID_BLESSED_HIVE)
