/datum/action/ability/activable/xeno/backhand
	name = "Backhand"
	action_icon_state = "backhand"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, deal high damage and a fair knock back to marines in front of you. Vehicles and mechas take more damage, but are not knocked back. If you are grabbing a marine, deal an incredible amount of damage instead."
	cooldown_duration = 10 SECONDS

/datum/action/ability/activable/xeno/backhand/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/backhand/use_ability(atom/target)
	var/damage = 60 * xeno_owner.xeno_melee_damage_modifier
	var/turf/current_turf = get_turf(xeno_owner)
	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	var/cooldown_plasma_bonus = unleash_ability?.is_active() ? 2 : 1
	if(grabbed_human)
		xeno_owner.face_atom(grabbed_human)
		xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
		xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
		xeno_owner.visible_message(span_danger("[xeno_owner] lifts [grabbed_human] into the air and gets ready to slam!"))
		if(do_after(xeno_owner, 3 SECONDS / cooldown_plasma_bonus, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(grab_extra_check))))
			xeno_owner.stop_pulling()
			xeno_owner.visible_message(span_danger("[xeno_owner] slams [grabbed_human] into the ground!"))
			grabbed_human.emote("scream")
			grabbed_human.Shake(duration = 0.5 SECONDS) // Must stop pulling first for Shake to work.
			playsound(current_turf, 'sound/effects/alien/behemoth/seismic_fracture_explosion.ogg', 50, 1)
			for(var/turf/turf_in_range AS in RANGE_TURFS(2, current_turf))
				turf_in_range.Shake(duration = 0.25 SECONDS)
				for(var/mob/living/living_in_range in turf_in_range.contents)
					if(xeno_owner == living_in_range || grabbed_human == living_in_range)
						continue
					animate(living_in_range, pixel_z = living_in_range.pixel_z + 8, layer = max(MOB_JUMP_LAYER, living_in_range.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
					animate(pixel_z = living_in_range.pixel_z - 8, layer = living_in_range.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
					var/datum/component/jump/living_jump_component = living_in_range.GetComponent(/datum/component/jump)
					if(living_jump_component)
						TIMER_COOLDOWN_START(living_in_range, JUMP_COMPONENT_COOLDOWN, 0.5 SECONDS)
			grabbed_human.take_overall_damage(damage * 2.5, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE) // 150
			xeno_owner.gain_plasma(250 * cooldown_plasma_bonus)
		xeno_owner.move_resist = initial(xeno_owner.move_resist)
		xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		succeed_activate()
		add_cooldown()
		return

	xeno_owner.face_atom(target)
	var/list/turf/affected_turfs = get_turfs_to_target()
	for(var/turf/affected_turf AS in affected_turfs)
		new /obj/effect/temp_visual/dragon/warning(affected_turf, 1.2 SECONDS / cooldown_plasma_bonus)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS / cooldown_plasma_bonus, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return

	var/has_hit_anything = FALSE
	for(var/turf/affected_tile AS in affected_turfs)
		for(var/atom/affected_atom AS in affected_tile)
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				affected_living.knockback(xeno_owner, 2, 1)
				xeno_owner.do_attack_animation(affected_living)
				xeno_owner.visible_message(span_danger("\The [xeno_owner] smacks [affected_living]!"), \
					span_danger("We smack [affected_living]!"), null, 5)
				has_hit_anything = TRUE
				continue
			if(!isobj(affected_atom))
				continue
			var/obj/affected_obj = affected_atom
			if(ishitbox(affected_obj))
				affected_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = xeno_owner) // 20, adjusted for 3x3 multitile vehicles.
				has_hit_anything = TRUE
				continue
			if(!isvehicle(affected_obj))
				affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
				has_hit_anything = TRUE
				continue
			if(ismecha(affected_obj))
				affected_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner) // 180
			else if(isarmoredvehicle(affected_obj))
				affected_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = xeno_owner) // 20, adjusted for 3x3 multitile vehicles.
			else
				affected_obj.take_damage(damage * 2, BRUTE, MELEE, blame_mob = xeno_owner) // 120
			has_hit_anything = TRUE
			continue

	playsound(current_turf, has_hit_anything ? get_sfx(SFX_ALIEN_BITE) : 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	if(has_hit_anything)
		xeno_owner.gain_plasma(100 * cooldown_plasma_bonus)
	succeed_activate()
	add_cooldown()

/// Gets a 3x2 block of turfs that are not closed turf and can be seen by the owner.
/datum/action/ability/activable/xeno/backhand/proc/get_turfs_to_target()
	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y + 2, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 1, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 1, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 1, xeno_owner.z)

	var/list/turf/acceptable_turfs = list()
	var/list/turf/possible_turfs = block(lower_left, upper_right)
	for(var/turf/possible_turf AS in possible_turfs)
		if(isclosedturf(possible_turf))
			continue
		if(!line_of_sight(xeno_owner, possible_turf, 3))
			continue
		acceptable_turfs += possible_turf
	return acceptable_turfs

/// Checks if the ability is still usable and is currently grabbing a human.
/datum/action/ability/activable/xeno/backhand/proc/grab_extra_check()
	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	if(!grabbed_human || !can_use_ability(grabbed_human, FALSE, ABILITY_USE_BUSY))
		return FALSE
	return TRUE

/datum/action/ability/activable/xeno/fly
	name = "Fly"
	action_icon_state = "fly"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a long cast time, fly into the air. If you're already flying, land with a delay. Landing causes nearby marines to take lots of damage with vehicles taking up to 3x as much."
	cooldown_duration = 240 SECONDS

