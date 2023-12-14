/obj/effect/temp_visual/behemoth
	name = "Behemoth"
	duration = 10 SECONDS

/obj/effect/temp_visual/behemoth/stomp
	icon_state = "behemoth_stomp"
	duration = 0.5 SECONDS
	layer = ABOVE_LYING_MOB_LAYER

/obj/effect/temp_visual/behemoth/stomp/Initialize(mapload)
	. = ..()
	var/matrix/current_matrix = matrix()
	transform = current_matrix.Scale(0.6, 0.6)
	current_matrix.Scale(2.2, 2.2)
	animate(src, alpha = 0, transform = current_matrix, time = duration - 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/stomp/west/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x += 12
			pixel_y += 1
		if(SOUTH)
			pixel_x -= 10
			pixel_y -= 1
		if(WEST)
			pixel_x -= 25
			pixel_y -= 1
		if(EAST)
			pixel_x += 32
			pixel_y -= 1

/obj/effect/temp_visual/behemoth/stomp/east/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x -= 12
			pixel_y += 1
		if(SOUTH)
			pixel_x += 10
			pixel_y -= 1
		if(WEST)
			pixel_x -= 11
			pixel_y -= 1
		if(EAST)
			pixel_x += 18
			pixel_y -= 1

/obj/effect/temp_visual/behemoth/crack
	icon_state = "behemoth_crack"
	duration = 5.5 SECONDS
	layer = CONVEYOR_LAYER

/obj/effect/temp_visual/behemoth/crack/Initialize(mapload)
	. = ..()
	layer += 0.01
	animate(src, time = duration - 1 SECONDS)
	animate(alpha = 0, time = 1 SECONDS)

/obj/effect/temp_visual/behemoth/warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "generic_warning"
	layer = BELOW_MOB_LAYER
	color = COLOR_ORANGE

/obj/effect/temp_visual/behemoth/warning/Initialize(mapload, warning_duration)
	. = ..()
	if(warning_duration)
		duration = warning_duration
	animate(src, time = duration - 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/warning/enhanced
	color = COLOR_VIVID_RED


// ***************************************
// *********** Global Procs
// ***************************************
/// Warns nearby players, in any way or form, of the incoming ability and the range it will affect.
/proc/do_warning(owner, list/turf/target_turfs, duration)
	if(!owner || !length(target_turfs) || !duration)
		CRASH("do_warning([owner], [length(target_turfs)], [duration]) called with improper arguments")
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/ability/xeno_action/primal_wrath/primal_wrath_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	var/warning_type = primal_wrath_action?.ability_active? /obj/effect/temp_visual/behemoth/warning/enhanced : /obj/effect/temp_visual/behemoth/warning
	for(var/turf/target_turf AS in target_turfs)
		new warning_type(target_turf, duration)
		playsound(target_turf, 'sound/effects/behemoth/behemoth_rumble.ogg', 15, TRUE)
		for(var/mob/living/target_living in target_turf)
			if(xeno_owner.issamexenohive(target_living) || target_living.stat == DEAD || CHECK_BITFIELD(target_living.status_flags, INCORPOREAL|GODMODE))
				continue


// ***************************************
// *********** Roll
// ***************************************
#define BEHEMOTH_ROLL_WIND_UP 1.8 SECONDS

/datum/action/ability/xeno_action/ready_charge/behemoth_roll
	name = "Roll"
	desc = "Toggles Rolling on or off."
	charge_type = CHARGE_BEHEMOTH
	speed_per_step = 0.4
	steps_for_charge = 4
	max_steps_buildup = 4
	crush_living_damage = 0
	plasma_use_multiplier = 0
	agile_charge = TRUE
	should_start_on = FALSE
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BEHEMOTH_ROLL,
	)

/datum/action/ability/xeno_action/ready_charge/behemoth_roll/action_activate()
	if(charge_ability_on)
		charge_off()
		return
	if(!do_after(owner, BEHEMOTH_ROLL_WIND_UP, IGNORE_HELD_ITEM, owner, BUSY_ICON_HOSTILE, BUSY_ICON_HOSTILE))
		return
	charge_on()

/datum/action/ability/xeno_action/ready_charge/behemoth_roll/charge_off(verbose = TRUE)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.behemoth_charging = FALSE
	REMOVE_TRAIT(xeno_owner, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	xeno_owner.update_icons()
	add_cooldown(15 SECONDS)

/datum/action/ability/xeno_action/ready_charge/behemoth_roll/charge_on(verbose = TRUE)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.behemoth_charging = TRUE
	ADD_TRAIT(xeno_owner, TRAIT_SILENT_FOOTSTEPS, XENO_TRAIT)
	xeno_owner.update_icons()
	for(var/mob/living/rider AS in xeno_owner.buckled_mobs)
		xeno_owner.unbuckle_mob(rider)


// ***************************************
// *********** Landslide
// ***************************************
#define LANDSLIDE_WIND_UP 0.8 SECONDS
#define LANDSLIDE_ENHANCED_WIND_UP 0.4 SECONDS
#define LANDSLIDE_RANGE 7
#define LANDSLIDE_STEP_DELAY 1.7 //in deciseconds
#define LANDSLIDE_ENHANCED_STEP_DELAY 0.5 //in deciseconds
#define LANDSLIDE_ENDING_COLLISION_DELAY 0.3 SECONDS
#define LANDSLIDE_KNOCKDOWN_DURATION 1 SECONDS
#define LANDSLIDE_DAMAGE_MULTIPLIER 1.2
#define LANDSLIDE_DAMAGE_MECHA_MODIFIER 20
#define LANDSLIDE_OBJECT_INTEGRITY_THRESHOLD 150

#define LANDSLIDE_ENDED_CANCELLED (1<<0)
#define LANDSLIDE_ENDED_NO_PLASMA (1<<1)

/obj/effect/temp_visual/behemoth/crack/landslide/Initialize(mapload, direction, which_step)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x += which_step? -12 : 12
			pixel_y += 17
		if(SOUTH)
			pixel_x += which_step? 12 : -12
			pixel_y -= 24
		if(WEST)
			pixel_x -= 16
			pixel_y += which_step? -10 : 10
		if(EAST)
			pixel_x += 20
			pixel_y += which_step? 10 : -10

/obj/effect/temp_visual/behemoth/landslide/dust
	icon = 'icons/effects/effects.dmi'
	icon_state = "landslide_dust"
	layer = ABOVE_LYING_MOB_LAYER
	duration = 1.1 SECONDS

/obj/effect/temp_visual/behemoth/landslide/dust/Initialize(mapload, direction, which_step)
	. = ..()
	adjust_offsets(direction, which_step)
	do_animation(direction)

/// Adjusts pixel_x and pixel_y, based on direction, with hand-picked offsets.
/obj/effect/temp_visual/behemoth/landslide/dust/proc/adjust_offsets(direction, which_step)
	switch(direction)
		if(NORTH)
			pixel_x += which_step? -12 : 12
			pixel_y -= 2
		if(SOUTH)
			pixel_x += which_step? -11 : 11
			pixel_y -= 13
		if(WEST)
			pixel_x += which_step? -25 : -12
			pixel_y -= 13
		if(EAST)
			pixel_x += which_step? 18 : 31
			pixel_y -= 13

/// Executes the animation for this object.
/obj/effect/temp_visual/behemoth/landslide/dust/proc/do_animation(direction)
	var/pixel_mod = 10
	switch(direction)
		if(NORTH)
			animate(src, alpha = 0, pixel_y = pixel_y - pixel_mod, time = duration - duration * 0.2, easing = CIRCULAR_EASING|EASE_OUT)
		if(SOUTH)
			animate(src, alpha = 0, pixel_y = pixel_y + pixel_mod, time = duration - duration * 0.2, easing = CIRCULAR_EASING|EASE_OUT)
		if(WEST)
			animate(src, alpha = 0, pixel_x = pixel_x + pixel_mod, time = duration - duration * 0.2, easing = CIRCULAR_EASING|EASE_OUT)
		if(EAST)
			animate(src, alpha = 0, pixel_x = pixel_x - pixel_mod, time = duration - duration * 0.2, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/landslide/dust/charge
	icon = 'icons/effects/96x96.dmi'
	duration = 1.8 SECONDS
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/behemoth/landslide/dust/charge/adjust_offsets(direction, which_step)
	switch(direction)
		if(NORTH)
			pixel_y += 8
		if(SOUTH)
			pixel_y -= 6
		if(WEST)
			pixel_x -= 13
		if(EAST)
			pixel_x += 16

/obj/effect/temp_visual/behemoth/landslide/dust/charge/do_animation(direction)
	animate(src, alpha = 0, time = duration - duration * 0.2, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/landslide/hit
	icon = 'icons/effects/effects.dmi'
	icon_state = "landslide_hit"
	duration = 0.21 SECONDS
	layer = RIPPLE_LAYER

/obj/effect/temp_visual/behemoth/landslide/hit/Initialize(mapload)
	. = ..()
	layer += 0.01
	var/list/pixel_modifier = rand(-3, 3)
	pixel_x += pixel_modifier
	pixel_y += pixel_modifier

/datum/action/ability/activable/xeno/landslide
	name = "Landslide"
	action_icon_state = "landslide"
	desc = "Rush forward in the selected direction, damaging enemies caught in a wide path."
	ability_cost = 3 // This is deducted per step taken during the ability.
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LANDSLIDE,
	)
	/// Whether this ability is currently active or not.
	var/ability_active = FALSE
	/// The amount of charges we currently have.
	var/current_charges = 1
	/// The maximum amount of charges we can have.
	var/maximum_charges = 1

/datum/action/ability/activable/xeno/landslide/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[current_charges]/[maximum_charges]")
	visual_references[VREF_MUTABLE_LANDSLIDE] = counter_maptext

/datum/action/ability/activable/xeno/landslide/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_LANDSLIDE])
	visual_references[VREF_MUTABLE_LANDSLIDE] = null

/datum/action/ability/activable/xeno/landslide/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_LANDSLIDE])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_LANDSLIDE]
	number.maptext = MAPTEXT("[current_charges]/[maximum_charges]")
	visual_references[VREF_MUTABLE_LANDSLIDE] = number
	button.add_overlay(visual_references[VREF_MUTABLE_LANDSLIDE])
	return ..()

