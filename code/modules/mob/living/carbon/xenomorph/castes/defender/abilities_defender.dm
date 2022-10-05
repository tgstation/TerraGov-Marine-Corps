// ***************************************
// *********** Tail sweep
// ***************************************
/datum/action/xeno_action/tail_sweep
	name = "Tail Sweep"
	action_icon_state = "tail_sweep"
	mechanics_text = "Hit all adjacent units around you, knocking them away and down."
	ability_name = "tail sweep"
	plasma_cost = 35
	use_state_flags = XACT_USE_CRESTED
	cooldown_timer = 12 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_SWEEP
	)

/datum/action/xeno_action/tail_sweep/can_use_action(silent, override_flags)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		to_chat(X, span_xenowarning("We don't have enough plasma, we need [(plasma_cost * 2) - X.plasma_stored] more plasma!"))
		return FALSE

/datum/action/xeno_action/tail_sweep/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	GLOB.round_statistics.defender_tail_sweeps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_tail_sweeps")
	X.visible_message(span_xenowarning("\The [X] sweeps its tail in a wide circle!"), \
	span_xenowarning("We sweep our tail in a wide circle!"))

	X.add_filter("defender_tail_sweep", 2, gauss_blur_filter(1)) //Add cool SFX
	X.spin(4, 1)
	X.enable_throw_parry(0.6 SECONDS)
	playsound(X,pick('sound/effects/alien_tail_swipe1.ogg','sound/effects/alien_tail_swipe2.ogg','sound/effects/alien_tail_swipe3.ogg'), 25, 1) //Sound effects

	var/sweep_range = 1
	var/list/L = orange(sweep_range, X)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		H.add_filter("defender_tail_sweep", 2, gauss_blur_filter(1)) //Add cool SFX; motion blur
		addtimer(CALLBACK(H, /atom.proc/remove_filter, "defender_tail_sweep"), 0.5 SECONDS) //Remove cool SFX
		if(H.stat != DEAD && !isnestedhost(H) ) //No bully
			var/damage = X.xeno_caste.melee_damage
			var/affecting = H.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			var/armor_block = H.get_soft_armor("melee", affecting)
			H.apply_damage(damage, BRUTE, affecting, armor_block) //Crap base damage after armour...
			H.apply_damage(damage, STAMINA, updating_health = TRUE) //...But some sweet armour ignoring Stamina
			H.Paralyze(5) //trip and go
		GLOB.round_statistics.defender_tail_sweep_hits++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_tail_sweep_hits")
		shake_camera(H, 2, 1)

		to_chat(H, span_xenowarning("We are struck by \the [X]'s tail sweep!"))
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)

	addtimer(CALLBACK(X, /atom.proc/remove_filter, "defender_tail_sweep"), 0.5 SECONDS) //Remove cool SFX
	succeed_activate()
	if(X.crest_defense)
		X.use_plasma(plasma_cost)
	add_cooldown()

/datum/action/xeno_action/tail_sweep/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We gather enough strength to tail sweep again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/tail_sweep/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/tail_sweep/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Forward Charge
// ***************************************
/datum/action/xeno_action/activable/forward_charge
	name = "Forward Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 4 tiles and knockdown any targets in our way."
	ability_name = "charge"
	cooldown_timer = 10 SECONDS
	plasma_cost = 80
	use_state_flags = XACT_USE_CRESTED|XACT_USE_FORTIFIED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FORWARD_CHARGE
	)
	///How far can we charge
	var/range = 4
	///How long is the windup before charging
	var/windup_time = 0.5 SECONDS

/datum/action/xeno_action/activable/forward_charge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT, COMSIG_MOVABLE_POST_THROW))

/datum/action/xeno_action/activable/forward_charge/proc/mob_hit(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	return COMPONENT_KEEP_THROWING

/datum/action/xeno_action/activable/forward_charge/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack))
		var/obj/structure/S = target
		X.visible_message(span_danger("[X] plows straight through [S]!"), null, null, 5)
		S.deconstruct(FALSE) //We want to continue moving, so we do not reset throwing.
		return // stay registered
	target.hitby(X, speed) //This resets throwing.
	charge_complete()

