// ***************************************
// *********** Emit Gas
// ***************************************
/datum/action/ability/emit_gas
	name = "Emit Gas"
	action_icon_state = "emit_neurogas"
	action_icon = 'icons/Xeno/actions/defiler.dmi'
	desc = "Use to emit a cloud of blinding smoke."
	cooldown_duration = 30 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EMIT_NEUROGAS,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke grenade will encompass
	var/smokeradius = 4
	///The duration of the smoke in 2 second ticks
	var/smoke_duration = 3

/datum/action/ability/emit_gas/on_cooldown_finish()
	playsound(owner.loc, 'sound/effects/alien/new_larva.ogg', 50, 0)
	to_chat(owner, span_xenodanger("We feel our smoke filling us once more. We can emit gas again."))
	toggle_particles(TRUE)
	return ..()

/datum/action/ability/emit_gas/action_activate()
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	var/turf/owner_turf = get_turf(owner)
	playsound(owner_turf, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(smokeradius, owner_turf, smoke_duration)
	smoke.start()
	toggle_particles(FALSE)

	add_cooldown()
	succeed_activate()

	owner.record_war_crime()

/datum/action/ability/emit_gas/ai_should_start_consider()
	return TRUE

/datum/action/ability/emit_gas/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(carbon_target.faction == owner.faction)
		return FALSE
	if(get_dist(carbon_target, owner) > 2)
		return FALSE
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(!line_of_sight(owner, carbon_target))
		return FALSE
	return TRUE

/// Toggles particles on or off
/datum/action/ability/emit_gas/proc/toggle_particles(activate)
	if(!activate)
		QDEL_NULL(particle_holder)
		return

	particle_holder = new(owner, /particles/smoker_zombie)
	particle_holder.pixel_y = 6

/datum/action/ability/emit_gas/give_action(mob/living/L)
	. = ..()
	toggle_particles(TRUE)

/datum/action/ability/emit_gas/remove_action(mob/living/L)
	. = ..()
	QDEL_NULL(particle_holder)

/datum/action/ability/emit_gas/Destroy()
	. = ..()
	QDEL_NULL(particle_holder)


/datum/action/ability/activable/pounce
	name = "Pounce"
	desc = "Leap at your target, tackling and disarming them."
	action_icon_state = "pounce"
	action_icon = 'icons/Xeno/actions/runner.dmi'
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_POUNCE,
	)
	use_state_flags = ABILITY_USE_BUCKLED
	/// The range of this ability.
	var/pounce_range = 4
	/// The stun duration (inflicted to mob) on successful tackle.
	var/stun_duration = 2 SECONDS
	/// The immobilize duration (inflicted to self) on successful tackle.
	var/self_immobilize_duration = 1 SECONDS

/datum/action/ability/activable/pounce/on_cooldown_finish()
	owner.balloon_alert(owner, "pounce ready")
	owner.playsound_local(owner, 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	return ..()

/datum/action/ability/activable/pounce/can_use_ability(atom/A, silent = FALSE, override_flags)
	if(!A)
		return FALSE
	return ..()

/datum/action/ability/activable/pounce/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/pounce/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(carbon_target.faction == owner.faction)
		return FALSE
	if(!line_of_sight(owner, target, pounce_range))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	return TRUE

/datum/action/ability/activable/pounce/use_ability(atom/A)
	if(owner.buckled)
		owner.buckled.unbuckle_mob(owner)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(movement_fx))
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(pounce_complete))
	RegisterSignal(owner, COMSIG_MOVABLE_PREBUMP_MOVABLE, PROC_REF(mob_hit))
	owner.throw_at(A, pounce_range, 2, owner)
	succeed_activate()
	add_cooldown()

	if(!owner.throwing) //if we instantly run into something, the throw is already over
		pounce_complete()
		return
	owner.remove_pass_flags(PASS_MOB, THROW_TRAIT) //we explicitly want to hit people

///Visual mid pounce
/datum/action/ability/activable/pounce/proc/movement_fx()
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/after_image(get_turf(owner), owner)

///Impact checks mid pounce
/datum/action/ability/activable/pounce/proc/mob_hit(datum/source, mob/living/living_target)
	SIGNAL_HANDLER
	if(!istype(living_target))
		return

	. = TRUE

	if(living_target.faction == owner.faction) //we leap past friendlies
		return

	if(ishuman(living_target) && (angle_to_dir(Get_Angle(owner.throw_source, living_target)) in reverse_nearby_direction(living_target.dir)))
		var/mob/living/carbon/human/human_target = living_target
		if(!human_target.check_shields(COMBAT_TOUCH_ATTACK, 30, "melee"))
			var/mob/living/living_owner = owner
			living_owner.Paralyze(stun_duration)
			living_owner.set_throwing(FALSE)
			return
	trigger_pounce_effect(living_target)
	pounce_complete()