/datum/action/ability/activable/xeno/fly/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(TIMER_COOLDOWN_CHECK(xeno_owner, COOLDOWN_DRAGON_CHANGE_FORM))
			if(!silent)
				xeno_owner.balloon_alert(xeno_owner, "already landing")
			return FALSE
		var/list/mob/living/carbon/xenomorph/nearby_xenos = cheap_get_xenos_near(xeno_owner, 7)
		var/found_los_xenos = FALSE
		for(var/mob/living/carbon/xenomorph/nearby_xeno AS in nearby_xenos)
			if(nearby_xeno == xeno_owner)
				continue
			if(!xeno_owner.issamexenohive(nearby_xeno))
				continue
			if(line_of_sight(xeno_owner, nearby_xeno, 7))
				found_los_xenos = TRUE
				break
		var/weeds_found = locate(/obj/alien/weeds) in xeno_owner.loc
		if(!weeds_found && !found_los_xenos)
			if(!silent)
				if(nearby_xenos.len > 1)
					xeno_owner.balloon_alert(xeno_owner, "no friendlies in sight")
				else
					xeno_owner.balloon_alert(xeno_owner, "no weeds")
			return FALSE
	if(!isxenodragon(xeno_owner))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "no wings")
		return FALSE
	if(TIMER_COOLDOWN_CHECK(xeno_owner, COOLDOWN_DRAGON_CHANGE_FORM))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already lifting")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/fly/use_ability(atom/target)
	if(xeno_owner.status_flags & INCORPOREAL)
		xeno_owner.change_form()
		return
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	xeno_owner.setDir(SOUTH)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, unleash_ability?.is_active() ? 2.5 SECONDS : 5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return
	xeno_owner.change_form()

/datum/action/ability/activable/xeno/tailswipe
	name = "Tailswipe"
	action_icon_state = "tailswipe"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, turn around and deal high damage along with a knockdown to marines behind you. Occupants of vehicles, including those inside mechas, are knocked down."
	cooldown_duration = 12 SECONDS

/datum/action/ability/activable/xeno/tailswipe/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/tailswipe/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	var/castplasma_multiplier = unleash_ability?.is_active() ? 2 : 1
	var/list/turf/impacted_turfs = get_turfs_to_target()
	for(var/turf/impacted_turf AS in impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(impacted_turf, 1.2 SECONDS / castplasma_multiplier)

	xeno_owner.setDir(turn(xeno_owner.dir, 180))
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS / castplasma_multiplier, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)

	if(!was_successful)
		return

	var/damage = 55 * xeno_owner.xeno_melee_damage_modifier
	var/has_hit_anything = FALSE
	var/list/obj/vehicle/already_stunned_vehicles = list() // To stop hitting something the same multitile vehicle twice.
	for(var/turf/impacted_turf AS in impacted_turfs)
		for(var/atom/impacted_atom AS in impacted_turf)
			if(!(impacted_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(isxeno(impacted_atom))
				continue
			if(isliving(impacted_atom))
				var/mob/living/impacted_living = impacted_atom
				if(impacted_living.stat == DEAD)
					continue
				impacted_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				impacted_living.apply_effect(2 SECONDS, EFFECT_PARALYZE)

				animate(impacted_living, pixel_z = impacted_living.pixel_z + 8, layer = max(MOB_JUMP_LAYER, impacted_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = impacted_living.pixel_z - 8, layer = impacted_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				impacted_living.animation_spin(0.5 SECONDS, 1, impacted_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				var/datum/component/jump/living_jump_component = impacted_living.GetComponent(/datum/component/jump)
				if(living_jump_component)
					TIMER_COOLDOWN_START(impacted_living, JUMP_COMPONENT_COOLDOWN, 0.25 SECONDS)

				xeno_owner.do_attack_animation(impacted_living)
				xeno_owner.visible_message(span_danger("\The [xeno_owner] tail swipes [impacted_living]!"), \
					span_danger("We tail swipes [impacted_living]!"), null, 5)
				has_hit_anything = TRUE
				continue
			if(!isobj(impacted_atom))
				continue
			var/obj/impacted_obj = impacted_atom
			if(ishitbox(impacted_atom))
				var/obj/hitbox/impacted_hitbox = impacted_atom
				var/can_stun = !(impacted_hitbox.root in already_stunned_vehicles)
				handle_vehicle_effects(impacted_hitbox.root, damage / 3, should_stun = can_stun)
				if(can_stun)
					already_stunned_vehicles += impacted_hitbox.root
				has_hit_anything = TRUE
				continue
			if(!isvehicle(impacted_obj))
				impacted_obj.take_damage(damage, BRUTE, MELEE, blame_mob = src)
				has_hit_anything = TRUE
				continue
			var/can_stun = !(impacted_obj in already_stunned_vehicles)
			if(ismecha(impacted_obj))
				handle_vehicle_effects(impacted_obj, damage * 3, 50, should_stun = can_stun)
			else if(isarmoredvehicle(impacted_obj))
				handle_vehicle_effects(impacted_obj, damage / 3, should_stun = can_stun)
			else
				handle_vehicle_effects(impacted_obj, damage * 2, should_stun = can_stun)
			already_stunned_vehicles += impacted_obj
			has_hit_anything = TRUE

	playsound(xeno_owner, has_hit_anything ? 'sound/weapons/alien_claw_block.ogg' : 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	if(has_hit_anything)
		xeno_owner.gain_plasma(75 * castplasma_multiplier)

	succeed_activate()
	add_cooldown()

/// Gets a 5x3 block of turfs that are not closed turf and can be seen by the owner.
/datum/action/ability/activable/xeno/tailswipe/proc/get_turfs_to_target()
	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 3, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 3, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 3, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 2, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 3, xeno_owner.y + 2, xeno_owner.z)

	var/list/turf/acceptable_turfs = list()
	var/list/turf/possible_turfs = block(lower_left, upper_right)
	for(var/turf/possible_turf AS in possible_turfs)
		if(isclosedturf(possible_turf))
			continue
		if(!line_of_sight(xeno_owner, possible_turf, 3))
			continue
		acceptable_turfs += possible_turf
	return acceptable_turfs

/// Stuns the vehicle's occupants and does damage to the vehicle itself.
/datum/action/ability/activable/xeno/tailswipe/proc/handle_vehicle_effects(obj/vehicle/vehicle, damage, ap, should_stun)
	vehicle.take_damage(damage, BRUTE, MELEE, armour_penetration = ap, blame_mob = src)
	if(!should_stun)
		return
	for(var/mob/living/living_occupant in vehicle.occupants)
		living_occupant.apply_effect(1.5 SECONDS, EFFECT_PARALYZE)

/datum/action/ability/activable/xeno/dragon_breath
	name = "Dragon Breath"
	action_icon_state = "dragon_breath"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, gain the ability to continuously shoot fire balls with a large spread for a short time. If you are grabbing a marine, deal an incredible amount of damage and knock them back instead."
	cooldown_duration = 30 SECONDS
	/// Current target that the xeno is targeting. This is for aiming.
	var/current_target
	/// The timer id for the timer that ends the ability.
	var/ability_timer
	/// The timer id for the timer that gives plasma every second.
	var/plasma_timer

/datum/action/ability/activable/xeno/dragon_breath/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/dragon_breath/use_ability(atom/target)
	if(ability_timer)
		return // The auto fire component handles the shooting.

	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	var/castplasma_multiplier = unleash_ability?.is_active() ? 2 : 1
	if(grabbed_human)
		xeno_owner.face_atom(grabbed_human)
		xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
		xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		xeno_owner.visible_message(span_danger("[xeno_owner] inhales and turns their sights to [grabbed_human]..."))
		if(do_after(xeno_owner, 3 SECONDS / castplasma_multiplier, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(grab_extra_check))))
			xeno_owner.stop_pulling()
			xeno_owner.visible_message(span_danger("[xeno_owner] exhales a massive fireball right ontop of [grabbed_human]!"))
			new /obj/effect/temp_visual/dragon/grab_fire(get_turf(grabbed_human))
			grabbed_human.emote("scream")
			grabbed_human.Shake(duration = 0.5 SECONDS) // Must stop pulling first for Shake to work.
			playsound(get_turf(xeno_owner), 'sound/effects/alien/fireball.ogg', 50, 1)
			new /obj/effect/temp_visual/xeno_fireball_explosion(get_turf(grabbed_human))
			var/datum/status_effect/stacking/melting_fire/debuff = grabbed_human.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
			if(debuff)
				debuff.add_stacks(10)
			else
				grabbed_human.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, 10)
			grabbed_human.take_overall_damage(200 * xeno_owner.xeno_melee_damage_modifier, BURN, FIRE, max_limbs = length(grabbed_human.get_damageable_limbs()), updating_health = TRUE)
			grabbed_human.knockback(xeno_owner, 5, 1)
			xeno_owner.gain_plasma(250 * castplasma_multiplier)
		xeno_owner.move_resist = initial(xeno_owner.move_resist)
		xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		succeed_activate()
		add_cooldown()
		return

	playsound(xeno_owner, 'sound/effects/alien/behemoth/primal_wrath_roar.ogg', 75, TRUE)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS / castplasma_multiplier, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return

	ability_timer = addtimer(CALLBACK(src, PROC_REF(end_ability)), 10 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
	plasma_timer = addtimer(CALLBACK(src, PROC_REF(regenerate_plasma)), 1 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_BREATH, TRUE, 0, NONE, TRUE, 1)
	xeno_owner.AddComponent(/datum/component/automatedfire/autofire, 0.2 SECONDS, _fire_mode = GUN_FIREMODE_AUTOMATIC, _callback_reset_fire = CALLBACK(src, PROC_REF(reset_fire)), _callback_fire = CALLBACK(src, PROC_REF(fire)))
	RegisterSignal(xeno_owner, COMSIG_LIVING_DO_RESIST, PROC_REF(end_ability)) // An alternative way to end the ability.
	RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))
	RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEUP, PROC_REF(stop_fire))
	RegisterSignal(xeno_owner, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_fire))

