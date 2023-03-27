/obj/effect/temp_visual/tendril_blood
	name = "tendril blood"
	icon_state = "tendril_blood"
	duration = 0.5 SECONDS
	layer = TANK_BARREL_LAYER

/obj/effect/temp_visual/tendril_blood/Initialize()
	. = ..()
	animate(src, alpha = 65, time = 0.4)

/obj/effect/ebeam/slime_tendril
	name = "slimy tendril"
	alpha = 200
	layer = ABOVE_MOB_LAYER

// ***************************************
// *********** Acidic Trail
// ***************************************
/datum/action/xeno_action/acidic_trail
	name = "Acidic Trail"
	ability_name = "Acidic Trail"
	action_icon_state = "acidic_trail"
	desc = "Left click toggles a trail of acidic puddles when moving. Right click toggles an acid that will imbue your slashes with Intoxication."
	cooldown_timer = 0.5 SECONDS
	plasma_cost = 0
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACIDIC_TRAIL,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_ACIDIC_TRAIL_ALTERNATE,
	)
	/// Whether the trail of acidic puddles when moving is active or not.
	var/acidic_steps = TRUE
	/// Whether the acid that imbues your slashes with Intoxication is active or not.
	var/acidic_slashes = TRUE
	/// References the Pounce action and its vars.
	var/datum/action/xeno_action/activable/attach_pounce/attach_pounce_action

/datum/action/xeno_action/acidic_trail/give_action(mob/living/L)
	. = ..()
	if(acidic_steps)
		RegisterSignal(L, COMSIG_MOVABLE_MOVED, PROC_REF(acid_steps))
	if(acidic_slashes)
		RegisterSignal(L, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(acid_slashes))

/datum/action/xeno_action/acidic_trail/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED, COMSIG_XENOMORPH_ATTACK_LIVING)

/datum/action/xeno_action/acidic_trail/action_activate()
	toggle_ability()

/// Called by action_activate().
/// Toggles the ability on or off. This is also called by Slime Pounce if it was temporarily disabled.
/datum/action/xeno_action/acidic_trail/proc/toggle_ability(called_by_pounce = FALSE)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	attach_pounce_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/attach_pounce]
	if(!called_by_pounce && attach_pounce_action && attach_pounce_action.attached_atom)
		owner.balloon_alert(owner, "Currently attached")
		return
	if(acidic_steps)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		acidic_steps = FALSE
		if(!called_by_pounce)
			owner.balloon_alert(owner, "Acidic Steps OFF")
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(acid_steps))
	acidic_steps = TRUE
	if(!called_by_pounce)
		owner.balloon_alert(owner, "Acidic Steps ON")

/obj/effect/xenomorph/spray/slime
	layer = UNDERFLOOR_OBJ_LAYER

/// Called whenever a Slime moves and Acid Steps is active.
/// Leaves behind a trail of acidic puddles on the Slime's location.
/datum/action/xeno_action/acidic_trail/proc/acid_steps(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = mover
	new /obj/effect/xenomorph/spray/slime(get_turf(xeno_owner), SLIME_MOVEMENT_ACID_DURATION, SLIME_MOVEMENT_ACID_DAMAGE)

/datum/action/xeno_action/acidic_trail/alternate_action_activate()
	if(acidic_slashes)
		UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING)
		owner.balloon_alert(owner, "Acidic Slashes OFF")
		acidic_slashes = FALSE
		return
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(acid_slashes))
	owner.balloon_alert(owner, "Acidic Slashes ON")
	acidic_slashes = TRUE