/datum/action/ability/activable/xeno/landslide/can_use_action(silent, override_flags, selecting)
	if(ability_active)
		return FALSE
	return ..()

/datum/action/ability/activable/xeno/landslide/action_cooldown_check()
	if(cooldown_timer && current_charges > 0)
		return TRUE
	return ..()

/datum/action/ability/activable/xeno/landslide/on_cooldown_finish()
	current_charges = min(maximum_charges, current_charges + 1)
	update_button_icon()
	owner.balloon_alert(owner, "[name] ready ([current_charges]/[maximum_charges])")
	if(current_charges < maximum_charges)
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(on_cooldown_finish)), cooldown_duration, TIMER_STOPPABLE)
		return
	return ..()

/datum/action/ability/activable/xeno/landslide/use_ability(atom/target)
	if(!target)
		return
	var/turf/owner_turf = get_turf(owner)
	var/direction = get_cardinal_dir(owner, target)
	if(LinkBlocked(owner_turf, get_step(owner, direction)) || owner_turf == get_turf(target))
		owner.balloon_alert(owner, "No space")
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/ability/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/behemoth_roll]
	if(behemoth_roll_action?.charge_ability_on)
		behemoth_roll_action.charge_off()
	ability_active = TRUE
	current_charges--
	update_button_icon()
	xeno_owner.face_atom(target)
	xeno_owner.set_canmove(FALSE)
	xeno_owner.behemoth_charging = TRUE
	ADD_TRAIT(xeno_owner, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	playsound(xeno_owner, 'sound/effects/behemoth/landslide_roar.ogg', 40, TRUE)
	var/which_step = pick(0, 1)
	new /obj/effect/temp_visual/behemoth/landslide/dust(owner_turf, direction, which_step)
	do_warning(xeno_owner, get_affected_turfs(owner_turf, direction, LANDSLIDE_RANGE), LANDSLIDE_WIND_UP + 0.5 SECONDS)
	var/charge_damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * LANDSLIDE_DAMAGE_MULTIPLIER
	var/datum/action/ability/xeno_action/primal_wrath/primal_wrath_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	if(primal_wrath_action?.ability_active)
		var/animation_time = LANDSLIDE_RANGE * LANDSLIDE_ENHANCED_STEP_DELAY
		addtimer(CALLBACK(src, PROC_REF(enhanced_do_charge), direction, charge_damage, LANDSLIDE_ENHANCED_STEP_DELAY, LANDSLIDE_RANGE), LANDSLIDE_ENHANCED_WIND_UP)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(playsound), xeno_owner, 'sound/effects/behemoth/landslide_enhanced_charge.ogg', 30, TRUE), LANDSLIDE_ENHANCED_WIND_UP)
		animate(xeno_owner, time = LANDSLIDE_ENHANCED_WIND_UP, flags = ANIMATION_END_NOW)
		animate(pixel_y = xeno_owner.pixel_y + (LANDSLIDE_RANGE / 2), time = animation_time / 2, easing = CIRCULAR_EASING|EASE_OUT)
		animate(pixel_y = initial(xeno_owner.pixel_y), time = animation_time / 2, easing = CIRCULAR_EASING|EASE_IN)
		return
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/atom, balloon_alert), owner, "Use [name] again to cancel"), LANDSLIDE_WIND_UP)
	addtimer(CALLBACK(src, PROC_REF(RegisterSignals), owner, list(COMSIG_MOB_CLICK_RIGHT, COMSIG_MOB_CLICK_SHIFT, COMSIG_MOB_MIDDLE_CLICK), PROC_REF(cancel_charge)), LANDSLIDE_WIND_UP)
	addtimer(CALLBACK(src, PROC_REF(do_charge), owner_turf, direction, charge_damage, which_step), LANDSLIDE_WIND_UP)

/// Cancels the ability.
/datum/action/ability/activable/xeno/landslide/proc/cancel_charge(datum/source)
	SIGNAL_HANDLER
	end_charge(LANDSLIDE_ENDED_CANCELLED)

/**
 * Gets a list of the turfs affected by this ability, based on direction and range.
 * * origin_turf: The origin turf from which to start checking.
 * * direction: The direction to check in.
 * * range: The range in tiles to limit our checks to.
*/
/datum/action/ability/activable/xeno/landslide/proc/get_affected_turfs(turf/origin_turf, direction, range)
	if(!origin_turf || !direction || !range)
		return
	var/list/turf/turfs_list = list(origin_turf)
	var/list/turf/turfs_to_check = list()
	for(var/turf/turf_to_check AS in get_line(origin_turf, get_ranged_target_turf(origin_turf, direction, range)))
		if(turf_to_check in turfs_list)
			continue
		turfs_to_check += turf_to_check
	for(var/turf/turf_to_check AS in turfs_to_check)
		for(var/turf/adjacent_turf AS in get_adjacent_open_turfs(turf_to_check))
			if((adjacent_turf in turfs_to_check) || (adjacent_turf in turfs_list))
				continue
			turfs_to_check += adjacent_turf
	for(var/turf/turf_to_check AS in turfs_to_check)
		if(LinkBlocked(origin_turf, turf_to_check) || !line_of_sight(origin_turf, turf_to_check, range))
			continue
		turfs_list += turf_to_check
	return turfs_list

