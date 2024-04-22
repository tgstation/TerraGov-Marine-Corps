/datum/disease/dna_retrovirus
	name = "Retrovirus"
	max_stages = 4
	spread_text = "Contact"
	spread_flags = DISEASE_SPREAD_BLOOD | DISEASE_SPREAD_CONTACT_SKIN | DISEASE_SPREAD_CONTACT_FLUIDS
	cure_text = "Rest or an injection of mutadone"
	cure_chance = 6
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = ""
	severity = DISEASE_SEVERITY_HARMFUL
	permeability_mod = 0.4
	stage_prob = 2
	var/restcure = 0

/datum/disease/dna_retrovirus/New()
	..()
	agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	if(prob(40))
		cures = list(/datum/reagent/medicine/mutadone)
	else
		restcure = 1

/datum/disease/dna_retrovirus/Copy()
	var/datum/disease/dna_retrovirus/D = ..()
	D.restcure = restcure
	return D

/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(30))
					to_chat(affected_mob, "<span class='notice'>I feel better.</span>")
					cure()
					return
			if (prob(8))
				to_chat(affected_mob, "<span class='danger'>My head hurts.</span>")
			if (prob(9))
				to_chat(affected_mob, "<span class='danger'>I feel a tingling sensation in my chest.</span>")
			if (prob(9))
				to_chat(affected_mob, "<span class='danger'>I feel angry.</span>")
		if(2)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
					to_chat(affected_mob, "<span class='notice'>I feel better.</span>")
					cure()
					return
			if (prob(8))
				to_chat(affected_mob, "<span class='danger'>My skin feels loose.</span>")
			if (prob(10))
				to_chat(affected_mob, "<span class='danger'>I feel very strange.</span>")
			if (prob(4))
				to_chat(affected_mob, "<span class='danger'>I feel a stabbing pain in my head!</span>")
				affected_mob.Unconscious(40)
			if (prob(4))
				to_chat(affected_mob, "<span class='danger'>My stomach churns.</span>")
		if(3)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(20))
					to_chat(affected_mob, "<span class='notice'>I feel better.</span>")
					cure()
					return
			if (prob(10))
				to_chat(affected_mob, "<span class='danger'>My entire body vibrates.</span>")

			if (prob(35))
				if(prob(50))
					scramble_dna(affected_mob, 1, 0, rand(15,45))
				else
					scramble_dna(affected_mob, 0, 1, rand(15,45))

		if(4)
			if(restcure)
				if(!(affected_mob.mobility_flags & MOBILITY_STAND) && prob(5))
					to_chat(affected_mob, "<span class='notice'>I feel better.</span>")
					cure()
					return
			if (prob(60))
				if(prob(50))
					scramble_dna(affected_mob, 1, 0, rand(50,75))
				else
					scramble_dna(affected_mob, 0, 1, rand(50,75))
