/mob/living/carbon/xenomorph/larva
	caste_base_type = /mob/living/carbon/xenomorph/larva
	speak_emote = list("hisses")
	icon_state = "Bloody Larva"
	bubble_icon = "alien"

	a_intent = INTENT_HELP //Forces help intent for all interactions.

	maxHealth = 35
	health = 35
	see_in_dark = 8
	flags_pass = PASSTABLE | PASSMOB | PASSXENO
	tier = XENO_TIER_ZERO  //Larva's don't count towards Pop limits
	upgrade = XENO_UPGRADE_ZERO
	gib_chance = 25
	hud_type = /datum/hud/larva
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

	base_icon_state = "Larva"

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/larva/a_intent_change()
	if(xeno_caste.melee_damage)
		return ..()
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
	if(grown < 50)
		progress = "Bloody "
	else
		progress = xeno_caste.upgrade_name + " "

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

///Fully passive "ability" which lets larva push towards primo faster once they're ancient
/datum/action/xeno_action/larval_feast
	name = "Larval feast"
	action_icon_state = "headbite"
	desc = "Whenever we feast upon our prey, we speed ourselves towards greatness."
	ability_name = "larval feast"

/datum/action/xeno_action/larval_feast/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_HUMAN, PROC_REF(feasting))

/datum/action/xeno_action/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_XENOMORPH_ATTACK_HUMAN)

/datum/action/xeno_action/larval_feast/can_use_action()
	return TRUE

///Signal handler, increase age when you bite a human
/datum/action/xeno_action/proc/feasting()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	X.upgrade_stored += 1000