/// Called whenever a Slime attacks a living target and Acid Slashes is active.
/// Inflicts the Intoxication debuff on the victim.
/datum/action/xeno_action/acidic_trail/proc/acid_slashes(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = source
	if(living_target && living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = living_target.has_status_effect(STATUS_EFFECT_INTOXICATED)
		debuff.add_stacks(SLIME_ATTACK_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks)
		return
	living_target.apply_status_effect(STATUS_EFFECT_INTOXICATED, SLIME_ATTACK_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks)

// ***************************************
// *********** Pounce (Attach)
// ***************************************
/datum/action/xeno_action/activable/attach_pounce
	name = "Pounce"
	ability_name = "Pounce"
	action_icon_state = "pounce"
	desc = "Leap towards your target, attaching to it. Will inflict Intoxication to non-allied victims and slow them down."
	cooldown_timer = 1.5 SECONDS
	plasma_cost = 20
	use_state_flags = XACT_USE_BUCKLED|XACT_USE_CLOSEDTURF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ATTACH_POUNCE,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_ATTACH_POUNCE_ALTERNATE,
	)
	/// Whether to apply harmful effects or not.
	var/passive_pounce = FALSE
	/// The atom we're currently attached to.
	var/atom/attached_atom
	/// Before attaching to a non-living atom, we store the turf we were in for further reference.
	var/atom/previous_turf
	/// References the Acidic Trail action and its vars.
	var/datum/action/xeno_action/acidic_trail/acidic_trail_action

/datum/action/xeno_action/activable/attach_pounce/alternate_action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(passive_pounce)
		passive_pounce = FALSE
		xeno_owner.balloon_alert(xeno_owner, "Harmful Pounce")
		return
	passive_pounce = TRUE
	xeno_owner.balloon_alert(xeno_owner, "Passive Pounce")
	return COMSIG_KB_ACTIVATED

/datum/action/xeno_action/activable/attach_pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A || A.layer >= FLY_LAYER)
		return FALSE

/datum/action/xeno_action/activable/attach_pounce/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.layer == XENO_HIDING_LAYER)
		xeno_owner.layer = MOB_LAYER
	if(attached_atom)
		end_ability()
	xeno_owner.flags_pass = PASSTABLE|PASSFIRE
	RegisterSignal(owner, COMSIG_MOVABLE_IMPACT, PROC_REF(atom_hit))
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_complete))
	xeno_owner.throw_at(A, SLIME_POUNCE_RANGE, SLIME_POUNCE_SPEED, xeno_owner)
	succeed_activate()
	add_cooldown()

/// Called whenever we hit an atom.
/// Will attempt to "attach" to it (buckle on mobs and objects, place inside the atom otherwise).
/datum/action/xeno_action/activable/attach_pounce/proc/atom_hit(datum/source, atom/hit_atom)
	if(istype(hit_atom, /obj/effect) \
		|| istype(hit_atom, /obj/structure/caspart) \
		|| istype(hit_atom, /obj/structure/dropship_piece) \
		|| istype(hit_atom, /obj/structure/dropship_equipment) \
		|| istype(hit_atom, /turf/closed/shuttle) \
		|| isspaceturf(hit_atom) \
		|| islava(hit_atom) \
		|| islavacatwalk(hit_atom))
		owner.balloon_alert(owner, "Cannot attach to this")
		return
	attached_atom = hit_atom
	throw_complete(TRUE)
	owner.layer = ABOVE_MOB_LAYER
	owner.flags_pass = PASSABLE|HOVERING
	owner.balloon_alert_to_viewers("Attached")
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	RegisterSignal(owner, list(
		COMSIG_ATOM_EX_ACT, // Hit by an explosion.
		COMSIG_MOB_DEATH,
		COMSIG_XENOMORPH_FIRE_BURNING,
		COMSIG_LIVING_DO_RESIST,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_XENOMORPH_WATER), // Exposed to a form of water.
		PROC_REF(call_end_ability))
	RegisterSignal(attached_atom, COMSIG_PARENT_QDELETING, PROC_REF(call_end_ability))
	RegisterSignal(attached_atom, COMSIG_ATOM_BULLET_ACT, PROC_REF(call_attached_atom_projectile_hit))
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		attached_living.buckle_mob(owner, TRUE, TRUE, 90)
		attached_living.add_movespeed_modifier(MOVESPEED_ID_SLIME_ATTACHED, TRUE, 0, NONE, TRUE, SLIME_POUNCE_ATTACHED_SLOWDOWN)
		RegisterSignal(attached_living, list(
			COMSIG_MOVABLE_UNBUCKLE,
			COMSIG_MOB_DEATH,
			COMSIG_LIVING_STATUS_UNCONSCIOUS),
			PROC_REF(call_end_ability))
		RegisterSignal(attached_living, COMSIG_LIVING_DO_RESIST, PROC_REF(call_living_resist))
		if(passive_pounce)
			return
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		if(xeno_owner.issamexenohive(attached_living) || HAS_TRAIT(attached_living, TRAIT_INTOXICATION_IMMUNE))
			return
		effect_over_time(SLIME_POUNCE_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks)
		return
	if(isobj(attached_atom))
		var/obj/attached_object = attached_atom
		RegisterSignal(attached_object, COMSIG_OBJ_DECONSTRUCT, PROC_REF(call_end_ability))
		if(isvehicle(attached_object))
			RegisterSignal(attached_object, COMSIG_MOVABLE_MOVED, PROC_REF(call_follow_vehicle))
			return
		if(istype(attached_object, /obj/structure/window) \
			|| istype (attached_object, /obj/machinery/door/poddoor))
			previous_turf = get_turf(owner)
		attached_object.buckle_mob(owner, TRUE, FALSE, 90)
		RegisterSignal(attached_object, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(call_end_ability))
	else // Catch all for anything else.
		RegisterSignal(attached_atom, COMSIG_ATOM_EX_ACT, PROC_REF(call_attached_atom_ex_act))
		previous_turf = get_turf(owner)
		owner.forceMove(get_turf(attached_atom))
		owner.anchored = TRUE

