/obj/effect/temp_visual/behemoth
	name = "Behemoth"
	duration = 10 SECONDS

/obj/effect/temp_visual/behemoth/stomp
	icon_state = "behemoth_stomp"
	duration = 0.4 SECONDS
	layer = ABOVE_LYING_MOB_LAYER

/obj/effect/temp_visual/behemoth/stomp/Initialize(mapload)
	. = ..()
	var/matrix/current_matrix = matrix()
	transform = current_matrix.Scale(0.6, 0.6)
	current_matrix.Scale(2.0, 2.0)
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
	color = COLOR_YELLOW

/obj/effect/temp_visual/behemoth/warning/Initialize(mapload, warning_duration)
	. = ..()
	if(warning_duration)
		duration = warning_duration
	animate(src, time = duration - 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/warning/enhanced
	color = COLOR_RED

/obj/effect/temp_visual/behemoth/warning/enhanced/numeric/Initialize(mapload, warning_duration, number)
	. = ..()
	icon_state = "warning_[number]"


// ***************************************
// *********** Global Procs
// ***************************************
#define BEHEMOTH_STOMP_KNOCKDOWN_DURATION 0.8 SECONDS

/// Stomps anyone on the same tile as the user, damaging them and knocking them down.
/proc/do_stomp(owner, turf/target_turf)
	if(!owner || !target_turf)
		return
	playsound(target_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 30, TRUE)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		affected_living.emote("scream")
		shake_camera(affected_living, max(1, BEHEMOTH_STOMP_KNOCKDOWN_DURATION), 1)
		affected_living.Knockdown(BEHEMOTH_STOMP_KNOCKDOWN_DURATION)
		affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 2, BRUTE, blocked = MELEE)

/// Warns nearby players, in any way or form, of the incoming ability and the range it will affect.
/proc/do_warning(owner, list/turf/target_turfs, duration, enhanced, action)
	if(!owner || !length(target_turfs) || !duration)
		return
	var/warning_type = enhanced? /obj/effect/temp_visual/behemoth/warning/enhanced : /obj/effect/temp_visual/behemoth/warning
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/activable/landslide/landslide_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/landslide]
	for(var/turf/target_turf AS in target_turfs)
		playsound(target_turf, 'sound/effects/behemoth/behemoth_rumble.ogg', 15, TRUE)
		for(var/mob/living/target_living in target_turf)
			if(xeno_owner.issamexenohive(target_living) || target_living.stat == DEAD)
				continue
			shake_camera(target_living, max(1, duration), 0.5)
		if(!enhanced || action != landslide_action)
			new warning_type(target_turf, duration)
			continue
		landslide_action.enhanced_warnings += new warning_type(target_turf)

/*
// ***************************************
// *********** Roll
// ***************************************
#define BEHEMOTH_ROLL_WIND_UP 2.5 SECONDS
#define BEHEMOTH_ROLL_MOVEMENT_DELAY 40 //4 seconds

/datum/action/xeno_action/behemoth_roll
	name = "Roll"
	ability_name = "Roll"
	action_icon_state = "4"
	desc = "Curl up into a ball, sacrificing some offensive capabilities in exchange for greater movement speed."
	cooldown_timer = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BEHEMOTH_ROLL,
	)
	var/currently_moving = FALSE
	/// Whether this ability is active or not.
	var/ability_active = FALSE
	/// The direction in which we're rolling.
	var/rolling_direction = null
	/// Counter that determines how long you've been changing directions.
	var/turning_counter = 0
	/// How many steps we've taken.
	var/steps_taken = 0
	/// The maximum amount of steps needed to achieve maximum velocity.
	var/max_steps = 6
	/// The speed bonus we gain per step.
	var/speed_per_step = -0.4
	var/list/keybind_signals = list(COMSIG_KB_MOVEMENT_NORTH_DOWN, COMSIG_KB_MOVEMENT_SOUTH_DOWN, COMSIG_KB_MOVEMENT_WEST_DOWN, COMSIG_KB_MOVEMENT_EAST_DOWN)

/datum/action/xeno_action/behemoth_roll/remove_action(mob/living/L)
	if(ability_active)
		action_activate(FALSE)
	return ..()

/*
#define COMSIG_KB_MOVEMENT_NORTH_DOWN "keybinding_movement_north_down"
#define COMSIG_KB_MOVEMENT_SOUTH_DOWN "keybinding_movement_south_down"
#define COMSIG_KB_MOVEMENT_WEST_DOWN "keybinding_movement_west_down"
#define COMSIG_KB_MOVEMENT_EAST_DOWN "keybinding_movement_east_down"
*/

/datum/action/xeno_action/behemoth_roll/action_activate(toggle)
	if(!ability_active || toggle)
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		if(!do_after(xeno_owner, BEHEMOTH_ROLL_WIND_UP, FALSE, xeno_owner, BUSY_ICON_DANGER,/* \
			extra_checks = CALLBACK(src, TYPE_PROC_REF(/mob, break_do_after_checks), list("health" = xeno_owner.health))*/))
			return
		ability_active = TRUE
		set_toggle(TRUE)
		RegisterSignal(owner, COMSIG_KB_MOVEMENT_NORTH_DOWN, PROC_REF(movement_north))
		RegisterSignal(owner, COMSIG_KB_MOVEMENT_SOUTH_DOWN, PROC_REF(movement_south))
		RegisterSignal(owner, COMSIG_KB_MOVEMENT_WEST_DOWN, PROC_REF(movement_west))
		RegisterSignal(owner, COMSIG_KB_MOVEMENT_EAST_DOWN, PROC_REF(movement_east))
		add_cooldown(2 SECONDS)
		return
	message_admins("finish testing this bitch")
	return
/*
	ability_active = FALSE
	set_toggle(FALSE)
	stop_momentum()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED)
	add_cooldown()
*/

/datum/action/xeno_action/activable/landslide/proc/movement_north(datum/source)
	if(currently_moving)
		return
	do_movement(NORTH, BEHEMOTH_ROLL_MOVEMENT_DELAY, TRUE)

/datum/action/xeno_action/activable/landslide/proc/movement_south(datum/source)
	if(currently_moving)
		return
	do_movement(SOUTH, BEHEMOTH_ROLL_MOVEMENT_DELAY, TRUE)

/datum/action/xeno_action/activable/landslide/proc/movement_west(datum/source)
	if(currently_moving)
		return
	do_movement(WEST, BEHEMOTH_ROLL_MOVEMENT_DELAY, TRUE)

/datum/action/xeno_action/activable/landslide/proc/movement_west(datum/source)
	if(currently_moving)
		return
	do_movement(EAST, BEHEMOTH_ROLL_MOVEMENT_DELAY, TRUE)

/datum/action/xeno_action/activable/landslide/proc/do_movement(direction, movement_delay, voluntary)
	message_admins("do_movement([source_keybind], [direction])")
	currently_moving = TRUE
	if(owner.stat || !ability_active)
		end_movement()
		return
	step(owner, direction, 1)
	if(steps_taken < max_steps)
		steps_taken++
	addtimer(CALLBACK(src, PROC_REF(check_movement), direction, movement_delay), clamp(movement_delay - (steps_taken * 2.5), 0.1, BEHEMOTH_ROLL_MOVEMENT_DELAY))

