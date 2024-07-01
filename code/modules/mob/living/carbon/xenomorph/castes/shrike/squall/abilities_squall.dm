// ***************************************
// *********** Psychic Fling (Squall)
// ***************************************
#define PSYCHIC_FLING_IMPACT_DAMAGE_MULTIPLIER 0.5
#define PSYCHIC_FLING_IMPACT_STUN_MULTIPLIER 5

/datum/action/ability/activable/xeno/psychic_fling/squall
	cooldown_duration = 6 SECONDS
	ability_cost = 50
	stun_duration = 0.2 SECONDS
	use_state_flags = ABILITY_DO_AFTER_ATTACK

/datum/action/ability/activable/xeno/psychic_fling/squall/do_fling(atom/movable/target)
	if(isliving(target))
		RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(flung_into))
		RegisterSignal(target, COMSIG_MOVABLE_POST_THROW, PROC_REF(fling_ended))
	return ..()

/// Handles anything that would happen when a target is thrown into an atom using an ability.
/datum/action/ability/activable/xeno/psychic_fling/squall/proc/flung_into(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/mob/living/living_target = source
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	new /obj/effect/temp_visual/warrior/impact(get_turf(living_target), get_dir(living_target, xeno_owner))
	// mob/living/turf_collision() does speed * 5 damage on impact with a turf, and we don't want to go overboard, so we deduce that here.
	var/thrown_damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) - (impact_speed * 5)) * PSYCHIC_FLING_IMPACT_DAMAGE_MULTIPLIER
	living_target.apply_damage(thrown_damage, BRUTE, blocked = MELEE)
	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		if(hit_living.issamexenohive(xeno_owner))
			return
		INVOKE_ASYNC(hit_living, TYPE_PROC_REF(/mob, emote), "scream")
		hit_living.apply_damage(thrown_damage, BRUTE, blocked = MELEE)
		hit_living.Knockdown(stun_duration * PSYCHIC_FLING_IMPACT_STUN_MULTIPLIER)
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

/// Ends the target's throw.
/datum/action/ability/activable/xeno/psychic_fling/squall/proc/fling_ended(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	/* So the reason why we do not flat out unregister this is because, when an atom makes impact with something, it calls throw_impact(). Calling it this way causes
	stop_throw() to be called in most cases, because impacts can cause a bounce effect and ending the throw makes it happen. Given the way we have signals setup, unregistering
	it at that point would cause thrown_into() to never get called, and that is exactly the reason why the line of code below exists. */
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, UnregisterSignal), source, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW), 1)
	var/mob/living/living_target = source
	if(living_target.pass_flags & PASS_XENO)
		living_target.pass_flags &= ~PASS_XENO



// ***************************************
// *********** Unrelenting Force (Squall)
// ***************************************
/datum/action/ability/activable/xeno/unrelenting_force/squall
	cooldown_duration = 25 SECONDS
	ability_cost = 150
	stun_duration = 1 SECONDS
	weaken_duration = 1 SECONDS
	use_state_flags = ABILITY_DO_AFTER_ATTACK

/datum/action/ability/activable/xeno/unrelenting_force/squall/do_screech(list/turf/affected_turfs)
	var/list/things_to_throw = list()
	for(var/turf/affected_turf in affected_turfs)
		affected_turf.Shake(duration = 0.5 SECONDS)
		for(var/atom/movable/affected_movable AS in affected_turf)
			if(!isliving(affected_movable) && !isitem(affected_movable) && !isdroid(affected_movable))
				affected_movable.Shake(duration = 0.5 SECONDS)
				continue
			if(isliving(affected_movable))
				var/mob/living/affected_living = affected_movable
				if(affected_living.stat == DEAD)
					continue
				affected_living.apply_effects(stun_duration, weaken_duration)
				shake_camera(affected_living, 2, 1)
			things_to_throw += affected_movable
	for(var/atom/movable/affected_movable AS in things_to_throw)
		if(isliving(affected_movable))
			RegisterSignal(affected_movable, COMSIG_MOVABLE_IMPACT, PROC_REF(flung_into))
			RegisterSignal(affected_movable, COMSIG_MOVABLE_POST_THROW, PROC_REF(fling_ended))
		affected_movable.knockback(affected_movable.loc, UNRELENTING_FORCE_KNOCK_BACK, 1, owner.dir, spin = TRUE)
	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, SFX_ALIEN_ROAR, 50)

/// Handles anything that would happen when a target is thrown into an atom using an ability.
/datum/action/ability/activable/xeno/unrelenting_force/squall/proc/flung_into(datum/source, atom/hit_atom, impact_speed)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	var/mob/living/living_target = source
	INVOKE_ASYNC(living_target, TYPE_PROC_REF(/mob, emote), "scream")
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	new /obj/effect/temp_visual/warrior/impact(get_turf(living_target), get_dir(living_target, xeno_owner))
	// mob/living/turf_collision() does speed * 5 damage on impact with a turf, and we don't want to go overboard, so we deduce that here.
	var/thrown_damage = ((xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) - (impact_speed * 5)) * PSYCHIC_FLING_IMPACT_DAMAGE_MULTIPLIER
	living_target.apply_damage(thrown_damage, BRUTE, blocked = MELEE)
	if(isliving(hit_atom))
		var/mob/living/hit_living = hit_atom
		if(hit_living.issamexenohive(xeno_owner))
			return
		INVOKE_ASYNC(hit_living, TYPE_PROC_REF(/mob, emote), "scream")
		hit_living.apply_damage(thrown_damage, BRUTE, blocked = MELEE)
		hit_living.Knockdown(stun_duration * PSYCHIC_FLING_IMPACT_STUN_MULTIPLIER)
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

/// Ends the target's throw.
/datum/action/ability/activable/xeno/unrelenting_force/squall/proc/fling_ended(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	/* So the reason why we do not flat out unregister this is because, when an atom makes impact with something, it calls throw_impact(). Calling it this way causes
	stop_throw() to be called in most cases, because impacts can cause a bounce effect and ending the throw makes it happen. Given the way we have signals setup, unregistering
	it at that point would cause thrown_into() to never get called, and that is exactly the reason why the line of code below exists. */
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, UnregisterSignal), source, COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW), 1)
	var/mob/living/living_target = source
	if(living_target.pass_flags & PASS_XENO)
		living_target.pass_flags &= ~PASS_XENO
