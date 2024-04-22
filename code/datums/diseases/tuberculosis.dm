/datum/disease/tuberculosis
	form = "Disease"
	name = "Fungal tuberculosis"
	max_stages = 5
	spread_text = "Airborne"
	cure_text = "Spaceacillin & Convermol"
	cures = list(/datum/reagent/medicine/spaceacillin, /datum/reagent/medicine/C2/convermol)
	agent = "Fungal Tubercle bacillus Cosmosis"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5//like hell are you getting out of hell
	desc = ""
	required_organs = list(/obj/item/organ/lungs)
	severity = DISEASE_SEVERITY_BIOHAZARD
	bypasses_immunity = TRUE // TB primarily impacts the lungs; it's also bacterial or fungal in nature; viral immunity should do nothing.

/datum/disease/tuberculosis/stage_act() //it begins
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, "<span class='danger'>My chest hurts.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>My stomach violently rumbles!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>I feel a cold sweat form.</span>")
		if(4)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>I see four of everything!</span>")
				affected_mob.Dizzy(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>I feel a sharp pain from my lower chest!</span>")
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("breathgasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>I feel air escape from my lungs painfully.</span>")
				affected_mob.adjustOxyLoss(25)
				affected_mob.emote("breathgasp")
		if(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]</span>")
				affected_mob.adjustStaminaLoss(70)
			if(prob(10))
				affected_mob.adjustStaminaLoss(100)
				affected_mob.visible_message("<span class='warning'>[affected_mob] faints!</span>", "<span class='danger'>I surrender myself and feel so sick!...</span>")
				affected_mob.AdjustSleeping(100)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>I feel my mind relax and my thoughts drift!</span>")
				affected_mob.confused = min(100, affected_mob.confused + 8)
			if(prob(10))
				affected_mob.vomit(20)
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'><i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "My chest hurts!")]</i></span>")
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.adjust_nutrition(-100)
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel so sick!", "You feel like taking off some clothes...")]</span>")
				affected_mob.adjust_bodytemperature(40)
	return
