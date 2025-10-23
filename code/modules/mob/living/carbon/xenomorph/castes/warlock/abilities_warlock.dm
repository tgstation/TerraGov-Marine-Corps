/particles/warlock_charge
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "lemon"
	width = 100
	height = 100
	count = 300
	spawning = 15
	lifespan = 8
	fade = 12
	grow = -0.02
	velocity = list(0, 3)
	position = generator(GEN_CIRCLE, 15, 17, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.5), list(0, 0.2))
	gravity = list(0, 3)
	scale = generator(GEN_VECTOR, list(0.1, 0.1), list(0.5, 0.5), NORMAL_RAND)
	color = "#6a59b3"

/particles/warlock_charge/psy_blast
	width = 250
	height = 250
	color = "#970f0f"
	drift = null
	gravity = null
	spawning = 20
	lifespan = 12

/particles/warlock_charge/psy_blast/psy_lance
	color = "#CB0166"
	spawning = 30

/particles/crush_warning
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "lemon"
	width = 36
	height = 45
	count = 50
	spawning = 5
	lifespan = 8
	fade = 10
	grow = -0.04
	velocity = list(0, 0.2)
	position = generator(GEN_SPHERE, 15, 17, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-0.5, -0.5), list(0.5, 0.5))
	gravity = list(0, 0.6)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(0.7, 0.7), NORMAL_RAND)
	color = "#4b3f7e"

// ***************************************
// *********** Psychic shield
// ***************************************
/datum/action/ability/activable/xeno/psychic_shield
	name = "Psychic Shield"
	action_icon_state = "psy_shield"
	action_icon = 'icons/Xeno/actions/warlock.dmi'
	desc = "Channel a psychic shield at your current location that can reflect most projectiles. Activate again while the shield is active to detonate the shield forcibly, producing knockback. Must remain static to use."
	cooldown_duration = 10 SECONDS
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_SHIELD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TRIGGER_PSYCHIC_SHIELD,
	)
	use_state_flags = ABILITY_USE_BUSY
	/// The actual shield object created by this ability.
	var/obj/effect/xeno/shield/active_shield
	/// Whether to use the alternative mode of projectile reflection. Makes shields weaker, but sends projectiles toward a selected target.
	var/alternative_reflection = FALSE
	/// While the shield is active, what should be the ability cost be set to? Will revert back to initial ability cost afterward.
	var/detonation_cost = 200
	/// While the shield is active, will reactivating the ability cause it to detonate instead of only canceling?
	var/can_manually_detonate = TRUE
	/// If the owner has the plasma and the shield was canceled for a reason that isn't destruction or manual detonation, should the shield automatically detonate?
	var/detonates_on_cancel = FALSE
	/// The flags used for the do_after.
	var/do_after_flags = NONE
	/// While the shield is active, how strong of a movement speed modifier should be applied to the owner?
	var/movement_speed_modifier = 0

/datum/action/ability/activable/xeno/psychic_shield/remove_action(mob/M)
	if(active_shield)
		active_shield.release_projectiles()
		QDEL_NULL(active_shield)
	return ..()

/datum/action/ability/activable/xeno/psychic_shield/on_cooldown_finish()
	owner.balloon_alert(owner, "Shield ready")
	return ..()

//Overrides parent.
/datum/action/ability/activable/xeno/psychic_shield/alternate_action_activate()
	if(can_use_ability(null, FALSE, ABILITY_IGNORE_SELECTED_ABILITY))
		INVOKE_ASYNC(src, PROC_REF(use_ability))

/datum/action/ability/activable/xeno/psychic_shield/action_activate()
	if(xeno_owner.selected_ability == src && xeno_owner.upgrade == XENO_UPGRADE_PRIMO)
		alternative_reflection = !alternative_reflection
		// Reflects projectiles toward a target (targetted) / reflects projectiles as if it was bounced (normal).
		owner.balloon_alert(owner, alternative_reflection ? "targetted reflection" : "normal reflection")
	return ..()

