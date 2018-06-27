/datum/disease/ultrazine_addiction
	form = "Condition"
	name = "Ultrazine Addiction"
	max_stages = 4
	spread = "Acute"
	cure = "Withdrawal"
	curable = 0
	agent = "Ultrazine"
	affected_species = list("Human")
	permeability_mod = 1
	can_carry = 0
	spread_type = NON_CONTAGIOUS
	desc = "Use of addictive stimulants results in physiological and psychological dependency."
	severity = "Medium"
	longevity = 1000
	hidden = list(1, 1) //hidden from med-huds and pandemic scanners
	stage_minimum_age = 900001 // advanced only by ultrazine
	var/addiction_progression = 1
	var/progression_threshold = 300 //how many life() ticks it takes to advance stage. At 300, a 5 unit pill should increase progression from 0 to just below the threshold

/datum/disease/ultrazine_addiction/stage_act()
	..()

	//world << "stage: [stage], addiction_progression: [addiction_progression]"

	var/has_ultrazine = 0

	if(affected_mob.reagents.has_reagent("ultrazine"))
		has_ultrazine = 1

	//withdrawal process
	if(!has_ultrazine)
		addiction_progression -= 0.383 //about 30 minutes to get past each stage
		if(addiction_progression < 0)
			if(stage == 1)
				cure(0)
				return
			else
				stage = max(stage-1, 0)
				addiction_progression = progression_threshold

	//symptoms
	switch(stage)

		if(1)
			if(has_ultrazine) //if we have ultrazine, no effect
				return

			if(prob(20))
				affected_mob.halloss = max(20, affected_mob.halloss + 5)
				if(prob(50))
					affected_mob << "<span class='danger'>[pick("You could use another hit.", "More of that would be nice.", "Another dose would help.", "One more dose wouldn't hurt", "Why not take one more?")]</span>"

			affected_mob.next_move_slowdown = max(affected_mob.next_move_slowdown, 5)

		if(2)
			if(has_ultrazine)
				return

			if(prob(20))
				affected_mob.halloss = max(40, affected_mob.halloss + 5)
				if(prob(50))
					affected_mob << "<span class='danger'>[pick("It's just not the same without it.", "You could use another hit.", "You should take another.", "Just one more.", "Looks like you need another one.")]</span>"
				if(prob(25))
					affected_mob.emote("me",1, pick("winces slightly.", "grimaces.") )

			affected_mob.next_move_slowdown = max(affected_mob.next_move_slowdown, 7)

		if(3)
			if(has_ultrazine)
				return

			if(prob(3))
				affected_mob.hallucination += 10

			if(prob(20))
				affected_mob.halloss = max(60, affected_mob.halloss + 5)
				affected_mob.adjustToxLoss(1)
				if(prob(50))
					affected_mob << "<span class='danger'>[pick("You need more.", "It's hard to go on like this.", "You want more. You need more.", "Just take another hit. Now.", "One more.")]</span>"
				if(prob(25))
					affected_mob.emote("me",1, pick("winces.", "grimaces.", "groans!") )

			affected_mob.next_move_slowdown = max(affected_mob.next_move_slowdown, 10)

		if(4)
			if(has_ultrazine)
				if(prob(1))
					affected_mob.hallucination += 50
				if(prob(2))
					var/mob/living/carbon/human/H = affected_mob
					var/datum/internal_organ/heart/F = H.internal_organs_by_name["heart"]
					F.damage += 0.3
				return

			if(prob(5))
				affected_mob.hallucination += 50

			if(prob(20))
				affected_mob.halloss = max(80, affected_mob.halloss + 5)
				affected_mob.adjustToxLoss(1.5)
				if(prob(50))
					affected_mob. << "<span class='danger'>[pick("You need another dose, now. NOW.", "You can't stand it. You have to go back. You have to go back.", "You need more. YOU NEED MORE.", "MORE", "TAKE MORE.")]</span>"
				if(prob(25))
					affected_mob.emote("me",1, pick("groans painfully!", "contorts with pain!") )

			affected_mob.next_move_slowdown = max(affected_mob.next_move_slowdown, 10)