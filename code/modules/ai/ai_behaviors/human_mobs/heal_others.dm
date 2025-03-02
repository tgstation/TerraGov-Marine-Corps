//todo: add a mobs to help list so we can record who needs help, even if we're too busy to help right now
/datum/ai_behavior/human
	///A list of mobs that might need healing
	var/list/heal_list = list()
	///Chat lines for trying to heal
	var/list/healing_chat = list("Healing you.", "Healing you, hold still.", "Stop moving!", "Fixing you up.", "Healing.", "Treating wounds.", "I'll have you patched up in no time.", "Quit your complaining, it's just a fleshwound.", "Cover me!", "Give me some room!")

/datum/ai_behavior/human/late_initialize()
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		return
	. = ..()
	if(!registered_for_move)
		scheduled_move()

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
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
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
	RegisterSignal(crit_mob, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_interactee_stat_change))

///Unregisters a friendly target when their stat changes
/datum/ai_behavior/human/proc/on_interactee_stat_change(mob/living/carbon/source, current_stat, new_stat) //this is only for crit heal currently
	SIGNAL_HANDLER
	if(new_stat == current_stat)
		return
	if((medical_rating < AI_MED_MEDIC) || (new_stat == DEAD)) //todo: change when adding defib
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
	if(human_ai_state_flags & HUMAN_AI_ANY_HEALING)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return
	set_interact_target(patient)

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

///Tries to heal another mob
/datum/ai_behavior/human/proc/try_heal_other(mob/living/carbon/human/patient)
	if(patient.InCritical()) //crit heal is always priority
		crit_heal(patient)
	//if(patient.on_fire)
	//	extinguish ??? todo

	if(medical_rating < AI_MED_MEDIC)
		return

	do_unset_target(patient, FALSE)

	try_speak(pick(healing_chat))

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
	//health
	for(var/dam_type in dam_list)
		if(dam_list[dam_type] <= 10)
			continue
		if(heal_by_type(patient, dam_type))
			did_heal = TRUE
			continue


	var/infection
	var/internal_bleeding
	var/shrap_limb //we only need one since it will auto cycle to other limbs
	var/list/broken_limbs = list()

	for(var/datum/limb/limb AS in patient.limbs)
		if(limb.germ_level > INFECTION_LEVEL_ONE)
			infection = TRUE

		if((limb.limb_status & LIMB_BROKEN) && !(limb.limb_status & LIMB_SPLINTED))
			broken_limbs += limb

		if(!internal_bleeding)
			for(var/datum/wound/wound in limb.wounds)
				if(!istype(wound, /datum/wound/internal_bleeding))
					continue
				internal_bleeding = TRUE
				break

		if(!shrap_limb && length(limb.implants))
			for(var/obj/item/embedded AS in limb.implants)
				if(embedded.is_beneficial_implant())
					continue
				shrap_limb = limb
				break

	if(infection)
		heal_by_type(patient, INFECTION )
		did_heal = TRUE

	if(internal_bleeding)
		heal_by_type(patient, INTERNAL_BLEEDING)
		did_heal = TRUE

	if(shrap_limb)
		var/obj/item/shrap_remover = locate(/obj/item/tweezers_advanced) in mob_inventory.medical_list
		if(!shrap_remover)
			shrap_remover = locate(/obj/item/tweezers) in mob_inventory.medical_list
		if(shrap_remover)
			shrap_remover.ai_use(patient, mob_parent)
			did_heal = TRUE

	for(var/broken_limb in broken_limbs)
		if(!do_splint(broken_limb, patient))
			break
		did_heal = TRUE

	do_organ_heal(patient)

	if(!did_heal || prob(30)) //heal interupted or nothing left to heal, or to stop overload
		do_unset_target(patient)
	UnregisterSignal(patient, COMSIG_MOVABLE_MOVED)
	on_heal_end(mob_parent)
	SEND_SIGNAL(mob_parent, COMSIG_AI_HEALING_FINISHED)

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

///Addresses organ damage
/datum/ai_behavior/human/proc/do_organ_heal(mob/living/carbon/human/patient = mob_parent)
	var/organ_damaged = FALSE
	for(var/datum/internal_organ/organ AS in patient.internal_organs)
		if(organ.damage < organ.min_bruised_damage)
			continue
		if(istype(organ, /datum/internal_organ/eyes))
			heal_by_type(patient, EYE_DAMAGE)
			continue
		if(istype(organ, /datum/internal_organ/brain))
			heal_by_type(patient, BRAIN_DAMAGE)
			continue
		organ_damaged = TRUE
	if(organ_damaged)
		heal_by_type(patient, ORGAN_DAMAGE)

///Tries to heal damage of a given type
/datum/ai_behavior/human/proc/heal_by_type(mob/living/carbon/human/patient, dam_type)
	var/obj/item/heal_item
	var/list/med_list

	switch(dam_type)
		if(BRUTE)
			med_list = mob_inventory.brute_list
		if(BURN)
			med_list = mob_inventory.burn_list
		if(TOX)
			med_list = mob_inventory.tox_list
		if(OXY)
			med_list = mob_inventory.oxy_list
		if(CLONE)
			med_list = mob_inventory.clone_list
		if(PAIN)
			med_list = mob_inventory.pain_list
		if(EYE_DAMAGE)
			med_list = mob_inventory.eye_list
		if(BRAIN_DAMAGE)
			med_list = mob_inventory.brain_list
		if(INTERNAL_BLEEDING)
			med_list = mob_inventory.ib_list
		if(ORGAN_DAMAGE)
			med_list = mob_inventory.organ_list
		if(INFECTION)
			med_list = mob_inventory.infection_list

	for(var/obj/item/stored_item AS in med_list)
		if(!stored_item.ai_should_use(patient, mob_parent))
			continue
		heal_item = stored_item
		break

	if(!heal_item)
		return FALSE
	heal_item.ai_use(patient, mob_parent)
	return TRUE
