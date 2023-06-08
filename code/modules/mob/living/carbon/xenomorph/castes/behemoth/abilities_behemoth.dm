#define isearthpillar(A) (istype(A, /obj/structure/earth_pillar))

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
			pixel_x = 12
			pixel_y = 1
		if(SOUTH)
			pixel_x = -10
			pixel_y = -1
		if(WEST)
			pixel_x = -25
			pixel_y = -1
		if(EAST)
			pixel_x = 32
			pixel_y = -1

/obj/effect/temp_visual/behemoth/stomp/east/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x = -12
			pixel_y = 1
		if(SOUTH)
			pixel_x = 10
			pixel_y = -1
		if(WEST)
			pixel_x = -11
			pixel_y = -1
		if(EAST)
			pixel_x = 18
			pixel_y = -1

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
	color = "#FFD800"

/obj/effect/temp_visual/behemoth/warning/Initialize(mapload, warning_duration)
	. = ..()
	if(warning_duration)
		duration = warning_duration
	animate(src, time = duration - 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/warning/enhanced
	color = "#FF0000"

/obj/effect/temp_visual/behemoth/warning/enhanced/numeric/Initialize(mapload, warning_duration, number)
	. = ..()
	icon_state = "warning_[number]"

// ***************************************
// *********** Activable Parent
// ***************************************
#define BEHEMOTH_STOMP_KNOCKDOWN_DURATION 0.8 SECONDS

// This ability is exclusively here to house some stuff as a parent ability, and therefore reduce the amount of repeat code.
/datum/action/xeno_action/activable/behemoth
	ability_name = "Behemoth Ability"
	/// Whether this ability is currently active or not.
	var/ability_active = FALSE
	/// The sound that is played in ability warnings.
	var/warning_sound = 'sound/effects/behemoth/behemoth_rumble.ogg'
	/// The duration of the ability's wind-up process.
	var/wind_up_duration = 1 SECONDS
	/// References the Landslide action, if any.
	var/datum/action/xeno_action/activable/behemoth/landslide/landslide_action
	/// References the Landslide action, if any.
	var/datum/action/xeno_action/activable/behemoth/seismic_fracture/seismic_fracture_action
	/// References the Primal Wrath action, if any.
	var/datum/action/xeno_action/primal_wrath/primal_wrath_action

/datum/action/xeno_action/activable/behemoth/on_cooldown_finish()
	owner.balloon_alert(owner, "[ability_name] ready")
	return ..()

/datum/action/xeno_action/activable/behemoth/use_ability(atom/target)
	if(!target)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!primal_wrath_action)
		primal_wrath_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/primal_wrath]
	if(!landslide_action)
		landslide_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/behemoth/landslide]
	if(!seismic_fracture_action)
		seismic_fracture_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/behemoth/seismic_fracture]
	if(!landslide_action?.ability_active)
		owner.dir = get_cardinal_dir(owner, target)

/// Punishes anyone on the same tile as the Behemoth by damaging them and knocking them down.
/datum/action/xeno_action/activable/behemoth/proc/do_stomp(target_turf)
	if(!isturf(target_turf))
		target_turf = get_turf(target_turf)
	playsound(target_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 30)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		affected_living.emote("scream")
		shake_camera(affected_living, max(1, BEHEMOTH_STOMP_KNOCKDOWN_DURATION), 1)
		affected_living.Knockdown(BEHEMOTH_STOMP_KNOCKDOWN_DURATION)
		affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 2, BRUTE, blocked = MELEE)

/// Warns nearby players, in any way or form, of the incoming ability and the range it will affect.
/// Accepts lists, applying its effects to the contents.
/datum/action/xeno_action/activable/behemoth/proc/do_warning(target_turf, duration = 10 SECONDS, enhanced_landslide)
	if(duration && duration <= wind_up_duration && warning_sound)
		playsound(target_turf, warning_sound, 30)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	primal_wrath_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/primal_wrath]
	var/warning_type = primal_wrath_action?.ability_active? /obj/effect/temp_visual/behemoth/warning/enhanced : /obj/effect/temp_visual/behemoth/warning
	if(islist(target_turf))
		for(var/turf/affected_turf AS in target_turf)
			if(landslide_action && enhanced_landslide)
				landslide_action.enhanced_warnings += new warning_type(affected_turf)
			else
				new warning_type(affected_turf, duration)
			for(var/mob/living/affected_living in affected_turf)
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				shake_camera(affected_living, max(1, duration), 0.5)
		return
	if(!isturf(target_turf))
		target_turf = get_turf(target_turf)
	if(landslide_action && enhanced_landslide)
		landslide_action.enhanced_warnings += new warning_type(target_turf)
	else
		new warning_type(target_turf, duration)
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		shake_camera(affected_living, max(1, duration), 0.5)

/// Trying to use certain abilities on an Earth Pillar fires as a projectile in the user's cardinal direction.
/// See the following abilities, as well as the projectile itself, for specifics.
/datum/action/xeno_action/activable/behemoth/proc/do_projectile(obj/structure/earth_pillar/target_pillar, explode)
	playsound(target_pillar, pick(target_pillar.possible_hit_sounds), 40)
	var/turf/target_turf = get_turf(target_pillar)
	new /obj/effect/temp_visual/behemoth/landslide/hit(target_turf)
	QDEL_NULL(target_pillar)
	var/datum/ammo/xeno/earth_pillar/projectile
	if(explode)
		projectile = GLOB.ammo_list[/datum/ammo/xeno/earth_pillar/explosive]
	else
		projectile = GLOB.ammo_list[/datum/ammo/xeno/earth_pillar]
	var/obj/projectile/new_projectile = new /obj/projectile(target_turf)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	new_projectile.generate_bullet(projectile, xeno_owner.xeno_caste.melee_damage)
	new_projectile.fire_at(target_turf, xeno_owner, null, new_projectile.ammo.max_range)


// ***************************************
// *********** Roll
// ***************************************
#define BEHEMOTH_ROLL_WIND_UP 3 SECONDS

