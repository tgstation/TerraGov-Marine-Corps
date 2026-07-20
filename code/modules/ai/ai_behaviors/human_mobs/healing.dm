#define UNREVIVABLE_GENERIC \
	"Damn it, %AFFECTED_FIRST_NAME% is cold!",\
	"%A_AFFECTED_THEYRE% not coming back.",\
	"Goodnight, %AFFECTED_FIRST_NAME%.",\
	"%AFFECTED_FIRST_NAME%'s gone.",\
	"Ah... %AFFECTED_FIRST_NAME%.",\
	"%A_AFFECTED_THEYRE% dead.",\
	"We lost %AFFECTED_THEM%!",\
	"I'm sorry."

#define MOVE_TO_HEAL_GENERIC \
	"%AFFECTED_FIRST_NAME%, I have something for you!",\
	"%SELF_FIRST_NAME% on the way!",\
	"Hang in there, I'm coming!",\
	"Hold on, I'm coming!",\
	"I'm on the way!"

/datum/ai_behavior/human
	///A list of mobs that might need healing
	var/list/heal_list = list()
	/// Lines when healing self and in need of a medic
	var/list/self_heal_lines = list(
		FACTION_NEUTRAL = list(
			"I'm fixing myself up here, help!",
			"No pain, no gain...",
			"Healing over here!",
			"Cover me, man!",
			"I need help!",
		),
		FACTION_TERRAGOV = list(
			"I'm fixin' myself here, CORPSMAN!!",
			"CORPSMAN! OVER HERE!!",
			"I NEED A CORPSMAN!!",
			"CORPSMAN UP!!",
			"CORPSMAN!!",
			"Would you please cover me?!",
		),
	)
	/// Lines when unable to revive someone else
	var/list/unrevivable_lines = list(
		FACTION_NEUTRAL = list(
			UNREVIVABLE_GENERIC,
		),
		FACTION_TERRAGOV = list(
			"Goodnight, %AFFECTED_LAST_NAME%.",
			"We lost %AFFECTED_LAST_NAME%.",
			"%AFFECTED_LAST_NAME% is cold.",
			UNREVIVABLE_GENERIC,
		),
	)
	/// Lines when moving to help someone up who's in crit
	var/list/move_to_crit_lines = list(
		FACTION_NEUTRAL = list(
			"Cover me, I'm helping %AFFECTED_FIRST_NAME% up!",
			"Cover me while I get %AFFECTED_FIRST_NAME%!",
			"Someone help %AFFECTED_FIRST_NAME% up!",
			"Shit, %AFFECTED_FIRST_NAME% is down!",
			"Getting %AFFECTED_FIRST_NAME% up!",
			"%AFFECTED_FIRST_NAME% needs help!",
			"%AFFECTED_FIRST_NAME% is down!",
			"%AFFECTED_FIRST_NAME%!",
		),
		FACTION_TERRAGOV = list(
			"Cover me, I'm helping %AFFECTED_LAST_NAME% up!",
			"Cover me while I get %AFFECTED_LAST_NAME%!",
			"Someone help %AFFECTED_LAST_NAME% up!",
			"Shit, %AFFECTED_LAST_NAME% is down!",
			"Getting %AFFECTED_LAST_NAME% up!",
			"%AFFECTED_LAST_NAME% needs help!",
			"%AFFECTED_LAST_NAME% is down!",
			"%AFFECTED_LAST_NAME%!",
		)
	)
	/// Lines when moving to heal someone else
	var/list/move_to_heal_lines = list(
		FACTION_NEUTRAL = list(
			MOVE_TO_HEAL_GENERIC,
		),
		FACTION_TERRAGOV = list(
			"%AFFECTED_TITLE%, I have something for you!",
			"I hear you, %AFFECTED_TITLE%!",
			"Wait up, %AFFECTED_TITLE%!",
			"Corpsman on the way!",
			"%AFFECTED_TITLE%!",
		),
	)
	/// Lines when actively healing someone else
	var/list/healing_lines = list(
		FACTION_NEUTRAL = list(
			"Don't stop shooting, I'll heal you!",
			"Wait up, I have something for you!",
			"Healing you, don't stop shooting!",
			"Hold on, I'm gonna fix you up!",
		),
	)

/datum/ai_behavior/human/late_initialize()
	if(should_hold())
		return
	return ..()

///Checks if we should be healing somebody
/datum/ai_behavior/human/proc/medic_process()
	if(!length(heal_list))
		return
	if(ishuman(interact_target) && (interact_target in heal_list)) //already trying to heal someone
		return
	if(human_ai_state_flags & HUMAN_AI_FIRING)
		return
	if(current_action == MOVING_TO_SAFETY)
		return
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return

	var/mob/living/carbon/human/patient
	var/patient_dist = 10 //lets just check screen range, more or less
	for(var/mob/living/carbon/human/potential AS in heal_list)
		var/dist = get_dist(mob_parent, potential)
		if(dist >= patient_dist)
			continue
		patient = potential
		patient_dist = dist
	if(!patient)
		return

	set_interact_target(patient)
	faction_list_speak(move_to_heal_lines, talking_with = patient)
	return TRUE

///Someone is healing us
/datum/ai_behavior/human/proc/parent_being_healed(mob/living/source, mob/living/carbon/human/healer) //add player healing sig? only AI healing currently
	SIGNAL_HANDLER
	human_ai_state_flags |= HUMAN_AI_HEALING
	RegisterSignals(healer, list(COMSIG_MOB_STAT_CHANGED, COMSIG_MOVABLE_MOVED, COMSIG_AI_HEALING_FINISHED), PROC_REF(on_heal_end)) //DOC IS NOT SET AS A TARGET, SO THIS MAY FAIL IF THEY JUST GET GIBBED OR SOMETHING