/datum/action/xeno_action/activable/forward_charge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/xeno_action/activable/forward_charge/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our exoskeleton quivers as we get ready to use Forward Charge again."))
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/forward_charge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	if(!do_after(X, windup_time, FALSE, X, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_use_ability, A, FALSE, XACT_USE_BUSY)))
		return fail_activate()

	var/mob/living/carbon/xenomorph/defender/defender = X
	if(defender.fortify)
		var/datum/action/xeno_action/fortify/fortify_action = X.actions_by_path[/datum/action/xeno_action/fortify]
		if(fortify_action.cooldown_id)
			to_chat(X, span_xenowarning("We cannot yet untuck ourselves from our fortified stance!"))
			return fail_activate()

		fortify_action.set_fortify(FALSE, TRUE)
		fortify_action.add_cooldown()
		to_chat(X, span_xenowarning("We rapidly untuck ourselves, preparing to surge forward."))

	X.visible_message(span_danger("[X] charges towards \the [A]!"), \
	span_danger("We charge towards \the [A]!") )
	X.emote("roar")
	succeed_activate()

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit,)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, .proc/charge_complete)

	X.throw_at(A, range, 70, X)

	add_cooldown()

/datum/action/xeno_action/activable/forward_charge/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/forward_charge/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, range))
		return FALSE
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	action_activate()
	LAZYINCREMENT(owner.do_actions, target)
	addtimer(CALLBACK(src, .proc/decrease_do_action, target), windup_time)
	return TRUE

///Decrease the do_actions of the owner
/datum/action/xeno_action/activable/forward_charge/proc/decrease_do_action(atom/target)
	LAZYDECREMENT(owner.do_actions, target)

// ***************************************
// *********** Crest defense
// ***************************************
/datum/action/xeno_action/toggle_crest_defense
	name = "Toggle Crest Defense"
	action_icon_state = "crest_defense"
	mechanics_text = "Increase your resistance to projectiles at the cost of move speed. Can use abilities while in Crest Defense."
	ability_name = "toggle crest defense"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED // duh
	cooldown_timer = 1 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CREST_DEFENSE
	)
	var/last_crest_bonus = 0

/datum/action/xeno_action/toggle_crest_defense/on_xeno_upgrade()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.crest_defense)
		var/defensebonus = X.xeno_caste.crest_defense_armor
		X.soft_armor = X.soft_armor.modifyAllRatings(defensebonus)
		X.soft_armor = X.soft_armor.setRating(bomb = 30)
		last_crest_bonus = defensebonus
		X.add_movespeed_modifier(MOVESPEED_ID_CRESTDEFENSE, TRUE, 0, NONE, TRUE, X.xeno_caste.crest_defense_slowdown)

/datum/action/xeno_action/toggle_crest_defense/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/defender/X = owner
	to_chat(X, span_notice("We can [X.crest_defense ? "raise" : "lower"] our crest."))
	return ..()

/datum/action/xeno_action/toggle_crest_defense/action_activate()
	var/mob/living/carbon/xenomorph/defender/X = owner

	if(X.crest_defense)
		set_crest_defense(FALSE)
		add_cooldown()
		return succeed_activate()

	var/was_fortified = X.fortify
	if(X.fortify)
		var/datum/action/xeno_action/fortify/FT = X.actions_by_path[/datum/action/xeno_action/fortify]
		if(FT.cooldown_id)
			to_chat(X, span_xenowarning("We cannot yet untuck ourselves!"))
			return fail_activate()
		FT.set_fortify(FALSE, TRUE)
		FT.add_cooldown()
		to_chat(X, span_xenowarning("We carefully untuck, keeping our crest lowered."))

	set_crest_defense(TRUE, was_fortified)
	add_cooldown()
	return succeed_activate()

/datum/action/xeno_action/toggle_crest_defense/proc/set_crest_defense(on, silent = FALSE)
	var/mob/living/carbon/xenomorph/defender/X = owner
	X.crest_defense = on
	if(on)
		if(!silent)
			to_chat(X, span_xenowarning("We tuck ourselves into a defensive stance."))
		GLOB.round_statistics.defender_crest_lowerings++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_crest_lowerings")
		var/defensebonus = X.xeno_caste.crest_defense_armor
		ADD_TRAIT(X, TRAIT_STAGGERIMMUNE, CREST_DEFENSE_TRAIT) //Can now endure impacts/damages that would make lesser xenos flinch
		X.soft_armor = X.soft_armor.modifyAllRatings(defensebonus)
		X.soft_armor = X.soft_armor.setRating(bomb = 30)
		last_crest_bonus = defensebonus
		X.add_movespeed_modifier(MOVESPEED_ID_CRESTDEFENSE, TRUE, 0, NONE, TRUE, X.xeno_caste.crest_defense_slowdown)
	else
		if(!silent)
			to_chat(X, span_xenowarning("We raise our crest."))
		GLOB.round_statistics.defender_crest_raises++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_crest_raises")
		REMOVE_TRAIT(X, TRAIT_STAGGERIMMUNE, CREST_DEFENSE_TRAIT)
		X.soft_armor = X.soft_armor.modifyAllRatings(-last_crest_bonus)
		X.soft_armor = X.soft_armor.setRating(bomb = 20)
		last_crest_bonus = 0
		X.remove_movespeed_modifier(MOVESPEED_ID_CRESTDEFENSE)
	X.update_icons()

