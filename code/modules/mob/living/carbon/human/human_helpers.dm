/mob/living/carbon/human/get_crit_threshold()
	return CONFIG_GET(number/human_health_threshold_crit)

/mob/living/carbon/human/IsAdvancedToolUser()
	return species.has_fine_manipulation

/proc/get_gender_name(gender)
	var/g = "m"
	if (gender == FEMALE)
		g = "f"
	return g

/proc/get_limb_icon_name(var/datum/species/S, var/body_type, var/gender, var/limb_name, var/ethnicity)
	if(S.name == "Human")
		switch(limb_name)
			if ("torso")
				return "[ethnicity]_torso_[body_type]_[get_gender_name(gender)]"

			if ("chest")
				return "[ethnicity]_torso_[body_type]_[get_gender_name(gender)]"

			if ("head")
				return "[ethnicity]_[limb_name]_[get_gender_name(gender)]"

			if ("groin")
				return "[ethnicity]_[limb_name]_[get_gender_name(gender)]"

			if ("r_arm")
				return "[ethnicity]_right_arm"

			if ("right arm")
				return "[ethnicity]_right_arm"

			if ("l_arm")
				return "[ethnicity]_left_arm"

			if ("left arm")
				return "[ethnicity]_left_arm"

			if ("r_leg")
				return "[ethnicity]_right_leg"

			if ("right leg")
				return "[ethnicity]_right_leg"

			if ("l_leg")
				return "[ethnicity]_left_leg"

			if ("left leg")
				return "[ethnicity]_left_leg"

			if ("r_hand")
				return "[ethnicity]_right_hand"

			if ("right hand")
				return "[ethnicity]_right_hand"

			if ("l_hand")
				return "[ethnicity]_left_hand"

			if ("left hand")
				return "[ethnicity]_left_hand"

			if ("r_foot")
				return "[ethnicity]_right_foot"

			if ("right foot")
				return "[ethnicity]_right_foot"

			if ("l_foot")
				return "[ethnicity]_left_foot"

			if ("left foot")
				return "[ethnicity]_left_foot"

			else
				return null
	else
		switch(limb_name)
			if ("torso")
				return "[limb_name]_[get_gender_name(gender)]"

			if ("chest")
				return "[limb_name]_[get_gender_name(gender)]"

			if ("head")
				return "[limb_name]_[get_gender_name(gender)]"

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
	var/datum/body_type/B = GLOB.body_types_list[body_type]

	var/e_icon
	var/b_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	if (!B)
		b_icon = "mesomorphic"
	else
		b_icon = B.icon_name

	for(var/datum/limb/L in limbs)
		L.icon_name = get_limb_icon_name(species, b_icon, gender, L.display_name, e_icon)

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
				if(head?.flags_inventory & BLOCKSHARPOBJ)
					. = FALSE
			else
				if(wear_suit?.flags_inventory & BLOCKSHARPOBJ)
					. = FALSE
	if(!. && error_msg && user)
 		// Might need re-wording.
		to_chat(user, "<span class='alert'>There is no exposed flesh or thin material [target_zone == "head" ? "on their head" : "on their body"] to inject into.</span>")


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

/mob/living/carbon/human/has_vision()
	if(sdisabilities & BLIND)
		return FALSE
	if(!species.has_organ["eyes"]) //can see through other means
		return TRUE
	if(!has_eyes())
		return FALSE
	if(get_total_tint() >= TINT_HEAVY)
		return FALSE
	return TRUE

/mob/living/carbon/human/restrained(var/check_grab = 1)
	if(check_grab && pulledby && pulledby.grab_level >= GRAB_NECK)
		return 1
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1

	if (istype(buckled, /obj/structure/bed/nest))
		return 1

	return 0


/mob/living/carbon/human/has_legs()
	. = 0
	if(has_limb(FOOT_RIGHT) && has_limb(LEG_RIGHT))
		.++
	if(has_limb(FOOT_LEFT) && has_limb(LEG_LEFT))
		.++

/mob/living/carbon/human/get_permeability_protection()
	var/list/prot = list("hands"=0, "chest"=0, "groin"=0, "legs"=0, "feet"=0, "arms"=0, "head"=0)
	for(var/obj/item/I in get_equipped_items())
		if(I.flags_armor_protection & HANDS)
			prot["hands"] = max(1 - I.permeability_coefficient, prot["hands"])
		if(I.flags_armor_protection & CHEST)
			prot["chest"] = max(1 - I.permeability_coefficient, prot["chest"])
		if(I.flags_armor_protection & GROIN)
			prot["groin"] = max(1 - I.permeability_coefficient, prot["groin"])
		if(I.flags_armor_protection & LEGS)
			prot["legs"] = max(1 - I.permeability_coefficient, prot["legs"])
		if(I.flags_armor_protection & FEET)
			prot["feet"] = max(1 - I.permeability_coefficient, prot["feet"])
		if(I.flags_armor_protection & ARMS)
			prot["arms"] = max(1 - I.permeability_coefficient, prot["arms"])
		if(I.flags_armor_protection & HEAD)
			prot["head"] = max(1 - I.permeability_coefficient, prot["head"])
	var/protection = (prot["head"] + prot["arms"] + prot["feet"] + prot["legs"] + prot["groin"] + prot["chest"] + prot["hands"])/7
	return protection

mob/living/carbon/human/get_standard_bodytemperature()
	return species.body_temperature

/mob/living/proc/camo_off_process(code = 0, damage = 0)
	return

/mob/living/carbon/human/camo_off_process(code = 0, damage = 0)
	if(!code)
		return
	if(!istype(back, /obj/item/storage/backpack/marine/satchel/scout_cloak) )
		return
	var/obj/item/storage/backpack/marine/satchel/scout_cloak/S = back
	if(!S.camo_active)
		return
	switch(code)
		if(SCOUT_CLOAK_OFF_ATTACK)
			to_chat(src, "<span class='danger'>Your cloak shimmers from your actions!</span>")
			S.camo_last_shimmer = world.time //Reduces transparency to 50%
			alpha = max(alpha,S.shimmer_alpha)
		if(SCOUT_CLOAK_OFF_DAMAGE)
			if(damage >= 15)
				to_chat(src, "<span class='danger'>Your cloak shimmers from the damage!</span>")
				S.camo_last_shimmer = world.time //Reduces transparency to 50%
				alpha = max(alpha,S.shimmer_alpha)


/mob/living/carbon/human/throw_item(atom/target)
	. = ..()
	camo_off_process(SCOUT_CLOAK_OFF_ATTACK)


/mob/living/carbon/human/toggle_move_intent(screen_num as null|num)
	screen_num = 9
	if(legcuffed)
		to_chat(src, "<span class='notice'>You are legcuffed! You cannot run until you get [legcuffed] removed!</span>")
		m_intent = MOVE_INTENT_WALK
	return ..()