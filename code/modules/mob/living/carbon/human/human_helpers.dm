/proc/get_gender_name(gender)
	var/g = "m"
	if (gender == FEMALE)
		g = "f"
	return g

/proc/get_limb_icon_name(datum/species/S, gender, limb_name, ethnicity)
	if(S.limb_type == SPECIES_LIMB_HUMAN) // todo this section is fucking stupid and can be way more generic easily
		switch(limb_name)
			if ("torso", "chest")
				return "[ethnicity]_torso_[get_gender_name(gender)]"

			if ("head")
				return "[ethnicity]_head_[get_gender_name(gender)]"

			if ("groin")
				return "[ethnicity]_groin_[get_gender_name(gender)]"

			if ("r_arm", "right arm")
				return "[ethnicity]_right_arm_[get_gender_name(gender)]"

			if ("l_arm", "left arm")
				return "[ethnicity]_left_arm_[get_gender_name(gender)]"

			if ("r_leg", "right leg")
				return "[ethnicity]_right_leg_[get_gender_name(gender)]"

			if ("l_leg", "left leg")
				return "[ethnicity]_left_leg_[get_gender_name(gender)]"

			if ("r_hand", "right hand")
				return "[ethnicity]_right_hand_[get_gender_name(gender)]"

			if ("l_hand", "left hand")
				return "[ethnicity]_left_hand_[get_gender_name(gender)]"

			if ("r_foot", "right foot")
				return "[ethnicity]_right_foot_[get_gender_name(gender)]"

			if ("l_foot", "left foot")
				return "[ethnicity]_left_foot_[get_gender_name(gender)]"

			else
				return null
	else if(S.limb_type == SPECIES_LIMB_CLONE)
		switch(limb_name)
			if ("torso", "chest")
				return "torso_[get_gender_name(gender)]"

			if ("head")
				return "head_[get_gender_name(gender)]"

			if ("groin")
				return "groin_[get_gender_name(gender)]"

			if ("r_arm", "right arm")
				return "right_arm_[get_gender_name(gender)]"

			if ("l_arm", "left arm")
				return "left_arm_[get_gender_name(gender)]"

			if ("r_leg", "right leg")
				return "right_leg_[get_gender_name(gender)]"

			if ("l_leg", "left leg")
				return "left_leg_[get_gender_name(gender)]"

			if ("r_hand", "right hand")
				return "right_hand_[get_gender_name(gender)]"

			if ("l_hand", "left hand")
				return "left_hand_[get_gender_name(gender)]"

			if ("r_foot", "right foot")
				return "right_foot_[get_gender_name(gender)]"

			if ("l_foot", "left foot")
				return "left_foot_[get_gender_name(gender)]"
	else
		switch(limb_name)
			if ("torso")
				return "[limb_name]_[get_gender_name(gender)]"

			if ("chest")
				return "[limb_name]_[get_gender_name(gender)]"

			if ("head")
				return "head_[get_gender_name(gender)]"

			if ("groin")
				return "[limb_name]_[get_gender_name(gender)]"

			if ("r_arm")
				return "[limb_name]"

			if ("right arm")
				return "r_arm"

			if ("l_arm")
				return "[limb_name]"

			if ("left arm")
				return "l_arm"

			if ("r_leg")
				return "[limb_name]"

			if ("right leg")
				return "r_leg"

			if ("l_leg")
				return "[limb_name]"

			if ("left leg")
				return "l_leg"

			if ("r_hand")
				return "[limb_name]"

			if ("right hand")
				return "r_hand"

			if ("l_hand")
				return "[limb_name]"

			if ("left hand")
				return "l_hand"

			if ("r_foot")
				return "[limb_name]"

			if ("right foot")
				return "r_foot"

			if ("l_foot")
				return "[limb_name]"

			if ("left foot")
				return "l_foot"
			else
				return null

/mob/living/carbon/human/proc/set_limb_icons()
	var/datum/ethnicity/E = GLOB.ethnicities_list[ethnicity]

	var/e_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	for(var/datum/limb/L in limbs)
		L.icon_name = get_limb_icon_name(species, physique, L.display_name, e_icon)

