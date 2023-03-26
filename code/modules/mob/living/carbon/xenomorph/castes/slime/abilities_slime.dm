/*
TO DO:
- Fix the normal slash override, it's not working at all.
- More visual effects and sound effects everywhere.
*/

/obj/effect/temp_visual/tendril_blood
	name = "tendril blood"
	icon_state = "tendril_blood"
	duration = 0.5 SECONDS
	layer = ABOVE_MOB_LAYER

/obj/effect/temp_visual/tendril_blood/Initialize()
	. = ..()
	animate(src, alpha = 65, time = 0.4)

/obj/effect/ebeam/slime_tendril
	name = "slimy tendril"
	alpha = 200

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
	use_state_flags = XACT_USE_BUCKLED|XACT_USE_CLOSEDTURF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_POUNCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_SLIME_POUNCE_ALTERNATE,
	)
	/// Whether to apply harmful effects or not.
	var/passive_pounce = FALSE
	/// The atom we're currently attached to.
	var/atom/attached_atom
	/// Before attaching to a non-living atom, we store the turf we were in for further reference.
	var/atom/previous_turf

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
	if(attached_atom)
		end_ability()
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
	RegisterSignal(owner, list(
		COMSIG_ATOM_EX_ACT, // Hit by an explosion.
		COMSIG_MOB_DEATH, // Slime died.
		COMSIG_XENOMORPH_FIRE_BURNING, // Slime is burning.
		COMSIG_LIVING_DO_RESIST, // Slime used the Resist action.
		COMSIG_LIVING_STATUS_STUN, // Slime was stunned.
		COMSIG_LIVING_STATUS_KNOCKDOWN, // Slime was knocked down.
		COMSIG_LIVING_STATUS_PARALYZE, // Slime was paralyzed.
		COMSIG_LIVING_STATUS_UNCONSCIOUS, // Slime was unconscious.
		COMSIG_LIVING_STATUS_SLEEP, // Slime was asleep.
		COMSIG_LIVING_STATUS_STAGGER), // Slime was staggered.
		PROC_REF(call_end_ability))
	RegisterSignal(attached_atom, COMSIG_PARENT_QDELETING, PROC_REF(call_end_ability)) // Attached atom was qdeleted.
	RegisterSignal(attached_atom, COMSIG_ATOM_EX_ACT, PROC_REF(call_attached_atom_ex_act)) // Attached atom was hit by an explosion.
	RegisterSignal(attached_atom, COMSIG_ATOM_BULLET_ACT, PROC_REF(call_attached_atom_projectile_hit)) // Attached atom was hit by a projectile.
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		attached_living.buckle_mob(owner, TRUE, TRUE, 90)
		attached_living.add_movespeed_modifier(MOVESPEED_ID_SLIME_ATTACHED, TRUE, 0, NONE, TRUE, SLIME_POUNCE_ATTACHED_SLOWDOWN) // An attached Slime will weigh down its victim.
		RegisterSignal(attached_living, list(
			COMSIG_MOVABLE_UNBUCKLE, // Slime was unbuckled.
			COMSIG_MOB_DEATH, // Attached victim died.
			COMSIG_LIVING_STATUS_UNCONSCIOUS), // Attached victim was unconscious.
			PROC_REF(call_end_ability))
		RegisterSignal(attached_living, COMSIG_LIVING_DO_RESIST, PROC_REF(call_living_resist)) // Attached victim used the Resist action.
		if(passive_pounce)
			return
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		if(xeno_owner.issamexenohive(attached_living) || HAS_TRAIT(attached_living, TRAIT_INTOXICATION_IMMUNE))
			return
		effect_over_time(SLIME_POUNCE_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks) // Effects applied every few seconds to a Slime's victim.
		return
	previous_turf = get_turf(owner)
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	owner.forceMove(hit_atom)
	owner.anchored = TRUE

/// Called whenever the Pounce throw_at is completed, regardless of resolution.
/datum/action/xeno_action/activable/slime_pounce/proc/throw_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))

/// Applies effects over a set amount of time.
/// Will call itself again based on SLIME_POUNCE_INFLICTION_RATE unless there is no longer an attached atom.
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

/// Calls attached_atom_ex_act via INVOKE_ASYNC.
/datum/action/xeno_action/activable/slime_pounce/proc/call_attached_atom_ex_act(severity, epicenter_dist, impact_range)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attached_atom_ex_act), severity, epicenter_dist, impact_range)

/// Called whenever the Slime or the atom it's attached to is hit by an explosion.
/// Unbuckles the Slime and reflects the incoming damage.
/datum/action/xeno_action/activable/slime_pounce/proc/attached_atom_ex_act(severity, epicenter_dist, impact_range)
	end_ability()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	switch(severity)
		if(EXPLODE_DEVASTATE)
			xeno_owner.apply_damage(INFINITY, BRUTE, blocked = BOMB)
		if(EXPLODE_HEAVY)
			xeno_owner.apply_damage(rand(100, 250), BRUTE, blocked = BOMB)
		if(EXPLODE_LIGHT)
			xeno_owner.apply_damage(rand(10, 90), BRUTE, blocked = BOMB)

