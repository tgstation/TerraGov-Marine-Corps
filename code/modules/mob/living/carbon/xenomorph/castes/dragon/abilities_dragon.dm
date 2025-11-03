#define DRAGON_GRABBED_ABILITY_TIME 1.5 SECONDS

/datum/action/ability/activable/xeno/backhand
	name = "Backhand"
	action_icon_state = "backhand"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "Deal high damage, a knockback, and stun to marines in front of you. Vehicles and mechas take more damage, but are not knocked back nor stunned. If you are grabbing a marine, deal an incredible amount of damage to that marine after a windup."
	cooldown_duration = 18 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BACKHAND,
	)
	/// The sound that is played before the do_after, if any.
	var/do_after_sound
	/// The length of the do_after.
	var/do_after_length = 0.5 SECONDS
	/// The width inputted into `get_forward_square` used to telegraph and to get targets.
	var/width = 2
	/// The height inputted into `get_forward_square` used to telegraph and to get targets.
	var/height = 3
	/// Should they turn around during the initial do_after? Only for regular ability.
	var/turn_around = FALSE
	/// The amount of deciseconds to stun occupants of vehicles, if they should be stunned at all.
	var/vehicle_stun_length = 0 SECONDS

/datum/action/ability/activable/xeno/backhand/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying!")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/backhand/use_ability(atom/target)
	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	if(grabbed_human && handle_grabbed_human(grabbed_human))
		return

	xeno_owner.face_atom(target)
	var/list/turf/affected_turfs = get_forward_square(xeno_owner, width, height)
	if(do_after_length)
		for(var/turf/affected_turf AS in affected_turfs)
			new /obj/effect/temp_visual/dragon/warning(affected_turf, do_after_length)
	if(turn_around)
		xeno_owner.setDir(turn(xeno_owner.dir, 180))
	if(do_after_sound)
		playsound(xeno_owner, do_after_sound, 50, 1)

	var/was_successful = TRUE
	if(do_after_length)
		xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
		xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		was_successful = do_after(xeno_owner, do_after_length, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
		xeno_owner.move_resist = initial(xeno_owner.move_resist)
		xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(was_successful && handle_regular_ability(target, affected_turfs))
		return
	succeed_activate()
	add_cooldown()

/// Gets the base damage in which the ability does.
/datum/action/ability/activable/xeno/backhand/proc/get_damage()
	return 45 * xeno_owner.xeno_melee_damage_modifier

/// Performs the regular interaction as expected of the ability.
/datum/action/ability/activable/xeno/backhand/proc/handle_regular_ability(atom/target, list/turf/affected_turfs)
	xeno_owner.face_atom(target)
	new /obj/effect/temp_visual/dragon/directional/backhand(get_step(xeno_owner, target), xeno_owner.dir)
	var/has_hit_anything = FALSE
	var/list/mob/living/living_to_knockback = list()
	var/list/obj/vehicle/hit_vehicles = list()
	for(var/turf/affected_turf AS in affected_turfs)
		for(var/atom/affected_atom AS in affected_turf)
			if(isxeno(affected_atom))
				var/mob/living/carbon/xenomorph/affected_xenomorph = affected_atom
				if(xeno_owner.issamexenohive(affected_xenomorph))
					continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(get_damage(), BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				living_to_knockback += affected_living
				affected_living.apply_effect(2 SECONDS, EFFECT_PARALYZE)
				xeno_owner.do_attack_animation(affected_living)
				has_hit_anything = TRUE
				continue
			if(!isobj(affected_atom))
				continue
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			var/obj/affected_obj = affected_atom
			if(ishitbox(affected_obj) || isvehicle(affected_obj))
				has_hit_anything = handle_affected_vehicle(affected_obj, hit_vehicles)
				continue
			affected_obj.take_damage(get_damage(), BRUTE, MELEE, blame_mob = xeno_owner)
			has_hit_anything = TRUE
			continue

	// This is separate because it is possible for them to be pushed into an unprocessed turf which will then do the effects again, causing instant death (or more damage than desired).
	for(var/mob/living/knockbacked_living AS in living_to_knockback)
		knockbacked_living.knockback(xeno_owner, 2, 1)

	playsound(xeno_owner, has_hit_anything ? 'sound/effects/alien/dragon/backhand_hit.ogg' : 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	xeno_owner.gain_plasma(xeno_owner.xeno_caste.plasma_max / 2)

/// Performs a different interaction based on if there is a grabbed human.
/datum/action/ability/activable/xeno/backhand/proc/handle_grabbed_human(mob/living/carbon/human/grabbed_human)
	xeno_owner.face_atom(grabbed_human)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	xeno_owner.visible_message(span_danger("[xeno_owner] lifts [grabbed_human] into the air and gets ready to slam!"))
	if(do_after(xeno_owner, DRAGON_GRABBED_ABILITY_TIME, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(grab_extra_check))))
		xeno_owner.face_atom(grabbed_human)
		new /obj/effect/temp_visual/dragon/directional/backhand_slam(get_step(xeno_owner, grabbed_human), xeno_owner.dir)
		xeno_owner.stop_pulling()
		xeno_owner.visible_message(span_danger("[xeno_owner] slams [grabbed_human] into the ground!"))
		grabbed_human.emote("scream")
		grabbed_human.Shake(duration = 0.5 SECONDS) // Must stop pulling first for Shake to work.
		playsound(xeno_owner, 'sound/effects/alien/behemoth/seismic_fracture_explosion.ogg', 50, 1)
		for(var/turf/turf_in_range AS in filled_turfs(xeno_owner, 2, "square", FALSE, pass_flags_checked = PASS_AIR))
			turf_in_range.Shake(duration = 0.25 SECONDS)
			for(var/mob/living/living_in_range in turf_in_range.contents)
				if(xeno_owner == living_in_range || grabbed_human == living_in_range)
					continue
				animate(living_in_range, pixel_z = living_in_range.pixel_z + 8, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = living_in_range.pixel_z - 8, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
		grabbed_human.take_overall_damage(get_damage() * 1.7, BRUTE, MELEE, max_limbs = 3, updating_health = TRUE) // 76.5
		xeno_owner.gain_plasma(250)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	succeed_activate()
	add_cooldown()
	return TRUE

/// Does damage to the vehicle and stuns it if the ability wants it so.
/datum/action/ability/activable/xeno/backhand/proc/handle_affected_vehicle(obj/affected_obj, list/obj/vehicle/hit_vehicles)
	if(ishitbox(affected_obj))
		var/obj/hitbox/affected_hitbox = affected_obj
		return handle_affected_vehicle(affected_hitbox.root)
	if(!isvehicle(affected_obj))
		return FALSE
	var/obj/vehicle/affected_vehicle = affected_obj
	if(ismecha(affected_vehicle))
		affected_vehicle.take_damage(get_damage() * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner)
	else if(isarmoredvehicle(affected_vehicle)) // Obtained from hitbox.
		affected_vehicle.take_damage(get_damage() / 3, BRUTE, MELEE, blame_mob = xeno_owner)
	else
		affected_vehicle.take_damage(get_damage() * 2, BRUTE, MELEE, blame_mob = xeno_owner)
	if(!(affected_vehicle in hit_vehicles) && vehicle_stun_length > 0)
		for(var/mob/living/carbon/human/human_occupant in affected_vehicle.occupants)
			human_occupant.apply_effect(vehicle_stun_length, EFFECT_PARALYZE)

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
	cooldown_duration = 120 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_FLY,
	)
	/// Is the landing animation currently happening? Used for setting special state for Dragon.
	var/performing_landing_animation = FALSE
	COOLDOWN_DECLARE(animation_cooldown)

/datum/action/ability/activable/xeno/fly/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(COOLDOWN_TIMELEFT(src, animation_cooldown))
			if(!silent)
				xeno_owner.balloon_alert(xeno_owner, "already landing!")
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
					xeno_owner.balloon_alert(xeno_owner, "no friendlies in sight!")
				else
					xeno_owner.balloon_alert(xeno_owner, "no weeds!")
			return FALSE
	if(COOLDOWN_TIMELEFT(src, animation_cooldown))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already lifting!")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/fly/use_ability(atom/target)
	if(xeno_owner.status_flags & INCORPOREAL)
		start_landing()
		return
	xeno_owner.setDir(SOUTH)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	playsound(get_turf(xeno_owner), 'sound/effects/alien/dragon/flying_progress.ogg', 75, TRUE, 9)
	var/was_successful = do_after(xeno_owner, 5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_ability), target, FALSE, ABILITY_USE_BUSY))
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return
	xeno_owner.stop_pulling()
	playsound(xeno_owner, 'sound/effects/alien/dragon/flying_flight.ogg', 50, TRUE)
	start_flight()