/datum/action/ability/activable/xeno/psychic_shield/use_ability(atom/targetted_atom)
	if(active_shield)
		if(!can_manually_detonate)
			cancel_shield()
			return
		if(ability_cost > xeno_owner.plasma_stored)
			owner.balloon_alert(owner, "need [ability_cost - xeno_owner.plasma_stored] more plasma!")
			return FALSE
		if(can_use_action(FALSE, ABILITY_USE_BUSY))
			shield_blast(targetted_atom)
			cancel_shield()
		return

	// If activated by mouse click, face the atom clicked.
	if(targetted_atom)
		owner.dir = get_cardinal_dir(owner, targetted_atom)

	// Blocked by something in front of us.
	var/turf/target_turf = get_step(owner, owner.dir)
	if(target_turf.density)
		owner.balloon_alert(owner, "Obstructed by [target_turf]")
		return
	for(var/atom/movable/affected AS in target_turf)
		if(affected.density)
			owner.balloon_alert(owner, "Obstructed by [affected]")
			return

	succeed_activate()
	playsound(owner,'sound/effects/magic.ogg', 75, 1)

	action_icon_state = "psy_shield_reflect"
	update_button_icon()
	xeno_owner.update_glow(3, 3, "#5999b3")
	xeno_owner.move_resist = MOVE_FORCE_EXTREMELY_STRONG // This aims to prevent bumping (or shuffling) from a fair amount of xenomorph castes which may lead to the shield cancelling (and unloading the now-unfrozen projectiles into the bumper or bumpee).

	ability_cost = detonation_cost
	GLOB.round_statistics.psy_shields++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_shields")

	if(alternative_reflection)
		active_shield = new /obj/effect/xeno/shield/special(target_turf, owner)
	else
		active_shield = new(target_turf, owner)
	if(movement_speed_modifier)
		xeno_owner.add_movespeed_modifier(MOVESPEED_ID_WARLOCK_PSYCHIC_SHIELD, TRUE, 0, NONE, TRUE, movement_speed_modifier)
	if(!do_after(owner, 6 SECONDS, do_after_flags, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_action), TRUE, ABILITY_USE_BUSY)))
		if(detonates_on_cancel && ability_cost <= xeno_owner.plasma_stored && !QDELETED(active_shield))
			shield_blast(null, TRUE)
		cancel_shield()
		return
	if(detonates_on_cancel && ability_cost <= xeno_owner.plasma_stored)
		shield_blast(null, TRUE)
	cancel_shield()

/// Removes the shield and resets the ability.
/datum/action/ability/activable/xeno/psychic_shield/proc/cancel_shield()
	if(movement_speed_modifier)
		xeno_owner.remove_movespeed_modifier(MOVESPEED_ID_WARLOCK_PSYCHIC_SHIELD)
	action_icon_state = "psy_shield"
	xeno_owner.update_glow()
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	update_button_icon()
	add_cooldown()
	if(active_shield)
		active_shield.release_projectiles()
		QDEL_NULL(active_shield)

///AOE knockback triggerable by ending the shield early
/datum/action/ability/activable/xeno/psychic_shield/proc/shield_blast(atom/targetted_atom, silent = TRUE)
	succeed_activate()

	active_shield.reflect_projectiles(targetted_atom)

	if(!silent)
		owner.visible_message(span_xenowarning("[owner] sends out a huge blast of psychic energy!"), span_xenowarning("We send out a huge blast of psychic energy!"))

	var/turf/lower_left
	var/turf/upper_right
	switch(active_shield.dir)
		if(NORTH)
			lower_left = locate(active_shield.x - 1, active_shield.y, active_shield.z)
			upper_right = locate(active_shield.x + 1, active_shield.y + 1, active_shield.z)
		if(SOUTH)
			lower_left = locate(active_shield.x - 1, active_shield.y - 1, active_shield.z)
			upper_right = locate(active_shield.x + 1, active_shield.y, active_shield.z)
		if(WEST)
			lower_left = locate(active_shield.x - 1, active_shield.y - 1, active_shield.z)
			upper_right = locate(active_shield.x, active_shield.y + 1, active_shield.z)
		if(EAST)
			lower_left = locate(active_shield.x, active_shield.y - 1, active_shield.z)
			upper_right = locate(active_shield.x + 1, active_shield.y + 1, active_shield.z)

	for(var/turf/affected_tile AS in block(lower_left, upper_right)) //everything in the 2x3 block is found.
		affected_tile.Shake(duration = 0.5 SECONDS)
		for(var/atom/movable/affected in affected_tile)
			if(!ishuman(affected) && !istype(affected, /obj/item) && !isdroid(affected))
				affected.Shake(duration = 0.5 SECONDS)
				continue
			if(ishuman(affected))
				var/mob/living/carbon/human/H = affected
				if(H.stat == DEAD)
					continue
				H.apply_effects(paralyze = 1 SECONDS)
				shake_camera(H, 2, 1)
			var/throwlocation = affected.loc
			for(var/x in 1 to 6)
				throwlocation = get_step(throwlocation, active_shield.dir)
			affected.throw_at(throwlocation, 4, 1, owner, TRUE)

	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, 'sound/voice/alien/roar_warlock.ogg', 25)

	ability_cost = initial(ability_cost) // Revert this back to normal since it could be different.
	GLOB.round_statistics.psy_shield_blasts++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_shield_blasts")


