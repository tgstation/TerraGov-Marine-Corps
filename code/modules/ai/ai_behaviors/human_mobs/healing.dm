/datum/ai_behavior/human
	///A list of mobs that might need healing
	var/list/heal_list = list()
	///Chat lines for trying to heal
	var/list/healing_chat = list("Healing you.", "Healing you, hold still.", "Stop moving!", "Fixing you up.", "Healing.", "Treating wounds.", "I'll have you patched up in no time.", "Quit your complaining, it's just a fleshwound.", "Cover me!", "Give me some room!")
	///Chat lines for trying to heal
	var/list/self_heal_chat = list("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!.")
	///Chat lines for someone being perma
	var/list/unrevivable_chat = list("We lost them!", "I lost them!", "Damn it, they're gone!", "Perma!", "No longer revivable.", "I can't help this one.", "I'm sorry.")
	///Chat lines for getting a new heal target
	var/list/move_to_heal_chat = list("Hold on, I'm coming!", "Cover me, I'm moving!", "Moving to assist!", "I'm gonna fix you up.", "They need help!", "Cover me!", "Getting them up.", "Quit your complaining, it's just a fleshwound.", "On the move!", "Helping out here.")

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
	try_speak(pick(move_to_heal_chat))
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
	try_speak(pick(move_to_heal_chat))
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
	try_speak(pick(move_to_heal_chat))

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
	var/mob/living/living_parent = mob_parent
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_NEED_HEAL, mob_parent)

	var/turf/owner_turf = get_turf(mob_parent)
	if((living_parent.is_on_fire() || living_parent.has_status_effect(STATUS_EFFECT_INTOXICATED)) && can_cross_lava_turf(owner_turf) && check_hazards())
		living_parent.do_resist()
		return

	if(!COOLDOWN_FINISHED(src, ai_heal_after_dam_cooldown))
		return

	if(prob(75))
		try_speak(pick(self_heal_chat))

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
		remove_from_heal_list(patient)
		try_speak(pick(unrevivable_chat))
		return

	if(!mob_parent.CanReach(patient))
		return

	try_speak(pick(healing_chat))
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
