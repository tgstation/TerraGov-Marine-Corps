//Takes care of organ & limb related updates, such as broken and missing limbs
/mob/living/carbon/human/handle_organs()
	. = ..()

	if(reagents && !CHECK_BITFIELD(species.species_flags, NO_CHEM_METABOLIZATION))
		var/datum/internal_organ/liver/L
		if(species?.has_organ["liver"])
			L = internal_organs_by_name["liver"]
		var/overdosable = CHECK_BITFIELD(species.species_flags, NO_OVERDOSE) ? FALSE : TRUE
		if(!(status_flags & GODMODE)) //godmode doesn't work as intended anyway
			reagents.metabolize(src, overdosable, L ? FALSE : TRUE)

	if(!issynth(src)) //synthetics are never hungry
		//Nutrition decrease
		if(nutrition > 0 && stat != DEAD)
			adjust_nutrition(-HUNGER_FACTOR)

		if(nutrition > NUTRITION_OVERFED)
			if(overeatduration < 600) //Capped so people don't take forever to unfat
				overeatduration++
		else
			if(overeatduration > 1)
				overeatduration -= 2	//Doubled the unfat rate

	var/leg_tally = 2

	last_dam = getBruteLoss() + getFireLoss() + getToxLoss()

	for(var/datum/internal_organ/I in internal_organs)
		I.process()

	for(var/i in limbs)
		var/datum/limb/E = i
		if(!E.need_process())
			continue

		E.process()

		if(!lying_angle && world.time - last_move_time < 15 && m_intent != MOVE_INTENT_WALK || pulledby)
			if(E.is_broken() && E.internal_organs && prob(15))
				var/datum/internal_organ/I = pick(E.internal_organs)
				custom_pain("You feel broken bones moving in your [E.display_name]!", 1)
				I.take_damage(rand(3,5))

			//Moving makes open wounds get infected much faster
			for(var/j in E.wounds)
				var/datum/wound/W = j
				if(!W.infection_check())
					continue
				W.germ_level += 1

		if(E.name in list("l_leg", "l_foot", "r_leg", "r_foot") && !lying_angle)
			if(!E.is_usable() || E.is_malfunctioning() || ( E.is_broken() && !(E.limb_status & LIMB_SPLINTED) && !(E.limb_status & LIMB_STABILIZED) ) )
				leg_tally--			//let it fail even if just foot&leg

	//standing is poor
	if(leg_tally <= 0 && !IsUnconscious() && !lying_angle && prob(5))
		if(!(species.species_flags & NO_PAIN))
			emote("pain")
		emote("collapse")
		SetUnconscious(20 SECONDS)