/datum/action/xeno_action/behemoth_roll/proc/check_movement(direction, movement_delay)
	for(var/movement_keybind in movement_keybinds)
		if(SEND_SIGNAL(owner, movement_keybind) & COMSIG_KB_ACTIVATED)
			return do_movement(selected_direction(movement_keybind), movement_delay, TRUE)
	do_movement(direction, movement_delay, FALSE)

/datum/action/xeno_action/behemoth_roll/proc/selected_direction(keybind)
	switch(keybind)
		if(COMSIG_KB_MOVEMENT_NORTH_DOWN)
			return NORTH
		if(COMSIG_KB_MOVEMENT_SOUTH_DOWN)
			return SOUTH
		if(COMSIG_KB_MOVEMENT_WEST_DOWN)
			return WEST
		if(COMSIG_KB_MOVEMENT_EAST_DOWN)
			return EAST
*/


// ***************************************
// *********** Landslide
// ***************************************
#define LANDSLIDE_WIND_UP 1.5 SECONDS
#define LANDSLIDE_RANGE 7
#define LANDSLIDE_STEP_DELAY 0.25 SECONDS
#define LANDSLIDE_ENDING_COLLISION_DELAY 0.4 SECONDS
#define LANDSLIDE_KNOCKDOWN_DURATION 1 SECONDS
#define LANDSLIDE_CHARGE_DAMAGE_ADJACENT_MODIFIER 0.5
#define LANDSLIDE_DAMAGE_MECHA_MODIFIER 20
#define LANDSLIDE_DAMAGE_OBJECT_MODIFIER 8
#define LANDSLIDE_DAMAGE_TURF_MODIFIER 30

#define LANDSLIDE_ENDED_CANCELLED (1<<0)
#define LANDSLIDE_ENDED_NO_PLASMA (1<<1)
#define LANDSLIDE_ENDED_NO_SELECTION (1<<2)

#define LANDSLIDE_ENHANCED_WAIT_TIME 10 SECONDS
#define LANDSLIDE_ENHANCED_WAIT_DELAY 2 SECONDS
#define LANDSLIDE_ENHANCED_POSSIBLE_SELECTIONS 3
#define LANDSLIDE_ENHANCED_STEP_DELAY 0.05 SECONDS
#define LANDSLIDE_ENHANCED_CHARGE_DELAY 0.4 SECONDS

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

/datum/action/xeno_action/activable/landslide
	name = "Landslide"
	ability_name = "Landslide"
	action_icon_state = "headbutt"
	desc = "Rush forward in the selected direction, damaging enemies caught in a wide path."
	plasma_cost = 2.5 // This is deducted per step taken during the ability.
	cooldown_timer = 25 SECONDS
	target_flags = XABB_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LANDSLIDE,
	)
	/// Whether this ability is currently active or not.
	var/ability_active = FALSE
	/// List containing possible sound effects that are played during this ability.
	var/list/possible_step_sounds = list(
		'sound/effects/alien_footstep_large1.ogg',
		'sound/effects/alien_footstep_large2.ogg',
		'sound/effects/alien_footstep_large3.ogg')
	/// List containing the selected turfs for the Enhanced version of this ability.
	var/list/turf/enhanced_turfs = list()
	/// List containing the warnings in the selected turfs for the Enhanced version of this ability.
	var/list/turf/enhanced_warnings = list()

/datum/action/xeno_action/activable/landslide/on_cooldown_finish()
	owner.balloon_alert(owner, "[ability_name] ready")
	return ..()

/datum/action/xeno_action/activable/landslide/use_ability(atom/target)
	if(!target)
		return
	if(ability_active)
		end_charge(LANDSLIDE_ENDED_CANCELLED)
		return
	var/turf/owner_turf = get_turf(owner)
	var/direction = get_cardinal_dir(owner, target)
	if(LinkBlocked(owner_turf, get_step(owner, direction)) || owner_turf == get_turf(target))
		owner.balloon_alert(owner, "No space")
		return
	ability_active = TRUE
	owner.dir = direction
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	playsound(owner, 'sound/effects/behemoth/landslide_roar.ogg', 40, TRUE)
	var/which_step = pick(0, 1)
	new /obj/effect/temp_visual/behemoth/landslide/dust(owner_turf, direction, which_step)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/primal_wrath/primal_wrath_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/primal_wrath]
	if(primal_wrath_action?.ability_active)
		add_cooldown(LANDSLIDE_WIND_UP)
		enhanced_turfs += owner_turf
		enhanced_check_charge()
		RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(enhanced_prepare_charge))
		return
	add_cooldown(5 SECONDS)
	do_warning(xeno_owner, get_affected_turfs(owner_turf, direction, LANDSLIDE_RANGE), LANDSLIDE_WIND_UP + 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(do_charge), owner_turf, direction, xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, which_step), LANDSLIDE_WIND_UP)

/** Gets a list of the turfs affected by this ability, based on direction and range.
* * origin_turf: The origin turf from which to start checking.
* * direction: The direction to check in.
* * range: The range in tiles to limit our checks to.
*/
/datum/action/xeno_action/activable/landslide/proc/get_affected_turfs(turf/origin_turf, direction, range)
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

/** Moves the user in the specified direction. This simulates movement by using step() and repeatedly calling itself.
* Will repeatedly check a 3x1 rectangle in front of the user, applying its effects to valid targets and stopping early if the path is blocked.
* * owner_turf: The turf where the owner is.
* * direction: The direction to move in.
* * damage: The damage we will deal to valid targets.
* * which_step: Used to determine the initial positioning of visual effects.
*/
/datum/action/xeno_action/activable/landslide/proc/do_charge(turf/owner_turf, direction, damage, which_step)
	if(!ability_active || !direction)
		return
	if(owner.stat)
		end_charge()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.plasma_stored < plasma_cost)
		end_charge(LANDSLIDE_ENDED_NO_PLASMA)
		return
	succeed_activate()
	var/turf/direct_turf = get_step(owner, direction)
	if(iswallturf(direct_turf))
		var/turf/closed/wall/affected_wall = direct_turf
		if(affected_wall.wall_integrity <= damage * LANDSLIDE_DAMAGE_TURF_MODIFIER && affected_wall.resistance_flags != INDESTRUCTIBLE)
			playsound(direct_turf, 'sound/effects/meteorimpact.ogg', 30, TRUE)
			affected_wall.dismantle_wall()
	var/list/turf/target_turfs = list(direct_turf)
	target_turfs += get_step(xeno_owner, turn(direction, 45))
	target_turfs += get_step(xeno_owner, turn(direction, -45))
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/affected_atom AS in target_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				hit_living(affected_living, direct_turf, damage)
			if(!(affected_atom in direct_turf))
				continue
			if(isobj(affected_atom))
				var/obj/affected_object = affected_atom
				hit_object(affected_object, damage)
	if(LinkBlocked(owner_turf, direct_turf))
		ending_hit(direct_turf, damage)
		shake_camera(xeno_owner, 1, 0.5)
		addtimer(CALLBACK(src, PROC_REF(end_charge)), LANDSLIDE_ENDING_COLLISION_DELAY)
		return
	which_step =! which_step
	step(xeno_owner, direction, 1)
	playsound(owner_turf, pick(possible_step_sounds), 40)
	new /obj/effect/temp_visual/behemoth/crack/landslide(owner_turf, direction, which_step)
	new /obj/effect/temp_visual/behemoth/landslide/dust/charge(owner_turf, direction)
	addtimer(CALLBACK(src, PROC_REF(do_charge), get_turf(xeno_owner), direction, damage, which_step), LANDSLIDE_STEP_DELAY)