/**
 * Moves the user in the specified direction. This simulates movement by using step() and repeatedly calling itself.
 * Will repeatedly check a 3x1 rectangle in front of the user, applying its effects to valid targets and stopping early if the path is blocked.
 * * owner_turf: The turf where the owner is.
 * * direction: The direction to move in.
 * * damage: The damage we will deal to valid targets.
 * * which_step: Used to determine the initial positioning of visual effects.
*/
/datum/action/ability/activable/xeno/landslide/proc/do_charge(turf/owner_turf, direction, damage, which_step)
	if(!ability_active || !direction)
		return
	if(owner.stat || owner.lying_angle)
		end_charge()
		return
	if(owner.pulling)
		owner.stop_pulling()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.plasma_stored < ability_cost)
		end_charge(LANDSLIDE_ENDED_NO_PLASMA)
		return
	succeed_activate()
	var/turf/direct_turf = get_step(owner, direction)
	var/list/turf/target_turfs = list(direct_turf)
	target_turfs += get_step(xeno_owner, turn(direction, 45))
	target_turfs += get_step(xeno_owner, turn(direction, -45))
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/affected_atom AS in target_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(affected_living.stat == DEAD)
					continue
				if(xeno_owner.issamexenohive(affected_living) && !affected_living.lying_angle)
					if(affected_living in direct_turf)
						step_away(affected_living, xeno_owner, 2, 1)
					continue
				hit_living(affected_living, damage)
			if(isobj(affected_atom))
				if(isearthpillar(affected_atom))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					affected_pillar.throw_pillar(get_ranged_target_turf(xeno_owner, xeno_owner.dir, 7), TRUE)
					continue
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mecha = affected_atom
					affected_mecha.take_damage(damage * LANDSLIDE_DAMAGE_MECHA_MODIFIER, MELEE)
					continue
				var/obj/affected_object = affected_atom
				if(!affected_object.density || affected_object.allow_pass_flags & PASS_MOB || affected_object.resistance_flags & INDESTRUCTIBLE)
					continue
				hit_object(affected_object)
	if(LinkBlocked(owner_turf, direct_turf))
		playsound(direct_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 40, TRUE)
		xeno_owner.do_attack_animation(direct_turf)
		addtimer(CALLBACK(src, PROC_REF(end_charge)), LANDSLIDE_ENDING_COLLISION_DELAY)
		return
	which_step = !which_step
	step(xeno_owner, direction, 1)
	playsound(owner_turf, "behemoth_step_sounds", 40)
	new /obj/effect/temp_visual/behemoth/crack/landslide(owner_turf, direction, which_step)
	new /obj/effect/temp_visual/behemoth/landslide/dust/charge(owner_turf, direction)
	addtimer(CALLBACK(src, PROC_REF(do_charge), get_turf(xeno_owner), direction, damage, which_step), LANDSLIDE_STEP_DELAY)

/**
 * Moves the user in the specified direction. This simulates movement by using step() and repeatedly calling itself.
 * Will repeatedly check a 3x1 rectangle in front of the user, applying its effects to valid targets and stopping early if the path is blocked.
 * * direction: The direction to move in.
 * * damage: The damage we will deal to valid targets.
 * * speed: The speed at which we move. This is reduced when we're nearing our destination, to simulate a slow-down effect.
 * * steps_to_take: The amount of steps needed to reach our destination. This is used to determine when to end the charge,
*/
/datum/action/ability/activable/xeno/landslide/proc/enhanced_do_charge(direction, damage, speed, steps_to_take)
	if(!ability_active || !direction)
		return
	if(owner.stat || owner.lying_angle)
		end_charge()
		return
	if(owner.pulling)
		owner.stop_pulling()
	var/owner_turf = get_turf(owner)
	var/direct_turf = get_step(owner, direction)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(steps_to_take <= 0 || xeno_owner.wrath_stored < ability_cost)
		if(LinkBlocked(owner_turf, direct_turf))
			playsound(direct_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 40, TRUE)
			xeno_owner.do_attack_animation(direct_turf)
		new /obj/effect/temp_visual/behemoth/crack/landslide(get_turf(owner), direction, pick(1, 2))
		end_charge()
		return
	succeed_activate()
	var/list/turf/target_turfs = list(direct_turf)
	target_turfs += get_step(xeno_owner, turn(direction, 45))
	target_turfs += get_step(xeno_owner, turn(direction, -45))
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/affected_atom AS in target_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				hit_living(affected_living, damage)
			if(isobj(affected_atom))
				if(isearthpillar(affected_atom))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					affected_pillar.throw_pillar(get_ranged_target_turf(xeno_owner, xeno_owner.dir, 7), TRUE)
					continue
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mecha = affected_atom
					affected_mecha.take_damage(damage * LANDSLIDE_DAMAGE_MECHA_MODIFIER, MELEE)
					continue
				var/obj/affected_object = affected_atom
				if(!affected_object.density || affected_object.allow_pass_flags & PASS_MOB || affected_object.resistance_flags & INDESTRUCTIBLE)
					continue
				hit_object(affected_object)
	steps_to_take--
	step(xeno_owner, direction, 1)
	if(steps_to_take <= 2)
		speed += 0.5
		new /obj/effect/temp_visual/behemoth/landslide/dust/charge(owner_turf, direction)
	addtimer(CALLBACK(src, PROC_REF(enhanced_do_charge), direction, damage, speed, steps_to_take), speed)

/**
 * Ends the charge.
 * * reason: If specified, determines the reason why the charge ended, and does the respective balloon alert. Leave empty for no reason.
*/
/datum/action/ability/activable/xeno/landslide/proc/end_charge(reason)
	ability_active = FALSE
	UnregisterSignal(owner, COMSIG_MOB_CLICK_RIGHT, COMSIG_MOB_CLICK_SHIFT, COMSIG_MOB_MIDDLE_CLICK)
	REMOVE_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, JUMP_COMPONENT)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.behemoth_charging = FALSE
	if(!xeno_owner.lying_angle)
		xeno_owner.set_canmove(TRUE)
	add_cooldown()
	switch(reason)
		if(LANDSLIDE_ENDED_CANCELLED) // The user manually cancelled the ability at some point during its use.
			xeno_owner.balloon_alert(xeno_owner, "Cancelled")
		if(LANDSLIDE_ENDED_NO_PLASMA) // During the charge, the user did not have enough plasma to maintain the ability.
			xeno_owner.balloon_alert(xeno_owner, "Insufficient plasma")

/**
 * Applies several effects to a living target.
 * * living_target: The targeted living mob.
 * * damage: The damage inflicted by related effects.
*/
/datum/action/ability/activable/xeno/landslide/proc/hit_living(mob/living/living_target, damage)
	if(!living_target || !damage)
		return
	if(living_target.buckled)
		living_target.buckled.unbuckle_mob(living_target, TRUE)
	if(!living_target.lying_angle)
		living_target.Knockdown(LANDSLIDE_KNOCKDOWN_DURATION)
		new /obj/effect/temp_visual/behemoth/landslide/hit(get_turf(living_target))
		playsound(living_target, 'sound/effects/behemoth/landslide_hit_mob.ogg', 30, TRUE)
	living_target.emote("scream")
	shake_camera(living_target, 1, 0.8)
	living_target.apply_damage(damage, BRUTE, blocked = MELEE)

