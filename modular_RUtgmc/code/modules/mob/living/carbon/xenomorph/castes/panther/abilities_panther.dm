/// runner abilities
/datum/action/xeno_action/activable/psydrain/panther
	plasma_cost = 10

/datum/action/xeno_action/activable/pounce/panther
	plasma_cost = 20
	var/pantherplasmaheal = 45

/datum/action/xeno_action/activable/pounce/panther/mob_hit(datum/source, mob/living/M)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	X.plasma_stored += pantherplasmaheal

///////////////////////////////////
// ***************************************
// *********** Tearing tail
// ***************************************

/datum/action/xeno_action/tearingtail
	name = "Tearing tail"
	action_icon_state = "tearing_tail"
	desc = "Hit all adjacent units around you, poisoning them with selected toxin and healing you for each creature hit."
	ability_name = "tearing tail"
	plasma_cost = 50
	cooldown_timer = 15 SECONDS
	var/tearing_tail_reagent
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
			H.apply_damage(damage, BRUTE, affecting, MELEE)
			X.plasma_stored += 25
			X.heal_overall_damage(25, 25, updating_health = TRUE)
			if(H.can_sting())
				tearing_tail_reagent = X.selected_reagent
				H.reagents.add_reagent(tearing_tail_reagent, PANTHER_TEARING_TAIL_REAGENT_AMOUNT)
				playsound(H, 'sound/effects/spray3.ogg', 15, TRUE)
		shake_camera(H, 2, 1)
		to_chat(H, span_xenowarning("We are hit by \the [X]'s tail sweep!"))
		playsound(H,'sound/weapons/alien_tail_attack.ogg', 50, 1)

	addtimer(CALLBACK(X, TYPE_PROC_REF(/atom, remove_filter), "defender_tail_sweep"), 0.5 SECONDS) //Remove cool SFX
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
	action_icon_state = "adrenaline_jump"
	desc = "Jump from some distance to target, knocking them down and pulling them to you, only works if you are at least from 3 to 8 meters away from the target, this ability sends Pounce on cooldown."
	ability_name = "adrenaline jump"
	plasma_cost = 15
	cooldown_timer = 12 SECONDS
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

	if(get_dist_euclide_square(A, owner) > 64) //8 tiles range
		if(!silent)
			to_chat(owner, span_xenonotice("You are too far!"))
		return FALSE

	if(!line_of_sight(A, owner))
		if(!silent)
			owner.balloon_alert(owner, "We need clear jump line!")
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
	span_xenowarning("We jump at [A]!"))

	lunge_target = A

	RegisterSignal(lunge_target, COMSIG_QDELETING, PROC_REF(clean_lunge_target))
	RegisterSignal(X, COMSIG_MOVABLE_MOVED, PROC_REF(check_if_lunge_possible))
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, PROC_REF(clean_lunge_target))

	if(lunge_target.Adjacent(X)) //They're already in range, pat their head, we messed up.
		playsound(X,'sound/weapons/thudswoosh.ogg', 75, 1)
		X.plasma_stored += -50
		clean_lunge_target()
	else
		X.throw_at(get_step_towards(A, X), 6, 2, X)

	succeed_activate()
	add_cooldown()
	var/datum/action/xeno_action/pounce = X.actions_by_path[/datum/action/xeno_action/activable/pounce/panther]
	if(pounce)
		pounce.add_cooldown()

	return TRUE

///Check if we are close enough to lunge, and if yes, fling them
/datum/action/xeno_action/activable/adrenalinejump/proc/check_if_lunge_possible(datum/source)
	SIGNAL_HANDLER
	if(!lunge_target.Adjacent(source))
		return
	INVOKE_ASYNC(src, PROC_REF(pantherfling), lunge_target)

/// Null lunge target and reset throw vars
/datum/action/xeno_action/activable/adrenalinejump/proc/clean_lunge_target()
	SIGNAL_HANDLER
	UnregisterSignal(lunge_target, COMSIG_QDELETING)
	UnregisterSignal(owner, COMSIG_MOVABLE_POST_THROW)
	lunge_target = null
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.stop_throw()


