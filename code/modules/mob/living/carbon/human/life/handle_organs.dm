
// Takes care of organ & limb related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_organs()

	var/leg_tally = 2

	last_dam = getBruteLoss() + getFireLoss() + getToxLoss()

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
			//Moving around with fractured ribs won't do you any good
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
				if (!E.is_usable() || E.is_malfunctioning() || (E.is_broken() && !(E.status & LIMB_SPLINTED)))
					leg_tally--			// let it fail even if just foot&leg

	// standing is poor
	if(leg_tally <= 0 && !knocked_out && !lying && prob(5))
		if(!(species && (species.flags & NO_PAIN)))
			emote("pain")
		emote("collapse")
		knocked_out = 10
