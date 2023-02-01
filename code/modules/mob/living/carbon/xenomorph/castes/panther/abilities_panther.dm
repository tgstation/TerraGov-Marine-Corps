/// runner abilities
/datum/action/xeno_action/activable/psydrain/panther
	plasma_cost = 10

/datum/action/xeno_action/evasion/panther
	plasma_cost = 50

/datum/action/xeno_action/activable/pounce/panther
	plasma_cost = 20
	pantherplasmaheal = 45

///////////////////////////////////
// ***************************************
// *********** Tearing tail
// ***************************************

/datum/action/xeno_action/tearingtail
	name = "Tearing tail"
	action_icon_state = "tearing_tail"
	desc = "Hit all adjacent units around you, poisoning them toxin for their mind."
	ability_name = "tearing tail"
	plasma_cost = 50
	cooldown_timer = 15 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TEARING_TAIL,
	)

/datum/action/xeno_action/tearingtail/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	X.add_filter("defender_tail_sweep", 2, gauss_blur_filter(1)) //Add cool SFX
	X.spin(4, 1)
	X.enable_throw_parry(0.6 SECONDS)
	playsound(X,pick('sound/effects/alien_tail_swipe1.ogg','sound/effects/alien_tail_swipe2.ogg','sound/effects/alien_tail_swipe3.ogg'), 25, 1) //Sound effects

	var/sweep_range = 1
	var/list/L = orange(sweep_range, X)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		if(H.stat != DEAD && !isnestedhost(H) ) //No bully
			var/damage = X.xeno_caste.melee_damage
			var/affecting = H.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			H.apply_damage(damage*2, BRUTE, affecting, MELEE)
			X.plasma_stored += 25
			X.heal_overall_damage(25, 25, updating_health = TRUE)
			H.reagents.add_reagent(/datum/reagent/toxin/mindbreaker, 1)
			playsound(H, 'sound/effects/spray3.ogg', 15, TRUE)
		shake_camera(H, 2, 1)
		to_chat(H, span_xenowarning("We are hit by \the [X]'s tail sweep!"))
		playsound(H,'sound/weapons/alien_tail_attack.ogg', 50, 1)

	addtimer(CALLBACK(X, /atom.proc/remove_filter, "defender_tail_sweep"), 0.5 SECONDS) //Remove cool SFX
	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/tearingtail/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We gather enough strength to tear the skin again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

///////////////////////////////////
// ***************************************
// *********** Adrenaline Jump
// ***************************************
// lunge+fling idk

/datum/action/xeno_action/activable/adrenalinejump
	name = "Adrenaline Jump"
	action_icon_state = "lunge"
	desc = "Jump from some distance to target, knocking them down."
	ability_name = "adrenaline jump"
	plasma_cost = 10
	cooldown_timer = 13 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ADRENALINE_JUMP,
	)
	target_flags = XABB_MOB_TARGET
	/// The target of our lunge, we keep it to check if we are adjacent everytime we move
	var/atom/lunge_target

/datum/action/xeno_action/activable/adrenalinejump/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We ready ourselves to jump again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/adrenalinejump/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(get_dist_euclide_square(A, owner) > 18)
		if(!silent)
			to_chat(owner, span_xenonotice("You are too far!"))
		return FALSE

	if(!isliving(A))
		if(!silent)
			to_chat(owner, span_xenodanger("We can't jump at that!"))
		return FALSE

	var/mob/living/living_target = A
	if(living_target.stat == DEAD)
		if(!silent)
			to_chat(owner, span_xenodanger("We can't jump at that!"))
		return FALSE

/datum/action/xeno_action/activable/adrenalinejump/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	X.visible_message(span_xenowarning("\The [X] jump towards [A]!"), \
	span_xenowarning("We lunge at [A]!"))

	lunge_target = A

	RegisterSignal(lunge_target, COMSIG_PARENT_QDELETING, .proc/clean_lunge_target)
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, .proc/clean_lunge_target)
	if(lunge_target.Adjacent(X)) //They're already in range, neck grab without lunging.
		playsound(X,'sound/weapons/thudswoosh.ogg', 75, 1)
		X.plasma_stored += -50
	else
		X.throw_at(get_step_towards(A, X), 6, 2, X)
		pantherfling(lunge_target)
		X.plasma_stored += 50

	if(X.pulling && !isxeno(X.pulling)) //If we grabbed something give us combo.
		X.empower(empowerable = FALSE) //Doesn't have a special interaction
	succeed_activate()
	add_cooldown()
	var/datum/action/xeno_action/pounce = X.actions_by_path[/datum/action/xeno_action/activable/pounce/panther]
	if(pounce)
		pounce.add_cooldown()
	return TRUE