/datum/action/xeno_action/activable/adrenalinejump/proc/pantherfling(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/lunge_target = A
	var/fling_distance = 1

	X.face_atom(lunge_target) //Face towards the victim

	X.visible_message(span_xenowarning("\The [X] effortlessly trips [lunge_target] !"), \
	span_xenowarning("We effortlessly trip [lunge_target] !"))
	playsound(lunge_target,'sound/weapons/alien_claw_block.ogg', 75, 1)

	X.do_attack_animation(lunge_target, ATTACK_EFFECT_DISARM2)
	X.plasma_stored += 50 //reward for our smart little panther

	if(isxeno(lunge_target))
		var/mob/living/carbon/xenomorph/x_lunge_target = lunge_target
		if(X.issamexenohive(x_lunge_target)) //We don't fuck up friendlies
			return

	lunge_target.ParalyzeNoChain(1 SECONDS)
	lunge_target.throw_at(X, fling_distance, 1, X) //go under us


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
	rush_off(TRUE) // Ensure we remove the movespeed
	return ..()

/datum/action/xeno_action/adrenaline_rush/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(speed_activated)
		return TRUE

/datum/action/xeno_action/adrenaline_rush/action_activate()
	if(speed_activated)
		rush_off()
		return fail_activate()
	rush_on()
	succeed_activate()


/datum/action/xeno_action/adrenaline_rush/proc/rush_on(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	speed_activated = TRUE
	if(!silent)
		owner.balloon_alert(owner, "It's time to run")
	if(walker.loc_weeds_type)
		speed_bonus_active = TRUE
		walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
	set_toggle(TRUE)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(rush_on_moved))


/datum/action/xeno_action/adrenaline_rush/proc/rush_off(silent = FALSE)
	var/mob/living/carbon/xenomorph/walker = owner
	if(!silent)
		owner.balloon_alert(owner, "Adrenaline rush is over")
	if(speed_bonus_active)
		walker.remove_movespeed_modifier(type)
		speed_bonus_active = FALSE
	speed_activated = FALSE
	set_toggle(FALSE)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)


/datum/action/xeno_action/adrenaline_rush/proc/rush_on_moved(datum/source, atom/oldloc, direction, Forced = FALSE)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/walker = owner
	if(!isturf(walker.loc) || walker.plasma_stored < 3)
		owner.balloon_alert(owner, "We are too tired to run so fast")
		rush_off(TRUE)
		return
	if(owner.m_intent == MOVE_INTENT_RUN)
		if(!speed_bonus_active)
			speed_bonus_active = TRUE
			walker.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, -1.5)
		walker.use_plasma(3)
		return
	if(!speed_bonus_active)
		return
	speed_bonus_active = FALSE
	walker.remove_movespeed_modifier(type)

// ***************************************
// *********** Evasive maneuvers
// ***************************************
/datum/action/xeno_action/evasive_maneuvers
	name = "Toggle evasive maneuvers"
	action_icon_state = "evasive_maneuvers"
	desc = "Toggle evasive action, forcing non-friendly projectiles that would hit you to miss."
	plasma_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EVASIVE_MANEUVERS,
	)
	cooldown_timer = PANTHER_EVASION_COOLDOWN
	///Whether evasion is currently active
	var/evade_active = FALSE
	///Number of successful cooldown clears in a row
	action_type = ACTION_TOGGLE

/datum/action/xeno_action/evasive_maneuvers/remove_action(mob/living/L)
	if(evade_active)
		evasion_deactivate()
	return ..()

