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
	desc = "Channel a psychic shield at your current location that can reflect most projectiles. Activate again while the shield is active to detonate the shield forcibly, producing knockback. Must remain static to use."
	cooldown_duration = 10 SECONDS
	ability_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_SHIELD,
		KEYBINDING_ALTERNATE = COMSIG_XENOABILITY_TRIGGER_PSYCHIC_SHIELD,
	)
	use_state_flags = ABILITY_USE_BUSY
	/// The actual shield object created by this ability
	var/obj/effect/xeno/shield/active_shield

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


/datum/action/ability/activable/xeno/psychic_shield/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(active_shield)
		if(ability_cost > xeno_owner.plasma_stored)
			owner.balloon_alert(owner, "[ability_cost - xeno_owner.plasma_stored] more plasma!")
			return FALSE
		if(can_use_action(FALSE, ABILITY_USE_BUSY))
			shield_blast()
			cancel_shield()
		return

	if(A)
		owner.dir = get_cardinal_dir(owner, A) //if activated by mouse click, we face the atom clicked

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
	xeno_owner.move_resist = MOVE_FORCE_EXTREMELY_STRONG

	GLOB.round_statistics.psy_shields++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_shields")

	active_shield = new(target_turf, owner)
	if(!do_after(owner, 6 SECONDS, NONE, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, PROC_REF(can_use_action), FALSE, ABILITY_USE_BUSY)))
		cancel_shield()
		return
	cancel_shield()

///Removes the shield and resets the ability
/datum/action/ability/activable/xeno/psychic_shield/proc/cancel_shield()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	action_icon_state = "psy_shield"
	xeno_owner.update_glow()
	xeno_owner.move_resist = initial(xeno_owner.move_resist)
	update_button_icon()
	add_cooldown()
	if(active_shield)
		active_shield.release_projectiles()
		QDEL_NULL(active_shield)

///AOE knockback triggerable by ending the shield early
/datum/action/ability/activable/xeno/psychic_shield/proc/shield_blast()
	succeed_activate()

	active_shield.reflect_projectiles()

	owner.visible_message(span_xenowarning("[owner] sends out a huge blast of psychic energy!"), span_xenowarning("We send out a huge blast of psychic energy!"))

	var/turf/lower_left
	var/turf/upper_right
	switch(active_shield.dir)
		if(NORTH)
			lower_left = locate(owner.x - 1, owner.y + 1, owner.z)
			upper_right = locate(owner.x + 1, owner.y + 2, owner.z)
		if(SOUTH)
			lower_left = locate(owner.x - 1, owner.y - 2, owner.z)
			upper_right = locate(owner.x + 1, owner.y - 1, owner.z)
		if(WEST)
			lower_left = locate(owner.x - 2, owner.y - 1, owner.z)
			upper_right = locate(owner.x - 1, owner.y + 1, owner.z)
		if(EAST)
			lower_left = locate(owner.x + 1, owner.y - 1, owner.z)
			upper_right = locate(owner.x + 2, owner.y + 1, owner.z)

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
				H.apply_effects(1 SECONDS, 1 SECONDS)
				shake_camera(H, 2, 1)
			var/throwlocation = affected.loc
			for(var/x in 1 to 6)
				throwlocation = get_step(throwlocation, active_shield.dir)
			affected.throw_at(throwlocation, 4, 1, owner, TRUE)

	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, 'sound/voice/alien_roar_warlock.ogg', 25)

	GLOB.round_statistics.psy_shield_blasts++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_shield_blasts")


/obj/effect/xeno/shield
	icon = 'icons/Xeno/96x96.dmi'
	icon_state = "shield"
	resistance_flags = BANISH_IMMUNE|UNACIDABLE|PLASMACUTTER_IMMUNE
	max_integrity = 350
	layer = ABOVE_MOB_LAYER
	///Who created the shield
	var/mob/living/carbon/xenomorph/owner
	///All the projectiles currently frozen by this obj
	var/list/frozen_projectiles = list()

