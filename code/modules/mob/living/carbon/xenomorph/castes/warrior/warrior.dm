/mob/living/carbon/xenomorph/warrior
	caste_base_type = /mob/living/carbon/xenomorph/warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/castes/warrior.dmi'
	icon_state = "Warrior Walking"
	bubble_icon = "alienroyal"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	///How many stacks of combo do we have ? Interacts with every ability.
	var/combo = 0
	///Abilities with empowered interactions
	var/list/empowerable_actions = list(
		/datum/action/ability/activable/xeno/fling,
		/datum/action/ability/activable/xeno/toss,
		/datum/action/ability/activable/xeno/punch,
		/datum/action/ability/activable/xeno/punch/jab,
	)
// ***************************************
// *********** Icons
// ***************************************
/mob/living/carbon/xenomorph/warrior/handle_special_state()
	if(agility)
		icon_state = "Warrior Agility"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/warrior/handle_special_wound_states(severity)
	. = ..()
	if(agility)
		return "warrior_wounded_agility_[severity]"

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/warrior/stop_pulling()
	if(isliving(pulling) && !isxeno(pulling))
		var/mob/living/L = pulling
		grab_resist_level = 0 //zero it out
		L.SetStun(0)
		UnregisterSignal(L, COMSIG_LIVING_DO_RESIST)
	..()

/mob/living/carbon/xenomorph/warrior/start_pulling(atom/movable/AM, force = move_force, suppress_message = TRUE, lunge = FALSE)
	if(!check_state())
		return FALSE

	if(agility)
		balloon_alert(src, "Cannot in agility mode")
		return FALSE

	var/mob/living/L = AM

	if(isxeno(L))
		var/mob/living/carbon/xenomorph/X = L
		if(issamexenohive(X)) //No neckgrabbing of allies.
			return ..()

	if(lunge && ..())
		return neck_grab(L)

	. = ..(L, force, suppress_message)

/mob/living/carbon/xenomorph/warrior/proc/neck_grab(mob/living/L)
	GLOB.round_statistics.warrior_grabs++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_grabs")
	setGrabState(GRAB_NECK)
	ENABLE_BITFIELD(L.restrained_flags, RESTRAINED_NECKGRAB)
	RegisterSignal(L, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against))
	L.drop_all_held_items()
	L.Paralyze(0.1 SECONDS)
	visible_message(span_xenowarning("\The [src] grabs [L] by the throat!"), \
	span_xenowarning("We grab [L] by the throat!"))
	return TRUE


/mob/living/carbon/xenomorph/warrior/resisted_against(datum/source)
	var/mob/living/victim = source
	victim.do_resist_grab()

// ***************************************
// *********** Primordial procs
// ***************************************
///Handles primordial warrior empowered abilities, returns TRUE if the ability should be empowered.
/mob/living/carbon/xenomorph/warrior/empower(empowerable = TRUE)
	. = ..()
	if(!empowerable) //gives combo but doesn't combo but doesn't consume it.
		give_combo()
		return FALSE
	if(upgrade != XENO_UPGRADE_PRIMO)
		return FALSE
	if(combo >= WARRIOR_COMBO_THRESHOLD) //Fully stacked, clear all the stacks and return TRUE.
		emote("roar")
		clear_combo()
		return TRUE
	give_combo()
	return FALSE

///Primordial warriors empowered ability trigger when they get 3 combo stacks, handles visuals aswell.
/mob/living/carbon/xenomorph/warrior/proc/give_combo()
	if(upgrade != XENO_UPGRADE_PRIMO)
		return FALSE
	combo++
	if(combo >= WARRIOR_COMBO_THRESHOLD)
		for(var/datum/action/ability/xeno_action/A AS in actions)
			if(A.type in empowerable_actions)
				A.add_empowered_frame()
				A.update_button_icon()
	addtimer(CALLBACK(src, PROC_REF(clear_combo)), WARRIOR_COMBO_FADEOUT_TIME, TIMER_OVERRIDE|TIMER_UNIQUE)
	return TRUE

///Removes all combo stacks from the warrior, removes the frame around the ability buttons.
/mob/living/carbon/xenomorph/warrior/proc/clear_combo()
	for(var/datum/action/ability/xeno_action/A AS in actions)
		if(A.type in empowerable_actions)
			A.remove_empowered_frame()
			A.update_button_icon()
	combo = 0