// ***************************************
// *********** Fortify
// ***************************************
/datum/action/xeno_action/fortify
	name = "Fortify"
	action_icon_state = "fortify"	// TODO
	mechanics_text = "Plant yourself for a large defensive boost."
	ability_name = "fortify"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED // duh
	cooldown_timer = 1 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FORTIFY
	)
	var/last_fortify_bonus = 0

/datum/action/xeno_action/fortify/on_xeno_upgrade()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.fortify)
		var/fortifyAB = X.xeno_caste.fortify_armor
		X.soft_armor = X.soft_armor.modifyAllRatings(fortifyAB)
		X.soft_armor = X.soft_armor.setRating(bomb = 100)
		last_fortify_bonus = fortifyAB

/datum/action/xeno_action/fortify/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We can [X.fortify ? "stand up" : "fortify"] again."))
	return ..()

/datum/action/xeno_action/fortify/action_activate()
	var/mob/living/carbon/xenomorph/defender/X = owner

	if(X.fortify)
		set_fortify(FALSE)
		add_cooldown()
		return succeed_activate()

	var/was_crested = X.crest_defense
	if(X.crest_defense)
		var/datum/action/xeno_action/toggle_crest_defense/CD = X.actions_by_path[/datum/action/xeno_action/toggle_crest_defense]
		if(CD.cooldown_id)
			to_chat(X, span_xenowarning("We cannot yet transition to a defensive stance!"))
			return fail_activate()
		CD.set_crest_defense(FALSE, TRUE)
		CD.add_cooldown()
		to_chat(X, span_xenowarning("We tuck our lowered crest into ourselves."))

	set_fortify(TRUE, was_crested)
	add_cooldown()
	return succeed_activate()

/datum/action/xeno_action/fortify/proc/set_fortify(on, silent = FALSE)
	var/mob/living/carbon/xenomorph/defender/X = owner
	GLOB.round_statistics.defender_fortifiy_toggles++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_fortifiy_toggles")
	if(on)
		ADD_TRAIT(X, TRAIT_IMMOBILE, FORTIFY_TRAIT)
		if(!silent)
			to_chat(X, span_xenowarning("We tuck ourselves into a defensive stance."))
		var/fortifyAB = X.xeno_caste.fortify_armor
		X.soft_armor = X.soft_armor.modifyAllRatings(fortifyAB)
		X.soft_armor = X.soft_armor.setRating(bomb = 100)
		last_fortify_bonus = fortifyAB
	else
		if(!silent)
			to_chat(X, span_xenowarning("We resume our normal stance."))
		X.soft_armor = X.soft_armor.modifyAllRatings(-last_fortify_bonus)
		X.soft_armor = X.soft_armor.setRating(bomb = 20)
		last_fortify_bonus = 0
		REMOVE_TRAIT(X, TRAIT_IMMOBILE, FORTIFY_TRAIT)
	X.fortify = on
	X.anchored = on
	playsound(X.loc, 'sound/effects/stonedoor_openclose.ogg', 30, TRUE)
	X.update_icons()

// ***************************************
// *********** Regenerate Skin
// ***************************************
/datum/action/xeno_action/regenerate_skin
	name = "Regenerate Skin"
	action_icon_state = "regenerate_skin"
	mechanics_text = "Regenerate your hard exoskeleton skin, restoring some health and removing all sunder."
	ability_name = "regenerate skin"
	use_state_flags = XACT_USE_FORTIFIED|XACT_USE_CRESTED|XACT_TARGET_SELF|XACT_IGNORE_SELECTED_ABILITY|XACT_KEYBIND_USE_ABILITY
	plasma_cost = 160
	cooldown_timer = 1 MINUTES
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_REGENERATE_SKIN
	)

/datum/action/xeno_action/regenerate_skin/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We feel we are ready to shred our skin and grow another."))
	return ..()

