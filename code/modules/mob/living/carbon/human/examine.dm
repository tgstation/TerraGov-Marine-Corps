/mob/living/carbon/human/proc/on_examine_face(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.dna?.species && dna?.species)
		if(user.dna.species.name != "Dark Elf")
			if(dna.species.name == "Dark Elf")
				user.add_stress(/datum/stressevent/delf)
		if(user.dna.species.name != "Tiefling")
			if(dna.species.name == "Tiefling")
				user.add_stress(/datum/stressevent/tieb)
	if(user.has_flaw(/datum/charflaw/paranoid))
		if((STASTR - user.STASTR) > 1)
			user.add_stress(/datum/stressevent/parastr)

/mob/living/carbon/human/examine(mob/user)
//this is very slightly better than it was because you can use it more places. still can't do \his[src] though.
	var/t_He = p_they(TRUE)
	var/t_his = p_their()
//	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()
	var/obscure_name
	var/race_name = dna.species.name

	var/m1 = "[t_He] [t_is]"
	var/m2 = "[t_his]"
	var/m3 = "[t_He] [t_has]"
	if(user == src)
		m1 = "I am"
		m2 = "my"
		m3 = "I have"

	if(isliving(user))
		var/mob/living/L = user
		if(HAS_TRAIT(L, TRAIT_PROSOPAGNOSIA))
			obscure_name = TRUE

	if(name == "Unknown" || name == "Unknown Man" || name == "Unknown Woman")
		obscure_name = TRUE

	if(isobserver(user))
		obscure_name = FALSE

	if(obscure_name)
		. = list("<span class='info'>ø ------------ ø\nThis is <EM>Unknown</EM>.")
	else
		on_examine_face(user)
		var/used_name = name
		if(isobserver(user))
			used_name = real_name
		if(job)
			var/datum/job/J = SSjob.GetJob(job)
			var/used_title = J.title
			if(gender == FEMALE && J.f_title)
				used_title = J.f_title
			if(used_title == "Adventurer")
				used_title = advjob
				. = list("<span class='info'>ø ------------ ø\nThis is <EM>[used_name]</EM>, the wandering [race_name] [used_title].")
			else
				if(islatejoin)
					. = list("<span class='info'>ø ------------ ø\nThis is <EM>[used_name]</EM>, the returning [race_name] [used_title].")
				else
					. = list("<span class='info'>ø ------------ ø\nThis is <EM>[used_name]</EM>, the [race_name] [used_title].")
		else
			. = list("<span class='info'>ø ------------ ø\nThis is the [race_name], <EM>[used_name]</EM>.")

		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.marriedto == real_name)
				. += "<span class='love'>It's my spouse.</span>"

		if(real_name in GLOB.excommunicated_players)
			. += "<span class='userdanger'>HERETIC! SHAME!</span>"

		if(real_name in GLOB.outlawed_players)
			. += "<span class='userdanger'>OUTLAW!</span>"
		if(mind && mind.special_role)
		else
			if(mind && mind.special_role == "Bandit")
				. += "<span class='userdanger'>BANDIT!</span>"
			if(mind && mind.special_role == "Vampire Lord")
				. += "<span class='userdanger'>A MONSTER!</span>"

	if(leprosy == 1)
		. += "<span class='userdanger'>A LEPER...</span>"

	if(user != src)
		var/datum/mind/Umind = user.mind
		if(Umind && mind)
			for(var/datum/antagonist/aD in mind.antag_datums)
				for(var/datum/antagonist/bD in Umind.antag_datums)
					var/shit = bD.examine_friendorfoe(aD,user,src)
					if(shit)
						. += shit
		if(user.mind.special_role == "Vampire Lord" || user.mind.special_role == "Vampire Spawn")
			. += "<span class='userdanger'>Blood Volume: [blood_volume]</span>"

	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))

	if(wear_shirt && !(SLOT_SHIRT in obscured))
		. += "[m3] [wear_shirt.get_examine_string(user)]."

	//uniform
	if(wear_pants && !(SLOT_PANTS in obscured))
		//accessory
		var/accessory_msg
		if(istype(wear_pants, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = wear_pants
			if(U.attached_accessory)
				accessory_msg += " with [icon2html(U.attached_accessory, user)] \a [U.attached_accessory]"

		. += "[m3] [wear_pants.get_examine_string(user)][accessory_msg]."

	//head
	if(head && !(SLOT_HEAD in obscured))
		. += "[m3] [head.get_examine_string(user)] on [m2] head."
	//suit/armor
	if(wear_armor && !(SLOT_ARMOR in obscured))
		. += "[m3] [wear_armor.get_examine_string(user)]."
		//suit/armor storage
		if(s_store && !(SLOT_S_STORE in obscured))
			. += "[m1] carrying [s_store.get_examine_string(user)] on [m2] [wear_armor.name]."
	//back
//	if(back)
//		. += "[m3] [back.get_examine_string(user)] on [m2] back."

	if(cloak && !(SLOT_CLOAK in obscured))
		. += "[m3] [cloak.get_examine_string(user)] on [m2] shoulders."

	if(backr && !(SLOT_BACK_R in obscured))
		. += "[m3] [backr.get_examine_string(user)] on [m2] back."

	if(backl && !(SLOT_BACK_L in obscured))
		. += "[m3] [backl.get_examine_string(user)] on [m2] back."

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[m1] holding [I.get_examine_string(user)] in [m2] [get_held_index_name(get_held_index_of_item(I))]."

	var/datum/component/forensics/FR = GetComponent(/datum/component/forensics)
	//gloves
	if(gloves && !(SLOT_GLOVES in obscured))
		. += "[m3] [gloves.get_examine_string(user)] on [m2] hands."
	else if(FR && length(FR.blood_DNA))
		var/hand_number = get_num_arms(FALSE)
		if(hand_number)
			. += "<span class='warning'>[m3] [hand_number > 1 ? "" : "a"] blood-stained hand[hand_number > 1 ? "s" : ""]!</span>"

	//belt
	if(belt && !(SLOT_BELT in obscured))
		. += "[m3] [belt.get_examine_string(user)] about [m2] waist."

	if(beltr && !(SLOT_BELT_R in obscured))
		. += "[m3] [beltr.get_examine_string(user)] on [m2] belt."

	if(beltl && !(SLOT_BELT_L in obscured))
		. += "[m3] [beltl.get_examine_string(user)] on [m2] belt."

	//shoes
	if(shoes && !(SLOT_SHOES in obscured))
		. += "[m3] [shoes.get_examine_string(user)] on [m2] feet."

	//mask
	if(wear_mask && !(SLOT_WEAR_MASK in obscured))
		. += "[m3] [wear_mask.get_examine_string(user)] on [m2] face."

	if(mouth && !(SLOT_MOUTH in obscured))
		. += "[m3] [mouth.get_examine_string(user)] in [m2] mouth."

	if(wear_neck && !(SLOT_NECK in obscured))
		. += "[m3] [wear_neck.get_examine_string(user)] around [m2] neck."

	//eyes
	if(!(SLOT_GLASSES in obscured))
		if(glasses)
			. += "[m3] [glasses.get_examine_string(user)] covering [m2] eyes."
		else if(eye_color == BLOODCULT_EYE && iscultist(src) && HAS_TRAIT(src, CULT_EYES))
			. += "<span class='warning'><B>[m2] eyes are glowing an unnatural red!</B></span>"

	//ears
	if(ears && !(SLOT_HEAD in obscured))
		. += "[m3] [ears.get_examine_string(user)] on [m2] ears."

	//ID
	if(wear_ring && !(SLOT_RING in obscured))
		. += "[m3] [wear_ring.get_examine_string(user)]."

	if(wear_wrists && !(SLOT_WRISTS in obscured))
		. += "[m3] [wear_wrists.get_examine_string(user)]."

	//handcuffed?
	if(handcuffed)
		. += "<A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'><span class='warning'>[m1] tied up with \a [handcuffed]!</span></A>"

	if(legcuffed)
		. += "<A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'><span class='warning'>[m3] \a [legcuffed] around [m2] legs!</span></A>"


	//Status effects
	var/list/status_examines = status_effect_examines()
	if (length(status_examines))
		. += status_examines

	//Jitters
	switch(jitteriness)
		if(300 to INFINITY)
			. += "<span class='warning'><B>[m1] convulsing violently!</B></span>"
		if(200 to 300)
			. += "<span class='warning'>[m1] extremely jittery.</span>"
		if(100 to 200)
			. += "<span class='warning'>[m1] twitching ever so slightly.</span>"

	var/appears_dead = 0
	if(stat == DEAD || (HAS_TRAIT(src, TRAIT_FAKEDEATH)))
		appears_dead = 1
		if(suiciding)
			. += "<span class='warning'>[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>"
		if(hellbound)
			. += "<span class='warning'>[capitalize(m2)] soul seems to have been ripped out of [m2] body. Revival is impossible.</span>"
		. += ""
//		if(getorgan(/obj/item/organ/brain) && !key && !get_ghost(FALSE, TRUE))
//			. += "<span class='deadsay'>[m1] limp and unresponsive; there are no signs of life and [m2] soul has departed...</span>"
//		else
//			. += "<span class='deadsay'>[m1] limp and unresponsive; there are no signs of life...</span>"

	var/list/msg = list()

	var/temp = getBruteLoss() + getFireLoss() //no need to calculate each of these twice

	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if (temp < 25)
				msg += "[m1] a little wounded.\n"
			else if (temp < 50)
				msg += "[m1] wounded.\n"
			else
				msg += "[m1] gravely wounded.\n"

	if(fire_stacks > 0)
		msg += "[m1] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"


	var/list/missing = get_missing_limbs()
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			msg += "<B>[capitalize(m2)] [parse_zone(t)] is gone.</B>\n"
			continue
		msg += "<B>[capitalize(m2)] [parse_zone(t)] is gone.</B>\n"

	if(pulledby && pulledby.grab_state)
		msg += "[m1] being grabbed by [pulledby].\n"

	if(nutrition < (NUTRITION_LEVEL_STARVING - 50))
		msg += "[m1] looking very hungry.\n"
//	else if(nutrition >= NUTRITION_LEVEL_FAT)
//		if(user.nutrition < NUTRITION_LEVEL_STARVING - 50)
//			msg += "[t_He] [t_is] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"
//		else
//			msg += "[t_He] [t_is] quite chubby.\n"
	switch(disgust)
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			msg += "[t_He] look[p_s()] a bit disgusted.\n"
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			msg += "[t_He] look[p_s()] really disgusted.\n"
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			msg += "[t_He] look[p_s()] extremely disgusted.\n"

	if(blood_volume < BLOOD_VOLUME_SAFE || skin_tone == "albino")
		msg += "[m3] pale skin.\n"

	if(eyesclosed)
		msg += "[m2] eyes are closed.\n"

	if(bleed_rate)
		msg += "<B>[m1] bleeding!</B>\n"

	if(has_status_effect(/datum/status_effect/debuff/sleepytime))
		msg += "[m1] looking a little tired.\n"

	if(!obscure_name)
		if(HAS_TRAIT(user, RTRAIT_EMPATH))
			switch(stress)
				if(20 to INFINITY)
					msg += "[m1] extremely stressed.\n"
				if(10 to 19)
					msg += "[m1] very stressed.\n"
				if(1 to 9)
					msg += "[m1] a little stressed.\n"
				if(0 to -9)
					msg += "[m1] not stressed.\n"
				if(-10 to -19)
					msg += "[m1] somewhat at peace.\n"
				if(-20 to INFINITY)
					msg += "[m1] at peace inside.\n"
		else
			if(stress > 10)
				msg += "[m3] stress all over [m2] face.\n"

	if(islist(stun_absorption))
		for(var/i in stun_absorption)
			if(stun_absorption[i]["end_time"] > world.time && stun_absorption[i]["examine_message"])
				msg += "[m1][stun_absorption[i]["examine_message"]]\n"

	if(!appears_dead)
		if(drunkenness && !skipface) //Drunkenness
			switch(drunkenness)
				if(11 to 21)
					msg += "[m1] slightly flushed.\n"
				if(21.01 to 41) //.01s are used in case drunkenness ends up to be a small decimal
					msg += "[m1] flushed.\n"
				if(41.01 to 51)
					msg += "[m1] quite flushed and [m2] breath smells of alcohol.\n"
				if(51.01 to 61)
					msg += "[m1] very flushed, with breath reeking of alcohol.\n"
				if(61.01 to 91)
					msg += "[t_He] look[p_s()] like a drunken mess.\n"
				if(91.01 to INFINITY)
					msg += "[m1] a shitfaced, slobbering wreck.\n"

			msg += ""

		if(InCritical())
			. += "[m1] barely conscious.</span>"
		else
			if(stat == UNCONSCIOUS)
				. += "<span class='warning'>[m1] unconscious.</span>"

	else
		. += "<span class='warning'>[m1] unconscious.</span>"
//		else
//			if(HAS_TRAIT(src, TRAIT_DUMB))
//				msg += "[m3] a stupid expression on [m2] face.\n"
//			if(InCritical())
//				msg += "[m1] barely conscious.\n"
//		if(getorgan(/obj/item/organ/brain))
//			if(!key)
//				msg += "<span class='deadsay'>[m1] totally catatonic. The stresses of life in deep-space must have been too much for [t_him]. Any recovery is unlikely.</span>\n"
//			else if(!client)
//				msg += "[m3] a blank, absent-minded stare and appears completely unresponsive to anything. [t_He] may snap out of it soon.\n"

	if (length(msg))
		. += "<span class='warning'>[msg.Join("")]</span>"

	if(isliving(user))
		var/mob/living/L = user
		if((STASTR - L.STASTR) > 1)
			if((STASTR - L.STASTR) > 6)
				. += "<span class='warning'><B>[t_He] look[p_s()] much stronger than I.</B></span>"
			else
				. += "<span class='warning'>[t_He] look[p_s()] stronger than I.</span>"
		if((L.STASTR - STASTR) > 1)
			if((L.STASTR - STASTR) > 6)
				. += "<span class='warning'><B>[t_He] look[p_s()] much weaker.</B></span>"
			else
				. += "<span class='warning'>[t_He] look[p_s()] weaker.</span>"

	if(Adjacent(user))
		. += "<a href='?src=[REF(src)];inspect_limb=1'>Inspect [parse_zone(check_zone(user.zone_selected))]</a>"

		if(lying && user != src)
			if(user.zone_selected == "chest")
				if(!wear_armor)
					. += "<a href='?src=[REF(src)];check_hb=1'>Listen to Heartbeat</a>"

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/traitstring = get_trait_string()

	var/perpname = get_face_name(get_id_name(""))
	if(perpname && (HAS_TRAIT(user, TRAIT_SECURITY_HUD) || HAS_TRAIT(user, TRAIT_MEDICAL_HUD)))
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.general)
		if(R)
			. += "<span class='deptradio'>Rank:</span> [R.fields["rank"]]\n<a href='?src=[REF(src)];hud=1;photo_front=1'>\[Front photo\]</a><a href='?src=[REF(src)];hud=1;photo_side=1'>\[Side photo\]</a>"
		if(HAS_TRAIT(user, TRAIT_MEDICAL_HUD))
			var/cyberimp_detect
			for(var/obj/item/organ/cyberimp/CI in internal_organs)
				if(CI.status == ORGAN_ROBOTIC && !CI.syndicate_implant)
					cyberimp_detect += "[name] is modified with a [CI.name]."
			if(cyberimp_detect)
				. += "Detected cybernetic modifications:"
				. += cyberimp_detect
			if(R)
				var/health_r = R.fields["p_stat"]
				. += "<a href='?src=[REF(src)];hud=m;p_stat=1'>\[[health_r]\]</a>"
				health_r = R.fields["m_stat"]
				. += "<a href='?src=[REF(src)];hud=m;m_stat=1'>\[[health_r]\]</a>"
			R = find_record("name", perpname, GLOB.data_core.medical)
			if(R)
				. += "<a href='?src=[REF(src)];hud=m;evaluation=1'>\[Medical evaluation\]</a><br>"
			if(traitstring)
				. += "<span class='info'>Detected physiological traits:\n[traitstring]"

		if(HAS_TRAIT(user, TRAIT_SECURITY_HUD))
			if(!user.stat && user != src)
			//|| !user.canmove || user.restrained()) Fluff: Sechuds have eye-tracking technology and sets 'arrest' to people that the wearer looks and blinks at.
				var/criminal = "None"

				R = find_record("name", perpname, GLOB.data_core.security)
				if(R)
					criminal = R.fields["criminal"]

				. += "<span class='deptradio'>Criminal status:</span> <a href='?src=[REF(src)];hud=s;status=1'>\[[criminal]\]</a>"
				. += jointext(list("<span class='deptradio'>Security record:</span> <a href='?src=[REF(src)];hud=s;view=1'>\[View\]</a>",
					"<a href='?src=[REF(src)];hud=s;add_crime=1'>\[Add crime\]</a>",
					"<a href='?src=[REF(src)];hud=s;view_comment=1'>\[View comment log\]</a>",
					"<a href='?src=[REF(src)];hud=s;add_comment=1'>\[Add comment\]</a>"), "")
//	else if(isobserver(user) && traitstring)
//		. += "<span class='info'><b>Traits:</b> [traitstring]</span>"
	. += "ø ------------ ø</span>"

/mob/living/proc/status_effect_examines(pronoun_replacement) //You can include this in any mob's examine() to show the examine texts of status effects!
	var/list/dat = list()
	if(!pronoun_replacement)
		pronoun_replacement = p_they(TRUE)
	for(var/V in status_effects)
		var/datum/status_effect/E = V
		if(E.examine_text)
			var/new_text = replacetext(E.examine_text, "SUBJECTPRONOUN", pronoun_replacement)
			new_text = replacetext(new_text, "[pronoun_replacement] is", "[pronoun_replacement] [p_are()]") //To make sure something become "They are" or "She is", not "They are" and "She are"
			dat += "[new_text]\n" //dat.Join("\n") doesn't work here, for some reason
	if(dat.len)
		return dat.Join()