///Our healing ended, successfully or otherwise
/datum/ai_behavior/human/proc/on_heal_end(mob/living/carbon/human/healer)
	SIGNAL_HANDLER
	UnregisterSignal(healer, list(COMSIG_MOB_STAT_CHANGED, COMSIG_MOVABLE_MOVED, COMSIG_AI_HEALING_FINISHED))
	human_ai_state_flags &= ~HUMAN_AI_HEALING
	late_initialize()

///Decides if we should do something when another mob goes crit
/datum/ai_behavior/human/proc/on_other_mob_crit(datum/source, mob/living/carbon/crit_mob)
	SIGNAL_HANDLER
	if(crit_mob.faction != mob_parent.faction)
		return
	if(crit_mob.z != mob_parent.z)
		return
	if(crit_mob == mob_parent)
		return
	if(medical_rating >= AI_MED_MEDIC)
		add_to_heal_list(crit_mob)
	if(get_dist(mob_parent, crit_mob) > 5)
		return
	set_interact_target(crit_mob)
	if(prob(33))
		faction_list_speak(move_to_crit_lines, talking_with = crit_mob)
	RegisterSignal(crit_mob, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_interactee_stat_change))

///Unregisters a friendly target when their stat changes
/datum/ai_behavior/human/proc/on_interactee_stat_change(mob/living/carbon/source, current_stat, new_stat) //this is only for crit heal currently
	SIGNAL_HANDLER
	if(new_stat == current_stat)
		return
	if((medical_rating < AI_MED_MEDIC))
		unset_target(source) //only medics will still try heal
	UnregisterSignal(source, COMSIG_MOB_STAT_CHANGED)

///Checks if a hurt AI human needs healing
/datum/ai_behavior/human/proc/mob_need_heal(datum/source, mob/living/carbon/human/patient)
	SIGNAL_HANDLER
	if(patient.faction != mob_parent.faction)
		return
	if(patient.z != mob_parent.z)
		return
	if(patient == mob_parent)
		return

	add_to_heal_list(patient)
	//if we're too far away, or busy with other stuff, we don't immediately help
	if(get_dist(mob_parent, patient) > 7)
		return
	if(human_ai_state_flags & HUMAN_AI_FIRING)
		return
	if(current_action == MOVING_TO_SAFETY)
		return
	if(human_ai_state_flags & HUMAN_AI_BUSY_ACTION)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return
	set_interact_target(patient)
	faction_list_speak(move_to_heal_lines, talking_with = patient)

///Adds mob to list
/datum/ai_behavior/human/proc/add_to_heal_list(mob/living/carbon/human/patient)
	if(patient in heal_list)
		return
	heal_list += patient
	RegisterSignal(patient, COMSIG_AI_HEALING_MOB, PROC_REF(unset_target))

///Removes mob from list
/datum/ai_behavior/human/proc/remove_from_heal_list(mob/living/carbon/human/old_patient)
	UnregisterSignal(old_patient, COMSIG_AI_HEALING_MOB)
	heal_list -= old_patient

///Tries healing themselves
/datum/ai_behavior/human/proc/try_heal()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_NEED_HEAL, mob_parent)

	var/turf/owner_turf = get_turf(mob_parent)
	if((mob_parent.is_on_fire() || mob_parent.has_status_effect(STATUS_EFFECT_INTOXICATED)) && can_cross_lava_turf(owner_turf) && check_hazards())
		mob_parent.do_resist()
		return

	if(!COOLDOWN_FINISHED(src, ai_heal_after_dam_cooldown))
		return

	if(prob(75))
		faction_list_speak(self_heal_lines)

	human_ai_state_flags |= HUMAN_AI_SELF_HEALING

	heal_loop(mob_parent)

	human_ai_state_flags &= ~HUMAN_AI_SELF_HEALING
	late_initialize()

///Tries to heal another mob
/datum/ai_behavior/human/proc/try_heal_other(mob/living/carbon/human/patient)
	if(patient.InCritical()) //crit heal is always priority
		heal_by_type(patient, OXY)

	if(medical_rating < AI_MED_MEDIC)
		return

	do_unset_target(patient, FALSE)
	if(HAS_TRAIT(patient, TRAIT_UNDEFIBBABLE))
		faction_list_speak(unrevivable_lines, talking_with = patient)
		return

	if(!mob_parent.CanReach(patient))
		return

	faction_list_speak(healing_lines, talking_with = patient)
	human_ai_state_flags |= HUMAN_AI_HEALING

	if(patient.stat == DEAD) //we specifically don't want the sig sent out if we fail to defib
		if(!attempt_revive(patient))
			on_heal_end(mob_parent)
			return

	SEND_SIGNAL(patient, COMSIG_AI_HEALING_MOB, mob_parent)
	RegisterSignal(patient, COMSIG_MOVABLE_MOVED, PROC_REF(do_unset_target))

	var/did_heal = heal_loop(patient)

	if(!did_heal || prob(30)) //heal interupted or nothing left to heal, or to stop overload
		do_unset_target(patient)
	UnregisterSignal(patient, COMSIG_MOVABLE_MOVED)
	on_heal_end(mob_parent)
	SEND_SIGNAL(mob_parent, COMSIG_AI_HEALING_FINISHED)

#undef UNREVIVABLE_GENERIC
#undef MOVE_TO_HEAL_GENERIC