/obj/effect/xeno/shield
	icon = 'icons/Xeno/96x96.dmi'
	icon_state = "shield"
	anchored = TRUE
	resistance_flags = UNACIDABLE|PLASMACUTTER_IMMUNE
	max_integrity = 650
	layer = ABOVE_MOB_LAYER
	/// Who created the shield?
	var/mob/living/carbon/xenomorph/owner
	/// All the projectiles currently frozen by this obj.
	var/list/frozen_projectiles = list()
	/// Should reflecting projectiles should go to a targetted atom?
	var/alternative_reflection = FALSE

/obj/effect/xeno/shield/Initialize(mapload, creator)
	. = ..()
	if(!creator)
		return INITIALIZE_HINT_QDEL
	owner = creator
	dir = owner.dir
	if(dir & (EAST|WEST))
		bound_height = 96
		bound_y = -32
		pixel_y = -32
	else
		bound_width = 96
		bound_x = -32
		pixel_x = -32
	if(alternative_reflection) // The easy alternative to spriting 92 frames.
		add_atom_colour("#ff000d", FIXED_COLOR_PRIORITY)

/obj/effect/xeno/shield/projectile_hit(atom/movable/projectile/proj, cardinal_move, uncrossing)
	if(!(cardinal_move & REVERSE_DIR(dir)))
		return FALSE
	return !uncrossing

/obj/effect/xeno/shield/do_projectile_hit(atom/movable/projectile/proj)
	proj.projectile_behavior_flags |= PROJECTILE_FROZEN
	proj.iff_signal = null
	frozen_projectiles += proj
	take_damage(proj.damage, proj.ammo.damage_type, proj.ammo.armor_type, 0, REVERSE_DIR(proj.dir), proj.ammo.penetration)
	if(QDELETED(src)) // Could be deleted from take_damage / obj_destruction.
		return
	alpha = obj_integrity * 255 / max_integrity

/obj/effect/xeno/shield/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	release_projectiles()
	owner.apply_effect(1 SECONDS, EFFECT_PARALYZE)
	return ..()

/// Unfreezes the projectiles on their original path.
/obj/effect/xeno/shield/proc/release_projectiles()
	for(var/atom/movable/projectile/proj AS in frozen_projectiles)
		proj.projectile_behavior_flags &= ~PROJECTILE_FROZEN
		proj.resume_move()
	record_projectiles_frozen(owner, LAZYLEN(frozen_projectiles))

/// Unfreezes the projectles, then reflects them towards a specified atom or based on their relative incoming angle if nothing was specified.
/obj/effect/xeno/shield/proc/reflect_projectiles(atom/targetted_atom)
	playsound(loc, 'sound/effects/portal.ogg', 20)

	var/perpendicular_angle = Get_Angle(get_turf(src), get_step(src, dir)) //the angle src is facing, get_turf because pixel_x or y messes with the angle
	var/direction_to_atom = angle_to_dir(Get_Angle(src, targetted_atom))
	for(var/atom/movable/projectile/reflected_projectile AS in frozen_projectiles)
		reflected_projectile.projectile_behavior_flags &= ~PROJECTILE_FROZEN
		reflected_projectile.distance_travelled = 0

		// If alternative reflection is on, try to deflect toward the targetted area that we're facing.
		if(alternative_reflection)
			var/bad_angle = TRUE
			switch(dir)
				if(NORTH)
					if(direction_to_atom == NORTHWEST || direction_to_atom == NORTH || direction_to_atom == NORTHEAST)
						bad_angle = FALSE
				if(EAST)
					if(direction_to_atom == NORTHEAST || direction_to_atom == EAST || direction_to_atom == SOUTHEAST)
						bad_angle = FALSE
				if(SOUTH)
					if(direction_to_atom == SOUTHEAST || direction_to_atom == SOUTH || direction_to_atom == SOUTHWEST)
						bad_angle = FALSE
				if(WEST)
					if(direction_to_atom == SOUTHWEST || direction_to_atom == WEST || direction_to_atom == NORTHWEST)
						bad_angle = FALSE
			if(!bad_angle)
				reflected_projectile.fire_at(targetted_atom, source = src, recursivity = TRUE)
				record_rocket_reflection(owner, reflected_projectile)
				continue

		// If alternative reflection is off OR it fails to get an acceptable angle, reflect it as if it bounced off the shield.
		var/bounced_angle = perpendicular_angle + (perpendicular_angle - reflected_projectile.dir_angle - 180)
		if(bounced_angle < 0)
			bounced_angle += 360
		else if(bounced_angle > 360)
			bounced_angle -= 360
		reflected_projectile.fire_at(source = src, angle = bounced_angle, recursivity = TRUE)
		record_rocket_reflection(owner, reflected_projectile)

	record_projectiles_frozen(owner, LAZYLEN(frozen_projectiles), TRUE)
	frozen_projectiles.Cut()