/datum/action/xeno_action/ready_charge/behemoth_roll
	name = "Roll"
	ability_name = "Roll"
	action_icon_state = "4"
	desc = "Curl up into a ball, sacrificing some offensive capabilities in exchange for greater movement speed."
	cooldown_timer = 25 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_BEHEMOTH_ROLL,
	)
	agile_charge = TRUE
	charge_type = CHARGE_BULL
	speed_per_step = 0.15
	steps_for_charge = 3
	max_steps_buildup = 10
	crush_living_damage = 0
	plasma_use_multiplier = 0

/datum/action/xeno_action/ready_charge/behemoth/roll/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!charge_ability_on)
		if(!do_after(xeno_owner, BEHEMOTH_ROLL_WIND_UP, FALSE, xeno_owner, BUSY_ICON_DANGER))
			return fail_activate()
		charge_on()
		xeno_owner.update_icons()
		add_cooldown(5 SECONDS)
		return
	charge_off()
	xeno_owner.update_icons()
	add_cooldown(5 SECONDS)


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
#define LANDSLIDE_DAMAGE_OBJECT_MODIFIER 7
#define LANDSLIDE_DAMAGE_TURF_MODIFIER 30

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

/datum/action/xeno_action/activable/behemoth/landslide
	name = "Landslide"
	ability_name = "Landslide"
	action_icon_state = "4"
	desc = "Rush forward in the selected direction, damaging enemies caught in a wide path."
	plasma_cost = 2.5 // This is deducted per step taken during the ability.
	cooldown_timer = 25 SECONDS
	target_flags = XABB_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LANDSLIDE,
	)
	wind_up_duration = LANDSLIDE_WIND_UP
	/// List containing possible sound effects that are played during this ability.
	var/list/possible_step_sounds = list(
		'sound/effects/alien_footstep_large1.ogg',
		'sound/effects/alien_footstep_large2.ogg',
		'sound/effects/alien_footstep_large3.ogg')
	/// List containing the selected turfs for the Enhanced version of this ability.
	var/list/turf/enhanced_turfs = list()
	/// List containing the warnings in the selected turfs for the Enhanced version of this ability.
	var/list/turf/enhanced_warnings = list()

/datum/action/xeno_action/activable/behemoth/landslide/use_ability(atom/target)
	. = ..()
	if(ability_active)
		end_charge(1)
		return
	var/turf/owner_turf = get_turf(owner)
	var/direction = get_cardinal_dir(owner, target)
	var/turf/direct_turf = get_step(owner, direction)
	var/turf/target_turf = get_turf(target)
	if(LinkBlocked(owner_turf, direct_turf) || owner_turf == target_turf)
		owner.balloon_alert(owner, "No space")
		return
	ability_active = TRUE
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	playsound(owner, 'sound/effects/behemoth/landslide_roar.ogg', 40, TRUE)
	var/which_step = pick(0, 1)
	new /obj/effect/temp_visual/behemoth/landslide/dust(owner_turf, direction, which_step)
	if(primal_wrath_action?.ability_active)
		add_cooldown(wind_up_duration)
		enhanced_turfs += owner_turf
		enhanced_check_charge()
		RegisterSignal(owner, COMSIG_MOB_CLICKON, PROC_REF(enhanced_prepare_charge))
		return
	add_cooldown(5 SECONDS)
	do_warning(get_affected_turfs(owner_turf, direction, LANDSLIDE_RANGE), wind_up_duration + 0.5 SECONDS)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/charge_damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier
	addtimer(CALLBACK(src, PROC_REF(do_charge), owner_turf, direction, charge_damage, which_step), wind_up_duration)

/// Gets a list of the turfs affected by this ability, based on direction and range.
/// - origin_turf: The origin turf from which to start checking.
/// - direction: The direction to check in.
/// - range: The range in tiles to limit our checks to.
/datum/action/xeno_action/activable/behemoth/landslide/proc/get_affected_turfs(turf/origin_turf, direction, range)
	if(!range)
		return
	var/list/turf/turfs_list = list(origin_turf)
	var/list/turf/turfs_to_check = list()
	for(var/turf/turf_to_check AS in get_line(origin_turf, get_ranged_target_turf(origin_turf, direction, range)))
		if(turf_to_check in turfs_list)
			continue
		turfs_to_check += turf_to_check
	for(var/turf/turf_to_check AS in turfs_to_check)
		for(var/turf/adjacent_turf AS in get_adjacent_open_turfs(turf_to_check))
			if((adjacent_turf in turfs_to_check) || (adjacent_turf in turfs_list) || get_dir(origin_turf, adjacent_turf) != direction)
				continue
			turfs_to_check += adjacent_turf
	for(var/turf/turf_to_check AS in turfs_to_check)
		if(LinkBlocked(origin_turf, turf_to_check) || !line_of_sight(origin_turf, turf_to_check, range))
			continue
		turfs_list += turf_to_check
	return turfs_list

/// Moves the user in the specified direction. This simulates movement by using step() and repeatedly calling itself.
/// Will repeatedly check a 3x1 rectangle in front of the user, applying its effects to valid targets and stopping early if the path is blocked.
/// - owner_turf: The turf where the owner is.
/// - direction: The direction to move in.
/// - damage: The damage we will deal to valid targets.
/// - which_step: Used to determine the initial positioning of visual effects.
/datum/action/xeno_action/activable/behemoth/landslide/proc/do_charge(turf/owner_turf, direction, damage, which_step)
	if(!ability_active)
		return
	if(owner.stat)
		end_charge()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.plasma_stored < plasma_cost)
		end_charge(2)
		return
	succeed_activate()
	var/direct_turf = get_step(owner, direction)
	if(iswallturf(direct_turf))
		var/turf/closed/wall/affected_wall = direct_turf
		if(affected_wall.wall_integrity <= damage * LANDSLIDE_DAMAGE_TURF_MODIFIER && affected_wall.resistance_flags != INDESTRUCTIBLE)
			playsound(direct_turf, 'sound/effects/meteorimpact.ogg', 30, TRUE)
			affected_wall.dismantle_wall()
	var/list/turf/affected_turfs = list(direct_turf)
	affected_turfs += get_step(xeno_owner, turn(direction, 45))
	affected_turfs += get_step(xeno_owner, turn(direction, -45))
	for(var/turf/affected_turf AS in affected_turfs)
		for(var/atom/movable/affected_atom AS in affected_turf)
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

