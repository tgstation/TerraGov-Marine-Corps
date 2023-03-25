/obj/effect/temp_visual/tendril_blood
	name = "tendril blood"
	icon_state = "tendril_blood"
	duration = 0.5 SECONDS

/obj/effect/temp_visual/tendril_blood/Initialize()
	. = ..()
	animate(src, alpha = 65, time = 0.4)

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
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_SLIME_POUNCE_ALTERNATE,
	)

	/// Whether to apply harmful effects or not.
	var/passive_pounce = FALSE
	/// The atom we're currently attached to.
	var/atom/attached_atom

/datum/action/xeno_action/activable/slime_pounce/alternate_action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(passive_pounce)
		passive_pounce = FALSE
		xeno_owner.balloon_alert(xeno_owner, "Harmful Pounce")
		return
	passive_pounce = TRUE
	xeno_owner.balloon_alert(xeno_owner, "Passive Pounce")
	return COMSIG_KB_ACTIVATED

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
	RegisterSignal(owner, COMSIG_MOVABLE_IMPACT, PROC_REF(atom_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_complete))
	xeno_owner.throw_at(A, SLIME_POUNCE_RANGE, SLIME_POUNCE_SPEED, xeno_owner)
	succeed_activate()
	add_cooldown()
	return TRUE

/// Called whenever the Slime hits an atom.
/// Will attempt to "attach" to it (buckle on mobs, place inside the atom otherwise).
/datum/action/xeno_action/activable/slime_pounce/proc/atom_hit(datum/source, atom/hit_atom)
	throw_complete()
	attached_atom = hit_atom
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(call_end_ability)) // If the Slime dies, the ability ends.
	RegisterSignal(owner, list(COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_STATUS_SLEEP, COMSIG_LIVING_STATUS_STAGGER), PROC_REF(call_end_ability)) // If the Slime is affected by a negative effect, the ability ends.
	RegisterSignal(owner, COMSIG_XENOMORPH_FIRE_BURNING, PROC_REF(call_end_ability)) // If the Slime is burning, the ability ends.
	RegisterSignal(attached_atom, COMSIG_ATOM_BULLET_ACT, PROC_REF(call_attached_atom_hit)) // An attached Slime will take damage if the atom it is attached to is attacked.
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		attached_living.buckle_mob(owner, TRUE, TRUE, 90)
		attached_living.add_movespeed_modifier(MOVESPEED_ID_SLIME_ATTACHED, TRUE, 0, NONE, TRUE, SLIME_POUNCE_ATTACHED_SLOWDOWN) // An attached Slime will weigh down its victim.
		RegisterSignal(attached_living, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(call_end_ability)) // If the Slime is unbuckled, it will end the ability.
		RegisterSignal(attached_living, COMSIG_MOB_DEATH, PROC_REF(call_end_ability)) // If the attached victim dies, the ability ends.
		RegisterSignal(attached_living, COMSIG_LIVING_DO_RESIST, PROC_REF(call_living_resist)) // A victim can resist to throw off the Slime.
		if(!passive_pounce && !HAS_TRAIT(attached_living, TRAIT_INTOXICATION_IMMUNE))
			var/mob/living/carbon/xenomorph/xeno_owner = owner
			effect_over_time(SLIME_POUNCE_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks) // Effects applied every few seconds to a Slime's victim.
		return
	owner.forceMove(get_turf(hit_atom))

/// Called whenever the Pounce throw_at is completed, regardless of resolution.
/datum/action/xeno_action/activable/slime_pounce/proc/throw_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))

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
		end_ability()
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
	attached_living.balloon_alert_to_viewers(attached_living, "Resisting against Slime...")
	if(!do_after(attached_living, SLIME_POUNCE_RESIST_CHANNEL, TRUE, attached_living, BUSY_ICON_GENERIC))
		attached_living.balloon_alert(attached_living, "Interrupted")
		return
	end_ability()