/obj/effect/xeno/shield/Initialize(mapload, creator)
	. = ..()
	if(!creator)
		return INITIALIZE_HINT_QDEL
	owner = creator
	dir = owner.dir
	max_integrity = owner.xeno_caste.shield_strength
	obj_integrity = max_integrity
	if(dir & (EAST|WEST))
		bound_height = 96
		bound_y = -32
		pixel_y = -32
	else
		bound_width = 96
		bound_x = -32
		pixel_x = -32

/obj/effect/xeno/shield/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(!(cardinal_move & REVERSE_DIR(dir)))
		return FALSE
	return !uncrossing

/obj/effect/xeno/shield/do_projectile_hit(obj/projectile/proj)
	proj.flags_projectile_behavior |= PROJECTILE_FROZEN
	proj.iff_signal = null
	frozen_projectiles += proj
	take_damage(proj.damage, proj.ammo.damage_type, proj.ammo.armor_type, 0, REVERSE_DIR(proj.dir), proj.ammo.penetration)
	alpha = obj_integrity * 255 / max_integrity
	if(obj_integrity <= 0)
		release_projectiles()
		owner.apply_effect(1 SECONDS, WEAKEN)

/obj/effect/xeno/shield/obj_destruction()
	release_projectiles()
	owner.apply_effect(1 SECONDS, WEAKEN)
	return ..()

///Unfeezes the projectiles on their original path
/obj/effect/xeno/shield/proc/release_projectiles()
	for(var/obj/projectile/proj AS in frozen_projectiles)
		proj.flags_projectile_behavior &= ~PROJECTILE_FROZEN
		proj.resume_move()
	record_projectiles_frozen(owner, LAZYLEN(frozen_projectiles))

///Reflects projectiles based on their relative incoming angle
/obj/effect/xeno/shield/proc/reflect_projectiles()
	playsound(loc, 'sound/effects/portal.ogg', 20)
	var/perpendicular_angle = Get_Angle(get_turf(src), get_step(src, dir)) //the angle src is facing, get_turf because pixel_x or y messes with the angle
	for(var/obj/projectile/proj AS in frozen_projectiles)
		proj.flags_projectile_behavior &= ~PROJECTILE_FROZEN
		proj.distance_travelled = 0 //we're effectively firing it fresh
		var/new_angle = (perpendicular_angle + (perpendicular_angle - proj.dir_angle - 180))
		if(new_angle < 0)
			new_angle += 360
		else if(new_angle > 360)
			new_angle -= 360
		proj.firer = src
		proj.fire_at(shooter = src, source = src, angle = new_angle, recursivity = TRUE)

		//Record those sick rocket shots
		//Is not part of record_projectiles_frozen() because it is probably bad to be running that for every bullet!
		if(istype(proj.ammo, /datum/ammo/rocket) && owner.client)
			var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
			personal_statistics.rockets_reflected++

	record_projectiles_frozen(owner, LAZYLEN(frozen_projectiles), TRUE)
	frozen_projectiles.Cut()


// ***************************************
// *********** psychic crush
// ***************************************
/datum/action/ability/activable/xeno/psy_crush
	name = "Psychic Crush"
	action_icon_state = "psy_crush"
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

	var/mob/living/carbon/xenomorph/xeno_owner = owner
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
	var/mob/living/carbon/xenomorph/xeno_owner = owner
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
			if(LinkBlocked(current_turf, turf_to_check, air_pass = TRUE))
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
	var/mob/living/carbon/xenomorph/xeno_owner = owner
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
				carbon_victim.apply_damage(xeno_owner.xeno_caste.crush_strength, BRUTE, blocked = BOMB)
				carbon_victim.apply_damage(xeno_owner.xeno_caste.crush_strength * 1.5, STAMINA, blocked = BOMB)
				carbon_victim.adjust_stagger(5 SECONDS)
				carbon_victim.add_slowdown(6)
			else if(ismecha(victim))
				var/obj/vehicle/sealed/mecha/mecha_victim = victim
				mecha_victim.take_damage(xeno_owner.xeno_caste.crush_strength * 5, BRUTE, BOMB)
	stop_crush()

