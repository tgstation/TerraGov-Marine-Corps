// ***************************************
// *********** Stomp
// ***************************************
/datum/action/ability/activable/xeno/stomp
	name = "Stomp"
	action_icon_state = "stomp"
	desc = "Knocks all adjacent targets away and down."
	ability_cost = 100
	cooldown_duration = 16 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_STOMP,
	)

/datum/action/ability/activable/xeno/stomp/use_ability(atom/A)
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
		if(X.issamexenohive(M) || M.stat == DEAD || isnestedhost(M) || !X.Adjacent(M))
			continue
		var/distance = get_dist(M, X)
		var/damage = X.xeno_caste.stomp_damage/max(1, distance + 1)
		if(distance == 0) //If we're on top of our victim, give him the full impact
			GLOB.round_statistics.crusher_stomp_victims++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomp_victims")
			M.take_overall_damage(damage, BRUTE, MELEE, updating_health = TRUE, max_limbs = 3)
			M.Paralyze(3 SECONDS)
			to_chat(M, span_highdanger("You are stomped on by [X]!"))
			shake_camera(M, 3, 3)
		else
			step_away(M, X, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, span_highdanger("You reel from the shockwave of [X]'s stomp!"))
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
#define CRUSHER_IMPACT_DAMAGE_MULTIPLIER 1
#define CRUSHER_DISPLACE_KNOCKDOWN 0.8 SECONDS