/// Calls end_ability via INVOKE_ASYNC.
/datum/action/xeno_action/activable/slime_pounce/proc/call_end_ability()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(end_ability))

/// Unbuckles the Slime from the living target and punishes them for a successful resist.
/datum/action/xeno_action/activable/slime_pounce/proc/end_ability()
	UnregisterSignal(attached_atom, list(COMSIG_ATOM_BULLET_ACT, COMSIG_MOVABLE_UNBUCKLE, COMSIG_MOB_DEATH, COMSIG_LIVING_DO_RESIST))
	UnregisterSignal(owner, list(COMSIG_MOB_DEATH, COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_STATUS_SLEEP, COMSIG_LIVING_STATUS_STAGGER, COMSIG_XENOMORPH_FIRE_BURNING))
	if(!attached_atom)
		return
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		if(attached_living.buckled_mobs)
			attached_living.unbuckle_mob(owner)
			attached_living.remove_movespeed_modifier(MOVESPEED_ID_SLIME_ATTACHED)
	attached_atom = null
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.Stun(SLIME_POUNCE_UNBUCKLE_STUN_DURATION)
	xeno_owner.balloon_alert_to_viewers("Deattached")

// ***************************************
// *********** Spread Tendrils
// ***************************************
/datum/action/xeno_action/spread_tendrils
	name = "Spread Tendrils"
	ability_name = "Spread Tendrils"
	action_icon_state = "spread_tendrils"
	desc = "Spread hardened, thorn-like tendrils, dealing damage to surrounding enemies and immobilizing them briefly. Increased intensity for victims in the same tile as you."
	cooldown_timer = 15 SECONDS
	plasma_cost = 30
	use_state_flags = XACT_USE_BUCKLED
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_SPREAD_TENDRILS,
	)

/datum/action/xeno_action/spread_tendrils/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!do_after(xeno_owner, SLIME_SPREAD_TENDRILS_WINDUP, FALSE, xeno_owner, BUSY_ICON_DANGER))
		return
	succeed_activate()
	add_cooldown()
	for(var/mob/living/affected_living in range(SLIME_SPREAD_TENDRILS_RANGE, get_turf(xeno_owner)))
		if(affected_living.stat == DEAD || affected_living == xeno_owner)
			return
		shake_camera(affected_living, 2, 1)
		affected_living.do_jitter_animation(1 SECONDS)
		new /obj/effect/temp_visual/tendril_blood(get_turf(affected_living))
		var/attack_damage = xeno_owner.xeno_caste.melee_damage
		var/apply_stun = FALSE
		if(affected_living.loc == xeno_owner.loc) // Bonuses applied if an affected target is on the same tile as the Slime.
			attack_damage = attack_damage * SLIME_SPREAD_TENDRILS_CRITICAL_MULTIPLIER
			apply_stun = TRUE
		affected_living.apply_damage(attack_damage, BURN, blocked = ACID)
		if(get_dist(get_turf(xeno_owner), get_turf(affected_living)) > 1)
			step_towards(affected_living, xeno_owner, 1)
		if(apply_stun)
			affected_living.emote("scream")
			affected_living.Stun(SLIME_SPREAD_TENDRILS_EFFECT_DURATION * SLIME_SPREAD_TENDRILS_CRITICAL_MULTIPLIER)
		else
			affected_living.emote("pain")
			affected_living.Immobilize(SLIME_SPREAD_TENDRILS_EFFECT_DURATION)
		var/applied_stacks = SLIME_EXTEND_TENDRIL_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks
		if(!HAS_TRAIT(affected_living, TRAIT_INTOXICATION_IMMUNE))
			if(affected_living.has_status_effect(STATUS_EFFECT_INTOXICATED))
				var/datum/status_effect/stacking/intoxicated/debuff = affected_living.has_status_effect(STATUS_EFFECT_INTOXICATED)
				debuff.add_stacks(applied_stacks)
			else
				affected_living.apply_status_effect(STATUS_EFFECT_INTOXICATED, applied_stacks)

