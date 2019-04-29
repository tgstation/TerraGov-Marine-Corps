//Updates the mob's health from limbs and mob damage variables
/mob/living/carbon/human/updatehealth()

	if(status_flags & GODMODE)
		health = species.total_health
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	for(var/datum/limb/O in limbs)	//hardcoded to streamline things a bit
		total_brute	+= O.brute_dam
		total_burn	+= O.burn_dam

	var/oxy_l = getOxyLoss()
	var/tox_l = ((species.species_flags & NO_POISON) ? 0 : getToxLoss())
	var/clone_l = getCloneLoss()

	health = species.total_health - oxy_l - tox_l - clone_l - total_burn - total_brute

	if(CONFIG_GET(flag/husking_on) && ((species.total_health - total_burn) < get_death_threshold() * 4))
		ChangeToHusk()


	update_stat()
	med_hud_set_health()
	med_hud_set_status()



/mob/living/carbon/human/adjustBrainLoss(amount, silent = FALSE)

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species?.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(sponge)
			sponge.take_damage(amount, silent)
			sponge.damage = CLAMP(sponge.damage, 0, maxHealth*2)
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/setBrainLoss(amount)

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species?.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(sponge)
			sponge.damage = CLAMP(amount, 0, maxHealth*2)
			brainloss = sponge.damage
		else
			brainloss = 200
	else
		brainloss = 0

/mob/living/carbon/human/getBrainLoss()

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species?.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(sponge) //Make sure they actually have a brain
			brainloss = min(sponge.damage,maxHealth*2)
		else
			brainloss = 200 //No brain!
	else
		brainloss = 0
	return brainloss

//These procs fetch a cumulative total damage from all limbs
/mob/living/carbon/human/getBruteLoss(var/organic_only=0)
	var/amount = 0
	for(var/datum/limb/O in limbs)
		if(!(organic_only && O.limb_status & LIMB_ROBOT))
			amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss(var/organic_only=0)
	var/amount = 0
	for(var/datum/limb/O in limbs)
		if(!(organic_only && O.limb_status & LIMB_ROBOT))
			amount += O.burn_dam
	return amount


/mob/living/carbon/human/adjustBruteLoss(var/amount)
	if(species && species.brute_mod && amount > 0)
		amount = amount*species.brute_mod

	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)


/mob/living/carbon/human/adjustFireLoss(var/amount)
	if(species && species.burn_mod && amount > 0)
		amount = amount*species.burn_mod

	if(amount > 0)
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)


/mob/living/carbon/human/proc/adjustBruteLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	if(species && species.brute_mod && amount > 0)
		amount = amount*species.brute_mod

	for(var/X in limbs)
		var/datum/limb/O = X
		if(O.name == organ_name)
			if(amount > 0)
				O.take_damage_limb(amount, 0, is_sharp(damage_source), has_edge(damage_source))
			else
				//if you don't want to heal robot limbs, they you will have to check that yourself before using this proc.
				O.heal_damage(-amount, 0, internal=0, robo_repair=(O.limb_status & LIMB_ROBOT))
			break



/mob/living/carbon/human/proc/adjustFireLossByPart(var/amount, var/organ_name, var/obj/damage_source = null)
	if(species && species.burn_mod && amount > 0)
		amount = amount*species.burn_mod

	for(var/X in limbs)
		var/datum/limb/O = X
		if(O.name == organ_name)
			if(amount > 0)
				O.take_damage_limb(0, amount, is_sharp(damage_source), has_edge(damage_source))
			else
				//if you don't want to heal robot limbs, they you will have to check that yourself before using this proc.
				O.heal_damage(0, -amount, internal=0, robo_repair=(O.limb_status & LIMB_ROBOT))
			break



/mob/living/carbon/human/getCloneLoss()
	if(species.species_flags & (IS_SYNTHETIC|NO_SCAN))
		cloneloss = 0
	return ..()

/mob/living/carbon/human/setCloneLoss(var/amount)
	if(species.species_flags & (IS_SYNTHETIC|NO_SCAN))
		cloneloss = 0
	else
		..()