/datum/action/ability/activable/xeno/cresttoss
	name = "Crest Toss"
	action_icon_state = "cresttoss"
	desc = "Fling an adjacent target over and behind you, or away from you while on harm intent. Also works over barricades."
	ability_cost = 75
	cooldown_duration = 14 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_CRESTTOSS,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/xeno/cresttoss/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, span_xenowarning("<b>We can now crest toss again.</b>"))
	playsound(X, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
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
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(A) //Face towards the target so we don't look silly
	var/facing
	var/toss_distance = X.xeno_caste.crest_toss_distance
	var/turf/throw_origin = get_turf(A)
	var/turf/target_turf = throw_origin //throw distance is measured from the target
	var/big_mob_message

	if(!X.issamexenohive(A)) //xenos should be able to fling xenos into xeno passable areas!
		for(var/obj/effect/forcefield/fog/fog in throw_origin)
			A.balloon_alert(X, "Cannot, fog")
			return fail_activate()
	if(isliving(A))
		var/mob/living/L = A
		if(L.mob_size >= MOB_SIZE_BIG) //Penalize toss distance for big creatures
			toss_distance = FLOOR(toss_distance * 0.5, 1)
			big_mob_message = ", struggling mightily to heft its bulk"
	else if(ismecha(A))
		toss_distance = FLOOR(toss_distance * 0.5, 1)
		big_mob_message = ", struggling mightily to heft its bulk"

	if(X.a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		facing = get_dir(X, A)
	else
		facing = get_dir(A, X)

	var/turf/temp
	for(var/x in 1 to toss_distance)
		temp = get_step(target_turf, facing)
		if(!temp)
			break
		target_turf = temp

	X.icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	X.visible_message(span_xenowarning("\The [X] flings [A] away with its crest[big_mob_message]!"), \
	span_xenowarning("We fling [A] away with our crest[big_mob_message]!"))

	succeed_activate()

	A.forceMove(throw_origin)
	A.throw_at(target_turf, toss_distance, 1, X, TRUE, TRUE)

	//Handle the damage
	if(!X.issamexenohive(A) && isliving(A)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 7
		var/mob/living/L = A
		L.take_overall_damage(damage, BRUTE, MELEE, updating_health = TRUE)
		shake_camera(L, 2, 2)
		playsound(A, pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)
		RegisterSignal(A, COMSIG_MOVABLE_IMPACT, PROC_REF(thrown_into))
	add_cooldown()
	addtimer(CALLBACK(X, TYPE_PROC_REF(/mob, update_icons)), 3)

/// Handles anything that would happen when a target is thrown into an atom using an ability.
/datum/action/ability/activable/xeno/cresttoss/proc/thrown_into(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/mob/living/living_target = source
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")
	living_target.Knockdown(CRUSHER_DISPLACE_KNOCKDOWN)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	new /obj/effect/temp_visual/crusher/impact(get_turf(living_target), get_dir(living_target, xeno_owner))
	// mob/living/turf_collision() does speed * 5 damage on impact with a turf, and we don't want to go overboard, so we deduce that here.
	var/thrown_damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) - (impact_speed * 5)) * CRUSHER_IMPACT_DAMAGE_MULTIPLIER
	living_target.apply_damage(thrown_damage, BRUTE, blocked = MELEE)
	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		if(hit_living.issamexenohive(xeno_owner))
			return
		INVOKE_ASYNC(hit_living, TYPE_PROC_REF(/mob, emote), "scream")
		hit_living.apply_damage(thrown_damage, BRUTE, blocked = MELEE)
		hit_living.Knockdown(CRUSHER_DISPLACE_KNOCKDOWN)
		step_away(hit_living, living_target, 1, 1)
	if(isobj(hit_atom))
		var/obj/hit_object = hit_atom
		if(istype(hit_object, /obj/structure/xeno))
			return
		hit_object.take_damage(thrown_damage, BRUTE, MELEE)
	if(iswallturf(hit_atom))
		var/turf/closed/wall/hit_wall = hit_atom
		if(!(hit_wall.resistance_flags & INDESTRUCTIBLE))
			hit_wall.take_damage(thrown_damage, BRUTE, MELEE)


/obj/effect/temp_visual/crusher/impact
	icon = 'icons/effects/96x96.dmi'
	icon_state = "throw_impact"
	duration = 3.5
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/crusher/impact/Initialize(mapload, direction)
	. = ..()
	animate(src, alpha = 0, time = duration - 1.5)
	// directions refuse to work naturally so i improvised, suck it byond
	direction = closest_cardinal_dir(direction)
	switch(direction)
		if(NORTH)
			icon_state = "[initial(icon_state)]_n"
			pixel_y -= 20
		if(SOUTH)
			icon_state = "[initial(icon_state)]_s"
			pixel_y += 20
		if(WEST)
			icon_state = "[initial(icon_state)]_w"
			pixel_x += 20
		if(EAST)
			icon_state = "[initial(icon_state)]_e"
			pixel_x -= 20

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
	playsound(owner, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	return ..()

/datum/action/ability/activable/xeno/advance/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(get_dist(owner, A) > advance_range)
		return FALSE


/datum/action/ability/activable/xeno/advance/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	X.face_atom(A)
	X.set_canmove(FALSE)
	if(!do_after(X, 1 SECONDS, NONE, X, BUSY_ICON_DANGER) || (QDELETED(A)) || X.z != A.z)
		if(!X.stat)
			X.set_canmove(TRUE)
		return fail_activate()
	X.set_canmove(TRUE)

	var/datum/action/ability/xeno_action/ready_charge/charge = X.actions_by_path[/datum/action/ability/xeno_action/ready_charge]
	var/aimdir = get_dir(X, A)
	if(charge)
		charge.charge_on(FALSE)
		charge.do_stop_momentum(FALSE) //Reset charge so next_move_limit check_momentum() does not cuck us and 0 out steps_taken
		charge.do_start_crushing()
		charge.valid_steps_taken = charge.max_steps_buildup - 1
		charge.charge_dir = aimdir //Set dir so check_momentum() does not cuck us
	for(var/i=0 to max(get_dist(X, A), advance_range))
		if(i % 2)
			playsound(X, "alien_charge", 50)
			new /obj/effect/temp_visual/after_image(get_turf(X), X)
		X.Move(get_step(X, aimdir), aimdir)
		aimdir = get_dir(X, A)
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