/datum/action/xeno_action/evasive_maneuvers/can_use_action(silent = FALSE, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/panther/R = owner

	if(!.)
		return FALSE
	if(R.on_fire)
		if(!silent)
			owner.balloon_alert(owner, "Can't while on fire!")
		return FALSE
	return TRUE

/datum/action/xeno_action/evasive_maneuvers/action_activate()
	var/mob/living/carbon/xenomorph/panther/R = owner

	if(evade_active)
		evasion_deactivate()
		return TRUE
	R.balloon_alert(R, "Begin evasion.")
	to_chat(R, span_highdanger("We take evasive action, making us impossible to hit with projectiles."))
	succeed_activate()


	RegisterSignals(R, list(COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_LIVING_IGNITED), PROC_REF(evasion_debuff_check))

	RegisterSignal(R, COMSIG_MOVABLE_MOVED, PROC_REF(handle_evasion))
	RegisterSignal(R, COMSIG_XENO_PROJECTILE_HIT, PROC_REF(evasion_dodge)) //This is where we actually check to see if we dodge the projectile.
	RegisterSignal(R, COMSIG_ATOM_BULLET_ACT, PROC_REF(evasion_flamer_hit)) //Register status effects and fire which impact evasion.
	RegisterSignal(R, COMSIG_LIVING_PRE_THROW_IMPACT, PROC_REF(evasion_throw_dodge)) //Register status effects and fire which impact evasion.
	RegisterSignal(R, COMSIG_LIVING_ADD_VENTCRAWL, PROC_REF(evasion_deactivate))

	set_toggle(TRUE)
	evade_active = TRUE //evasion is currently active

	GLOB.round_statistics.runner_evasions++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_evasions") //Statistics

	handle_evasion()
	START_PROCESSING(SSprocessing, src)

/datum/action/xeno_action/evasive_maneuvers/proc/handle_evasion()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xenoowner = owner
	if(owner.m_intent == MOVE_INTENT_RUN)
		xenoowner.use_plasma(PANTHER_EVASION_PLASMADRAIN)
	if(owner.m_intent == MOVE_INTENT_WALK)
		xenoowner.use_plasma(PANTHER_EVASION_LOW_PLASMADRAIN)
	//If we have 0 plasma after expending evasion upkeep plasma, end evasion.
	if(!xenoowner.plasma_stored)
		to_chat(xenoowner, span_xenodanger("We lack sufficient plasma to keep evading."))
		evasion_deactivate()

///Called when the owner is hit by a flamethrower projectile
/datum/action/xeno_action/evasive_maneuvers/proc/evasion_flamer_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER

	if((proj.ammo.flags_ammo_behavior & AMMO_FLAME)) //If it's not from a flamethrower, we don't care
		to_chat(owner, span_danger("The searing fire compromises our ability to dodge!"))
		evasion_deactivate()

///After getting hit with an Evasion disabling debuff, this is where we check to see if evasion is active, and if we actually have debuff stacks
/datum/action/xeno_action/evasive_maneuvers/proc/evasion_debuff_check(datum/source, amount)
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/X = owner

	if(!(amount > 0) || !evade_active) //If evasion isn't active we don't care
		return
	to_chat(owner, span_highdanger("Our movements have been interrupted!"))
	X.plasma_stored += -65


///Where we deactivate evasion and unregister the signals/zero out vars, etc.
/datum/action/xeno_action/evasive_maneuvers/proc/evasion_deactivate()
	SIGNAL_HANDLER
	add_cooldown()
	to_chat(owner, "<span class='xenodanger'>We stop evading.</span>")

	UnregisterSignal(owner, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_XENO_PROJECTILE_HIT,
		COMSIG_LIVING_IGNITED,
		COMSIG_LIVING_PRE_THROW_IMPACT,
		COMSIG_LIVING_ADD_VENTCRAWL,
		COMSIG_ATOM_BULLET_ACT,))

	set_toggle(FALSE)
	evade_active = FALSE //Evasion is no longer active

	owner.balloon_alert(owner, "Evasion ended")
	owner.playsound_local(owner, 'sound/voice/hiss5.ogg', 50)


/datum/action/xeno_action/evasive_maneuvers/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We are able to take evasive action again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)

	return ..()

/datum/action/xeno_action/evasive_maneuvers/process()
	if(!evade_active)
		return PROCESS_KILL
	handle_evasion()

