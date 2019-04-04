
// Takes care of organ & limb related updates, such as broken and missing limbs
/mob/living/carbon/human/handle_organs()
	. = ..()

	if(reagents && !(species.species_flags & NO_CHEM_METABOLIZATION))
		if(species && species.has_organ["liver"])
			var/datum/internal_organ/liver/L = internal_organs_by_name["liver"]
			var/alien = (species && species.reagent_tag) ? species.reagent_tag : null
			var/overdose = (species.species_flags & NO_OVERDOSE) ? FALSE : TRUE
			if(!(status_flags & GODMODE)) //godmode doesn't work as intended anyway
				if(L)
					reagents.metabolize(src, alien, can_overdose = overdose)
				else
					reagents.metabolize(src, alien, can_overdose = FALSE, liverless=TRUE)

	if(!(species.species_flags & IS_SYNTHETIC))
		//Nutrition decrease
		if(nutrition > 0 && stat != 2)
			nutrition = max (0, nutrition - HUNGER_FACTOR)

		if(nutrition > 450)
			if(overeatduration < 600) //Capped so people don't take forever to unfat
				overeatduration++
		else
			if(overeatduration > 1)
				overeatduration -= 2 //Doubled the unfat rate

	else nutrition = 350 //synthetics are never hungry

	var/leg_tally = 2

	last_dam = getBruteLoss() + getFireLoss() + getToxLoss()
	if(stat != DEAD) //Zombie calling this proc just for the chem.. *sigh*
		//processing internal organs is pretty cheap, do that first.
		for(var/datum/internal_organ/I in internal_organs)
			I.process()

		for(var/datum/limb/E in limbs)
			if(!E)
				continue
			if(!E.need_process())
				//bad_limbs -= E
				continue
			else
				E.process()

				if (!lying && world.time - l_move_time < 15)
					if(m_intent != MOVE_INTENT_WALK || pulledby) //Running around with fractured ribs won't do you any good; walking prevents worsening, unless you're being pulled around
						if (E.is_broken() && E.internal_organs && prob(15))
							var/datum/internal_organ/I = pick(E.internal_organs)
							custom_pain("You feel broken bones moving in your [E.display_name]!", 1)
							I.take_damage(rand(3,5))

					//Moving makes open wounds get infected much faster
					if (E.wounds.len)
						for(var/datum/wound/W in E.wounds)
							if (W.infection_check())
								W.germ_level += 1

				if(E.name in list("l_leg","l_foot","r_leg","r_foot") && !lying)
					if (!E.is_usable() || E.is_malfunctioning() || ( E.is_broken() && !(E.limb_status & LIMB_SPLINTED) && !(E.limb_status & LIMB_STABILIZED) ) )
						leg_tally--			// let it fail even if just foot&leg

		// standing is poor
		if(leg_tally <= 0 && !knocked_out && !lying && prob(5))
			if(!(species && (species.species_flags & NO_PAIN)))
				emote("pain")
			emote("collapse")
			knocked_out = 10
