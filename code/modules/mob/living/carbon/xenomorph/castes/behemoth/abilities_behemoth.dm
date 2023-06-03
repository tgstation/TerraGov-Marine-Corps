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
	var/matrix/scale_change = matrix()
	transform = scale_change.Scale(0.6, 0.6)
	scale_change.Scale(2.0, 2.0)
	animate(src, alpha = 0, transform = scale_change, time = duration - 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

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
	duration = 6 SECONDS
	layer = ABOVE_TURF_LAYER

/obj/effect/temp_visual/behemoth/crack/Initialize(mapload, direction, effect_layer = layer)
	. = ..()
	layer = effect_layer + 0.01
	animate(src, time = duration - 1 SECONDS)
	animate(alpha = 0, time = 1 SECONDS)

/obj/effect/temp_visual/behemoth/crack/west/Initialize(mapload, direction, effect_layer = layer)
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

/obj/effect/temp_visual/behemoth/crack/east/Initialize(mapload, direction, effect_layer = layer)
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

/obj/effect/temp_visual/behemoth/warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "generic_warning"
	layer = BELOW_MOB_LAYER
	color = "#FFD800"

/obj/effect/temp_visual/behemoth/warning/Initialize(mapload, warning_duration)
	. = ..()
	duration = warning_duration
	animate(src, time = duration - 0.5 SECONDS)
	animate(alpha = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/warning/wrath
	color = "#FF0000"


// ***************************************
// *********** Activable Parent
// ***************************************
// This ability is exclusively here to house some stuff as a parent ability, and therefore reduce the amount of repeat code.
#define BEHEMOTH_STOMP_KNOCKDOWN_DURATION 1 SECONDS

/datum/action/xeno_action/activable/behemoth
	/// Whether this ability is currently active or not.
	var/ability_active = FALSE
	/// The sound that is played in ability warnings.
	var/warning_sound = 'sound/effects/behemoth/behemoth_rumble.ogg'
	/// The duration of the ability's wind-up process.
	var/wind_up_duration = 1 SECONDS
	/// References the Landslide action, if any.
	var/datum/action/xeno_action/activable/behemoth/landslide/landslide_action
	/// References the Primal Wrath action, if any.
	var/datum/action/xeno_action/primal_wrath/primal_wrath_action

/datum/action/xeno_action/activable/behemoth/use_ability(atom/target)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	landslide_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/activable/behemoth/landslide]
	if(landslide_action && !landslide_action.ability_active)
		owner.dir = get_cardinal_dir(owner, target)

/// Punishes anyone on the same tile as the Behemoth with a stomp, which damages the victim and knocks them down.
/datum/action/xeno_action/activable/behemoth/proc/do_stomp(target_turf)
	if(!isturf(target_turf))
		target_turf = get_turf(target_turf)
	playsound(target_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 30)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		affected_living.emote("scream")
		shake_camera(affected_living, BEHEMOTH_STOMP_KNOCKDOWN_DURATION / 2, 1)
		affected_living.Knockdown(BEHEMOTH_STOMP_KNOCKDOWN_DURATION)
		affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 2, BRUTE, blocked = MELEE)

/// Warns nearby players, in any way or form, of the incoming ability and the range it will affect.
/// Accepts lists, applying its effects to the contents.
/datum/action/xeno_action/activable/behemoth/proc/do_warning(target_turf, duration)
	if(!duration)
		return
	if(duration <= wind_up_duration && warning_sound)
		playsound(target_turf, warning_sound, 30)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	primal_wrath_action = xeno_owner.actions_by_path?[/datum/action/xeno_action/primal_wrath]
	var/warning_type = /obj/effect/temp_visual/behemoth/warning
	if(primal_wrath_action?.ability_activated)
		warning_type = /obj/effect/temp_visual/behemoth/warning/wrath
	if(islist(target_turf))
		for(var/turf/affected_turf AS in target_turf)
			new warning_type(affected_turf, duration)
			for(var/mob/living/affected_living in affected_turf)
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				shake_camera(affected_living, duration, 0.5)
		return
	if(!isturf(target_turf))
		target_turf = get_turf(target_turf)
	new warning_type(target_turf, duration)
	for(var/mob/living/affected_living in target_turf)
		if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
			continue
		shake_camera(affected_living, duration, 0.5)

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
#define LANDSLIDE_WIND_UP 2 SECONDS
#define LANDSLIDE_WARNING_RANGE 8
#define LANDSLIDE_CHARGE_SPEED 0.25 SECONDS
#define LANDSLIDE_KNOCKDOWN_DURATION 1.5 SECONDS

