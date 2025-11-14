// ***************************************
// *********** Fire Charge
// ***************************************
/datum/action/ability/activable/xeno/charge/fire_charge
	name = "Fire Charge"
	action_icon_state = "fireslash"
	action_icon = 'icons/Xeno/actions/pyrogen.dmi'
	desc = "Charge up to 3 tiles, attacking any organic you come across. Extinguishes the target if they were set on fire, but deals extra damage and restores plasma depending on how many fire stacks they have."
	cooldown_duration = 12 SECONDS
	ability_cost = 75
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FIRECHARGE,
	)
	paralyze_duration = 0 // Although we don't do anything related to paralyze, it is nice to have this zeroed out.
	// Should they also slash upon hitting a mob?
	var/should_slash = TRUE
	/// How much damage is dealt for hitting through a mob?
	var/charge_damage = PYROGEN_FIRECHARGE_DAMAGE
	/// How much damage to add for each consumed melting fire stack? Only consumes melting fire stacks if it is above zero.
	var/stack_damage = PYROGEN_FIRECHARGE_DAMAGE_PER_STACK
	/// How much stacks of melting fire to add? These stacks are not consumed.
	var/stacks_to_add = 0
	/// Upon hitting a mob, should they keep going or stop?
	var/pierces_mobs = FALSE

/datum/action/ability/activable/xeno/charge/fire_charge/use_ability(atom/target)
	if(!target)
		return
	RegisterSignal(xeno_owner, COMSIG_XENO_OBJ_THROW_HIT, PROC_REF(obj_hit))
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))
	RegisterSignal(xeno_owner, COMSIG_XENOMORPH_LEAP_BUMP, PROC_REF(mob_hit))
	xeno_owner.emote("roar")
	xeno_owner.xeno_flags |= XENO_LEAPING //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	xeno_owner.throw_at(target, PYROGEN_CHARGEDISTANCE, PYROGEN_CHARGESPEED, xeno_owner)

	add_cooldown()

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

/// Deals with hitting mobs. Triggered by bump instead of throw impact as we want to plow past mobs.
/datum/action/ability/activable/xeno/charge/fire_charge/mob_hit(datum/source, mob/living/living_target)
	. = TRUE
	if(living_target.stat || isxeno(living_target) || living_target.status_flags & GODMODE) // We leap past xenos.
		return
	if(should_slash)
		living_target.attack_alien_harm(xeno_owner, xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/fire_damage = charge_damage
	var/datum/status_effect/stacking/melting_fire/debuff = living_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(!debuff)
		if(stacks_to_add)
			living_target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, stacks_to_add, xeno_owner)
	else
		var/stacks_to_give = stacks_to_add ? stacks_to_add : 0
		if(stack_damage)
			fire_damage += debuff.stacks * stack_damage
			xeno_owner.gain_plasma(debuff.stacks * 20) // Restores plasma for each stack consumed
			stacks_to_give -= debuff.stacks
		debuff.add_stacks(stacks_to_give, xeno_owner)
	if(fire_damage)
		living_target.take_overall_damage(fire_damage, BURN, FIRE, max_limbs = 2)
	if(!pierces_mobs)
		living_target.hitby(owner)

///Cleans up after charge is finished
/datum/action/ability/activable/xeno/charge/fire_charge/charge_complete()
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENOMORPH_LEAP_BUMP))
	xeno_owner.xeno_flags &= ~XENO_LEAPING

// ***************************************
// *********** Fireball
// ***************************************
/datum/action/ability/activable/xeno/fireball
	name = "Fireball"
	action_icon_state = "fireball"
	action_icon = 'icons/Xeno/actions/pyrogen.dmi'
	desc = "Release a fireball that explodes on contact."
	ability_cost = 300
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FIREBALL,
	)