/// Ends the ability early.
/datum/action/ability/activable/xeno/dragon_breath/on_deselection()
	if(!ability_timer)
		return
	end_ability()

/// Checks if the ability is still usable and is currently grabbing a human.
/datum/action/ability/activable/xeno/dragon_breath/proc/grab_extra_check()
	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	if(!grabbed_human || !can_use_ability(grabbed_human, FALSE, ABILITY_USE_BUSY))
		return FALSE
	return TRUE

/// Undoes everything associated with starting the ability.
/datum/action/ability/activable/xeno/dragon_breath/proc/end_ability()
	deltimer(ability_timer)
	ability_timer = null
	deltimer(plasma_timer)
	plasma_timer = null
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_BREATH)
	qdel(xeno_owner.GetComponent(/datum/component/automatedfire/autofire))
	UnregisterSignal(xeno_owner, list(COMSIG_LIVING_DO_RESIST, COMSIG_MOB_MOUSEUP, COMSIG_MOB_MOUSEDRAG, COMSIG_MOB_MOUSEDOWN))
	reset_fire()
	succeed_activate()
	add_cooldown()

/// Gives 30 plasma to the ability owner and repeats itself.
/datum/action/ability/activable/xeno/dragon_breath/proc/regenerate_plasma()
	xeno_owner.gain_plasma(30)
	deltimer(plasma_timer)
	plasma_timer = addtimer(CALLBACK(src, PROC_REF(regenerate_plasma)), 1 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Starts the xeno firing.
/datum/action/ability/activable/xeno/dragon_breath/proc/start_fire(datum/source, atom/object, turf/location, control, params, can_use_ability_flags)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(((modifiers["right"] || modifiers["middle"]) && (modifiers["shift"] || modifiers["ctrl"] || modifiers["left"])) || \
	((modifiers["left"] && modifiers["shift"]) && (modifiers["ctrl"] || modifiers["middle"] || modifiers["right"])) || \
	(modifiers["left"] && !modifiers["shift"]))
		return
	if(!can_use_ability(object, TRUE, can_use_ability_flags))
		return fail_activate()
	set_target(get_turf_on_clickcatcher(object, xeno_owner, params))
	if(!current_target)
		return

	SEND_SIGNAL(xeno_owner, COMSIG_XENO_FIRE)
	xeno_owner.client?.mouse_pointer_icon = 'icons/effects/xeno_target.dmi'

/// Fires the projectile.
/datum/action/ability/activable/xeno/dragon_breath/proc/fire()
	var/sound_to_play = pick(1, 2) == 1 ? 'sound/voice/alien/spitacid.ogg' : 'sound/voice/alien/spitacid2.ogg'
	playsound(xeno_owner.loc, sound_to_play, 25, 1)

	var/datum/ammo/xeno/dragon_spit/dragon_spit = GLOB.ammo_list[/datum/ammo/xeno/dragon_spit]
	var/obj/projectile/dragon_proj = new /obj/projectile(get_turf(xeno_owner))
	dragon_proj.generate_bullet(dragon_spit, dragon_spit.damage)
	dragon_proj.def_zone = xeno_owner.get_limbzone_target()
	dragon_proj.fire_at(current_target, xeno_owner, xeno_owner, dragon_spit.max_range, dragon_spit.shell_speed, get_angle_with_scatter(xeno_owner, current_target, dragon_spit.scatter, dragon_proj.p_x, dragon_proj.p_y))

	if(can_use_ability(current_target) && xeno_owner.client)
		succeed_activate()
		return AUTOFIRE_CONTINUE
	fail_activate()
	return NONE

/// Resets the autofire component.
/datum/action/ability/activable/xeno/dragon_breath/proc/reset_fire()
	set_target(null)
	owner?.client?.mouse_pointer_icon = initial(owner.client.mouse_pointer_icon)

/// Changes the current target.
/datum/action/ability/activable/xeno/dragon_breath/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno = owner
	set_target(get_turf_on_clickcatcher(over_object, xeno, params))
	xeno.face_atom(current_target)

/// Sets the current target and registers for qdel to prevent hardels
/datum/action/ability/activable/xeno/dragon_breath/proc/set_target(atom/object)
	if(object == current_target || object == owner)
		return
	if(current_target)
		UnregisterSignal(current_target, COMSIG_QDELETING)
	current_target = object
	if(current_target)
		RegisterSignal(current_target, COMSIG_QDELETING, PROC_REF(clean_target))

/// Cleans the current target in case of Hardel.
/datum/action/ability/activable/xeno/dragon_breath/proc/clean_target()
	SIGNAL_HANDLER
	current_target = get_turf(current_target)

/// Stops the Autofire component and resets the current cursor.
/datum/action/ability/activable/xeno/dragon_breath/proc/stop_fire()
	SIGNAL_HANDLER
	owner?.client?.mouse_pointer_icon = initial(owner.client.mouse_pointer_icon)
	SEND_SIGNAL(owner, COMSIG_XENO_STOP_FIRE)

/datum/action/ability/activable/xeno/wind_current
	name = "Wind Current"
	action_icon_state = "wind_current"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, deal high damage and a knockback to marines in front of you. This also clear any gas in front of you."
	cooldown_duration = 20 SECONDS

/datum/action/ability/activable/xeno/wind_current/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/wind_current/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	var/castplasma_multiplier = unleash_ability?.is_active() ? 2 : 1
	var/list/turf/impacted_turfs = get_turfs_to_target()
	for(var/turf/impacted_turf AS in impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(impacted_turf, 1.2 SECONDS / castplasma_multiplier)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS / castplasma_multiplier, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return

	new /obj/effect/temp_visual/dragon/wind_current(get_turf(xeno_owner))
	xeno_owner.visible_message(span_danger("\The [xeno_owner] flaps their wings!"), \
		span_danger("We flap our wings!"), null, 5)

	var/damage = 50 * xeno_owner.xeno_melee_damage_modifier
	var/has_hit_anything = FALSE
	for(var/turf/impacted_turf AS in impacted_turfs)
		impacted_turf.Shake(duration = 0.25 SECONDS)
		for(var/atom/impacted_atom AS in impacted_turf)
			if(istype(impacted_atom, /obj/effect/particle_effect/smoke))
				qdel(impacted_atom)
				has_hit_anything = TRUE
				continue
			if(!(impacted_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(isxeno(impacted_atom))
				continue
			if(isliving(impacted_atom))
				var/mob/living/impacted_living = impacted_atom
				if(impacted_living.stat == DEAD)
					continue
				impacted_living.take_overall_damage(damage, BURN, MELEE, max_limbs = 6, updating_health = TRUE)
				if(impacted_living.move_resist < MOVE_FORCE_OVERPOWERING)
					impacted_living.knockback(xeno_owner, 4, 1)

				animate(impacted_living, pixel_z = impacted_living.pixel_z + 8, layer = max(MOB_JUMP_LAYER, impacted_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = impacted_living.pixel_z - 8, layer = impacted_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				impacted_living.animation_spin(0.5 SECONDS, 1, impacted_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				var/datum/component/jump/living_jump_component = impacted_living.GetComponent(/datum/component/jump)
				if(living_jump_component)
					TIMER_COOLDOWN_START(impacted_living, JUMP_COMPONENT_COOLDOWN, 0.5 SECONDS)
				has_hit_anything = TRUE
				continue
			if(!isobj(impacted_atom))
				continue
			var/obj/impacted_obj = impacted_atom
			if(isvehicle(impacted_obj))
				if(ismecha(impacted_obj))
					impacted_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner)
				else if(isarmoredvehicle(impacted_obj) || ishitbox(impacted_obj))
					impacted_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = xeno_owner) // Adjusted for 3x3 multitile vehicles.
				else
					impacted_obj.take_damage(damage * 2, BRUTE, MELEE, blame_mob = xeno_owner)
				has_hit_anything = TRUE
				continue
			impacted_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
			has_hit_anything = TRUE

	playsound(xeno_owner, 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	if(has_hit_anything)
		xeno_owner.gain_plasma(200 * castplasma_multiplier)
	succeed_activate()
	add_cooldown()

/// Gets a 5x5 block of turfs that are not closed turf and can be seen by the owner.
/datum/action/ability/activable/xeno/wind_current/proc/get_turfs_to_target()
	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 5, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 5, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 5, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 2, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 5, xeno_owner.y + 2, xeno_owner.z)

	var/list/turf/acceptable_turfs = list()
	var/list/turf/possible_turfs = block(lower_left, upper_right)
	for(var/turf/possible_turf AS in possible_turfs)
		if(isclosedturf(possible_turf))
			continue
		if(!line_of_sight(xeno_owner, possible_turf, 3))
			continue
		acceptable_turfs += possible_turf
	return acceptable_turfs

/datum/action/ability/activable/xeno/grab
	name = "Grab"
	action_icon_state = "grab"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	desc = "After a windup, drag a marine in front of you and initiate a passive grab allowing you to drag them as you move. They are unable to move on their volition, but are fully capable of fighting back. Your grab automatically breaks if you stop grabbing or take too much damage."
	cooldown_duration = 20 SECONDS
	/// The grab item that is grabbing the human.
	var/obj/item/grab/grabbing_item
	/// The human that we are trying to grab or are currently grabbing. Used to differenate from a normal grab vs. ability grab.
	var/mob/living/carbon/human/grabbed_human
	/// Damage taken so far while actively grabbing.
	var/damage_taken_so_far = 0

/datum/action/ability/activable/xeno/grab/can_use_ability(atom/target, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	if(grabbed_human)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already grabbing someone")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/grab/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	var/castplasma_multiplier = unleash_ability?.is_active() ? 2 : 1
	var/list/turf/impacted_turfs = get_turfs_to_target()
	for(var/turf/impacted_turf AS in impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(impacted_turf, 1.2 SECONDS / castplasma_multiplier)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS / castplasma_multiplier, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return

	var/list/mob/living/carbon/human/acceptable_humans = list()
	for(var/turf/impacted_turf AS in impacted_turfs)
		for(var/mob/living/carbon/human/affected_human in impacted_turf)
			if(affected_human.stat == DEAD)
				continue
			if(affected_human.move_resist >= MOVE_FORCE_OVERPOWERING)
				continue
			acceptable_humans += affected_human

	if(!acceptable_humans.len) // Whiff.
		playsound(xeno_owner, 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
		succeed_activate()
		add_cooldown()
		return

	for(var/mob/living/carbon/human/nearest_human in acceptable_humans)
		if(!grabbed_human)
			grabbed_human = nearest_human
			continue
		if(get_dist(xeno_owner, grabbed_human) > nearest_human)
			continue
		grabbed_human = nearest_human

	RegisterSignal(grabbed_human, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_completion))
	ADD_TRAIT(grabbed_human, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	grabbed_human.pass_flags |= (PASS_MOB|PASS_XENO)
	grabbed_human.throw_at(get_step(xeno_owner, xeno_owner.dir), 5, 5, xeno_owner)

/// Gets a 5x2 block of turfs that are not closed turf and can be seen by the owner.
/datum/action/ability/activable/xeno/grab/proc/get_turfs_to_target()
	var/turf/lower_left
	var/turf/upper_right
	switch(xeno_owner.dir)
		if(NORTH)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y + 1, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 2, xeno_owner.z)
		if(SOUTH)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y - 1, xeno_owner.z)
		if(WEST)
			lower_left = locate(xeno_owner.x - 2, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x - 1, xeno_owner.y + 2, xeno_owner.z)
		if(EAST)
			lower_left = locate(xeno_owner.x + 1, xeno_owner.y - 2, xeno_owner.z)
			upper_right = locate(xeno_owner.x + 2, xeno_owner.y + 2, xeno_owner.z)

	var/list/turf/acceptable_turfs = list()
	var/list/turf/possible_turfs = block(lower_left, upper_right)
	for(var/turf/possible_turf AS in possible_turfs)
		if(isclosedturf(possible_turf))
			continue
		if(!line_of_sight(xeno_owner, possible_turf, 3))
			continue
		acceptable_turfs += possible_turf
	return acceptable_turfs

/// Removes signal and pass_flags from the thrown human and tries to grab them (via async).
/datum/action/ability/activable/xeno/grab/proc/throw_completion(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/thrown_human = source
	UnregisterSignal(thrown_human, COMSIG_MOVABLE_POST_THROW)
	thrown_human.pass_flags &= ~(PASS_MOB|PASS_XENO)
	INVOKE_ASYNC(src, PROC_REF(try_grabbing), thrown_human)

/// Try to grab the thrown human.
/datum/action/ability/activable/xeno/grab/proc/try_grabbing(mob/living/carbon/human/thrown_human)
	if(QDELETED(thrown_human) || thrown_human.stat == DEAD || !xeno_owner.Adjacent(thrown_human))
		return
	if(!xeno_owner.start_pulling(thrown_human) || !xeno_owner.get_active_held_item())
		return

	grabbing_item = xeno_owner.get_active_held_item()
	if(!grabbing_item)
		return
	grabbed_human = thrown_human
	damage_taken_so_far = 0

	RegisterSignal(grabbing_item, COMSIG_QDELETING, PROC_REF(end_grabbing))
	RegisterSignal(grabbed_human, COMSIG_MOB_STAT_CHANGED, PROC_REF(human_stat_changed))
	RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taken_damage))
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	xeno_owner.gain_plasma(unleash_ability?.is_active() ? 500 : 250)
	new /obj/effect/temp_visual/dragon/grab(get_turf(grabbed_human))
	playsound(xeno_owner, 'sound/voice/alien/pounce.ogg', 25, TRUE)

/// Cleans up everything associated with the grabbing and ends the ability.
/datum/action/ability/activable/xeno/grab/proc/end_grabbing()
	SIGNAL_HANDLER
	REMOVE_TRAIT(grabbed_human, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	UnregisterSignal(grabbing_item, COMSIG_QDELETING)
	UnregisterSignal(grabbed_human, COMSIG_MOB_STAT_CHANGED)
	UnregisterSignal(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	grabbed_human = null
	grabbing_item = null
	succeed_activate()
	add_cooldown()

/// Stops grabbing if the grabbed human dies.
/datum/action/ability/activable/xeno/grab/proc/human_stat_changed(datum/source, mob/source_mob, new_stat)
	SIGNAL_HANDLER
	if(new_stat != DEAD)
		return
	xeno_owner.stop_pulling()

/// Stops grabbing if owner has taken 300 or more damage since beginning the grab. Damage is calculated after soft armor and plasma reduction.
/datum/action/ability/activable/xeno/grab/proc/taken_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far >= 300)
		xeno_owner.stop_pulling()

/datum/action/ability/activable/xeno/psychic_channel
	name = "Psychic Channel"
	action_icon_state = "psychic_channel"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "Begin channeling your psychic abilities. During your channeling, you can cast various spells which all have independent cooldowns. Right-click to select what spell to use while channeling."
	/// The currently selected spell. Will be automatically chosen after channeling if none was selected.
	var/selected_spell = "psychic_channel"
	/// Damage taken so far while actively channeling.
	var/damage_taken_so_far = 0
	/// The timer id for any timed spell proc.
	var/spell_timer
	COOLDOWN_DECLARE(miasma_cooldown)
	COOLDOWN_DECLARE(lightning_shrike_cooldown)
	COOLDOWN_DECLARE(ice_storm_cooldown)

/datum/action/ability/activable/xeno/psychic_channel/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	if(spell_timer)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy casting")
		return FALSE
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	if(unleash_ability?.currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "busy roaring")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/psychic_channel/update_button_icon()
	action_icon_state = is_actively_channeling() ? selected_spell : "psychic_channel"
	return ..()

/// Opens a radical wheel to select a spell.
/datum/action/ability/activable/xeno/psychic_channel/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_spell), null, FALSE, TRUE)

/// Ends the ability early.
/datum/action/ability/activable/xeno/psychic_channel/on_deselection()
	if(!is_actively_channeling())
		return
	cancel_channel()

/// Selects the chosen spell. Alternatively, lets the owner choose from a radical wheel of spells.
/datum/action/ability/activable/xeno/psychic_channel/proc/select_spell(spell_name = "Psychic Channel", force_update = FALSE, do_selection = FALSE, pick_randomly = FALSE)
	if(do_selection)
		var/spell_images_list = list(
			"Miasma" = image('icons/Xeno/actions/dragon.dmi', icon_state = "miasma"),
			"Lightning Strike" = image('icons/Xeno/actions/dragon.dmi', icon_state = "lightning_strike"),
			"Ice Storm" = image('icons/Xeno/actions/dragon.dmi', icon_state = "ice_storm")
		)
		spell_name = show_radial_menu(xeno_owner, xeno_owner, spell_images_list, radius = 35)
		if(!spell_name)
			return
		select_spell(spell_name)
		return
	if(pick_randomly)
		spell_name = pick(list("Miasma", "Lightning Strike", "Ice Storm"))
	switch(spell_name)
		if("Psychic Channel")
			selected_spell = "psychic_channel"
			if(is_actively_channeling() || force_update)
				name = "Psychic Channel"
				desc = "Begin channeling your psychic abilities. During your channeling, you can cast various spells which all have independent cooldowns. Right-click to select what spell to use while channeling."
		if("Miasma")
			selected_spell = "miasma"
			if(is_actively_channeling() || force_update)
				name = "Miasma"
				desc = "Fires a projectile that plagues an area with black miasma. Marines caught in the blast are burnt and have their healing reduced."
		if("Lightning Strike")
			selected_spell = "lightning_strike"
			if(is_actively_channeling() || force_update)
				name = "Lightning Strike"
				desc = "Up to 15 nearby marines are marked to be struck with lightning. Marines that do not move out of way fast enough are burnt and inflicted with an effect that causes additional damage if they move."
		if("Ice Storm")
			selected_spell = "ice_storm"
			if(is_actively_channeling() || force_update)
				name = "Ice Storm"
				desc = "Create 10 homing ice spikes around you in a circle. Each spike will follow the nearest marine and deals a small amount of damage along with a slowdown if they are hit."
	reset_cooldown()
	update_button_icon()

/// Determines if the owner is currently channeling.
/datum/action/ability/activable/xeno/psychic_channel/proc/is_actively_channeling()
	return xeno_owner.light_on

/// Resets the cooldown depending on what spell is currently selected.
/datum/action/ability/activable/xeno/psychic_channel/proc/reset_cooldown()
	clear_cooldown()
	switch(selected_spell)
		if("psychic_channel")
			cooldown_duration = null
			return
		if("miasma")
			var/remaining_cooldown = COOLDOWN_TIMELEFT(src, miasma_cooldown)
			if(remaining_cooldown)
				add_cooldown(COOLDOWN_TIMELEFT(src, miasma_cooldown))
		if("lightning_strike")
			var/remaining_cooldown = COOLDOWN_TIMELEFT(src, lightning_shrike_cooldown)
			if(remaining_cooldown)
				add_cooldown(COOLDOWN_TIMELEFT(src, lightning_shrike_cooldown))
		if("ice_storm")
			var/remaining_cooldown = COOLDOWN_TIMELEFT(src, ice_storm_cooldown)
			if(remaining_cooldown)
				add_cooldown(COOLDOWN_TIMELEFT(src, ice_storm_cooldown))

/// Either begin channeling or perform the spell.
/datum/action/ability/activable/xeno/psychic_channel/use_ability(atom/A)
	var/datum/action/ability/activable/xeno/unleash/unleash_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/unleash]
	var/castplasma_multiplier = unleash_ability?.is_active() ? 2 : 1

	if(!is_actively_channeling())
		xeno_owner.update_glow(3, 3, "#6a59b3")
		if(!do_after(owner, 2 SECONDS / castplasma_multiplier, NONE, xeno_owner, BUSY_ICON_DANGER))
			xeno_owner.update_glow()
			return fail_activate()
		xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_PSYCHIC_CHANNEL, TRUE, 0, NONE, TRUE, 0.9)
		select_spell(selected_spell, TRUE, FALSE, selected_spell == "psychic_channel" ? TRUE : FALSE)
		RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taken_damage))
		return

	switch(selected_spell)
		if("miasma")
			var/obj/projectile/proj = new(get_turf(xeno_owner))
			proj.generate_bullet(/datum/ammo/xeno/miasma_orb)
			proj.def_zone = xeno_owner.get_limbzone_target()
			proj.fire_at(A, xeno_owner, xeno_owner, range = 10, speed = 1)
			xeno_owner.gain_plasma(100 * castplasma_multiplier)
			COOLDOWN_START(src, miasma_cooldown, 20 SECONDS)
		if("lightning_strike")
			var/list/mob/living/carbon/human/acceptable_humans = get_lightning_shrike_marines()
			var/list/turf/impacted_turfs = get_lightning_shrike_hit_turfs(acceptable_humans)
			for(var/turf/impacted_turf AS in impacted_turfs)
				new /obj/effect/temp_visual/dragon/warning(impacted_turf, 1.5 SECONDS / castplasma_multiplier)
			spell_timer = addtimer(CALLBACK(src, PROC_REF(finalize_lightning_shrike), get_lightning_shrike_center_turfs(acceptable_humans), impacted_turfs), 1.5 SECONDS / castplasma_multiplier, TIMER_STOPPABLE|TIMER_UNIQUE)
			xeno_owner.gain_plasma(100 * castplasma_multiplier)
			COOLDOWN_START(src, lightning_shrike_cooldown, 25 SECONDS)
		if("ice_storm")
			var/list/bullets = list()
			for(var/i = 1 to 10)
				var/obj/projectile/proj = new(get_turf(xeno_owner))
				proj.generate_bullet(/datum/ammo/xeno/homing_ice_spike)
				bullets += proj
			bullet_burst(xeno_owner, bullets, xeno_owner, "sound/weapons/burst_phaser2.ogg", 10, 0.3, FALSE, -1)
			xeno_owner.gain_plasma(150 * castplasma_multiplier)
			COOLDOWN_START(src, ice_storm_cooldown, 30 SECONDS)

	reset_cooldown()
	succeed_activate()