/obj/effect/temp_visual/behemoth/landslide
	icon = 'icons/effects/96x96.dmi'
	icon_state = "landslide_dust"
	duration = 1 SECONDS
	layer = ABOVE_LYING_MOB_LAYER
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/behemoth/landslide/dust/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration - 0.1 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/landslide/hit
	icon = 'icons/effects/effects.dmi'
	icon_state = "landslide_hit"
	duration = 0.2 SECONDS
	layer = RIPPLE_LAYER
	pixel_x = 0
	pixel_y = 0

/obj/effect/temp_visual/behemoth/landslide/hit/Initialize(mapload)
	. = ..()
	layer += 0.01
	pixel_x += pick(-3, -2, -1, 0, 1, 2, 3)
	pixel_y += pick(-3, -2, -1, 0, 1, 2, 3)

/datum/action/xeno_action/activable/behemoth/landslide
	name = "Landslide"
	ability_name = "Landslide"
	action_icon_state = "4"
	desc = "Rush forward in the selected direction, damaging enemies caught in a wide path."
	plasma_cost = 25
	cooldown_timer = 25 SECONDS
	target_flags = XABB_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_LANDSLIDE,
	)
	wind_up_duration = LANDSLIDE_WIND_UP
	/// List containing possible sound effects that are played during this ability.
	var/possible_step_sounds = list(
		'sound/effects/alien_footstep_large1.ogg',
		'sound/effects/alien_footstep_large2.ogg',
		'sound/effects/alien_footstep_large3.ogg')

/datum/action/xeno_action/activable/behemoth/landslide/use_ability(atom/target)
	. = ..()
	if(!ability_active)
		ability_active = TRUE
		playsound(owner, 'sound/effects/behemoth/landslide_roar.ogg', 40, TRUE)
		ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
		var/turf/owner_turf = get_turf(owner)
		var/cardinal_direction = get_cardinal_dir(owner, target)
		do_warning(get_affected_turfs(owner_turf, cardinal_direction), wind_up_duration)
		addtimer(CALLBACK(src, PROC_REF(do_charge), owner_turf, cardinal_direction), wind_up_duration)
		add_cooldown(5 SECONDS)
		succeed_activate()
		return
	end_charge(force = TRUE)

/// Borrowed from CAS code. Gets a list of the turfs affected by this ability.
/datum/action/xeno_action/activable/behemoth/landslide/proc/get_affected_turfs(turf/owner_turf, direction = SOUTH, range = LANDSLIDE_WARNING_RANGE)
	var/turf/beginning = owner_turf
	var/list/turf/turfs_list = list(beginning)
	turfs_list += get_step(beginning, turn(direction, 90))
	turfs_list += get_step(beginning, turn(direction, -90))
	for(var/i=0 to range)
		beginning = get_step(beginning, direction)
		turfs_list += beginning
		turfs_list += get_step(beginning, turn(direction, 90))
		turfs_list += get_step(beginning, turn(direction, -90))
	for(var/turf/included_turf AS in turfs_list)
		if(!line_of_sight(owner, included_turf, LANDSLIDE_WARNING_RANGE) || LinkBlocked(owner_turf, included_turf))
			turfs_list -= included_turf
	return turfs_list