/// Ends the charge.
/// - reason: If specified, determines the reason why the charge ended, and does the respective balloon alert. Leave empty for no reason, and no feedback.
/datum/action/xeno_action/activable/behemoth/landslide/proc/end_charge(reason)
	ability_active = FALSE
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	if(cooldown_id)
		clear_cooldown()
	add_cooldown()
	if(length(enhanced_turfs))
		enhanced_turfs -= enhanced_turfs
	if(length(enhanced_warnings))
		enhanced_warnings -= enhanced_warnings
	switch(reason)
		if(1) // The user manually cancelled the ability at some point during its use.
			owner.balloon_alert(owner, "Cancelled")
		if(2) // During the charge, the user did not have enough plasma to satisfy the charge's cost.
			owner.balloon_alert(owner, "Insufficient plasma")
		if(3) // During the target selection phase for the Primal Wrath version of this ability, no selection was made.
			owner.balloon_alert(owner, "No selection made, cancelled")

/// Applies several effects to a living target.
/// - living_target: The targeted living mob.
/// - direct_turf: If specified, living targets in this turf will receive additional effects.
/// - damage: The damage inflicted by related effects.
/datum/action/xeno_action/activable/behemoth/landslide/proc/hit_living(mob/living/living_target, turf/direct_turf, damage, enhanced)
	if(living_target in direct_turf || enhanced)
		if(!living_target.lying_angle)
			living_target.Knockdown(LANDSLIDE_KNOCKDOWN_DURATION)
			new /obj/effect/temp_visual/behemoth/landslide/hit(direct_turf)
			playsound(living_target, 'sound/effects/behemoth/landslide_hit_mob.ogg', 30, TRUE)
		living_target.emote("scream")
		shake_camera(living_target, max(1, LANDSLIDE_KNOCKDOWN_DURATION), 1)
		living_target.apply_damage(damage, BRUTE, blocked = MELEE)
		return
	shake_camera(living_target, max(1, LANDSLIDE_KNOCKDOWN_DURATION), 0.5)
	living_target.do_jitter_animation(jitter_loops = 2)
	living_target.apply_damage(damage * LANDSLIDE_CHARGE_DAMAGE_ADJACENT_MODIFIER, BRUTE, blocked = MELEE)

/// Applies several effects to an object. Effects differ based on the object's type, with unique interactions for mechas and Earth Pillars.
/// - object_target: The targeted object.
/// - damage: The damage inflicted by related effects.
/// - ending: If TRUE, applies different effects to the target.
/datum/action/xeno_action/activable/behemoth/landslide/proc/hit_object(obj/object_target, damage, ending)
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
		return
	object_target.do_jitter_animation(jitter_loops = 3)
	new /obj/effect/temp_visual/behemoth/landslide/hit(object_turf)
	if(isearthpillar(object_target))
		var/obj/structure/earth_pillar/pillar_target = object_target
		do_projectile(pillar_target, TRUE)
		return
	if(ismecha(object_target))
		var/obj/vehicle/sealed/mecha/mecha_target = object_target
		mecha_target.take_damage(damage * LANDSLIDE_DAMAGE_MECHA_MODIFIER, MELEE)
		return
	object_target.take_damage(damage * LANDSLIDE_DAMAGE_OBJECT_MODIFIER, MELEE)

/// Applies several effects to a target turf, and its contents if applicable. Effects differ based on the turf type and its contents, with unique interactions for walls
/// and objects.
/// - turf_target: The targeted turf.
/// - damage: The damage inflicted by related effects.
/datum/action/xeno_action/activable/behemoth/landslide/proc/ending_hit(obj/turf_target, damage)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.do_attack_animation(turf_target)
	playsound(turf_target, 'sound/effects/behemoth/behemoth_stomp.ogg', 40)
	if(iswallturf(turf_target))
		var/turf/closed/wall/wall_target = turf_target
		new /obj/effect/temp_visual/behemoth/landslide/hit(wall_target)
		new /obj/effect/temp_visual/behemoth/crack(wall_target)
		wall_target.take_damage(damage * LANDSLIDE_DAMAGE_TURF_MODIFIER, MELEE)
	var/list/turf/affected_turfs = list(turf_target)
	affected_turfs += get_turf(owner)
	for(var/turf/affected_turf AS in affected_turfs)
		for(var/obj/affected_object in affected_turf)
			if(!affected_object.density || affected_object.resistance_flags & INDESTRUCTIBLE)
				continue
			hit_object(affected_object, damage, TRUE)

/// Runs any checks associated to the Enhanced version of this ability, ending it early if conditions are met.
/// - times_called: Counter for the amount of times this proc has been called. This is used to determine the amount of time spent during the selection phase,
/// cancelling the ability after some time.
/datum/action/xeno_action/activable/behemoth/landslide/proc/enhanced_check_charge(times_called)
	times_called++
	if(!ability_active || length(enhanced_turfs) > LANDSLIDE_ENHANCED_POSSIBLE_SELECTIONS)
		return
	if(owner.stat)
		end_charge()
		return
	if(times_called >= LANDSLIDE_ENHANCED_WAIT_TIME / LANDSLIDE_ENHANCED_WAIT_DELAY)
		end_charge(3)
		return
	addtimer(CALLBACK(src, PROC_REF(enhanced_check_charge), times_called), LANDSLIDE_ENHANCED_WAIT_DELAY)

