
//procs directly related to mob health


/mob/living/proc/getBruteLoss(organic_only = FALSE)
	return bruteloss

///We straight up set bruteloss/brute damage to a desired amount unless godmode is enabled
/mob/living/proc/setBruteLoss(amount)
	if(status_flags & GODMODE)
		return FALSE
	bruteloss = amount

/mob/living/proc/adjustBruteLoss(amount, updating_health = FALSE)
	if(status_flags & GODMODE)
		return FALSE	//godmode
	bruteloss = clamp(bruteloss + amount, 0, maxHealth * 2)
	if(updating_health)
		updatehealth()


/mob/living/proc/getFireLoss(organic_only = FALSE)
	return fireloss

///We straight up set fireloss/burn damage to a desired amount unless godmode is enabled
/mob/living/proc/setFireLoss(amount)
	if(status_flags & GODMODE)
		return FALSE
	fireloss = amount

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
	if(stamina_loss_adjustment > health_limit) //If we exceed maxHealth * 2 stamina damage, half of any excess as oxyloss
		adjustOxyLoss((stamina_loss_adjustment - health_limit) * 0.5)

	staminaloss = clamp(stamina_loss_adjustment, -max_stamina, health_limit)

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
		visible_message(span_warning("\The [src] slumps to the ground, too weak to continue fighting."),
			span_warning("You slump to the ground, you're too exhausted to keep going..."))

	ParalyzeNoChain(1 SECONDS) //Short stun
	adjust_stagger(STAMINA_EXHAUSTION_STAGGER_DURATION)
	add_slowdown(STAMINA_EXHAUSTION_DEBUFF_STACKS)
	adjust_blurriness(STAMINA_EXHAUSTION_DEBUFF_STACKS)
	COOLDOWN_START(src, last_stamina_exhaustion, LIVING_STAMINA_EXHAUSTION_COOLDOWN - (skills.getRating(SKILL_STAMINA) * STAMINA_SKILL_COOLDOWN_MOD)) //set the cooldown.


/mob/living/carbon/human/updateStamina(feedback = TRUE)
	. = ..()
	if(!hud_used?.staminas)
		return
	if(stat == DEAD)
		hud_used.staminas.icon_state = "stamloss200"
		return
	var/relative_stamloss = getStaminaLoss()
	if(relative_stamloss < 0 && max_stamina)
		relative_stamloss = round(((relative_stamloss * 14) / max_stamina), 1)
	else
		relative_stamloss = round(((relative_stamloss * 7) / (maxHealth * 2)), 1)
	hud_used.staminas.icon_state = "stamloss[relative_stamloss]"

/// Adds an entry to our stamina_regen_modifiers and updates stamina_regen_multiplier
/mob/living/proc/add_stamina_regen_modifier(mod_name, mod_value)
	if(stamina_regen_modifiers[mod_name] == mod_value)
		return
	stamina_regen_modifiers[mod_name] = mod_value
	recalc_stamina_regen_multiplier()

/// Removes an entry from our stamina_regen_modifiers and updates stamina_regen_multiplier. Returns TRUE if an entry was removed
/mob/living/proc/remove_stamina_regen_modifier(mod_name)
	if(!stamina_regen_modifiers.Remove(mod_name))
		return FALSE
	recalc_stamina_regen_multiplier()
	return TRUE

/// Regenerates stamina_regen_multiplier from initial based on the current modifier list, minimum 0.
/mob/living/proc/recalc_stamina_regen_multiplier()
	stamina_regen_multiplier = initial(stamina_regen_multiplier)
	for(var/mod_name in stamina_regen_modifiers)
		stamina_regen_multiplier += stamina_regen_modifiers[mod_name]
	stamina_regen_multiplier = max(stamina_regen_multiplier, 0)

///Updates the mob's stamina modifiers if their stam skill changes
/mob/living/proc/update_stam_skill_mod(datum/source)
	SIGNAL_HANDLER
	add_stamina_regen_modifier(SKILL_STAMINA, skills.getRating(SKILL_STAMINA) * STAMINA_SKILL_REGEN_MOD)

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
/mob/living/proc/heal_limb_damage(brute, burn, robo_repair = FALSE, updating_health = FALSE)
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
/mob/living/proc/heal_overall_damage(brute, burn, robo_repair = FALSE, updating_health = FALSE)
	adjustBruteLoss(-brute)
	adjustFireLoss(-burn)
	if(updating_health)
		updatehealth()


///Damages all limbs equally. Overridden by human, otherwise just does apply_damage
/mob/living/proc/take_overall_damage(damage, damagetype, armortype, sharp = FALSE, edge = FALSE, updating_health = FALSE, penetration, max_limbs)
	return apply_damage(damage, damagetype, null, armortype, sharp, edge, updating_health, penetration)

/mob/living/proc/restore_all_organs()
	return

///Heal limbs until the total mob health went up by health_to_heal
/mob/living/carbon/human/proc/heal_limbs(health_to_heal)
	var/proportion_to_heal = (health_to_heal < (maxHealth - health)) ? (health_to_heal / (maxHealth - health)) : 1
	for(var/datum/limb/limb AS in limbs)
		limb.heal_limb_damage(limb.brute_dam * proportion_to_heal, limb.burn_dam * proportion_to_heal, robo_repair = TRUE)
	updatehealth()

/mob/living/proc/on_revive()
	SEND_SIGNAL(src, COMSIG_MOB_REVIVE)
	timeofdeath = 0
	GLOB.alive_living_list += src
	GLOB.dead_mob_list -= src

