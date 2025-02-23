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
	return ..()

/datum/action/ability/activable/xeno/backhand/use_ability(atom/target)
	var/damage = 60 * xeno_owner.xeno_melee_damage_modifier
	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	var/turf/current_turf = get_turf(xeno_owner)
	if(grabbed_human)
		xeno_owner.face_atom(grabbed_human)
		xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
		xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
		xeno_owner.visible_message(span_danger("[xeno_owner] lifts [grabbed_human] into the air and gets ready to slam!"))
		if(do_after(xeno_owner, 3 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(grab_extra_check))))
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
			xeno_owner.gain_plasma(250)
		xeno_owner.move_resist = initial(xeno_owner.move_resist)
		xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		succeed_activate()
		add_cooldown()
		return

	xeno_owner.face_atom(target)
	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/list/turf/affected_turfs = get_turfs_to_target()
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	QDEL_LIST(telegraphed_atoms)

	if(!was_successful)
		succeed_activate()
		add_cooldown()
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
					span_danger("We smack [affected_living]!"), null, 5) // TODO: Better flavor.
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
		xeno_owner.gain_plasma(100)
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
	if(TIMER_COOLDOWN_CHECK(xeno_owner, COOLDOWN_DRAGON_CHANGE_FORM))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already lifting")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/fly/use_ability(atom/target)
	if(xeno_owner.status_flags & INCORPOREAL)
		xeno_owner.change_form()
		return
	xeno_owner.setDir(SOUTH)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)

	if(!was_successful)
		succeed_activate()
		add_cooldown()
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
	return ..()

