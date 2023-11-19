#define BANDAGE (1<<0)
#define SALVE (1<<1)
#define DISINFECT (1<<2)

/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
	amount = 10
	max_amount = 10
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 4
	throw_range = 20
	///Medical skill level needed to not get a fumble delay
	var/skill_level_needed = SKILL_MEDICAL_UNTRAINED
	///Fumble delay applied without sufficient skill
	var/unskilled_delay = SKILL_TASK_TRIVIAL

/obj/item/stack/medical/attack(mob/living/M, mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(M))
		M.balloon_alert(user, "not a human")
		return FALSE
	var/mob/living/carbon/human/target = M

	if(!ishuman(user))
		target.balloon_alert(user, "not dextrous enough")
		return FALSE

	if(user.do_actions)
		target.balloon_alert(user, "already busy")
		return

	var/datum/limb/affecting = user.client.prefs.toggles_gameplay & RADIAL_MEDICAL ? radial_medical(target, user) : target.get_limb(user.zone_selected)

	if(!affecting)
		return FALSE

	if(!can_affect_limb(affecting))
		target.balloon_alert(user, "Limb is [affecting.limb_status & LIMB_ROBOT ? "robotic": "organic"]!")
		return FALSE

	return affecting

///Checks for whether the limb is appropriately organic/robotic
/obj/item/stack/medical/proc/can_affect_limb(datum/limb/affecting)
	return !(affecting.limb_status & LIMB_ROBOT)

/obj/item/stack/medical/heal_pack
	name = "platonic gauze"
	amount = 40
	max_amount = 40
	///How much brute damage this pack heals when applied to a limb
	var/heal_brute = 0
	///How much burn damage this pack heals when applied to a limb
	var/heal_burn = 0
	///Set of wound flags applied by use, including BANDAGE, SALVE, and DISINFECT
	var/heal_flags = NONE


/obj/item/stack/medical/heal_pack/attack(mob/living/M, mob/living/user)
	. = ..()
	if(!.) // note this true/false is inverted because we want to get the limb
		return

	var/datum/limb/affecting = .
	var/mob/living/carbon/human/patient = M //If we've got to this point, the parent proc already checked they're human

	if(affecting.limb_status & LIMB_DESTROYED)
		patient.balloon_alert(user, "limb destroyed")
		return

	var/unskilled_penalty = (user.skills.getRating(SKILL_MEDICAL) < skill_level_needed) ? 0.5 : 1
	var/list/patient_limbs = patient.limbs.Copy()
	patient_limbs -= affecting
	while(affecting)
		if(!do_after(user, SKILL_TASK_VERY_EASY / (unskilled_penalty ** 2), NONE, patient, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL, extra_checks = CALLBACK(src, PROC_REF(can_affect_limb), affecting)))
			patient.balloon_alert(user, "Stopped tending")
			return
		var/affected = heal_limb(affecting, unskilled_penalty)
		generate_treatment_messages(user, patient, affecting, affected)
		use(1)
		affecting = null
		while(!affecting)
			var/candidate = popleft(patient_limbs)
			if(can_heal_limb(candidate))
				affecting = candidate
				break
			if(!length(patient_limbs))
				break
	patient.balloon_alert(user, "Finished tending")

/// return TRUE if a given limb can be healed by src, FALSE otherwise
/obj/item/stack/medical/heal_pack/proc/can_heal_limb(datum/limb/affecting)
	if(affecting.limb_status & LIMB_DESTROYED)
		return FALSE
	if(!can_affect_limb(affecting))
		return FALSE
	if(heal_flags & BANDAGE && !affecting.is_bandaged())
		return TRUE
	if(heal_flags & SALVE && !affecting.is_salved())
		return TRUE
	if(heal_flags & DISINFECT && !affecting.is_disinfected())
		return TRUE
	return FALSE

///Applies the heal_pack to a specified limb. Unskilled penalty is a multiplier between 0 and 1 on brute/burn healing effectiveness
/obj/item/stack/medical/heal_pack/proc/heal_limb(datum/limb/affecting, unskilled_penalty)
	var/affected = FALSE
	if(heal_flags & BANDAGE)
		affected |= affecting.bandage()
	if(heal_flags & SALVE)
		affected |= affecting.salve()
	if(heal_flags & DISINFECT)
		affected |= affecting.disinfect()

	if(affected)
		affecting.heal_limb_damage(heal_brute * unskilled_penalty, heal_burn * unskilled_penalty, updating_health = TRUE)

	return affected

///Purely visual, generates the success/failure messages for using a health pack
/obj/item/stack/medical/heal_pack/proc/generate_treatment_messages(mob/user, mob/patient, datum/limb/target_limb, success)
	if(!success)
		to_chat(user, span_warning("The wounds on [patient]'s [target_limb.display_name] have already been treated."))
		return
	user.visible_message(span_notice("[user] treats the wounds on [patient]'s [target_limb.display_name] with [src]."),
	span_notice("You treat the wounds on [patient]'s [target_limb.display_name] with [src].") )

/obj/item/stack/medical/heal_pack/gauze
	name = "roll of gauze"
	singular_name = "medical gauze"
	desc = "Some sterile gauze to wrap around bloody stumps."
	icon_state = "brutepack"
	heal_brute = 3
	heal_flags = BANDAGE