///Triggers the effect of a successful pounce on the target
/datum/action/ability/activable/pounce/proc/trigger_pounce_effect(mob/living/living_target)
	var/mob/living/living_owner = owner
	playsound(get_turf(living_target), 'sound/voice/alien/pounce.ogg', 25, TRUE)
	living_owner.Immobilize(self_immobilize_duration)
	living_owner.forceMove(get_turf(living_target))
	living_target.Knockdown(stun_duration)
	GLOB.round_statistics.runner_pounce_victims++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "runner_pounce_victims")

///Cleans up after pounce is complete
/datum/action/ability/activable/pounce/proc/pounce_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_PREBUMP_MOVABLE, COMSIG_MOVABLE_POST_THROW))

// ***************************************
// *********** Boomer Explode
// ***************************************
/datum/action/ability/boomer_explode
	name = "Boomer Explode"
	action_icon_state = "baneling_explode"
	action_icon = 'icons/Xeno/actions/baneling.dmi'
	desc = "Explode and spread dangerous toxins to hinder or kill your foes. You die."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BANELING_EXPLODE,
	)

/datum/action/ability/boomer_explode/give_action(mob/living/L)
	. = ..()
	RegisterSignal(L, COMSIG_MOB_PRE_DEATH, PROC_REF(handle_smoke))

/datum/action/ability/boomer_explode/remove_action(mob/living/L)
	. = ..()
	UnregisterSignal(L, COMSIG_MOB_PRE_DEATH)

/datum/action/ability/boomer_explode/action_activate()
	. = ..()
	owner.record_tactical_unalive()
	handle_smoke()

/// This proc defines, and sets up and then lastly starts the smoke, if ability is false we divide range by 4.
/datum/action/ability/boomer_explode/proc/handle_smoke(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_MOB_PRE_DEATH)
	var/turf/own_turf = get_turf(owner)
	var/datum/effect_system/smoke_spread/smoke = new /datum/effect_system/smoke_spread/xeno/neuro(own_turf)
	smoke.set_up(3, own_turf, 4)
	playsound(own_turf, 'sound/effects/blobattack.ogg', 25)
	smoke.start()

	owner.record_war_crime()
	INVOKE_NEXT_TICK(owner, TYPE_PROC_REF(/mob/living, death), TRUE)

/datum/action/ability/boomer_explode/ai_should_start_consider()
	return TRUE

/datum/action/ability/boomer_explode/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/living_owner = owner
	if(living_owner.health > (living_owner.maxHealth * 0.3))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(carbon_target.faction == owner.faction)
		return FALSE
	if(get_dist(target, owner) > 1)
		return FALSE
	if(!line_of_sight(owner, target))
		return FALSE
	return TRUE

// ***************************************
// *********** Bile spit
// ***************************************
/datum/action/ability/activable/bile_spit
	name = "Bile spit"
	action_icon_state = "spray_acid"
	action_icon = 'icons/Xeno/actions/boiler.dmi'
	desc = "Hurl a glob of bile at your foes."
	cooldown_duration = 12 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_BLAST,
	)
	///Ammo type to fire
	var/spit_type = /datum/ammo/bile_spit

/datum/action/ability/activable/bile_spit/on_cooldown_finish()
	owner.balloon_alert(owner, "Bile ready")
	playsound(owner, 'sound/effects/refill.ogg', 50, 1)
	return ..()

/datum/action/ability/activable/bile_spit/use_ability(atom/A)
	owner.do_jitter_animation(1000)
	if(!do_after(owner, 1 SECONDS, IGNORE_TARGET_LOC_CHANGE, A, BUSY_ICON_DANGER) || !can_use_ability(A, FALSE, ABILITY_IGNORE_SELECTED_ABILITY) || !(A in range(get_screen_size(TRUE), owner)))
		fail_activate()
		return

	succeed_activate()
	add_cooldown()

	var/atom/movable/projectile/projectile = new /atom/movable/projectile(owner.loc)
	projectile.generate_bullet(spit_type)
	projectile.fire_at(A, owner, owner, projectile.ammo.max_range, projectile.ammo.shell_speed)
	playsound(owner, 'sound/effects/blobattack.ogg', 40, 1)

/datum/action/ability/activable/bile_spit/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/bile_spit/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(carbon_target.faction == owner.faction)
		return FALSE
	if(!line_of_sight(owner, target, 8))
		return FALSE
	if(check_path(owner, target, PASS_PROJECTILE|PASS_MOB) != get_turf(target))
		return
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	return TRUE