/**
 * Attempts to deconstruct the object in question if possible.
 * * object_target: The targeted object.
*/
/datum/action/ability/activable/xeno/landslide/proc/hit_object(obj/object_target)
	if(!object_target)
		return
	var/object_turf = get_turf(object_target)
	if(istype(object_target, /obj/machinery/vending))
		var/obj/machinery/vending/vending_target = object_target
		playsound(object_turf, 'sound/effects/meteorimpact.ogg', 30, TRUE)
		new /obj/effect/temp_visual/behemoth/landslide/hit(object_turf)
		vending_target.tip_over()
		return
	if(istype(object_target, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/tank_target = object_target
		tank_target.explode()
		return
	if(istype(object_target, /obj/structure/mineral_door/resin))
		var/obj/structure/mineral_door/resin/resin_door = object_target
		resin_door.toggle_state()
		return
	if(object_target.obj_integrity <= LANDSLIDE_OBJECT_INTEGRITY_THRESHOLD || istype(object_target, /obj/structure/closet))
		playsound(object_turf, 'sound/effects/meteorimpact.ogg', 30, TRUE)
		new /obj/effect/temp_visual/behemoth/landslide/hit(object_turf)
		if(istype(object_target, /obj/structure/window/framed))
			var/obj/structure/window/framed/framed_window = object_target
			framed_window.deconstruct(FALSE, FALSE)
			return
		object_target.deconstruct(FALSE)

/**
 * Changes the maximum amount of charges the ability can have.
 * This will also adjust the current amount of charges to account for the new difference, be it positive or negative.
 * * amount: The new amount of maximum charges.
*/
/datum/action/ability/activable/xeno/landslide/proc/change_maximum_charges(amount)
	if(!amount)
		return
	maximum_charges = amount
	current_charges = maximum_charges
	clear_cooldown()


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_WIND_UP 1.6 SECONDS
#define EARTH_RISER_RANGE 3

/obj/effect/temp_visual/behemoth/crack/earth_riser/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x += 13
			pixel_y -= 11
		if(SOUTH)
			pixel_x -= 10
			pixel_y -= 11
		if(WEST)
			pixel_x -= 26
			pixel_y -= 12
		if(EAST)
			pixel_x += 32
			pixel_y -= 13

/datum/action/ability/activable/xeno/earth_riser
	name = "Earth Riser"
	action_icon_state = "earth_riser"
	desc = "Raise a pillar of earth at the selected location. This solid structure can be used for defense, and it interacts with other abilities for offensive usage. The pillar can be launched by click-dragging it in a direction. Alternate use destroys active pillars, starting with the oldest one."
	ability_cost = 30
	cooldown_duration = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EARTH_RISER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE,
	)
	/// Maximum amount of Earth Pillars that this ability can have.
	var/maximum_pillars = 1
	/// List that contains all Earth Pillars created by this ability.
	var/list/obj/structure/earth_pillar/active_pillars = list()

/datum/action/ability/activable/xeno/earth_riser/on_cooldown_finish()
	owner.balloon_alert(owner, "[name] ready ([length(active_pillars)]/[maximum_pillars])")
	return ..()

/datum/action/ability/activable/xeno/earth_riser/give_action(mob/living/L)
	. = ..()
	var/mutable_appearance/counter_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	counter_maptext.pixel_x = 16
	counter_maptext.pixel_y = -4
	counter_maptext.maptext = MAPTEXT("[length(active_pillars)]/[maximum_pillars]")
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = counter_maptext

/datum/action/ability/activable/xeno/earth_riser/remove_action(mob/living/carbon/xenomorph/X)
	. = ..()
	button.cut_overlay(visual_references[VREF_MUTABLE_EARTH_PILLAR])
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = null
	QDEL_LIST(active_pillars)

/datum/action/ability/activable/xeno/earth_riser/update_button_icon()
	button.cut_overlay(visual_references[VREF_MUTABLE_EARTH_PILLAR])
	var/mutable_appearance/number = visual_references[VREF_MUTABLE_EARTH_PILLAR]
	number.maptext = MAPTEXT("[length(active_pillars)]/[maximum_pillars]")
	visual_references[VREF_MUTABLE_EARTH_PILLAR] = number
	button.add_overlay(visual_references[VREF_MUTABLE_EARTH_PILLAR])
	return ..()

/datum/action/ability/activable/xeno/earth_riser/alternate_action_activate()
	if(!length(active_pillars))
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "No active pillars")
		return
	add_cooldown(2 SECONDS)
	var/obj/structure/earth_pillar/oldest_pillar = popleft(active_pillars)
	qdel(oldest_pillar)
	update_button_icon()

/datum/action/ability/activable/xeno/earth_riser/use_ability(atom/target)
	. = ..()
	if(length(active_pillars) >= maximum_pillars)
		owner.balloon_alert(owner, "Maximum amount of pillars reached")
		return
	var/turf/owner_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	if(!line_of_sight(owner, target, EARTH_RISER_RANGE) || LinkBlocked(owner_turf, target_turf))
		owner.balloon_alert(owner, "Out of range")
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/ability/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/behemoth_roll]
	if(behemoth_roll_action?.charge_ability_on)
		behemoth_roll_action.charge_off()
	playsound(target_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 30, TRUE)
	new /obj/effect/temp_visual/behemoth/stomp/west(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf, owner.dir)
	do_warning(xeno_owner, list(target_turf), EARTH_RISER_WIND_UP)
	addtimer(CALLBACK(src, PROC_REF(do_ability), target_turf), EARTH_RISER_WIND_UP)
	add_cooldown(EARTH_RISER_WIND_UP + 0.1 SECONDS)
	succeed_activate()

/// Checks if there's any living mobs in the target turf, displaces them if so, then creates a new Earth Pillar and adds it to the list of active pillars.
/datum/action/ability/activable/xeno/earth_riser/proc/do_ability(turf/target_turf)
	if(!target_turf)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		step_away(affected_living, target_turf, 1, 2)
	active_pillars += new /obj/structure/earth_pillar(target_turf, xeno_owner)
	update_button_icon()

/**
 * Changes the maximum amount of Earth Pillars that can be had.
 * If the user has more Earth Pillars active than the new maximum, it will destroy them, from oldest to newest, until meeting the new amount.
*/
/datum/action/ability/activable/xeno/earth_riser/proc/change_maximum_pillars(amount)
	if(!amount)
		return
	maximum_pillars = amount
	if(!length(active_pillars))
		return
	while(length(active_pillars) > maximum_pillars)
		var/obj/structure/earth_pillar/oldest_pillar = popleft(active_pillars)
		new /obj/effect/temp_visual/behemoth/earth_pillar/broken(oldest_pillar.loc)
		playsound(oldest_pillar.loc, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 30, TRUE)
		qdel(oldest_pillar)
	update_button_icon()


// ***************************************
// *********** Seismic Fracture
// ***************************************
#define SEISMIC_FRACTURE_WIND_UP 1.3 SECONDS
#define SEISMIC_FRACTURE_RANGE 4
#define SEISMIC_FRACTURE_ATTACK_RADIUS 2
#define SEISMIC_FRACTURE_ATTACK_RADIUS_ENHANCED 5
#define SEISMIC_FRACTURE_ATTACK_RADIUS_EARTH_PILLAR 2
#define SEISMIC_FRACTURE_ENHANCED_DELAY 1 SECONDS
#define SEISMIC_FRACTURE_PARALYZE_DURATION 1 SECONDS
#define SEISMIC_FRACTURE_DAMAGE_MULTIPLIER 1.2
#define SEISMIC_FRACTURE_DAMAGE_MECHA_MODIFIER 10

/obj/effect/temp_visual/behemoth/seismic_fracture
	icon = 'icons/effects/64x64.dmi'
	icon_state = "seismic_fracture"
	duration = 1 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	pixel_y = 8

/obj/effect/temp_visual/behemoth/seismic_fracture/Initialize(mapload, fade_out = TRUE)
	. = ..()
	if(!fade_out)
		return
	animate(src, alpha = 0, time = duration, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/seismic_fracture/enhanced
	icon = 'icons/effects/128x128.dmi'
	icon_state = "seismic_fracture_enhanced"
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -49
	pixel_y = -5

/obj/effect/temp_visual/behemoth/crack/seismic_fracture/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x -= 13
			pixel_y -= 11
		if(SOUTH)
			pixel_x += 10
			pixel_y -= 11
		if(WEST)
			pixel_x -= 12
			pixel_y -= 12
		if(EAST)
			pixel_x += 19
			pixel_y -= 12

/obj/effect/temp_visual/shockwave/enhanced/Initialize(mapload, radius, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x -= 11
			pixel_y -= 6
		if(SOUTH)
			pixel_x += 11
			pixel_y -= 7
		if(WEST)
			pixel_x -= 10
			pixel_y -= 8
		if(EAST)
			pixel_x += 18
			pixel_y -= 8

/datum/action/ability/activable/xeno/seismic_fracture
	name = "Seismic Fracture"
	action_icon_state = "seismic_fracture"
	desc = "Blast the earth around the selected location, inflicting heavy damage in a large radius."
	ability_cost = 50
	cooldown_duration = 20 SECONDS
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SEISMIC_FRACTURE,
	)

/datum/action/ability/activable/xeno/seismic_fracture/on_cooldown_finish()
	owner.balloon_alert(owner, "[name] ready")
	return ..()

/datum/action/ability/activable/xeno/seismic_fracture/use_ability(atom/target)
	. = ..()
	if(!line_of_sight(owner, target, SEISMIC_FRACTURE_RANGE))
		owner.balloon_alert(owner, "Out of range")
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/ability/xeno_action/ready_charge/behemoth_roll/behemoth_roll_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/ready_charge/behemoth_roll]
	if(behemoth_roll_action?.charge_ability_on)
		behemoth_roll_action.charge_off()
	var/target_turf = get_turf(target)
	var/owner_turf = get_turf(xeno_owner)
	new /obj/effect/temp_visual/behemoth/stomp/east(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf, owner.dir)
	playsound(target_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 30, TRUE)
	var/datum/action/ability/xeno_action/primal_wrath/primal_wrath_action = xeno_owner.actions_by_path[/datum/action/ability/xeno_action/primal_wrath]
	do_ability(target_turf, SEISMIC_FRACTURE_WIND_UP, primal_wrath_action?.ability_active? TRUE : FALSE)