/mob/living/carbon/human/get_reagent_tags()
	. = ..()
	return .|IS_HUMAN

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	. = reagents

	if(!.) //yikes
		return

	if(!user)
		target_zone = pick("chest","chest","chest","left leg","right leg","left arm", "right arm", "head")
	else if(!target_zone)
		target_zone = user.zone_selected

	if(!penetrate_thick)
		switch(target_zone)
			if("head")
				if(head?.inventory_flags & BLOCKSHARPOBJ)
					. = FALSE
			else
				if(wear_suit?.inventory_flags & BLOCKSHARPOBJ)
					. = FALSE
	if(!. && error_msg && user)
		// Might need re-wording.
		to_chat(user, span_alert("There is no exposed flesh or thin material [target_zone == "head" ? "on their head" : "on their body"] to inject into."))


/mob/living/carbon/human/has_brain()
	if(get_organ_slot(ORGAN_SLOT_BRAIN))
		var/datum/internal_organ/brain = get_organ_slot(ORGAN_SLOT_BRAIN)
		if(brain && istype(brain))
			return 1
	return 0

/mob/living/carbon/human/has_eyes()
	if(get_organ_slot(ORGAN_SLOT_EYES))
		var/datum/internal_organ/eyes = get_organ_slot(ORGAN_SLOT_EYES)
		if(eyes && istype(eyes))
			return 1
	return 0

/mob/living/carbon/human/has_vision()
	if(disabilities & BLIND)
		return FALSE
	if(!species.has_organ["eyes"]) //can see through other means
		return TRUE
	if(!has_eyes())
		return FALSE
	if(tinttotal >= TINT_BLIND)
		return FALSE
	return TRUE


/mob/living/carbon/human/has_legs()
	. = 0
	if(has_limb(FOOT_RIGHT) && has_limb(LEG_RIGHT))
		.++
	if(has_limb(FOOT_LEFT) && has_limb(LEG_LEFT))
		.++

/mob/living/carbon/human/get_permeability_protection()
	// hands = 1 | chest = 2 | groin = 3 | legs = 4 | feet = 5 | arms = 6 | head = 7
	var/list/prot = list(0,0,0,0,0,0,0)
	for(var/obj/item/I in get_equipped_items())
		if(I.armor_protection_flags & HANDS)
			prot[1] = max(1 - I.permeability_coefficient, prot[1])
		if(I.armor_protection_flags & CHEST)
			prot[2] = max(1 - I.permeability_coefficient, prot[2])
		if(I.armor_protection_flags & GROIN)
			prot[3] = max(1 - I.permeability_coefficient, prot[3])
		if(I.armor_protection_flags & LEGS)
			prot[4] = max(1 - I.permeability_coefficient, prot[4])
		if(I.armor_protection_flags & FEET)
			prot[5] = max(1 - I.permeability_coefficient, prot[5])
		if(I.armor_protection_flags & ARMS)
			prot[6] = max(1 - I.permeability_coefficient, prot[6])
		if(I.armor_protection_flags & HEAD)
			prot[7] = max(1 - I.permeability_coefficient, prot[7])
	var/protection = (prot[7] + prot[6] + prot[5] + prot[4] + prot[3] + prot[2] + prot[1])/7
	return protection

/mob/living/carbon/human/get_soft_acid_protection()
	var/protection = 0
	for(var/def_zone in GLOB.human_body_parts)
		protection += get_soft_armor(ACID, def_zone)
	// adds arms and feet twice since precise.(acid armor goes from 0 to 100)
	return protection/1100

/mob/living/carbon/human/get_hard_acid_protection()
	var/protection = 0
	for(var/def_zone in GLOB.human_body_parts)
		protection += get_hard_armor(ACID, def_zone)
	// adds arms and feet twice since precise.
	return protection/11

/mob/living/carbon/human/get_standard_bodytemperature()
	return species.body_temperature

/mob/living/carbon/human/get_policy_keywords()
	. = ..()
	if(species.name)
		. += species.name

///wrapper for a signal to handle opening the squad selector ui just before drop
/mob/living/carbon/human/proc/suggest_squad_assign()
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, COMSIG_GLOB_DEPLOY_TIMELOCK_ENDED)
	GLOB.squad_selector.interact(src)

/**
 * Proc to check if a carbon human has the required organs to sustain life.
 *
 * Returns false if `has_brain` returns false, this human is missing a heart, or their current heart is broken
 *
 * Returns true otherwise
 */