/// Prepares selections made during the selection phase of this ability. Selected turfs are processed and adapted to the ability for their later usage.
/// If the maximum amount of selections has been reached, this proc will end the selection phase and execute the charge.
/// - source: References the source of this proc. Usually the owner.
/// - selected_atom: The atom that was selected by the user. This is later converted into a turf.
/datum/action/xeno_action/activable/behemoth/landslide/proc/enhanced_prepare_charge(datum/source, atom/selected_atom)
	SIGNAL_HANDLER
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
	do_warning(get_affected_turfs(origin_turf, get_dir(origin_turf, corrected_turf), get_dist(origin_turf, corrected_turf)), LANDSLIDE_ENHANCED_WAIT_TIME, TRUE)
	enhanced_turfs += corrected_turf
	if(length(enhanced_turfs) > LANDSLIDE_ENHANCED_POSSIBLE_SELECTIONS)
		var/numeric_counter
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
		var/charge_damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier
		var/charge_direction = get_dir(enhanced_turfs[1], enhanced_turfs[2])
		new /obj/effect/temp_visual/behemoth/crack/landslide(get_turf(owner), charge_direction, pick(1, 2))
		var/charge_distance = get_dist(enhanced_turfs[1], enhanced_turfs[2])
		if(ISDIAGONALDIR(charge_direction) && charge_distance >= LANDSLIDE_RANGE)
			charge_distance--
		var/animation_time = charge_distance * LANDSLIDE_ENHANCED_STEP_DELAY
		animate(xeno_owner, pixel_y = xeno_owner.pixel_y + (charge_distance / 2), time = animation_time / 2, flags = ANIMATION_END_NOW, easing = CIRCULAR_EASING|EASE_OUT)
		animate(pixel_y = initial(xeno_owner.pixel_y), time = animation_time / 2, flags = CIRCULAR_EASING|EASE_IN)
		playsound(xeno_owner, 'sound/effects/behemoth/landslide_enhanced_charge.ogg', 15, TRUE)
		INVOKE_ASYNC(src, PROC_REF(enhanced_do_charge), charge_direction, charge_damage, LANDSLIDE_ENHANCED_STEP_DELAY, charge_distance)

/// Moves the user between the selections previously made. This simulates movement by using step() and repeatedly calling itself.
/// Will repeatedly check a 3x1 rectangle in front of the user, applying its effects to valid targets and stopping early if the path is blocked.
/// - direction: The direction to move in.
/// - damage: The damage we will deal to valid targets.
/// - speed: The speed at which we move. This is reduced when we're nearing our destination, to simulate a slow-down effect.
/// - steps_to_take: The amount of steps needed to reach our destination. This is used to determine when to move on to the next selection.
/// - which_charge: Which charge, or which selection, are we currently executing.
/// - steps_taken: The amount of steps we have taken. This is used to determine when to move on to the next selection.
/datum/action/xeno_action/activable/behemoth/landslide/proc/enhanced_do_charge(direction, damage, speed, steps_to_take, which_charge = 1)
	if(!ability_active)
		return
	if(owner.stat)
		end_charge()
		return
	var/owner_turf = get_turf(owner)
	var/direct_turf = get_step(owner, direction)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(LinkBlocked(owner_turf, direct_turf) || steps_to_take <= 0 || xeno_owner.plasma_stored < plasma_cost)
		if(LinkBlocked(owner_turf, direct_turf))
			shake_camera(xeno_owner, 1, 0.5)
			ending_hit(direct_turf, damage)
		enhanced_next_charge(direction, damage, which_charge)
		return
	succeed_activate()
	if(iswallturf(direct_turf))
		var/turf/closed/wall/affected_wall = direct_turf
		if(affected_wall.wall_integrity <= damage * LANDSLIDE_DAMAGE_TURF_MODIFIER && affected_wall.resistance_flags != INDESTRUCTIBLE)
			playsound(direct_turf, 'sound/effects/meteorimpact.ogg', 30)
			affected_wall.dismantle_wall()
	var/list/turf/affected_turfs = list(direct_turf)
	affected_turfs += get_step(xeno_owner, turn(direction, 45))
	affected_turfs += get_step(xeno_owner, turn(direction, -45))
	for(var/turf/affected_turf AS in affected_turfs)
		for(var/atom/movable/affected_atom in affected_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				hit_living(affected_living, direct_turf, damage, TRUE)
			if(!(affected_atom in direct_turf))
				continue
			if(isobj(affected_atom))
				var/obj/affected_object = affected_atom
				hit_object(affected_object, damage)
	steps_to_take--
	step(xeno_owner, direction, 1)
	if(steps_to_take <= 2)
		speed += 0.5
		new /obj/effect/temp_visual/behemoth/landslide/dust/charge(owner_turf, direction)
	addtimer(CALLBACK(src, PROC_REF(enhanced_do_charge), direction, damage, speed, steps_to_take, which_charge), speed)

/// Handles everything necessary before beginning the next charge.
/// - direction: The direction we will move in.
/// - damage: The damage we will deal in related effects.
/// - which_charge: Which charge, or which selection, we will execute.
/datum/action/xeno_action/activable/behemoth/landslide/proc/enhanced_next_charge(direction, damage, which_charge)
	which_charge++
	if(which_charge >= length(enhanced_turfs))
		end_charge()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.plasma_stored < plasma_cost)
		end_charge(2)
		return
	direction = get_dir(enhanced_turfs[which_charge], enhanced_turfs[which_charge + 1])
	new /obj/effect/temp_visual/behemoth/crack/landslide(get_turf(owner), direction, pick(1, 2))
	var/steps_to_take = get_dist(enhanced_turfs[which_charge], enhanced_turfs[which_charge + 1])
	var/animation_time = steps_to_take * LANDSLIDE_ENHANCED_STEP_DELAY
	animate(xeno_owner, time = LANDSLIDE_ENHANCED_CHARGE_DELAY, flags = ANIMATION_END_NOW)
	animate(pixel_y = xeno_owner.pixel_y + (steps_to_take / 2), time = animation_time / 2, easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(xeno_owner.pixel_y), time = animation_time / 2, easing = CIRCULAR_EASING|EASE_IN)
	addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(playsound), xeno_owner, 'sound/effects/behemoth/landslide_enhanced_charge.ogg', 15, TRUE), LANDSLIDE_ENHANCED_CHARGE_DELAY)
	addtimer(CALLBACK(src, PROC_REF(enhanced_do_charge), direction, damage, LANDSLIDE_ENHANCED_STEP_DELAY, steps_to_take, which_charge), LANDSLIDE_ENHANCED_CHARGE_DELAY)


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_WIND_UP 2 SECONDS
#define EARTH_RISER_RANGE 3