/// Called whenever the Pounce throw_at is completed, regardless of resolution.
/// Unregisters signals, and checks if we're is attached to something.
/// - If it is attached to something, it will also disable acidic steps temporarily.
/// - Otherwise, it only resets pass flags.
/datum/action/xeno_action/activable/attach_pounce/proc/throw_complete(attached = FALSE)
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_IMPACT, COMSIG_MOVABLE_POST_THROW))
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(attached_atom || attached)
		acidic_trail_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/acidic_trail]
		if(acidic_trail_action && acidic_trail_action.acidic_steps)
			acidic_trail_action.toggle_ability(TRUE)
		return
	xeno_owner.reset_flags_pass()

/// Applies effects over a set amount of time.
/// Will call itself again unless there is no longer an attached atom.
/datum/action/xeno_action/activable/attach_pounce/proc/effect_over_time(stacks)
	if(!attached_atom)
		return
	addtimer(CALLBACK(src, PROC_REF(effect_over_time), stacks), SLIME_POUNCE_INFLICTION_RATE)
	var/mob/living/attached_living = attached_atom
	if(attached_living.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = attached_living.has_status_effect(STATUS_EFFECT_INTOXICATED)
		debuff.add_stacks(stacks)
		return
	attached_living.apply_status_effect(STATUS_EFFECT_INTOXICATED, stacks)

/// Calls follow_vehicle via INVOKE_ASYNC.
/datum/action/xeno_action/activable/attach_pounce/proc/call_follow_vehicle(severity)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(follow_vehicle))

/// Called whenever we're attached to a vehicle and that vehicle moves.
/// Moves us to the vehicle's new location.
/datum/action/xeno_action/activable/attach_pounce/proc/follow_vehicle()
	owner.forceMove(get_turf(attached_atom))

/// Calls attached_atom_ex_act via INVOKE_ASYNC.
/datum/action/xeno_action/activable/attach_pounce/proc/call_attached_atom_ex_act(severity)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attached_atom_ex_act), severity)

/// Called whenever the atom we're attached to is hit by an explosion.
/// Unbuckles and reflects the incoming damage to us.
/datum/action/xeno_action/activable/attach_pounce/proc/attached_atom_ex_act(severity)
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
/datum/action/xeno_action/activable/attach_pounce/proc/call_attached_atom_projectile_hit(datum/source, obj/projectile/proj)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attached_atom_projectile_hit), source, proj)

/// Called whenever the atom we're attached to is hit by a projectile.
/// Unbuckles if hit by certain projectiles, and reflects the incoming damage.
/datum/action/xeno_action/activable/attach_pounce/proc/attached_atom_projectile_hit(datum/source, obj/projectile/proj)
	if(proj.ammo.flags_ammo_behavior & AMMO_EXPLOSIVE || proj.ammo.flags_ammo_behavior & AMMO_ROCKET || proj.ammo.flags_ammo_behavior & AMMO_INCENDIARY || proj.ammo.flags_ammo_behavior & AMMO_FLAME)
		end_ability()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.bullet_act(proj)

/// Calls living_resist via INVOKE_ASYNC.
/datum/action/xeno_action/activable/attach_pounce/proc/call_living_resist()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(living_resist))

/// Called whenever the living target we're attached to uses the Resist verb.
/// This proc makes the living target execute a channel. If it succeeds, we're unbuckled.
/datum/action/xeno_action/activable/attach_pounce/proc/living_resist()
	var/mob/living/attached_living = attached_atom
	attached_living.balloon_alert_to_viewers(attached_living, "Resisting against Slime...")
	if(!do_after(attached_living, SLIME_POUNCE_RESIST_CHANNEL, TRUE, attached_living, BUSY_ICON_GENERIC))
		attached_living.balloon_alert(attached_living, "Interrupted")
		return
	end_ability()

