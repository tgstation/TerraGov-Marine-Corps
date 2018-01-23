

/mob/living/carbon/human/IsAdvancedToolUser()
	return species.has_fine_manipulation


/mob/living/carbon/human/can_inject(var/mob/user, var/error_msg, var/target_zone)
	. = 1

	if(!user)
		target_zone = pick("chest","chest","chest","left leg","right leg","left arm", "right arm", "head")
	else if(!target_zone)
		target_zone = user.zone_selected

	switch(target_zone)
		if("head")
			if(head && head.flags_inventory & BLOCKSHARPOBJ)
				. = 0
		else
			if(wear_suit && wear_suit.flags_inventory & BLOCKSHARPOBJ)
				. = 0
	if(!. && error_msg && user)
 		// Might need re-wording.
		user << "<span class='alert'>There is no exposed flesh or thin material [target_zone == "head" ? "on their head" : "on their body"] to inject into.</span>"


/mob/living/carbon/human/has_brain()
	if(internal_organs_by_name["brain"])
		var/datum/internal_organ/brain = internal_organs_by_name["brain"]
		if(brain && istype(brain))
			return 1
	return 0

/mob/living/carbon/human/has_eyes()
	if(internal_organs_by_name["eyes"])
		var/datum/internal_organ/eyes = internal_organs_by_name["eyes"]
		if(eyes && istype(eyes) && !eyes.cut_away)
			return 1
	return 0


/mob/living/carbon/human/is_mob_restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1

	if (istype(buckled, /obj/structure/bed/nest))
		return 1

	return 0


/mob/living/carbon/human/has_legs()
	. = 0
	if(has_limb("r_foot") && has_limb("r_leg"))
		.++
	if(has_limb("l_foot") && has_limb("l_leg"))
		.++