/// Begins the process of flying.
/datum/action/ability/activable/xeno/fly/proc/start_flight()
	COOLDOWN_START(src, animation_cooldown, 0.5 SECONDS)
	new /obj/effect/temp_visual/dragon/fly(get_turf(xeno_owner))
	animate(xeno_owner, pixel_x = initial(xeno_owner.pixel_x), pixel_y = 500, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finalize_flight)), 0.5 SECONDS)

/// Finalizes the process of flying by granting various flags and so on.
/datum/action/ability/activable/xeno/fly/proc/finalize_flight()
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_FLIGHT, TRUE, 0, NONE, TRUE, -1)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_move_attempt))
	COOLDOWN_RESET(src, animation_cooldown)
	animate(xeno_owner, pixel_x = 0, pixel_y = 0, time = 0)
	xeno_owner.status_flags = GODMODE|INCORPOREAL
	xeno_owner.resistance_flags = RESIST_ALL
	xeno_owner.add_pass_flags(PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE, DRAGON_ABILITY_TRAIT)
	xeno_owner.density = FALSE
	ADD_TRAIT(xeno_owner, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	xeno_owner.gain_plasma(xeno_owner.xeno_caste.plasma_max)
	xeno_owner.update_icons(TRUE)
	xeno_owner.update_action_buttons()

/// Begins the process of landing.
/datum/action/ability/activable/xeno/fly/proc/start_landing()
	performing_landing_animation = TRUE
	COOLDOWN_START(src, animation_cooldown, 3 SECONDS)
	animate(xeno_owner, pixel_x = initial(xeno_owner.pixel_x), pixel_y = 500, time = 0)
	var/list/turf/future_impacted_turfs = filled_turfs(xeno_owner, 2, "square", FALSE, pass_flags_checked = PASS_AIR)
	for(var/turf/turf_to_telegraph AS in future_impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(turf_to_telegraph, 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(continue_landing), future_impacted_turfs), 2.5 SECONDS)

/// Continues the process of landing (mainly because of animations).
/datum/action/ability/activable/xeno/fly/proc/continue_landing(list/turf/impacted_turfs)
	animate(xeno_owner, pixel_x = initial(xeno_owner.pixel_x), pixel_y = 0, time = 0.5 SECONDS)
	xeno_owner.update_icons(TRUE)
	addtimer(CALLBACK(src, PROC_REF(perform_landing_effects), impacted_turfs), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finalize_landing)), 0.5 SECONDS)
	playsound(xeno_owner, 'sound/effects/alien/dragon/flying_landing.ogg', 50, TRUE)