/// Stops the channel if owner has taken 300 or more damage since beginning the channeling. Damage is calculated after soft armor and plasma reduction.
/datum/action/ability/activable/xeno/psychic_channel/proc/taken_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far >= 300)
		INVOKE_ASYNC(src, PROC_REF(cancel_channel))

/// Cancels the channel and stops any spells that is currently being casted.
/datum/action/ability/activable/xeno/psychic_channel/proc/cancel_channel()
	xeno_owner.update_glow()
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_PSYCHIC_CHANNEL)
	select_spell(force_update = TRUE)
	UnregisterSignal(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
	deltimer(spell_timer)
	spell_timer = null

/// Returns up to 15 humans that are in line of sight, nearby, and not dead.
/datum/action/ability/activable/xeno/psychic_channel/proc/get_lightning_shrike_marines()
	var/list/mob/living/carbon/human/acceptable_humans = list()
	for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(xeno_owner, 9))
		if(acceptable_humans.len >= 15)
			break
		if(nearby_human.stat == DEAD)
			continue
		if(!line_of_sight(xeno_owner, nearby_human, 9))
			continue
		acceptable_humans += nearby_human
	return acceptable_humans

/// Returns all the turfs in which a lightning shrike will be centered at given a list of humans.
/datum/action/ability/activable/xeno/psychic_channel/proc/get_lightning_shrike_center_turfs(list/mob/living/carbon/human/targetted_humans)
	var/list/turf/center_turfs = list()
	for(var/mob/living/carbon/human/nearby_human AS in targetted_humans)
		center_turfs += get_turf(nearby_human)
	return center_turfs

