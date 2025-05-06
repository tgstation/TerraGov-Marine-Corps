

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
	if(atom_flags & NOBLOODY)
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

		if((inhand_x_dimension > 32) || (inhand_y_dimension > 32))
			I.Blend(new /icon('icons/effects/64x64.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
			I.Blend(new /icon('icons/effects/64x64.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		else
			I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
			I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)

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

///Removes blood from our atom
/atom/proc/clean_blood()
	if(blood_color)
		blood_color = null
		return TRUE

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
		blood_overlay = null


/obj/item/clothing/gloves/clean_blood()
	. = ..()
	transfer_blood = 0

/mob/clean_blood()
	. = ..()
	r_hand?.clean_blood()
	l_hand?.clean_blood()
	if(wear_mask?.clean_blood())
		update_inv_wear_mask()

/mob/living/carbon/clean_blood()
	. = ..()
	if(back?.clean_blood())
		update_inv_back()

/mob/living/carbon/human/clean_blood()
	. = ..()
	germ_level = 0

	if(head?.clean_blood())
		update_inv_head()

	if(wear_suit?.clean_blood())
		update_inv_wear_suit()

	if(w_uniform?.clean_blood())
		update_inv_w_uniform()

	if(!gloves?.clean_blood())
		blood_color = null
		bloody_hands = 0
	update_inv_gloves()

	if(!shoes?.clean_blood())
		feet_blood_color = null
	update_inv_shoes()

	if(glasses?.clean_blood())
		update_inv_glasses()

	if(wear_ear?.clean_blood())
		update_inv_ears()

	if(belt?.clean_blood())
		update_inv_belt()

	return TRUE