/// stops channeling and unregisters all listeners, resetting the ability
/datum/action/ability/activable/xeno/psy_crush/proc/stop_crush()
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/xeno_owner = owner
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

// ***************************************
// *********** Psyblast
// ***************************************
/datum/action/ability/activable/xeno/psy_blast
	name = "Psychic Blast"
	action_icon_state = "psy_blast"
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

/datum/action/ability/activable/xeno/psy_blast/on_cooldown_finish()
	owner.balloon_alert(owner, "Psy blast ready")
	return ..()

/datum/action/ability/activable/xeno/psy_blast/action_activate()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.selected_ability == src)
		var/list/spit_types = xeno_owner.xeno_caste.spit_types
		if(length(spit_types) <= 1)
			return ..()
		var/found_pos = spit_types.Find(xeno_owner.ammo.type)
		if(!found_pos)
			xeno_owner.ammo = GLOB.ammo_list[spit_types[1]]
		else
			xeno_owner.ammo = GLOB.ammo_list[spit_types[(found_pos%length(spit_types))+1]]	//Loop around if we would exceed the length
		var/datum/ammo/energy/xeno/selected_ammo = xeno_owner.ammo
		ability_cost = selected_ammo.ability_cost
		particle_type = selected_ammo.channel_particle
		owner.balloon_alert(owner, "[selected_ammo]")
		update_button_icon()
	return ..()


/datum/action/ability/activable/xeno/psy_blast/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!xeno_owner.check_state())
		return FALSE
	var/datum/ammo/energy/xeno/selected_ammo = xeno_owner.ammo
	if(selected_ammo.ability_cost > xeno_owner.plasma_stored)
		if(!silent)
			owner.balloon_alert(owner, "[selected_ammo.ability_cost - xeno_owner.plasma_stored] more plasma!")

		return FALSE

/datum/action/ability/activable/xeno/psy_blast/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	owner.balloon_alert(owner, "We channel our psychic power")
	generate_particles(A, 7)
	ADD_TRAIT(xeno_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
	var/datum/ammo/energy/xeno/ammo_type = xeno_owner.ammo
	xeno_owner.update_glow(3, 3, ammo_type.glow_color)

	if(!do_after(xeno_owner, 1 SECONDS, IGNORE_TARGET_LOC_CHANGE, A, BUSY_ICON_DANGER) || !can_use_ability(A, FALSE) || !(A in range(get_screen_size(TRUE), owner)))
		owner.balloon_alert(owner, "Our focus is disrupted")
		end_channel()
		REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
		return fail_activate()

	succeed_activate()

	var/obj/projectile/hitscan/projectile = new /obj/projectile/hitscan(xeno_owner.loc)
	projectile.effect_icon = initial(ammo_type.hitscan_effect_icon)
	projectile.generate_bullet(ammo_type)
	projectile.fire_at(A, xeno_owner, null, projectile.ammo.max_range, projectile.ammo.shell_speed)
	playsound(xeno_owner, 'sound/weapons/guns/fire/volkite_4.ogg', 40)

	if(istype(xeno_owner.ammo, /datum/ammo/energy/xeno/psy_blast))
		GLOB.round_statistics.psy_blasts++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_blasts")
	else
		GLOB.round_statistics.psy_lances++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_lances")

	add_cooldown()
	update_button_icon()
	REMOVE_TRAIT(xeno_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(end_channel)), 5)

/datum/action/ability/activable/xeno/psy_blast/update_button_icon()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/ammo/energy/xeno/ammo_type = xeno_owner.ammo
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
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	QDEL_NULL(particle_holder)
	xeno_owner.update_glow()