/** Ends the charge.
* * reason: If specified, determines the reason why the charge ended, and does the respective balloon alert. Leave empty for no reason.
*/
/datum/action/xeno_action/activable/landslide/proc/end_charge(reason)
	ability_active = FALSE
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	if(cooldown_id)
		clear_cooldown()
	add_cooldown()
	if(length(enhanced_turfs))
		enhanced_turfs = list()
	if(length(enhanced_warnings))
		enhanced_warnings = list()
	switch(reason)
		if(LANDSLIDE_ENDED_CANCELLED) // The user manually cancelled the ability at some point during its use.
			owner.balloon_alert(owner, "Cancelled")
		if(LANDSLIDE_ENDED_NO_PLASMA) // During the charge, the user did not have enough plasma to satisfy the charge's cost.
			owner.balloon_alert(owner, "Insufficient plasma")
		if(LANDSLIDE_ENDED_NO_SELECTION) // During the target selection phase for the Primal Wrath version of this ability, no selection was made.
			owner.balloon_alert(owner, "No selection made, cancelled")

/** Applies several effects to a living target.
* * living_target: The targeted living mob.
* * direct_turf: If specified, living targets in this turf will receive additional effects.
* * damage: The damage inflicted by related effects.
*/
/datum/action/xeno_action/activable/landslide/proc/hit_living(mob/living/living_target, turf/target_turf, damage, enhanced)
	if(!living_target || !damage)
		return
	if(living_target in target_turf || enhanced)
		if(!living_target.lying_angle)
			living_target.Knockdown(LANDSLIDE_KNOCKDOWN_DURATION)
			new /obj/effect/temp_visual/behemoth/landslide/hit(get_turf(living_target))
			playsound(living_target, 'sound/effects/behemoth/landslide_hit_mob.ogg', 30, TRUE)
		living_target.emote("scream")
		shake_camera(living_target, max(1, LANDSLIDE_KNOCKDOWN_DURATION), 1)
		living_target.apply_damage(damage, BRUTE, blocked = MELEE)
		return
	shake_camera(living_target, max(1, LANDSLIDE_KNOCKDOWN_DURATION), 0.5)
	living_target.do_jitter_animation(jitter_loops = 2)
	living_target.apply_damage(damage * LANDSLIDE_CHARGE_DAMAGE_ADJACENT_MODIFIER, BRUTE, blocked = MELEE)

/** Applies several effects to an object. Effects differ based on the object's type, with unique interactions for mechas and Earth Pillars.
* * object_target: The targeted object.
* * damage: The damage inflicted by related effects.
* * ending: If TRUE, applies different effects to the target.
*/
/datum/action/xeno_action/activable/landslide/proc/hit_object(obj/object_target, damage, ending)
	if(!object_target || !damage)
		return
	var/object_turf = get_turf(object_target)
	if(!ending)
		if(isearthpillar(object_target))
			return
		var/damage_requirement = damage * LANDSLIDE_DAMAGE_OBJECT_MODIFIER
		if(ismecha(object_target))
			damage_requirement = damage * LANDSLIDE_DAMAGE_MECHA_MODIFIER
		if(object_target.obj_integrity <= damage_requirement)
			playsound(object_turf, 'sound/effects/meteorimpact.ogg', 30, TRUE)
			object_target.deconstruct(FALSE)
			object_target.do_jitter_animation(jitter_loops = 3)
		return
	new /obj/effect/temp_visual/behemoth/landslide/hit(object_turf)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/activable/earth_riser/earth_riser_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/earth_riser]
	if(isearthpillar(object_target) && earth_riser_action)
		var/obj/structure/earth_pillar/pillar_target = object_target
		earth_riser_action.do_projectile(pillar_target, TRUE)
		return
	if(ismecha(object_target))
		var/obj/vehicle/sealed/mecha/mecha_target = object_target
		mecha_target.take_damage(damage * LANDSLIDE_DAMAGE_MECHA_MODIFIER, MELEE)
		return
	object_target.take_damage(damage * LANDSLIDE_DAMAGE_OBJECT_MODIFIER, MELEE)
	return

/** Applies several effects to a target turf, and its contents if applicable. Effects differ based on the turf type and its contents, with unique interactions for walls and objects.
* * turf_target: The targeted turf.
* * damage: The damage inflicted by related effects.
*/
/datum/action/xeno_action/activable/landslide/proc/ending_hit(obj/turf_target, damage)
	if(!turf_target || !damage)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.do_attack_animation(turf_target)
	playsound(turf_target, 'sound/effects/behemoth/behemoth_stomp.ogg', 40, TRUE)
	if(iswallturf(turf_target))
		var/turf/closed/wall/wall_target = turf_target
		new /obj/effect/temp_visual/behemoth/landslide/hit(wall_target)
		new /obj/effect/temp_visual/behemoth/crack(wall_target)
		wall_target.take_damage(damage * LANDSLIDE_DAMAGE_TURF_MODIFIER, MELEE)
	var/list/turf/target_turfs = list(turf_target)
	target_turfs += get_turf(owner)
	for(var/turf/target_turf AS in target_turfs)
		for(var/obj/affected_object in target_turf)
			if(!affected_object.density || affected_object.resistance_flags & INDESTRUCTIBLE)
				continue
			hit_object(affected_object, damage, TRUE)

/** Runs any checks associated to the Enhanced version of this ability, ending it early if conditions are met.
* * times_called: Counter for the amount of times this proc has been called. This is used to determine the amount of time spent during the selection phase, cancelling the ability after some time.
*/
/datum/action/xeno_action/activable/landslide/proc/enhanced_check_charge(times_called)
	times_called++
	if(!ability_active || length(enhanced_turfs) > LANDSLIDE_ENHANCED_POSSIBLE_SELECTIONS)
		return
	if(owner.stat)
		end_charge()
		return
	if(times_called >= LANDSLIDE_ENHANCED_WAIT_TIME / LANDSLIDE_ENHANCED_WAIT_DELAY)
		end_charge(LANDSLIDE_ENDED_NO_SELECTION)
		return
	addtimer(CALLBACK(src, PROC_REF(enhanced_check_charge), times_called), LANDSLIDE_ENHANCED_WAIT_DELAY)