/**
 * Handles the warnings, calling the following procs, as well as any alterations caused by Primal Wrath.
 * This has to be cut off from use_ability() to optimize code, due to an interaction with Earth Pillars.
 * Earth Pillars caught in the range of Seismic Fracture reflect the attack by calling this proc again.
 * * target_turf: The targeted turf.
 * * wind_up: The wind-up duration before the ability happens.
 * * enhanced: Whether this is enhanced by Primal Wrath or not.
 * * earth_riser: If this proc was called by an Earth Pillar, its attack radius is reduced.
*/
/datum/action/ability/activable/xeno/seismic_fracture/proc/do_ability(turf/target_turf, wind_up, enhanced, earth_pillar)
	if(!target_turf)
		return
	var/list/turf/turfs_to_attack = filled_turfs(target_turf, earth_pillar? SEISMIC_FRACTURE_ATTACK_RADIUS_EARTH_PILLAR : SEISMIC_FRACTURE_ATTACK_RADIUS, include_edge = FALSE, bypass_window = TRUE, projectile = TRUE)
	if(!length(turfs_to_attack))
		owner.balloon_alert(owner, "Unable to use here")
		return
	if(wind_up <= 0)
		do_attack(turfs_to_attack, enhanced, TRUE)
		return
	add_cooldown()
	succeed_activate()
	do_warning(owner, turfs_to_attack, wind_up)
	addtimer(CALLBACK(src, PROC_REF(do_attack), turfs_to_attack, enhanced), wind_up)
	if(!enhanced)
		return
	new /obj/effect/temp_visual/shockwave/enhanced(get_turf(owner), SEISMIC_FRACTURE_ATTACK_RADIUS, owner.dir)
	playsound(owner, 'sound/effects/behemoth/landslide_roar.ogg', 40, TRUE)
	var/list/turf/extra_turfs_to_warn = filled_turfs(target_turf, SEISMIC_FRACTURE_ATTACK_RADIUS_ENHANCED, bypass_window = TRUE, projectile = TRUE)
	for(var/turf/extra_turf_to_warn AS in extra_turfs_to_warn)
		if(isclosedturf(extra_turf_to_warn))
			extra_turfs_to_warn -= extra_turf_to_warn
	if(length(extra_turfs_to_warn) && length(turfs_to_attack))
		extra_turfs_to_warn -= turfs_to_attack
	do_warning(owner, extra_turfs_to_warn, wind_up + SEISMIC_FRACTURE_ENHANCED_DELAY)
	var/list/turf/extra_turfs = filled_turfs(target_turf, SEISMIC_FRACTURE_ATTACK_RADIUS + 1, bypass_window = TRUE, projectile = TRUE)
	if(length(extra_turfs) && length(turfs_to_attack))
		extra_turfs -= turfs_to_attack
	addtimer(CALLBACK(src, PROC_REF(do_attack_extra), target_turf, extra_turfs, turfs_to_attack, enhanced, SEISMIC_FRACTURE_ATTACK_RADIUS_ENHANCED, SEISMIC_FRACTURE_ATTACK_RADIUS_ENHANCED - SEISMIC_FRACTURE_ATTACK_RADIUS), wind_up + SEISMIC_FRACTURE_ENHANCED_DELAY)

/**
 * Checks for any atoms caught in the attack's range, and applies several effects based on the atom's type.
 * * turfs_to_attack: The turfs affected by this proc.
 * * enhanced: Whether this is enhanced or not.
 * * instant: Whether this is done instantly or not.
*/
/datum/action/ability/activable/xeno/seismic_fracture/proc/do_attack(list/turf/turfs_to_attack, enhanced, instant)
	if(!length(turfs_to_attack))
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) * SEISMIC_FRACTURE_DAMAGE_MULTIPLIER
	for(var/turf/target_turf AS in turfs_to_attack)
		if(isclosedturf(target_turf))
			continue
		new /obj/effect/temp_visual/behemoth/crack(target_turf)
		playsound(target_turf, 'sound/effects/behemoth/seismic_fracture_explosion.ogg', 15)
		var/attack_vfx = enhanced? /obj/effect/temp_visual/behemoth/seismic_fracture/enhanced : /obj/effect/temp_visual/behemoth/seismic_fracture
		new attack_vfx(target_turf, enhanced? FALSE : null)
		for(var/atom/movable/affected_atom AS in target_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD || CHECK_BITFIELD(affected_living.status_flags, INCORPOREAL|GODMODE))
					continue
				affected_living.emote("scream")
				shake_camera(affected_living, 1, 0.8)
				affected_living.Paralyze(SEISMIC_FRACTURE_PARALYZE_DURATION)
				affected_living.apply_damage(damage, BRUTE, blocked = MELEE)
				if(instant)
					continue
				affected_living.layer = ABOVE_MOB_LAYER
				animate(affected_living, pixel_y = affected_living.pixel_y + 40, time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW)
				animate(pixel_y = initial(affected_living.pixel_y), time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_IN)
				addtimer(CALLBACK(src, PROC_REF(living_landing), affected_living), SEISMIC_FRACTURE_PARALYZE_DURATION)
			else if(isearthpillar(affected_atom) || ismecha(affected_atom) || istype(affected_atom, /obj/structure/reagent_dispensers/fueltank))
				affected_atom.do_jitter_animation()
				new /obj/effect/temp_visual/behemoth/landslide/hit(affected_atom.loc)
				playsound(affected_atom.loc, get_sfx("behemoth_earth_pillar_hit"), 40)
				if(isearthpillar(affected_atom))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					if(affected_pillar.warning_flashes < initial(affected_pillar.warning_flashes))
						continue
					affected_pillar.seismic_fracture()
					do_ability(target_turf, initial(affected_pillar.warning_flashes) * 10, FALSE)
					continue
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mecha = affected_atom
					affected_mecha.take_damage(damage * SEISMIC_FRACTURE_DAMAGE_MECHA_MODIFIER, MELEE)
					continue
				if(istype(affected_atom, /obj/structure/reagent_dispensers/fueltank))
					var/obj/structure/reagent_dispensers/fueltank/affected_tank = affected_atom
					affected_tank.explode()
					continue

/// Living mobs that were previously caught in the attack's radius are subject to a landing effect. Their invincibility is removed, and they receive a reduced amount of damage.
/datum/action/ability/activable/xeno/seismic_fracture/proc/living_landing(mob/living/affected_living)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	affected_living.layer = initial(affected_living.layer)
	var/landing_damage = (xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier) / 2
	affected_living.apply_damage(landing_damage, BRUTE, blocked = MELEE)
	playsound(affected_living.loc, 'sound/effects/behemoth/seismic_fracture_landing.ogg', 10, TRUE)
	new /obj/effect/temp_visual/behemoth/stomp(affected_living.loc)

/**
 * Handles the additional attacks caused by Primal Wrath. These are done iteratively rather than instantly, with a delay inbetween.
 * * origin_turf: The starting turf.
 * * extra_turfs: Any additional turfs that should be handled.
 * * excepted_turfs: Turfs that should be excepted from this proc.
 * * enhanced: Whether this is enhanced by Primal Wrath or not.
 * * range: The range to cover.
 * * iteration: The current iteration.
*/
/datum/action/ability/activable/xeno/seismic_fracture/proc/do_attack_extra(turf/origin_turf, list/turf/extra_turfs, list/turf/excepted_turfs, enhanced, range, iteration)
	if(!origin_turf || !range || !iteration || iteration > range)
		return
	var/list/turfs_to_attack = list()
	for(var/turf/extra_turf AS in extra_turfs)
		turfs_to_attack += extra_turf
		var/list/turfs_to_check = get_adjacent_open_turfs(extra_turf)
		for(var/turf/turf_to_check AS in turfs_to_check)
			if((turf_to_check in extra_turfs) || (turf_to_check in excepted_turfs) || (turf_to_check in turfs_to_attack))
				continue
			if(!line_of_sight(origin_turf, turf_to_check) || LinkBlocked(origin_turf, turf_to_check, TRUE, TRUE))
				continue
			extra_turfs += turf_to_check
	do_attack(turfs_to_attack, enhanced)
	extra_turfs -= turfs_to_attack
	excepted_turfs += turfs_to_attack
	iteration++
	addtimer(CALLBACK(src, PROC_REF(do_attack_extra), origin_turf, extra_turfs, excepted_turfs, enhanced, range, iteration), SEISMIC_FRACTURE_ENHANCED_DELAY)


