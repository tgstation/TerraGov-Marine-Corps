// ***************************************
// *********** Agility
// ***************************************
/datum/action/ability/xeno_action/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
	desc = "Move an all fours for greater speed. Cannot use abilities while in this mode."
	cooldown_duration = 0.5 SECONDS
	use_state_flags = ABILITY_USE_AGILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_AGILITY,
	)
	var/last_agility_bonus = 0

/datum/action/ability/xeno_action/toggle_agility/give_action()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	last_agility_bonus = X.xeno_caste.agility_speed_armor

/datum/action/ability/xeno_action/toggle_agility/on_xeno_upgrade()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.agility)
		X.soft_armor = X.soft_armor.modifyAllRatings(-last_agility_bonus)
		last_agility_bonus = X.xeno_caste.agility_speed_armor
		X.soft_armor = X.soft_armor.modifyAllRatings(last_agility_bonus)
		X.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY , TRUE, 0, NONE, TRUE, X.xeno_caste.agility_speed_increase)
	else
		last_agility_bonus = X.xeno_caste.agility_speed_armor

/datum/action/ability/xeno_action/toggle_agility/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_notice("We can [X.agility ? "raise ourselves back up" : "lower ourselves back down"] again."))
	return ..()

/datum/action/ability/xeno_action/toggle_agility/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	X.agility = !X.agility

	GLOB.round_statistics.warrior_agility_toggles++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_agility_toggles")

	if(X.agility)
		to_chat(X, span_xenowarning("We lower ourselves to all fours and loosen our armored scales to ease our movement."))
		X.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY , TRUE, 0, NONE, TRUE, X.xeno_caste.agility_speed_increase)
		X.soft_armor = X.soft_armor.modifyAllRatings(last_agility_bonus)
		owner.toggle_move_intent(MOVE_INTENT_RUN) //By default we swap to running when activating agility
	else
		to_chat(X, span_xenowarning("We raise ourselves to stand on two feet, hard scales setting back into place."))
		X.remove_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY)
		X.soft_armor = X.soft_armor.modifyAllRatings(-last_agility_bonus)

	X.update_icons()
	add_cooldown()
	return succeed_activate()

// ***************************************
// *********** Lunge
// ***************************************
/datum/action/ability/activable/xeno/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	desc = "Pounce up to 5 tiles and grab a target, knocking them down and putting them in your grasp."
	ability_cost = 25
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LUNGE,
	)
	target_flags = ABILITY_MOB_TARGET
	/// The target of our lunge, we keep it to check if we are adjacent everytime we move
	var/atom/lunge_target

/datum/action/ability/activable/xeno/lunge/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We ready ourselves to lunge again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/lunge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(get_dist_euclide_square(A, owner) > 20)
		if(!silent)
			to_chat(owner, span_xenonotice("You are too far!"))
		return FALSE

	if(!isliving(A)) //We can only lunge at the living; expanded to xenos in order to allow for supportive applications; lunging > throwing to safety
		if(!silent)
			to_chat(owner, span_xenodanger("We can't [initial(name)] at that!"))
		return FALSE

	var/mob/living/living_target = A
	if(living_target.stat == DEAD)
		if(!silent)
			to_chat(owner, span_xenodanger("We can't [initial(name)] at that!"))
		return FALSE

/datum/action/ability/activable/xeno/lunge/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/lunge/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, 2))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/lunge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	GLOB.round_statistics.warrior_lunges++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_lunges")
	X.visible_message(span_xenowarning("\The [X] lunges towards [A]!"), \
	span_xenowarning("We lunge at [A]!"))

	X.add_filter("warrior_lunge", 2, gauss_blur_filter(3))
	lunge_target = A

	RegisterSignal(lunge_target, COMSIG_QDELETING, PROC_REF(clean_lunge_target))
	RegisterSignal(X, COMSIG_MOVABLE_MOVED, PROC_REF(check_if_lunge_possible))
	RegisterSignal(X, COMSIG_MOVABLE_POST_THROW, PROC_REF(clean_lunge_target))
	if(lunge_target.Adjacent(X)) //They're already in range, neck grab without lunging.
		lunge_grab(X, lunge_target)
	else
		X.throw_at(get_step_towards(A, X), 6, 2, X)

	if(X.pulling && !isxeno(X.pulling)) //If we grabbed something give us combo.
		X.empower(empowerable = FALSE) //Doesn't have a special interaction
	succeed_activate()
	add_cooldown()
	return TRUE

///Check if we are close enough to lunge, and if yes, grab neck
/datum/action/ability/activable/xeno/lunge/proc/check_if_lunge_possible(datum/source)
	SIGNAL_HANDLER
	if(!lunge_target.Adjacent(source))
		return
	INVOKE_ASYNC(src, PROC_REF(lunge_grab), source, lunge_target)