///Do a last check to see if we can grab the target, and then clean up after the throw. Handles an in-place lunge.
/datum/action/xeno_action/activable/adrenalinejump/proc/finish_lunge(datum/source)
	SIGNAL_HANDLER
	if(lunge_target) //Still couldn't get them.
		clean_lunge_target()

/// Null lunge target and reset throw vars
/datum/action/xeno_action/activable/adrenalinejump/proc/clean_lunge_target()
	SIGNAL_HANDLER
	UnregisterSignal(lunge_target, COMSIG_PARENT_QDELETING)
	UnregisterSignal(owner, COMSIG_MOVABLE_POST_THROW)
	lunge_target = null
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.stop_throw()
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/datum/action/xeno_action/activable/adrenalinejump/proc/pantherfling(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/lunge_target = A
	var/facing = get_dir(X, lunge_target)
	var/fling_distance = 1

	X.face_atom(lunge_target) //Face towards the victim

	X.visible_message(span_xenowarning("\The [X] effortlessly flings [lunge_target] away!"), \
	span_xenowarning("We effortlessly fling [lunge_target] away!"))
	playsound(lunge_target,'sound/weapons/alien_claw_block.ogg', 75, 1)

	var/turf/T = X.loc
	var/turf/temp = X.loc
	var/empowered = X.empower() //Should it knockdown everyone down its path ?

	for (var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if (!temp)
			break
		if(empowered)
			for(var/mob/living/carbon/human/human in temp)
				human.KnockdownNoChain(2 SECONDS) //Bowling pins
				to_chat(human, span_highdanger("[lunge_target] crashes into us!"))
		T = temp

	X.do_attack_animation(lunge_target, ATTACK_EFFECT_DISARM2)
	lunge_target.throw_at(T, fling_distance, 1, X, 1)

	if(isxeno(lunge_target))
		var/mob/living/carbon/xenomorph/x_lunge_target = lunge_target
		if(X.issamexenohive(x_lunge_target)) //We don't fuck up friendlies
			return

	lunge_target.ParalyzeNoChain(1 SECONDS)

///////////////////////////////////
// ***************************************
// *********** Adrenaline rush
// ***************************************

/datum/action/xeno_action/adrenaline_rush
	name = "Adrenaline rush"
	action_icon_state = "adrenaline_rush"
	desc = "Move faster."
	plasma_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ADRENALINE_RUSH,
	)
	use_state_flags = XACT_USE_LYING
	action_type = ACTION_TOGGLE
	var/speed_activated = FALSE
	var/speed_bonus_active = FALSE

/datum/action/xeno_action/adrenaline_rush/remove_action()
	resinwalk_off(TRUE) // Ensure we remove the movespeed
	return ..()

/datum/action/xeno_action/adrenaline_rush/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(speed_activated)
		return TRUE

/datum/action/xeno_action/adrenaline_rush/action_activate()
	if(speed_activated)
		resinwalk_off()
		return fail_activate()
	resinwalk_on()
	succeed_activate()


/datum/action/xeno_action/adrenaline_rush/proc/resinwalk_on(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	speed_activated = TRUE
	if(!silent)
		owner.balloon_alert(owner, "It's time to run")
	if(walker.loc_weeds_type)
		speed_bonus_active = TRUE
		walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
	set_toggle(TRUE)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/resinwalk_on_moved)


/datum/action/xeno_action/adrenaline_rush/proc/resinwalk_off(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	if(!silent)
		owner.balloon_alert(owner, "Adrenaline rush is over")
	if(speed_bonus_active)
		walker.remove_movespeed_modifier(type)
		speed_bonus_active = FALSE
	speed_activated = FALSE
	set_toggle(FALSE)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)


/datum/action/xeno_action/adrenaline_rush/proc/resinwalk_on_moved(datum/source, atom/oldloc, direction, Forced = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/walker = owner
	if(!isturf(walker.loc) || walker.plasma_stored < 3)
		owner.balloon_alert(owner, "We are too tired to run so fast")
		resinwalk_off(TRUE)
		return
	if(!speed_bonus_active)
		speed_bonus_active = TRUE
		walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
	walker.use_plasma(3)
	return
	if(!speed_bonus_active)
		return
	speed_bonus_active = FALSE
	walker.remove_movespeed_modifier(type)