/// Finalizes the process of landing by reversing the effects from flying.
/datum/action/ability/activable/xeno/fly/proc/finalize_landing()
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_FLIGHT)
	performing_landing_animation = FALSE
	xeno_owner.status_flags = initial(xeno_owner.status_flags)
	xeno_owner.resistance_flags = initial(xeno_owner.resistance_flags)
	xeno_owner.remove_pass_flags(PASS_LOW_STRUCTURE|PASS_DEFENSIVE_STRUCTURE|PASS_FIRE, DRAGON_ABILITY_TRAIT)
	xeno_owner.density = TRUE
	REMOVE_TRAIT(xeno_owner, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	xeno_owner.update_icons(TRUE)
	xeno_owner.update_action_buttons()
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_PRE_MOVE, COMSIG_XENOMORPH_SUNDER_REGEN))
	succeed_activate()
	add_cooldown()

// Performs various landing effects.
/datum/action/ability/activable/xeno/fly/proc/perform_landing_effects(list/turf/affected_turfs)
	new /obj/effect/temp_visual/dragon/land(get_turf(xeno_owner))
	var/damage = 99 * xeno_owner.xeno_melee_damage_modifier // One damage below the knockdown threshold for default sentries.
	var/list/obj/vehicle/hit_vehicles = list()
	for(var/turf/affected_turf AS in affected_turfs)
		affected_turf.Shake(duration = 0.2 SECONDS)
		for(var/atom/affected_atom AS in affected_turf)
			if(isxeno(affected_atom))
				var/mob/living/carbon/xenomorph/affected_xenomorph = affected_atom
				if(xeno_owner.issamexenohive(affected_xenomorph))
					continue
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				affected_living.take_overall_damage(damage, BRUTE, MELEE, max_limbs = 5, updating_health = TRUE)
				animate(affected_living, pixel_z = affected_living.pixel_z + 8, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = affected_living.pixel_z - 8, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				affected_living.animation_spin(0.5 SECONDS, 1, affected_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				continue
			if(!isobj(affected_atom))
				continue
			if(!(affected_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			var/obj/affected_obj = affected_atom
			if(ishitbox(affected_obj) || isvehicle(affected_obj))
				handle_affected_vehicle(affected_obj, hit_vehicles)
				continue
			affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
			continue
	playsound(xeno_owner, 'sound/effects/alien/behemoth/seismic_fracture_explosion.ogg', 50, 1)
	xeno_owner.gain_plasma(xeno_owner.xeno_caste.plasma_max)
	succeed_activate()
	add_cooldown()

/// Does damage to the vehicle and stuns it.
/datum/action/ability/activable/xeno/fly/proc/handle_affected_vehicle(obj/affected_obj, list/obj/vehicle/hit_vehicles)
	var/damage = 100 * xeno_owner.xeno_melee_damage_modifier
	if(ishitbox(affected_obj))
		var/obj/hitbox/affected_hitbox = affected_obj
		return handle_affected_vehicle(affected_hitbox.root)
	if(!isvehicle(affected_obj))
		return FALSE
	var/obj/vehicle/affected_vehicle = affected_obj
	if(ismecha(affected_vehicle))
		affected_vehicle.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = src)
	else if(isarmoredvehicle(affected_vehicle)) // Obtained from hitbox.
		affected_vehicle.take_damage(damage / 3, BRUTE, MELEE, blame_mob = src)
	else
		affected_vehicle.take_damage(damage * 2, BRUTE, MELEE, blame_mob = src)
	if(!(affected_vehicle in hit_vehicles))
		for(var/mob/living/carbon/human/human_occupant in affected_vehicle.occupants)
			human_occupant.apply_effect(2 SECONDS, EFFECT_PARALYZE)

/// If they are incorporeal, lets them move anywhere as long it is not a bad place.
/datum/action/ability/activable/xeno/fly/proc/on_move_attempt(atom/source, atom/newloc, direction)
	SIGNAL_HANDLER
	if(COOLDOWN_TIMELEFT(src, animation_cooldown))
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	if(!(xeno_owner.status_flags & INCORPOREAL))
		return
	. = COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	if(isclosedturf(newloc) && !istype(newloc, /turf/closed/wall/resin))
		return
	for(var/atom/atom_on_turf AS in newloc.contents)
		if(atom_on_turf.CanPass(xeno_owner, newloc))
			continue
		if((atom_on_turf.resistance_flags & RESIST_ALL)) // This prevents them from going off into space during hijack.
			return
		if(istype(atom_on_turf, /obj/machinery/door/poddoor/timed_late)) /// This prevents them from entering the LZ early.
			return
	xeno_owner.abstract_move(newloc)
	return

/datum/action/ability/activable/xeno/backhand/dragon_breath
	name = "Dragon Breath"
	action_icon_state = "dragon_breath"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, continuously blast fire in a cardinal direction. If you are grabbing a marine, deal an incredible amount of damage and knock them back instead."
	cooldown_duration = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAGON_BREATH,
	)
	width = 1
	height = 9
	do_after_sound = 'sound/effects/alien/dragon/dragonbreath_start.ogg'
	do_after_length = 3 SECONDS
	/// The starting direction of the ability.
	var/starting_direction
	/// The turfs that will (eventually) get affected by the ability. Reset upon movement or when empty.
	var/list/turf/affected_turfs_in_order = list()
	/// The visual effect to delete early if needed.
	var/obj/effect/temp_visual/dragon/fire_breath/visual_effect
	/// The timer id for the timer that ends the ability after a period of time.
	var/ability_timer
	/// The timer id for the timer that occurs every tick while the ability is active.
	var/tick_timer
	/// The typepath of what is to be created on each turf.
	var/selected_typepath = /obj/fire/melting_fire
	/// An image list for the fire selection's radical menu.
	var/selectable_fire_images_list = list()

/datum/action/ability/activable/xeno/backhand/dragon_breath/New()
	. = ..()
	selectable_fire_images_list[DRAGON_BREATH_MELTING] = image('icons/effects/fire.dmi', icon_state = "purple_3")

/datum/action/ability/activable/xeno/backhand/dragon_breath/use_ability(atom/target)
	if(!ability_timer)
		return ..()
	end_ability()

/datum/action/ability/activable/xeno/backhand/dragon_breath/alternate_action_activate()
	if(length(selectable_fire_images_list) <= 1 || ability_timer)
		return
	INVOKE_ASYNC(src, PROC_REF(switch_fire))
	return COMSIG_KB_ACTIVATED

/// Shows a radical menu that lets the owner choose which type of fire they want to use.
/datum/action/ability/activable/xeno/backhand/dragon_breath/proc/switch_fire()
	var/fire_choice = show_radial_menu(owner, owner, selectable_fire_images_list, radius = 35)
	if(!fire_choice)
		return
	switch(fire_choice)
		if(DRAGON_BREATH_MELTING)
			selected_typepath = /obj/fire/melting_fire
			to_chat(owner, span_xenonotice("Our breath will spew melting fire."))
		if(DRAGON_BREATH_SHATTERING)
			selected_typepath = /obj/fire/melting_fire/shattering
			to_chat(owner, span_xenonotice("Our breath will spew shattering fire."))
		if(DRAGON_BREATH_MELTING_ACID)
			selected_typepath = /obj/fire/melting_fire/melting_acid
			to_chat(owner, span_xenonotice("Our breath will spew acidic fire."))

/datum/action/ability/activable/xeno/backhand/dragon_breath/get_damage()
	return 20 * xeno_owner.xeno_melee_damage_modifier

/datum/action/ability/activable/xeno/backhand/dragon_breath/handle_grabbed_human(mob/living/carbon/human/grabbed_human)
	xeno_owner.face_atom(grabbed_human)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	xeno_owner.visible_message(span_danger("[xeno_owner] inhales and turns their sights to [grabbed_human]..."))
	if(do_after(xeno_owner, DRAGON_GRABBED_ABILITY_TIME, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(grab_extra_check))))
		xeno_owner.stop_pulling()
		grabbed_human.emote("scream")
		grabbed_human.Shake(duration = 0.5 SECONDS) // Must stop pulling first for Shake to work.
		xeno_owner.visible_message(span_danger("[xeno_owner] exhales a massive fireball right ontop of [grabbed_human]!"))
		playsound(get_turf(xeno_owner), 'sound/effects/alien/fireball.ogg', 50, 1)
		var/obj/effect/temp_visual/dragon/grab_fire/visual_grab_fire = new(get_turf(grabbed_human))
		var/obj/effect/temp_visual/xeno_fireball_explosion/visual_fireball_explosion = new(get_turf(grabbed_human))
		var/armor_type = BURN
		switch(selected_typepath)
			if(/obj/fire/melting_fire)
				var/datum/status_effect/stacking/melting_fire/debuff = grabbed_human.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
				if(debuff)
					debuff.add_stacks(10, xeno_owner) // 110 (avoidable / extinguishable)
				else
					grabbed_human.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, 10)
			if(/obj/fire/melting_fire/shattering)
				visual_grab_fire.add_atom_colour("#ff000d", FIXED_COLOR_PRIORITY)
				visual_fireball_explosion.add_atom_colour("#ff000d", FIXED_COLOR_PRIORITY)
				var/datum/status_effect/stacking/melting_fire/debuff = grabbed_human.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
				if(debuff)
					debuff.add_stacks(10, xeno_owner) // 110 (avoidable / extinguishable)
				else
					grabbed_human.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, 10)
			if(/obj/fire/melting_fire/melting_acid)
				visual_grab_fire.add_atom_colour("#00ff15", FIXED_COLOR_PRIORITY)
				visual_fireball_explosion.add_atom_colour("#00ff15", FIXED_COLOR_PRIORITY)
				var/datum/status_effect/stacking/melting_acid/debuff = grabbed_human.has_status_effect(STATUS_EFFECT_MELTING_ACID)
				if(debuff)
					debuff.add_stacks(15) // 75 (unavoidable)
				else
					grabbed_human.apply_status_effect(STATUS_EFFECT_MELTING_ACID, 15)
				armor_type = ACID
		grabbed_human.take_overall_damage(get_damage() * 5.5, BURN, armor_type, max_limbs = length(grabbed_human.get_damageable_limbs()), updating_health = TRUE) // 110
		grabbed_human.knockback(xeno_owner, 5, 1)
		xeno_owner.gain_plasma(250)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	succeed_activate()
	add_cooldown()
	return TRUE

