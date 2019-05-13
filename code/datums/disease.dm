
/*

IMPORTANT NOTE: Please delete the diseases by using cure() proc or del() instruction.
Diseases are referenced in a global list, so simply setting mob or obj vars
to null does not delete the object itself. Thank you.

*/

var/list/diseases = subtypesof(/datum/disease)


/datum/disease
	var/form = "Virus" //During medscans, what the disease is referred to as
	var/name = "No disease"
	var/stage = 1 //all diseases start at stage 1
	var/max_stages = 0.0
	var/cure = null
	var/cure_id = null// reagent.id or list containing them
	var/cure_list = null // allows for multiple possible cure combinations
	var/cure_chance = 8//chance for the cure to do its job
	var/spread = null //spread type description
	var/initial_spread = null
	var/spread_type = AIRBORNE
	var/contagious_period = 0//the disease stage when it can be spread
	var/list/affected_species = list()
	var/mob/living/carbon/affected_mob = null //the mob which is affected by disease.
	var/holder = null //the atom containing the disease (mob or obj)
	var/carrier = 0.0 //there will be a small chance that the person will be a carrier
	var/curable = 0 //can this disease be cured? (By itself...)
	var/list/strain_data = list() //This is passed on to infectees
	var/stage_prob = 4		// probability of advancing to next stage, default 4% per check
	var/agent = "some microbes"//name of the disease agent
	var/permeability_mod = 1//permeability modifier coefficient.
	var/desc = null//description. Leave it null and this disease won't show in med records.
	var/severity = null//severity descr
	var/longevity = 150//time in "ticks" the virus stays in inanimate object (blood stains, corpses, etc). In syringes, bottles and beakers it stays infinitely.
	var/list/hidden = list(0, 0)
	// if hidden[1] is true, then virus is hidden from medical scanners
	// if hidden[2] is true, then virus is hidden from PANDEMIC machine
	var/can_carry = 1 // If the disease allows "carriers".
	var/age = 0 // age of the disease in the current mob
	var/stage_minimum_age = 0 // how old the disease must be to advance per stage
	var/survive_mob_death = FALSE //whether the virus continues processing as normal when the affected mob is dead.


/datum/disease/proc/stage_act()
	age++
	var/cure_present = has_cure()
	//to_chat(world, "[cure_present]")

	if(carrier&&!cure_present)
		//to_chat(world, "[affected_mob] is carrier")
		return

	spread = (cure_present?"Remissive":initial_spread)
	if(stage > max_stages)
		stage = max_stages

	if(!cure_present && prob(stage_prob) && age > stage_minimum_age) //now the disease shouldn't get back up to stage 4 in no time
		stage = min(stage + 1, max_stages)
		age = 0

	else if(cure_present && prob(cure_chance))
		stage = max(stage - 1, 1)

	if(stage <= 1 && ((prob(1) && curable) || (cure_present && prob(cure_chance))))
		cure()
		return
	return

/datum/disease/proc/has_cure()//check if affected_mob has required reagents.
	if(!cure_id) return 0
	var/result = 1
	if(cure_list == list(cure_id))
		if(istype(cure_id, /list))
			for(var/C_id in cure_id)
				if(!affected_mob.reagents.has_reagent(C_id))
					result = 0
					break
		else if(!affected_mob.reagents.has_reagent(cure_id))
			result = 0
	else
		for(var/C_list in cure_list)
			if(istype(C_list, /list))
				for(var/C_id in cure_id)
					if(!affected_mob.reagents.has_reagent(C_id))
						result = 0
						break
			else if(!affected_mob.reagents.has_reagent(C_list))
				result = 0

	return result

/datum/disease/proc/spread_by_touch()
	switch(spread_type)
		if(CONTACT_FEET, CONTACT_HANDS, CONTACT_GENERAL)
			return 1
	return 0