/** Prepares selections made during the selection phase of this ability. Selected turfs are processed and adapted to the ability for their later usage.
* If the maximum amount of selections has been reached, this proc will end the selection phase and execute the charge.
* * source: References the source of this proc. Usually the owner.
* * selected_atom: The atom that was selected by the user. This is later converted into a turf.
*/
/datum/action/xeno_action/activable/landslide/proc/enhanced_prepare_charge(datum/source, atom/selected_atom)
	SIGNAL_HANDLER
	if(!selected_atom)
		return
	if(!isturf(selected_atom))
		selected_atom = get_turf(selected_atom)
	var/turf/origin_turf = enhanced_turfs[length(enhanced_turfs)]
	var/turf/corrected_turf = get_ranged_target_turf(origin_turf, get_dir(origin_turf, selected_atom), min(LANDSLIDE_RANGE, get_dist(origin_turf, selected_atom)))
	var/list/turf/possible_turfs = get_line(origin_turf, corrected_turf)
	for(var/turf/possible_turf AS in possible_turfs)
		if(LinkBlocked(origin_turf, possible_turf) || !line_of_sight(origin_turf, possible_turf))
			possible_turfs -= possible_turf
	corrected_turf = possible_turfs[length(possible_turfs)]
	if(corrected_turf == get_turf(owner) || (corrected_turf in enhanced_turfs))
		owner.balloon_alert(owner, "Same target")
		return
	enhanced_warnings += new /obj/effect/temp_visual/behemoth/warning/enhanced/numeric(corrected_turf, LANDSLIDE_ENHANCED_WAIT_TIME, length(enhanced_turfs))
	do_warning(owner, get_affected_turfs(origin_turf, get_dir(origin_turf, corrected_turf), get_dist(origin_turf, corrected_turf), TRUE, src), LANDSLIDE_ENHANCED_WAIT_TIME, TRUE, src)
	enhanced_turfs += corrected_turf
	if(length(enhanced_turfs) < LANDSLIDE_ENHANCED_POSSIBLE_SELECTIONS + 1)
		return
	var/numeric_counter = 0
	var/warning_duration = 2.5 SECONDS
	for(var/obj/effect/temp_visual/behemoth/warning/enhanced/enhanced_warning AS in enhanced_warnings)
		if(istype(enhanced_warning, /obj/effect/temp_visual/behemoth/warning/enhanced/numeric) && numeric_counter < 3)
			numeric_counter++
			new /obj/effect/temp_visual/behemoth/warning/enhanced/numeric(get_turf(enhanced_warning), warning_duration, numeric_counter)
			continue
		new /obj/effect/temp_visual/behemoth/warning/enhanced(get_turf(enhanced_warning), warning_duration)
	QDEL_LIST(enhanced_warnings)
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/charge_direction = get_dir(enhanced_turfs[1], enhanced_turfs[2])
	new /obj/effect/temp_visual/behemoth/crack/landslide(get_turf(owner), charge_direction, pick(1, 2))
	var/charge_distance = get_dist(enhanced_turfs[1], enhanced_turfs[2])
	if(ISDIAGONALDIR(charge_direction) && charge_distance >= LANDSLIDE_RANGE)
		charge_distance--
	INVOKE_ASYNC(src, PROC_REF(enhanced_do_charge), \
		charge_direction, xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier, LANDSLIDE_ENHANCED_STEP_DELAY, charge_distance)
	var/animation_time = charge_distance * LANDSLIDE_ENHANCED_STEP_DELAY
	animate(xeno_owner, pixel_y = xeno_owner.pixel_y + (charge_distance / 2), time = animation_time / 2, flags = ANIMATION_END_NOW, easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(xeno_owner.pixel_y), time = animation_time / 2, flags = CIRCULAR_EASING|EASE_IN)
	playsound(xeno_owner, 'sound/effects/behemoth/landslide_enhanced_charge.ogg', 15, TRUE)

/** Moves the user between the selections previously made. This simulates movement by using step() and repeatedly calling itself.
* Will repeatedly check a 3x1 rectangle in front of the user, applying its effects to valid targets and stopping early if the path is blocked.
* * direction: The direction to move in.
* * damage: The damage we will deal to valid targets.
* * speed: The speed at which we move. This is reduced when we're nearing our destination, to simulate a slow-down effect.
* * steps_to_take: The amount of steps needed to reach our destination. This is used to determine when to move on to the next selection.
* * which_charge: Which charge, or which selection, are we currently executing.
* * steps_taken: The amount of steps we have taken. This is used to determine when to move on to the next selection.
*/
/datum/action/xeno_action/activable/landslide/proc/enhanced_do_charge(direction, damage, speed, steps_to_take, which_charge = 1)
	if(!ability_active || !direction)
		return
	if(owner.stat)
		end_charge()
		return
	var/owner_turf = get_turf(owner)
	var/direct_turf = get_step(owner, direction)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(steps_to_take <= 0 || xeno_owner.wrath_stored < plasma_cost)
		if(LinkBlocked(owner_turf, direct_turf))
			shake_camera(xeno_owner, 1, 0.5)
			ending_hit(direct_turf, damage)
		enhanced_next_charge(direction, which_charge, damage)
		return
	succeed_activate()
	if(iswallturf(direct_turf))
		var/turf/closed/wall/affected_wall = direct_turf
		if(affected_wall.wall_integrity <= damage * LANDSLIDE_DAMAGE_TURF_MODIFIER && affected_wall.resistance_flags != INDESTRUCTIBLE)
			playsound(direct_turf, 'sound/effects/meteorimpact.ogg', 30, TRUE)
			affected_wall.dismantle_wall()
	var/list/turf/target_turfs = list(direct_turf)
	target_turfs += get_step(xeno_owner, turn(direction, 45))
	target_turfs += get_step(xeno_owner, turn(direction, -45))
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/affected_atom in target_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				hit_living(affected_living, direct_turf, damage, TRUE)
			if(!(affected_atom in direct_turf))
				continue
			if(isobj(affected_atom))
				var/datum/action/xeno_action/activable/earth_riser/earth_riser_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/earth_riser]
				if(isearthpillar(affected_atom) && earth_riser_action)
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					earth_riser_action.do_projectile(affected_pillar, TRUE)
					continue
				var/obj/affected_object = affected_atom
				hit_object(affected_object, damage)
	steps_to_take--
	step(xeno_owner, direction, 1)
	if(steps_to_take <= 2)
		speed += 0.5
		new /obj/effect/temp_visual/behemoth/landslide/dust/charge(owner_turf, direction)
	addtimer(CALLBACK(src, PROC_REF(enhanced_do_charge), direction, damage, speed, steps_to_take, which_charge), speed)

