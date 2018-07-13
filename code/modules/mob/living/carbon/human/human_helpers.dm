

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
				message_admins("DEBUG: Something called get_limb_icon_name() incorrectly, they use the name [limb_name]")
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
				message_admins("DEBUG: Something called get_limb_icon_name() incorrectly, they use the name [limb_name]")
				return null

/mob/living/carbon/human/proc/set_limb_icons()
	var/datum/ethnicity/E = ethnicities_list[ethnicity]
	var/datum/body_type/B = body_types_list[body_type]

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


/mob/living/carbon/human/is_mob_restrained(var/check_grab = 1)
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
	if(has_limb("r_foot") && has_limb("r_leg"))
		.++
	if(has_limb("l_foot") && has_limb("l_leg"))
		.++

/mob/living/carbon/human/proc/disable_lights(var/armor = 1, var/guns = 1, var/flares = 1, var/misc = 1)
	var/light_off = 0
	var/goes_out = 0
	if(armor)
		if(istype(wear_suit, /obj/item/clothing/suit/storage/marine))
			var/obj/item/clothing/suit/storage/marine/S = wear_suit
			if(S.turn_off_light(src))
				light_off++
	if(guns)
		for(var/obj/item/weapon/gun/G in contents)
			if(G.turn_off_light(src))
				light_off++
	if(flares)
		for(var/obj/item/device/flashlight/flare/F in contents)
			if(F.on) goes_out++
			F.turn_off(src)
	if(misc)
		for(var/obj/item/device/flashlight/L in contents)
			if(istype(L, /obj/item/device/flashlight/flare)) continue
			if(L.turn_off_light(src))
				light_off++
		for(var/obj/item/tool/weldingtool/W in contents)
			if(W.isOn())
				W.toggle()
				goes_out++
		for(var/obj/item/tool/match/M in contents)
			M.burn_out(src)
		for(var/obj/item/tool/lighter/Z in contents)
			if(Z.turn_off(src))
				goes_out++
	if(goes_out && light_off)
		src << "<span class='notice'>Your sources of light short and fizzle out.</span>"
	else if(goes_out)
		if(goes_out > 1)
			src << "<span class='notice'>Your sources of light fizzle out.</span>"
		else
			src << "<span class='notice'>Your source of light fizzles out.</span>"
	else if(light_off)
		if(light_off > 1)
			src << "<span class='notice'>Your sources of light short out.</span>"
		else
			src << "<span class='notice'>Your source of light shorts out.</span>"