/obj/item/stack/medical/heal_pack/gauze/generate_treatment_messages(mob/user, mob/patient, datum/limb/target_limb, success)
	if(!success)
		to_chat(user, span_warning("The wounds on [patient]'s [target_limb.display_name] have already been treated."))
		return
	user.visible_message(span_notice("[user] bandages [patient]'s [target_limb.display_name]."),
		span_notice("You bandage [patient]'s [target_limb.display_name].") )

/obj/item/stack/medical/heal_pack/ointment
	name = "ointment"
	desc = "Used to treat burns, infected wounds, and relieve itching in unusual places."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	heal_burn = 3
	heal_flags = SALVE

/obj/item/stack/medical/heal_pack/ointment/generate_treatment_messages(mob/user, mob/patient, datum/limb/target_limb, success)
	if(!success)
		to_chat(user, span_warning("The wounds on [patient]'s [target_limb.display_name] have already been treated."))
		return
	user.visible_message(span_notice("[user] salves wounds on [patient]'s [target_limb.display_name]."),
	span_notice("You salve wounds on [patient]'s [target_limb.display_name]."))

/obj/item/stack/medical/heal_pack/gauze/sectoid
	name = "\improper healing resin pack"
	singular_name = "healing resin pack"
	desc = "A strange tool filled with a sticky, alien resin. It seems it is meant for covering wounds."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "predator_fixovein"
	heal_brute = 20
	heal_burn = 20
	heal_flags = BANDAGE | SALVE | DISINFECT


/obj/item/stack/medical/heal_pack/advanced
	dir = NORTH
	flags_atom = DIRLOCK
	skill_level_needed = SKILL_MEDICAL_PRACTICED
	unskilled_delay = SKILL_TASK_EASY

/obj/item/stack/medical/heal_pack/advanced/update_icon_state()
	if(max_amount < 1 || amount > max_amount)
		return
	var/percentage = round(amount / max_amount) * 100
	switch(percentage)
		if(1 to 20)
			setDir(SOUTH)
		if(21 to 40)
			setDir(EAST)
		if(41 to 60)
			setDir(SOUTHEAST)
		if(61 to 80)
			setDir(WEST)
		if(81 to INFINITY)
			setDir(NORTH)

/obj/item/stack/medical/heal_pack/advanced/bruise_pack
	name = "advanced trauma kit"
	singular_name = "advanced trauma kit"
	desc = "An advanced trauma kit for severe injuries."
	icon_state = "traumakit"
	heal_brute = 12
	heal_flags = BANDAGE | DISINFECT

/obj/item/stack/medical/heal_pack/advanced/bruise_pack/generate_treatment_messages(mob/user, mob/patient, datum/limb/target_limb, success)
	if(!success)
		to_chat(user, span_warning("The wounds on [patient]'s [target_limb.display_name] have already been treated."))
		return
	user.visible_message(span_notice("[user] cleans [patient]'s [target_limb.display_name] and seals its wounds with bioglue."),
		span_notice("You clean and seal all the wounds on [patient]'s [target_limb.display_name]."))

/obj/item/stack/medical/heal_pack/advanced/burn_pack
	name = "advanced burn kit"
	singular_name = "advanced burn kit"
	desc = "An advanced treatment kit for severe burns."
	icon_state = "burnkit"
	heal_burn = 12
	heal_flags = SALVE | DISINFECT

/obj/item/stack/medical/heal_pack/advanced/burn_pack/generate_treatment_messages(mob/user, mob/patient, datum/limb/target_limb, success)
	if(!success)
		to_chat(user, span_warning("The wounds on [patient]'s [target_limb.display_name] have already been treated."))
		return
	user.visible_message(span_notice("[user] covers the wounds on [patient]'s [target_limb.display_name] with regenerative membrane."),
	span_notice("You cover the wounds on [patient]'s [target_limb.display_name] with regenerative membrane."))

/obj/item/stack/medical/splint
	name = "medical splints"
	desc = "Used to stabilize broken bones."
	singular_name = "medical splint"
	icon_state = "splint"
	amount = 5
	max_amount = 5
	skill_level_needed = SKILL_MEDICAL_PRACTICED
	unskilled_delay = SKILL_TASK_TOUGH
	///How much splint health per medical skill is applied
	var/applied_splint_health = 15


/obj/item/stack/medical/splint/attack(mob/living/M, mob/living/user)
	. = ..()
	if(!.) // note this true/false is inverted because we want to get the limb
		return

	if(user.skills.getRating(SKILL_MEDICAL) < skill_level_needed)
		if(user.do_actions)
			M.balloon_alert(user, "already busy")
			return FALSE
		if(!do_after(user, unskilled_delay, NONE, M, BUSY_ICON_UNSKILLED, BUSY_ICON_MEDICAL))
			return FALSE

	var/datum/limb/affecting = .
	if(M == user && ((!user.hand && affecting.body_part == ARM_RIGHT) || (user.hand && affecting.body_part == ARM_LEFT)))
		user.balloon_alert(user, "You are using that arm!")
		return
	if(affecting.apply_splints(src, user == M ? (applied_splint_health*max(user.skills.getRating(SKILL_MEDICAL) - 1, 0)) : applied_splint_health*user.skills.getRating(SKILL_MEDICAL), user, M))
		use(1)


#undef BANDAGE
#undef SALVE
#undef DISINFECT