/// Returns all the turfs in which a lightning shrike will affect.
/datum/action/ability/activable/xeno/psychic_channel/proc/get_lightning_shrike_hit_turfs(list/mob/living/carbon/human/targetted_humans)
	var/list/turf/hit_turfs = list()
	var/list/turf/center_turfs = get_lightning_shrike_center_turfs(targetted_humans)
	for(var/turf/center_turf AS in center_turfs)
		var/list/turf/filled_turfs = filled_turfs(center_turf, 1, include_edge = FALSE, pass_flags_checked = PASS_GLASS|PASS_PROJECTILE)
		for(var/turf/filled_turf AS in filled_turfs)
			if(locate(/obj/effect/temp_visual/dragon/warning) in filled_turf.contents)
				continue
			hit_turfs += filled_turf
	return hit_turfs

/// Performs the lightning shrike on various turfs.
/datum/action/ability/activable/xeno/psychic_channel/proc/finalize_lightning_shrike(list/turf/center_turfs, list/turf/impacted_turfs)
	spell_timer = null
	for(var/turf/center_turf AS in center_turfs)
		new /obj/effect/temp_visual/dragon/lightning_shrike(center_turf)
		playsound(get_turf(center_turf), 'sound/magic/lightningshock.ogg', 50, TRUE)
	for(var/turf/impacted_turf AS in impacted_turfs)
		impacted_turf.Shake(duration = 0.2 SECONDS)
		for(var/atom/impacted_atom AS in impacted_turf)
			if(!(impacted_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(isxeno(impacted_atom))
				continue
			if(isliving(impacted_atom))
				var/mob/living/impacted_living = impacted_atom
				if(impacted_living.stat == DEAD)
					continue
				impacted_living.take_overall_damage(75 * xeno_owner.xeno_melee_damage_modifier, BURN, FIRE, max_limbs = 6, updating_health = TRUE)
				impacted_living.apply_status_effect(STATUS_EFFECT_ELECTRIFIED)
				continue
			if(!isobj(impacted_atom))
				continue
			var/obj/impacted_obj = impacted_atom
			if(ishitbox(impacted_obj) || isAPC(impacted_obj))
				impacted_obj.take_damage(15, BURN, FIRE, blame_mob = xeno_owner)
				continue
			impacted_obj.take_damage(75, BURN, FIRE, blame_mob = xeno_owner)

/datum/action/ability/activable/xeno/unleash
	name = "Unleash"
	action_icon_state = "unleash"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 240 SECONDS
	/// If we are currently in the process of roaring.
	var/currently_roaring = FALSE
	/// The timer id for the proc regarding the beginning or ending of withdrawal.
	var/timer_id = FALSE

/datum/action/ability/activable/xeno/unleash/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	if(is_active())
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already active")
		return FALSE
	if(timer_id)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "undergoing withdrawal")
		return FALSE
	if(currently_roaring)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "currently roaring")
		return FALSE
	return ..()