/obj/effect/xeno/shield/special
	max_integrity = 325
	alternative_reflection = TRUE

// ***************************************
// *********** psychic crush
// ***************************************

#define PSY_CRUSH_DAMAGE 50
/datum/action/ability/activable/xeno/psy_crush
	name = "Psychic Crush"
	action_icon_state = "psy_crush"
	action_icon = 'icons/Xeno/actions/warlock.dmi'
	desc = "Channel an expanding AOE crush effect, activating it again pre-maturely crushes enemies over an area. The longer it is channeled, the larger area it will affect, but will consume more plasma."
	ability_cost = 40
	cooldown_duration = 12 SECONDS
	keybind_flags = ABILITY_KEYBIND_USE_ABILITY
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_CRUSH,
	)
	///The number of times we can expand our effect radius. Effectively a max radius
	var/max_interations = 5
	///How many times we have expanded our effect radius
	var/current_iterations = 0
	///timer hash for the timer we use when charging up
	var/channel_loop_timer
	///List of turfs in the effect radius
	var/list/target_turfs
	///list of effects used to visualise area of effect
	var/list/effect_list
	/// A list of all things that had a fliter applied
	var/list/filters_applied
	///max range at which we can cast out ability
	var/ability_range = 7
	///Holder for the orb visual effect
	var/obj/effect/xeno/crush_orb/orb
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///The particle type this ability uses
	var/channel_particle = /particles/warlock_charge

/datum/action/ability/activable/xeno/psy_crush/use_ability(atom/target)
	if(channel_loop_timer)
		if(length(target_turfs)) //it shouldn't be possible to do this without any turfs, but just in case
			crush(target_turfs[1])
		return

	if(xeno_owner.selected_ability != src)
		action_activate()
		return
	if(owner.do_actions || !target || !can_use_action(TRUE) || !check_distance(target, TRUE))
		return fail_activate()

	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, PSYCHIC_CRUSH_ABILITY_TRAIT)
	if(!do_after(owner, 0.8 SECONDS, NONE, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_action), FALSE, ABILITY_USE_BUSY)))
		REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, PSYCHIC_CRUSH_ABILITY_TRAIT)
		return fail_activate()

	owner.visible_message(span_xenowarning("\The [owner] starts channeling their psychic might!"), span_xenowarning("We start channeling our psychic might!"))
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, PSYCHIC_CRUSH_ABILITY_TRAIT)
	owner.add_movespeed_modifier(MOVESPEED_ID_WARLOCK_CHANNELING, TRUE, 0, NONE, TRUE, 0.9)

	particle_holder = new(owner, channel_particle)
	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 5

	xeno_owner.update_glow(3, 3, "#6a59b3")

	var/turf/target_turf = get_turf(target)
	LAZYINITLIST(target_turfs)
	target_turfs += target_turf
	LAZYINITLIST(effect_list)
	effect_list += new /obj/effect/xeno/crush_warning(target_turf)
	orb = new /obj/effect/xeno/crush_orb(target_turf)

	action_icon_state = "psy_crush_activate"
	update_button_icon()
	RegisterSignals(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED)), PROC_REF(stop_crush))
	do_channel(target_turf)

///Checks if the owner is close enough/can see the target
/datum/action/ability/activable/xeno/psy_crush/proc/check_distance(atom/target, sight_needed)
	if(get_dist(owner, target) > ability_range)
		owner.balloon_alert(owner, "Too far!")
		return FALSE
	if(sight_needed && !line_of_sight(owner, target, 9))
		owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	return TRUE

