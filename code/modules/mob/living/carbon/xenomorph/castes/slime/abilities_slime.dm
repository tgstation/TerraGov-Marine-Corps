// ***************************************
// *********** Pounce (Slime)
// ***************************************
/datum/action/xeno_action/activable/slime_pounce
	name = "Pounce"
	ability_name = "Pounce"
	action_icon_state = "pounce"
	desc = "Leap towards your target, attaching to it."
	cooldown_timer = 1 SECONDS
	plasma_cost = 15
	use_state_flags = XACT_USE_BUCKLED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_POUNCE,
	)

	/// How far can we pounce.
	var/pounce_range = 5
	/// How fast does the pounce happen.
	var/pounce_speed = 1
	/// The living atom we're attached to.
	var/atom/attached_atom
	/// The living mob we're attached to.
	var/mob/living/attached_living

/datum/action/xeno_action/activable/slime_pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/slime_pounce/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.layer == XENO_HIDING_LAYER)
		xeno_owner.layer = MOB_LAYER
	if(xeno_owner.buckled)
		xeno_owner.buckled.unbuckle_mob(xeno_owner)
	xeno_owner.flags_pass = PASSTABLE|PASSFIRE
	addtimer(CALLBACK(xeno_owner, TYPE_PROC_REF(/mob/living/carbon/xenomorph, reset_flags_pass)), 6)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_IMPACT, PROC_REF(atom_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_complete))
	xeno_owner.throw_at(A, pounce_range, pounce_speed, xeno_owner)
	succeed_activate()
	add_cooldown()
	return TRUE

/// Called whenever the Slime hits an atom
/datum/action/xeno_action/activable/slime_pounce/proc/atom_hit(datum/source, atom/hit_atom)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	throw_complete()
	attached_atom = hit_atom
	RegisterSignal(attached_atom, COMSIG_ATOM_BULLET_ACT, PROC_REF(call_attached_atom_hit))
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		attached_living.buckle_mob(xeno_owner, TRUE, TRUE, 90, 1, 0)
		RegisterSignal(xeno_owner, COMSIG_XENOMORPH_FIRE_BURNING, PROC_REF(call_living_unbuckle))
		RegisterSignal(attached_living, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(call_living_unbuckle))
		RegisterSignal(attached_living, COMSIG_LIVING_DO_RESIST, PROC_REF(call_living_resist))
		if(!HAS_TRAIT(attached_living, TRAIT_INTOXICATION_IMMUNE))
			effect_over_time(SLIME_POUNCE_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks)
		return
	xeno_owner.forceMove(get_turf(hit_atom))

/// Applies effects over a set amount of time.
/// Will call itself every 2 seconds unless there is no longer an attached atom.
/datum/action/xeno_action/activable/slime_pounce/proc/effect_over_time(stacks)
	if(!attached_atom || !owner.buckled)
		return
	addtimer(CALLBACK(src, PROC_REF(effect_over_time), stacks), SLIME_POUNCE_INFLICTION_RATE)
	var/mob/living/attached_living = attached_atom
	if(attached_living.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = attached_living.has_status_effect(STATUS_EFFECT_INTOXICATED)
		debuff.add_stacks(stacks)
		return
	attached_living.apply_status_effect(STATUS_EFFECT_INTOXICATED, stacks)

/// Calls attached_atom_hit via INVOKE_ASYNC.
/datum/action/xeno_action/activable/slime_pounce/proc/call_attached_atom_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attached_atom_hit))

/// Called whenever the atom the Slime is attached to is hit by a projectile.
/// Unbuckles if the projectile is fire, and reflects all dealt damage to the Slime.
/datum/action/xeno_action/activable/slime_pounce/proc/attached_atom_hit(datum/source, obj/projectile/proj)
	if(attached_atom && proj.ammo.flags_ammo_behavior & AMMO_FLAME) // If hit by a fire projectile, automatically unbuckle.
		living_unbuckle()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.apply_damage(proj.damage, proj.ammo.damage_type, penetration = proj.ammo.penetration)

/// Calls living_resist via INVOKE_ASYNC.
/datum/action/xeno_action/activable/slime_pounce/proc/call_living_resist()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(living_resist))

/// Called whenever the living target we're attached to uses the Resist verb.
/// This proc makes the living target execute a channel. If it succeeds, the Slime is unbuckled.
/datum/action/xeno_action/activable/slime_pounce/proc/living_resist()
	var/mob/living/attached_living = attached_atom
	if(!do_after(attached_living, SLIME_POUNCE_RESIST_CHANNEL, TRUE, attached_living, BUSY_ICON_GENERIC))
		attached_living.balloon_alert("Interrupted")
		return
	attached_living.balloon_alert("Succeeded")
	living_unbuckle()

/// Calls living_unbuckle via INVOKE_ASYNC.
/datum/action/xeno_action/activable/slime_pounce/proc/call_living_unbuckle()
	SIGNAL_HANDLER
	message_admins("living_unbuckle called")
	INVOKE_ASYNC(src, PROC_REF(living_unbuckle))

/// Unbuckles the Slime from the living target and punishes them for a successful resist.
/datum/action/xeno_action/activable/slime_pounce/proc/living_unbuckle()
	UnregisterSignal(attached_atom, list(COMSIG_ATOM_BULLET_ACT, COMSIG_LIVING_DO_RESIST))
	UnregisterSignal(owner, list(COMSIG_XENOMORPH_FIRE_BURNING))
	var/mob/living/attached_living = attached_atom
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(attached_living.buckled_mobs)
		attached_living.unbuckle_mob(owner)
	attached_atom = null
	xeno_owner.Stun(SLIME_POUNCE_UNBUCKLE_STUN_DURATION)
	xeno_owner.balloon_alert_to_viewers("Thrown off!")