// ***************************************
// *********** Primal Wrath
// ***************************************
#define PRIMAL_WRATH_ACTIVATION_DURATION 3 SECONDS // Timed with the sound played.
#define PRIMAL_WRATH_RANGE 12
#define PRIMAL_WRATH_DAMAGE_MULTIPLIER 1.2
#define PRIMAL_WRATH_SPEED_BONUS -0.3
#define PRIMAL_WRATH_DECAY_MULTIPLIER 1.2
#define PRIMAL_WRATH_ACTIVE_DECAY_DIVISION 40
#define PRIMAL_WRATH_GAIN_MULTIPLIER 0.3

/particles/primal_wrath
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = list("wrath_1", "wrath_2", "wrath_3", "wrath_4", "wrath_5", "wrath_6", "wrath_7", "wrath_8", "wrath_9")
	width = 200
	height = 200
	count = 1000
	spawning = 3
	lifespan = 6
	fade = 10
	grow = 0.08
	velocity = list(0, 1)
	position = generator(GEN_NUM, 0, 55, UNIFORM_RAND)
	gravity = list(0, 0.25)
	scale = generator(GEN_NUM, 0.3, 0.5, UNIFORM_RAND)
	rotation = 0
	spin = generator(GEN_NUM, 5, 20)

/obj/effect/temp_visual/shockwave/primal_wrath/Initialize(mapload, radius, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_y += 16
		if(SOUTH)
			pixel_y += 0
		if(WEST)
			pixel_x -= 34
			pixel_y += 6
		if(EAST)
			pixel_x += 39
			pixel_y += 6

/atom/movable/vis_obj/wrath_block
	icon = 'icons/Xeno/castes/behemoth.dmi'
	icon_state = "Behemoth Flashing"

/datum/action/ability/xeno_action/primal_wrath
	name = "Primal Wrath"
	action_icon_state = "primal_wrath"
	desc = "Unleash your wrath. Enhances your abilities, changing their functionality and allowing them to apply a damage over time debuff."
	cooldown_duration = 1 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY|ABILITY_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PRIMAL_WRATH,
	)
	/// Whether Primal Wrath is active or not.
	var/ability_active = FALSE
	/// Whether we are currently roaring or not.
	var/currently_roaring = FALSE
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// Timer that determines when Wrath will start decaying.
	var/decay_time = 60 SECONDS
	/// Base amount of Wrath lost every valid tick.
	var/decay_amount = 10
	/// The overlay used when Primal Wrath blocks fatal damage.
	var/atom/movable/vis_obj/block_overlay

/datum/action/ability/xeno_action/primal_wrath/give_action(mob/living/L)
	. = ..()
	block_overlay = new(null, src)
	owner.vis_contents += block_overlay
	START_PROCESSING(SSprocessing, src)
	RegisterSignals(owner, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(stop_ability))
	RegisterSignals(owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taking_damage))

/datum/action/ability/xeno_action/primal_wrath/remove_action(mob/living/L)
	. = ..()
	stop_ability()

/datum/action/ability/xeno_action/primal_wrath/process()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.hivenumber == XENO_HIVE_FALLEN)
		if(xeno_owner.wrath_stored < xeno_owner.xeno_caste.wrath_max)
			xeno_owner.wrath_stored = xeno_owner.xeno_caste.wrath_max
		return
	if(decay_time > 0)
		decay_time -= 1 SECONDS
		return
	if(ability_active)
		if(xeno_owner.wrath_stored <= 0)
			toggle_buff(FALSE)
			return
		xeno_owner.wrath_stored = max(0, xeno_owner.wrath_stored - round(xeno_owner.xeno_caste.wrath_max / PRIMAL_WRATH_ACTIVE_DECAY_DIVISION))
		return
	if(xeno_owner.wrath_stored <= 0)
		return
	xeno_owner.wrath_stored = max(0, xeno_owner.wrath_stored - decay_amount)
	decay_amount = round(decay_amount * PRIMAL_WRATH_DECAY_MULTIPLIER)

/datum/action/ability/xeno_action/primal_wrath/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.hivenumber != XENO_HIVE_FALLEN)
		if(ability_active || currently_roaring)
			return
		if(xeno_owner.wrath_stored < xeno_owner.xeno_caste.wrath_max - (xeno_owner.xeno_caste.wrath_max * 0.2))
			xeno_owner.balloon_alert(xeno_owner, "Not enough Wrath")
			return
	else if(xeno_owner.hivenumber == XENO_HIVE_FALLEN && ability_active)
		toggle_buff(FALSE)
		return
	toggle_buff(TRUE)
	currently_roaring = TRUE
	xeno_owner.status_flags |= GODMODE
	xeno_owner.fortify = TRUE
	xeno_owner.face_atom(target)
	xeno_owner.set_canmove(FALSE)
	var/owner_turf = get_turf(xeno_owner)
	playsound(owner_turf, 'sound/effects/behemoth/primal_wrath_roar.ogg', 75, TRUE)
	do_ability(owner_turf)
	addtimer(CALLBACK(src, PROC_REF(end_ability)), PRIMAL_WRATH_ACTIVATION_DURATION)
	succeed_activate()
	add_cooldown()

