// ***************************************
// *********** Stomp
// ***************************************
/datum/action/xeno_action/activable/stomp
	name = "Stomp"
	action_icon_state = "stomp"
	mechanics_text = "Knocks all adjacent targets away and down."
	ability_name = "stomp"
	plasma_cost = 100
	cooldown_timer = 20 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_STOMP

/datum/action/xeno_action/activable/stomp/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.crusher_stomps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomps")

	playsound(X.loc, 'sound/effects/bang.ogg', 25, 0)
	X.visible_message(span_xenodanger("[X] smashes into the ground!"), \
	span_xenodanger("We smash into the ground!"))
	X.create_stomp() //Adds the visual effect. Wom wom wom

	for(var/mob/living/M in range(1, get_turf(X)))
		if(X.issamexenohive(M) || M.stat == DEAD || isnestedhost(M))
			continue
		var/distance = get_dist(M, X)
		var/damage = X.xeno_caste.stomp_damage/max(1, distance + 1)
		if(distance == 0) //If we're on top of our victim, give him the full impact
			GLOB.round_statistics.crusher_stomp_victims++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomp_victims")
			M.take_overall_damage_armored(damage, BRUTE, "melee", FALSE, FALSE, TRUE)
			M.Paralyze(3 SECONDS)
			to_chat(M, span_highdanger("You are stomped on by [X]!"))
			shake_camera(M, 3, 3)
		else
			step_away(M, X, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, span_highdanger("You reel from the shockwave of [X]'s stomp!"))
			M.take_overall_damage_armored(damage, BRUTE, "melee", FALSE, FALSE, TRUE)
			M.Paralyze(0.5 SECONDS)

/datum/action/xeno_action/activable/stomp/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/stomp/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Cresttoss
// ***************************************
/datum/action/xeno_action/activable/cresttoss
	name = "Crest Toss"
	action_icon_state = "cresttoss"
	mechanics_text = "Fling an adjacent target over and behind you. Also works over barricades."
	ability_name = "crest toss"
	plasma_cost = 75
	cooldown_timer = 12 SECONDS
	keybind_signal = COMSIG_XENOABILITY_CRESTTOSS
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/cresttoss/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_xenowarning("<b>We can now crest toss again.</b>"))
	playsound(X, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/cresttoss/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!owner.Adjacent(A) || !ismovable(A))
		return FALSE
	var/atom/movable/movable_atom = A
	if(movable_atom.anchored)
		return FALSE
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat == DEAD || isnestedhost(L)) //no bully
			return FALSE

/datum/action/xeno_action/activable/cresttoss/use_ability(atom/movable/A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(A) //Face towards the target so we don't look silly
	var/facing = get_dir(X, A)
	var/toss_distance = X.xeno_caste.crest_toss_distance
	var/turf/T = X.loc
	var/turf/temp = X.loc
	var/big_mob_message

	if(isliving(A))
		var/mob/living/L = A
		if(L.mob_size >= MOB_SIZE_BIG) //Penalize toss distance for big creatures
			toss_distance = FLOOR(toss_distance * 0.5, 1)
			big_mob_message = ", struggling mightily to heft its bulk"

	if(X.a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for(var/x in 1 to toss_distance)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(A, X)
		var/turf/throw_origin = get_step(T, facing)
		if(isclosedturf(throw_origin)) //Make sure the victim can actually go to the target turf
			to_chat(X, span_xenowarning("We try to fling [A] behind us, but there's no room!"))
			return fail_activate()
		for(var/obj/O in throw_origin)
			if(!O.CanPass(A, get_turf(X)) && !istype(O, /obj/structure/barricade)) //Ignore barricades because they will once thrown anyway
				to_chat(X, span_xenowarning("We try to fling [A] behind us, but there's no room!"))
				return fail_activate()

		A.forceMove(throw_origin) //Move the victim behind us before flinging
		for(var/x = 0, x < toss_distance, x++)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp //Throw target

	X.icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	X.visible_message(span_xenowarning("\The [X] flings [A] away with its crest[big_mob_message]!"), \
	span_xenowarning("We fling [A] away with our crest[big_mob_message]!"))

	succeed_activate()

	A.throw_at(T, toss_distance, 1, X, TRUE)

	//Handle the damage
	if(!X.issamexenohive(A) && isliving(A)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 6
		var/mob/living/L = A
		L.take_overall_damage_armored(damage, BRUTE, "melee", updating_health = TRUE)
		shake_camera(L, 2, 2)
		playsound(A, pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)

	add_cooldown()
	addtimer(CALLBACK(X, /mob/.proc/update_icons), 3)

/datum/action/xeno_action/activable/cresttoss/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/cresttoss/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

// ***************************************
// *********** Advance
// ***************************************
/datum/action/xeno_action/activable/advance
	name = "Rapid Advance"
	action_icon_state = "crest_defense"
	mechanics_text = "Charges up the crushers charge in place, then unleashes the full bulk of the crusher at the target location. Does not crush in diagonal directions."
	ability_name = "rapid advance"
	plasma_cost = 175
	cooldown_timer = 30 SECONDS
	keybind_signal = COMSIG_XENOABILITY_ADVANCE

/datum/action/xeno_action/activable/advance/on_cooldown_finish()
	to_chat(owner, span_xenowarning("<b>We can now rapidly charge forward again.</b>"))
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/advance/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(get_dist(owner, A) > 7)
		return FALSE


/datum/action/xeno_action/activable/advance/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(A)
	X.set_canmove(FALSE)
	if(!do_after(X, 10, TRUE, X, BUSY_ICON_DANGER))
		X.set_canmove(TRUE)
		return fail_activate()
	X.set_canmove(TRUE)

	var/datum/action/xeno_action/ready_charge/charge = X.actions_by_path[/datum/action/xeno_action/ready_charge]
	var/aimdir = get_dir(X,A)
	if(charge)
		charge.do_stop_momentum(FALSE) //Reset charge so next_move_limit check_momentum() does not cuck us and 0 out steps_taken
		charge.do_start_crushing()
		charge.valid_steps_taken = charge.max_steps_buildup - 1
		charge.charge_dir = aimdir //Set dir so check_momentum() does not cuck us
	for(var/i=0 to get_dist(X, A))
		if(i % 2)
			playsound(X, "alien_charge", 50)
			new /atom/movable/effect/temp_visual/xenomorph/afterimage(get_turf(X), X)
		X.Move(get_step(X, aimdir), aimdir)
		aimdir = get_dir(X,A)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/advance/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/advance/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE
