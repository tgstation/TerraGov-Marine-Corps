/mob/living/carbon/xenomorph/larva
	caste_base_type = /mob/living/carbon/xenomorph/larva
	speak_emote = list("hisses")
	icon_state = "Bloody Larva"
	bubble_icon = "alien"

	a_intent = INTENT_HELP //Forces help intent for all interactions.

	maxHealth = 35
	health = 35
	see_in_dark = 8
	allow_pass_flags = PASS_MOB|PASS_XENO
	pass_flags = PASS_LOW_STRUCTURE|PASS_MOB|PASS_XENO
	tier = XENO_TIER_ZERO  //Larva's don't count towards Pop limits
	upgrade = XENO_UPGRADE_INVALID
	gib_chance = 25
	hud_type = /datum/hud/larva
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	base_icon_state = "Larva"

/mob/living/carbon/xenomorph/larva/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/larva/a_intent_change()
	return

/mob/living/carbon/xenomorph/larva/start_pulling(atom/movable/AM, force = move_force, suppress_message = FALSE)
	return FALSE

/mob/living/carbon/xenomorph/larva/pull_response(mob/puller)
	return TRUE

// ***************************************
// *********** Name
// ***************************************
/mob/living/carbon/xenomorph/larva/generate_name()
	var/progress = "" //Naming convention, three different names

	var/grown = (evolution_stored / xeno_caste.evolution_threshold) * 100
	switch(grown)
		if(0 to 49) //We're still bloody
			progress = "Bloody "
		if(100 to INFINITY)
			progress = "Mature "

	name = "[hive.prefix][progress]Larva ([nicknumber])"

	//Update linked data so they show up properly
	real_name = name
	if(mind)
		mind.name = name //This gives them the proper name in deadchat if they explode on death. It's always the small things

// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/larva/update_icons()
	generate_name()

	var/bloody = ""
	var/grown = (evolution_stored / xeno_caste.evolution_threshold) * 100
	if(grown < 50)
		bloody = "Bloody "

	color = hive.color

	if(stat == DEAD)
		icon_state = "[bloody][base_icon_state] Dead"
	else if(handcuffed)
		icon_state = "[bloody][base_icon_state] Cuff"

	else if(lying_angle)
		if((resting || IsSleeping()) && (!IsParalyzed() && !IsUnconscious() && health > 0))
			icon_state = "[bloody][base_icon_state] Sleeping"
		else
			icon_state = "[bloody][base_icon_state] Stunned"
	else
		icon_state = "[bloody][base_icon_state]"

// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/larva/on_death()
	log_game("[key_name(src)] died as a Larva at [AREACOORD(src)].")
	message_admins("[ADMIN_TPMONTY(src)] died as a Larva.")
	return ..()

/mob/living/carbon/xenomorph/larva/spec_evolution_boost()
	if(!loc_weeds_type)
		return 0
	return 1
