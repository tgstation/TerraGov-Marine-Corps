// ***************************************
// *********** Fire Charge
// ***************************************
/datum/action/ability/activable/xeno/charge/fire_charge
	name = "Fire Charge"
	action_icon_state = "fireslash"
	desc = "Charge up to 3 tiles, inflicting a stack of melting flame and slashing them with a fiery claw. "
	cooldown_duration = 4 SECONDS
	ability_cost = 30
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FIRECHARGE,
	)

/datum/action/ability/activable/xeno/charge/fire_charge/use_ability(atom/target)
	if(!target)
		return
	var/mob/living/carbon/xenomorph/pyrogen/xeno = owner

	RegisterSignal(xeno, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	xeno.emote("roar")
	xeno.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	xeno.throw_at(target, PYROGEN_CHARGEDISTANCE, PYROGEN_CHARGESPEED, xeno)

	add_cooldown()

/datum/action/ability/activable/xeno/charge/fire_charge/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our exoskeleton quivers as we are ready to schorch using [name] again."))
	return ..()

/datum/action/ability/activable/xeno/charge/fire_charge/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/charge/fire_charge/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(owner, target, PYROGEN_CHARGEDISTANCE))
		return FALSE
	if(!can_use_ability(target, override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

///Deals with hitting objects
/datum/action/ability/activable/xeno/charge/fire_charge/obj_hit(datum/source, obj/target, speed)
	target.hitby(owner, speed) //This resets throwing.
	charge_complete()

///Deals with hitting mobs. Triggered by bump instead of throw impact as we want to plow past mobs
/datum/action/ability/activable/xeno/charge/fire_charge/mob_hit(datum/source, mob/living/living_target)
	. = TRUE
	if(living_target.stat || isxeno(living_target) || living_target.status_flags & GODMODE) //we leap past xenos
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	living_target.attack_alien_harm(xeno_owner, xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/fire_damage = PYROGEN_FIRECHARGE_DAMAGE
	if(living_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		var/datum/status_effect/stacking/melting_fire/debuff = living_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
		fire_damage += debuff.stacks * PYROGEN_FIRECHARGE_DAMAGE_PER_STACK
		living_target.remove_status_effect(STATUS_EFFECT_MELTING_FIRE)
	living_target.take_overall_damage(fire_damage, BURN, ACID, max_limbs = 2)
	living_target.hitby(owner)


///Cleans up after charge is finished
/datum/action/ability/activable/xeno/charge/fire_charge/charge_complete()
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENOMORPH_LEAP_BUMP))
	var/mob/living/carbon/xenomorph/pyrogen/xeno_owner = owner
	xeno_owner.xeno_flags &= ~XENO_LEAPING

// ***************************************
// *********** Fireball
// ***************************************
/datum/action/ability/activable/xeno/fireball
	name = "Fireball"
	action_icon_state = "fireball"
	desc = "Release a fireball that explodes on contact."
	ability_cost = 50
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FIREBALL,
	)

/datum/action/ability/activable/xeno/fireball/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/pyrogen/xeno = owner
	playsound(get_turf(xeno), 'sound/effects/wind.ogg', 50)
	if(!do_after(xeno, 1 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	playsound(get_turf(xeno), 'sound/effects/fireball.ogg', 50)

	var/obj/projectile/magic_bullshit = new(get_turf(src))
	magic_bullshit.generate_bullet(/datum/ammo/xeno/fireball)
	magic_bullshit.fire_at(target, xeno, xeno, PYROGEN_FIREBALL_MAXDIST, PYROGEN_FIREBALL_SPEED)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/fireball/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/fireball/ai_should_use(atom/target)
	if(!iscarbon(target))
		return FALSE
	if(!line_of_sight(src, target, 5))
		return FALSE
	if(!can_use_ability(target))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

/obj/effect/temp_visual/xeno_fireball_explosion
	name = "bang"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "empty"
	pixel_x = -16
	duration = 1.5 SECONDS

// Flick() for perfectly smooth animation
/obj/effect/temp_visual/xeno_fireball_explosion/Initialize(mapload)
	. = ..()
	flick("fireball_explosion", src)

// ***************************************
// *********** Firenado
// ***************************************
/datum/action/ability/activable/xeno/firestorm
	name = "Fire Storm"
	action_icon_state = "whirlwind"
	desc = "Unleash 3 fiery tornados. They will try to close on your target tile"
	target_flags = ABILITY_TURF_TARGET
	ability_cost = 50
	cooldown_duration = 14 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FIRENADO,
	)

/obj/effect/xenomorph/firenado
	name = "Plasma Whirlwind"
	desc = "A glowing whirlwind of... cold plasma? Seems to \"burn\" "
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whirlwind"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -16
	/// Target turf to bias going towards
	var/turf/target
	/// Tracks how many times we moved
	var/moves = 0


/obj/effect/xenomorph/firenado/Initialize(mapload, arg_target)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)
	target = arg_target
	QDEL_IN(src, 2 SECONDS)

/obj/effect/xenomorph/firenado/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/// called when attacking a mob
/obj/effect/xenomorph/firenado/proc/mob_act(mob/living/carbon/human/target)
	if(target.status_flags & GODMODE || target.stat == DEAD)
		return
	var/datum/status_effect/stacking/melting_fire/debuff = target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(debuff)
		debuff.add_stacks(PYROGEN_TORNADO_MELTING_FIRE_STACKS)
	else
		target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, PYROGEN_TORNADO_MELTING_FIRE_STACKS)
	target.take_overall_damage(PYROGEN_TORNADE_HIT_DAMAGE, BURN, ACID, max_limbs = 2)

