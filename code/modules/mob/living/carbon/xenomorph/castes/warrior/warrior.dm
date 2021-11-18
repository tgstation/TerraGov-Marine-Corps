/mob/living/carbon/xenomorph/warrior
	caste_base_type = /mob/living/carbon/xenomorph/warrior
	name = "Warrior"
	desc = "A beefy, alien with an armored carapace."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Warrior Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO

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

/mob/living/carbon/xenomorph/warrior/start_pulling(atom/movable/AM, suppress_message = TRUE, lunge = FALSE)
	if(!check_state() || agility || !isliving(AM))
		return FALSE

	var/mob/living/L = AM

	if(isxeno(L))
		var/mob/living/carbon/xenomorph/X = L
		if(issamexenohive(X)) //No neckgrabbing of allies.
			return ..()

	if(lunge && ..())
		return neck_grab(L)

	. = ..(L, suppress_message)

/mob/living/carbon/xenomorph/warrior/proc/neck_grab(mob/living/L)
	GLOB.round_statistics.warrior_grabs++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_grabs")
	setGrabState(GRAB_NECK)
	ENABLE_BITFIELD(L.restrained_flags, RESTRAINED_NECKGRAB)
	RegisterSignal(L, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
	L.drop_all_held_items()
	L.Paralyze(1)
	visible_message(span_xenowarning("\The [src] grabs [L] by the throat!"), \
	span_xenowarning("We grab [L] by the throat!"))
	return TRUE


/mob/living/carbon/xenomorph/warrior/resisted_against(datum/source)
	var/mob/living/victim = source
	victim.do_resist_grab()


/mob/living/carbon/xenomorph/warrior/hitby(atom/movable/AM, speed = 5)
	if(ishuman(AM))
		return
	..()

///Handles primordial warrior empowered abilities, return TRUE if the ability should be empowered.
/mob/living/carbon/xenomorph/warrior/proc/empower()
	if(upgrade != XENO_UPGRADE_FOUR)
		return FALSE
	var/datum/xeno_caste/warrior/primordial/caste = xeno_caste
	if(caste.combo >= WARRIOR_COMBO_THRESHOLD) //Fully stacked, clear all the stacks and return TRUE.
		//Update abilities icons
		src.emote("roar")
		src.clear_combo()
		return TRUE
	var/image/counter = image(null, src, null) //Visual clue for the warrior
	caste.combo++
	counter.maptext = MAPTEXT("[caste.combo]")
	src.client.images += counter
	//for(var/datum/action/xeno_action/activable/i in caste.actions)
	//	var/image/x = image('icons/mob/actions.dmi', null, "borders_center")
	//	x.y = 7
	//	i.button.overlays += x
	//	i.update_button_icon()
	addtimer(CALLBACK(src,.proc/clear_counter, counter), WARRIOR_COMBO_FADEOUT_TIME)
	addtimer(CALLBACK(src, .proc/clear_combo, counter), WARRIOR_COMBO_FADEOUT_TIME, TIMER_OVERRIDE|TIMER_UNIQUE)
	return FALSE

/mob/living/carbon/xenomorph/warrior/proc/give_combo() //Only useful for lunge because it gives stacks but doesn't consume any, use empower() otherwise.
	if(upgrade != XENO_UPGRADE_FOUR)
		return FALSE
	var/datum/xeno_caste/warrior/primordial/caste = xeno_caste
	caste.combo++
	return TRUE

/mob/living/carbon/xenomorph/warrior/proc/clear_combo()
	var/datum/xeno_caste/warrior/primordial/caste = xeno_caste
	caste.combo = 0
	//for(var/datum/action/xeno_action/activable/i in caste.actions)
	//	i.clear_icon()
	//	i.update_button_icon()

/mob/living/carbon/xenomorph/warrior/proc/clear_counter(image/counter)
	src.client.images.Remove(counter)
