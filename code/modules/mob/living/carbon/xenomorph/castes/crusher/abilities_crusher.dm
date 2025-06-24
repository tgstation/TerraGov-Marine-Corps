// ***************************************
// *********** Stomp
// ***************************************
/datum/action/ability/activable/xeno/stomp
	name = "Stomp"
	action_icon_state = "stomp"
	action_icon = 'icons/Xeno/actions/crusher.dmi'
	desc = "Knocks all adjacent targets away and down."
	ability_cost = 100
	cooldown_duration = 20 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_STOMP,
	)

/datum/action/ability/activable/xeno/stomp/use_ability(atom/A)
	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.crusher_stomps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomps")

	playsound(xeno_owner.loc, 'sound/effects/bang.ogg', 25, 0)
	xeno_owner.visible_message(span_xenodanger("[xeno_owner] smashes into the ground!"), \
	span_xenodanger("We smash into the ground!"))
	xeno_owner.create_stomp() //Adds the visual effect. Wom wom wom

	for(var/mob/living/M in range(1, get_turf(xeno_owner)))
		if(xeno_owner.issamexenohive(M) || M.stat == DEAD || isnestedhost(M) || !xeno_owner.Adjacent(M))
			continue
		var/distance = get_dist(M, xeno_owner)
		var/damage = xeno_owner.xeno_caste.stomp_damage/max(1, distance + 1)
		if(distance == 0) //If we're on top of our victim, give him the full impact
			GLOB.round_statistics.crusher_stomp_victims++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomp_victims")
			M.take_overall_damage(damage, BRUTE, MELEE, updating_health = TRUE, max_limbs = 3)
			M.Paralyze(3 SECONDS)
			to_chat(M, span_userdanger("You are stomped on by [xeno_owner]!"))
			shake_camera(M, 3, 3)
		else
			step_away(M, xeno_owner, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, span_userdanger("You reel from the shockwave of [xeno_owner]'s stomp!"))
			M.take_overall_damage(damage, BRUTE, MELEE, updating_health = TRUE, max_limbs = 3)
			M.Paralyze(0.5 SECONDS)

/datum/action/ability/activable/xeno/stomp/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/stomp/ai_should_use(atom/target)
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
// *********** Cresttoss
// ***************************************
/datum/action/ability/activable/xeno/cresttoss
	name = "Crest Toss"
	action_icon_state = "cresttoss"
	action_icon = 'icons/Xeno/actions/crusher.dmi'
	desc = "Fling an adjacent target over and behind you, or away from you while on harm intent. Also works over barricades."
	ability_cost = 75
	cooldown_duration = 12 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CRESTTOSS,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/cresttoss/on_cooldown_finish()
	to_chat(xeno_owner, span_xenowarning("<b>We can now crest toss again.</b>"))
	playsound(xeno_owner, 'sound/effects/alien/new_larva.ogg', 50, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/cresttoss/can_use_ability(atom/A, silent = FALSE, override_flags)
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

/datum/action/ability/activable/xeno/cresttoss/use_ability(atom/movable/A)
	xeno_owner.face_atom(A) //Face towards the target so we don't look silly
	var/facing
	var/toss_distance = xeno_owner.xeno_caste.crest_toss_distance
	var/turf/throw_origin = get_turf(xeno_owner)
	var/turf/target_turf = throw_origin //throw distance is measured from the xeno itself
	var/big_mob_message

	if(!xeno_owner.issamexenohive(A)) //xenos should be able to fling xenos into xeno passable areas!
		for(var/obj/effect/forcefield/fog/fog in throw_origin)
			A.balloon_alert(xeno_owner, "Cannot, fog")
			return fail_activate()
	if(A.move_resist >= MOVE_FORCE_OVERPOWERING)
		A.balloon_alert(xeno_owner, "Too heavy!")
		return fail_activate()
	if(isliving(A))
		var/mob/living/L = A
		if(L.mob_size >= MOB_SIZE_BIG) //Penalize toss distance for big creatures
			toss_distance = FLOOR(toss_distance * 0.5, 1)
			big_mob_message = ", struggling mightily to heft its bulk"
	else if(ismecha(A))
		toss_distance = FLOOR(toss_distance * 0.5, 1)
		big_mob_message = ", struggling mightily to heft its bulk"

	if(xeno_owner.a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		facing = get_dir(xeno_owner, A)
	else
		facing = get_dir(A, xeno_owner)

	var/turf/temp
	for(var/x in 1 to toss_distance)
		temp = get_step(target_turf, facing)
		if(!temp)
			break
		target_turf = temp

	xeno_owner.icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] flings [A] away with its crest[big_mob_message]!"), \
	span_xenowarning("We fling [A] away with our crest[big_mob_message]!"))

	succeed_activate()

	A.forceMove(throw_origin)
	A.throw_at(target_turf, toss_distance, 1, xeno_owner, TRUE, TRUE)

	//Handle the damage
	if(!xeno_owner.issamexenohive(A) && isliving(A)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 6
		var/mob/living/L = A
		L.take_overall_damage(damage, BRUTE, MELEE, updating_health = TRUE)
		shake_camera(L, 2, 2)
		playsound(A, pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)

	add_cooldown()
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob, update_icons)), 3)

/datum/action/ability/activable/xeno/cresttoss/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/cresttoss/ai_should_use(atom/target)
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
// *********** Advance
// ***************************************
/datum/action/ability/activable/xeno/advance
	name = "Rapid Advance"
	action_icon_state = "crest_defense"
	action_icon = 'icons/Xeno/actions/defender.dmi'
	desc = "Charges up the crushers charge in place, then unleashes the full bulk of the crusher at the target location. Does not crush in diagonal directions."
	ability_cost = 175
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ADVANCE,
	)
	///Max charge range
	var/advance_range = 7

/datum/action/ability/activable/xeno/advance/on_cooldown_finish()
	to_chat(owner, span_xenowarning("<b>We can now rapidly charge forward again.</b>"))
	playsound(owner, 'sound/effects/alien/new_larva.ogg', 50, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/advance/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(get_dist(owner, A) > advance_range)
		return FALSE


/datum/action/ability/activable/xeno/advance/use_ability(atom/A)
	xeno_owner.face_atom(A)
	xeno_owner.set_canmove(FALSE)
	if(!do_after(xeno_owner, 1 SECONDS, NONE, xeno_owner, BUSY_ICON_DANGER) || (QDELETED(A)) || xeno_owner.z != A.z)
		if(!xeno_owner.stat)
			xeno_owner.set_canmove(TRUE)
		return fail_activate()
	xeno_owner.set_canmove(TRUE)

	var/datum/action/ability/xeno_action/ready_charge/charge = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge]
	var/aimdir = get_dir(xeno_owner, A)
	if(charge)
		charge.charge_on(FALSE)
		charge.do_stop_momentum(FALSE) //Reset charge so next_move_limit check_momentum() does not cuck us and 0 out steps_taken
		charge.do_start_crushing()
		charge.valid_steps_taken = charge.max_steps_buildup - 1
		charge.charge_dir = aimdir //Set dir so check_momentum() does not cuck us
	for(var/i=0 to max(get_dist(xeno_owner, A), advance_range))
		if(i % 2)
			playsound(xeno_owner, SFX_ALIEN_CHARGE, 50)
			new /obj/effect/temp_visual/after_image(get_turf(xeno_owner), xeno_owner)
		xeno_owner.Move(get_step(xeno_owner, aimdir), aimdir)
		aimdir = get_dir(xeno_owner, A)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/advance/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/advance/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE
