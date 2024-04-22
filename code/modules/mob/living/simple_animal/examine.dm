/mob/living/simple_animal/examine(mob/user)
	var/t_He = p_they(TRUE)
	var/t_his = p_their()
	var/t_has = p_have()
	var/t_is = p_are()

	. = list("<span class='info'>✠ ------------ ✠\nThis is \a <EM>[src]</EM>!")

	var/m1 = "[t_He] [t_is]"
	var/m2 = "[t_his]"
	var/m3 = "[t_He] [t_has]"
	if(user == src)
		m1 = "I am"
		m2 = "my"
		m3 = "I have"

	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[m1] holding [I.get_examine_string(user)] in [m2] [get_held_index_name(get_held_index_of_item(I))]."

	var/list/msg = list("<span class='warning'>")

	var/temp = getBruteLoss()
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

	if(fire_stacks > 0)
		msg += "[t_He] [t_is] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[t_He] look[p_s()] a little soaked.\n"

	if(pulledby && pulledby.grab_state)
		msg += "[m1] restrained by [pulledby]'s grip.\n"

	msg += "</span>"

	. += msg.Join("")

	if(stat == UNCONSCIOUS)
		. += "[m1] unconscious."
	if(stat == DEAD)
		. += "[m1] unconscious."

	if(isliving(user))
		var/mob/living/L = user
		if(STASTR > L.STASTR)
			if(STASTR >= 15)
				. += "<span class='warning'><B>[t_He] look[p_s()] stronger than I.</B></span>"
			else
				. += "<span class='warning'>[t_He] look[p_s()] stronger than I.</span>"

	if(food_type && food_type.len)
		if(food < 50)
			. += "<span class='warning'>[t_He] look[p_s()] a little hungry.</span>"
		else if(food <= 0)
			. += "<span class='warning'>[t_He] look[p_s()] starved.</span>"

	if(Adjacent(user) && HAS_TRAIT(src, TRAIT_SIMPLE_WOUNDS))
		. += "<a href='?src=[REF(src)];inspect_animal=1'>Inspect Wounds</a>"

	. += "✠ ------------ ✠</span>"