///Increases the area of effect, or triggers the crush if we've reached max iterations
/datum/action/ability/activable/xeno/psy_crush/proc/do_channel(turf/target)
	channel_loop_timer = null
	if(!check_distance(target) || isnull(xeno_owner) || xeno_owner.stat == DEAD)
		stop_crush()
		return
	if(current_iterations >= max_interations)
		crush(target)
		return

	succeed_activate()
	playsound(target, 'sound/effects/woosh_swoosh.ogg', 30 + (current_iterations * 10))

	var/list/turfs_to_add = list()
	for(var/turf/current_turf AS in target_turfs)
		var/list/turfs_to_check = get_adjacent_open_turfs(current_turf)
		for(var/turf/turf_to_check AS in turfs_to_check)
			if((turf_to_check in target_turfs) || (turf_to_check in turfs_to_add))
				continue
			if(LinkBlocked(current_turf, turf_to_check, PASS_AIR))
				continue
			turfs_to_add += turf_to_check
			effect_list += new /obj/effect/xeno/crush_warning(turf_to_check)
	target_turfs += turfs_to_add
	current_iterations ++
	if(can_use_action(xeno_owner, ABILITY_IGNORE_COOLDOWN))
		channel_loop_timer = addtimer(CALLBACK(src, PROC_REF(do_channel), target), 0.6 SECONDS, TIMER_STOPPABLE)
		return

	stop_crush()

///crushes all turfs in the AOE
/datum/action/ability/activable/xeno/psy_crush/proc/crush(turf/target)
	var/crush_cost = ability_cost * current_iterations
	if(crush_cost > xeno_owner.plasma_stored)
		owner.balloon_alert(owner, "[crush_cost - xeno_owner.plasma_stored] more plasma!")
		stop_crush()
		return
	if(!check_distance(target))
		stop_crush()
		return

	succeed_activate(crush_cost)
	playsound(target, 'sound/effects/EMPulse.ogg', 70)
	apply_filters(target_turfs)
	orb.icon_state = "crush_hard" //used as a check in stop_crush
	flick("crush_hard", orb)
	addtimer(CALLBACK(src, PROC_REF(remove_all_filters)), 1 SECONDS, TIMER_STOPPABLE)

	for(var/turf/effected_turf AS in target_turfs)
		for(var/victim in effected_turf)
			if(iscarbon(victim))
				var/mob/living/carbon/carbon_victim = victim
				if(isxeno(carbon_victim) || carbon_victim.stat == DEAD)
					continue
				carbon_victim.apply_damage(PSY_CRUSH_DAMAGE, BRUTE, blocked = BOMB, attacker = owner)
				carbon_victim.apply_damage(PSY_CRUSH_DAMAGE * 1.5, STAMINA, blocked = BOMB, attacker = owner)
				carbon_victim.adjust_stagger(5 SECONDS)
				carbon_victim.add_slowdown(6)
				continue
			if(isvehicle(victim) || ishitbox(victim))
				var/obj/obj_victim = victim
				var/dam_mult = 0.5
				if(ismecha(obj_victim))
					dam_mult = 2.3
				obj_victim.take_damage(PSY_CRUSH_DAMAGE * dam_mult, BRUTE, BOMB)
				continue
			if(isfire(victim))
				var/obj/fire/fire = victim
				fire.reduce_fire(10)
				continue
	stop_crush()

/// stops channeling and unregisters all listeners, resetting the ability
/datum/action/ability/activable/xeno/psy_crush/proc/stop_crush()
	SIGNAL_HANDLER
	if(channel_loop_timer)
		deltimer(channel_loop_timer)
		channel_loop_timer = null
	QDEL_LIST(effect_list)
	if(orb.icon_state != "crush_hard") //we failed to crush
		flick("crush_smooth", orb)
		QDEL_NULL_IN(src, orb, 0.5 SECONDS)
	else
		QDEL_NULL_IN(src, orb, 0.4 SECONDS)
	current_iterations = 0
	target_turfs = null
	effect_list = null
	owner.remove_movespeed_modifier(MOVESPEED_ID_WARLOCK_CHANNELING)
	action_icon_state = "psy_crush"
	xeno_owner.update_glow()
	add_cooldown()
	update_button_icon()
	QDEL_NULL(particle_holder)
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED)))