// ***************************************
// *********** Extend Tendril
// ***************************************
/obj/effect/ebeam/slime_tendril
	name = "slimy tendril"
	alpha = 200

/datum/action/xeno_action/activable/extend_tendril
	name = "Extend Tendril"
	ability_name = "Extend Tendril"
	action_icon_state = "tail_attack"
	desc = "Extend a hardened, thorn-like tendril that will deal damage to a target, pulling them closer to you and immobilizing them briefly."
	cooldown_timer = 15 SECONDS
	plasma_cost = 30
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_USE_BUCKLED
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_EXTEND_TENDRIL,
	)

	/// Reference to the tendril VFX beam.
	var/datum/beam/tendril_beam

/datum/action/xeno_action/activable/extend_tendril/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isliving(A))
		if(!silent)
			A.balloon_alert(owner, "Invalid target")
		return
	var/mob/living/living_target = A
	if(living_target.stat == DEAD)
		if(!silent)
			A.balloon_alert(owner, "Target is dead")
		return
	var/turf/current_turf = get_turf(owner)
	var/turf/target_turf = get_turf(living_target)
	if(current_turf == target_turf)
		return TRUE
	if(get_dist(current_turf, target_turf) > SLIME_EXTEND_TENDRIL_RANGE)
		return FALSE
	current_turf = get_step_towards(current_turf, target_turf)
	while((current_turf != target_turf))
		if(current_turf.density)
			return FALSE
		current_turf = get_step_towards(current_turf, target_turf)

/datum/action/xeno_action/activable/extend_tendril/use_ability(atom/A)
	succeed_activate()
	add_cooldown()
	handle_beam(FALSE, A)
	var/mob/living/living_target = A
	shake_camera(living_target, 2, 1)
	living_target.do_jitter_animation(1 SECONDS)
	new /obj/effect/temp_visual/tendril_blood(get_turf(living_target))
	var/target_distance = get_dist(get_turf(owner), get_turf(living_target))
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/attack_damage = xeno_owner.xeno_caste.melee_damage
	var/apply_stun = FALSE
	if(target_distance > 1)
		step_towards(living_target, xeno_owner, SLIME_EXTEND_TENDRIL_PULL_RANGE)
		if(target_distance >= SLIME_EXTEND_TENDRIL_RANGE) // Bonuses applied if the victim was at maximum range
			attack_damage = attack_damage * SLIME_EXTEND_TENDRIL_CRITICAL_MULTIPLIER
			apply_stun = TRUE
	living_target.apply_damage(attack_damage, BURN, blocked = ACID)
	if(apply_stun)
		living_target.emote("scream")
		living_target.Stun(SLIME_EXTEND_TENDRIL_EFFECT_DURATION * SLIME_EXTEND_TENDRIL_CRITICAL_MULTIPLIER)
	else
		living_target.emote("pain")
		living_target.Immobilize(SLIME_EXTEND_TENDRIL_EFFECT_DURATION)
	var/applied_stacks = SLIME_EXTEND_TENDRIL_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks
	if(!HAS_TRAIT(living_target, TRAIT_INTOXICATION_IMMUNE))
		if(living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
			var/datum/status_effect/stacking/intoxicated/debuff = living_target.has_status_effect(STATUS_EFFECT_INTOXICATED)
			debuff.add_stacks(applied_stacks)
		else
			living_target.apply_status_effect(STATUS_EFFECT_INTOXICATED, applied_stacks)

/// Handles the beam used in representation of the Slime's tendril.
/// Has a "mode" var. If set to true, it will delete the beam instead of creating one.
/datum/action/xeno_action/activable/extend_tendril/proc/handle_beam(mode, atom/target_atom)
	if(!mode)
		tendril_beam = owner.beam(target_atom, icon_state = "tentacle", beam_type = /obj/effect/ebeam/slime_tendril)
		addtimer(CALLBACK(src, PROC_REF(handle_beam), TRUE, target_atom), 0.5 SECONDS)
		return
	QDEL_NULL(tendril_beam)
