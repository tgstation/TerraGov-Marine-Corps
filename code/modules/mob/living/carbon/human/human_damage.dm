#define MAX_BRAINLOSS 200

//Updates the mob's health from limbs and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
		return
	var/total_burn = 0
	var/total_brute = 0
	for(var/datum/limb/O AS in limbs)	//hardcoded to streamline things a bit
		total_brute	+= O.brute_dam
		total_burn	+= O.burn_dam

	var/oxy_l = getOxyLoss()
	var/tox_l = ((species.species_flags & NO_POISON) ? 0 : getToxLoss())
	var/clone_l = getCloneLoss()

	health = maxHealth - oxy_l - tox_l - clone_l - total_burn - total_brute

	update_stat()
	med_pain_set_perceived_health()
	med_hud_set_health()
	med_hud_set_status()

	var/health_deficiency = max(1 - (health / maxHealth) * 100, staminaloss)

	if(health_deficiency >= 50)
		add_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN, TRUE, 0, NONE, TRUE, health_deficiency / 50)
	else
		remove_movespeed_modifier(MOVESPEED_ID_DAMAGE_SLOWDOWN)


/mob/living/carbon/human/adjustBrainLoss(amount, silent = FALSE)

	if(status_flags & GODMODE)
		return FALSE	//godmode

	if(species?.has_organ["brain"])
		var/datum/internal_organ/brain/sponge = internal_organs_by_name["brain"]
		if(sponge)
			sponge.take_damage(amount, silent)
			sponge.damage = clamp(sponge.damage, 0, MAX_BRAINLOSS)
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
			sponge.damage = clamp(amount, 0, MAX_BRAINLOSS)
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
			brainloss = min(sponge.damage, MAX_BRAINLOSS)
		else
			brainloss = 200 //No brain!
	else
		brainloss = 0
	return brainloss

//These procs fetch a cumulative total damage from all limbs
/mob/living/carbon/human/getBruteLoss(organic_only=FALSE)
	var/amount = 0
	for(var/datum/limb/O in limbs)
		if(!(organic_only && O.limb_status & LIMB_ROBOT))
			amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss(organic_only=FALSE)
	var/amount = 0
	for(var/datum/limb/O in limbs)
		if(!(organic_only && O.limb_status & LIMB_ROBOT))
			amount += O.burn_dam
	return amount


/mob/living/carbon/human/adjustBruteLoss(amount, updating_health = FALSE)
	if(species?.brute_mod && amount > 0)
		amount = amount*species.brute_mod

	if(amount > 0)
		take_overall_damage(amount, BRUTE, updating_health = updating_health)
	else
		heal_overall_damage(-amount, 0, updating_health = updating_health)


/mob/living/carbon/human/adjustFireLoss(amount, updating_health = FALSE)
	if(species?.burn_mod && amount > 0)
		amount = amount*species.burn_mod

	if(amount > 0)
		take_overall_damage(amount, BURN, updating_health = updating_health)
	else
		heal_overall_damage(0, -amount, updating_health = updating_health)


/mob/living/carbon/human/proc/adjustBruteLossByPart(amount, organ_name, obj/damage_source = null)
	if(species?.brute_mod && amount > 0)
		amount = amount*species.brute_mod

	for(var/X in limbs)
		var/datum/limb/O = X
		if(O.name == organ_name)
			if(amount > 0)
				O.take_damage_limb(amount, 0, is_sharp(damage_source), has_edge(damage_source))
			else
				//if you don't want to heal robot limbs, they you will have to check that yourself before using this proc.
				O.heal_limb_damage(-amount, robo_repair = (O.limb_status & LIMB_ROBOT))
			break


/mob/living/carbon/human/proc/adjustFireLossByPart(amount, organ_name, obj/damage_source = null)
	if(species?.burn_mod && amount > 0)
		amount = amount*species.burn_mod

	for(var/X in limbs)
		var/datum/limb/O = X
		if(O.name == organ_name)
			if(amount > 0)
				O.take_damage_limb(0, amount, is_sharp(damage_source), has_edge(damage_source))
			else
				//if you don't want to heal robot limbs, they you will have to check that yourself before using this proc.
				O.heal_limb_damage(burn = -amount, robo_repair = (O.limb_status & LIMB_ROBOT))
			break


/mob/living/carbon/human/getCloneLoss()
	if(species.species_flags & (IS_SYNTHETIC|NO_SCAN))
		cloneloss = 0
	return ..()

/mob/living/carbon/human/setCloneLoss(amount)
	if(species.species_flags & (IS_SYNTHETIC|NO_SCAN))
		cloneloss = 0
	else
		..()

/mob/living/carbon/human/adjustCloneLoss(amount)
	..()

	if(species.species_flags & (IS_SYNTHETIC|NO_SCAN))
		cloneloss = 0
		return


/mob/living/carbon/human/adjustOxyLoss(amount, forced = FALSE)
	if(species.species_flags & NO_BREATHE && !forced)
		oxyloss = 0
		return
	return ..()

/mob/living/carbon/human/setOxyLoss(amount, forced = FALSE)
	if(species.species_flags & NO_BREATHE && !forced)
		oxyloss = 0
		return
	return ..()

/mob/living/carbon/human/getToxLoss()
	if(species.species_flags & NO_POISON)
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(amount)
	if(species.species_flags & NO_POISON)
		toxloss = 0
	else
		..()

