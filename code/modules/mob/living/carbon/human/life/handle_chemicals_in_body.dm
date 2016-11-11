//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_chemicals_in_body()

	if(reagents && !(species.flags & IS_SYNTHETIC)) //Synths don't process reagents.
		var/alien = 0
		if(species && species.reagent_tag)
			alien = species.reagent_tag
		reagents.metabolize(src,alien)

		var/total_phoronloss = 0
		for(var/obj/item/I in src)
			if(I.contaminated)
				total_phoronloss += vsc.plc.CONTAMINATION_LOSS
		if(!(status_flags & GODMODE)) adjustToxLoss(total_phoronloss)

	if(status_flags & GODMODE)	return 0	//godmode

	var/datum/organ/internal/diona/node/light_organ = locate() in internal_organs
	if(light_organ && !light_organ.is_broken())
		var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
		if(isturf(loc)) //else, there's considered to be no light
			var/turf/T = loc
			var/area/A = T.loc
			if(A)
				if(A.lighting_use_dynamic)	light_amount = min(10,T.lighting_lumcount) - 5 //hardcapped so it's not abused by having a ton of flashlights
				else						light_amount =  5
		nutrition += light_amount
		traumatic_shock -= light_amount

		if(species.flags & IS_PLANT)
			if(nutrition > 500)
				nutrition = 500
			if(light_amount >= 3) //if there's enough light, heal
				adjustBruteLoss(-(light_amount))
				adjustToxLoss(-(light_amount))
				adjustOxyLoss(-(light_amount))
				//TODO: heal wounds, heal broken limbs.

	if(dna && dna.mutantrace == "shadow")
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			var/area/A = T.loc
			if(A)
				if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
				else						light_amount =  10
		if(light_amount > 2) //if there's enough light, start dying
			take_overall_damage(1,1)
		else if (light_amount < 2) //heal in the dark
			heal_overall_damage(1,1)

	// nutrition decrease
	if (nutrition > 0 && stat != 2)
		nutrition = max (0, nutrition - HUNGER_FACTOR)

	if (nutrition > 450)
		if(overeatduration < 600) //capped so people don't take forever to unfat
			overeatduration++
	else
		if(overeatduration > 1)
			overeatduration -= 2 //doubled the unfat rate

	if(species.flags & IS_PLANT && (!light_organ || light_organ.is_broken()))
		if(nutrition < 200)
			take_overall_damage(2,0)
			traumatic_shock++

	if(!(species.flags & IS_SYNTHETIC)) handle_trace_chems()
	updatehealth()

	return //TODO: DEFERRED
