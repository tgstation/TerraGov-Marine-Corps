/datum/disease/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Ethanol"
	cures = list(/datum/reagent/consumable/ethanol)
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	desc = ""
	severity = DISEASE_SEVERITY_MINOR

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>I feel anxious.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>My stomach flutters.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>I feel panicky.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You're overtaken with panic!</span>")
				affected_mob.confused += (rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>I feel butterflies in my stomach.</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] stumbles around in a panic.</span>", \
												"<span class='danger'>I have a panic attack!</span>")
				affected_mob.confused += (rand(6,8))
				affected_mob.jitteriness += (rand(6,8))
			if(prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] coughs up butterflies!</span>", \
													"<span class='danger'>I cough up butterflies!</span>")
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