///Do a last check to see if we can grab the target, and then clean up after the throw. Handles an in-place lunge.
/datum/action/ability/activable/xeno/lunge/proc/finish_lunge(datum/source)
	SIGNAL_HANDLER
	check_if_lunge_possible(source)
	if(lunge_target) //Still couldn't get them.
		clean_lunge_target()

/// Null lunge target and reset throw vars
/datum/action/ability/activable/xeno/lunge/proc/clean_lunge_target()
	SIGNAL_HANDLER
	UnregisterSignal(lunge_target, COMSIG_QDELETING)
	UnregisterSignal(owner, COMSIG_MOVABLE_POST_THROW)
	lunge_target = null
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.remove_filter("warrior_lunge")
	owner.stop_throw()

///Do the grab on the target, and clean all previous vars
/datum/action/ability/activable/xeno/lunge/proc/lunge_grab(mob/living/carbon/xenomorph/warrior/X, atom/A)
	clean_lunge_target()
	X.swap_hand()
	X.start_pulling(A, lunge = TRUE)
	X.swap_hand()

// ***************************************
// *********** Fling
// ***************************************
/datum/action/ability/activable/xeno/fling
	name = "Fling"
	action_icon_state = "fling"
	desc = "Knock a target flying up to 5 tiles away."
	ability_cost = 18
	cooldown_duration = 20 SECONDS //Shared cooldown with Grapple Toss
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FLING,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/fling/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We gather enough strength to fling something again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/fling/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

	if(!owner.Adjacent(A))
		return FALSE

	if(!isliving(A))
		return FALSE
	var/mob/living/L = A
	if(L.stat == DEAD)
		return FALSE

/datum/action/ability/activable/xeno/fling/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/victim = A
	var/facing = get_dir(X, victim)
	var/fling_distance = 4

	X.face_atom(victim) //Face towards the victim

	GLOB.round_statistics.warrior_flings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_flings")

	X.visible_message(span_xenowarning("\The [X] effortlessly flings [victim] away!"), \
	span_xenowarning("We effortlessly fling [victim] away!"))
	playsound(victim,'sound/weapons/alien_claw_block.ogg', 75, 1)

	if(victim.mob_size >= MOB_SIZE_BIG) //Penalize fling distance for big creatures
		fling_distance = FLOOR(fling_distance * 0.5, 1)

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
				to_chat(human, span_highdanger("[victim] crashes into us!"))
		T = temp

	X.do_attack_animation(victim, ATTACK_EFFECT_DISARM2)
	victim.throw_at(T, fling_distance, 1, X, 1)

	shake_camera(victim, 2, 1)
	succeed_activate()
	add_cooldown()

	var/datum/action/ability/xeno_action/toss = X.actions_by_path[/datum/action/ability/activable/xeno/toss]
	if(toss)
		toss.add_cooldown()

	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/x_victim = victim
		if(X.issamexenohive(x_victim)) //We don't fuck up friendlies
			return

	victim.ParalyzeNoChain(0.5 SECONDS)


/datum/action/ability/activable/xeno/fling/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/fling/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Grapple Toss
// ***************************************
/datum/action/ability/activable/xeno/toss
	name = "Grapple Toss"
	action_icon_state = "grapple_toss"
	desc = "Throw a creature you're grappling up to 3 tiles away."
	ability_cost = 18
	cooldown_duration = 20 SECONDS //Shared cooldown with Fling
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GRAPPLE_TOSS,
	)
	target_flags = ABILITY_TURF_TARGET