///Effects applied to a mob that crosses a burning turf
/obj/effect/xenomorph/firenado/proc/on_cross(datum/source, mob/living/carbon/human/target, oldloc, oldlocs)
	if(!istype(target))
		return
	mob_act(target)
	qdel(src)

/obj/effect/xenomorph/firenado/Bump(atom/target)
	. = ..()
	if(iswallturf(target))
		if(!istype(target,/turf/closed/wall/resin))
			var/turf/closed/wall/wall = target
			wall.take_damage(PYROGEN_TORNADE_HIT_DAMAGE, BURN)
			qdel(src)
			return
	else if(isobj(target) && !istype(target, /obj/effect/xenomorph/firenado))
		if(!istype(target, /obj/structure/mineral_door/resin) && !istype(target, /obj/structure/xeno))
			var/obj/object = target
			object.take_damage(PYROGEN_TORNADE_HIT_DAMAGE, BURN)
			qdel(src)
	else if(ismob(target))
		mob_act(target)
		qdel(src)

/obj/effect/xenomorph/firenado/process()
	var/turf/current_location = loc
	if(!istype(current_location)) //Is it a valid turf?
		qdel(src)
		return
	for(var/mob/living/carbon/human/humie in current_location)
		if(humie.stat == DEAD || humie.status_flags & GODMODE)
			continue
		mob_act(humie)
	/// random number so it isn't north biased by default if no target
	var/target_dir = 666
	if(target)
		target_dir = get_dir(src,target)
	var/turf/move_turf
	if(moves%2 || !target)
		move_turf = pickweight(
			list(
				get_step(src, NORTH) = target_dir == NORTH ? 3 : 1,
				get_step(src, SOUTH) = target_dir == SOUTH ? 3 : 1,
				get_step(src, EAST) = target_dir == EAST ? 3 : 1,
				get_step(src, WEST) = target_dir == WEST ? 3 : 1,
			)
		)
	else
		move_turf = get_step(src, target_dir)


	// before moving so that if we hit someone , we don't also put down a fire that they will instantly gain another stack from
	if(!locate(/obj/fire/melting_fire) in current_location)
		new /obj/fire/melting_fire(current_location)
	Move(move_turf)
	moves++

