//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)
		return 0

	if(stat == DEAD) //DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else //ALIVE. LIGHTS ARE ON
		updatehealth() //TODO

		if(health <= config.health_threshold_dead || (species.has_organ["brain"] && !has_brain()))
			death()
			blinded = 1
			silent = 0
			return 1

		//The analgesic effect wears off slowly
		analgesic = max(0, analgesic - 1)

		//UNCONSCIOUS. NO-ONE IS HOME
		if((getOxyLoss() > 50) || (config.health_threshold_crit > health))
			Paralyse(3)

		if(hallucination)
			if(hallucination >= 20)
				if(prob(3))
					fake_attack(src)
				if(!handling_hal)
					spawn handle_hallucinations() //The not boring kind!

			if(hallucination <= 2)
				hallucination = 0
				halloss = 0
			else
				hallucination -= 2

		else
			for(var/atom/a in hallucinations)
				del a

			if(halloss > 100)
				visible_message("<span class='warning'>\The [src] slumps to the ground, too weak to continue fighting.</span>", \
				"<span class='warning'>You slump to the ground, you're in too much pain to keep going.</span>")
				Paralyse(10)
				setHalLoss(99)

		if(paralysis)
			AdjustParalysis(-1)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			speech_problem_flag = 1
			handle_dreams()
			adjustHalLoss(-3)
			if(mind)
				if((mind.active && client != null) || immune_to_ssd) //This also checks whether a client is connected, if not, sleep is not reduced.
					sleeping = max(sleeping - 1, 0)
			blinded = 1
			stat = UNCONSCIOUS
			if(prob(2) && health && !hal_crit)
				spawn()
					emote("snore")
		else
			stat = CONSCIOUS

		if(in_stasis) blinded = TRUE //Always blinded while in stasis.

		if(has_species(src,"Yautja")) //Hurr hurr.
			if(weakened)
				weakened-- //Yautja stand up twice as fast from knockdown.

		//Periodically double-check embedded_flag
		if(embedded_flag && !(life_tick % 10))
			var/list/E
			E = get_visible_implants(0)
			if(!E.len)
				embedded_flag = 0

		//Eyes
		if(!species.has_organ["eyes"]) //Presumably if a species has no eyes, they see via something else.
			eye_blind =  0
			blinded =    0
			eye_blurry = 0
		else if(!has_eyes())           //Eyes cut out? Permablind.
			eye_blind =  1
			blinded =    1
			eye_blurry = 1
		else if(sdisabilities & BLIND) //Disabled-blind, doesn't get better on its own
			blinded =    1
		else if(eye_blind)		       //Blindness, heals slowly over time
			eye_blind =  max(eye_blind - 1, 0)
			blinded =    1
		else if(istype(glasses, /obj/item/clothing/glasses/sunglasses/blindfold)) //Resting your eyes with a blindfold heals blurry eyes faster
			eye_blurry = max(eye_blurry - 3, 0)
			blinded =    1
		else if(eye_blurry)	           //Blurry eyes heal slowly
			eye_blurry = max(eye_blurry - 1, 0)

		//Ears
		if(sdisabilities & DEAF) //Disabled-deaf, doesn't get better on its own
			ear_deaf = max(ear_deaf, 1)
		else if(ear_deaf) //Deafness, heals slowly over time
			ear_deaf = max(ear_deaf - 1, 0)
		else if(istype(l_ear, /obj/item/clothing/ears/earmuffs) || istype(r_ear, /obj/item/clothing/ears/earmuffs))	//Resting your ears with earmuffs heals ear damage faster
			ear_damage = max(ear_damage - 0.15, 0)
			ear_deaf = max(ear_deaf, 1)
		else if(ear_damage < 25) //Ear damage heals slowly under this threshold. otherwise you'll need earmuffs
			ear_damage = max(ear_damage - 0.05, 0)

		//Resting
		if(resting)
			dizziness = max(0, dizziness - 15)
			jitteriness = max(0, jitteriness - 15)
			adjustHalLoss(-3)
		else
			dizziness = max(0, dizziness - 3)
			jitteriness = max(0, jitteriness - 3)
			adjustHalLoss(-1)

		//Other
		handle_statuses()

		if(drowsyness)
			drowsyness--
			eye_blurry = max(2, eye_blurry)
			if(prob(5))
				sleeping += 1
				Paralyse(5)

		confused = max(0, confused - 1)

		//If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

	return 1
