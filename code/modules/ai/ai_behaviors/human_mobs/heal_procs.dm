///Cycles through and heals the normal damage types
/datum/ai_behavior/human/proc/heal_damage(mob/living/carbon/human/patient)
	var/list/dam_list = list(
		BRUTE = patient.getBruteLoss(),
		BURN = patient.getFireLoss(),
		TOX = patient.getToxLoss(),
		OXY = patient.getOxyLoss(),
		CLONE = patient.getCloneLoss(),
		PAIN = patient.getShock_Stage() * 3, //pain is pretty important, but has low numbers and takes time to change
	)

	dam_list = sortTim(dam_list, /proc/cmp_numeric_dsc, TRUE)
	for(var/dam_type in dam_list)
		if(dam_list[dam_type] <= 10)
			continue
		if(heal_by_type(patient, dam_type))
			. = TRUE
			continue

///Heal other ailments
/datum/ai_behavior/human/proc/heal_secondaries(mob/living/carbon/human/patient)
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
		. = TRUE

	if(internal_bleeding)
		heal_by_type(patient, INTERNAL_BLEEDING)
		. = TRUE

	if(shrap_limb)
		var/obj/item/shrap_remover = locate(/obj/item/tweezers_advanced) in mob_inventory.medical_list
		if(!shrap_remover)
			shrap_remover = locate(/obj/item/tweezers) in mob_inventory.medical_list
		if(shrap_remover)
			shrap_remover.ai_use(patient, mob_parent)
			. = TRUE

	for(var/broken_limb in broken_limbs)
		if(!do_splint(broken_limb, patient))
			break
		. = TRUE

///Addresses organ damage
/datum/ai_behavior/human/proc/heal_organs(mob/living/carbon/human/patient = mob_parent)
	var/organ_damaged = FALSE
	for(var/datum/internal_organ/organ AS in patient.internal_organs)
		if(organ.damage < organ.min_bruised_damage)
			continue
		if(istype(organ, /datum/internal_organ/eyes))
			if(heal_by_type(patient, EYE_DAMAGE))
				. = TRUE
			continue
		if(istype(organ, /datum/internal_organ/brain))
			if(heal_by_type(patient, BRAIN_DAMAGE))
				. = TRUE
			continue
		organ_damaged = TRUE

	if(organ_damaged && heal_by_type(patient, ORGAN_DAMAGE))
		. = TRUE

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

///Tries to splint a limb
/datum/ai_behavior/human/proc/do_splint(datum/limb/broken_limb, target = mob_parent)
	var/obj/item/stack/medical/splint/splint = locate(/obj/item/stack/medical/splint) in mob_inventory.medical_list
	if(!splint)
		return FALSE
	mob_parent.zone_selected = broken_limb.name //why god do we rely on the limb name, which isnt a define?
	if(splint.attack(target, mob_parent))
		. = TRUE
	mob_parent?.zone_selected = BODY_ZONE_CHEST

///Tries to revive a dead dude
/datum/ai_behavior/human/proc/do_defib(mob/living/carbon/human/patient, obj/item/defibrillator/defib)
	if(patient.stat != DEAD)
		return
	if(!(patient.check_defib() & (DEFIB_POSSIBLE|DEFIB_FAIL_TOO_MUCH_DAMAGE))) //can't be revived
		return
	if(!defib)
		defib = locate(/obj/item/defibrillator) in mob_inventory.medical_list
	if(!defib)
		return
	if(!defib.ready)
		defib.attack_self(mob_parent) //do it early so the cooldown can happen while we do other shit
	if(!HAS_TRAIT(patient, TRAIT_IMMEDIATE_DEFIB) && patient.health + patient.getOxyLoss() + (2 * DEFIBRILLATOR_HEALING_TIMES_SKILL(mob_parent.skills.getRating(SKILL_MEDICAL), DEFIBRILLATOR_BASE_HEALING_VALUE)) <= patient.get_death_threshold())
		try_heal_other(patient, TRUE)
	if(patient.wear_suit)
		if(!do_after(mob_parent, patient.wear_suit.strip_delay, NONE, patient, BUSY_ICON_FRIENDLY))
			return
		patient.dropItemToGround(patient.wear_suit)
		if(patient.stat != DEAD) //someone else got them
			return
	if(!defib.defibrillate(patient, mob_parent)) //we were unable to defib for whatever reason
		return
	if(patient.stat != DEAD)
		if(patient.InCritical())
			try_heal_other(patient, TRUE)
		return TRUE
	if(!do_after(mob_parent, DEFIBRILLATOR_COOLDOWN + 1, NONE, patient, BUSY_ICON_FRIENDLY))
		return
	return do_defib(patient, defib)

