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
		if(!(status_flags & GODMODE))
			adjustToxLoss(total_phoronloss)

	if(status_flags & GODMODE)
		return 0 //Godmode

	if(dna && dna.mutantrace == "shadow")
		var/light_amount = 0
		if(isturf(loc))
			var/turf/T = loc
			var/area/A = T.loc
			if(A)
				if(A.lighting_use_dynamic)
					light_amount = T.lighting_lumcount
				else
					light_amount =  10
		if(light_amount > 2) //If there's enough light, start dying
			take_overall_damage(1, 1)
		else if(light_amount < 2) //Heal in the dark
			heal_overall_damage(1, 1)

	if(!(species.flags & IS_SYNTHETIC))
		//Nutrition decrease
		if(nutrition > 0 && stat != 2)
			nutrition = max (0, nutrition - HUNGER_FACTOR)

		if(nutrition > 450)
			if(overeatduration < 600) //Capped so people don't take forever to unfat
				overeatduration++
		else
			if(overeatduration > 1)
				overeatduration -= 2 //Doubled the unfat rate

		handle_trace_chems()

	else nutrition = 350 //synthetics are never hungry

	updatehealth()

	return //TODO: DEFERRED
