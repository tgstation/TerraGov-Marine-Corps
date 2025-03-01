//todo: add a mobs to help list so we can record who needs help, even if we're too busy to help right now
/datum/ai_behavior/human
	var/list/heal_list = list()
	///Chat lines for trying to heal
	var/list/healing_chat = list("healing other mob.")
	//var/list/healing_chat = list("Healing, cover me!", "Healing over here.", "Where's the damn medic?", "Medic!", "Treating wounds.", "It's just a flesh wound.", "Need a little help here!", "Cover me!.")

/datum/ai_behavior/human/late_initialize()
	if(human_ai_state_flags & HUMAN_AI_HEALING)
		return
	. = ..()
	if(!registered_for_move)
		scheduled_move()

/datum/ai_behavior/human/proc/medic_process()
	if(!length(heal_list))
		return
	if(ishuman(interact_target) && (interact_target in heal_list)) //already trying to heal someone
		return
	if(human_ai_state_flags & HUMAN_AI_FIRING)
		return
	if(current_action == MOVING_TO_SAFETY)
		return
	if(human_ai_state_flags & HUMAN_AI_HEALING)
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
	return TRUE

///Someone is healing us
/datum/ai_behavior/human/proc/parent_being_healed(mob/living/source, mob/living/carbon/human/healer) //add player healing sig? only AI healing currently
	SIGNAL_HANDLER
	human_ai_state_flags |= HUMAN_AI_HEALING
	RegisterSignals(healer, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOB_STAT_CHANGED, COMSIG_MOVABLE_MOVED, COMSIG_AI_HEALING_FINISHED), PROC_REF(on_heal_end))

///Healing ended, successfully or otherwise
/datum/ai_behavior/human/proc/on_heal_end(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_MOB_STAT_CHANGED, COMSIG_MOVABLE_MOVED, COMSIG_AI_HEALING_FINISHED))
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
	RegisterSignal(crit_mob, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_interactee_stat_change))

///Unregisters a friendly target when their stat changes
/datum/ai_behavior/human/proc/on_interactee_stat_change(mob/living/carbon/source, current_stat, new_stat) //this is only for crit heal currently
	SIGNAL_HANDLER
	if(new_stat == current_stat)
		return
	if((medical_rating < AI_MED_MEDIC) || (new_stat == DEAD)) //todo: change when adding defib
		unset_target(source)
	UnregisterSignal(source, COMSIG_MOB_STAT_CHANGED)

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
	if(human_ai_state_flags & HUMAN_AI_HEALING)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return
	set_interact_target(patient)

/datum/ai_behavior/human/proc/add_to_heal_list(mob/living/carbon/human/patient)
	if(patient in heal_list)
		return
	heal_list += patient
	//RegisterSignals(patient, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_AI_HEALING_MOB, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(unset_target), TRUE)
	RegisterSignal(patient, COMSIG_AI_HEALING_MOB, PROC_REF(unset_target))

/datum/ai_behavior/human/proc/remove_from_heal_list(mob/living/carbon/human/old_patient)
	UnregisterSignal(old_patient, COMSIG_AI_HEALING_MOB)
	heal_list -= old_patient

///Tries to heal another mob
/datum/ai_behavior/human/proc/try_heal_other(mob/living/carbon/human/patient)
	if(patient.InCritical()) //crit heal is always priority
		crit_heal(patient)
	//if(patient.on_fire)
	//	extinguish ??? todo

	if(medical_rating < AI_MED_MEDIC)
		return

	do_unset_target(patient, FALSE)
	//remove_from_heal_list(patient)

	try_speak(pick(healing_chat)) //new lines needed

	var/list/dam_list = list(
		BRUTE = patient.getBruteLoss(),
		BURN = patient.getFireLoss(),
		TOX = patient.getToxLoss(),
		OXY = patient.getOxyLoss(),
		CLONE = patient.getCloneLoss(),
		PAIN = patient.getShock_Stage() * 3, //pain is pretty important, but has low numbers and takes time to change
	)

	human_ai_state_flags |= HUMAN_AI_HEALING
	SEND_SIGNAL(patient, COMSIG_AI_HEALING_MOB, mob_parent)
	RegisterSignal(patient, COMSIG_MOVABLE_MOVED, PROC_REF(do_unset_target))

	dam_list = sortTim(dam_list, /proc/cmp_numeric_dsc, TRUE)
	var/did_heal = FALSE
	for(var/dam_type in dam_list)
		if(dam_list[dam_type] <= 10)
			continue
		if(do_heal(dam_type, patient))
			did_heal = TRUE
			continue

	var/list/broken_limbs = list()
	for(var/datum/limb/limb AS in patient.limbs)
		if(!(limb.limb_status & LIMB_BROKEN) || (limb.limb_status & LIMB_SPLINTED))
			continue
		broken_limbs += limb
	for(var/broken_limb in broken_limbs)
		if(!do_splint(broken_limb, patient))
			break
		did_heal = TRUE

	SEND_SIGNAL(mob_parent, COMSIG_AI_HEALING_FINISHED)
	human_ai_state_flags &= ~HUMAN_AI_HEALING
	//if we were unsuccesful in healing them for whatever reason, we stop. Generally because they're as healed as possible
	///RNG stop so they don't try apply 500 chems to someone
	if(!did_heal) //|| prob(30)
		do_unset_target(patient)
	else
		UnregisterSignal(patient, COMSIG_MOVABLE_MOVED)
	late_initialize()

///Handles a friendly in crit
/datum/ai_behavior/human/proc/crit_heal(mob/living/carbon/human/patient)
	var/obj/item/heal_item

	for(var/obj/item/stored_item AS in mob_inventory.oxy_list)
		if(!stored_item.ai_should_use(patient, mob_parent))
			continue
		heal_item = stored_item
		break

	if(!heal_item)
		return FALSE
	heal_item.ai_use(patient, mob_parent)
	return TRUE