/// Calls attached_atom_projectile_hit via INVOKE_ASYNC.
/datum/action/xeno_action/activable/slime_pounce/proc/call_attached_atom_projectile_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attached_atom_projectile_hit), source, proj)

/// Called whenever the atom the Slime is attached to is hit by a projectile.
/// Unbuckles if the projectile is fire, and reflects the incoming damage.
/datum/action/xeno_action/activable/slime_pounce/proc/attached_atom_projectile_hit(datum/source, obj/projectile/proj)
	if(proj.ammo.flags_ammo_behavior & AMMO_EXPLOSIVE || proj.ammo.flags_ammo_behavior & AMMO_ROCKET || proj.ammo.flags_ammo_behavior & AMMO_INCENDIARY || proj.ammo.flags_ammo_behavior & AMMO_FLAME) // If hit by an explosive, automatically unbuckle.
		end_ability()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/blocked_type = determine_armor_type(proj) // The corresponding armor type for the projectile.
	xeno_owner.apply_damage(proj.damage, proj.ammo.damage_type, blocked = blocked_type, penetration = proj.ammo.penetration)
	animation_flash_color(xeno_owner)
	if(proj.ammo.sound_hit)
		playsound(xeno_owner, proj.ammo.sound_hit, 50, 1)

/// Determines what armor type to respond to the incoming damage with, when attached to another atom.
/datum/action/xeno_action/activable/slime_pounce/proc/determine_armor_type(obj/projectile/proj)
	switch(proj.ammo.flags_ammo_behavior)
		if(AMMO_EXPLOSIVE || AMMO_ROCKET)
			return BOMB
		if(AMMO_ENERGY)
			return LASER
		if(AMMO_INCENDIARY || AMMO_FLAME)
			return FIRE
		if(AMMO_BALLISTIC)
			return BULLET
		if(AMMO_XENO)
			return ACID
		else
			return BULLET

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
	if(!attached_atom)
		return
	UnregisterSignal(owner, list(COMSIG_ATOM_EX_ACT, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_FIRE_BURNING, COMSIG_LIVING_DO_RESIST, COMSIG_LIVING_STATUS_STUN, COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE, COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_STATUS_SLEEP, COMSIG_LIVING_STATUS_STAGGER))
	UnregisterSignal(attached_atom, list(COMSIG_PARENT_QDELETING, COMSIG_ATOM_EX_ACT, COMSIG_ATOM_BULLET_ACT))
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		UnregisterSignal(attached_living, list(COMSIG_MOVABLE_UNBUCKLE, COMSIG_MOB_DEATH, COMSIG_LIVING_STATUS_UNCONSCIOUS, COMSIG_LIVING_DO_RESIST))
		if(attached_living.buckled_mobs)
			attached_living.unbuckle_mob(owner, TRUE)
			attached_living.remove_movespeed_modifier(MOVESPEED_ID_SLIME_ATTACHED)
	if(previous_turf)
		REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
		owner.anchored = FALSE
		owner.forceMove(previous_turf)
		previous_turf = null
	attached_atom = null
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.Knockdown(SLIME_POUNCE_UNBUCKLE_EFFECT_DURATION)
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
	plasma_cost = 25
	use_state_flags = XACT_USE_BUCKLED|XACT_USE_CLOSEDTURF
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
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		var/distance = get_dist(affected_living, xeno_owner)
		var/damage = xeno_owner.xeno_caste.melee_damage
		var/effect_duration = SLIME_SPREAD_TENDRILS_EFFECT_DURATION
		if(distance == 0)
			damage = damage * SLIME_SPREAD_TENDRILS_CRITICAL_MULTIPLIER
			effect_duration = effect_duration * SLIME_SPREAD_TENDRILS_CRITICAL_MULTIPLIER
		if(distance > 1)
			affected_living.throw_at(xeno_owner, SLIME_SPREAD_TENDRILS_PULL_RANGE, 1, xeno_owner, FALSE)
		new /obj/effect/temp_visual/tendril_blood(get_turf(affected_living))
		affected_living.apply_damage(damage, BURN, blocked = ACID)
		affected_living.Stun(effect_duration)
		affected_living.adjust_stagger(effect_duration)
		affected_living.do_jitter_animation(1 SECONDS)
		affected_living.emote("pain")
		shake_camera(affected_living, 2, 1)
		if(HAS_TRAIT(affected_living, TRAIT_INTOXICATION_IMMUNE))
			continue
		var/applied_stacks = SLIME_EXTEND_TENDRIL_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks
		if(affected_living.has_status_effect(STATUS_EFFECT_INTOXICATED))
			var/datum/status_effect/stacking/intoxicated/debuff = affected_living.has_status_effect(STATUS_EFFECT_INTOXICATED)
			debuff.add_stacks(applied_stacks)
		else
			affected_living.apply_status_effect(STATUS_EFFECT_INTOXICATED, applied_stacks)

