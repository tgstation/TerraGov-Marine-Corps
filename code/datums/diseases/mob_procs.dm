
/mob/proc/has_disease(var/datum/disease/virus)
	for(var/datum/disease/D in viruses)
		if(D.IsSame(virus))
			//error("[D.name]/[D.type] is the same as [virus.name]/[virus.type]")
			return 1
	return 0

// This proc has some procs that should be extracted from it. I believe we can develop some helper procs from it - Rockdtben
/mob/proc/contract_disease(var/datum/disease/virus, var/skip_this = 0, var/force_species_check=1, var/spread_type = -5)
	//to_chat(world, "Contract_disease called by [src] with virus [virus]")
	if(stat == DEAD)
		//to_chat(world, "He's dead jim.")
		return
	if(istype(virus, /datum/disease/advance))
		//to_chat(world, "It's an advance virus.")
		var/datum/disease/advance/A = virus
		if(A.GetDiseaseID() in resistances)
			//to_chat(world, "It resisted us!")
			return
		if(count_by_type(viruses, /datum/disease/advance) >= 3)
			return

	else
		if(src.resistances.Find(virus.type))
			//to_chat(world, "Normal virus and resisted")
			return

	if(has_disease(virus))
		return

	if(force_species_check)
		var/fail = 1
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			for(var/vuln_species in virus.affected_species)
				if(H.species.name == vuln_species)
					fail = 0
					break
		if(fail) return

	if(skip_this == 1)
		//to_chat(world, "infectin")
		//if(src.virus)				< -- this used to replace the current disease. Not anymore!
			//src.virus.cure(0)
		var/datum/disease/v = new virus.type(1, virus, 0)
		src.viruses += v
		v.affected_mob = src
		v.strain_data = v.strain_data.Copy()
		v.holder = src
		if(v.can_carry && prob(5))
			v.carrier = 1
		return

	if(prob(15/virus.permeability_mod)) return //the power of immunity compels this disease! but then you forgot resistances
	//to_chat(world, "past prob()")
	var/passed = 1

	//chances to target this zone
	var/head_ch
	var/body_ch
	var/hands_ch
	var/feet_ch

	if(spread_type == -5)
		spread_type = virus.spread_type

	switch(spread_type)
		if(CONTACT_HANDS)
			head_ch = 0
			body_ch = 0
			hands_ch = 100
			feet_ch = 0
		if(CONTACT_FEET)
			head_ch = 0
			body_ch = 0
			hands_ch = 0
			feet_ch = 100
		else
			head_ch = 100
			body_ch = 100
			hands_ch = 25
			feet_ch = 25


	var/target_zone = pick(head_ch;1,body_ch;2,hands_ch;3,feet_ch;4)//1 - head, 2 - body, 3 - hands, 4- feet

	passed = check_disease_pass_clothes(target_zone)

	if(!passed && spread_type == AIRBORNE && !internal)
		passed = (prob((50*virus.permeability_mod) - 1))

	if(passed)
		//to_chat(world, "Infection in the mob [src]. YAY")
		AddDisease(virus)




/mob/living/carbon/human/contract_disease(datum/disease/virus, skip_this = 0, force_species_check=1, spread_type = -5)
	if(species.flags & IS_SYNTHETIC) return //synthetic species are immune
	..()



/mob/proc/AddDisease(datum/disease/D)
	var/datum/disease/DD = new D.type(1, D)
	viruses += DD
	DD.affected_mob = src
	DD.strain_data = DD.strain_data.Copy()
	DD.holder = src
	if(DD.can_carry && prob(5))
		DD.carrier = 1


/mob/living/carbon/human/AddDisease(datum/disease/D)
	..()
	med_hud_set_status()

//returns whether the mob's clothes stopped the disease from passing through
/mob/proc/check_disease_pass_clothes(target_zone)
	return 1

/mob/living/carbon/monkey/check_disease_pass_clothes(target_zone)
	switch(target_zone)
		if(1)
			if(wear_mask)
				. = prob((wear_mask.permeability_coefficient*100) - 1)



/mob/living/carbon/human/check_disease_pass_clothes(target_zone)
	var/obj/item/clothing/Cl
	switch(target_zone)
		if(1)
			if(isobj(head) && !istype(head, /obj/item/paper))
				Cl = head
				. = prob((Cl.permeability_coefficient*100) - 1)
			if(. && wear_mask)
				. = prob((Cl.permeability_coefficient*100) - 1)
		if(2)//arms and legs included
			if(isobj(wear_suit))
				Cl = wear_suit
				. = prob((Cl.permeability_coefficient*100) - 1)
			if(. && isobj(WEAR_BODY))
				Cl = WEAR_BODY
				. = prob((Cl.permeability_coefficient*100) - 1)
		if(3)
			if(isobj(wear_suit) && wear_suit.flags_armor_protection&HANDS)
				Cl = wear_suit
				. = prob((Cl.permeability_coefficient*100) - 1)

			if(. && isobj(gloves))
				Cl = gloves
				. = prob((Cl.permeability_coefficient*100) - 1)
		if(4)
			if(isobj(wear_suit) && wear_suit.flags_armor_protection&FEET)
				Cl = wear_suit
				. = prob((Cl.permeability_coefficient*100) - 1)

			if(. && isobj(shoes))
				Cl = shoes
				. = prob((Cl.permeability_coefficient*100) - 1)
		else
			to_chat(src, "Something bad happened with disease target zone code, tell a dev or admin ")

