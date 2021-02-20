
//procs directly related to mob health


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	bruteloss = clamp(bruteloss + amount, 0, maxHealth * 2)
	if(updating_health)
		updatehealth()


/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	fireloss = clamp(fireloss + amount, 0, maxHealth * 2)

	if(updating_health)
		updatehealth()


/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	oxyloss = clamp(oxyloss + amount, 0, maxHealth * 2)

/mob/living/proc/setOxyLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	oxyloss = amount


/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	toxloss = clamp(toxloss + amount, 0, maxHealth * 2)

/mob/living/proc/setToxLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	toxloss = amount


/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, update = TRUE, feedback = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode

	var/stamina_loss_adjustment = staminaloss + amount
	var/health_limit = maxHealth * 2
	if(stamina_loss_adjustment > health_limit) //If we exceed maxHealth * 2 stamina damage, apply any excess as oxyloss
		adjustOxyLoss(stamina_loss_adjustment - health_limit)

	staminaloss = clamp(stamina_loss_adjustment, -max_stamina_buffer, health_limit)

	if(amount > 0)
		last_staminaloss_dmg = world.time
	if(update)
		updateStamina(feedback)

/mob/living/proc/setStaminaLoss(amount, update = TRUE, feedback = TRUE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	staminaloss = amount
	if(update)
		updateStamina(feedback)

/mob/living/proc/updateStamina(feedback = TRUE)
	if(staminaloss < max(health * 1.5,0) || !(COOLDOWN_CHECK(src, last_stamina_exhaustion))) //If we're on cooldown for stamina exhaustion, don't bother
		return

	if(feedback)
		visible_message("<span class='warning'>\The [src] slumps to the ground, too weak to continue fighting.</span>",
			"<span class='warning'>You slump to the ground, you're too exhausted to keep going...</span>")

	ParalyzeNoChain(1 SECONDS) //Short stun
	adjust_stagger(STAMINA_EXHAUSTION_DEBUFF_STACKS)
	add_slowdown(STAMINA_EXHAUSTION_DEBUFF_STACKS)
	adjust_blurriness(STAMINA_EXHAUSTION_DEBUFF_STACKS)
	COOLDOWN_START(src, last_stamina_exhaustion, LIVING_STAMINA_EXHAUSTION_COOLDOWN) //set the cooldown.


/mob/living/carbon/human/updateStamina(feedback = TRUE)
	. = ..()
	if(!hud_used?.staminas)
		return
	if(stat == DEAD)
		hud_used.staminas.icon_state = "stamloss200"
		return
	var/relative_stamloss = getStaminaLoss()
	if(relative_stamloss < 0 && max_stamina_buffer)
		relative_stamloss = round(((relative_stamloss * 14) / max_stamina_buffer), 1)
	else
		relative_stamloss = round(((relative_stamloss * 7) / (maxHealth * 2)), 1)
	hud_used.staminas.icon_state = "stamloss[relative_stamloss]"


/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	cloneloss = clamp(cloneloss+amount,0,maxHealth*2)

/mob/living/proc/setCloneLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	cloneloss = amount

/mob/living/proc/getBrainLoss()
	return brainloss

/mob/living/proc/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	brainloss = clamp(brainloss+amount,0,maxHealth*2)

/mob/living/proc/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	brainloss = amount

/mob/living/proc/getMaxHealth()
	return maxHealth

/mob/living/proc/setMaxHealth(newMaxHealth)
	maxHealth = newMaxHealth

/mob/living/proc/Losebreath(amount, forced = FALSE)
	return

/mob/living/proc/adjust_Losebreath(amount, forced = FALSE)
	return

/mob/living/proc/set_Losebreath(amount, forced = FALSE)
	return

/mob/living/proc/adjustDrowsyness(amount)
	if(status_flags & GODMODE)
		return FALSE
	setDrowsyness(max(drowsyness + amount, 0))

/mob/living/proc/setDrowsyness(amount)
	if(status_flags & GODMODE)
		return FALSE
	if(drowsyness == amount)
		return
	. = drowsyness //Old value
	drowsyness = amount
	if(drowsyness)
		if(!.)
			add_movespeed_modifier(MOVESPEED_ID_DROWSINESS, TRUE, 0, NONE, TRUE, 6)
		return
	remove_movespeed_modifier(MOVESPEED_ID_DROWSINESS)


// heal ONE limb, organ gets randomly selected from damaged ones.
/mob/living/proc/heal_limb_damage(brute, burn, updating_health = FALSE)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	if(updating_health)
		updatehealth()


// damage ONE limb, organ gets randomly selected from damaged ones.
/mob/living/proc/take_limb_damage(brute, burn, sharp = FALSE, edge = FALSE, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	if(updating_health)
		updatehealth()


// heal MANY limbs, in random order
/mob/living/proc/heal_overall_damage(brute, burn, updating_health = FALSE)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	if(updating_health)
		updatehealth()


// damage MANY limbs, in random order
/mob/living/proc/take_overall_damage(brute, burn, blocked = 0, sharp = FALSE, edge = FALSE, updating_health = FALSE)
	if(status_flags & GODMODE)
		return 0//godmode

	var/hit_percent = (100 - blocked) * 0.01

	if(hit_percent <= 0) //total negation
		return 0

	if(blocked)
		if(brute)
			brute *= CLAMP01(hit_percent) //Percentage reduction
		if(burn)
			burn *= CLAMP01(hit_percent) //Percentage reduction

	if(!brute && !burn) //Complete negation
		return 0

	adjustBruteLoss(brute)
	adjustFireLoss(burn)
	if(updating_health)
		updatehealth()
	return TRUE

/// This proc causes damage evenly on a human mob limbs, accounting individual limb armor, if used on livings will just call take_overall_damage().
/mob/living/proc/take_overall_damage_armored(damage, damagetype, armortype, sharp = FALSE, edge = FALSE, updating_health = FALSE) //This proc is overrided on humans, otherwise it just applies some damage and checks armor on chest if not human.
	if(damagetype == BRUTE)
		return take_overall_damage(damage, 0, run_armor_check(BODY_ZONE_CHEST, armortype), sharp, edge, updating_health)
	if(damagetype == BURN)
		return take_overall_damage(0, damage, run_armor_check(BODY_ZONE_CHEST, armortype), sharp, edge, updating_health)
	return FALSE

/mob/living/proc/restore_all_organs()
	return


/mob/living/proc/on_revive()
	SEND_SIGNAL(src, COMSIG_MOB_REVIVE)
	timeofdeath = 0
	GLOB.alive_living_list += src
	GLOB.dead_mob_list -= src

/mob/living/carbon/human/on_revive()
	. = ..()
	revive_grace_time = initial(revive_grace_time)
	GLOB.alive_human_list += src
	GLOB.dead_human_list -= src
	LAZYADD(GLOB.humans_by_zlevel["[z]"], src)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, .proc/human_z_changed)

/mob/living/carbon/xenomorph/on_revive()
	. = ..()
	GLOB.alive_xeno_list += src
	GLOB.dead_xeno_list -= src

/mob/living/proc/revive()
	for(var/i in embedded_objects)
		var/obj/item/embedded = i
		embedded.unembed_ourself()

	// shut down various types of badness
	setStaminaLoss(0)
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	remove_all_status_effect()
	ExtinguishMob()
	fire_stacks = 0

	// shut down ongoing problems
	bodytemperature = get_standard_bodytemperature()
	disabilities = 0

	// fix blindness and deafness
	set_drugginess(0)
	set_blindness(0, TRUE)
	set_blurriness(0, TRUE)
	set_ear_damage(0, 0)
	heal_overall_damage(getBruteLoss(), getFireLoss())

	// fix all of our organs
	restore_all_organs()

	//remove larva
	var/obj/item/alien_embryo/A = locate() in src
	var/mob/living/carbon/xenomorph/larva/L = locate() in src //the larva was fully grown, ready to burst.
	if(A)
		qdel(A)
	if(L)
		qdel(L)
	DISABLE_BITFIELD(status_flags, XENO_HOST)

	// restore us to conciousness
	set_stat(CONSCIOUS)
	updatehealth()

	// make the icons look correct
	regenerate_icons()
	med_hud_set_status()
	med_pain_set_perceived_health()
	med_hud_set_health()
	handle_regular_hud_updates()
	reload_fullscreens()
	hud_used?.show_hud(hud_used.hud_version)

	SSmobs.start_processing(src)


/mob/living/carbon/revive()
	set_nutrition(400)
	setTraumatic_Shock(0)
	setShock_Stage(0)
	drunkenness = 0
	disabilities = 0

	if(handcuffed && !initial(handcuffed))
		dropItemToGround(handcuffed)
	update_handcuffed(initial(handcuffed))

	return ..()


/mob/living/carbon/human/revive()
	restore_all_organs()

	if(species && !(species.species_flags & NO_BLOOD))
		restore_blood()

	//try to find the brain player in the decapitated head and put them back in control of the human
	if(!client && !mind) //if another player took control of the human, we don't want to kick them out.
		for(var/i in GLOB.head_list)
			var/obj/item/limb/head/H = i
			if(!H.brainmob)
				continue

			if(H.brainmob.real_name != real_name)
				continue

			if(!H.brainmob.mind)
				continue

			H.brainmob.mind.transfer_to(src)
			qdel(H)

	for(var/datum/internal_organ/I in internal_organs)
		I.damage = 0

	reagents.clear_reagents() //and clear all reagents in them
	undefibbable = FALSE
	dead_ticks = 0
	chestburst = 0
	headbitten = FALSE
	update_body()
	update_hair()
	return ..()


/mob/living/carbon/xenomorph/revive()
	plasma_stored = xeno_caste.plasma_max
	stagger = 0
	sunder = 0
	set_slowdown(0)
	if(stat == DEAD)
		hive?.on_xeno_revive(src)
	return ..()