/datum/action/ability/activable/xeno/fireball/use_ability(atom/target)
	playsound(get_turf(xeno_owner), 'sound/effects/wind.ogg', 50)
	if(!do_after(xeno_owner, 0.6 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	playsound(get_turf(xeno_owner), 'sound/effects/alien/fireball.ogg', 50)

	var/atom/movable/projectile/magic_bullshit = new(get_turf(src))
	magic_bullshit.generate_bullet(/datum/ammo/xeno/fireball)
	magic_bullshit.fire_at(target, xeno_owner, xeno_owner, PYROGEN_FIREBALL_MAXDIST, PYROGEN_FIREBALL_SPEED)
	succeed_activate()
	add_cooldown()
	GLOB.round_statistics.pyrogen_fireballs++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "pyrogen_fireballs")

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
// *********** Fire Storm
// ***************************************
/datum/action/ability/activable/xeno/firestorm
	name = "Fire Storm"
	action_icon_state = "whirlwind"
	action_icon = 'icons/Xeno/actions/pyrogen.dmi'
	desc = "Unleash a fiery tornado that goes in a straight line which will set fire around it as it goes and harm marines that directly touch it."
	target_flags = ABILITY_TURF_TARGET
	ability_cost = 300
	cooldown_duration = 12 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FIRENADO,
	)

/datum/action/ability/activable/xeno/firestorm/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/turf/owner_turf = get_turf(owner)
	if(!isopenturf(owner_turf) || isspaceturf(owner_turf))
		return FALSE

/datum/action/ability/activable/xeno/firestorm/use_ability(atom/target)
	if(!do_after(owner, 0.6 SECONDS, IGNORE_HELD_ITEM, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(target, FALSE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	var/turf/owner_turf = get_turf(owner)
	playsound(owner_turf, 'sound/effects/alien/prepare.ogg', 50)
	new /obj/effect/xenomorph/firenado(owner_turf, target, xeno_owner)

	succeed_activate()
	add_cooldown()
	GLOB.round_statistics.pyrogen_firestorms++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "pyrogen_firestorms")

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

// ***************************************
// *********** Inferno
// ***************************************
/datum/action/ability/activable/xeno/inferno
	name = "Inferno"
	action_icon_state = "inferno"
	action_icon = 'icons/Xeno/actions/pyrogen.dmi'
	desc = "After a short cast time, release a burst of fire in a 5x5 radius. All tiles are set on fire. Humans are set on fire and burnt."
	ability_cost = 125
	cooldown_duration = 18 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_INFERNO,
	)

/datum/action/ability/activable/xeno/inferno/use_ability(atom/target)
	if(!do_after(xeno_owner, 0.5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER) || !can_use_ability(target, TRUE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	playsound(get_turf(xeno_owner), 'sound/effects/alien/fireball.ogg', 50)
	new /obj/effect/temp_visual/xeno_fireball_explosion(get_turf(xeno_owner))
	for(var/turf/turf_in_range AS in RANGE_TURFS(2, xeno_owner.loc)) // 5x5
		if(!line_of_sight(xeno_owner, turf_in_range, 2))
			continue

		var/obj/fire/melting_fire/fire_in_turf = locate(/obj/fire/melting_fire) in turf_in_range.contents
		if(fire_in_turf)
			fire_in_turf.burn_ticks = initial(fire_in_turf.burn_ticks)
		else
			fire_in_turf = new(turf_in_range)
		fire_in_turf.creator = xeno_owner

		for(var/mob/living/carbon/human/human_in_turf in turf_in_range.contents)
			if(human_in_turf.stat == DEAD)
				continue
			human_in_turf.take_overall_damage(30, BURN, FIRE, max_limbs = 2)
			var/datum/status_effect/stacking/melting_fire/debuff = human_in_turf.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
			if(debuff)
				debuff.add_stacks(2, xeno_owner)
				continue
			debuff = human_in_turf.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, 2, xeno_owner)

	succeed_activate()
	add_cooldown()
	GLOB.round_statistics.pyrogen_infernos++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "pyrogen_infernos")

// ***************************************
// *********** Infernal Trigger
// ***************************************
/datum/action/ability/activable/xeno/infernal_trigger
	name = "Infernal Trigger"
	action_icon_state = "infernaltrigger"
	action_icon = 'icons/Xeno/actions/pyrogen.dmi'
	desc = "Causes a chosen human's flame to burst outwardly. The severity of the damage is based on how badly they were on fire. In addition, the area near them is set on fire."
	target_flags = ABILITY_MOB_TARGET
	ability_cost = 100
	cooldown_duration = 6 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_INFERNAL_TRIGGER,
	)