/datum/action/ability/activable/xeno/backhand/dragon_breath/handle_regular_ability(atom/target, list/turf/affected_turfs)
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_DRAGON_BREATH, TRUE, 0, NONE, TRUE, 8)
	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.soft_armor = xeno_owner.soft_armor.modifyAllRatings(15)
	ADD_TRAIT(xeno_owner, TRAIT_HANDS_BLOCKED, DRAGON_ABILITY_TRAIT)
	RegisterSignal(xeno_owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(xeno_owner, COMSIG_MOB_STAT_CHANGED, PROC_REF(on_stat_changed))
	starting_direction = get_cardinal_dir(xeno_owner, target)
	visual_effect = new /obj/effect/temp_visual/dragon/fire_breath(get_step(xeno_owner, target), starting_direction)
	switch(selected_typepath)
		if(/obj/fire/melting_fire/shattering)
			visual_effect.add_atom_colour("#ff000d", FIXED_COLOR_PRIORITY)
		if(/obj/fire/melting_fire/melting_acid)
			visual_effect.add_atom_colour("#00ff15", FIXED_COLOR_PRIORITY)
	ability_timer = addtimer(CALLBACK(src, PROC_REF(end_ability)), 10 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)
	tick_effects(get_turf(target), affected_turfs, list())
	return TRUE

/// Ends the ability early.
/datum/action/ability/activable/xeno/backhand/dragon_breath/on_deselection()
	if(!ability_timer)
		return
	end_ability()

/// Rotates the owner back to the starting direction.
/datum/action/ability/activable/xeno/backhand/dragon_breath/proc/on_move(datum/source)
	SIGNAL_HANDLER
	xeno_owner.setDir(starting_direction)
	visual_effect.forceMove(get_turf(xeno_owner))
	affected_turfs_in_order.Cut()
	var/turf/maximum_distance_turf = get_turf(xeno_owner)
	for(var/i in 1 to height)
		maximum_distance_turf = get_step(maximum_distance_turf, xeno_owner.dir)
		affected_turfs_in_order += maximum_distance_turf
		affected_turfs_in_order += get_step(maximum_distance_turf, turn(xeno_owner.dir, 90))
		affected_turfs_in_order += get_step(maximum_distance_turf, turn(xeno_owner.dir, -90))

/// Performs the ability at a pace similar of CAS which is one width length at a time.
/datum/action/ability/activable/xeno/backhand/dragon_breath/proc/tick_effects()
	xeno_owner.setDir(starting_direction) // To prevent them from spinning and looking funky while using this ability.
	playsound(xeno_owner, SFX_GUN_FLAMETHROWER, 50, 1)
	xeno_owner.gain_plasma(3)

	if(!length(affected_turfs_in_order))
		var/turf/maximum_distance_turf = get_turf(xeno_owner)
		for(var/i in 1 to height)
			maximum_distance_turf = get_step(maximum_distance_turf, xeno_owner.dir)
			affected_turfs_in_order += maximum_distance_turf
			affected_turfs_in_order += get_step(maximum_distance_turf, turn(xeno_owner.dir, 90))
			affected_turfs_in_order += get_step(maximum_distance_turf, turn(xeno_owner.dir, -90))
	for(var/i = 1 to (1 + width*2))
		var/turf/affected_turf = affected_turfs_in_order[1]
		affected_turfs_in_order -= affected_turf
		if(!line_of_sight(xeno_owner, affected_turf, max(width, height)))
			continue
		refresh_or_create_fire(affected_turf)
		for(var/atom/affected_atom AS in affected_turf)
			if(isxeno(affected_atom))
				var/mob/living/carbon/xenomorph/affected_xenomorph = affected_atom
				if(xeno_owner.issamexenohive(affected_xenomorph))
					continue
			if(!isliving(affected_atom))
				continue
			var/mob/living/affected_living = affected_atom
			if(affected_living.stat == DEAD)
				continue

			var/armor_type = BURN
			if(selected_typepath == /obj/fire/melting_fire/melting_acid)
				armor_type = ACID
			affected_living.take_overall_damage(get_damage(), BURN, armor_type, updating_health = TRUE, penetration = 30, max_limbs = 5)
			continue
	tick_timer = addtimer(CALLBACK(src, PROC_REF(tick_effects)), 0.1 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Creates a melting fire if it does not exist. If it does, refresh it and affect all atoms in the same turf.
/datum/action/ability/activable/xeno/backhand/dragon_breath/proc/refresh_or_create_fire(turf/target_turf)
	var/obj/fire/melting_fire/fire_in_turf = locate(selected_typepath) in target_turf.contents
	if(!fire_in_turf)
		new selected_typepath(target_turf)
		return
	fire_in_turf.burn_ticks = initial(fire_in_turf.burn_ticks)
	for(var/something_in_turf in get_turf(fire_in_turf))
		fire_in_turf.affect_atom(something_in_turf)

/// Ends the ability if they are not conscious.
/datum/action/ability/activable/xeno/backhand/dragon_breath/proc/on_stat_changed(datum/source, old_stat, new_stat)
	SIGNAL_HANDLER
	if(new_stat == CONSCIOUS)
		return
	end_ability()

/// Undoes everything associated with starting the ability.
/datum/action/ability/activable/xeno/backhand/dragon_breath/proc/end_ability()
	xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_DRAGON_BREATH)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.soft_armor = xeno_owner.soft_armor.modifyAllRatings(-15)
	REMOVE_TRAIT(xeno_owner, TRAIT_HANDS_BLOCKED, DRAGON_ABILITY_TRAIT)
	UnregisterSignal(xeno_owner, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_STAT_CHANGED))
	starting_direction = null
	affected_turfs_in_order.Cut()
	QDEL_NULL(visual_effect)
	deltimer(ability_timer)
	ability_timer = null
	deltimer(tick_timer)
	tick_timer = null
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/wind_current
	name = "Wind Current"
	action_icon_state = "wind_current"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a short windup, deal high damage and a knockback to marines in a cone in front of you. This also clear any gas."
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_WIND_CURRENT,
	)