/**
 * Distorts the view of every valid living mob in range.
 * * origin_turf: The source location of this ability.
*/
/datum/action/ability/xeno_action/primal_wrath/proc/do_ability()
	if(!currently_roaring)
		return
	new /obj/effect/temp_visual/shockwave/primal_wrath(get_turf(owner), 4, owner.dir)
	for(var/mob/living/affected_living in cheap_get_humans_near(owner, PRIMAL_WRATH_RANGE) + owner)
		if(!affected_living.hud_used)
			continue
		var/atom/movable/screen/plane_master/floor/floor_plane = affected_living.hud_used.plane_masters["[FLOOR_PLANE]"]
		var/atom/movable/screen/plane_master/game_world/world_plane = affected_living.hud_used.plane_masters["[GAME_PLANE]"]
		if(floor_plane.get_filter("primal_wrath") || world_plane.get_filter("primal_wrath"))
			continue
		var/filter_size = 0.01
		world_plane.add_filter("primal_wrath", 2, radial_blur_filter(filter_size))
		animate(world_plane.get_filter("primal_wrath"), size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		floor_plane.add_filter("primal_wrath", 2, radial_blur_filter(filter_size))
		animate(floor_plane.get_filter("primal_wrath"), size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		ability_check(affected_living, owner)
	addtimer(CALLBACK(src, PROC_REF(do_ability)), 0.1 SECONDS)

/// Ends the ability.
/datum/action/ability/xeno_action/primal_wrath/proc/end_ability()
	currently_roaring = FALSE
	owner.status_flags &= ~GODMODE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.fortify = FALSE
	xeno_owner.set_canmove(TRUE)

/**
 * Checks if the affected target should no longer be affected by the ability.
 * * affected_living: The affected living mob.
 * * xeno_source: The source of the effects.
*/
/datum/action/ability/xeno_action/primal_wrath/proc/ability_check(mob/living/affected_living, mob/living/carbon/xenomorph/xeno_source)
	if(!affected_living || !xeno_source)
		return
	var/atom/movable/screen/plane_master/floor/floor_plane = affected_living.hud_used.plane_masters["[FLOOR_PLANE]"]
	var/atom/movable/screen/plane_master/game_world/world_plane = affected_living.hud_used.plane_masters["[GAME_PLANE]"]
	if(!floor_plane.get_filter("primal_wrath") || !world_plane.get_filter("primal_wrath"))
		return
	if(!currently_roaring || get_dist(affected_living, xeno_source) > PRIMAL_WRATH_RANGE)
		var/resolve_time = 0.2 SECONDS
		animate(floor_plane.get_filter("primal_wrath"), size = 0, time = resolve_time, flags = ANIMATION_PARALLEL)
		animate(world_plane.get_filter("primal_wrath"), size = 0, time = resolve_time, flags = ANIMATION_PARALLEL)
		addtimer(CALLBACK(floor_plane, TYPE_PROC_REF(/atom, remove_filter), "primal_wrath"), resolve_time)
		addtimer(CALLBACK(world_plane, TYPE_PROC_REF(/atom, remove_filter), "primal_wrath"), resolve_time)
		return
	addtimer(CALLBACK(src, PROC_REF(ability_check), affected_living, xeno_source), 0.1 SECONDS)

/// Changes the cost of all actions to use Wrath instead of plasma.
/datum/action/ability/xeno_action/primal_wrath/proc/change_cost(datum/source, datum/action/source_action, action_cost)
	SIGNAL_HANDLER
	if(!ability_active || source_action == src)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.wrath_stored = max(0, xeno_owner.wrath_stored - (action_cost / 2))
	return SUCCEED_ACTIVATE_CANCEL

/**
 * When taking damage, resets decay and returns an amount of Wrath proportional to the damage.
 * If damage taken would kill the user, it is instead reduced, and
 * * source: The source of this proc.
 * * amount: The RAW amount of damage taken.
 * * amount_mod: If provided, this list includes modifiers applied to the damage. This, for example, can be useful for reducing the damage.
*/
/datum/action/ability/xeno_action/primal_wrath/proc/taking_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || owner.stat || owner.lying_angle)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(ability_active)
		if(amount >= xeno_owner.health)
			var/damage_amount = (amount - xeno_owner.health)
			xeno_owner.wrath_stored = max(0, xeno_owner.wrath_stored - damage_amount)
			amount_mod += damage_amount + 1
		if(xeno_owner.wrath_stored <= 0)
			toggle_buff(FALSE)
		return
	decay_time = initial(decay_time)
	decay_amount = initial(decay_amount)
	if(xeno_owner.wrath_stored < xeno_owner.xeno_caste.wrath_max)
		xeno_owner.wrath_stored = min(xeno_owner.wrath_stored + (amount * PRIMAL_WRATH_GAIN_MULTIPLIER), xeno_owner.xeno_caste.wrath_max)

/**
 * Toggles the buff, which increases the owner's damage based on a multiplier, and gives them a particle effect.
 * * toggle: Whether to toggle it on or off.
 * * multiplier: The multiplier applied to the owner's damage.
*/
/datum/action/ability/xeno_action/primal_wrath/proc/toggle_buff(toggle)
	ability_active = !ability_active
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/ability/activable/xeno/landslide/landslide_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/landslide]
	var/datum/action/ability/activable/xeno/earth_riser/earth_riser_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(!toggle)
		set_toggle(FALSE)
		QDEL_NULL(particle_holder)
		decay_time = initial(decay_time)
		xeno_owner.xeno_melee_damage_modifier = initial(xeno_owner.xeno_melee_damage_modifier)
		xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_BEHEMOTH_PRIMAL_WRATH)
		landslide_action?.change_maximum_charges(1)
		earth_riser_action?.change_maximum_pillars(1)
		owner.balloon_alert(owner, "Primal Wrath ended")
		UnregisterSignal(xeno_owner, COMSIG_XENO_ACTION_SUCCEED_ACTIVATE)
		return
	set_toggle(TRUE)
	decay_time = 4 SECONDS
	decay_amount = initial(decay_amount)
	particle_holder = new(xeno_owner, /particles/primal_wrath)
	particle_holder.pixel_x = 3
	particle_holder.pixel_y = -20
	xeno_owner.xeno_melee_damage_modifier = PRIMAL_WRATH_DAMAGE_MULTIPLIER
	xeno_owner.add_movespeed_modifier(MOVESPEED_ID_BEHEMOTH_PRIMAL_WRATH, TRUE, 0, NONE, TRUE, PRIMAL_WRATH_SPEED_BONUS)
	landslide_action?.change_maximum_charges(3)
	landslide_action?.clear_cooldown()
	earth_riser_action?.change_maximum_pillars(3)
	earth_riser_action?.clear_cooldown()
	var/datum/action/ability/activable/xeno/seismic_fracture/seismic_fracture_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/seismic_fracture]
	seismic_fracture_action?.clear_cooldown()
	RegisterSignal(xeno_owner, COMSIG_XENO_ACTION_SUCCEED_ACTIVATE, PROC_REF(change_cost))

/// Stops processing, and unregisters related signals.
/datum/action/ability/xeno_action/primal_wrath/proc/stop_ability(datum/source)
	SIGNAL_HANDLER
	if(ability_active)
		toggle_buff(FALSE)
	STOP_PROCESSING(SSprocessing, src)
	if(owner)
		UnregisterSignal(owner, list(COMSIG_QDELETING, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))


// ***************************************
// *********** Earth Pillar (also see: Earth Riser)
// ***************************************
/particles/earth_pillar
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "behemoth_smoke"
	width = 100
	height = 100
	count = 1000
	spawning = 3
	gravity = list(0, 0.15)
	lifespan = 15
	fade = 15
	position = generator(GEN_SPHERE, 0, 17, UNIFORM_RAND)
	velocity = list(0, 0.2)
	scale = generator(GEN_NUM, 0.3, 0.5, UNIFORM_RAND)
	grow = 0.05
	spin = generator(GEN_NUM, 10, 20)

/obj/effect/temp_visual/behemoth/earth_pillar
	duration = 2 SECONDS
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/behemoth/earth_pillar/projectile
	icon = 'icons/effects/128x128.dmi'
	icon_state = "earth_pillar_exploded"
	duration = 1.6 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -48
	pixel_y = -41