/// Moves the user in the cardinal direction previously determined by use_ability(). Several things happen here:
/// - Has a constant check to see if the tile ahead of the user is blocked, in which case the charge stops by calling end_charge().
/// - Enemies caught in diagonally adjacent turfs - as well as the turf ahead - directly in front of the user receive the ability's effects.
/// Note that this is "artificial movement", meaning we simulate it. This is done to accomplish a higher movement speed than what is otherwise common for the user.
/datum/action/xeno_action/activable/behemoth/landslide/proc/do_charge(turf/owner_turf, direction)
	if(!ability_active)
		return
	owner_turf = get_turf(owner)
	var/turf/direct_turf = get_step(owner, direction)
	if(LinkBlocked(owner_turf, direct_turf))
		end_charge(direct_turf)
		return
	var/list/turf/adjacent_turfs
	LAZYINITLIST(adjacent_turfs)
	adjacent_turfs += get_step(owner, turn(direction, 45))
	adjacent_turfs += get_step(owner, turn(direction, -45))
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living in direct_turf)
		if(!affected_living.lying_angle)
			affected_living.Knockdown(LANDSLIDE_KNOCKDOWN_DURATION)
			new /obj/effect/temp_visual/behemoth/landslide/hit(direct_turf)
			playsound(direct_turf, 'sound/effects/behemoth/landslide_hit_mob.ogg', 20)
		affected_living.emote("scream")
		shake_camera(affected_living, 1, 1)
		affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage, BRUTE, blocked = MELEE)
	for(var/turf/adjacent_turf AS in adjacent_turfs)
		for(var/mob/living/affected_living in adjacent_turf)
			shake_camera(affected_living, 1, 0.5)
			affected_living.do_jitter_animation(jitter_loops = 2)
			affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 2, BRUTE, blocked = MELEE)
	step(owner, direction, 1)
	playsound(owner_turf, pick(possible_step_sounds), 40)
	new /obj/effect/temp_visual/behemoth/crack(owner_turf)
	new /obj/effect/temp_visual/behemoth/landslide/dust(owner_turf)
	addtimer(CALLBACK(src, PROC_REF(do_charge), owner_turf, direction), LANDSLIDE_CHARGE_SPEED)

/// Ends the charge. This also resolves any effects applied to whatever stopped our charge.
/datum/action/xeno_action/activable/behemoth/landslide/proc/end_charge(turf/target_turf, force)
	ability_active = FALSE
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_GENERIC)
	clear_cooldown()
	add_cooldown()
	if(!force)
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.do_attack_animation(target_turf)
		new /obj/effect/temp_visual/behemoth/crack(target_turf, null, WALL_OBJ_LAYER)
		new /obj/effect/temp_visual/behemoth/landslide/hit(target_turf)
		playsound(target_turf, 'sound/effects/behemoth/behemoth_stomp.ogg', 40)
		for(var/atom/movable/affected_atom in target_turf)
			if(isobj(affected_atom))
				if(iseffect(affected_atom))
					continue
				affected_atom.do_jitter_animation(jitter_loops = 4)
				if(istype(affected_atom, /obj/structure/earth_pillar))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					do_projectile(affected_pillar, TRUE)
					continue
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mech = affected_atom
					affected_mech.take_damage(xeno_owner.xeno_caste.melee_damage * 10, MELEE)
					continue
				var/obj/affected_object = affected_atom
				affected_object.take_damage(xeno_owner.xeno_caste.melee_damage * 2, MELEE)


// ***************************************
// *********** Earth Riser
// ***************************************
#define EARTH_RISER_WIND_UP 2 SECONDS
#define EARTH_RISER_RANGE 3

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
	var/list/obj/structure/earth_pillar/active_pillars

// This is here because otherwise the list refuses to acknowledge types.
/datum/action/xeno_action/activable/behemoth/earth_riser/give_action(mob/living/L)
	. = ..()
	LAZYINITLIST(active_pillars)

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
	if(!target)
		return
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
	new /obj/effect/temp_visual/behemoth/crack/west(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/stomp/west(owner_turf, owner.dir)
	do_stomp(owner_turf)
	do_warning(target_turf, wind_up_duration)
	addtimer(CALLBACK(src, PROC_REF(do_ability), target_turf), wind_up_duration)
	add_cooldown(wind_up_duration)
	succeed_activate()

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
#define SEISMIC_FRACTURE_PARALYZE_DURATION 1.5 SECONDS

/obj/effect/temp_visual/behemoth/seismic_fracture
	icon = 'icons/effects/64x64.dmi'
	icon_state = "seismic_fracture"
	duration = 1 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	pixel_y = 8

/obj/effect/temp_visual/behemoth/seismic_fracture/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = duration, easing = CIRCULAR_EASING|EASE_OUT)

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
	if(!target)
		return
	if(!line_of_sight(owner, target, SEISMIC_FRACTURE_RANGE))
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "Out of range")
		return
	var/owner_turf = get_turf(owner)
	new /obj/effect/temp_visual/behemoth/crack/east(owner_turf, owner.dir)
	new /obj/effect/temp_visual/behemoth/stomp/east(owner_turf, owner.dir)
	do_stomp(owner_turf)
	do_ability(get_turf(target), wind_up_duration)

