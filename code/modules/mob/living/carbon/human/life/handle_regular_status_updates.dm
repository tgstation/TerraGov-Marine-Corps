//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)
		return 0

	if(stat == DEAD) //DEAD. BROWN BREAD. SWIMMING WITH THE SPESS CARP
		blinded = 1
		silent = 0
	else //ALIVE. LIGHTS ARE ON
		//updatehealth() // moved to Life()

		if(health <= config.health_threshold_dead || (species.has_organ["brain"] && !has_brain()))
			death()
			blinded = 1
			silent = 0
			return 1

		//The analgesic effect wears off slowly
		analgesic = max(0, analgesic - 1)

		//UNCONSCIOUS. NO-ONE IS HOME
		if((getOxyLoss() > 50) || (config.health_threshold_crit > health))
			KnockOut(3)

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
				hallucinations -= a
				cdel(a)

			if(halloss > 100)
				visible_message("<span class='warning'>\The [src] slumps to the ground, too weak to continue fighting.</span>", \
				"<span class='warning'>You slump to the ground, you're in too much pain to keep going.</span>")
				KnockOut(10)
				setHalLoss(99)

		if(knocked_out)
			AdjustKnockedout(-species.knock_out_reduction)
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

		if(in_stasis == STASIS_IN_CRYO_CELL) blinded = TRUE //Always blinded while in stasisTUBES

		//Periodically double-check embedded_flag
		if(embedded_flag && !(life_tick % 10))
			var/list/E
			E = get_visible_implants(0)
			if(!E.len)
				embedded_flag = 0

		//Eyes
		if(!species.has_organ["eyes"]) //Presumably if a species has no eyes, they see via something else.
			eye_blind = 0
			if(stat == CONSCIOUS) //even with 'eye-less' vision, unconsciousness makes you blind
				blinded = 0
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
		else if(istype(wear_ear, /obj/item/clothing/ears/earmuffs))	//Resting your ears with earmuffs heals ear damage faster
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
				KnockOut(5)

		confused = max(0, confused - 1)

		//If you're dirty, your gloves will become dirty, too.
		if(gloves && germ_level > gloves.germ_level && prob(10))
			gloves.germ_level += 1

		if(command_aura_cooldown > 0)
			command_aura_cooldown--
		if(command_aura)
			command_aura_tick--
			if(command_aura_tick < 1)
				command_aura = null
		if(command_aura && !stat)
			command_aura_strength = mind.cm_skills.leadership - 1 //2 is SL, so base of 1. Goes up to 3 (CO, XO)
			var/command_aura_range = round(4 + command_aura_strength * 1)
			for(var/mob/living/carbon/human/H in range(command_aura_range, src)) //Goes from 7 for Young Drone to 16 for Ancient Queen
				if(command_aura == "move" && command_aura_strength > H.mobility_new)
					H.mobility_new = command_aura_strength
				if(command_aura == "hold" && command_aura_strength > H.protection_new)
					H.protection_new = command_aura_strength
				if(command_aura == "focus" && command_aura_strength > H.marskman_new)
					H.marskman_new = command_aura_strength

		mobility_aura = mobility_new
		protection_aura = protection_new
		marskman_aura = marskman_new

		//hud_set_pheromone() //TODO: HOOK THIS UP, ASK PHIL

		mobility_new = 0
		protection_new = 0
		marskman_new = 0

	return 1

/mob/living/carbon/human/handle_knocked_down()
	if(knocked_down && client)
		AdjustKnockeddown(-species.knock_down_reduction)
	return knocked_down

/mob/living/carbon/human/handle_stunned()
	if(stunned)
		AdjustStunned(-species.stun_reduction)
	return stunned