/** Handles everything necessary before beginning the next charge.
* * direction: The direction we will move in.
* * damage: The damage we will deal in related effects.
* * which_charge: Which charge, or which selection, we will execute.
*/
/datum/action/xeno_action/activable/landslide/proc/enhanced_next_charge(direction, which_charge, damage)
	if(!direction || !which_charge)
		return
	which_charge++
	if(which_charge >= length(enhanced_turfs))
		end_charge()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.wrath_stored < plasma_cost)
		end_charge(LANDSLIDE_ENDED_NO_PLASMA)
		return
	direction = get_dir(enhanced_turfs[which_charge], enhanced_turfs[which_charge + 1])
	new /obj/effect/temp_visual/behemoth/crack/landslide(get_turf(owner), direction, pick(1, 2))
	var/steps_to_take = get_dist(enhanced_turfs[which_charge], enhanced_turfs[which_charge + 1])
	var/animation_time = steps_to_take * LANDSLIDE_ENHANCED_STEP_DELAY
	addtimer(CALLBACK(src, PROC_REF(enhanced_do_charge), direction, damage, LANDSLIDE_ENHANCED_STEP_DELAY, steps_to_take, which_charge), LANDSLIDE_ENHANCED_CHARGE_DELAY)
	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(playsound), xeno_owner, 'sound/effects/behemoth/landslide_enhanced_charge.ogg', 15, TRUE), LANDSLIDE_ENHANCED_CHARGE_DELAY)
	animate(xeno_owner, time = LANDSLIDE_ENHANCED_CHARGE_DELAY, flags = ANIMATION_END_NOW)
	animate(pixel_y = xeno_owner.pixel_y + (steps_to_take / 2), time = animation_time / 2, easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(xeno_owner.pixel_y), time = animation_time / 2, easing = CIRCULAR_EASING|EASE_IN)


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_WIND_UP 2 SECONDS
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

/datum/action/xeno_action/activable/earth_riser
	name = "Earth Riser"
	ability_name = "Earth Riser"
	action_icon_state = "unburrow"
	desc = "Raise a pillar of earth at the selected location. This solid structure can be used for defense, and it interacts with other abilities for offensive usage. Alternate use destroys active pillars, starting with the oldest one."
	plasma_cost = 15
	cooldown_timer = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EARTH_RISER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE,
	)
	/// Maximum amount of Earth Pillars that this ability can have.
	var/maximum_pillars = 1
	/// List that contains all Earth Pillars created by this ability.
	var/list/obj/structure/earth_pillar/active_pillars = list()

/datum/action/xeno_action/activable/earth_riser/on_cooldown_finish()
	owner.balloon_alert(owner, "[ability_name] ready")
	return ..()

/datum/action/xeno_action/activable/earth_riser/alternate_action_activate()
	if(!length(active_pillars))
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "No active pillars")
		return
	var/obj/structure/earth_pillar/oldest_pillar = active_pillars[1]
	new /obj/effect/temp_visual/behemoth/earth_pillar/broken(get_turf(oldest_pillar))
	QDEL_NULL(oldest_pillar)

/datum/action/xeno_action/activable/earth_riser/use_ability(atom/target)
	. = ..()
	if(owner.Adjacent(target) && isearthpillar(target))
		do_projectile(target)
		add_cooldown()
		return
	if(length(active_pillars) >= maximum_pillars)
		owner.balloon_alert(owner, "Maximum amount of pillars reached")
		return
	var/turf/owner_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	if(!line_of_sight(owner, target, EARTH_RISER_RANGE) || LinkBlocked(owner_turf, target_turf))
		owner.balloon_alert(owner, "Out of range")
		return
	do_stomp(owner, owner_turf)
	new /obj/effect/temp_visual/behemoth/stomp/west(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf, owner.dir)
	do_warning(owner, list(target_turf), EARTH_RISER_WIND_UP)
	addtimer(CALLBACK(src, PROC_REF(do_ability), target_turf), EARTH_RISER_WIND_UP)
	add_cooldown(EARTH_RISER_WIND_UP)
	succeed_activate()

/// Checks if there's any living mobs in the target turf, displaces them if so, then creates a new Earth Pillar and adds it to the list of active pillars.
/datum/action/xeno_action/activable/earth_riser/proc/do_ability(turf/target_turf)
	if(!target_turf)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		shake_camera(affected_living, 1, 0.5)
		step_away(affected_living, target_turf, 1, 2)
	active_pillars += new /obj/structure/earth_pillar(target_turf, xeno_owner)

/** Trying to use certain abilities on an Earth Pillar fires as a projectile in the user's cardinal direction.
* See the following abilities, as well as the projectile itself, for specifics.
*/
/datum/action/xeno_action/activable/earth_riser/proc/do_projectile(obj/structure/earth_pillar/target_pillar, explode)
	if(!target_pillar)
		return
	playsound(target_pillar, get_sfx("behemoth_earth_pillar_hit"), 40)
	var/turf/target_turf = get_turf(target_pillar)
	new /obj/effect/temp_visual/behemoth/landslide/hit(target_turf)
	QDEL_NULL(target_pillar)
	var/datum/ammo/xeno/earth_pillar/projectile = explode? GLOB.ammo_list[/datum/ammo/xeno/earth_pillar/explosive] : GLOB.ammo_list[/datum/ammo/xeno/earth_pillar]
	var/obj/projectile/new_projectile = new /obj/projectile(target_turf)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	new_projectile.generate_bullet(projectile)
	new_projectile.fire_at(target_turf, xeno_owner, null, new_projectile.ammo.max_range)

/** Changes the maximum amount of Earth Pillars that can be had.
* If the user has more Earth Pillars active than the new maximum, it will destroy them, from oldest to newest, until meeting the new amount.
*/
/datum/action/xeno_action/activable/earth_riser/proc/change_maximum_pillars(amount)
	if(!amount)
		return
	maximum_pillars = amount
	if(!length(active_pillars))
		return
	while(length(active_pillars) > maximum_pillars)
		var/obj/structure/earth_pillar/oldest_pillar = active_pillars[1]
		new /obj/effect/temp_visual/behemoth/earth_pillar/broken(get_turf(oldest_pillar))
		QDEL_NULL(oldest_pillar)


// ***************************************
// *********** Seismic Fracture
// ***************************************
#define SEISMIC_FRACTURE_WIND_UP 2 SECONDS
#define SEISMIC_FRACTURE_RANGE 3
#define SEISMIC_FRACTURE_ATTACK_RADIUS 2
#define SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS 5
#define SEISMIC_FRACTURE_ENHANCED_DELAY 1.2 SECONDS
#define SEISMIC_FRACTURE_PARALYZE_DURATION 1.5 SECONDS
#define SEISMIC_FRACTURE_DAMAGE_MECHA_MODIFIER 10
#define SEISMIC_FRACTURE_DAMAGE_OBJECT_MODIFIER 2

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

/datum/action/xeno_action/activable/seismic_fracture
	name = "Seismic Fracture"
	ability_name = "Seismic Fracture"
	action_icon_state = "4"
	desc = "Blast the earth around the selected location, inflicting heavy damage in a large radius."
	plasma_cost = 25
	cooldown_timer = 20 SECONDS
	target_flags = XABB_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_SEISMIC_FRACTURE,
	)

/datum/action/xeno_action/activable/seismic_fracture/on_cooldown_finish()
	owner.balloon_alert(owner, "[ability_name] ready")
	return ..()

/datum/action/xeno_action/activable/seismic_fracture/use_ability(atom/target)
	. = ..()
	if(!line_of_sight(owner, target, SEISMIC_FRACTURE_RANGE))
		owner.balloon_alert(owner, "Out of range")
		return
	var/owner_turf = get_turf(owner)
	new /obj/effect/temp_visual/behemoth/stomp/east(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf, owner.dir)
	do_stomp(owner, owner_turf)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/primal_wrath/primal_wrath_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/primal_wrath]
	do_ability(get_turf(target), SEISMIC_FRACTURE_WIND_UP, primal_wrath_action?.ability_active? TRUE : FALSE)