/mob/living/carbon/human/adjustCloneLoss(var/amount)
	..()

	if(species.species_flags & (IS_SYNTHETIC|NO_SCAN))
		cloneloss = 0
		return

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss()+10)
	if (amount > 0)
		if (prob(mut_prob))
			var/list/datum/limb/candidates = list()
			for (var/datum/limb/O in limbs)
				if(O.limb_status & (LIMB_ROBOT|LIMB_DESTROYED|LIMB_MUTATED)) continue
				candidates |= O
			if (candidates.len)
				var/datum/limb/O = pick(candidates)
				O.mutate()
				to_chat(src, "<span class = 'notice'>Something is not right with your [O.display_name]...</span>")
				return
	else
		if (prob(heal_prob))
			for (var/datum/limb/O in limbs)
				if (O.limb_status & LIMB_MUTATED)
					O.unmutate()
					to_chat(src, "<span class = 'notice'>Your [O.display_name] is shaped normally again.</span>")
					return

	if (getCloneLoss() < 1)
		for (var/datum/limb/O in limbs)
			if (O.limb_status & LIMB_MUTATED)
				O.unmutate()
				to_chat(src, "<span class = 'notice'>Your [O.display_name] is shaped normally again.</span>")


/mob/living/carbon/human/adjustOxyLoss(amount, forced = FALSE)
	if(species.species_flags & NO_BREATHE && !forced)
		return
	return ..()

/mob/living/carbon/human/setOxyLoss(amount, forced = FALSE)
	if(species.species_flags & NO_BREATHE && !forced)
		return
	return ..()

/mob/living/carbon/human/getToxLoss()
	if(species.species_flags & NO_POISON)
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(var/amount)
	if(species.species_flags & NO_POISON)
		toxloss = 0
	else
		..()

/mob/living/carbon/human/setToxLoss(var/amount)
	if(species.species_flags & NO_POISON)
		toxloss = 0
	else
		..()

////////////////////////////////////////////

//Returns a list of damaged limbs
/mob/living/carbon/human/proc/get_damaged_limbs(var/brute, var/burn)
	var/list/datum/limb/parts = list()
	for(var/datum/limb/O in limbs)
		if((brute && O.brute_dam) || (burn && O.burn_dam) || !(O.surgery_open_stage == 0))
			parts += O
	return parts

//Returns a list of damageable limbs
/mob/living/carbon/human/proc/get_damageable_limbs()
	var/list/datum/limb/parts = list()
	for(var/datum/limb/O in limbs)
		if(O.brute_dam + O.burn_dam < O.max_damage)
			parts += O
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_limb_damage(var/brute, var/burn)
	var/list/datum/limb/parts = get_damaged_limbs(brute,burn)
	if(!parts.len)	return
	var/datum/limb/picked = pick(parts)
	if(picked.heal_damage(brute,burn))
		UpdateDamageIcon()
	updatehealth()


/*
In most cases it makes more sense to use apply_damage() instead! And make sure to check armour if applicable.
*/
//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_limb_damage(var/brute, var/burn, var/sharp = 0, var/edge = 0)
	var/list/datum/limb/parts = get_damageable_limbs()
	if(!parts.len)	return
	var/datum/limb/picked = pick(parts)
	if(picked.take_damage_limb(brute, burn, sharp, edge))
		UpdateDamageIcon()

	if(brute)
		camo_off_process(SCOUT_CLOAK_OFF_DAMAGE, brute) //If we have the Scout cloak, check for a short out
	if(burn)
		camo_off_process(SCOUT_CLOAK_OFF_DAMAGE, burn) //If we have the Scout cloak, check for a short out

	updatehealth()
	speech_problem_flag = 1


//Heal MANY limbs, in random order
/mob/living/carbon/human/heal_overall_damage(var/brute, var/burn)
	var/list/datum/limb/parts = get_damaged_limbs(brute,burn)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/datum/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked
	updatehealth()
	speech_problem_flag = 1
	if(update)	UpdateDamageIcon()