/datum/action/ability/activable/xeno/tailswipe/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/list/turf/affected_turfs = get_turfs_to_target()
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	xeno_owner.setDir(turn(xeno_owner.dir, 180))
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	QDEL_LIST(telegraphed_atoms)

	if(!was_successful)
		succeed_activate()
		add_cooldown()
		return

	var/damage = 55 * xeno_owner.xeno_melee_damage_modifier
	var/has_hit_anything = FALSE
	var/list/obj/vehicle/vehicles_already_affected_so_far = list() // To stop hitting something the same multitile vehicle twice.
	for(var/turf/affected_tile AS in affected_turfs)
		for(var/atom/affected_atom AS in affected_tile)
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(affected_atom in vehicles_already_affected_so_far)
				continue
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				affected_living.apply_effect(2 SECONDS, EFFECT_PARALYZE)

				animate(affected_living, pixel_z = affected_living.pixel_z + 8, layer = max(MOB_JUMP_LAYER, affected_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = affected_living.pixel_z - 8, layer = affected_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				affected_living.animation_spin(0.5 SECONDS, 1, affected_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				var/datum/component/jump/living_jump_component = affected_living.GetComponent(/datum/component/jump)
				if(living_jump_component)
					TIMER_COOLDOWN_START(affected_living, JUMP_COMPONENT_COOLDOWN, 0.25 SECONDS)

				xeno_owner.do_attack_animation(affected_living)
				xeno_owner.visible_message(span_danger("\The [xeno_owner] tail swipes [affected_living]!"), \
					span_danger("We tail swipes [affected_living]!"), null, 5) // TODO: Better flavor.
				has_hit_anything = TRUE
				continue
			if(!isobj(affected_atom))
				continue
			var/obj/affected_obj = affected_atom
			if(ishitbox(affected_obj))
				var/obj/hitbox/vehicle_hitbox = affected_obj
				if(vehicle_hitbox.root in vehicles_already_affected_so_far)
					continue
				handle_vehicle_effects(vehicle_hitbox.root, damage / 3)
				vehicles_already_affected_so_far += vehicle_hitbox.root
				has_hit_anything = TRUE
				continue
			if(!isvehicle(affected_obj))
				affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
				has_hit_anything = TRUE
				continue
			if(ismecha(affected_obj))
				handle_vehicle_effects(affected_obj, damage * 3, 50)
			else if(isarmoredvehicle(affected_obj))
				handle_vehicle_effects(affected_obj, damage / 3)
			else
				handle_vehicle_effects(affected_obj, damage)
			vehicles_already_affected_so_far += affected_obj
			has_hit_anything = TRUE

	playsound(xeno_owner, has_hit_anything ? 'sound/weapons/alien_claw_block.ogg' : 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	if(has_hit_anything)
		xeno_owner.gain_plasma(75)

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
/datum/action/ability/activable/xeno/tailswipe/proc/handle_vehicle_effects(obj/vehicle/vehicle, damage, ap)
	for(var/mob/living/living_occupant in vehicle.occupants)
		living_occupant.apply_effect(1.5 SECONDS, EFFECT_PARALYZE)
	vehicle.take_damage(damage, BRUTE, MELEE, armour_penetration = ap, blame_mob = xeno_owner)

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
	return ..()

/datum/action/ability/activable/xeno/dragon_breath/use_ability(atom/target)
	if(ability_timer)
		return // The auto fire component handles the shooting.

	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	if(grabbed_human)
		xeno_owner.face_atom(grabbed_human)
		xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
		xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		xeno_owner.visible_message(span_danger("[xeno_owner] inhales and turns their sights to [grabbed_human]..."))
		if(do_after(xeno_owner, 3 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(grab_extra_check))))
			xeno_owner.stop_pulling()
			xeno_owner.visible_message(span_danger("[xeno_owner] exhales a massive fireball right ontop of [grabbed_human]!"))
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
			xeno_owner.gain_plasma(250)
		xeno_owner.move_resist = initial(xeno_owner.move_resist)
		xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		succeed_activate()
		add_cooldown()
		return

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/primal_wrath_roar.ogg', 75, TRUE)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
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
	return ..()

/datum/action/ability/activable/xeno/wind_current/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/list/turf/affected_turfs = get_turfs_to_target()
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	QDEL_LIST(telegraphed_atoms)

	if(!was_successful)
		succeed_activate()
		add_cooldown()
		return

	xeno_owner.visible_message(span_danger("\The [xeno_owner] flaps their wings!"), \
		span_danger("We flap our wings!"), null, 5) // TODO: Better flavor.

	var/damage = 50 * xeno_owner.xeno_melee_damage_modifier
	var/has_hit_anything = FALSE
	for(var/turf/affected_tile AS in affected_turfs)
		affected_tile.Shake(duration = 0.25 SECONDS)
		for(var/atom/affected_atom AS in affected_tile)
			if(istype(affected_atom, /obj/effect/particle_effect/smoke))
				qdel(affected_atom)
				has_hit_anything = TRUE
				continue
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			if(isxeno(affected_atom))
				continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BURN, MELEE, max_limbs = 6, updating_health = TRUE)
				if(affected_living.move_resist < MOVE_FORCE_OVERPOWERING)
					affected_living.knockback(xeno_owner, 4, 1)

				animate(affected_living, pixel_z = affected_living.pixel_z + 8, layer = max(MOB_JUMP_LAYER, affected_living.layer), time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = affected_living.pixel_z - 8, layer = affected_living.layer, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				affected_living.animation_spin(0.5 SECONDS, 1, affected_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				var/datum/component/jump/living_jump_component = affected_living.GetComponent(/datum/component/jump)
				if(living_jump_component)
					TIMER_COOLDOWN_START(affected_living, JUMP_COMPONENT_COOLDOWN, 0.5 SECONDS)
				has_hit_anything = TRUE
				continue
			if(!isobj(affected_atom))
				continue
			var/obj/affected_obj = affected_atom
			if(isvehicle(affected_obj))
				if(ismecha(affected_obj))
					affected_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner)
				else if(isarmoredvehicle(affected_obj) || ishitbox(affected_obj))
					affected_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = xeno_owner) // Adjusted for 3x3 multitile vehicles.
				else
					affected_obj.take_damage(damage * 2, BRUTE, MELEE, blame_mob = xeno_owner)
				has_hit_anything = TRUE
				continue
			affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
			has_hit_anything = TRUE

	playsound(xeno_owner, 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	if(has_hit_anything)
		xeno_owner.gain_plasma(200)
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
	return ..()

/datum/action/ability/activable/xeno/grab/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/list/obj/effect/xeno/dragon_warning/telegraphed_atoms = list()
	var/list/turf/affected_turfs = get_turfs_to_target()
	for(var/turf/affected_turf AS in affected_turfs)
		telegraphed_atoms += new /obj/effect/xeno/dragon_warning(affected_turf)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 1.2 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	QDEL_LIST(telegraphed_atoms)

	if(!was_successful)
		succeed_activate()
		add_cooldown()
		return

	var/list/mob/living/carbon/human/acceptable_humans = list()
	for(var/turf/affected_tile AS in affected_turfs)
		for(var/mob/living/carbon/human/affected_human in affected_tile)
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

	// TODO: Pick the closest human rather than a random one.
	grabbed_human = pick(acceptable_humans)
	RegisterSignal(grabbed_human, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_completion))
	ADD_TRAIT(grabbed_human, TRAIT_IMMOBILE, XENO_TRAIT)
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
	xeno_owner.gain_plasma(250)
	playsound(xeno_owner, 'sound/voice/alien/pounce.ogg', 25, TRUE)

/// Cleans up everything associated with the grabbing and ends the ability.
/datum/action/ability/activable/xeno/grab/proc/end_grabbing()
	SIGNAL_HANDLER
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
	COOLDOWN_DECLARE(miasma_cooldown)
	COOLDOWN_DECLARE(lightning_shrike_cooldown)
	COOLDOWN_DECLARE(ice_storm_cooldown)

/datum/action/ability/activable/xeno/psychic_channel/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/psychic_channel/update_button_icon()
	action_icon_state = is_actively_channeling() ? selected_spell : "psychic_channel"
	return ..()

/// Opens a radical wheel to select a spell.
/datum/action/ability/activable/xeno/psychic_channel/alternate_action_activate()
	INVOKE_ASYNC(src, PROC_REF(select_spell), null, TRUE)

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
				desc = "Create 25 homing ice spikes around you in a circle. Each spike will follow the nearest marine and deals a small amount of damage along with a slowdown if they are hit."
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
	if(!is_actively_channeling())
		xeno_owner.update_glow(3, 3, "#6a59b3")
		if(!do_after(owner, 2 SECONDS, NONE, xeno_owner, BUSY_ICON_DANGER))
			xeno_owner.update_glow()
			return fail_activate()
		xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_PSYCHIC_CHANNEL, TRUE, 0, NONE, TRUE, 0.9)
		select_spell(selected_spell, TRUE, FALSE, selected_spell == "psychic_channel" ? TRUE : FALSE)
		RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taken_damage))
		return

	switch(selected_spell)
		if("miasma")
			// TODO: Shoot a projectile.
			COOLDOWN_START(src, miasma_cooldown, 20 SECONDS)
		if("lightning_strike")
			// TODO: Get all marines within 9x9. If they cannot see (line of sight), exclude them.
			// TODO: If there is more than 15, remove a marine from a list until it's 15 or under.
			// TODO: Telegraph. Beh's stomp telegraph, except it's 1 tiles shorter.
			// TODO: After 1.5s,
			COOLDOWN_START(src, lightning_shrike_cooldown, 25 SECONDS)
		if("ice_storm")
			var/list/bullets = list()
			for(var/i = 1 to 25)
				var/obj/projectile/proj = new(get_turf(xeno_owner))
				proj.generate_bullet(/datum/ammo/xeno/homing_ice_spike)
				bullets += proj
			bullet_burst(xeno_owner, bullets, xeno_owner, "sound/weapons/burst_phaser2.ogg", 10, 0.2, FALSE, -1)
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

/datum/action/ability/activable/xeno/unleash
	name = "Unleash"
	action_icon_state = "unleash"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 240 SECONDS

/obj/effect/xeno/dragon_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "shallnotpass"