/// Second part of use_ability(). Gets the turfs affected by this ability, which are then passed along to the following procs.
/// This has to be cut off from use_ability() to optimize code, due to an interaction with Earth Pillars.
/// Earth Pillars caught in the range of Seismic Fracture reflect the attack by calling this proc again.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/do_ability(turf/target_turf, duration = wind_up_duration, instant)
	var/list/turf/turfs_to_attack = filled_turfs(target_turf, 2, bypass_window = TRUE, air_pass = TRUE)
	if(!length(turfs_to_attack)) // Just in case.
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		xeno_owner.balloon_alert(xeno_owner, "Unable to use here")
		return
	if(!duration || instant)
		do_attack(target_turf, turfs_to_attack, TRUE)
		if(!instant)
			add_cooldown()
			succeed_activate()
		return
	do_warning(turfs_to_attack, duration)
	addtimer(CALLBACK(src, PROC_REF(do_attack), target_turf, turfs_to_attack), duration)
	add_cooldown()
	succeed_activate()
	return

/// Checks for any atoms caught in the attack's range. Effects vary based on the atom type, with two possibilities:
/// - Living mobs are paralyzed and damaged, with a cool animation that happens during its debuff. They are invincible during this duration, and they will also be subject to a continuation of this ability (see: do_landing()) afterwards.
/// - Objects receive increased damage. Further increased if the object is a mecha.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/do_attack(target_turf, list/turf/turfs_to_attack, instant)
	playsound(target_turf, 'sound/effects/behemoth/seismic_fracture_explosion.ogg', 40)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/list/mob/living/living_to_attack
	LAZYINITLIST(living_to_attack)
	for(var/turf/affected_turf AS in turfs_to_attack)
		new /obj/effect/temp_visual/behemoth/seismic_fracture(affected_turf)
		new /obj/effect/temp_visual/behemoth/crack(affected_turf)
		for(var/atom/movable/affected_atom in affected_turf)
			if(isliving(affected_atom))
				var/mob/living/affected_living = affected_atom
				if(xeno_owner.issamexenohive(affected_living) || affected_living.stat == DEAD)
					continue
				living_to_attack += affected_living
				affected_living.emote("scream")
				shake_camera(affected_living, SEISMIC_FRACTURE_PARALYZE_DURATION / 2, 1)
				affected_living.Paralyze(SEISMIC_FRACTURE_PARALYZE_DURATION)
				affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage, BRUTE, blocked = MELEE)
				if(!instant)
					affected_living.layer = ABOVE_MOB_LAYER
					affected_living.status_flags |= (INCORPOREAL|GODMODE)
					animate(affected_living, pixel_y = affected_living.pixel_y + 40, layer = ABOVE_MOB_LAYER, time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_END_NOW)
					animate(pixel_y = initial(affected_living.pixel_y), time = SEISMIC_FRACTURE_PARALYZE_DURATION / 2, easing = CIRCULAR_EASING|EASE_IN)
			if(isobj(affected_atom))
				if(ismecha(affected_atom))
					var/obj/vehicle/sealed/mecha/affected_mech = affected_atom
					affected_mech.take_damage(xeno_owner.xeno_caste.melee_damage * 10, MELEE)
					continue
				if(istype(affected_atom, /obj/structure/earth_pillar))
					var/obj/structure/earth_pillar/affected_pillar = affected_atom
					affected_pillar.do_jitter_animation()
					affected_pillar.seismic_fracture()
					playsound(affected_pillar, pick(affected_pillar.possible_hit_sounds), 40)
					var/pillar_turf = get_turf(affected_pillar)
					new /obj/effect/temp_visual/behemoth/landslide/hit(pillar_turf)
					do_ability(pillar_turf, initial(affected_pillar.warning_flashes) * 10)
					continue
				var/obj/affected_object = affected_atom
				affected_object.take_damage(xeno_owner.xeno_caste.melee_damage * 2, MELEE)
	if(length(living_to_attack) && !instant)
		addtimer(CALLBACK(src, PROC_REF(do_landing), living_to_attack), SEISMIC_FRACTURE_PARALYZE_DURATION)