// damage MANY limbs, in random order
/mob/living/carbon/human/take_overall_damage(var/brute, var/burn, var/sharp = 0, var/edge = 0, var/used_weapon = null, var/blocked = 0)
	if(status_flags & GODMODE)	return	//godmode

	if(blocked >= 1) //Complete negation
		return FALSE

	if(blocked)
		if(brute)
			brute *= CLAMP(1-blocked,0.00,1.00) //Percentage reduction
		if(burn)
			burn *= CLAMP(1-blocked,0.00,1.00) //Percentage reduction

	if(!brute && !burn) //Complete negation
		return FALSE

	if(protection_aura)
		if(brute)
			brute = round(brute * ((15 - protection_aura) / 15))
		if(burn)
			burn = round(burn * ((15 - protection_aura) / 15))

	var/list/datum/limb/parts = get_damageable_limbs()
	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/datum/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.take_damage_limb(brute, burn, sharp, edge)
		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked

	if(brute)
		camo_off_process(SCOUT_CLOAK_OFF_DAMAGE, brute) //If we have the Scout cloak, check for a short out
	if(burn)
		camo_off_process(SCOUT_CLOAK_OFF_DAMAGE, burn) //If we have the Scout cloak, check for a short out

	updatehealth()
	if(update)	UpdateDamageIcon()


////////////////////////////////////////////



/*
This function restores all limbs.
*/
/mob/living/carbon/human/restore_all_organs()
	for(var/datum/limb/E in limbs)
		E.rejuvenate()

	//replace missing internal organs
	for(var/organ_slot in species.has_organ)
		var/internal_organ_type = species.has_organ[organ_slot]
		if(!internal_organs_by_name[organ_slot])
			var/datum/internal_organ/IO = new internal_organ_type(src)
			internal_organs_by_name[organ_slot] = IO



/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/limb/E = get_limb(zone)
	if(E.heal_damage(brute, burn))
		UpdateDamageIcon()


/mob/living/carbon/proc/get_limb(zone)
	return

/mob/living/carbon/human/get_limb(zone)
	zone = check_zone(zone)
	for(var/X in limbs)
		var/datum/limb/EO = X
		if(EO.name == zone)
			return EO

/mob/living/carbon/human/apply_damage(var/damage = 0, var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/edge = 0, var/obj/used_weapon = null)

	if(blocked >= 1) //total negation
		return 0

	if(blocked)
		damage *= CLAMP01(1-blocked) //Percentage reduction

	if(!damage) //Complete negation
		return 0

	if(protection_aura)
		damage = round(damage * ((15 - protection_aura) / 15))

	//Handle other types of damage
	if((damagetype != BRUTE) && (damagetype != BURN))
		if(damagetype == HALLOSS && !(species && (species.species_flags & NO_PAIN)))
			if ((damage > 25 && prob(20)) || (damage > 50 && prob(40)))
				emote("pain")

		..(damage, damagetype, def_zone, blocked)
		return damage

	//Handle BRUTE and BURN damage
	handle_suit_punctures(damagetype, damage)

	var/datum/limb/organ = null
	if(isorgan(def_zone))
		organ = def_zone
	else
		if(!def_zone)	def_zone = ran_zone(def_zone)
		organ = get_limb(check_zone(def_zone))
	if(!organ)
		return FALSE

	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(species && species.brute_mod)
				damage = damage*species.brute_mod
			if(organ.take_damage_limb(damage, 0, sharp, edge))
				UpdateDamageIcon()
		if(BURN)
			damageoverlaytemp = 20
			if(species && species.burn_mod)
				damage = damage*species.burn_mod
			if(organ.take_damage_limb(0, damage, sharp, edge))
				UpdateDamageIcon()

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().

	camo_off_process(SCOUT_CLOAK_OFF_DAMAGE, damage) //If we have the Scout cloak, check for a short out

	updatehealth()
	return damage