/obj/effect/temp_visual/behemoth/crack/earth_riser/Initialize(mapload, direction)
	. = ..()
	switch(direction)
		if(NORTH)
			pixel_x = 13
			pixel_y = -11
		if(SOUTH)
			pixel_x = -10
			pixel_y = -11
		if(WEST)
			pixel_x = -26
			pixel_y = -12
		if(EAST)
			pixel_x = 32
			pixel_y = -13

/datum/action/xeno_action/activable/behemoth/earth_riser
	name = "Earth Riser"
	ability_name = "Earth Riser"
	action_icon_state = "4"
	desc = "Raise a pillar of earth at the selected location. This solid structure can be used for defense, and it interacts with other abilities for offensive usage. Alternate use destroys active pillars, starting with the oldest one."
	plasma_cost = 15
	cooldown_timer = 15 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_EARTH_RISER,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_EARTH_RISER_ALTERNATE,
	)
	wind_up_duration = EARTH_RISER_WIND_UP
	/// Maximum amount of Earth Pillars that this ability can have.
	var/maximum_pillars = 1
	/// List that contains all Earth Pillars created by this ability.
	var/list/obj/structure/earth_pillar/active_pillars = list()

/datum/action/xeno_action/activable/behemoth/earth_riser/alternate_action_activate()
	if(!length(active_pillars))
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "No active pillars")
		return
	var/obj/structure/earth_pillar/oldest_pillar = active_pillars[1]
	new /obj/effect/temp_visual/behemoth/earth_pillar/broken(get_turf(oldest_pillar))
	QDEL_NULL(oldest_pillar)

/datum/action/xeno_action/activable/behemoth/earth_riser/use_ability(atom/target)
	. = ..()
	if(owner.Adjacent(target) && isearthpillar(target))
		do_projectile(target)
		add_cooldown()
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(length(active_pillars) >= maximum_pillars)
		xeno_owner.balloon_alert(xeno_owner, "Maximum amount of pillars reached")
		return
	var/turf/owner_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	if(!line_of_sight(owner, target, EARTH_RISER_RANGE) || LinkBlocked(owner_turf, target_turf))
		xeno_owner.balloon_alert(xeno_owner, "Out of range")
		return
	do_stomp(owner_turf)
	do_warning(target_turf, wind_up_duration)
	addtimer(CALLBACK(src, PROC_REF(do_ability), target_turf), wind_up_duration)
	add_cooldown(wind_up_duration)
	succeed_activate()
	new /obj/effect/temp_visual/behemoth/stomp/west(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf, owner.dir)

/// Checks if there's any living mobs in the target turf, and displaces them if so.
/// Also creates a new Earth Pillar and adds it to the list of active pillars.
/datum/action/xeno_action/activable/behemoth/earth_riser/proc/do_ability(turf/target_turf)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		shake_camera(affected_living, 1, 0.5)
		step_away(affected_living, target_turf, 1, 2)
	active_pillars += new /obj/structure/earth_pillar(target_turf, src)


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
			pixel_x = -13
			pixel_y = -11
		if(SOUTH)
			pixel_x = 10
			pixel_y = -11
		if(WEST)
			pixel_x = -12
			pixel_y = -12
		if(EAST)
			pixel_x = 19
			pixel_y = -12

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

/datum/action/xeno_action/activable/behemoth/seismic_fracture
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
	wind_up_duration = SEISMIC_FRACTURE_WIND_UP
	/// List of living mobs that will be affected by the attack.
	var/list/mob/living/living_to_attack

/datum/action/xeno_action/activable/behemoth/seismic_fracture/use_ability(atom/target)
	. = ..()
	if(!line_of_sight(owner, target, SEISMIC_FRACTURE_RANGE))
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "Out of range")
		return
	var/owner_turf = get_turf(owner)
	new /obj/effect/temp_visual/behemoth/stomp/east(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf, owner.dir)
	do_stomp(owner_turf)
	do_ability(get_turf(target), wind_up_duration)

/// Second part of use_ability(). Gets the turfs affected by this ability, which are then passed along to the following procs.
/// This has to be cut off from use_ability() to optimize code, due to an interaction with Earth Pillars.
/// Earth Pillars caught in the range of Seismic Fracture reflect the attack by calling this proc again.
/// If Primal Wrath is active, Seismic Fracture changes to cover more turfs.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/do_ability(turf/target_turf, duration = wind_up_duration, instant)
	var/list/turf/turfs_to_attack = filled_turfs(target_turf, SEISMIC_FRACTURE_ATTACK_RADIUS, bypass_window = TRUE, projectile = TRUE)
	if(!length(turfs_to_attack)) // Just in case.
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "Unable to use here")
		return
	if(instant)
		do_attack(target_turf, turfs_to_attack, TRUE)
		return
	add_cooldown()
	succeed_activate()
	do_warning(turfs_to_attack, duration)
	addtimer(CALLBACK(src, PROC_REF(do_attack), target_turf, turfs_to_attack), duration)
	if(primal_wrath_action?.ability_active)
		new /obj/effect/temp_visual/shockwave/enhanced(get_turf(owner), SEISMIC_FRACTURE_ATTACK_RADIUS, owner.dir)
		playsound(owner, 'sound/effects/behemoth/landslide_roar.ogg', 50, TRUE)
		var/list/turf/extra_turfs_to_warn = filled_turfs(target_turf, SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS, bypass_window = TRUE, projectile = TRUE)
		for(var/turf/extra_turf_to_warn AS in extra_turfs_to_warn)
			if(isclosedturf(extra_turf_to_warn))
				extra_turfs_to_warn -= extra_turf_to_warn
		if(length(extra_turfs_to_warn) && length(turfs_to_attack))
			extra_turfs_to_warn -= turfs_to_attack
		do_warning(extra_turfs_to_warn, duration + SEISMIC_FRACTURE_ENHANCED_DELAY)
		var/list/turf/extra_turfs = filled_turfs(target_turf, SEISMIC_FRACTURE_ATTACK_RADIUS + 1, bypass_window = TRUE, projectile = TRUE)
		if(length(extra_turfs) && length(turfs_to_attack))
			extra_turfs -= turfs_to_attack
		var/initial_iteration = SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS - SEISMIC_FRACTURE_ATTACK_RADIUS
		addtimer(CALLBACK(src, PROC_REF(do_attack_extra), target_turf, extra_turfs, turfs_to_attack, SEISMIC_FRACTURE_ENHANCED_ATTACK_RADIUS, initial_iteration), duration + SEISMIC_FRACTURE_ENHANCED_DELAY)