/datum/action/ability/activable/xeno/infernal_trigger/can_use_ability(atom/A, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(A))
		if(!silent)
			xeno_owner.balloon_alert(owner, "not a human")
		return FALSE
	var/mob/living/carbon/human/human_target = A
	if(human_target.stat == DEAD)
		if(!silent)
			xeno_owner.balloon_alert(owner, "already dead")
		return FALSE
	if(!human_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE))
		if(!silent)
			xeno_owner.balloon_alert(owner, "not on fire")
		return FALSE
	if(!line_of_sight(xeno_owner, human_target, 9))
		if(!silent)
			xeno_owner.balloon_alert(owner, "can't directly see")
		return FALSE

/datum/action/ability/activable/xeno/infernal_trigger/use_ability(atom/target)
	if(!do_after(xeno_owner, 0.5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER) || !can_use_ability(target, TRUE, ABILITY_IGNORE_PLASMA))
		return fail_activate()

	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/stacking/melting_fire/debuff = human_target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	human_target.take_overall_damage(min(debuff.stacks * 20, 150), BURN, FIRE, max_limbs = 6)
	qdel(debuff)

	playsound(get_turf(human_target), 'sound/effects/alien/fireball.ogg', 50)
	new /obj/effect/temp_visual/xeno_fireball_explosion(get_turf(human_target))

	for(var/turf/turf_in_range AS in RANGE_TURFS(1, target.loc))
		for(var/mob/living/carbon/human/human_in_turf in turf_in_range.contents)
			if(human_in_turf.stat == DEAD)
				continue
			if(human_in_turf == human_target)
				continue
			human_in_turf.take_overall_damage(25, BURN, FIRE, max_limbs = 2)
		var/obj/fire/melting_fire/fire_in_turf = locate(/obj/fire/melting_fire) in turf_in_range.contents
		if(fire_in_turf)
			fire_in_turf.burn_ticks = initial(fire_in_turf.burn_ticks)
		else
			fire_in_turf = new(turf_in_range)
		fire_in_turf.creator = xeno_owner

	succeed_activate()
	add_cooldown()

// Firestorm's Firenado
/obj/effect/xenomorph/firenado
	name = "Plasma Whirlwind"
	desc = "A glowing whirlwind of... cold plasma? Seems to \"burn\" "
	icon = 'icons/effects/64x64.dmi'
	icon_state = "whirlwind"
	anchored = TRUE
	pass_flags = PASS_LOW_STRUCTURE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -16
	/// The starting turf to see how far we are.
	var/turf/turf_starting
	/// The target turf that we will try to go to.
	var/turf/turf_target
	/// The pyrogen who created this effect.
	var/mob/living/carbon/xenomorph/pyrogen/creator

/obj/effect/xenomorph/firenado/Initialize(mapload, atom_target, mob/living/carbon/xenomorph/pyrogen/new_creator)
	. = ..()
	if(!atom_target)
		return INITIALIZE_HINT_QDEL
	turf_starting = get_turf(src)
	turf_target = get_turf(atom_target)
	if(creator)
		creator = new_creator

	START_PROCESSING(SSfastprocess, src)
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

	QDEL_IN(src, 2 SECONDS)
	for(var/mob/living/living_victim in loc)
		mob_act(living_victim)