/datum/action/ability/activable/xeno/firestorm/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/pyrogen/xeno = owner

	if(!do_after(xeno, 1 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	playsound(get_turf(xeno), 'sound/effects/prepare.ogg', 50)

	var/list/pickable_turfs = RANGE_TURFS(1, xeno)
	for(var/amount in 1 to PYROGEN_FIRESTORM_TORNADE_COUNT)
		var/turf/chosen = pick_n_take(pickable_turfs)
		while(chosen.density || QDELETED(chosen))
			if(length(pickable_turfs) == 0)
				chosen = get_turf(src)
				break
			chosen = pick_n_take(pickable_turfs)

		new /obj/effect/xenomorph/firenado(chosen, target)

	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/firestorm/ai_should_start_consider()
	return TRUE

/datum/action/ability/activable/xeno/firestorm/ai_should_use(target)
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 6) // If we can be seen.
		return FALSE
	if(!can_use_action(override_flags = ABILITY_IGNORE_SELECTED_ABILITY))
		return FALSE
	return TRUE

/datum/action/ability/xeno_action/heatray
	name = "Heat Ray"
	action_icon_state = "heatray"
	desc = "Microwave any target infront of you in a range of 7 tiles"
	target_flags = ABILITY_TURF_TARGET
	ability_cost = 150
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HEATRAY,
	)
	///list of turfs we are hitting while shooting our beam
	var/list/turf/targets
	///ref to beam that is currently active
	var/datum/beam/beam
	///particle holder for the particle visual effects
	var/obj/effect/abstract/particle_holder/particles
	///ref to looping timer for the fire loop
	var/timer_ref
	/// world time of the moment we started firing
	var/started_firing

/datum/action/ability/xeno_action/heatray/can_use_action(silent, override_flags)
	. = ..()
	if(!.)
		return
	if(SSmonitor.gamestate == SHUTTERS_CLOSED && is_ground_level(owner.z))
		if(!silent)
			owner.balloon_alert(owner, "too early")
		return FALSE

/datum/action/ability/xeno_action/heatray/action_activate()
	if(timer_ref)
		stop_beaming()
		return

	ADD_TRAIT(owner, TRAIT_IMMOBILE, HEATRAY_BEAM_ABILITY_TRAIT)

	if(!do_after(owner, PYROGEN_HEATRAY_CHARGEUP, IGNORE_HELD_ITEM, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_action), FALSE, ABILITY_USE_BUSY)))
		QDEL_NULL(beam)
		targets = null
		REMOVE_TRAIT(owner, TRAIT_IMMOBILE, HEATRAY_BEAM_ABILITY_TRAIT)
		add_cooldown(10 SECONDS)
		return fail_activate()

	var/turf/check_turf = get_step(owner, owner.dir)
	LAZYINITLIST(targets)
	while(check_turf && length(targets) < PYROGEN_HEATRAY_RANGE)
		targets += check_turf
		check_turf = get_step(check_turf, owner.dir)
	if(!LAZYLEN(targets))
		return

	beam = owner.loc.beam(targets[length(targets)], "heatray", beam_type = /obj/effect/ebeam)
	playsound(owner, 'sound/effects/firebeam.ogg', 80)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, HEATRAY_BEAM_ABILITY_TRAIT)
	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE), PROC_REF(stop_beaming))
	started_firing = world.time
	execute_attack()

/// recursive proc for firing the actual beam
/datum/action/ability/xeno_action/heatray/proc/execute_attack()
	if(!can_use_action(TRUE))
		stop_beaming()
		return
	succeed_activate()
	for(var/turf/target AS in targets)
		for(var/victim in target)
			if(ishuman(victim))
				var/mob/living/carbon/human/human_victim = victim
				if(human_victim.stat == DEAD || human_victim.status_flags & GODMODE)
					continue
				var/damage = PYROGEN_HEATRAY_HIT_DAMAGE
				var/datum/status_effect/stacking/melting_fire/debuff = human_victim.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
				if(debuff)
					damage += debuff.stacks * PYROGEN_HEATRAY_BONUS_DAMAGE_PER_MELTING_STACK

				human_victim.take_overall_damage(damage, BURN, ACID, updating_health = TRUE, max_limbs = 2)

				human_victim.flash_weak_pain()
				animation_flash_color(human_victim)
			else if(isvehicle(victim))
				var/obj/vehicle/veh_victim = victim
				veh_victim.take_damage(PYROGEN_HEATRAY_HIT_DAMAGE, BURN, ACID)
	if(world.time - started_firing > PYROGEN_HEATRAY_MAXDURATION)
		stop_beaming()
		return
	timer_ref = addtimer(CALLBACK(src, PROC_REF(execute_attack)), PYROGEN_HEATRAY_REFIRE_TIME, TIMER_STOPPABLE)

/// Gets rid of the beam.
/datum/action/ability/xeno_action/heatray/proc/stop_beaming()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(beam)
	deltimer(timer_ref)
	timer_ref = null
	targets = null
	started_firing = 0
	add_cooldown()
