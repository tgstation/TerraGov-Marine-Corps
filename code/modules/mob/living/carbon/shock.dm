/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	if(species && species.flags & NO_PAIN)
		traumatic_shock = 0
		return

	traumatic_shock = 			\
	1	* getOxyLoss() + 		\
	0.7	* getToxLoss() + 		\
	2.5	* getFireLoss() + 		\
	1.5	* getBruteLoss() + 		\
	1.8	* getCloneLoss() + 		\
	1.5	* halloss

	if(reagents.has_reagent("alkysine")) 		traumatic_shock -= 10
	if(reagents.has_reagent("inaprovaline")) 	traumatic_shock -= 25
	if(reagents.has_reagent("synaptizine")) 	traumatic_shock -= 40
	if(reagents.has_reagent("paracetamol")) 	traumatic_shock -= 50
	if(reagents.has_reagent("tramadol")) 		traumatic_shock -= 80
	if(reagents.has_reagent("oxycodone")) 		traumatic_shock -= 200
	if(slurring) 								traumatic_shock -= 20
	if(analgesic) 								traumatic_shock = 0


	//Broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/datum/organ/external/O in M.organs)
			if(O.status & ORGAN_DESTROYED && !O.amputated)		 	traumatic_shock += 40
			else if(O.status & ORGAN_BROKEN || O.open) 				traumatic_shock += O.status & ORGAN_SPLINTED ? 15 : 30
			if(O.status && O.germ_level >= INFECTION_LEVEL_ONE) 	traumatic_shock += O.germ_level * 0.05

		//Internal organs hurt too
		for(var/datum/organ/internal/O in M.internal_organs)
			if(O.damage) 											traumatic_shock += O.damage * 1.5
			if(O.germ_level >= INFECTION_LEVEL_ONE) 				traumatic_shock += O.germ_level * 0.05

	traumatic_shock = max(0, traumatic_shock)
	return traumatic_shock

/mob/living/carbon/proc/handle_shock()
	updateshock()