/datum/action/ability/activable/xeno/toss/on_cooldown_finish()
	to_chat(owner, span_xenodanger("We gather enough strength to toss something again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/toss/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(!owner.pulling) //If we're not grappling something, we should be flinging something living and adjacent
		if(!silent)
			to_chat(owner, span_xenodanger("We have nothing to toss!"))
		return FALSE

/datum/action/ability/activable/xeno/toss/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/movable/target = owner.pulling
	var/fling_distance = 4
	var/stagger_slow_stacks = 3
	var/stun_duration = 0.5 SECONDS
	var/big_mob_message

	X.face_atom(A)
	GLOB.round_statistics.warrior_flings++ //I'm going to consider this a fling for the purpose of statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_flings")

	playsound(target,'sound/weapons/alien_claw_block.ogg', 75, 1)

	if(isliving(target))
		var/mob/living/victim = target

		if(victim.mob_size >= MOB_SIZE_BIG) //Penalize fling distance for big creatures
			fling_distance = FLOOR(fling_distance * 0.5, 1)
			big_mob_message = ", struggling mightily to heft its bulk"

		if(isxeno(victim))
			var/mob/living/carbon/xenomorph/x_victim = victim
			if(X.issamexenohive(x_victim)) //We don't fuck up friendlies
				stagger_slow_stacks = 0
				stun_duration = 0

		victim.adjust_stagger(stagger_slow_stacks SECONDS)
		victim.add_slowdown(stagger_slow_stacks)
		victim.adjust_blurriness(stagger_slow_stacks) //Cosmetic eye blur SFX
		victim.ParalyzeNoChain(stun_duration)
		shake_camera(victim, 2, 1)

	if(X.empower())
		fling_distance *= 2
	target.forceMove(get_turf(X)) //First force them into our space so we can toss them behind us without problems
	X.do_attack_animation(target, ATTACK_EFFECT_DISARM2)
	target.throw_at(get_turf(A), fling_distance, 1, X, 1)
	X.visible_message(span_xenowarning("\The [X] throws [target] away[big_mob_message]!"), \
	span_xenowarning("We throw [target] away[big_mob_message]!"))

	succeed_activate()
	add_cooldown()

	var/datum/action/ability/xeno_action/fling = X.actions_by_path[/datum/action/ability/activable/xeno/fling]
	if(fling)
		fling.add_cooldown()

// ***************************************
// *********** Punch
// ***************************************
/datum/action/ability/activable/xeno/punch
	name = "Punch"
	action_icon_state = "punch"
	desc = "Strike a target, inflicting stamina damage, stagger and slowdown. Deals double damage, stagger and slowdown to grappled targets. Deals quadruple damage to structures and machinery."
	ability_cost = 12
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PUNCH,
	)
	target_flags = ABILITY_MOB_TARGET
	///The punch range, 1 would be adjacent.
	var/range = 1

/datum/action/ability/activable/xeno/punch/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_xenodanger("We gather enough strength to punch again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/punch/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return

	if(A.resistance_flags & (INDESTRUCTIBLE|CRUSHER_IMMUNE)) //no bolting down indestructible airlocks
		if(!silent)
			to_chat(owner, span_xenodanger("We cannot damage this target!"))
		return FALSE

	if(isxeno(A))
		if(!silent)
			to_chat(owner, span_xenodanger("We can't harm our sister!"))
		return FALSE

	if(!isliving(A) && !isstructure(A) && !ismachinery(A) && !isvehicle(A))
		if(!silent)
			to_chat(owner, span_xenodanger("We can't punch this target!"))
		return FALSE

	if(isliving(A))
		var/mob/living/L = A
		if(L.stat == DEAD)
			if(!silent)
				to_chat(owner, span_xenodanger("We don't care about the dead!"))
			return FALSE

	if(!line_of_sight(owner, A, range))
		if(!silent)
			to_chat(owner, span_xenodanger("Our target must be closer!"))
		return FALSE


/datum/action/ability/activable/xeno/punch/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/damage = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier
	var/target_zone = check_zone(X.zone_selected)

	if(X.empower())
		damage *= 1.5
	if(!A.punch_act(X, damage, target_zone))
		return fail_activate()

	GLOB.round_statistics.warrior_punches++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_punches")

	succeed_activate()
	add_cooldown()

/atom/proc/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	return TRUE

/obj/machinery/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3) //Break open the machine
	X.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	if(!CHECK_BITFIELD(resistance_flags, UNACIDABLE) || resistance_flags == (UNACIDABLE|XENO_DAMAGEABLE)) //If it's acidable or we can't acid it but it has the xeno damagable flag, we can damage it
		attack_generic(X, damage * 4, BRUTE, "", FALSE) //Deals 4 times regular damage to machines
	X.visible_message(span_xenodanger("\The [X] smashes [src] with a [punch_description] punch!"), \
		span_xenodanger("We smash [src] with a [punch_description] punch!"), visible_message_flags = COMBAT_MESSAGE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)

	if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(machine_stat, PANEL_OPEN)

	if(wires) //If it has wires, break em
		var/allcut = wires.is_all_cut()
		if(!allcut) //Considered prohibiting this vs airlocks, but tbh, I can see clever warriors using this to keep airlocks bolted open or closed as is most advantageous
			wires.cut_all()
			visible_message(span_danger("\The [src]'s wires snap apart in a rain of sparks!"), null, null, 5)

	update_icon()
	return TRUE

/obj/machinery/computer/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3) //Break open the machine
	set_disabled() //Currently only computers use this; falcon punch away its density
	return ..()

/obj/machinery/light/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	. = ..()
	attack_alien(X) //Smash it

/obj/machinery/camera/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	. = ..()
	var/datum/effect_system/spark_spread/sparks = new //Avoid the slash text, go direct to sparks
	sparks.set_up(2, 0, src)
	sparks.attach(src)
	sparks.start()

	deactivate()
	visible_message(span_danger("\The [src]'s wires snap apart in a rain of sparks!")) //Smash it

