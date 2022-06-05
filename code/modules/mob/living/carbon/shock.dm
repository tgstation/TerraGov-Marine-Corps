/mob/living/carbon/proc/getTraumatic_Shock()
	return traumatic_shock

/mob/living/carbon/proc/adjustTraumatic_Shock(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	traumatic_shock = clamp(traumatic_shock+amount,-100,maxHealth*2)

/mob/living/carbon/proc/setTraumatic_Shock(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	traumatic_shock = amount

/mob/living/carbon/proc/getShock_Stage()
	return shock_stage

/mob/living/carbon/proc/adjustShock_Stage(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	. = shock_stage
	shock_stage = clamp(shock_stage + (amount - shock_stage) * PAIN_REACTIVITY, 0, maxHealth * 2)
	adjust_pain_speed_mod(.)

/mob/living/carbon/proc/setShock_Stage(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	. = shock_stage
	shock_stage = amount
	adjust_pain_speed_mod(.)


/mob/living/carbon/proc/adjust_pain_speed_mod(old_shock_stage)
	switch(shock_stage)
		if(0 to 100)
			if(old_shock_stage <= 100)
				return
			remove_movespeed_modifier(MOVESPEED_ID_PAIN)
		if(100 to 125)
			if(old_shock_stage > 100 || old_shock_stage <= 125)
				return
			add_movespeed_modifier(MOVESPEED_ID_PAIN, TRUE, 0, NONE, TRUE, 1)
		if(125 to 150)
			if(old_shock_stage > 125 || old_shock_stage <= 150)
				return
			add_movespeed_modifier(MOVESPEED_ID_PAIN, TRUE, 0, NONE, TRUE, 2)
		if(150 to INFINITY)
			if(old_shock_stage > 150)
				return
			add_movespeed_modifier(MOVESPEED_ID_PAIN, TRUE, 0, NONE, TRUE, 3)


// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	if(species && species.species_flags & NO_PAIN || stat == DEAD)
		traumatic_shock = 0
		return

	traumatic_shock = 			\
	0.75	* getOxyLoss() + 		\
	0.75	* getToxLoss() + 		\
	1.20		* getFireLoss() + 		\
	1		* getBruteLoss() + 		\
	1		* getCloneLoss()

	traumatic_shock += reagent_shock_modifier

	if(slurring)
		traumatic_shock -= 10
	if(analgesic)
		traumatic_shock = 0


	//Broken or ripped off organs and limbs will add quite a bit of pain
	if(ishuman(src))
		var/mob/living/carbon/human/M = src
		for(var/datum/limb/O in M.limbs)
			if(((O.limb_status & LIMB_DESTROYED) && !(O.limb_status & LIMB_AMPUTATED)) || O.limb_status & LIMB_NECROTIZED)
				traumatic_shock += 40
			else if(O.limb_status & LIMB_BROKEN || O.surgery_open_stage)
				if(O.limb_status & LIMB_SPLINTED)
					traumatic_shock += 15
				else
					traumatic_shock += 25
			if(O.germ_level >= INFECTION_LEVEL_ONE)
				traumatic_shock += O.germ_level * 0.05

		//Internal organs hurt too
		for(var/datum/internal_organ/O in M.internal_organs)
			if(O.damage) 											traumatic_shock += O.damage * 1.5

		if(M.protection_aura)
			traumatic_shock -= 20 + M.protection_aura * 20 //-40 pain for SLs, -80 for Commanders

	traumatic_shock += reagent_pain_modifier

	return traumatic_shock

/mob/living/carbon/proc/handle_shock()
	updateshock()