// ***************************************
// *********** Extend Tendril
// ***************************************
/datum/action/xeno_action/activable/extend_tendril
	name = "Extend Tendril"
	ability_name = "Extend Tendril"
	action_icon_state = "tail_attack"
	desc = "Extend a hardened, thorn-like tendril that will deal damage to a target, pulling them closer to you and immobilizing them briefly."
	cooldown_timer = 15 SECONDS
	plasma_cost = 25
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_USE_BUCKLED|XACT_USE_CLOSEDTURF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_EXTEND_TENDRIL,
	)
	/// Reference to the tendril VFX beam.
	var/datum/beam/tendril_beam

/datum/action/xeno_action/activable/extend_tendril/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(A))
		if(!silent)
			A.balloon_alert(owner, "Invalid target")
		return FALSE
	var/mob/living/living_target = A
	if(living_target.stat == DEAD)
		if(!silent)
			A.balloon_alert(owner, "Target is dead")
		return FALSE
	if(get_dist(owner, A) > SLIME_EXTEND_TENDRIL_RANGE)
		if(!silent)
			A.balloon_alert(owner, "Out of range")
		return FALSE

/datum/action/xeno_action/activable/extend_tendril/use_ability(atom/A)
	succeed_activate()
	add_cooldown()
	handle_beam(FALSE, A)
	var/mob/living/living_target = A
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.issamexenohive(living_target))
		living_target.throw_at(xeno_owner, get_dist(living_target, xeno_owner) - 1, 1, xeno_owner, FALSE)
		living_target.Knockdown(SLIME_EXTEND_TENDRIL_EFFECT_DURATION / 2)
		return
	var/distance = get_dist(living_target, xeno_owner)
	var/damage = xeno_owner.xeno_caste.melee_damage
	var/effect_duration = SLIME_SPREAD_TENDRILS_EFFECT_DURATION
	if(distance > 1)
		living_target.throw_at(xeno_owner, SLIME_EXTEND_TENDRIL_PULL_RANGE, 1, xeno_owner, FALSE)
		if(distance >= SLIME_EXTEND_TENDRIL_RANGE)
			damage = damage * SLIME_EXTEND_TENDRIL_CRITICAL_MULTIPLIER
			effect_duration = effect_duration * SLIME_EXTEND_TENDRIL_CRITICAL_MULTIPLIER
	new /obj/effect/temp_visual/tendril_blood(get_turf(living_target))
	living_target.apply_damage(damage, BURN, blocked = ACID)
	living_target.do_jitter_animation(1 SECONDS)
	living_target.Stun(effect_duration)
	living_target.adjust_stagger(effect_duration)
	living_target.emote("scream")
	shake_camera(living_target, 2, 1)
	if(HAS_TRAIT(living_target, TRAIT_INTOXICATION_IMMUNE))
		return
	var/applied_stacks = SLIME_EXTEND_TENDRIL_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks
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

// ***************************************
// *********** Toxic Burst
// ***************************************
/datum/action/xeno_action/toxic_burst
	name = "Toxic Burst"
	ability_name = "Toxic Burst"
	action_icon_state = "4"
	desc = "Attack a victim you're attached to, consuming all Intoxication stacks and dealing an amount of damage proportional to the amount of stacks."
	cooldown_timer = 60 SECONDS
	plasma_cost = 50
	use_state_flags = XACT_USE_BUCKLED
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SLIME_TOXIC_BURST,
	)
	/// References the Pounce action and its vars.
	var/datum/action/xeno_action/activable/slime_pounce/slime_pounce_action

/datum/action/xeno_action/toxic_burst/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	slime_pounce_action = xeno_owner.actions_by_path[/datum/action/xeno_action/activable/slime_pounce]

/datum/action/xeno_action/toxic_burst/can_use_action(silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!slime_pounce_action)
		return FALSE
	var/mob/living/living_target = slime_pounce_action.attached_atom
	if(!living_target || !isliving(living_target))
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.issamexenohive(living_target))
		return FALSE
	if(HAS_TRAIT(living_target, TRAIT_INTOXICATION_IMMUNE))
		return FALSE
	if(!living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		return FALSE

/datum/action/xeno_action/toxic_burst/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!do_after(xeno_owner, SLIME_TOXIC_BURST_WINDUP, FALSE, xeno_owner, BUSY_ICON_DANGER))
		return
	succeed_activate()
	add_cooldown()
	var/mob/living/living_target = slime_pounce_action.attached_atom
	var/datum/status_effect/stacking/intoxicated/debuff = living_target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	var/damage = ((SENTINEL_INTOXICATED_BASE_DAMAGE + round(debuff.stacks / 10)) * debuff.stacks) / 2
	var/effect_duration = damage / 10
	living_target.apply_damage(damage, BURN, blocked = ACID)
	living_target.Knockdown(effect_duration * 2)
	living_target.adjust_slowdown(effect_duration)
	living_target.adjust_stagger(effect_duration)
	living_target.do_jitter_animation(effect_duration)
	living_target.emote("scream")
	living_target.remove_status_effect(STATUS_EFFECT_INTOXICATED)
