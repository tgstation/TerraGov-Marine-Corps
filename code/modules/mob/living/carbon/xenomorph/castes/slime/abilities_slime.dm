// ***************************************
// *********** Pounce (Slime)
// ***************************************
/datum/action/xeno_action/activable/slime_pounce
	name = "Pounce"
	ability_name = "Pounce"
	action_icon_state = "pounce"
	desc = "Leap towards your target, attaching to it."
	cooldown_timer = 1.5 SECONDS
	plasma_cost = 20
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_POUNCE,
	)
*/
	use_state_flags = XACT_USE_BUCKLED
	/// How far can we pounce.
	var/pounce_range = 5
	/// How fast does the pounce happen.
	var/pounce_speed = 1

/datum/action/xeno_action/activable/slime_pounce/proc/ability_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT))
	SEND_SIGNAL(owner, COMSIG_XENOMORPH_POUNCE_END)

/datum/action/xeno_action/activable/slime_pounce/proc/obj_hit(datum/source, obj/target_obj)
	SIGNAL_HANDLER
	message_admins("slime_pounce/obj_hit called (target_obj = [target_obj])")
	handle_hit(target_obj)

/datum/action/xeno_action/activable/slime_pounce/proc/mob_hit(datum/source, mob/living/target_mob)
	SIGNAL_HANDLER
	if(target_mob.stat)
		return
	message_admins("slime_pounce/mob_hit called (target_mob = [target_mob])")
	handle_hit(target_mob)

/datum/action/xeno_action/activable/slime_pounce/proc/handle_hit(target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	message_admins("slime_pounce/handle_hit called (target = [target])")
	xeno_owner.forceMove(get_turf(target))
	xeno_owner.buckle_mob(target, silent = TRUE)
	ability_complete()

/datum/action/xeno_action/activable/slime_pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/slime_pounce/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/slime_pounce/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_XENO_LIVING_THROW_HIT, PROC_REF(mob_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(ability_complete))
	if(xeno_owner.layer == XENO_HIDING_LAYER)
		xeno_owner.layer = MOB_LAYER
	if(xeno_owner.buckled)
		xeno_owner.buckled.unbuckle_mob(xeno_owner)
	SEND_SIGNAL(xeno_owner, COMSIG_XENOMORPH_POUNCE)
	succeed_activate()
	add_cooldown()
	xeno_owner.usedPounce = TRUE
	xeno_owner.flags_pass = PASSTABLE|PASSFIRE
	xeno_owner.throw_at(A, pounce_range, pounce_speed, xeno_owner) // Victim, distance, speed
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob/living/carbon/xenomorph, reset_flags_pass)), 6)
	return TRUE

// ***************************************
// *********** Thorn Spread
// ***************************************
/datum/action/xeno_action/thorn_spread
	name = "Thorn Spread"
	ability_name = "Thorn Spread"
	action_icon_state = "tail_sweep"
	desc = "Hit all adjacent units around you, knocking them away and down."
	plasma_cost = 35
	use_state_flags = XACT_USE_BUCKLED
	cooldown_timer = 20 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TAIL_SWEEP,
	)
*/
	/// The range of this ability.
	var/spread_range = 1

/datum/action/xeno_action/thorn_spread/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
	for(var/mob/living/carbon/target_carbon in orange(spread_range, X))
		if(target_carbon.stat != DEAD)
			var/damage = X.xeno_caste.melee_damage
			var/affected_limb = target_human.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			H.apply_damage(damage, BRUTE, affecting, MELEE)
			H.apply_damage(damage, STAMINA, updating_health = TRUE)
			H.Paralyze(5) //trip and go
		shake_camera(H, 2, 1)
	succeed_activate()
	add_cooldown()
