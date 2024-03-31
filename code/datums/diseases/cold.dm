/datum/disease/cold
	name = "The Cold"
	max_stages = 3
	cure_text = "Rest & Spaceacillin"
	cures = list(/datum/reagent/medicine/spaceacillin)
	agent = "XY-rhinovirus"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	permeability_mod = 0.5
	desc = ""
	severity = DISEASE_SEVERITY_NONTHREAT

/datum/disease/cold/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.IsSleeping() && prob(5))  //changed FROM prob(10) until sleeping is fixed
				cure()
				return
			if(prob(1) && prob(5))
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>My throat feels sore.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Mucous runs down the back of my throat.</span>")
		if(3)
			if(affected_mob.IsSleeping() && prob(1))  //changed FROM prob(5) until sleeping is fixed
				cure()
				return
			if(prob(1) && prob(1))
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>My throat feels sore.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>Mucous runs down the back of my throat.</span>")
			if(prob(1) && prob(50))
				if(!affected_mob.disease_resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu()
					affected_mob.ForceContractDisease(Flu, FALSE, TRUE)
					cure()
