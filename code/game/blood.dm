




//to add a mob's dna info into an object's blood_DNA list.
/atom/proc/transfer_mob_blood_dna(mob/living/L)
	// Returns 0 if we have that blood already
	var/new_blood_dna = L.get_blood_dna_list()
	if(!new_blood_dna)
		return 0
	if(!blood_DNA)	//if our list of DNA doesn't exist yet, initialise it.
		blood_DNA = list()
	var/old_length = blood_DNA.len
	blood_DNA |= new_blood_dna
	if(blood_DNA.len == old_length)
		return 0
	return 1

//to add blood dna info to the object's blood_DNA list
/atom/proc/transfer_blood_dna(list/blood_dna)
	if(!blood_DNA)
		blood_DNA = list()

	var/old_length = blood_DNA.len
	blood_DNA |= blood_dna
	if(blood_DNA.len > old_length)
		return 1//some new blood DNA was added


//to add blood from a mob onto something, and transfer their dna info and blood color
/atom/proc/add_mob_blood(mob/living/M)
	var/list/blood_dna = M.get_blood_dna_list()
	if(!blood_dna)
		return 0
	var/b_color = M.get_blood_color()

	return add_blood(blood_dna, b_color)




/////// add_blood ///////////////////

//to add blood onto something, with blood dna info to include.
/atom/proc/add_blood(list/blood_dna, b_color)
	return 0


/turf/add_blood(list/blood_dna, b_color)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src)
		if(b_color)
			B.basecolor = b_color
			B.color = b_color
	B.transfer_blood_dna(blood_dna) //give blood info to the blood decal.
	return 1 //we bloodied the floor


/obj/add_blood(list/blood_dna, b_color)
	if(flags_atom & NOBLOODY)
		return 0
	. = transfer_blood_dna(blood_dna)
	if(b_color)
		blood_color = b_color


/obj/item/add_blood(list/blood_dna, b_color)
	if(flags_atom & NOBLOODY)
		return 0
	var/blood_count = blood_DNA && blood_DNA.len
	..()
	if(!blood_count && !blood_overlay)//apply the blood-splatter overlay if it isn't already in there
		generate_blood_overlay()

	else if(blood_overlay && b_color && blood_overlay.color != b_color)
		overlays -= blood_overlay
		blood_overlay.color = b_color
		overlays += blood_overlay
	return 1 //we applied blood to the item


/obj/item/proc/generate_blood_overlay()
	if(!blood_overlay)
		var/icon/I = new /icon(icon, icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		blood_overlay = image(I)

		blood_overlay.color = blood_color
		overlays += blood_overlay




/mob/living/carbon/human/add_blood(list/blood_dna, b_color)
	if(wear_suit)
		wear_suit.add_blood(blood_dna, b_color)
		update_inv_wear_suit()
	else if(w_uniform)
		w_uniform.add_blood(blood_dna, b_color)
		update_inv_w_uniform()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood(blood_dna, b_color)
	else
		transfer_blood_dna(blood_dna)
		if(b_color)
			blood_color = b_color
	bloody_hands = rand(2, 4)

	update_inv_gloves()	//handles bloody hands overlays and updating
	return 1






/atom/proc/clean_blood()
	germ_level = 0
	if(istype(blood_DNA, /list))
		cdel(blood_DNA)
		blood_DNA = null
		blood_color = null
		return 1

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)


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
		if(istype(blood_DNA, /list))
			cdel(blood_DNA)
			blood_DNA = null
		blood_color = null
		bloody_hands = 0
		update_inv_gloves()

	if(clean_feet && !shoes && istype(feet_blood_DNA, /list))
		feet_blood_color = null
		cdel(feet_blood_DNA)
		feet_blood_DNA = null
		update_inv_shoes()
		return 1