/datum/action/ability/activable/xeno/wind_current/can_use_ability(atom/A, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying!")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/wind_current/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/list/turf/impacted_turfs = generate_cone(xeno_owner, 9, 1, 60, dir2angle(xeno_owner.dir), pass_flags_checked = PASS_AIR)
	for(var/turf/impacted_turf in impacted_turfs) // This gets us a flat-ended cone.
		if(get_dist(impacted_turf, get_turf(xeno_owner)) <= 7)
			continue
		impacted_turfs -= impacted_turf

	for(var/turf/impacted_turf AS in impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(impacted_turf, 0.5 SECONDS)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 0.5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return

	new /obj/effect/temp_visual/dragon/wind_current(get_turf(xeno_owner))
	xeno_owner.visible_message(span_danger("\The [xeno_owner] flaps their wings!"), \
		span_danger("We flap our wings!"), null, 5)

	var/damage = 55 * xeno_owner.xeno_melee_damage_modifier
	var/list/mob/living/living_to_knockback = list()
	for(var/turf/impacted_turf AS in impacted_turfs)
		impacted_turf.Shake(duration = 0.25 SECONDS)
		for(var/atom/impacted_atom AS in impacted_turf)
			if(istype(impacted_atom, /obj/effect/particle_effect/smoke))
				qdel(impacted_atom)
				continue
			if(isxeno(impacted_atom))
				var/mob/living/carbon/xenomorph/impacted_xenomorph = impacted_atom
				if(xeno_owner.issamexenohive(impacted_xenomorph))
					continue
			if(isliving(impacted_atom))
				var/mob/living/impacted_living = impacted_atom
				if(impacted_living.stat == DEAD)
					continue
				impacted_living.take_overall_damage(damage, BURN, MELEE, max_limbs = 5, updating_health = TRUE)
				if(impacted_living.move_resist < MOVE_FORCE_OVERPOWERING)
					living_to_knockback += impacted_living

				animate(impacted_living, pixel_z = impacted_living.pixel_z + 8, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW|ANIMATION_PARALLEL)
				animate(pixel_z = impacted_living.pixel_z - 8, time = 0.25 SECONDS, easing = CIRCULAR_EASING|EASE_IN)
				impacted_living.animation_spin(0.5 SECONDS, 1, impacted_living.dir == WEST ? FALSE : TRUE, anim_flags = ANIMATION_PARALLEL)
				continue
			if(!isobj(impacted_atom))
				continue
			if(isfire(impacted_atom))
				var/obj/fire/fire = impacted_atom
				fire.reduce_fire(20)
				continue
			if(!(impacted_atom.resistance_flags & XENO_DAMAGEABLE))
				continue
			var/obj/impacted_obj = impacted_atom
			if(ishitbox(impacted_obj))
				impacted_obj.take_damage(damage * 1/3, BRUTE, MELEE, blame_mob = xeno_owner) // Adjusted for 3x3 multitile vehicles.
				continue
			if(!isvehicle(impacted_obj))
				impacted_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
				continue
			if(ismecha(impacted_obj))
				impacted_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner)
				continue
			impacted_obj.take_damage(damage * 2, BRUTE, MELEE, blame_mob = xeno_owner)
			continue

	// This is separate because it is possible for them to be pushed into an unprocessed turf which will then do the effects again, causing instant death (or more damage than desired).
	for(var/mob/living/knockbacked_living AS in living_to_knockback)
		knockbacked_living.knockback(xeno_owner, 4, 1)

	playsound(get_turf(xeno_owner), 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
	xeno_owner.gain_plasma(xeno_owner.xeno_caste.plasma_max / 2)
	succeed_activate()
	add_cooldown()

/datum/action/ability/activable/xeno/grab
	name = "Grab"
	action_icon_state = "grab"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, drag a marine in front of you and initiate a passive grab allowing you to drag them as you move. They are unable to move on their volition, but are fully capable of fighting back. Your grab automatically breaks if you stop grabbing or take too much damage."
	cooldown_duration = 20 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_GRAB,
	)
	/// The grab item that is grabbing the human.
	var/obj/item/grab/grabbing_item
	/// The human that we are trying to grab or are currently grabbing. Used to differenate from a normal grab vs. ability grab.
	var/mob/living/carbon/human/grabbed_human
	/// Damage taken so far while actively grabbing.
	var/damage_taken_so_far = 0

/datum/action/ability/activable/xeno/grab/remove_action(mob/living/ability_owner)
	end_grabbing(no_cooldown = TRUE)
	return ..()

/datum/action/ability/activable/xeno/grab/can_use_ability(atom/target, silent, override_flags)
	if(xeno_owner.status_flags & INCORPOREAL)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while flying!")
		return FALSE
	if(grabbed_human)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already grabbing someone!")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/grab/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/list/turf/impacted_turfs = get_forward_square(xeno_owner, 2, 2) // 5x2
	for(var/turf/impacted_turf AS in impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(impacted_turf, 0.5 SECONDS)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 0.5 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER)
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

	if(!length(acceptable_humans)) // Whiff.
		playsound(get_turf(xeno_owner), 'sound/effects/alien/tail_swipe2.ogg', 50, 1)
		succeed_activate()
		add_cooldown()
		return

	for(var/mob/living/carbon/human/nearest_human AS in acceptable_humans)
		if(!grabbed_human)
			grabbed_human = nearest_human
			continue
		if(get_dist(xeno_owner, grabbed_human) > nearest_human)
			continue
		grabbed_human = nearest_human

	RegisterSignal(grabbed_human, COMSIG_MOVABLE_POST_THROW, PROC_REF(throw_completion))
	ADD_TRAIT(grabbed_human, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	grabbed_human.add_pass_flags(PASS_MOB|PASS_XENO, DRAGON_ABILITY_TRAIT)
	grabbed_human.throw_at(get_step(xeno_owner, xeno_owner.dir), 5, 5, xeno_owner)

/// Removes signal and pass_flags from the thrown human and tries to grab them (via async).
/datum/action/ability/activable/xeno/grab/proc/throw_completion(datum/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/thrown_human = source
	UnregisterSignal(thrown_human, COMSIG_MOVABLE_POST_THROW)
	thrown_human.remove_pass_flags(PASS_MOB|PASS_XENO, DRAGON_ABILITY_TRAIT)
	INVOKE_ASYNC(src, PROC_REF(try_grabbing), thrown_human)

/// Try to grab the thrown human.
/datum/action/ability/activable/xeno/grab/proc/try_grabbing(mob/living/carbon/human/thrown_human)
	if(QDELETED(thrown_human) || thrown_human.stat == DEAD || !xeno_owner.Adjacent(thrown_human))
		end_grabbing()
		return
	if(!xeno_owner.start_pulling(thrown_human) || !xeno_owner.get_active_held_item())
		end_grabbing()
		return

	grabbing_item = xeno_owner.get_active_held_item()
	if(!grabbing_item)
		end_grabbing()
		return
	grabbed_human = thrown_human
	damage_taken_so_far = 0

	ADD_TRAIT(grabbed_human, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	RegisterSignal(grabbing_item, COMSIG_QDELETING, PROC_REF(end_grabbing))
	RegisterSignal(grabbed_human, COMSIG_MOB_STAT_CHANGED, PROC_REF(human_stat_changed))
	RegisterSignal(grabbed_human, COMSIG_LIVING_DO_MOVE_RESIST, PROC_REF(on_resist_attempt))
	RegisterSignals(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taken_damage))
	xeno_owner.gain_plasma(250)
	new /obj/effect/temp_visual/dragon/grab(get_turf(grabbed_human))
	playsound(get_turf(xeno_owner), 'sound/voice/alien/pounce.ogg', 25, TRUE)

/// Cleans up everything associated with the grabbing and ends the ability.
/datum/action/ability/activable/xeno/grab/proc/end_grabbing(datum/source, no_cooldown = FALSE)
	SIGNAL_HANDLER
	if(grabbed_human)
		REMOVE_TRAIT(grabbed_human, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	if(grabbing_item) // Removing signals that are added only due to successful grab.
		UnregisterSignal(grabbing_item, COMSIG_QDELETING)
		UnregisterSignal(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
		if(grabbed_human)
			UnregisterSignal(grabbed_human, list(COMSIG_MOB_STAT_CHANGED, COMSIG_LIVING_DO_MOVE_RESIST))
	grabbed_human = null
	grabbing_item = null
	if(no_cooldown)
		return
	succeed_activate()
	add_cooldown()

/// Stops grabbing if the grabbed human dies.
/datum/action/ability/activable/xeno/grab/proc/human_stat_changed(datum/source, old_stat, new_stat)
	SIGNAL_HANDLER
	if(new_stat != DEAD)
		return
	xeno_owner.stop_pulling()

/// Prevents all atempts to resist (and move).
/datum/action/ability/activable/xeno/grab/proc/on_resist_attempt(datum/source)
	SIGNAL_HANDLER
	return COMSIG_LIVING_RESIST_SUCCESSFUL

/// Stops grabbing if owner has taken 200 or more damage since beginning the grab. Damage is calculated after soft armor and plasma reduction.
/datum/action/ability/activable/xeno/grab/proc/taken_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far >= 200)
		xeno_owner.stop_pulling()

/datum/action/ability/activable/xeno/scorched_land
	name = "Scorched Land"
	action_icon_state = "scorched_land"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "While flying, breath fire downward from the sky in a long line where you're facing."
	cooldown_duration = 150 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SCORCHED_LAND,
	)
	/// The timer id for the timer that occurs every tick.
	var/tick_timer

/datum/action/ability/activable/xeno/scorched_land/can_use_ability(atom/A, silent, override_flags)
	if(!(xeno_owner.status_flags & INCORPOREAL))
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "cannot while landed!")
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
				xeno_owner.balloon_alert(xeno_owner, "no friendlies in sight!")
			else
				xeno_owner.balloon_alert(xeno_owner, "no weeds!")
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/scorched_land/use_ability(atom/target)
	xeno_owner.face_atom(target)

	var/list/turf/impacted_turfs = get_forward_square(xeno_owner, 2, 7)
	for(var/turf/impacted_turf AS in impacted_turfs)
		new /obj/effect/temp_visual/dragon/warning(impacted_turf, 3 SECONDS)

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	var/was_successful = do_after(xeno_owner, 3 SECONDS, IGNORE_HELD_ITEM, xeno_owner, BUSY_ICON_DANGER)
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, DRAGON_ABILITY_TRAIT)
	if(!was_successful)
		return

	xeno_owner.face_atom(target)
	var/list/turf/affected_turfs_in_order = list()
	var/turf/maximum_distance_turf = get_turf(xeno_owner)
	for(var/i in 1 to 7)
		maximum_distance_turf = get_step(maximum_distance_turf, xeno_owner.dir)
		if(!line_of_sight(xeno_owner, maximum_distance_turf, 7))
			break
		if(isclosedturf(maximum_distance_turf))
			break
		affected_turfs_in_order += maximum_distance_turf
		affected_turfs_in_order += get_step(maximum_distance_turf, turn(xeno_owner.dir, 90))
		affected_turfs_in_order += get_step(get_step(maximum_distance_turf, turn(xeno_owner.dir, 90)), turn(xeno_owner.dir, 90))
		affected_turfs_in_order += get_step(maximum_distance_turf, turn(xeno_owner.dir, -90))
		affected_turfs_in_order += get_step(get_step(maximum_distance_turf, turn(xeno_owner.dir, -90)), turn(xeno_owner.dir, -90))
	tick_timer = addtimer(CALLBACK(src, PROC_REF(tick_effects), affected_turfs_in_order), 0.1 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Performs the ability at a pace similar of CAS which is one width length at a length.
/datum/action/ability/activable/xeno/scorched_land/proc/tick_effects(list/turf/affected_turfs_in_order)
	playsound(xeno_owner, SFX_GUN_FLAMETHROWER, 50, 1)

	var/effect_already_done = FALSE
	for(var/i = 1 to 5)
		var/turf/affected_turf = affected_turfs_in_order[1]
		if(!effect_already_done)
			new /obj/effect/temp_visual/dragon/fire_breath/sky(affected_turf)
			new /obj/effect/temp_visual/dragon/scorched_land(affected_turf)
			effect_already_done = TRUE
		affected_turfs_in_order -= affected_turf
		refresh_or_create_fire(affected_turf)
		for(var/atom/affected_atom AS in affected_turf)
			if(isxeno(affected_atom))
				var/mob/living/carbon/xenomorph/affected_xenomorph = affected_atom
				if(xeno_owner.issamexenohive(affected_xenomorph))
					continue
				continue
			if(!isliving(affected_atom))
				continue
			var/mob/living/affected_living = affected_atom
			if(affected_living.stat == DEAD)
				continue
			affected_living.take_overall_damage(100 * xeno_owner.xeno_melee_damage_modifier, BURN, FIRE, updating_health = TRUE, penetration = 30, max_limbs = 5)
			continue
	if(!length(affected_turfs_in_order))
		succeed_activate()
		add_cooldown()
		return
	tick_timer = addtimer(CALLBACK(src, PROC_REF(tick_effects), affected_turfs_in_order), 0.1 SECONDS, TIMER_STOPPABLE|TIMER_UNIQUE)

/// Creates a melting fire if it does not exist. If it does, refresh it and affect all atoms in the same turf.
/datum/action/ability/activable/xeno/scorched_land/proc/refresh_or_create_fire(turf/target_turf)
	var/obj/fire/melting_fire/fire_in_turf = locate(/obj/fire/melting_fire) in target_turf.contents
	if(!fire_in_turf)
		new /obj/fire/melting_fire(target_turf)
		return
	fire_in_turf.burn_ticks = initial(fire_in_turf.burn_ticks)
	for(var/something_in_turf in get_turf(fire_in_turf))
		fire_in_turf.affect_atom(something_in_turf)

/obj/effect/temp_visual/dragon
	name = "Dragon"
	randomdir = FALSE

/obj/effect/temp_visual/dragon/warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "generic_warning"
	layer = BELOW_MOB_LAYER
	color = COLOR_RED
	duration = 1.5 SECONDS

/obj/effect/temp_visual/dragon/warning/Initialize(mapload, _duration)
	if(isnum(_duration))
		duration = _duration
	notify_ai_hazard()
	return ..()

/obj/effect/temp_visual/dragon/directional
	icon = 'icons/effects/128x128.dmi'
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	randomdir = FALSE

/obj/effect/temp_visual/dragon/directional/Initialize(mapload, direction)
	if(!direction)
		return INITIALIZE_HINT_QDEL
	dir = direction
	switch(dir)
		if(NORTH)
			pixel_x = -48
			pixel_y = 0
		if(EAST)
			pixel_x = 0
			pixel_y = -48
		if(SOUTH)
			pixel_x = -48
			pixel_y = -96
		if(WEST)
			pixel_x = -96
			pixel_y = -48
	return ..()

/obj/effect/temp_visual/dragon/directional/backhand
	icon_state = "backhand"
	duration = 0.56 SECONDS

/obj/effect/temp_visual/dragon/directional/backhand_slam
	icon_state = "backhand_slam"
	duration = 0.64 SECONDS

/obj/effect/temp_visual/dragon/directional/tail_swipe
	icon_state = "tail_swipe"
	duration = 0.64 SECONDS

/obj/effect/temp_visual/dragon/fire_breath
	icon = 'icons/Xeno/300x300.dmi'
	icon_state = "firebreath_hold"
	layer = BELOW_MOB_LAYER
	randomdir = FALSE
	duration = 10 SECONDS

/obj/effect/temp_visual/dragon/fire_breath/Initialize(mapload, direction)
	if(!direction)
		return INITIALIZE_HINT_QDEL
	dir = direction
	switch(dir)
		if(NORTH)
			pixel_x = -128
			pixel_y = 32
		if(EAST)
			pixel_x = 32
			pixel_y = -128
		if(SOUTH)
			pixel_x = -128
			pixel_y = -300
		if(WEST)
			pixel_x = -332
			pixel_y = -128
	return ..()

/obj/effect/temp_visual/dragon/fire_breath/sky
	duration = 0.1 SECONDS

/obj/effect/temp_visual/dragon/fire_breath/sky/Initialize(mapload)
	. = ..(mapload, SOUTH)
	pixel_y = 0

/obj/effect/temp_visual/dragon/scorched_land
	icon = 'icons/Xeno/96x144.dmi'
	icon_state = "primo_impact"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.4 SECONDS

/obj/effect/temp_visual/dragon/fly
	icon = 'icons/Xeno/96x144.dmi'
	icon_state = "fly"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.8 SECONDS

/obj/effect/temp_visual/dragon/land
	icon = 'icons/Xeno/96x144.dmi'
	icon_state = "fly_landing"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.56 SECONDS

/obj/effect/temp_visual/dragon/grab_fire
	icon = 'icons/Xeno/64x64.dmi'
	icon_state = "grab_fire"
	pixel_x = -16
	pixel_y = -16
	layer = BELOW_MOB_LAYER
	duration = 1.19 SECONDS

/obj/effect/temp_visual/dragon/wind_current
	icon = 'icons/Xeno/96x144.dmi'
	icon_state = "wind_current"
	pixel_x = -32
	layer = BELOW_MOB_LAYER
	duration = 0.7 SECONDS

/obj/effect/temp_visual/dragon/grab
	icon = 'icons/Xeno/64x64.dmi'
	icon_state = "grab"
	pixel_x = -16
	pixel_y = -16
	layer = BELOW_MOB_LAYER
	duration = 0.72 SECONDS