/obj/effect/xenomorph/firenado/can_z_move(direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	z_move_flags |= ZMOVE_ALLOW_ANCHORED
	return ..()

/obj/effect/xenomorph/firenado/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	impact_flags |= ZIMPACT_NO_SPIN
	return ..()

/obj/effect/xenomorph/firenado/Bump(atom/target)
	. = ..()
	if(isliving(target))
		mob_act(target)
		return
	if(isclosedturf(target))
		if(!iswallturf(target) || istype(target, /turf/closed/wall/resin))
			qdel(src)
			return
		var/turf/closed/wall/wall = target
		wall.take_damage(PYROGEN_TORNADE_HIT_DAMAGE, BURN)
		qdel(src)
		return
	if(!isobj(target))
		return
	if(istype(target, /obj/structure/mineral_door/resin) || istype(target, /obj/structure/xeno))
		return
	var/obj/object = target
	object.take_damage(PYROGEN_TORNADE_HIT_DAMAGE, BURN)
	qdel(src)

/// Delete itself if it reaches maximum distance, reaches the target turf, or fails to take a step toward the target turf.
/obj/effect/xenomorph/firenado/process()
	var/turf/current_location = loc
	if(!istype(current_location))
		qdel(src)
		return
	if(get_dist(turf_starting, loc) > 7)
		qdel(src)
		return
	if(loc == turf_target)
		qdel(src)
		return
	if(!Move(get_step(src, get_dir(loc, turf_target))))
		qdel(src)
		return

/// Creates melting fire in a 3x3 and applies various effects to all humans in the new loc.
/obj/effect/xenomorph/firenado/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!isturf(loc))
		return
	for(var/mob/living/carbon/human/human_here in loc)
		mob_act(human_here)
	refresh_or_create_fire(loc)
	var/list/turf/nearby_turfs = RANGE_TURFS(1, loc) // 3x3
	var/list/turf/all_nonfire_turfs = get_acceptable_turfs(nearby_turfs)
	refresh_or_create_fire(all_nonfire_turfs.len ? pick(all_nonfire_turfs) : pick(nearby_turfs))

/// Applies various effects to humans who enter the same loc as the firenado.
/obj/effect/xenomorph/firenado/proc/on_cross(datum/source, atom/arrived, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!ishuman(arrived))
		return
	mob_act(arrived)

/// Sets living non-xenos with melting fire and deals burning damage to them.
/obj/effect/xenomorph/firenado/proc/mob_act(mob/living/target)
	if(isxeno(target) || target.status_flags & GODMODE || target.stat == DEAD)
		return
	var/datum/status_effect/stacking/melting_fire/debuff = target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(debuff)
		debuff.add_stacks(PYROGEN_TORNADO_MELTING_FIRE_STACKS, creator)
	else
		target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, PYROGEN_TORNADO_MELTING_FIRE_STACKS, creator)
	target.take_overall_damage(PYROGEN_TORNADE_HIT_DAMAGE, BURN, FIRE, max_limbs = 2)

/// Returns a list of open turfs that do not contain melting fire.
/obj/effect/xenomorph/firenado/proc/get_acceptable_turfs(list/turf/possible_turfs)
	var/list/turf/all_nonfire_turfs = list()
	for(var/turf/turf_in_list in possible_turfs)
		if(isclosedturf(turf_in_list))
			continue
		if(locate(/obj/fire/melting_fire) in turf_in_list.contents)
			continue
		all_nonfire_turfs += turf_in_list
	return all_nonfire_turfs

/// Refreshes the burn ticks of the melting fire on a turf or creates one if it does not exist.
/obj/effect/xenomorph/firenado/proc/refresh_or_create_fire(turf/target_turf)
	var/obj/fire/melting_fire/fire_in_turf = locate(/obj/fire/melting_fire) in target_turf.contents
	if(fire_in_turf)
		fire_in_turf.burn_ticks = initial(fire_in_turf.burn_ticks)
		fire_in_turf.creator = creator
		return
	var/obj/fire/melting_fire/new_fire = new(target_turf)
	new_fire.creator = creator