/** Handles the warnings, calling the following procs, and any alterations caused by Primal Wrath.
* This has to be cut off from use_ability() to optimize code, due to an interaction with Earth Pillars.
* Earth Pillars caught in the range of Seismic Fracture reflect the attack by calling this proc again.
* * target_turf: The targeted turf.
* * wind_up: The wind-up duration before the ability happens.
* * enhanced: Whether this is enhanced by Primal Wrath or not.
*/
/datum/action/xeno_action/activable/seismic_fracture/proc/do_ability(turf/target_turf, wind_up, enhanced)
	if(!target_turf)
		return
	var/list/turf/turfs_to_attack = filled_turfs(target_turf, SEISMIC_FRACTURE_ATTACK_RADIUS, bypass_window = TRUE, projectile = TRUE)
	if(!length(turfs_to_attack))
		owner.balloon_alert(owner, "Unable to use here")
		return
	if(wind_up <= 0)
		do_attack(turfs_to_attack, enhanced, TRUE)
		return
	add_cooldown()
	succeed_activate()
	do_warning(owner, turfs_to_attack, wind_up, enhanced)
	addtimer(CALLBACK(src, PROC_REF(do_attack), turfs_to_attack, enhanced), wind_up)
	if(!enhanced)
		return
	new /obj/effect/temp_visual/shockwave/enhanced(get_turf(owner), SEISMIC_FRACTURE_ATTACK_RADIUS, owner.dir)
	playsound(owner, 'sound/effects/behemoth/landslide_roar.ogg', 40, TRUE)
	var/list/turf/extra_turfs_to_warn = filled_turfs(target_turf, SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS, bypass_window = TRUE, projectile = TRUE)
	for(var/turf/extra_turf_to_warn AS in extra_turfs_to_warn)
		if(isclosedturf(extra_turf_to_warn))
			extra_turfs_to_warn -= extra_turf_to_warn
	if(length(extra_turfs_to_warn) && length(turfs_to_attack))
		extra_turfs_to_warn -= turfs_to_attack
	do_warning(owner, extra_turfs_to_warn, wind_up + SEISMIC_FRACTURE_ENHANCED_DELAY, enhanced)
	var/list/turf/extra_turfs = filled_turfs(target_turf, SEISMIC_FRACTURE_ATTACK_RADIUS + 1, bypass_window = TRUE, projectile = TRUE)
	if(length(extra_turfs) && length(turfs_to_attack))
		extra_turfs -= turfs_to_attack
	addtimer(CALLBACK(src, PROC_REF(do_attack_extra), \
		target_turf, extra_turfs, turfs_to_attack, enhanced, SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS, SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS - SEISMIC_FRACTURE_ATTACK_RADIUS), \
		wind_up + SEISMIC_FRACTURE_ENHANCED_DELAY)

/** Handles the additional attacks caused by Primal Wrath. These are done iteratively rather than instantly, with a delay inbetween.
* * origin_turf: The starting turf.
* * extra_turfs: Any additional turfs that should be handled.
* * excepted_turfs: Turfs that should be excepted from this proc.
* * enhanced: Whether this is enhanced by Primal Wrath or not.
* * range: The range to cover.
* * iteration: The current iteration.
*/
/datum/action/xeno_action/activable/seismic_fracture/proc/do_attack_extra(turf/origin_turf, list/turf/extra_turfs, list/turf/excepted_turfs, enhanced, range, iteration)
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

/** Checks for any atoms caught in the attack's range, and applies several effects based on the atom's type.
* * turfs_to_attack: The turfs affected by this proc.
* * enhanced: Whether this is enhanced or not.
* * instant: Whether this is done instantly or not.
*/
/datum/action/xeno_action/activable/seismic_fracture/proc/do_attack(list/turf/turfs_to_attack, enhanced, instant)
	if(!length(turfs_to_attack))
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/attack_damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier
	for(var/turf/target_turf AS in turfs_to_attack)
		if(isclosedturf(target_turf))
			continue
		new /obj/effect/temp_visual/behemoth/crack(target_turf)
		playsound(target_turf, 'sound/effects/behemoth/seismic_fracture_explosion.ogg', 15)
		for(var/atom/movable/affected_atom AS in target_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				affected_living.emote("scream")
				shake_camera(affected_living, max(1, SEISMIC_FRACTURE_PARALYZE_DURATION), 1)
				affected_living.Paralyze(SEISMIC_FRACTURE_PARALYZE_DURATION)
				affected_living.apply_damage(attack_damage, BRUTE, blocked = MELEE)
				if(instant)
					continue
				affected_living.layer = ABOVE_MOB_LAYER
				affected_living.status_flags |= (INCORPOREAL|GODMODE)
				animate(affected_living, pixel_y = affected_living.pixel_y + 40, layer = ABOVE_MOB_LAYER, time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, \
					easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW)
				animate(pixel_y = initial(affected_living.pixel_y), time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_IN)
				addtimer(CALLBACK(src, PROC_REF(living_landing), affected_living), SEISMIC_FRACTURE_PARALYZE_DURATION)
			else if(isobj(affected_atom))
				var/obj/affected_object = affected_atom
				if(!affected_object.density || affected_object.resistance_flags & INDESTRUCTIBLE)
					continue
				affected_object.do_jitter_animation()
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mecha = affected_atom
					affected_mecha.take_damage(attack_damage * SEISMIC_FRACTURE_DAMAGE_MECHA_MODIFIER, MELEE)
					continue
				if(isearthpillar(affected_atom))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					affected_pillar.seismic_fracture()
					playsound(affected_pillar, get_sfx("behemoth_earth_pillar_hit"), 40)
					new /obj/effect/temp_visual/behemoth/landslide/hit(target_turf)
					do_ability(target_turf, initial(affected_pillar.warning_flashes) * 10, FALSE)
					continue
				affected_object.take_damage(attack_damage * SEISMIC_FRACTURE_DAMAGE_OBJECT_MODIFIER, MELEE)
		if(!enhanced)
			new /obj/effect/temp_visual/behemoth/seismic_fracture(target_turf)
			continue
		new /obj/effect/temp_visual/behemoth/seismic_fracture/enhanced(target_turf, FALSE)

/// Living mobs that were previously caught in the attack's radius are subject to a landing effect. Their invincibility is removed, and they receive a reduced amount of damage.
/datum/action/xeno_action/activable/seismic_fracture/proc/living_landing(mob/living/affected_living)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	affected_living.layer = initial(affected_living.layer)
	affected_living.status_flags &= ~(INCORPOREAL|GODMODE)
	affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 3, BRUTE, blocked = MELEE)
	var/landing_turf = get_turf(affected_living)
	playsound(landing_turf, 'sound/effects/behemoth/seismic_fracture_landing.ogg', 10, TRUE)
	new /obj/effect/temp_visual/behemoth/stomp(landing_turf)