/// The additional attacks caused by Primal Wrath are done iteratively rather than instantly, as handled here.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/do_attack_extra(turf/origin_turf, list/turf/extra_turfs, list/turf/excepted_turfs, range, iteration)
	if(iteration > range)
		return
	var/list/turfs_to_add = list()
	var/list/turfs_to_remove = list()
	for(var/turf/extra_turf AS in extra_turfs)
		turfs_to_remove += extra_turf
		do_attack(extra_turf, extra_turf)
		var/list/turfs_to_check = get_adjacent_open_turfs(extra_turf)
		for(var/turf/turf_to_check AS in turfs_to_check)
			if((turf_to_check in extra_turfs) || (turf_to_check in excepted_turfs) || (turf_to_check in turfs_to_add))
				continue
			if(!line_of_sight(origin_turf, turf_to_check) || LinkBlocked(origin_turf, turf_to_check, TRUE, TRUE))
				continue
			turfs_to_add += turf_to_check
	extra_turfs += turfs_to_add
	extra_turfs -= turfs_to_remove
	excepted_turfs += turfs_to_remove
	iteration++
	addtimer(CALLBACK(src, PROC_REF(do_attack_extra), origin_turf, extra_turfs, excepted_turfs, range, iteration), SEISMIC_FRACTURE_ENHANCED_DELAY)

/// Checks for any atoms caught in the attack's range. Effects vary based on the atom type, with two possibilities:
/// - Living mobs are paralyzed and damaged, with a cool animation. They are invincible during its duration, and they will also be affected by living_landing().
/// - Objects receive increased damage. Further increased if the object is a mecha.
/// Primal Wrath alters the functionality of this proc to only affect target_turf, and changes the visual effects.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/do_attack(turf/target_turf, list/turf/turfs_to_attack, instant, enhanced)
	if(!turfs_to_attack || !length(turfs_to_attack))
		turfs_to_attack = list(target_turf)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/attack_damage = xeno_owner.xeno_caste.melee_damage * xeno_owner.xeno_melee_damage_modifier
	for(var/turf/affected_turf AS in turfs_to_attack)
		if(isclosedturf(affected_turf))
			continue
		new /obj/effect/temp_visual/behemoth/crack(affected_turf)
		playsound(target_turf, 'sound/effects/behemoth/seismic_fracture_explosion.ogg', 15)
		for(var/atom/movable/affected_atom AS in affected_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				affected_living.emote("scream")
				shake_camera(affected_living, max(1, SEISMIC_FRACTURE_PARALYZE_DURATION), 1)
				affected_living.Paralyze(SEISMIC_FRACTURE_PARALYZE_DURATION)
				affected_living.apply_damage(attack_damage, BRUTE, blocked = MELEE)
				if(!instant)
					affected_living.layer = ABOVE_MOB_LAYER
					affected_living.status_flags |= (INCORPOREAL|GODMODE)
					animate(affected_living, pixel_y = affected_living.pixel_y + 40, layer = ABOVE_MOB_LAYER, time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW)
					animate(pixel_y = initial(affected_living.pixel_y), time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_IN)
					addtimer(CALLBACK(src, PROC_REF(living_landing), affected_living), SEISMIC_FRACTURE_PARALYZE_DURATION)
			if(isobj(affected_atom))
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
					playsound(affected_pillar, pick(affected_pillar.possible_hit_sounds), 40)
					new /obj/effect/temp_visual/behemoth/landslide/hit(affected_turf)
					do_ability(affected_turf, initial(affected_pillar.warning_flashes) * 10)
					continue
				affected_object.take_damage(attack_damage * SEISMIC_FRACTURE_DAMAGE_OBJECT_MODIFIER, MELEE)
		if(!primal_wrath_action?.ability_active)
			new /obj/effect/temp_visual/behemoth/seismic_fracture(affected_turf)
			continue
		new /obj/effect/temp_visual/behemoth/seismic_fracture/enhanced(affected_turf, FALSE)

/// Continuation for do_attack(). Living mobs that were previously caught in the attack's radius are subject to a landing effect.
/// Their invincibility is removed, and they receive a reduced amount of damage.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/living_landing(mob/living/affected_living)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	affected_living.layer = initial(affected_living.layer)
	affected_living.status_flags &= ~(INCORPOREAL|GODMODE)
	affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 3, BRUTE, blocked = MELEE)
	var/landing_turf = get_turf(affected_living)
	playsound(landing_turf, 'sound/effects/behemoth/seismic_fracture_landing.ogg', 10)
	new /obj/effect/temp_visual/behemoth/stomp(landing_turf)


// ***************************************
// *********** Primal Wrath
// ***************************************
#define PRIMAL_WRATH_ACTIVATION_DURATION 3.5 SECONDS // Timed with the sound played.
#define PRIMAL_WRATH_DAMAGE_MULTIPLIER 1.2

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
	/// References an active Primal Wrath buff, if any.
	var/datum/status_effect/wrath_handler/wrath_handler_status

/datum/action/xeno_action/primal_wrath/give_action(mob/living/L)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_owner = L
	wrath_handler_status = xeno_owner.apply_status_effect(STATUS_EFFECT_XENO_WRATH_HANDLER, src)

/datum/action/xeno_action/primal_wrath/remove_action(mob/living/L)
	. = ..()
	QDEL_NULL(wrath_handler_status)

