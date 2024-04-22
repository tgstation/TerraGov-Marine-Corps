/mob/living/carbon/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_his = p_their()
	var/t_has = p_have()
	var/t_is = p_are()

	. = list("<span class='info'>✠ ------------ ✠\nThis is \a <EM>[src]</EM>!")
	var/list/obscured = check_obscured_slots()

	var/m1 = "[t_He] [t_is]"
	var/m2 = "[t_his]"
	var/m3 = "[t_He] [t_has]"
	if(user == src)
		m1 = "I am"
		m2 = "my"
		m3 = "I have"

	if (handcuffed)
		. += "<span class='warning'>[m1] tied up with \a [handcuffed]!</span>"
	if (head)
		. += "[m3] [head.get_examine_string(user)] on [m2] head. "
	if(wear_mask && !(SLOT_WEAR_MASK in obscured))
		. += "[m3] [wear_mask.get_examine_string(user)] on [m2] face."
	if(wear_neck && !(SLOT_NECK in obscured))
		. += "[m3] [wear_neck.get_examine_string(user)] around [m2] neck."

	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[m1] holding [I.get_examine_string(user)] in [m2] [get_held_index_name(get_held_index_of_item(I))]."

	if (back)
		. += "[m3] [back.get_examine_string(user)] on [m2] back."
	var/appears_dead = 0
/*	if (stat == DEAD)
		appears_dead = 1
		if(getorgan(/obj/item/organ/brain))
			. += "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>"
		else if(get_bodypart(BODY_ZONE_HEAD))
			. += "<span class='deadsay'>It appears that [t_his] brain is missing...</span>"*/

	var/list/missing = get_missing_limbs()
	for(var/t in missing)
		if(t==BODY_ZONE_HEAD)
			. += "<span class='deadsay'><B>[capitalize(m2)] [parse_zone(t)] is gone.</B></span>"
			continue
		. += "<span class='warning'><B>[capitalize(m2)] [parse_zone(t)] is gone.</B></span>"

	var/list/msg = list("<span class='warning'>")
	var/temp = getBruteLoss()
	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		if(temp)
			if (temp < 25)
				msg += "[m3] some bruises.\n"
			else if (temp < 50)
				msg += "[m3] a lot of bruises!\n"
			else
				msg += "<B>[m1] black and blue!!</B>\n"

		temp = getFireLoss()
		if(temp)
			if (temp < 25)
				msg += "[m3] some burns.\n"
			else if (temp < 50)
				msg += "[m3] many burns!\n"
			else
				msg += "<B>[m1] dragon food!!</B>\n"

		temp = getCloneLoss()
		if(temp)
			if(temp < 25)
				msg += "[t_He] [t_is] slightly deformed.\n"
			else if (temp < 50)
				msg += "[t_He] [t_is] <b>moderately</b> deformed!\n"
			else
				msg += "<b>[t_He] [t_is] severely deformed!</b>\n"

	if(HAS_TRAIT(src, TRAIT_DUMB))
		msg += "[t_He] seem[p_s()] to be clumsy and unable to think.\n"

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"

	if(pulledby && pulledby.grab_state)
		msg += "[m1] restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	. += msg.Join("")

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			. += "<span class='warning'>[m1] unconscious.</span>"
		else if(InCritical())
			. += "<span class='warning'>[m1] barely conscious.</span>"
	if (stat == DEAD)
		appears_dead = 1
		. += "<span class='warning'>[m1] unconscious.</span>"
	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	if(isliving(user))
		var/mob/living/L = user
		if(STASTR > L.STASTR)
			if(STASTR > 15)
				. += "<span class='warning'>[t_He] look[p_s()] stronger than I.</span>"
			else
				. += "<span class='warning'><B>[t_He] look[p_s()] stronger than I.</B></span>"

	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		switch(mood.shown_mood)
			if(-INFINITY to MOOD_LEVEL_SAD4)
				. += "[t_He] look[p_s()] depressed."
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				. += "[t_He] look[p_s()] very sad."
			if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
				. += "[t_He] look[p_s()] a bit down."
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				. += "[t_He] look[p_s()] quite happy."
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				. += "[t_He] look[p_s()] very happy."
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				. += "[t_He] look[p_s()] ecstatic."
	. += "✠ ------------ ✠</span>"