/// Calls end_ability via INVOKE_ASYNC.
/datum/action/xeno_action/activable/attach_pounce/proc/call_end_ability()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(end_ability))

/// Unbuckles us from the living target and handles everything that was previously done as part of this ability.
/datum/action/xeno_action/activable/attach_pounce/proc/end_ability()
	if(!attached_atom)
		return
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	UnregisterSignal(owner, list(
		COMSIG_ATOM_EX_ACT,
		COMSIG_MOB_DEATH,
		COMSIG_XENOMORPH_FIRE_BURNING,
		COMSIG_LIVING_DO_RESIST,
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_KNOCKDOWN,
		COMSIG_LIVING_STATUS_PARALYZE,
		COMSIG_LIVING_STATUS_UNCONSCIOUS,
		COMSIG_LIVING_STATUS_SLEEP,
		COMSIG_LIVING_STATUS_STAGGER,
		COMSIG_XENOMORPH_WATER))
	UnregisterSignal(attached_atom, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_ATOM_BULLET_ACT))
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	acidic_trail_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/acidic_trail]
	if(acidic_trail_action && acidic_trail_action.acidic_steps)
		acidic_trail_action.toggle_ability(TRUE)
	if(previous_turf)
		xeno_owner.forceMove(previous_turf)
		previous_turf = null
	if(isliving(attached_atom))
		var/mob/living/attached_living = attached_atom
		UnregisterSignal(attached_living, list(
			COMSIG_MOVABLE_UNBUCKLE,
			COMSIG_MOB_DEATH,
			COMSIG_LIVING_STATUS_UNCONSCIOUS,
			COMSIG_LIVING_DO_RESIST))
		attached_living.unbuckle_mob(xeno_owner, TRUE)
		attached_living.remove_movespeed_modifier(MOVESPEED_ID_SLIME_ATTACHED)
	if(isobj(attached_atom))
		var/obj/attached_object = attached_atom
		UnregisterSignal(attached_object, COMSIG_OBJ_DECONSTRUCT)
		if(isvehicle(attached_atom))
			UnregisterSignal(attached_object, COMSIG_MOVABLE_MOVED)
		else
			UnregisterSignal(attached_object, COMSIG_MOVABLE_UNBUCKLE)
			attached_object.unbuckle_mob(xeno_owner, TRUE)
	else
		UnregisterSignal(attached_atom, COMSIG_ATOM_EX_ACT)
		xeno_owner.anchored = FALSE
	attached_atom = null
	xeno_owner.layer = MOB_LAYER
	xeno_owner.reset_flags_pass()
	xeno_owner.SetKnockdown(SLIME_POUNCE_UNBUCKLE_EFFECT_DURATION)
	xeno_owner.balloon_alert_to_viewers("Deattached")

// ***************************************
// *********** Spread Tendrils
// ***************************************
/datum/action/xeno_action/spread_tendrils
	name = "Spread Tendrils"
	ability_name = "Spread Tendrils"
	action_icon_state = "spread_tendrils"
	desc = "Spread hardened, thorn-like tendrils, dealing damage to surrounding enemies and immobilizing them briefly. Increased intensity for victims in the same tile as you."
	cooldown_timer = 20 SECONDS
	plasma_cost = 25
	use_state_flags = XACT_USE_BUCKLED|XACT_USE_CLOSEDTURF
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SPREAD_TENDRILS,
	)