/datum/action/xeno_action/primal_wrath/action_activate()
	if(ability_active) // delete this after debugging
		owner.balloon_alert(owner, "OFF")
		ability_active = FALSE
		return
	ability_active = TRUE
	wrath_handler_status.toggle_damage_increase(PRIMAL_WRATH_DAMAGE_MULTIPLIER)
	toggle_immobilize()
	addtimer(CALLBACK(src, PROC_REF(toggle_immobilize)), PRIMAL_WRATH_ACTIVATION_DURATION)
	var/owner_turf = get_turf(owner)
	playsound(owner_turf, 'sound/effects/behemoth/primal_wrath_roar.ogg', 75, TRUE)
	for(var/mob/living/affected_living in hearers(WORLD_VIEW, owner_turf))
		if(!affected_living.hud_used)
			continue
		var/atom/movable/screen/plane_master/floor/floor_plane = affected_living.hud_used.plane_masters["[FLOOR_PLANE]"]
		var/atom/movable/screen/plane_master/game_world/world_plane = affected_living.hud_used.plane_masters["[GAME_PLANE]"]
		addtimer(CALLBACK(floor_plane, TYPE_PROC_REF(/atom, remove_filter), "primal_wrath"), PRIMAL_WRATH_ACTIVATION_DURATION)
		if(affected_living.client?.prefs.safe_visuals) // Some players feel sick with the effect, so allow them to get gaussian blur instead.
			floor_plane.add_filter("primal_wrath", 2, gauss_blur_filter(1.2))
			world_plane.add_filter("primal_wrath", 2, gauss_blur_filter(1.2))
		else
			world_plane.add_filter("primal_wrath", 2, radial_blur_filter(0.07))
			animate(world_plane.get_filter("primal_wrath"), size = 0.12, time = 5, loop = -1)
			floor_plane.add_filter("primal_wrath", 2, radial_blur_filter(0.07))
			animate(floor_plane.get_filter("primal_wrath"), size = 0.12, time = 5, loop = -1)
		addtimer(CALLBACK(world_plane, TYPE_PROC_REF(/atom, remove_filter), "primal_wrath"), PRIMAL_WRATH_ACTIVATION_DURATION)
	succeed_activate()
	add_cooldown()

/// Toggles the Immobilize trait on or off.
/datum/action/xeno_action/primal_wrath/proc/toggle_immobilize()
	if(HAS_TRAIT(src, TRAIT_IMMOBILE))
		REMOVE_TRAIT(src, TRAIT_IMMOBILE, TRAIT_GENERIC)
		return
	ADD_TRAIT(src, TRAIT_IMMOBILE, TRAIT_GENERIC)


// ***************************************
// *********** Earth Pillar (also see: Earth Riser)
// ***************************************
#define EARTH_PILLAR_KNOCKDOWN_DURATION 0.5 SECONDS
#define EARTH_PILLAR_DAMAGE_MECHA_MODIFIER 5
#define EARTH_PILLAR_DAMAGE_OBJECT_MODIFIER 2
#define EARTH_PILLAR_DAMAGE_TURF_MODIFIER 5

/obj/effect/temp_visual/behemoth/earth_pillar
	duration = 2 SECONDS
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/behemoth/earth_pillar/Initialize(mapload)
	. = ..()
	layer += 0.01

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
	position = generator(GEN_CIRCLE, 14, 14, UNIFORM_RAND)
	velocity = list(0, 0.2)
	scale = generator(GEN_NUM, 0.3, 0.5, UNIFORM_RAND)
	grow = 0.05
	spin = generator(GEN_NUM, 10, 20)

// This is a structure that can be created by the Earth Riser ability. See it for specifics.
/obj/structure/earth_pillar
	name = "earth pillar"
	icon = 'icons/effects/effects.dmi'
	icon_state = "earth_pillar"
	base_icon_state = "earth_pillar"
	layer = ABOVE_LYING_MOB_LAYER
	climbable = TRUE
	climb_delay = 3 SECONDS
	density = TRUE
	max_integrity = 300
	soft_armor = list(MELEE = 0, BULLET = 25, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, FIRE = 100, ACID = 0)
	var/possible_hit_sounds = list('sound/effects/behemoth/earth_pillar_hit_1.ogg',
	'sound/effects/behemoth/earth_pillar_hit_2.ogg',
	'sound/effects/behemoth/earth_pillar_hit_3.ogg',
	'sound/effects/behemoth/earth_pillar_hit_4.ogg',
	'sound/effects/behemoth/earth_pillar_hit_5.ogg',
	'sound/effects/behemoth/earth_pillar_hit_6.ogg')
	destroy_sound = 'sound/effects/behemoth/earth_pillar_destroyed.ogg'
	/// List of possible messages a Behemoth gets when they click this object in help intent.
	var/possible_eating_messages = list("We eat away at the stone. It tastes good, as expected of our primary diet.",
	"Mmmmm... Delicious rock. A fitting meal for the hardiest of monsters.",
	"This boulder -- its flavor fills us with glee. Our palate is thoroughly satisfied.",
	"The minerals in this crag are tasty! We want more!",
	"Eating this stone makes us think; is our hide tougher? It is. It must be.",
	"A delectable flavor. Just one bite is not enough...",
	"One bite, two bites... why not just finish the whole rock?",
	"The stone. The rock. The boulder. The crag. Its name matters not when we consume it.",
	"We're eating this boulder. It has other uses... Is this really a good idea?",
	"Delicious, delectable, simply exquisite. Just a few more minerals and it'd be perfect...")
	/// References the user's Earth Riser ability, if any.
	var/datum/action/xeno_action/activable/behemoth/earth_riser/earth_riser_action
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	/// The amount of times a xeno needs to attack this to destroy it.
	var/attacks_to_destroy = 3
	/// The amount of times an Earth Pillar flashes before executing its interaction with Seismic Fracture.
	var/warning_flashes = 3

/obj/structure/earth_pillar/Initialize(mapload, earth_riser_reference)
	. = ..()
	if(earth_riser_reference)
		earth_riser_action = earth_riser_reference
	playsound(src, 'sound/effects/behemoth/earth_pillar_rising.ogg', 40)
	particle_holder = new(src, /particles/earth_pillar)
	particle_holder.pixel_y = -4
	animate(particle_holder, pixel_y = 4, time = 1.0 SECONDS)
	animate(alpha = 0, time = 0.6 SECONDS)
	QDEL_NULL_IN(src, particle_holder, 1.6 SECONDS)
	do_jitter_animation(jitter_loops = 5)

/obj/structure/earth_pillar/Destroy()
	playsound(src, destroy_sound, 40)
	if(earth_riser_action && (src in earth_riser_action.active_pillars))
		earth_riser_action.active_pillars -= src
	return ..()