/mob/living/carbon/human/on_revive()
	. = ..()
	revive_grace_time = initial(revive_grace_time)
	GLOB.alive_human_list += src
	LAZYADD(GLOB.alive_human_list_faction[faction], src)
	GLOB.dead_human_list -= src
	LAZYADD(GLOB.humans_by_zlevel["[z]"], src)
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(human_z_changed))

	hud_list[HEART_STATUS_HUD].icon_state = ""

/mob/living/carbon/xenomorph/on_revive()
	. = ..()
	GLOB.alive_xeno_list += src
	LAZYADD(GLOB.alive_xeno_list_hive[hivenumber], src)
	GLOB.dead_xeno_list -= src

/mob/living/proc/revive(admin_revive = FALSE)
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
	heal_overall_damage(getBruteLoss(), getFireLoss(), robo_repair = TRUE)
	set_slowdown(0)

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
	SEND_SIGNAL(src, COMSIG_LIVING_POST_FULLY_HEAL, admin_revive)


/mob/living/carbon/revive(admin_revive = FALSE)
	set_nutrition(400)
	setTraumatic_Shock(0)
	setShock_Stage(0)
	drunkenness = 0
	disabilities = 0

	if(handcuffed && !initial(handcuffed))
		dropItemToGround(handcuffed)
	update_handcuffed(initial(handcuffed))

	return ..()


/mob/living/carbon/human/revive(admin_revive = FALSE)
	restore_all_organs()

	if(species && !(species.species_flags & NO_BLOOD))
		restore_blood()

	//try to find the brain player in the decapitated head and put them back in control of the human
	if(!client && !mind) //if another player took control of the human, we don't want to kick them out.
		for(var/obj/item/limb/head/H AS in GLOB.head_list)
			if(!H.brainmob)
				continue

			if(H.brainmob.real_name != real_name)
				continue

			if(!H.brainmob.mind)
				continue

			H.brainmob.mind.transfer_to(src)
			qdel(H)

	for(var/datum/internal_organ/I in internal_organs)
		I.heal_organ_damage(I.damage)

	reagents.clear_reagents() //and clear all reagents in them
	REMOVE_TRAIT(src, TRAIT_UNDEFIBBABLE, TRAIT_UNDEFIBBABLE)
	REMOVE_TRAIT(src, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
	dead_ticks = 0
	chestburst = 0
	update_body()
	update_hair()
	return ..()


/mob/living/carbon/xenomorph/revive(admin_revive = FALSE)
	plasma_stored = xeno_caste.plasma_max
	sunder = 0
	if(stat == DEAD)
		hive?.on_xeno_revive(src)
	return ..()

///Revive the huamn up to X health points
/mob/living/carbon/human/proc/revive_to_crit(should_offer_to_ghost = FALSE, should_zombify = FALSE)
	if(!has_working_organs())
		on_fire = TRUE
		fire_stacks = 15
		update_fire()
		QDEL_IN(src, 1 MINUTES)
		return
	if(health > 0)
		return
	var/mob/dead/observer/ghost = get_ghost()
	if(istype(ghost))
		notify_ghost(ghost, "<font size=3>Your body slowly regenerated. Return to it if you want to be resurrected!</font>", ghost_sound = 'sound/effects/adminhelp.ogg', enter_text = "Enter", enter_link = "reentercorpse=1", source = src, action = NOTIFY_JUMP)
	do_jitter_animation(1000)
	ADD_TRAIT(src, TRAIT_IS_RESURRECTING, REVIVE_TO_CRIT_TRAIT)
	if(should_zombify && (istype(wear_ear, /obj/item/radio/headset/mainship)))
		var/obj/item/radio/headset/mainship/radio = wear_ear
		if(istype(radio))
			radio.safety_protocol(src)
	addtimer(CALLBACK(src, PROC_REF(finish_revive_to_crit), should_offer_to_ghost, should_zombify), 10 SECONDS)

///Check if we have a mind, and finish the revive if we do
/mob/living/carbon/human/proc/finish_revive_to_crit(should_offer_to_ghost = FALSE, should_zombify = FALSE)
	if(!has_working_organs())
		on_fire = TRUE
		fire_stacks = 15
		update_icon()
		QDEL_IN(src, 1 MINUTES)
		return
	do_jitter_animation(1000)
	if(!client)
		if(should_offer_to_ghost)
			offer_mob()
			addtimer(CALLBACK(src, PROC_REF(finish_revive_to_crit), FALSE, should_zombify), 10 SECONDS)
			return
		REMOVE_TRAIT(src, TRAIT_IS_RESURRECTING, REVIVE_TO_CRIT_TRAIT)
		if(should_zombify || istype(species, /datum/species/zombie))
			AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie/patrolling, src) //Zombie patrol
			a_intent = INTENT_HARM
	if(should_zombify)
		set_species("Strong zombie")
		faction = FACTION_ZOMBIE
	heal_limbs(- health)
	set_stat(CONSCIOUS)
	overlay_fullscreen_timer(0.5 SECONDS, 10, "roundstart1", /atom/movable/screen/fullscreen/black)
	overlay_fullscreen_timer(2 SECONDS, 20, "roundstart2", /atom/movable/screen/fullscreen/spawning_in)
	REMOVE_TRAIT(src, TRAIT_IS_RESURRECTING, REVIVE_TO_CRIT_TRAIT)
	SSmobs.start_processing(src)