/// Begins the roar which comes with immobility, but godmode until it ends.
/datum/action/ability/activable/xeno/unleash/use_ability(atom/target)
	currently_roaring = TRUE
	xeno_owner.status_flags |= GODMODE
	xeno_owner.set_canmove(FALSE)
	playsound(get_turf(xeno_owner), 'sound/effects/alien/behemoth/primal_wrath_roar.ogg', 75, TRUE)
	handle_roar_effects()
	addtimer(CALLBACK(src, PROC_REF(end_roar)), PRIMAL_WRATH_ACTIVATION_DURATION)

/// Ends the roar and applies the buffs.
/datum/action/ability/activable/xeno/unleash/proc/end_roar()
	currently_roaring = FALSE
	xeno_owner.status_flags &= ~GODMODE
	xeno_owner.set_canmove(TRUE)
	apply_buffs()

/// Displays roar effects to nearby humans.
/datum/action/ability/activable/xeno/unleash/proc/handle_roar_effects()
	if(!currently_roaring)
		return
	new /obj/effect/temp_visual/shockwave/unleash(get_turf(xeno_owner), 4, owner.dir)
	for(var/mob/living/affected_living in cheap_get_humans_near(xeno_owner, PRIMAL_WRATH_RANGE) + xeno_owner)
		if(!affected_living.hud_used)
			continue
		var/atom/movable/screen/plane_master/floor/floor_plane = affected_living.hud_used.plane_masters["[FLOOR_PLANE]"]
		var/atom/movable/screen/plane_master/game_world/world_plane = affected_living.hud_used.plane_masters["[GAME_PLANE]"]
		if(floor_plane.get_filter("dragon_unleash") || world_plane.get_filter("dragon_unleash"))
			continue
		var/filter_size = 0.01
		world_plane.add_filter("dragon_unleash", 2, radial_blur_filter(filter_size))
		animate(world_plane.get_filter("dragon_unleash"), size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		floor_plane.add_filter("dragon_unleash", 2, radial_blur_filter(filter_size))
		animate(floor_plane.get_filter("dragon_unleash"), size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		end_roar_effects_for(affected_living)
	addtimer(CALLBACK(src, PROC_REF(handle_roar_effects)), 0.1 SECONDS)

/// Ends roar effects if roaring has ended or if said human gets out of rage.
/datum/action/ability/activable/xeno/unleash/proc/end_roar_effects_for(mob/living/affected_living)
	if(!affected_living || !xeno_owner)
		return
	var/atom/movable/screen/plane_master/floor/floor_plane = affected_living.hud_used.plane_masters["[FLOOR_PLANE]"]
	var/atom/movable/screen/plane_master/game_world/world_plane = affected_living.hud_used.plane_masters["[GAME_PLANE]"]
	if(!floor_plane.get_filter("dragon_unleash") || !world_plane.get_filter("dragon_unleash"))
		return
	if(!currently_roaring || get_dist(affected_living, xeno_owner) > PRIMAL_WRATH_RANGE)
		var/resolve_time = 0.2 SECONDS
		animate(floor_plane.get_filter("dragon_unleash"), size = 0, time = resolve_time, flags = ANIMATION_PARALLEL)
		animate(world_plane.get_filter("dragon_unleash"), size = 0, time = resolve_time, flags = ANIMATION_PARALLEL)
		addtimer(CALLBACK(floor_plane, TYPE_PROC_REF(/datum, remove_filter), "dragon_unleash"), resolve_time)
		addtimer(CALLBACK(world_plane, TYPE_PROC_REF(/datum, remove_filter), "dragon_unleash"), resolve_time)
		return
	addtimer(CALLBACK(src, PROC_REF(end_roar_effects_for), affected_living), 0.1 SECONDS)

/// Grants 33% additional slash/ability damage and a boost in movement speed that will wear off in 30 seconds.
/datum/action/ability/activable/xeno/unleash/proc/apply_buffs()
	xeno_owner.xeno_melee_damage_modifier += 1/3 //This is 33% increase of all slash and ability damage.
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_UNLEASH, TRUE, 0, NONE, TRUE, -0.5)
	timer_id = addtimer(CALLBACK(src, PROC_REF(start_withdrawal)), 30 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
	succeed_activate()

/// Reverses the buffs caused by the ability and gives a temporary slowdown.
/datum/action/ability/activable/xeno/unleash/proc/start_withdrawal()
	if(!is_active())
		return
	xeno_owner.visible_message(span_danger("\The [xeno_owner] looks tired."), span_danger("We feel tired."), null, 5)
	xeno_owner.xeno_melee_damage_modifier -= 1/3
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_UNLEASH)
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_UNLEASH_WITHDRAWAL, TRUE, 0, NONE, TRUE, 0.8)
	timer_id = addtimer(CALLBACK(src, PROC_REF(end_withdrawal)), 5 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Removes the temporary slowdown and sets the ability on cooldown.
/datum/action/ability/activable/xeno/unleash/proc/end_withdrawal()
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_UNLEASH_WITHDRAWAL)
	deltimer(timer_id)
	timer_id = null
	add_cooldown()