/mob/living/carbon/human/proc/has_working_organs()
	var/datum/internal_organ/heart/heart = get_organ_slot(ORGAN_SLOT_HEART)

	if(species.species_flags & ROBOTIC_LIMBS)
		return TRUE // combat robots and synthetics don't have any of these for some reason
	if(!has_brain())
		return FALSE
	if(!heart || heart.organ_status == ORGAN_BROKEN)
		return FALSE
	return TRUE

/**
 * Proc that brings a carbon human back to life. Only works if their health is higher than their death threshold and they are dead in the first place.
 *
 * Intended to be called by defibrillators or anything that brings a carbon human back to life
 */
/mob/living/carbon/human/proc/resuscitate()
	if(stat != DEAD || health <= get_death_threshold())
		return
	set_stat(UNCONSCIOUS)
	chestburst = CARBON_NO_CHEST_BURST
	regenerate_icons()
	reload_fullscreens()
	handle_regular_hud_updates()
	updatehealth() //One more time, so it doesn't show the target as dead on HUDs
	dead_ticks = 0 //We reset the DNR timer
	REMOVE_TRAIT(src, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)

/**
 * Proc for checking parameters of a human for defibrillation.
 *
 * Checks decapitation, DNR status, organ damage and health status (in that order) for defibrillation.
 *
 * See defines in `__DEFINES/defibrillator.dm` for bitflags.
 *
 * `additional_health_increase` can be used to add additional health when calculating health for situations like grabbing ghost.
 */
/mob/living/carbon/human/proc/check_defib(additional_health_increase = 0)

	var/datum/limb/head/head = get_limb("head")
	if(head.limb_status & LIMB_DESTROYED)
		return DEFIB_FAIL_DECAPITATED

	if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
		return DEFIB_FAIL_BRAINDEAD

	if(!has_working_organs())
		return DEFIB_FAIL_BAD_ORGANS

	if(health + getOxyLoss() + additional_health_increase <= get_death_threshold())
		return DEFIB_FAIL_TOO_MUCH_DAMAGE

	return DEFIB_POSSIBLE

/**
 * Setter for mob height
 *
 * Exists so that the update is done immediately
 *
 * Returns TRUE if changed, FALSE otherwise
 */
/mob/living/carbon/human/proc/set_mob_height(new_height)
	if(mob_height == new_height)
		return FALSE
	if(new_height == HUMAN_HEIGHT_DWARF || new_height == MONKEY_HEIGHT_DWARF)
		CRASH("Don't set height to dwarf height directly, use dwarf trait instead.")
	if(new_height == MONKEY_HEIGHT_MEDIUM)
		CRASH("Don't set height to monkey height directly, use monkified gene/species instead.")

	mob_height = new_height
	regenerate_icons()
	return TRUE

/**
 * Getter for mob height
 *
 * Mainly so that dwarfism can adjust height without needing to override existing height
 *
 * Returns a mob height num
 */
/mob/living/carbon/human/proc/get_mob_height()
	if(HAS_TRAIT(src, TRAIT_DWARF))
		if(ismonkey(src))
			return MONKEY_HEIGHT_DWARF
		else
			return HUMAN_HEIGHT_DWARF
	if(HAS_TRAIT(src, TRAIT_TOO_TALL))
		if(ismonkey(src))
			return MONKEY_HEIGHT_TALL
		else
			return HUMAN_HEIGHT_TALLEST

	else if(ismonkey(src))
		return MONKEY_HEIGHT_MEDIUM

	return mob_height

///Gets organ by name
/mob/living/carbon/human/proc/get_organ_slot(string)
	return internal_organs_by_name[string]

///Removes organ by name
/mob/living/carbon/human/proc/remove_organ_slot(string)
	var/datum/internal_organ/organ = get_organ_slot(string)
	internal_organs_by_name -= string
	internal_organs -= organ

/// Current active hand will interact with the other hand. Uses attackby and attack_hand.
/mob/living/carbon/human/proc/interact_other_hand()
	var/atom/active_hand = get_active_held_item()
	var/atom/inactive_hand = get_inactive_held_item()

	if(!inactive_hand)
		return
	if(!active_hand)
		inactive_hand.attack_hand(src)
		return
	inactive_hand.attackby(active_hand, src)