///Determines whether or not a thrown projectile is dodged while the Evasion ability is active
/datum/action/xeno_action/evasive_maneuvers/proc/evasion_throw_dodge(datum/source, atom/movable/proj)
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/X = owner
	if(!evade_active) //If evasion is not active we don't dodge
		return NONE

	if((X.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return NONE

	evasion_dodge_sfx(proj)

	return COMPONENT_PRE_THROW_IMPACT_HIT

///This is where the dodgy magic happens
/datum/action/xeno_action/evasive_maneuvers/proc/evasion_dodge(datum/source, obj/projectile/proj, cardinal_move, uncrossing)
	SIGNAL_HANDLER

	var/mob/living/carbon/xenomorph/panther/R = owner
	if(!evade_active) //If evasion is not active we don't dodge
		return FALSE

	if((R.last_move_time < (world.time - RUNNER_EVASION_RUN_DELAY))) //Gotta keep moving to benefit from evasion!
		return FALSE

	if(R.issamexenohive(proj.firer)) //We automatically dodge allied projectiles at no cost, and no benefit to our evasion stacks
		return COMPONENT_PROJECTILE_DODGE

	if(proj.ammo.flags_ammo_behavior & AMMO_FLAME) //We can't dodge literal fire
		return FALSE

	evasion_dodge_sfx(proj)

	return COMPONENT_PROJECTILE_DODGE

///Handles dodge effects and visuals for the Evasion ability.
/datum/action/xeno_action/evasive_maneuvers/proc/evasion_dodge_sfx(atom/movable/proj)

	var/mob/living/carbon/xenomorph/X = owner

	X.visible_message(span_warning("[X] effortlessly dodges the [proj.name]!"), \
	span_xenodanger("We effortlessly dodge the !"))

	X.add_filter("runner_evasion", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(X, TYPE_PROC_REF(/atom, remove_filter), "runner_evasion"), 0.5 SECONDS)
	X.do_jitter_animation(4000)

	var/turf/T = get_turf(X) //location of after image SFX
	playsound(T, pick('sound/effects/throw.ogg','sound/effects/alien_tail_swipe1.ogg', 'sound/effects/alien_tail_swipe2.ogg'), 25, 1) //sound effects
	var/obj/effect/temp_visual/xenomorph/afterimage/A
	for(var/i=0 to 2) //number of after images
		A = new /obj/effect/temp_visual/xenomorph/afterimage(T, owner) //Create the after image.
		A.pixel_x = pick(rand(X.pixel_x * 3, X.pixel_x * 1.5), rand(0, X.pixel_x * -1)) //Variation on the X position

// ***************************************
// *********** Select reagent (panther)
// ***************************************
/datum/action/xeno_action/select_reagent/panther
	name = "Select Reagent"
	action_icon_state = "select_reagent0"
	desc = "Selects which reagent to use for tearing tail. Hemodile slows by 25%, increased to 50% with neurotoxin present, and deals 20% of damage received as stamina damage. Transvitox converts brute/burn damage to toxin based on 40% of damage received up to 45 toxin on target, upon reaching which causes a stun. Neurotoxin deals increasing stamina damage the longer it remains in the victim's system and prevents stamina regeneration. Ozelomelyn purges medical chemicals from humans, while also causing slight intoxication. Sanguinal does damage depending on presence and amount of all previously mentioned reagents, also causes light brute damage and bleeding."
	use_state_flags = XACT_USE_BUSY|XACT_USE_LYING
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SELECT_REAGENT,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_RADIAL_SELECT_REAGENT,
	)

/datum/action/xeno_action/select_reagent/panther/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	X.selected_reagent = GLOB.panther_toxin_type_list[1] //Set our default
	update_button_icon() //Update immediately to get our default

/datum/action/xeno_action/select_reagent/panther/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	var/i = GLOB.panther_toxin_type_list.Find(X.selected_reagent)
	if(length_char(GLOB.panther_toxin_type_list) == i)
		X.selected_reagent = GLOB.panther_toxin_type_list[1]
	else
		X.selected_reagent = GLOB.panther_toxin_type_list[i+1]

	var/atom/A = X.selected_reagent
	X.balloon_alert(X, "[initial(A.name)]")
	update_button_icon()
	return succeed_activate()

/datum/action/xeno_action/select_reagent/panther/select_reagent_radial()
	//List of toxin images
	// This is cursed, don't copy this code its the WRONG way to do this.
	// TODO: generate this from GLOB.panther_toxin_type_list (or wait while offtgmc reworks the defiler code and then copy it )
	var/static/list/panther_toxin_images_list = list(
			PANTHER_NEUROTOXIN = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = PANTHER_NEUROTOXIN),
			PANTHER_HEMODILE = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = PANTHER_HEMODILE),
			PANTHER_TRANSVITOX = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = PANTHER_TRANSVITOX),
			PANTHER_OZELOMELYN = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = PANTHER_OZELOMELYN),
			PANTHER_SANGUINAL = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = PANTHER_SANGUINAL),
			)
	var/toxin_choice = show_radial_menu(owner, owner, panther_toxin_images_list, radius = 48)
	if(!toxin_choice)
		return
	var/mob/living/carbon/xenomorph/X = owner
	for(var/toxin in GLOB.panther_toxin_type_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[toxin]
		if(R.name == toxin_choice)
			X.selected_reagent = R.type
			break
	X.balloon_alert(X, "[toxin_choice]")
	update_button_icon()
	return succeed_activate()

#undef PANTHER_NEUROTOXIN
#undef PANTHER_HEMODILE
#undef PANTHER_TRANSVITOX
#undef PANTHER_OZELOMELYN
#undef PANTHER_SANGUINAL