///Apply a filter on all items in the list of turfs
/datum/action/ability/activable/xeno/psy_crush/proc/apply_filters(list/turfs)
	LAZYINITLIST(filters_applied)
	for(var/turf/targeted AS in turfs)
		targeted.add_filter("crushblur", 1, radial_blur_filter(0.3))
		filters_applied += targeted
		for(var/atom/movable/item AS in targeted.contents)
			item.add_filter("crushblur", 1, radial_blur_filter(0.3))
			filters_applied += item
	GLOB.round_statistics.psy_crushes++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_crushes")

///Remove all filters of items in filters_applied
/datum/action/ability/activable/xeno/psy_crush/proc/remove_all_filters()
	for(var/atom/thing AS in filters_applied)
		if(QDELETED(thing))
			continue
		thing.remove_filter("crushblur")
	filters_applied = null

/datum/action/ability/activable/xeno/psy_crush/on_cooldown_finish()
	owner.balloon_alert(owner, "Crush ready")
	return ..()

/obj/effect/xeno/crush_warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "crush_warning"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///The particle type this ability uses
	var/channel_particle = /particles/crush_warning

/obj/effect/xeno/crush_warning/Initialize(mapload)
	. = ..()
	particle_holder = new(src, channel_particle)
	particle_holder.pixel_y = 0
	notify_ai_hazard()

/obj/effect/xeno/crush_orb
	icon = 'icons/xeno/2x2building.dmi'
	icon_state = "orb_idle"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = FLY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -16

/obj/effect/xeno/crush_orb/Initialize(mapload)
	. = ..()
	flick("orb_charge", src)

#undef PSY_CRUSH_DAMAGE

// ***************************************
// *********** Psyblast
// ***************************************
/datum/action/ability/activable/xeno/psy_blast
	name = "Psychic Blast"
	action_icon_state = "psy_blast"
	action_icon = 'icons/Xeno/actions/warlock.dmi'
	desc = "Launch a blast of psychic energy that deals light damage and knocks back enemies in its AOE. Must remain stationary for a few seconds to use."
	cooldown_duration = 6 SECONDS
	ability_cost = 230
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_BLAST,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///The particle type that will be created when using this ability
	var/particles/particle_type = /particles/warlock_charge/psy_blast
	/// The ammo types that can be selected.
	var/list/datum/ammo/energy/xeno/selectable_ammo_types = list(
		/datum/ammo/energy/xeno/psy_blast
	)
	/// The currently selected ammo type.
	var/list/datum/ammo/energy/xeno/selected_ammo_type
	/// If Psychic Drain is used, how much bonus damage is granted?
	var/psychic_drain_bonus_damage = 0

/datum/action/ability/activable/xeno/psy_blast/New(Target)
	. = ..()
	if(length(selectable_ammo_types))
		selected_ammo_type = selectable_ammo_types[1]

/datum/action/ability/activable/xeno/psy_blast/give_action(mob/living/carbon/xenomorph/given_to_xenomorph)
	if(given_to_xenomorph.upgrade == XENO_UPGRADE_PRIMO)
		selectable_ammo_types += /datum/ammo/energy/xeno/psy_blast/psy_lance
	return ..()

/datum/action/ability/activable/xeno/psy_blast/remove_action(mob/living/carbon/xenomorph/removed_from_xenomorph)
	if(removed_from_xenomorph.upgrade == XENO_UPGRADE_PRIMO)
		selectable_ammo_types += /datum/ammo/energy/xeno/psy_blast/psy_lance
	return ..()

/datum/action/ability/activable/xeno/psy_blast/on_xeno_upgrade()
	. = ..()
	if(/datum/ammo/energy/xeno/psy_blast/psy_lance in selectable_ammo_types)
		return
	selectable_ammo_types += /datum/ammo/energy/xeno/psy_blast/psy_lance

/datum/action/ability/activable/xeno/psy_blast/on_cooldown_finish()
	owner.balloon_alert(owner, "Psy blast ready")
	return ..()

