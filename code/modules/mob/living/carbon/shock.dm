/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock(var/no_save = 0)
	var/newtraumatic_shock
	if(species && species.flags & NO_PAIN)
		if(!no_save)
			traumatic_shock = 0
		return

	newtraumatic_shock = 			\
	1	* getOxyLoss() + 		\
	0.7	* getToxLoss() + 		\
	1.5	* getFireLoss() + 		\
	1.5	* getBruteLoss() + 		\
	1.5	* getCloneLoss() + 		\
	1.5	* halloss

	if(reagents.has_reagent("alkysine")) 		newtraumatic_shock -= 10
	if(reagents.has_reagent("inaprovaline")) 	newtraumatic_shock -= 25
	if(reagents.has_reagent("synaptizine")) 	newtraumatic_shock -= 40
	if(slurring) 								newtraumatic_shock -= 20
	if(analgesic) 								newtraumatic_shock = 0


	//Broken or ripped off organs and limbs will add quite a bit of pain
	if(ishuman(src))
		var/mob/living/carbon/human/M = src
		for(var/datum/limb/O in M.limbs)
			if((O.status & LIMB_DESTROYED) && !(O.status & LIMB_AMPUTATED))
				newtraumatic_shock += 40
			else if(O.status & LIMB_BROKEN || O.surgery_open_stage)
				if(O.status & LIMB_SPLINTED)
					newtraumatic_shock += 15
				else
					newtraumatic_shock += 30
			if(O.germ_level >= INFECTION_LEVEL_ONE)
				newtraumatic_shock += O.germ_level * 0.05

		//Internal organs hurt too
		for(var/datum/internal_organ/O in M.internal_organs)
			if(O.damage) 											newtraumatic_shock += O.damage * 1.5
			if(O.germ_level >= INFECTION_LEVEL_ONE) 				newtraumatic_shock += O.germ_level * 0.05

		if(M.protection_aura)
			newtraumatic_shock -= M.protection_aura * 10

	newtraumatic_shock = max(0, traumatic_shock)	//reagents below this have the potential to mask damage

	if(reagents.has_reagent("paracetamol")) 	newtraumatic_shock -= 50
	if(reagents.has_reagent("tramadol")) 		newtraumatic_shock -= 80
	if(reagents.has_reagent("oxycodone")) 		newtraumatic_shock -= 200

	if(!no_save)
		traumatic_shock = newtraumatic_shock
	return newtraumatic_shock

/mob/living/carbon/proc/handle_shock()
	updateshock()
