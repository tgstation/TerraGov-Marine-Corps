//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_mutations_and_radiation()

	if(species.flags & IS_SYNTHETIC) //Robots don't suffer from mutations or radloss.
		return

	if(getFireLoss())
		if((COLD_RESISTANCE in mutations) || (prob(1)))
			heal_limb_damage(0, 1)

	//DNA2 - Gene processing.
	//The HULK stuff that was here is now in the hulk gene.
	for(var/datum/dna/gene/gene in dna_genes)
		if(!gene.block)
			continue
		if(gene.is_active(src))
			speech_problem_flag = 1
			gene.OnMobLife(src)

	radiation = CLAMP(radiation,0,100)

	if(radiation)

		var/damage = 0
		radiation -= 1 * RADIATION_SPEED_COEFFICIENT
		if(prob(25))
			damage = 1

		if(radiation > 50)
			damage = 1
			radiation -= 1 * RADIATION_SPEED_COEFFICIENT
			if(prob(5) && prob(100 * RADIATION_SPEED_COEFFICIENT))
				radiation -= 5 * RADIATION_SPEED_COEFFICIENT
				to_chat(src, "<span class='warning'>You feel weak.</span>")
				KnockDown(3)
				if(!lying)
					emote("collapse")
			if(prob(5) && prob(100 * RADIATION_SPEED_COEFFICIENT) && species.name == "Human") //Apes go bald
				if((h_style != "Bald" || f_style != "Shaved"))
					to_chat(src, "<span class='warning'>Your hair falls out.</span>")
					h_style = "Bald"
					f_style = "Shaved"
					update_hair()

		if(radiation > 75)
			radiation -= 1 * RADIATION_SPEED_COEFFICIENT
			damage = 3
			if(prob(5))
				take_overall_damage(0, 5 * RADIATION_SPEED_COEFFICIENT, used_weapon = "Radiation Burns")
			if(prob(1))
				to_chat(src, "<span class='warning'>You feel strange!</span>")
				adjustCloneLoss(5 * RADIATION_SPEED_COEFFICIENT)
				emote("gasp")

		if(damage)
			adjustToxLoss(damage * RADIATION_SPEED_COEFFICIENT)
			//updatehealth() moved to Life()
			if(limbs.len)
				var/datum/limb/O = pick(limbs)
				O.add_autopsy_data("Radiation Poisoning", damage)
