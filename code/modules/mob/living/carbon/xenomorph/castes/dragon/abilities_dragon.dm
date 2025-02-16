/datum/action/ability/activable/xeno/backhand
	name = "Backhand"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = "After a windup, deal high damage and a fair knock back to marines in front of you. Vehicles and mechas take more damage, but are not knocked back. If you are grabbing a marine, deal an incredible amount of damage instead."
	cooldown_duration = 10 SECONDS

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
			if(!isvehicle(affected_obj))
				affected_obj.take_damage(damage, BRUTE, MELEE, blame_mob = xeno_owner)
				has_hit_anything = TRUE
				continue
			if(ismecha(affected_obj))
				affected_obj.take_damage(damage * 3, BRUTE, MELEE, armour_penetration = 50, blame_mob = xeno_owner) // 180
			else if(isarmoredvehicle(affected_obj) || ishitbox(affected_obj))
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

/datum/action/ability/activable/xeno/tailswipe
	name = "Tailswipe"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 12 SECONDS

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
			if(ishitbox(affected_atom))
				var/obj/hitbox/vehicle_hitbox = affected_atom
				if(vehicle_hitbox.root in vehicles_already_affected_so_far)
					continue
				handle_vehicle_effects(vehicle_hitbox.root, damage * 1/3)
				vehicles_already_affected_so_far += vehicle_hitbox.root
				has_hit_anything = TRUE
				continue
			if(isvehicle(affected_atom))
				if(ismecha(affected_atom))
					handle_vehicle_effects(affected_atom, damage * 3, 50)
				else if(isarmoredvehicle(affected_atom))
					handle_vehicle_effects(affected_atom, damage / 3)
				else
					handle_vehicle_effects(affected_atom, damage)
				vehicles_already_affected_so_far += affected_atom
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
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 20 SECONDS
	/// Current target that the xeno is targeting. This is for aiming.
	var/current_target
	/// The timer id for the timer that ends the ability.
	var/ability_timer
	/// The timer id for the timer that gives plasma every second.
	var/plasma_timer

/datum/action/ability/activable/xeno/dragon_breath/use_ability(atom/target)
	if(ability_timer)
		return // The auto fire component handles the shooting.

	var/datum/action/ability/activable/xeno/grab/grab_ability = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/grab]
	var/mob/living/carbon/human/grabbed_human = grab_ability?.grabbed_human
	var/turf/current_turf = get_turf(xeno_owner)
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
			playsound(current_turf, 'sound/effects/alien/fireball.ogg', 50, 1)
			new /obj/effect/temp_visual/xeno_fireball_explosion(current_turf)
			grabbed_human.take_overall_damage(200 * xeno_owner.xeno_melee_damage_modifier, BURN, FIRE, max_limbs = 6, updating_health = TRUE)
			grabbed_human.knockback(xeno_owner, 5, 1)
			xeno_owner.gain_plasma(250)
		xeno_owner.move_resist = initial(xeno_owner.move_resist)
		xeno_owner.remove_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
		succeed_activate()
		add_cooldown()
		return

	xeno_owner.move_resist = MOVE_FORCE_OVERPOWERING
	xeno_owner.add_traits(list(TRAIT_HANDS_BLOCKED, TRAIT_IMMOBILE), DRAGON_ABILITY_TRAIT)
	playsound(xeno_owner, 'sound/effects/alien/behemoth/primal_wrath_roar.ogg', 75, TRUE) // TODO: This sound is not really ideal.
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
/datum/action/ability/activable/xeno/dragon_breath/deselect()
	end_ability()
	return ..()

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
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 20 SECONDS

/datum/action/ability/activable/xeno/wind_current/use_ability(atom/target)
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
				affected_living.take_overall_damage(damage, BURN, FIRE, max_limbs = 6, updating_health = TRUE)
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
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 20 SECONDS
	/// The grab item that is grabbing the human.
	var/obj/item/grab/grabbing_item
	/// The human that we are trying to grab or are currently grabbing. Used to differenate from a normal grab vs. ability grab.
	var/mob/living/carbon/human/grabbed_human
	/// Damage taken so far while actively grabbing.
	var/damage_taken_so_far = 0

/datum/action/ability/activable/xeno/grab/can_use_ability(atom/target, silent, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(grabbed_human)
		if(!silent)
			xeno_owner.balloon_alert(xeno_owner, "already grabbing someone")
		return FALSE

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

/// Stops grabbing if owner has taken 300+ damage since beginning the grab.
/datum/action/ability/activable/xeno/grab/proc/taken_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0)
		return
	damage_taken_so_far += amount
	if(damage_taken_so_far >= 300)
		xeno_owner.stop_pulling()

/datum/action/ability/activable/xeno/miasma
	name = "Miasma"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 30 SECONDS


/datum/action/ability/activable/xeno/lightning_strike
	name = "Lightning Strike"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 25 SECONDS


/datum/action/ability/activable/xeno/fire_storm
	name = "Fire Storm"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 30 SECONDS

/datum/action/ability/activable/xeno/ice_spike
	name = "Ice Spike"
	action_icon_state = "shattering_roar"
	action_icon = 'icons/Xeno/actions/dragon.dmi'
	desc = ""
	cooldown_duration = 30 SECONDS

/obj/effect/xeno/dragon_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "shallnotpass"