/// Returns true if the ability's buff is currently active.
/datum/action/ability/activable/xeno/unleash/proc/is_active()
	return timer_id ? xeno_owner.has_movespeed_modifier(MOVESPEED_ID_DRAGON_UNLEASH) : FALSE

/obj/effect/temp_visual/dragon
	name = "Dragon"

/obj/effect/temp_visual/dragon/lightning_shrike
	icon = 'icons/effects/96x144.dmi'
	icon_state = "lightning_strike"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 1 SECONDS

/obj/effect/temp_visual/dragon/fly
	icon = 'icons/effects/96x144.dmi'
	icon_state = "fly"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.8 SECONDS

/obj/effect/temp_visual/dragon/land
	icon = 'icons/effects/96x144.dmi'
	icon_state = "fly_landing"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.56 SECONDS

/obj/effect/temp_visual/dragon/plague
	icon = 'icons/Xeno/64x64.dmi'
	icon_state = "plague"
	pixel_x = -16
	layer = BELOW_MOB_LAYER
	duration = 0.56 SECONDS

/obj/effect/temp_visual/dragon/plague_mini
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "plague_mini"
	layer = BELOW_MOB_LAYER
	duration = 0.56 SECONDS

/obj/effect/temp_visual/dragon/grab
	icon = 'icons/Xeno/64x64.dmi'
	icon_state = "grab"
	pixel_x = -16
	pixel_y = -16
	layer = BELOW_MOB_LAYER
	duration = 0.72 SECONDS

/obj/effect/temp_visual/dragon/grab_fire
	icon = 'icons/Xeno/64x64.dmi'
	icon_state = "grab_fire"
	pixel_x = -16
	pixel_y = -16
	layer = BELOW_MOB_LAYER
	duration = 1.19 SECONDS

/obj/effect/temp_visual/dragon/wind_current
	icon = 'icons/effects/96x144.dmi'
	icon_state = "wind_current"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.7 SECONDS

/obj/effect/temp_visual/dragon/warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "generic_warning"
	layer = BELOW_MOB_LAYER
	color = COLOR_RED
	duration = 1.5 SECONDS

/obj/effect/temp_visual/dragon/warning/Initialize(mapload, _duration)
	if(isnum(_duration))
		duration = _duration
	return ..()

/obj/effect/temp_visual/shockwave/unleash/Initialize(mapload, radius, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_y += 48
		if(SOUTH)
			pixel_y += 32
		if(WEST)
			pixel_x -= 56
			pixel_y += 48
		if(EAST)
			pixel_x += 56
			pixel_y += 48