/datum/action/ability/activable/xeno/psy_blast/action_activate()
	if(xeno_owner.selected_ability != src || !length(selectable_ammo_types) || particle_holder)
		return ..()

	var/found_pos = selectable_ammo_types.Find(xeno_owner.ammo.type)
	if(!found_pos)
		xeno_owner.ammo = GLOB.ammo_list[selectable_ammo_types[1]]
	else
		xeno_owner.ammo = GLOB.ammo_list[selectable_ammo_types[(found_pos % length(selectable_ammo_types)) + 1]] // Pick the next selectable ammo type. If not, loop to the beginning.
	var/datum/ammo/energy/xeno/selected_ammo = xeno_owner.ammo
	ability_cost = selected_ammo.ability_cost
	particle_type = selected_ammo.channel_particle
	switch(selected_ammo.type)
		if(/datum/ammo/energy/xeno/psy_blast)
			name = "Psychic Blast ([ability_cost])"
			desc = "Launch a blast of psychic energy that deals light burn damage and staggers in an area. Direct hits deal additional light brute damage."
		if(/datum/ammo/energy/xeno/psy_blast/psy_lance)
			name = "Psychic Lance ([ability_cost])"
			desc = "Launch a blast of psychic energy that deals high brute damage with high armor penetration. This can hit multiple mobs and goes through structures."
		if(/datum/ammo/energy/xeno/psy_blast/psy_drain)
			name = "Psychic Drain ([ability_cost])"
			desc = "Launch a blast of psychic energy that deals light stamina damage, staggers, and knockbacks in a smaller area. Direct hits deal additional light stamina damage and briefly knockdowns."
	desc += " Must remain stationary for a few seconds to use." // Extra space intentional.
	owner.balloon_alert(xeno_owner, "[selected_ammo]")
	update_button_icon()
	return ..()

/datum/action/ability/activable/xeno/psy_blast/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!xeno_owner.check_state())
		return FALSE
	var/datum/ammo/energy/xeno/selected_ammo = xeno_owner.ammo
	if(selected_ammo.ability_cost > xeno_owner.plasma_stored)
		if(!silent)
			owner.balloon_alert(owner, "[selected_ammo.ability_cost - xeno_owner.plasma_stored] more plasma!")
		return FALSE

/datum/action/ability/activable/xeno/psy_blast/use_ability(atom/A)
	owner.balloon_alert(owner, "We channel our psychic power")
	generate_particles(A, 7)
	var/datum/ammo/energy/xeno/ammo_type = xeno_owner.ammo
	xeno_owner.update_glow(3, 3, ammo_type.glow_color)

	if(!do_after(xeno_owner, 1 SECONDS, IGNORE_TARGET_LOC_CHANGE, A, BUSY_ICON_DANGER) || !can_use_ability(A, FALSE) || !(A in range(get_screen_size(TRUE), owner)))
		owner.balloon_alert(owner, "Our focus is disrupted")
		end_channel()
		return fail_activate()

	succeed_activate()

	var/atom/movable/projectile/hitscan/projectile = new /atom/movable/projectile/hitscan(xeno_owner.loc)
	projectile.effect_icon = initial(ammo_type.hitscan_effect_icon)
	projectile.generate_bullet(ammo_type)
	projectile.fire_at(A, xeno_owner, xeno_owner, projectile.ammo.max_range, projectile.ammo.shell_speed)
	playsound(xeno_owner, 'sound/weapons/guns/fire/volkite_4.ogg', 40)

	if(istype(xeno_owner.ammo, /datum/ammo/energy/xeno/psy_blast))
		GLOB.round_statistics.psy_blasts++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_blasts")
	else
		GLOB.round_statistics.psy_lances++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_lances")

	add_cooldown()
	update_button_icon()
	addtimer(CALLBACK(src, PROC_REF(end_channel)), 5)

/datum/action/ability/activable/xeno/psy_blast/update_button_icon()
	var/datum/ammo/energy/xeno/ammo_type = xeno_owner.ammo
	if(ammo_type)
		action_icon_state = ammo_type.icon_state
	return ..()

//Generates particles and directs them towards target
/datum/action/ability/activable/xeno/psy_blast/proc/generate_particles(atom/target, velocity)
	var/angle = Get_Angle(get_turf(owner), get_turf(target)) //pixel offsets effect angles
	var/x_component = sin(angle) * velocity
	var/y_component = cos(angle) * velocity

	particle_holder = new(owner, particle_type)

	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 0
	particle_holder.particles.velocity = list(x_component * 0.5, y_component * 0.5)
	particle_holder.particles.gravity = list(x_component, y_component)
	particle_holder.particles.rotation = angle

///Cleans up when the channel finishes or is cancelled
/datum/action/ability/activable/xeno/psy_blast/proc/end_channel()
	QDEL_NULL(particle_holder)
	xeno_owner.update_glow()