/obj/structure/earth_pillar/attacked_by(obj/item/I, mob/living/user, def_zone)
	. = ..()
	playsound(src, pick(possible_hit_sounds), 40)
	new /obj/effect/temp_visual/behemoth/landslide/hit(get_turf(src))

// Attacking an Earth Pillar as a xeno has a few possible interactions, based on intent:
// - Harm intent will reduce a counter in this structure. When the counter hits zero, the structure is destroyed, meaning it is much easier to break it as a xeno.
// - Help intent as a Behemoth will trigger an easter egg. Does nothing, just fluff.
/obj/structure/earth_pillar/attack_alien(mob/living/carbon/xenomorph/xeno_owner, isrightclick = FALSE)
	var/current_turf = get_turf(src)
	switch(xeno_owner.a_intent)
		if(INTENT_HARM)
			if(attacks_to_destroy <= 1)
				xeno_owner.do_attack_animation(src)
				xeno_owner.balloon_alert(xeno_owner, "Destroyed")
				new /obj/effect/temp_visual/behemoth/landslide/hit(current_turf)
				new /obj/effect/temp_visual/behemoth/earth_pillar/broken(current_turf)
				Destroy()
				return TRUE
			attacks_to_destroy--
			xeno_owner.do_attack_animation(src)
			do_jitter_animation(jitter_loops = 1)
			playsound(src, pick(possible_hit_sounds), 40)
			xeno_owner.balloon_alert(xeno_owner, "Attack [attacks_to_destroy] more time(s) to destroy")
			new /obj/effect/temp_visual/behemoth/landslide/hit(current_turf)
			return TRUE
		if(INTENT_HELP)
			if(isxenobehemoth(xeno_owner))
				xeno_owner.do_attack_animation(src)
				do_jitter_animation(jitter_loops = 1)
				playsound(src, 'sound/effects/behemoth/earth_pillar_eating.ogg', 10, TRUE)
				xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] eats away at the [src.name]!"), \
				span_xenonotice(pick(possible_eating_messages)), null, 5)
				return TRUE
			return FALSE

/obj/structure/earth_pillar/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			Destroy()
		if(EXPLODE_HEAVY)
			take_damage(max_integrity / 2)
		if(EXPLODE_LIGHT)
			take_damage(max_integrity / 3)

/// Called by Seismic Fracture's do_attack() proc.
/// Seismic Fracture (as in the ability) has a special interaction with any Earth Pillars caught in its attack range.
/// Those Earth Pillars will reflect the same attack in a similar range around it, destroying itself afterwards.
/obj/structure/earth_pillar/proc/seismic_fracture()
	if(warning_flashes <= 0)
		new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(get_turf(src))
		qdel(src)
		return
	warning_flashes--
	addtimer(CALLBACK(src, PROC_REF(seismic_fracture)), 1 SECONDS)
	animate(src, color = "#FF6A00", time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(color = "#FFFFFF", time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_IN, flags = ANIMATION_PARALLEL)

// Earth Riser is capable of interacting with existing Earth Pillars to fire a projectile.
// See the Earth Riser ability for specifics.
/datum/ammo/xeno/earth_pillar
	name = "rock"
	icon_state = "earth_pillar"
	sound_hit = 'sound/effects/behemoth/earth_pillar_destroyed.ogg'
	sound_bounce = 'sound/effects/behemoth/earth_pillar_destroyed.ogg'
	ping = null
	bullet_color = COLOR_WHITE
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS
	shell_speed = 1
	accuracy = 100
	damage_falloff = 0
	damage_type = BRUTE
	armor_type = MELEE

/// Called by other on_hit_ procs.
/// Handles anything that would happen after the projectile hits something.
/datum/ammo/xeno/earth_pillar/proc/on_hit_anything(atom/hit_atom, obj/projectile/proj, explosion)
	var/atom_turf = get_turf(hit_atom)
	playsound(atom_turf, sound_hit, 40)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(atom_turf)

/datum/ammo/xeno/earth_pillar/on_hit_mob(mob/victim, obj/projectile/proj, explosion)
	. = ..()
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
	return on_hit_anything(victim, proj, explosion)

/datum/ammo/xeno/earth_pillar/on_hit_obj(obj/object, obj/projectile/proj, explosion)
	. = ..()
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/projectile_damage = xeno_firer?.xeno_caste.melee_damage * xeno_firer?.xeno_melee_damage_modifier
	if(ismecha(object))
		var/obj/vehicle/sealed/mecha/mecha_object = object
		mecha_object.take_damage(projectile_damage * EARTH_PILLAR_DAMAGE_MECHA_MODIFIER, MELEE)
		return on_hit_anything(object, proj)
	object.take_damage(projectile_damage * EARTH_PILLAR_DAMAGE_OBJECT_MODIFIER, MELEE)
	return on_hit_anything(object, proj, explosion)

/datum/ammo/xeno/earth_pillar/on_hit_turf(turf/hit_turf, obj/projectile/proj)
	. = ..()
	if(!iswallturf(hit_turf) || hit_turf.resistance_flags != INDESTRUCTIBLE)
		return
	var/turf/closed/wall/hit_wall = hit_turf
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/projectile_damage = xeno_firer?.xeno_caste.melee_damage * xeno_firer?.xeno_melee_damage_modifier
	hit_wall.take_damage(projectile_damage * EARTH_PILLAR_DAMAGE_TURF_MODIFIER, MELEE)
	return on_hit_anything(hit_turf, proj)

/datum/ammo/xeno/earth_pillar/explosive
	bullet_color = COLOR_LIGHT_ORANGE

/datum/ammo/xeno/earth_pillar/explosive/on_hit_anything(atom/hit_atom, obj/projectile/proj)
	. = ..()
	if(!isxeno(proj.firer))
		return
	var/mob/living/carbon/xenomorph/xeno_firer = proj.firer
	var/datum/action/xeno_action/activable/behemoth/seismic_fracture/seismic_fracture_action = xeno_firer.actions_by_path?[/datum/action/xeno_action/activable/behemoth/seismic_fracture]
	if(seismic_fracture_action)
		seismic_fracture_action.do_ability(get_turf(hit_atom), instant = TRUE)