// ***************************************
// *********** Primal Wrath
// ***************************************
#define PRIMAL_WRATH_ACTIVATION_DURATION 3.6 SECONDS // Timed with the sound played.
#define PRIMAL_WRATH_RANGE 12
#define PRIMAL_WRATH_DAMAGE_MULTIPLIER 1.3
#define PRIMAL_WRATH_DECAY_MULTIPLIER 1.2
#define PRIMAL_WRATH_ACTIVE_DECAY_DIVISION 40
#define PRIMAL_WRATH_COST_MULTIPLIER 0.5
#define PRIMAL_WRATH_GAIN_MULTIPLIER 0.4

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
	icon = 'icons/Xeno/3x3_Xenos.dmi'
	icon_state = "Behemoth Flashing"

/datum/action/xeno_action/primal_wrath
	name = "Primal Wrath"
	ability_name = "Primal Wrath"
	action_icon_state = "26"
	desc = "Unleash your wrath. Enhances your abilities, changing their functionality and allowing them to apply a damage over time debuff."
	keybind_flags = XACT_KEYBIND_USE_ABILITY|XACT_IGNORE_SELECTED_ABILITY
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

/datum/action/xeno_action/primal_wrath/give_action(mob/living/L)
	. = ..()
	block_overlay = new(null, src)
	owner.vis_contents += block_overlay
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(owner, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED), PROC_REF(stop_ability))

/datum/action/xeno_action/primal_wrath/remove_action(mob/living/L)
	. = ..()
	stop_ability()

/datum/action/xeno_action/primal_wrath/process()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
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

/datum/action/xeno_action/primal_wrath/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.wrath_stored < xeno_owner.xeno_caste.wrath_max - (xeno_owner.xeno_caste.wrath_max * 0.2))
		xeno_owner.balloon_alert(xeno_owner, "Not enough Wrath")
		return
	toggle_buff(TRUE)
	currently_roaring = TRUE
	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	xeno_owner.status_flags |= GODMODE
	var/owner_turf = get_turf(xeno_owner)
	playsound(owner_turf, 'sound/effects/behemoth/primal_wrath_roar.ogg', 75, TRUE)
	do_ability(owner_turf)
	addtimer(CALLBACK(src, PROC_REF(end_ability)), PRIMAL_WRATH_ACTIVATION_DURATION)
	succeed_activate()
	add_cooldown()

/** Distorts the view of every valid living mob in range.
* * origin_turf: The source location of this ability.
*/
/datum/action/xeno_action/primal_wrath/proc/do_ability(turf/origin_turf)
	if(!origin_turf || !currently_roaring)
		return
	new /obj/effect/temp_visual/shockwave/primal_wrath(origin_turf, 4, owner.dir)
	for(var/mob/living/affected_living in get_hearers_in_view(PRIMAL_WRATH_RANGE, owner))
		if(!affected_living.hud_used)
			continue
		var/atom/movable/screen/plane_master/floor/floor_plane = affected_living.hud_used.plane_masters["[FLOOR_PLANE]"]
		var/atom/movable/screen/plane_master/game_world/world_plane = affected_living.hud_used.plane_masters["[GAME_PLANE]"]
		if(floor_plane.get_filter("primal_wrath") || world_plane.get_filter("primal_wrath"))
			continue
		var/filter_size = 0.04
		world_plane.add_filter("primal_wrath", 2, radial_blur_filter(filter_size))
		animate(world_plane.get_filter("primal_wrath"), size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		floor_plane.add_filter("primal_wrath", 2, radial_blur_filter(filter_size))
		animate(floor_plane.get_filter("primal_wrath"), size = filter_size * 2, time = 0.5 SECONDS, loop = -1)
		ability_check(affected_living, owner)
	addtimer(CALLBACK(src, PROC_REF(do_ability), origin_turf), 0.1 SECONDS)

/// Ends the ability.
/datum/action/xeno_action/primal_wrath/proc/end_ability()
	currently_roaring = FALSE
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	owner.status_flags &= ~GODMODE

/** Checks if the affected target should no longer be affected by the ability.
* * affected_living: The affected living mob.
* * xeno_source: The source of the effects.
*/
/datum/action/xeno_action/primal_wrath/proc/ability_check(mob/living/affected_living, mob/living/carbon/xenomorph/xeno_source)
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
/datum/action/xeno_action/primal_wrath/proc/change_cost(datum/source, datum/action/xeno_action/source_action, action_cost)
	SIGNAL_HANDLER
	if(!ability_active)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/activable/earth_riser/earth_riser_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/earth_riser]
	if(source_action == src || source_action == earth_riser_action)
		return
	xeno_owner.wrath_stored = max(0, xeno_owner.wrath_stored - round(action_cost * PRIMAL_WRATH_COST_MULTIPLIER))
	return SUCCEED_ACTIVATE_CANCEL

/** When taking damage, resets decay and returns an amount of Wrath proportional to the damage.
* If damage taken would kill the user, it is instead reduced, and
* * source: The source of this proc.
* * amount: The RAW amount of damage taken.
* * amount_mod: If provided, this list includes modifiers applied to the damage. This, for example, can be useful for reducing the damage.
*/
/datum/action/xeno_action/primal_wrath/proc/taking_damage(datum/source, amount, list/amount_mod)
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
	xeno_owner.wrath_stored += amount * PRIMAL_WRATH_GAIN_MULTIPLIER

/** Toggles the buff, which increases the owner's damage based on a multiplier, and gives them a particle effect.
* * toggle: Whether to toggle it on or off.
* * multiplier: The multiplier applied to the owner's damage.
*/
/datum/action/xeno_action/primal_wrath/proc/toggle_buff(toggle)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/activable/earth_riser/earth_riser_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/earth_riser]
	if(!toggle)
		ability_active = FALSE
		set_toggle(FALSE)
		QDEL_NULL(particle_holder)
		decay_time = initial(decay_time)
		xeno_owner.xeno_melee_damage_modifier = initial(xeno_owner.xeno_melee_damage_modifier)
		earth_riser_action?.change_maximum_pillars(1)
		owner.balloon_alert(owner, "Primal Wrath ended")
		UnregisterSignal(xeno_owner, list(COMSIG_XENO_ACTION_SUCCEED_ACTIVATE, COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE))
		return
	ability_active = TRUE
	set_toggle(TRUE)
	decay_time = 4 SECONDS
	decay_amount = initial(decay_amount)
	particle_holder = new(xeno_owner, /particles/primal_wrath)
	particle_holder.pixel_x = 3
	particle_holder.pixel_y = -20
	xeno_owner.xeno_melee_damage_modifier = PRIMAL_WRATH_DAMAGE_MULTIPLIER
	earth_riser_action?.change_maximum_pillars(3)
	RegisterSignal(xeno_owner, COMSIG_XENO_ACTION_SUCCEED_ACTIVATE, PROC_REF(change_cost))
	RegisterSignal(xeno_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taking_damage))

/// Stops processing, and unregisters related signals.
/datum/action/xeno_action/primal_wrath/proc/stop_ability(datum/source)
	SIGNAL_HANDLER
	if(ability_active)
		toggle_buff(FALSE)
	UnregisterSignal(owner, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_DEATH, COMSIG_XENOMORPH_EVOLVED, COMSIG_XENOMORPH_DEEVOLVED))
	STOP_PROCESSING(SSprocessing, src)


