// ***************************************
// *********** Blink
// ***************************************
/datum/action/xeno_action/activable/blink
	plasma_cost = 15


// ***************************************
// *********** Timestop
// ***************************************
/datum/action/xeno_action/timestop
	plasma_cost = 50
	cooldown_timer = 30 SECONDS

// ***************************************
// *********** Banish
// ***************************************

///Ends the effect of the Banish ability
/datum/action/xeno_action/activable/banish/banish_deactivate()
	if(QDELETED(banishment_target))
		return
	var/turf/return_turf = get_turf(portal)
	if(!return_turf)
		return_turf = locate(backup_coordinates[1], backup_coordinates[2], backup_coordinates[3])

	for(var/atom/victim in return_turf)
		if(!ismovableatom(victim))
			continue
		var/atom/movable/movable_victim = victim
		if(movable_victim.anchored)
			continue
		if(ishuman(movable_victim))
			var/mob/living/carbon/human/H = movable_victim
			if(H.stat == DEAD)
				continue
		if(movable_victim)
			var/turf/targetturf = return_turf
			targetturf = locate(targetturf.x + rand(-1, 1), targetturf.y + rand(-1, 1), targetturf.z)
			movable_victim.throw_at(targetturf, 2, 1, owner, FALSE, FALSE)

	return ..()

// ***************************************
// *********** Portal
// ***************************************
/datum/action/xeno_action/portal
	plasma_cost = 30


// ***************************************
// *********** Rewind
// ***************************************

/datum/action/xeno_action/activable/rewind
	/// Initial fire stacks of the target
	var/target_initial_fire_stacks = 0
	/// Initial on_fire value
	var/target_initial_on_fire = FALSE

/datum/action/xeno_action/activable/rewind/use_ability(atom/A)
	targeted = A
	last_target_locs_list = list(get_turf(A))
	target_initial_brute_damage = targeted.getBruteLoss()
	target_initial_burn_damage = targeted.getFireLoss()
	target_initial_fire_stacks = targeted.fire_stacks
	target_initial_on_fire = targeted.on_fire
	if(isxeno(A))
		var/mob/living/carbon/xenomorph/xeno_target = targeted
		target_initial_sunder = xeno_target.sunder
	addtimer(CALLBACK(src, PROC_REF(start_rewinding)), start_rewinding)
	RegisterSignal(targeted, COMSIG_MOVABLE_MOVED, PROC_REF(save_move))
	targeted.add_filter("prerewind_blur", 1, radial_blur_filter(0.04))
	targeted.balloon_alert(targeted, "You feel anchored to the past!")
	ADD_TRAIT(targeted, TRAIT_TIME_SHIFTED, XENO_TRAIT)
	add_cooldown()
	succeed_activate()
	return

/// Move the target two tiles per tick
/datum/action/xeno_action/activable/rewind/rewind()
	var/turf/loc_a = pop(last_target_locs_list)
	if(loc_a)
		new /obj/effect/temp_visual/xenomorph/afterimage(targeted.loc, targeted)

	var/turf/loc_b = pop(last_target_locs_list)
	if(!loc_b)
		targeted.status_flags &= ~(INCORPOREAL|GODMODE)
		REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TIMESHIFT_TRAIT)
		if(isxeno(targeted))
			targeted.heal_overall_damage(targeted.getBruteLoss() - target_initial_brute_damage, targeted.getFireLoss() - target_initial_burn_damage, updating_health = TRUE)
			handle_fire()
			var/mob/living/carbon/xenomorph/xeno_target = targeted
			xeno_target.sunder = target_initial_sunder
		targeted.remove_filter("rewind_blur")
		REMOVE_TRAIT(targeted, TRAIT_TIME_SHIFTED, XENO_TRAIT)
		targeted = null
		return

	targeted.Move(loc_b, get_dir(loc_b, loc_a))
	new /obj/effect/temp_visual/xenomorph/afterimage(loc_a, targeted)
	INVOKE_NEXT_TICK(src, PROC_REF(rewind))

/datum/action/xeno_action/activable/rewind/proc/handle_fire()
	if(target_initial_on_fire == TRUE && target_initial_fire_stacks >= 0)
		targeted.fire_stacks = target_initial_fire_stacks
		targeted.IgniteMob()
	else
		targeted.ExtinguishMob()