/// Continuation for do_attack(). Living mobs that were previously caught in the attack's radius are subject to a landing effect, where the following happens:
/// - Their invincibility is removed, reestablishing anything that was changed.
/// - They receive a reduced amount of damage.
/datum/action/xeno_action/activable/behemoth/seismic_fracture/proc/do_landing(list/mob/living/living_to_attack)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	for(var/mob/living/affected_living AS in living_to_attack)
		affected_living.layer = initial(affected_living.layer)
		affected_living.status_flags &= ~(INCORPOREAL|GODMODE)
		affected_living.apply_damage(xeno_owner.xeno_caste.melee_damage / 3, BRUTE, blocked = MELEE)
		var/landing_turf = get_turf(affected_living)
		playsound(landing_turf, 'sound/effects/behemoth/seismic_fracture_landing.ogg', 10)
		new /obj/effect/temp_visual/behemoth/stomp(landing_turf)
	living_to_attack = null


// ***************************************
// *********** Primal Wrath
// ***************************************
/datum/action/xeno_action/primal_wrath
	name = "Primal Wrath"
	ability_name = "Primal Wrath"
	action_icon_state = "26"
	desc = "Unleash your wrath. Enhances your abilities, changing their functionality and allowing them to apply a damage over time debuff."
	plasma_cost = 0
	cooldown_timer = 300 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY|XACT_IGNORE_SELECTED_ABILITY
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PRIMAL_WRATH,
	)
	/// Whether Primal Wrath is active or not.
	var/ability_activated = FALSE

/datum/action/xeno_action/primal_wrath/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.balloon_alert(xeno_owner, "Primal Wrath ready")
	xeno_owner.playsound_local(xeno_owner, 'sound/effects/xeno_newlarva.ogg', 20, 0, 1)
	return ..()

/datum/action/xeno_action/primal_wrath/action_activate()
	ability_activated = TRUE
	add_cooldown(1 SECONDS)


// ***************************************
// *********** Earth Pillar (also see: Earth Riser)
// ***************************************
#define EARTH_PILLAR_PROJECTILE_KNOCKDOWN_DURATION 0.5 SECONDS

/obj/effect/temp_visual/behemoth/earth_pillar
	duration = 2 SECONDS
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/temp_visual/behemoth/earth_pillar/destroyed/Initialize(mapload)
	. = ..()
	layer += 0.01
	animate(src, time = 0.3 SECONDS)
	animate(alpha = 0, time = 0.7 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)

/obj/effect/temp_visual/behemoth/earth_pillar/destroyed
	icon = 'icons/effects/128x128.dmi'
	icon_state = "earth_pillar_destroyed"
	duration = 1 SECONDS
	pixel_x = -48
	pixel_y = -41

/obj/effect/temp_visual/behemoth/earth_pillar/destroyed/Initialize(mapload)
	. = ..()
	layer += 0.01
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
	layer += 0.01
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
	layer = ABOVE_MOB_LAYER
	climbable = TRUE
	climb_delay = 2 SECONDS
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
	shell_speed = 2
	accuracy = 100
	damage_falloff = 0
	damage_type = BRUTE
	armor_type = MELEE

/// Called by other on_hit_ procs.
/// Handles anything that would happen after the projectile hits something.
/datum/ammo/xeno/earth_pillar/proc/on_hit_anything(atom/hit_atom, obj/projectile/proj)
	var/atom_turf = get_turf(hit_atom)
	playsound(atom_turf, sound_hit, 40)
	new /obj/effect/temp_visual/behemoth/earth_pillar/destroyed(atom_turf)

/datum/ammo/xeno/earth_pillar/on_hit_mob(mob/victim, obj/projectile/proj)
	. = ..()
	step_away(victim, proj, 1, 1)
	if(isliving(victim))
		var/mob/living/human_victim = victim
		human_victim.Knockdown(EARTH_PILLAR_PROJECTILE_KNOCKDOWN_DURATION)
	return on_hit_anything(victim, proj)

/datum/ammo/xeno/earth_pillar/on_hit_obj(obj/object, obj/projectile/proj)
	. = ..()
	if(ismecha(object))
		var/obj/vehicle/sealed/mecha/mecha_object = object
		mecha_object.take_damage(damage * 5, MELEE)
		return on_hit_anything(object, proj)
	object.take_damage(damage, MELEE)
	return on_hit_anything(object, proj)

/datum/ammo/xeno/earth_pillar/on_hit_turf(turf/hit_turf, obj/projectile/proj)
	. = ..()
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