// ***************************************
// *********** Earth Pillar (also see: Earth Riser)
// ***************************************
#define EARTH_PILLAR_KNOCKDOWN_DURATION 0.5 SECONDS
#define EARTH_PILLAR_DAMAGE_MECHA_MODIFIER 5
#define EARTH_PILLAR_DAMAGE_OBJECT_MODIFIER 2
#define EARTH_PILLAR_DAMAGE_TURF_MODIFIER 5

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
	icon_state = "earth_pillar"
	base_icon_state = "earth_pillar"
	layer = ABOVE_LYING_MOB_LAYER
	climbable = TRUE
	climb_delay = 3 SECONDS
	interaction_flags = INTERACT_CHECK_INCAPACITATED
	density = TRUE
	max_integrity = 300
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 0, BIO = 100, FIRE = 100, ACID = 0)
	destroy_sound = 'sound/effects/behemoth/earth_pillar_destroyed.ogg'
	coverage = 128
	/// The owner of this object.
	var/owner
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// The amount of times a xeno needs to attack this to destroy it.
	var/attacks_to_destroy = 3
	/// The amount of times an Earth Pillar flashes before executing its interaction with Seismic Fracture.
	var/warning_flashes = 3

/obj/structure/earth_pillar/Initialize(mapload, new_owner)
	. = ..()
	owner = new_owner
	playsound(src, 'sound/effects/behemoth/earth_pillar_rising.ogg', 40, TRUE)
	particle_holder = new(src, /particles/earth_pillar)
	particle_holder.pixel_y = -4
	animate(particle_holder, pixel_y = 4, time = 1.0 SECONDS)
	animate(alpha = 0, time = 0.6 SECONDS)
	QDEL_NULL_IN(src, particle_holder, 1.6 SECONDS)
	do_jitter_animation(jitter_loops = 5)

/obj/structure/earth_pillar/Destroy()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/action/xeno_action/activable/earth_riser/earth_riser_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/earth_riser]
	if(earth_riser_action && (src in earth_riser_action.active_pillars))
		earth_riser_action.active_pillars -= src
	return ..()

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
				playsound(src, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
				new /obj/effect/temp_visual/behemoth/landslide/hit(current_turf)
				new /obj/effect/temp_visual/behemoth/earth_pillar/broken(current_turf)
				Destroy()
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
				playsound(src, 'sound/effects/behemoth/earth_pillar_eating.ogg', 10, TRUE)
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
			Destroy()
		if(EXPLODE_HEAVY)
			take_damage(max_integrity / 2)
		if(EXPLODE_LIGHT)
			take_damage(max_integrity / 3)

/// Seismic Fracture (as in the ability) has a special interaction with any Earth Pillars caught in its attack range.
/// Those Earth Pillars will reflect the same attack in a similar range around it, destroying itself afterwards.
/obj/structure/earth_pillar/proc/seismic_fracture()
	if(warning_flashes <= 0)
		new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(get_turf(src))
		qdel(src)
		return
	warning_flashes--
	addtimer(CALLBACK(src, PROC_REF(seismic_fracture)), 1 SECONDS)
	animate(src, color = COLOR_TAN_ORANGE, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(color = COLOR_WHITE, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

// Earth Riser is capable of interacting with existing Earth Pillars to fire a projectile.
// See the Earth Riser ability for specifics.
/datum/ammo/xeno/earth_pillar
	name = "rock"
	icon_state = "earth_pillar"
	ping = null
	bullet_color = COLOR_WHITE
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS
	shell_speed = 1
	accuracy = 100
	damage_falloff = 0
	damage_type = BRUTE
	armor_type = MELEE

/datum/ammo/xeno/earth_pillar/on_hit_mob(mob/victim, obj/projectile/proj, explosion)
	var/mob_turf = get_turf(victim)
	playsound(mob_turf, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(mob_turf)
	if(!isliving(victim))
		return
	var/mob/living/living_victim = victim
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	if(xeno_firer.issamexenohive(living_victim) || living_victim.stat == DEAD)
		return
	step_away(living_victim, proj, 1, 1)
	shake_camera(living_victim, max(1, EARTH_PILLAR_KNOCKDOWN_DURATION), 1)
	living_victim.Knockdown(EARTH_PILLAR_KNOCKDOWN_DURATION)
	var/projectile_damage = xeno_firer?.xeno_caste.melee_damage * xeno_firer?.xeno_melee_damage_modifier
	living_victim.apply_damage(projectile_damage, BRUTE, blocked = MELEE)

/datum/ammo/xeno/earth_pillar/on_hit_obj(obj/object, obj/projectile/proj, explosion)
	var/object_turf = get_turf(object)
	playsound(object_turf, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(object_turf)
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/projectile_damage = xeno_firer?.xeno_caste.melee_damage * xeno_firer?.xeno_melee_damage_modifier
	if(ismecha(object))
		var/obj/vehicle/sealed/mecha/mecha_object = object
		mecha_object.take_damage(projectile_damage * EARTH_PILLAR_DAMAGE_MECHA_MODIFIER, MELEE)
		return
	object.take_damage(projectile_damage * EARTH_PILLAR_DAMAGE_OBJECT_MODIFIER, MELEE)

/datum/ammo/xeno/earth_pillar/on_hit_turf(turf/hit_turf, obj/projectile/proj)
	playsound(hit_turf, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(hit_turf)
	if(!iswallturf(hit_turf) || hit_turf.resistance_flags != INDESTRUCTIBLE)
		return
	var/turf/closed/wall/hit_wall = hit_turf
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/projectile_damage = xeno_firer?.xeno_caste.melee_damage * xeno_firer?.xeno_melee_damage_modifier
	hit_wall.take_damage(projectile_damage * EARTH_PILLAR_DAMAGE_TURF_MODIFIER, MELEE)

/datum/ammo/xeno/earth_pillar/explosive
	bullet_color = COLOR_LIGHT_ORANGE

/datum/ammo/xeno/earth_pillar/explosive/on_hit_mob(mob/victim, obj/projectile/proj)
	return on_hit_anything(victim, proj)

/datum/ammo/xeno/earth_pillar/explosive/on_hit_obj(obj/object, obj/projectile/proj)
	return on_hit_anything(object, proj)

/datum/ammo/xeno/earth_pillar/explosive/on_hit_turf(turf/hit_turf, obj/projectile/proj)
	return on_hit_anything(hit_turf, proj)

/// Handles anything that would happen after the projectile hits something.
/datum/ammo/xeno/earth_pillar/explosive/proc/on_hit_anything(atom/hit_atom, obj/projectile/proj)
	var/atom_turf = get_turf(hit_atom)
	playsound(atom_turf, 'sound/effects/behemoth/earth_pillar_destroyed.ogg', 40, TRUE)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(atom_turf)
	if(!isxeno(proj.firer))
		return
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/datum/action/xeno_action/activable/seismic_fracture/seismic_fracture_action = xeno_firer.actions_by_path?[/datum/action/xeno_action/activable/seismic_fracture]
	seismic_fracture_action?.do_ability(get_step(atom_turf, turn(proj.dir, 180)), 0, FALSE)