/// Called whenever the throw_at is completed.
/datum/action/xeno_action/activable/slime_pounce/proc/throw_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))

/// Called whenever an attachment is ended. Clears signals.
/datum/action/xeno_action/activable/slime_pounce/proc/end_attachment()
	SIGNAL_HANDLER

// ***************************************
// *********** Spread Thorns
// ***************************************
/datum/action/xeno_action/spread_thorns
	name = "Spread Thorns"
	ability_name = "Spread Thorns"
	action_icon_state = "tail_sweep"
	desc = "Spread hardened, thorn-like protrusions, dealing damage to surrounding enemies and rooting them for a brief moment."
	cooldown_timer = 20 SECONDS
	plasma_cost = 50
	use_state_flags = XACT_USE_BUCKLED
	keybind_flags = XACT_KEYBIND_USE_ABILITY
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SPREAD_THORNS,
	)
*/
	/// The range of this ability.
	var/spread_range = 1
	/// The duration of this ability's wind-up.
	var/windup_time = 0.5 SECONDS

/datum/action/xeno_action/spread_thorns/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!do_after(xeno_owner, windup_time, FALSE, xeno_owner, BUSY_ICON_DANGER))
		return
	for(var/mob/living/carbon/human/affected_human in orange(spread_range, xeno_owner))
		if(affected_human.stat == DEAD)
			return
		affected_human.apply_damage(xeno_owner.xeno_caste.melee_damage, BURN, blocked = ACID)
		affected_human.Immobilize(1.5 SECONDS)
		affected_human.do_jitter_animation(1 SECONDS)
		affected_human.emote("pain")
		shake_camera(affected_human, 2, 1)
	succeed_activate()
	add_cooldown()

// ***************************************
// *********** Extend Thorn
// ***************************************
/datum/action/xeno_action/activable/extend_thorn
	name = "Extend Thorn"
	ability_name = "Extend Thorn"
	action_icon_state = "tail_sweep"
	desc = "Extend a hardened, thorn-like protrusion, dealing damage to a target and pulling them closer to you."
	cooldown_timer = 20 SECONDS
	plasma_cost = 50
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_USE_BUCKLED
	keybind_flags = XACT_KEYBIND_USE_ABILITY
/*
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EXTEND_THORN,
	)
*/
	/// The range of this ability.
	var/extension_range = 2
	/// Reference to beam protrusion.
	var/datum/beam/protrusion

/datum/action/xeno_action/activable/extend_thorn/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isitem(A) && !ishuman(A))
		if(!silent)
			A.balloon_alert(owner, "Invalid target")
		return FALSE
	if(isliving(A))
		var/mob/living/livingtarget = A
		if(livingtarget.stat == DEAD)
			if(!silent)
				livingtarget.balloon_alert(owner, "Invalid target")
			return FALSE
	var/atom/movable/target = A
	if(target.anchored)
		if(!silent)
			target.balloon_alert(owner, "Invalid target")
		return FALSE

	var/turf/current = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	if(current == target_turf)
		return TRUE
	if(get_dist(current, target_turf) > extension_range)
		return FALSE
	current = get_step_towards(current, target_turf)
	while((current != target_turf))
		if(current.density)
			return FALSE
		current = get_step_towards(current, target_turf)

/datum/action/xeno_action/activable/extend_thorn/use_ability(atom/movable/target)
	var/atom/movable/protrusion_end/protrusion_end = new (get_turf(owner))
	protrusion = owner.beam(protrusion_end,"curse0",'icons/effects/beam.dmi')
	RegisterSignal(protrusion_end, list(COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_IMPACT), PROC_REF(finish_grab))
	protrusion_end.throw_at(target, extension_range, 3, owner, FALSE)
	succeed_activate()
	add_cooldown()

/// Signal handler to grab the target when we thentacle head hit something
/datum/action/xeno_action/activable/extend_thorn/proc/finish_grab(datum/source, atom/movable/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	QDEL_NULL(protrusion)
	qdel(source)
	if(!can_use_ability(target, TRUE, XACT_IGNORE_COOLDOWN|XACT_IGNORE_PLASMA))
		owner.balloon_alert(owner, "Failed")
		clear_cooldown()
		return
	protrusion = owner.beam(target, "curse0",'icons/effects/beam.dmi')
	playsound(target, 'sound/effects/blobattack.ogg', 40, 1)
	RegisterSignal(target, COMSIG_MOVABLE_POST_THROW, PROC_REF(delete_beam))
	target.throw_at(owner, extension_range, 1, owner, FALSE)
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(xeno_owner.xeno_caste.melee_damage, BURN, blocked = ACID)
		living_target.Immobilize(1.5 SECONDS)
		living_target.do_jitter_animation(1 SECONDS)
		shake_camera(living_target, 2, 1)

/// Deletes the extended protrusion.
/datum/action/xeno_action/activable/extend_thorn/proc/delete_beam(datum/source, atom/impacted)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_POST_THROW)
	QDEL_NULL(protrusion)

/atom/movable/protrusion_end
	name = "You can't see this"
	invisibility = INVISIBILITY_ABSTRACT
