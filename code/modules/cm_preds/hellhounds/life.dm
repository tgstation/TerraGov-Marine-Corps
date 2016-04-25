/mob/living/carbon/hellhound/Life()
	set invisibility = 0
	set background = 1

	..()

	if (stat != DEAD)

		//Chemicals in the body
		handle_chemicals_in_body()

	blinded = null

	//Check if we're on fire
	handle_fire()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()

	if(client)
		handle_regular_hud_updates()

	// Grabbing
	for(var/obj/item/weapon/grab/G in src)
		G.process()

	updatehealth()
	update_icons()

/mob/living/carbon/hellhound/proc/handle_chemicals_in_body()
	if(reagents && reagents.reagent_list.len)
		reagents.metabolize(src)

	if(confused)
		confused = 0

	if(resting)
		dizziness = 0
	else
		dizziness = max(0, dizziness - 1)

	return

/mob/living/carbon/hellhound/handle_fire()
	if(..())
		return
//	adjustFireLoss(5)
	return

/mob/living/carbon/hellhound/proc/handle_regular_status_updates()
	if(stat == DEAD)	//DEAD
		blinded = 1
		silent = 0
	else				//ALIVE. LIGHTS ARE ON
		updatehealth()
		if(health < -100 || !has_brain())
			death()
			blinded = 1
			stat = DEAD
			silent = 0
			return 1

		//They heal quickly.
		see_in_dark = 8
		adjustBruteLoss(-5)
		adjustFireLoss(-5)
		adjustOxyLoss(-10)
		adjustToxLoss(-50)
		if(weakened) weakened -= 2
		if(weakened < 0) weakened = 0 //Just to be sure.
		if(stunned) stunned = 0

		//UNCONSCIOUS. NO-ONE IS HOME
		if(health < 0)
			if( health <= 10 && prob(1) )
				spawn(0)
					emote("gasp")
			if(!reagents.has_reagent("inaprovaline"))
				adjustOxyLoss(11)
			Paralyse(3)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
		else if(sleeping)
			sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if( prob(10) && health && !hal_crit )
				spawn(0)
					emote("snore")
		else
			stat = CONSCIOUS

/mob/living/carbon/hellhound/proc/handle_regular_hud_updates()
	if (healths)
		if (stat != 2)
			switch(health)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(pullin)	pullin.icon_state = "pull[pulling ? 1 : 0]"

	return 1