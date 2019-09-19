

//to add blood from a mob onto something, and transfer their dna info and blood color
/atom/proc/add_mob_blood(mob/living/M)
	var/b_color = M.get_blood_color()

	return add_blood(b_color)




/////// add_blood ///////////////////

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(b_color)
	return FALSE


/turf/add_blood(b_color)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
		if(b_color)
			B.basecolor = b_color
			B.color = b_color
	return TRUE //we bloodied the floor


/obj/add_blood(b_color)
	if(flags_atom & NOBLOODY)
		return FALSE
	if(b_color)
		blood_color = b_color
	return TRUE


/obj/item/add_blood(b_color)
	if(!..())
		return FALSE
	if(!blood_overlay)//apply the blood-splatter overlay if it isn't already in there
		generate_blood_overlay()

	else if(blood_overlay && b_color && blood_overlay.color != b_color)
		overlays -= blood_overlay
		blood_overlay.color = b_color
		overlays += blood_overlay
	return TRUE //we applied blood to the item


/obj/item/proc/generate_blood_overlay()
	if(!blood_overlay)
		var/icon/I = new /icon(icon, icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		blood_overlay = image(I)

		blood_overlay.color = blood_color
		overlays += blood_overlay




/mob/living/carbon/human/add_blood(b_color)
	if(wear_suit)
		wear_suit.add_blood(b_color)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood(b_color)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(b_color)
	else
		if(b_color)
			blood_color = b_color
	bloody_hands = rand(2, 4)

	update_inv_gloves()	//handles bloody hands overlays and updating
	return TRUE






/atom/proc/clean_blood()
	germ_level = 0
	blood_color = null
	return 1

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
		blood_overlay = null


/obj/item/clothing/gloves/clean_blood()
	. = ..()
	transfer_blood = 0

/mob/living/carbon/human/clean_blood(clean_feet)
	germ_level = 0
	if(gloves)
		if(gloves.clean_blood())
			update_inv_gloves()
		gloves.germ_level = 0
	else
		blood_color = null
		bloody_hands = 0
		update_inv_gloves()

	if(clean_feet && !shoes)
		feet_blood_color = null
		update_inv_shoes()
		return TRUE