/datum/action/xeno_action/regenerate_skin/action_activate()
	var/mob/living/carbon/xenomorph/defender/X = owner

	if(!can_use_action(TRUE))
		return fail_activate()

	if(X.on_fire)
		to_chat(X, span_xenowarning("We can't use that while on fire."))
		return fail_activate()

	X.emote("roar")
	X.visible_message(span_warning("The skin on \the [X] shreds and a new layer can be seen in it's place!"),
		span_notice("We shed our skin, showing the fresh new layer underneath!"))

	X.do_jitter_animation(1000)
	X.set_sunder(0)
	X.heal_overall_damage(25, 25, updating_health = TRUE)
	add_cooldown()
	return succeed_activate()


// ***************************************
// *********** Centrifugal force
// ***************************************
/datum/action/xeno_action/centrifugal_force
	name = "Centrifugal force"
	action_icon_state = "centrifugal_force"
	mechanics_text = "Rapidly spin and hit all adjacent humans around you, knocking them away and down. Uses double plasma when crest is active."
	ability_name = "centrifugal force"
	plasma_cost = 15
	use_state_flags = XACT_USE_CRESTED
	cooldown_timer = 30 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CENTRIFUGAL_FORCE
	)
	///bool whether we should take a random step this tick
	var/step_tick = FALSE
	///timer hash for the timer we use when spinning
	var/spin_loop_timer

/datum/action/xeno_action/centrifugal_force/can_use_action(silent, override_flags)
	if(spin_loop_timer)
		return TRUE
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		to_chat(X, span_xenowarning("We don't have enough plasma, we need [(plasma_cost * 2) - X.plasma_stored] more plasma!"))
		return FALSE

/datum/action/xeno_action/centrifugal_force/action_activate()
	if(spin_loop_timer)
		stop_spin()
		return
	if(!can_use_action(TRUE))
		return fail_activate()
	if(!do_after(owner, 0.5 SECONDS, TRUE, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_use_action, FALSE, XACT_USE_BUSY)))
		return fail_activate()
	owner.visible_message(span_xenowarning("\The [owner] starts swinging its tail in a circle!"), \
		span_xenowarning("We start swinging our tail in a wide circle!"))
	do_spin() //kick it off

	spin_loop_timer = addtimer(CALLBACK(src, .proc/do_spin), 5, TIMER_STOPPABLE)
	add_cooldown()
	RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_ADDTRAIT(TRAIT_IMMOBILE)), .proc/stop_spin)

/// runs a spin, then starts the timer for a new spin if needed
/datum/action/xeno_action/centrifugal_force/proc/do_spin()
	spin_loop_timer = null
	var/mob/living/carbon/xenomorph/X = owner
	X.spin(4, 1)
	X.enable_throw_parry(0.6 SECONDS)
	playsound(X, pick('sound/effects/alien_tail_swipe1.ogg','sound/effects/alien_tail_swipe2.ogg','sound/effects/alien_tail_swipe3.ogg'), 25, 1) //Sound effects

	for(var/mob/living/carbon/human/slapped in orange(1, X))
		step_away(slapped, src, 1, 2)
		if(slapped.stat == DEAD)
			continue
		var/damage = X.xeno_caste.melee_damage/2
		var/affecting = slapped.get_limb(ran_zone(null, 0))
		if(!affecting)
			affecting = slapped.get_limb("chest")
		var/armor_block = slapped.get_soft_armor("melee", affecting)
		slapped.apply_damage(damage, BRUTE, affecting, armor_block)
		slapped.apply_damage(damage, STAMINA, updating_health = TRUE)
		slapped.Paralyze(3)
		shake_camera(slapped, 2, 1)

		to_chat(slapped, span_xenowarning("We are struck by \the [X]'s flying tail!"))
		playsound(slapped, 'sound/weapons/alien_claw_block.ogg', 50, 1)

	succeed_activate(X.crest_defense ? plasma_cost * 2 : plasma_cost)
	if(step_tick)
		step(X, pick(GLOB.alldirs))
	step_tick = !step_tick

	if(can_use_action(X, XACT_IGNORE_COOLDOWN))
		spin_loop_timer = addtimer(CALLBACK(src, .proc/do_spin), 5, TIMER_STOPPABLE)
		return
	stop_spin()

/// stops spin and unregisters all listeners
/datum/action/xeno_action/centrifugal_force/proc/stop_spin()
	SIGNAL_HANDLER
	if(spin_loop_timer)
		deltimer(spin_loop_timer)
		spin_loop_timer = null
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_ADDTRAIT(TRAIT_IMMOBILE)))