/datum/disease/proc/spread(var/atom/source=null, var/airborne_range = 2,  var/force_spread)
	//to_chat(world, "Disease [src] proc spread was called from holder [source]")

	// If we're overriding how we spread, say so here
	var/how_spread = spread_type
	if(force_spread)
		how_spread = force_spread

	if(how_spread == SPECIAL || how_spread == NON_CONTAGIOUS || how_spread == BLOOD)//does not spread
		return

	if(stage < contagious_period) //the disease is not contagious at this stage
		return

	if(!source)//no holder specified
		if(affected_mob)//no mob affected holder
			source = affected_mob
		else //no source and no mob affected. Rogue disease. Break
			return

	if(affected_mob && affected_mob.reagents)
		if(affected_mob.reagents.has_reagent("spaceacillin"))
			return // Don't spread if we have spaceacillin in our system.

	var/check_range = airborne_range//defaults to airborne - range 2

	if(how_spread != AIRBORNE && how_spread != SPECIAL)
		check_range = 1 // everything else, like infect-on-contact things, only infect things on top of it

	if(isturf(source.loc))
		for(var/mob/living/carbon/M in oview(check_range, source))
			if(isturf(M.loc))
				if(AStar(source.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, check_range))
					M.contract_disease(src, 0, 1, force_spread)

	return


/datum/disease/process()
	if(!holder)
		active_diseases -= src
		return
	if(prob(65))
		spread(holder)

	if(affected_mob)
		for(var/datum/disease/D in affected_mob.viruses)
			if(D != src)
				if(IsSame(D))
					//error("Deleting [D.name] because it's the same as [src.name].")
					qdel(D) // if there are somehow two viruses of the same kind in the system, delete the other one

	if(holder == affected_mob)
		if(affected_mob.stat != DEAD || survive_mob_death) //he's alive or disease transcends death.
			stage_act()
		else //he's dead.
			if(spread_type!=SPECIAL)
				spread_type = CONTACT_GENERAL
			affected_mob = null
	if(!affected_mob) //the virus is in inanimate obj
//		to_chat(world, "[src] longevity = [longevity]")

		if(prob(70))
			if(--longevity<=0)
				cure(0)
	return

/datum/disease/proc/cure(var/resistance=1)//if resistance = 0, the mob won't develop resistance to disease
	if(affected_mob)
		if(resistance && !(type in affected_mob.resistances))
			var/saved_type = "[type]"
			affected_mob.resistances += text2path(saved_type)
		remove_virus()
	qdel(src)	//delete the datum to stop it processing
	return


//unsafe proc, call cure() instead
/datum/disease/proc/remove_virus()
	affected_mob.viruses -= src
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		H.med_hud_set_status()



/datum/disease/New(process=1, datum/disease/D)//process = 1 - adding the object to global list. List is processed by master controller.
	cure_list = list(cure_id) // to add more cures, add more vars to this list in the actual disease's New()
	if(process)				 // Viruses in list are considered active.
		active_diseases += src
	initial_spread = spread

/datum/disease/proc/IsSame(var/datum/disease/D)
	if(istype(src, D.type))
		return 1
	return 0

/datum/disease/proc/Copy(var/process = 0)
	return new type(process, src)


/datum/disease/Destroy()
	affected_mob = null
	holder = null
	active_diseases -= src
	return ..()


/mob/living/carbon/proc/has_disease(var/datum/disease/virus)
	for(var/datum/disease/D in viruses)
		if(D.IsSame(virus))
			return TRUE
	return FALSE


/mob/living/carbon/proc/contract_disease(datum/disease/virus, skip_this = FALSE, force_species_check = TRUE, spread_type = -5)
	if(species.species_flags & IS_SYNTHETIC)
		return //synthetic species are immune
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
		if(resistances.Find(virus.type))
			//to_chat(world, "Normal virus and resisted")
			return

	if(has_disease(virus))
		return

	if(force_species_check)
		var/fail = TRUE
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			for(var/vuln_species in virus.affected_species)
				if(H.species.name == vuln_species)
					fail = FALSE
					break
		if(fail)
			return

	if(skip_this == TRUE)
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

	if(prob(15/virus.permeability_mod))
		return //the power of immunity compels this disease! but then you forgot resistances
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


/mob/living/carbon/proc/AddDisease(datum/disease/D)
	var/datum/disease/DD = new D.type(1, D)
	viruses += DD
	DD.affected_mob = src
	DD.strain_data = DD.strain_data.Copy()
	DD.holder = src
	if(DD.can_carry && prob(5))
		DD.carrier = 1
	med_hud_set_status()
	

//returns whether the mob's clothes stopped the disease from passing through
/mob/proc/check_disease_pass_clothes(target_zone)
	return TRUE


/mob/living/carbon/monkey/check_disease_pass_clothes(target_zone)
	if(target_zone == 1 && wear_mask)
		return prob((wear_mask.permeability_coefficient*100) - 1)


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
			if(. && isobj(SLOT_W_UNIFORM))
				Cl = SLOT_W_UNIFORM
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
			stack_trace("Something bad happened with disease target zone code.")