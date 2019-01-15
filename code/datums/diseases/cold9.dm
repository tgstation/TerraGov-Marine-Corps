/datum/disease/cold9
	name = "The Cold"
	max_stages = 3
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Common Cold Anti-bodies & Spaceacillin"
	cure_id = "spaceacillin"
	agent = "ICE9-rhinovirus"
	affected_species = list("Human")
	desc = "If left untreated the subject will slow, as if partly frozen."
	severity = "Moderate"

/datum/disease/cold9/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.adjust_bodytemperature(-10 * TEMPERATURE_DAMAGE_COEFFICIENT)
			if(prob(1) && prob(10))
				to_chat(affected_mob, "\blue You feel better.")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "\red Your throat feels sore.")
			if(prob(5))
				to_chat(affected_mob, "\red You feel stiff.")
		if(3)
			affected_mob.adjust_bodytemperature(-20 * TEMPERATURE_DAMAGE_COEFFICIENT)
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "\red Your throat feels sore.")
			if(prob(10))
				to_chat(affected_mob, "\red You feel stiff.")