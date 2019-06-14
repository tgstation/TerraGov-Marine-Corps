
//procs directly related to mob health


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	bruteloss = CLAMP(bruteloss+amount,0,maxHealth*2)

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	oxyloss = CLAMP(oxyloss+amount,0,maxHealth*2)

/mob/living/proc/setOxyLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	oxyloss = amount

/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	toxloss = CLAMP(toxloss+amount,0,maxHealth*2)

/mob/living/proc/setToxLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	toxloss = amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	fireloss = CLAMP(fireloss+amount,0,maxHealth*2)

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	cloneloss = CLAMP(cloneloss+amount,0,maxHealth*2)

/mob/living/proc/setCloneLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	brainloss = CLAMP(brainloss+amount,0,maxHealth*2)

/mob/living/proc/setBrainLoss(var/amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	brainloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(var/newMaxHealth)
	maxHealth = newMaxHealth

mob/living/proc/adjustHalLoss(amount) //This only makes sense for carbon.
	return

/mob/living/proc/Losebreath(amount, forced = FALSE)
	return

/mob/living/proc/adjust_Losebreath(amount, forced = FALSE)
	return

/mob/living/proc/set_Losebreath(amount, forced = FALSE)
	return






// heal ONE limb, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_limb_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage ONE limb, organ gets randomly selected from damaged ones.
/mob/living/proc/take_limb_damage(var/brute, var/burn)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

// heal MANY limbs, in random order
/mob/living/proc/heal_overall_damage(var/brute, var/burn)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	src.updatehealth()

// damage MANY limbs, in random order
/mob/living/proc/take_overall_damage(var/brute, var/burn, var/used_weapon = null, var/blocked = 0)
	if(status_flags & GODMODE)
		return 0//godmode

	if(blocked >= 1) //Complete negation
		return 0

	if(blocked)
		if(brute)
			brute *= CLAMP(1-blocked,0.00,1.00) //Percentage reduction
		if(burn)
			burn *= CLAMP(1-blocked,0.00,1.00) //Percentage reduction

	if(!brute && !burn) //Complete negation
		return 0

	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	src.updatehealth()

/mob/living/proc/restore_all_organs()
	return



/mob/living/proc/revive()
	rejuvenate()

/mob/living/proc/on_revive()
	GLOB.alive_mob_list += src
	GLOB.dead_mob_list -= src

/mob/living/carbon/human/on_revive()
	. = ..()
	GLOB.alive_human_list += src
	GLOB.dead_human_list -= src

/mob/living/carbon/xenomorph/on_revive()
	. = ..()
	GLOB.alive_xeno_list += src
	GLOB.dead_xeno_list -= src

/mob/living/proc/rejuvenate()

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	SetKnockedout(0)
	SetStunned(0)
	SetKnockeddown(0)
	ExtinguishMob()
	fire_stacks = 0

	// shut down ongoing problems
	radiation = 0
	bodytemperature = get_standard_bodytemperature()
	sdisabilities = 0

	// fix blindness and deafness
	set_blindness(0, TRUE)
	set_blurriness(0, TRUE)
	setEarDamage(0, 0)
	heal_overall_damage(getBruteLoss(), getFireLoss())

	// fix all of our organs
	restore_all_organs()

	// remove the character from the list of the dead
	if(stat == DEAD)
		on_revive()
		timeofdeath = 0

	SSmobs.start_processing(src)

	// restore us to conciousness
	stat = CONSCIOUS
	updatehealth()

	// make the icons look correct
	regenerate_icons()
	med_hud_set_status()
	med_pain_set_perceived_health()
	med_hud_set_health()
	handle_regular_hud_updates()
	reload_fullscreens()

/mob/living/carbon/rejuvenate()
	nutrition = 400
	setHalLoss(0)
	setTraumatic_Shock(0)
	setShock_Stage(0)
	drunkenness = 0
	disabilities = 0
	return ..()

/mob/living/carbon/human/rejuvenate()
	restore_blood() //restore all of a human's blood
	reagents.clear_reagents() //and clear all reagents in them
	undefibbable = FALSE
	chestburst = 0
	return ..()

/mob/living/carbon/xenomorph/rejuvenate()
	plasma_stored = xeno_caste.plasma_max
	stagger = 0
	slowdown = 0
	if(stat == DEAD)
		hive?.on_xeno_revive(src)
	return ..()