/obj/effect/temp_visual/behemoth/earth_pillar/projectile/Initialize(mapload)
	. = ..()
	animate(src, time = duration - 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/earth_pillar/destroyed
	icon = 'icons/effects/128x128.dmi'
	icon_state = "earth_pillar_destroyed"
	duration = 1 SECONDS
	pixel_x = -49
	pixel_y = -38

/obj/effect/temp_visual/behemoth/earth_pillar/destroyed/Initialize(mapload)
	. = ..()
	animate(src, time = 0.3 SECONDS)
	animate(alpha = 0, time = 0.7 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/earth_pillar/broken
	icon = 'icons/effects/96x96.dmi'
	icon_state = "earth_pillar_broken"
	duration = 0.9 SECONDS
	pixel_x = -32
	pixel_y = -29

/obj/effect/temp_visual/behemoth/earth_pillar/broken/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = CIRCULAR_EASING|EASE_OUT)

/obj/structure/earth_pillar
	name = "earth pillar"
	icon = 'icons/effects/effects.dmi'
	icon_state = "earth_pillar_0"
	base_icon_state = "earth_pillar_0"
	layer = ABOVE_LYING_MOB_LAYER
	climbable = TRUE
	climb_delay = 1.5 SECONDS
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	density = TRUE
	max_integrity = 200
	soft_armor = list(MELEE = 25, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 100, FIRE = 100, ACID = 0)
	destroy_sound = 'sound/effects/behemoth/earth_pillar_destroyed.ogg'
	coverage = 128
	/// The xeno owner of this object.
	var/mob/living/carbon/xenomorph/xeno_owner
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// The amount of times a xeno needs to attack this to destroy it.
	var/attacks_to_destroy = 2
	/// The amount of times an Earth Pillar flashes before executing its interaction with Seismic Fracture.
	var/warning_flashes = 2

/obj/structure/earth_pillar/Initialize(mapload, mob/living/carbon/xenomorph/new_owner)
	. = ..()
	xeno_owner = new_owner
	playsound(src, 'sound/effects/behemoth/earth_pillar_rising.ogg', 40, TRUE)
	particle_holder = new(src, /particles/earth_pillar)
	particle_holder.pixel_y = -4
	animate(particle_holder, pixel_y = 4, time = 1.0 SECONDS)
	animate(alpha = 0, time = 0.6 SECONDS)
	QDEL_NULL_IN(src, particle_holder, 1.6 SECONDS)
	do_jitter_animation(jitter_loops = 5)
	RegisterSignals(src, list(COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_EX_ACT, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, COMSIG_ATOM_ATTACKBY), PROC_REF(call_update_icon_state))

/obj/structure/earth_pillar/Destroy()
	playsound(loc, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/broken(loc)
	var/datum/action/ability/activable/xeno/earth_riser/earth_riser_action = xeno_owner?.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	if(earth_riser_action && (src in earth_riser_action.active_pillars))
		earth_riser_action.active_pillars -= src
	xeno_owner = null
	return ..()

/// Calls update_icon_state().
/obj/structure/earth_pillar/proc/call_update_icon_state()
	SIGNAL_HANDLER
	update_icon_state()

/obj/structure/earth_pillar/update_icon_state()
	. = ..()
	if(obj_integrity <= max_integrity * 0.25)
		icon_state = "earth_pillar_3"
		return
	if(obj_integrity <= max_integrity * 0.5)
		icon_state = "earth_pillar_2"
		return
	if(obj_integrity <= max_integrity * 0.75)
		icon_state = "earth_pillar_1"
		return

/obj/structure/earth_pillar/attacked_by(obj/item/I, mob/living/user, def_zone)
	. = ..()
	playsound(src, get_sfx("behemoth_earth_pillar_hit"), 40)
	new /obj/effect/temp_visual/behemoth/landslide/hit(get_turf(src))

// Attacking an Earth Pillar as a xeno has a few possible interactions, based on intent:
// - Harm intent will reduce a counter in this structure. When the counter hits zero, the structure is destroyed, meaning it is much easier to break it as a xeno.
// - Help intent as a Behemoth will trigger an easter egg. Does nothing, just fluff.
/obj/structure/earth_pillar/attack_alien(mob/living/carbon/xenomorph/xeno_user, isrightclick = FALSE)
	var/current_turf = get_turf(src)
	switch(xeno_user.a_intent)
		if(INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
			if(attacks_to_destroy <= 1)
				xeno_user.do_attack_animation(src)
				xeno_user.balloon_alert(xeno_user, "Destroyed")
				new /obj/effect/temp_visual/behemoth/landslide/hit(current_turf)
				qdel(src)
				return TRUE
			attacks_to_destroy--
			xeno_user.do_attack_animation(src)
			do_jitter_animation(jitter_loops = 1)
			playsound(src, get_sfx("behemoth_earth_pillar_hit"), 40)
			xeno_user.balloon_alert(xeno_user, "Attack [attacks_to_destroy] more time(s) to destroy")
			new /obj/effect/temp_visual/behemoth/landslide/hit(current_turf)
			return TRUE
		if(INTENT_HELP)
			if(isxenobehemoth(xeno_user))
				xeno_user.do_attack_animation(src)
				do_jitter_animation(jitter_loops = 1)
				playsound(src, 'sound/effects/behemoth/earth_pillar_eating.ogg', 30, TRUE)
				xeno_user.visible_message(span_xenowarning("\The [xeno_user] eats away at the [src.name]!"), \
				span_xenonotice(pick(
					"We eat away at the stone. It tastes good, as expected of our primary diet.",
					"Mmmmm... Delicious rock. A fitting meal for the hardiest of creatures.",
					"This boulder -- its flavor fills us with glee. Our palate is thoroughly satisfied.",
					"These minerals are tasty! We want more!",
					"Eating this stone makes us think; is our hide tougher? It is. It must be...",
					"A delectable flavor. Just one bite is not enough...",
					"One bite, two bites... why not just finish the whole rock?",
					"The stone. The rock. The boulder. The crag. Its name matters not when we consume it.",
					"We're eating this boulder. It has other uses... Is this really a good idea?",
					"Delicious, delectable, simply exquisite. Just a few more minerals and it'd be perfect...")), null, 5)
				return TRUE
		else return FALSE

/obj/structure/earth_pillar/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(max_integrity / 2)
		if(EXPLODE_LIGHT)
			take_damage(max_integrity / 3)

// When clickdragging an Earth Pillar, it fires it as a projectile to whatever we clickdragged it to.
/obj/structure/earth_pillar/MouseDrop(atom/over_atom)
	throw_pillar(over_atom)

/// Deletes the pillar and creates a projectile on the same tile, to be fired at the target atom.
/obj/structure/earth_pillar/proc/throw_pillar(atom/target_atom, landslide)
	if(!isxeno(usr) || !in_range(src, usr) || target_atom == src || warning_flashes < initial(warning_flashes))
		return
	var/source_turf = get_turf(src)
	playsound(source_turf, get_sfx("behemoth_earth_pillar_hit"), 40)
	new /obj/effect/temp_visual/behemoth/landslide/hit(source_turf)
	var/datum/action/ability/activable/xeno/earth_riser/earth_riser_action = xeno_owner.actions_by_path[/datum/action/ability/activable/xeno/earth_riser]
	earth_riser_action?.add_cooldown()
	qdel(src)
	var/datum/ammo/xeno/earth_pillar/projectile = landslide? GLOB.ammo_list[/datum/ammo/xeno/earth_pillar/landslide] : GLOB.ammo_list[/datum/ammo/xeno/earth_pillar]
	var/obj/projectile/new_projectile = new /obj/projectile(source_turf)
	new_projectile.generate_bullet(projectile)
	new_projectile.fire_at(get_turf(target_atom), usr, null, new_projectile.ammo.max_range, loc_override = source_turf)

/// Seismic Fracture (as in the ability) has a special interaction with any Earth Pillars caught in its attack range.
/// Those Earth Pillars will reflect the same attack in a similar range around it, destroying itself afterwards.
/obj/structure/earth_pillar/proc/seismic_fracture()
	if(warning_flashes <= 0)
		new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(loc)
		qdel(src)
		return
	warning_flashes--
	addtimer(CALLBACK(src, PROC_REF(seismic_fracture)), 1 SECONDS)
	animate(src, color = COLOR_TAN_ORANGE, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(color = COLOR_WHITE, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

// Earth Riser is capable of interacting with existing Earth Pillars to fire a projectile.
// See the Earth Riser ability for specifics.
/datum/ammo/xeno/earth_pillar
	name = "earth pillar"
	icon_state = "earth_pillar"
	ping = null
	bullet_color = COLOR_LIGHT_ORANGE
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS
	shell_speed = 1
	max_range = 10
	damage_falloff = 0
	damage_type = BRUTE
	armor_type = MELEE

/datum/ammo/xeno/earth_pillar/do_at_max_range(turf/hit_turf, obj/projectile/proj)
	return rock_broke(hit_turf, proj)

/datum/ammo/xeno/earth_pillar/on_hit_turf(turf/hit_turf, obj/projectile/proj)
	return rock_broke(hit_turf, proj)

/datum/ammo/xeno/earth_pillar/on_hit_obj(obj/hit_object, obj/projectile/proj)
	if(istype(hit_object, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/hit_tank = hit_object
		hit_tank.explode()
	return rock_broke(get_turf(hit_object), proj)

/datum/ammo/xeno/earth_pillar/on_hit_mob(mob/hit_mob, obj/projectile/proj)
	if(!isxeno(proj.firer) || !isliving(hit_mob))
		return
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/mob/living/hit_living = hit_mob
	if(xeno_firer.issamexenohive(hit_living) || hit_living.stat == DEAD)
		return on_hit_anything(get_turf(hit_mob), proj)
	step_away(hit_living, proj, 1, 1)
	return on_hit_anything(get_turf(hit_mob), proj)

/// VFX + SFX for when the rock doesn't hit anything.
/datum/ammo/xeno/earth_pillar/proc/rock_broke(turf/hit_turf, obj/projectile/proj)
	new /obj/effect/temp_visual/behemoth/earth_pillar/broken(hit_turf)
	playsound(hit_turf, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 30, TRUE)

/// Does some stuff if the rock DOES hit something.
/datum/ammo/xeno/earth_pillar/proc/on_hit_anything(turf/hit_turf, obj/projectile/proj)
	playsound(hit_turf, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(hit_turf)
	if(!isxeno(proj.firer))
		return
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/datum/action/ability/activable/xeno/seismic_fracture/seismic_fracture_action = xeno_firer.actions_by_path[/datum/action/ability/activable/xeno/seismic_fracture]
	seismic_fracture_action?.do_ability(hit_turf, earth_pillar = TRUE)

/datum/ammo/xeno/earth_pillar/landslide/do_at_max_range(turf/hit_turf, obj/projectile/proj)
	return on_hit_anything(hit_turf, proj)

/datum/ammo/xeno/earth_pillar/landslide/on_hit_turf(turf/hit_turf, obj/projectile/proj)
	return on_hit_anything(hit_turf, proj)

/datum/ammo/xeno/earth_pillar/landslide/on_hit_obj(obj/hit_object, obj/projectile/proj)
	. = ..()
	return on_hit_anything(get_turf(hit_object), proj)
