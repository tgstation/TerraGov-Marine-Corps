/mob/living/carbon/proc/getHalLoss()
	return halloss

/mob/living/carbon/adjustHalLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	halloss = CLAMP(halloss+amount,0,maxHealth*2)

/mob/living/carbon/proc/setHalLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	halloss = amount

/mob/living/carbon/proc/getTraumatic_Shock()
	return traumatic_shock

/mob/living/carbon/proc/adjustTraumatic_Shock(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	traumatic_shock = CLAMP(traumatic_shock+amount,0,maxHealth*2)

/mob/living/carbon/proc/setTraumatic_Shock(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	traumatic_shock = amount

/mob/living/carbon/proc/getShock_Stage()
	return shock_stage

/mob/living/carbon/proc/adjustShock_Stage(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	shock_stage = CLAMP(shock_stage+amount,0,maxHealth*2)

/mob/living/carbon/proc/setShock_Stage(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	shock_stage = amount

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	if(species && species.flags & NO_PAIN || stat == DEAD)
		traumatic_shock = 0
		return

	traumatic_shock = 			\
	1	* getOxyLoss() + 		\
	0.7	* getToxLoss() + 		\
	1.5	* getFireLoss() + 		\
	1.5	* getBruteLoss() + 		\
	1.5	* getCloneLoss()

	traumatic_shock += reagent_shock_modifier

	if(slurring)
		traumatic_shock -= 10
	if(analgesic)
		traumatic_shock = 0


	//Broken or ripped off organs and limbs will add quite a bit of pain
	if(ishuman(src))
		var/mob/living/carbon/human/M = src
		for(var/datum/limb/O in M.limbs)
			if((O.status & LIMB_DESTROYED) && !(O.status & LIMB_AMPUTATED))
				traumatic_shock += 40
			else if(O.status & LIMB_BROKEN || O.surgery_open_stage)
				if(O.status & LIMB_SPLINTED)
					traumatic_shock += 15
				else
					traumatic_shock += 30
			if(O.germ_level >= INFECTION_LEVEL_ONE)
				traumatic_shock += O.germ_level * 0.05

		//Internal organs hurt too
		for(var/datum/internal_organ/O in M.internal_organs)
			if(O.damage) 											traumatic_shock += O.damage * 1.5
			if(O.germ_level >= INFECTION_LEVEL_ONE) 				traumatic_shock += O.germ_level * 0.05

		if(M.protection_aura)
			traumatic_shock -= 20 + M.protection_aura * 20 //-40 pain for SLs, -80 for Commanders

	traumatic_shock = max(0, traumatic_shock)	//stuff below this has the potential to mask damage

	traumatic_shock += 1.5 * halloss //not affected by reagent shock reduction
	traumatic_shock += reagent_pain_modifier

	return traumatic_shock

/mob/living/carbon/proc/handle_shock()
	updateshock()

/mob/living/carbon/proc/halloss_recovery()
	if(stat == DEAD)
		setHalLoss(0)
		return
	var/rate = BASE_HALLOSS_RECOVERY_RATE

	if(lying || last_move_intent < world.time - 20) //If we're standing still or knocked down we benefit from the downed halloss rate
		if(resting || sleeping) //we're deliberately resting, comfortably taking a breather
			rate = REST_HALLOSS_RECOVERY_RATE
		else
			rate = DOWNED_HALLOSS_RECOVERY_RATE
	else if(m_intent == MOVE_INTENT_WALK)
		rate = WALK_HALLOSS_RECOVERY_RATE

	adjustHalLoss(rate)