/mob/living/carbon/human/setToxLoss(amount)
	if(species.species_flags & NO_POISON)
		toxloss = 0
	else
		..()

/mob/living/carbon/human/getStaminaLoss()
	if(species.species_flags & NO_STAMINA)
		staminaloss = 0
		return staminaloss
	return ..()

/mob/living/carbon/human/adjustStaminaLoss(amount)
	if(species.species_flags & NO_STAMINA)
		staminaloss = 0
		return
	return ..()

/mob/living/carbon/human/setStaminaLoss(amount)
	if(species.species_flags & NO_STAMINA)
		staminaloss = 0
		return
	return ..()

////////////////////////////////////////////

//Returns a list of damaged limbs
/mob/living/carbon/human/proc/get_damaged_limbs(brute, burn, include_robotics = FALSE)
	var/list/datum/limb/parts = list()
	for(var/datum/limb/O in limbs)
		if(O.limb_status & LIMB_ROBOT && !include_robotics)
			continue
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
/mob/living/carbon/human/heal_limb_damage(brute, burn, robo_repair = FALSE, updating_health = FALSE)
	var/list/datum/limb/parts = get_damaged_limbs(brute, burn, robo_repair)
	if(!length(parts))
		return
	var/datum/limb/picked = pick(parts)
	if(picked.heal_limb_damage(brute, burn, robo_repair, updating_health))
		UpdateDamageIcon()

/*
In most cases it makes more sense to use apply_damage() instead! And make sure to check armour if applicable.
*/
//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_limb_damage(brute, burn, sharp = FALSE, edge = FALSE, updating_health = FALSE)
	var/list/datum/limb/parts = get_damageable_limbs()
	if(!length(parts))
		return
	var/datum/limb/picked = pick(parts)
	if(picked.take_damage_limb(brute, burn, sharp, edge, 0, updating_health))
		UpdateDamageIcon()

	SEND_SIGNAL(src, COMSIG_HUMAN_DAMAGE_TAKEN, brute + burn)


///Heal MANY limbs, in random order. If robo_repair is TRUE then both metal and flesh limbs will be healed, otherwise only flesh.
/mob/living/carbon/human/heal_overall_damage(brute, burn, robo_repair = FALSE, updating_health = FALSE)
	var/list/datum/limb/parts = get_damaged_limbs(brute, burn, robo_repair)

	var/update = 0
	while(length(parts) && (brute>0 || burn>0) )
		var/datum/limb/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_limb_damage(brute, burn, robo_repair)

		brute -= (brute_was - picked.brute_dam)
		burn -= (burn_was - picked.burn_dam)

		parts -= picked
	if(updating_health)
		updatehealth()
	if(update)
		UpdateDamageIcon()

//Damage all limbs on your body equally
/mob/living/carbon/human/take_overall_damage(damage, damagetype, armortype, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, max_limbs)
	if(status_flags & GODMODE)
		return

	var/list/datum/limb/parts = get_damageable_limbs()
	var/partcount = length(parts)
	if(!partcount)
		return
	if(max_limbs)
		partcount = min(partcount, max_limbs)
	damage = damage / partcount
	for(var/i=1 to partcount)
		var/datum/limb/picked = pick_n_take(parts)
		apply_damage(damage, damagetype, picked, armortype, sharp, edge, FALSE, penetration)

	if(updating_health)
		updatehealth()

////////////////////////////////////////////



/*
This function restores all limbs.
*/
/mob/living/carbon/human/restore_all_organs(updating_health = FALSE)
	for(var/datum/limb/E in limbs)
		E.rejuvenate()

	//replace missing internal organs
	for(var/organ_slot in species.has_organ)
		var/internal_organ_type = species.has_organ[organ_slot]
		if(!internal_organs_by_name[organ_slot])
			var/datum/internal_organ/IO = new internal_organ_type(src)
			internal_organs_by_name[organ_slot] = IO

	if(updating_health)
		updatehealth()


/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/limb/E = get_limb(zone)
	if(E.heal_limb_damage(brute, burn))
		UpdateDamageIcon()


/mob/living/carbon/proc/get_limb(zone)
	return

/mob/living/carbon/human/get_limb(zone)
	zone = check_zone(zone)
	for(var/X in limbs)
		var/datum/limb/EO = X
		if(EO.name != zone)
			continue
		return EO

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration)
	if(status_flags & (GODMODE))
		return
	return species.apply_damage(damage, damagetype, def_zone, blocked, sharp, edge, updating_health, penetration, src)

/mob/living/carbon/human/get_soft_armor(armor_type, proj_def_zone)
	if(!proj_def_zone)
		return ..()

	var/datum/limb/affected_limb

	if(isorgan(proj_def_zone))
		affected_limb = proj_def_zone
	else
		affected_limb = get_limb(proj_def_zone)

	return affected_limb.soft_armor.getRating(armor_type)

/mob/living/carbon/human/get_hard_armor(armor_type, proj_def_zone)
	if(!proj_def_zone)
		return ..()

	var/datum/limb/affected_limb

	if(isorgan(proj_def_zone))
		affected_limb = proj_def_zone
	else
		affected_limb = get_limb(proj_def_zone)

	return affected_limb.hard_armor.getRating(armor_type)