/obj/machinery/power/apc/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	. = ..()
	beenhit += 4 //Break it open instantly

/obj/machinery/vending/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	. = ..()
	if(tipped_level < 2) //Knock it down if it isn't
		X.visible_message(span_danger("\The [X] knocks \the [src] down!"), \
		span_danger("You knock \the [src] down!"), null, 5)
		tip_over()

/obj/structure/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3) //Smash structures
	. = ..()
	X.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	attack_alien(X, damage * 4, BRUTE, "", FALSE) //Deals 4 times regular damage to structures
	X.visible_message(span_xenodanger("\The [X] smashes [src] with a devastating punch!"), \
		span_xenodanger("We smash [src] with a devastating punch!"), visible_message_flags = COMBAT_MESSAGE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)

/obj/vehicle/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	. = ..()
	X.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)
	attack_generic(X, damage * 4, BRUTE, "", FALSE) //Deals 4 times regular damage to vehicles
	X.visible_message(span_xenodanger("\The [X] smashes [src] with a devastating punch!"), \
		span_xenodanger("We smash [src] with a devastating punch!"), visible_message_flags = COMBAT_MESSAGE)
	playsound(src, pick('sound/effects/bang.ogg','sound/effects/metal_crash.ogg','sound/effects/meteorimpact.ogg'), 50, 1)
	Shake(duration = 0.5 SECONDS)
	return TRUE

/mob/living/punch_act(mob/living/carbon/xenomorph/warrior/X, damage, target_zone, push = TRUE, punch_description = "powerful", stagger_stacks = 3, slowdown_stacks = 3)
	. = ..()
	if(pulledby == X) //If we're being grappled by the Warrior punching us, it's gonna do extra damage and debuffs; combolicious
		damage *= 1.5
		slowdown_stacks *= 2
		stagger_stacks *= 2
		ParalyzeNoChain(0.5 SECONDS)
		X.stop_pulling()
		punch_description = "devastating"

	if(iscarbon(src))
		var/mob/living/carbon/carbon_victim = src
		var/datum/limb/L = carbon_victim.get_limb(target_zone)

		if (!L || (L.limb_status & LIMB_DESTROYED))
			L = carbon_victim.get_limb(BODY_ZONE_CHEST)
		apply_damage(damage, BRUTE, L, MELEE)
	else
		apply_damage(damage, BRUTE, blocked = MELEE)

	if(push)
		var/facing = get_dir(X, src)

		if(loc == X.loc) //If they're sharing our location we still want to punch them away
			facing = X.dir

		var/turf/T = X.loc
		var/turf/temp = X.loc

		for (var/x in 1 to 2)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp

		throw_at(T, 2, 1, X, 1) //Punch em away

	var/target_location_feedback = get_living_limb_descriptive_name(target_zone)
	X.visible_message(span_xenodanger("\The [X] hits [src] in the [target_location_feedback] with a [punch_description] punch!"), \
		span_xenodanger("We hit [src] in the [target_location_feedback] with a [punch_description] punch!"), visible_message_flags = COMBAT_MESSAGE)
	playsound(src, pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'), 50, 1)
	X.face_atom(src) //Face the target so you don't look like an idiot
	X.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)

	adjust_stagger(stagger_stacks SECONDS)
	add_slowdown(slowdown_stacks)
	adjust_blurriness(slowdown_stacks) //Cosmetic eye blur SFX

	apply_damage(damage, STAMINA, updating_health = TRUE) //Armor penetrating stamina also applies.
	shake_camera(src, 2, 1)
	Shake(duration = 0.5 SECONDS)

/datum/action/ability/activable/xeno/punch/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/punch/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Jab
// ***************************************
/datum/action/ability/activable/xeno/punch/jab
	name = "Jab"
	action_icon_state = "jab"
	desc = "Precisely strike your target from further away, heavily slowing them."
	ability_cost = 10
	range = 2
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_JAB,
	)

/datum/action/ability/activable/xeno/punch/jab/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/human/target = A
	var/target_zone = check_zone(X.zone_selected)
	var/damage = X.xeno_caste.melee_damage * X.xeno_melee_damage_modifier

	if(!target.punch_act(X, damage, target_zone, push = FALSE, punch_description = "precise", stagger_stacks = 3, slowdown_stacks = 6))
		return fail_activate()
	if(X.empower() && ishuman(target))
		target.blind_eyes(3)
		target.blur_eyes(6)
		to_chat(target, span_highdanger("The concussion from the [X]'s blow blinds us!"))
		target.apply_status_effect(STATUS_EFFECT_CONFUSED, 3 SECONDS)
	GLOB.round_statistics.warrior_punches++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_punches")
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/punch/jab/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_xenodanger("We gather enough strength to jab again."))
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()
