/datum/examine_effect/proc/trigger(mob/user)
	return

/datum/examine_effect/proc/get_examine_line(mob/user)
	return

/obj/item/examine(mob/user) //This might be spammy. Remove?
	. = ..()

	if(max_integrity)
		if(obj_integrity < max_integrity)
			var/meme = round(((obj_integrity / max_integrity) * 100), 1)
			switch(meme)
				if(0 to 10)
					. += "<span class='warning'>It's nearly broken.</span>"
				if(10 to 30)
					. += "<span class='warning'>It's severely damaged.</span>"
				if(30 to 80)
					. += "<span class='warning'>It's damaged.</span>"
				if(80 to 99)
					. += "<span class='warning'>It's a little damaged.</span>"

//	if(has_inspect_verb || (obj_integrity < max_integrity))
//		. += "<span class='notice'><a href='?src=[REF(src)];inspect=1'>Inspect</a></span>"

	if(get_real_price() > 0 && (HAS_TRAIT(user, RTRAIT_SEEPRICES) || simpleton_price))
		. += "<span class='info'>Value: [get_real_price()] mammon</span>"

//	. += "[gender == PLURAL ? "They are" : "It is"] a [weightclass2text(w_class)] item."

/*	if(resistance_flags & INDESTRUCTIBLE)
		. += "[src] seems extremely robust! It'll probably withstand anything that could happen to it!"
	else
		if(resistance_flags & LAVA_PROOF)
			. += "[src] is made of an extremely heat-resistant material, it'd probably be able to withstand lava!"
		if(resistance_flags & (ACID_PROOF | UNACIDABLE))
			. += "[src] looks pretty robust! It'd probably be able to withstand acid!"
		if(resistance_flags & FREEZE_PROOF)
			. += "[src] is made of cold-resistant materials."
		if(resistance_flags & FIRE_PROOF)
			. += "[src] is made of fire-retardant materials."
*/

	for(var/datum/examine_effect/E in examine_effects)
		E.trigger(user)