/datum/action/xeno_action/spread_tendrils/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!do_after(xeno_owner, SLIME_SPREAD_TENDRILS_WINDUP, FALSE, xeno_owner, BUSY_ICON_DANGER))
		return
	succeed_activate()
	add_cooldown()
	for(var/mob/living/carbon/human/affected_human in cheap_get_humans_near(get_turf(xeno_owner), SLIME_SPREAD_TENDRILS_RANGE))
		if(affected_human.stat == DEAD)
			continue
		var/distance = get_dist(affected_human, xeno_owner)
		var/damage = xeno_owner.xeno_caste.melee_damage
		var/effect_duration = SLIME_SPREAD_TENDRILS_EFFECT_DURATION
		if(distance > 1)
			affected_human.throw_at(xeno_owner, SLIME_SPREAD_TENDRILS_PULL_RANGE, 1, xeno_owner, FALSE)
		else
			damage = damage * SLIME_SPREAD_TENDRILS_CRITICAL_MULTIPLIER
			effect_duration = effect_duration * SLIME_SPREAD_TENDRILS_CRITICAL_MULTIPLIER
		new /obj/effect/temp_visual/tendril_blood(get_turf(affected_human))
		affected_human.apply_damage(damage, BURN, blocked = ACID)
		affected_human.Stun(effect_duration)
		affected_human.adjust_stagger(effect_duration)
		affected_human.do_jitter_animation(1 SECONDS)
		affected_human.emote("pain")
		shake_camera(affected_human, 2, 1)
		if(HAS_TRAIT(affected_human, TRAIT_INTOXICATION_IMMUNE))
			continue
		var/applied_stacks = SLIME_EXTEND_TENDRIL_INTOXICATION_STACKS + xeno_owner.xeno_caste.additional_stacks
		if(affected_human.has_status_effect(STATUS_EFFECT_INTOXICATED))
			var/datum/status_effect/stacking/intoxicated/debuff = affected_human.has_status_effect(STATUS_EFFECT_INTOXICATED)
			debuff.add_stacks(applied_stacks)
		else
			affected_human.apply_status_effect(STATUS_EFFECT_INTOXICATED, applied_stacks)

// ***************************************
// *********** Extend Tendril
// ***************************************
/datum/action/xeno_action/activable/extend_tendril
	name = "Extend Tendril"
	ability_name = "Extend Tendril"
	action_icon_state = "tail_attack"
	desc = "Extend a hardened, thorn-like tendril that will deal damage to a target, pulling them closer to you and immobilizing them briefly."
	cooldown_timer = 20 SECONDS
	plasma_cost = 25
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_USE_BUCKLED|XACT_USE_CLOSEDTURF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EXTEND_TENDRIL,
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
/datum/action/xeno_action/activable/toxic_burst
	name = "Toxic Burst"
	ability_name = "Toxic Burst"
	action_icon_state = "toxic_burst"
	desc = "Attack a victim you're attached to, consuming the Intoxication debuff and dealing an amount of damage proportional to the amount of stacks."
	cooldown_timer = 60 SECONDS
	plasma_cost = 50
	use_state_flags = XACT_USE_BUCKLED
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOXIC_BURST,
	)
	/// References the Pounce action and its vars.
	var/datum/action/xeno_action/activable/attach_pounce/attach_pounce_action

/datum/action/xeno_action/activable/toxic_burst/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	attach_pounce_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/attach_pounce]
	if(!attach_pounce_action)
		if(!silent)
			owner.balloon_alert(owner, "No Pounce ability")
		return FALSE
	var/mob/living/living_target = attach_pounce_action?.attached_atom
	if(!living_target || xeno_owner.issamexenohive(living_target))
		if(!silent)
			owner.balloon_alert(owner, "No valid target")
		return FALSE
	if(HAS_TRAIT(living_target, TRAIT_INTOXICATION_IMMUNE))
		if(!silent)
			owner.balloon_alert(owner, "Immune to Intoxication")
		return FALSE
	if(!living_target.has_status_effect(STATUS_EFFECT_INTOXICATED))
		if(!silent)
			owner.balloon_alert(owner, "Not intoxicated")
		return FALSE

/datum/action/xeno_action/activable/toxic_burst/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!do_after(xeno_owner, SLIME_TOXIC_BURST_WINDUP, FALSE, xeno_owner, BUSY_ICON_DANGER))
		return
	succeed_activate()
	add_cooldown()
	var/mob/living/living_target = attach_pounce_action.attached_atom
	var/datum/status_effect/stacking/intoxicated/debuff = living_target.has_status_effect(STATUS_EFFECT_INTOXICATED)
	var/damage = ((SENTINEL_INTOXICATED_BASE_DAMAGE + round(debuff.stacks / 10)) * debuff.stacks) / 2
	var/effect_duration = damage / 30
	living_target.apply_damage(damage, BURN, blocked = ACID)
	living_target.Knockdown(min(0.1, effect_duration))
	living_target.do_jitter_animation(effect_duration)
	living_target.emote("scream")
	living_target.remove_status_effect(STATUS_EFFECT_INTOXICATED)
