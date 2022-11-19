// ***************************************
// *********** Psychic shield
// ***************************************
/datum/action/xeno_action/activable/psychic_shield
	name = "Psychic Shield"
	ability_name = "psychic shield"
	action_icon_state = "psy_shield"
	mechanics_text = "Channel a psychic shield at your current location that can reflect most projectiles. Activate again while the shield is active to detonate the shield forcibly, producing knockback. Must remain static to use."
	cooldown_timer = 8 SECONDS
	plasma_cost = 200
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_SHIELD,
	)
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	use_state_flags = XACT_USE_BUSY
	var/obj/effect/xeno/shield/active_shield


/datum/action/xeno_action/activable/psychic_shield/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to create a psychic shield again."))
	return ..()

/datum/action/xeno_action/activable/psychic_shield/use_ability(atom/A)
	. = ..()
	if(active_shield)
		var/mob/living/carbon/xenomorph/xeno_owner = owner
		if(plasma_cost > xeno_owner.plasma_stored)
			to_chat(xeno_owner, span_warning("We need [plasma_cost - xeno_owner.plasma_stored] more plasma!"))
			return FALSE
		if(can_use_action(FALSE, XACT_USE_BUSY))
			shield_blast()
			cancel_shield()
		return
	owner.visible_message("A strange and violent psychic aura is suddenly emitted from \the [owner]!")
	playsound(owner,'sound/effects/magic.ogg', 75, 1)

	active_shield = new(get_step(owner, owner.dir), owner)
	action_icon_state = "psy_shield_reflect"
	succeed_activate()
	//GLOB.round_statistics.psy_shields++
	//SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_shields")
	if(!do_after(owner, 5 SECONDS, TRUE, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_use_action, FALSE, XACT_USE_BUSY)))
		cancel_shield()
		return
	cancel_shield()

///Removes the shield and resets the ability
/datum/action/xeno_action/activable/psychic_shield/proc/cancel_shield()
	qdel(active_shield)
	active_shield = null
	action_icon_state = "psy_shield"
	add_cooldown()

///AOE knockback triggerable by ending the shield early
/datum/action/xeno_action/activable/psychic_shield/proc/shield_blast()
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

	for(var/turf/affected_tile in block(lower_left, upper_right)) //everything in the 2x3 block is found.
		affected_tile.Shake(4, 4, 2 SECONDS)
		for(var/i in affected_tile)
			var/atom/movable/affected = i
			if(!ishuman(affected) && !istype(affected, /obj/item) && !isdroid(affected))
				affected.Shake(4, 4, 20)
				continue
			if(ishuman(affected))
				var/mob/living/carbon/human/H = affected
				if(H.stat == DEAD)
					continue
				H.apply_effects(1, 1)
				shake_camera(H, 2, 1)
			var/throwlocation = affected.loc
			for(var/x in 1 to 6)
				throwlocation = get_step(throwlocation, owner.dir)
			affected.throw_at(throwlocation, 4, 1, owner, TRUE)

	owner.visible_message(span_xenowarning("[owner] sends out a huge blast of psychic energy!"), \
	span_xenowarning("We send out a huge blast of psychic energy!"))

	playsound(owner,'sound/effects/bamf.ogg', 75, TRUE)
	playsound(owner, "alien_roar", 50)
	//GLOB.round_statistics.psy_shield_blasts++
	//SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_shield_blasts")
	succeed_activate()

/obj/effect/xeno/shield
	icon = 'icons/Xeno/96x96.dmi'
	icon_state = "shield"
	resistance_flags = RESIST_ALL
	layer = ABOVE_MOB_LAYER
	var/mob/living/carbon/xenomorph/owner

/obj/effect/xeno/shield/Initialize(loc, creator)
	. = ..()
	owner = creator
	dir = owner.dir
	if(dir == EAST || dir == WEST)
		bound_height = 96
		bound_y = -32
		pixel_y = -32
	else
		bound_width = 96
		bound_x = -32
		pixel_x = -32

/obj/effect/xeno/shield/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(!(cardinal_move & REVERSE_DIR(dir)))
		if(!uncrossing)
			proj.uncross_scheduled += src
		return FALSE
	if (uncrossing)
		return FALSE
	reflect_projectile(proj)
	return FALSE

///Reflects projectiles based on their relative incoming angle
/obj/effect/xeno/shield/proc/reflect_projectile(obj/projectile/proj)
	playsound(loc, 'sound/effects/portal.ogg', 20)
	var/new_range = proj.proj_max_range - proj.distance_travelled

	if(new_range <= 0)
		proj.ammo.do_at_max_range(proj)
		qdel(proj)
		return
	var/perpendicular_angle = Get_Angle(src, get_step(src, dir)) //the angle src is facing
	var/new_angle = (perpendicular_angle + (perpendicular_angle - proj.dir_angle - 180))
	if(new_angle < 0)
		new_angle += 360
	else if(new_angle > 360)
		new_angle -= 360
	proj.firer = src
	proj.fire_at(shooter = src, source = src, range = new_range, angle = new_angle, recursivity = TRUE) //loc_override = loc //note investigate hitscan issue

// ***************************************
// *********** psychic crush
// ***************************************
/datum/action/xeno_action/activable/psy_crush
	name = "psychic Crush"
	action_icon_state = "psy_crush"
	mechanics_text = "Channel our psychic force to crush our enemies. The longer we channel, the larger the area."
	ability_name = "psychic crush"
	plasma_cost = 35
	cooldown_timer = 8 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
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
	var/list/target_turfs = list()
	///list of effects used to visualise area of effect
	var/list/effect_list = list()
	/// A list of all things that had a fliter applied
	var/list/filters_applied = list()
	///max range at which we can cast out ability
	var/ability_range = 9

/datum/action/xeno_action/activable/psy_crush/use_ability(atom/target)
	if(channel_loop_timer)
		if(length(target_turfs)) //it shouldn't be possible to do this without any turfs, but just in case
			crush(target_turfs[1])
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(xeno_owner.selected_ability != src)
		action_activate()
		return
	if(owner.do_actions || !target || !can_use_action(TRUE) || !check_distance(target))
		return fail_activate()
	if(!do_after(owner, 0.5 SECONDS, TRUE, owner, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_use_action, FALSE, XACT_USE_BUSY)))
		return fail_activate()
	owner.visible_message(span_xenowarning("\The [owner] starts channeling their psychic might!"), \
		span_xenowarning("We start channeling our psychic might!"))
	var/turf/target_turf = get_turf(target)
	target_turfs += target_turf
	effect_list += new /obj/effect/xeno/crush_warning(target_turf)
	owner.add_movespeed_modifier(MOVESPEED_ID_WARLOCK_CHANNELING, TRUE, 0, NONE, TRUE, 0.9)
	action_icon_state = "psy_crush_activate"
	do_channel(target_turf)
	RegisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_ADDTRAIT(TRAIT_IMMOBILE)), .proc/stop_crush)

///Checks if the owner is close enough/can see the target
/datum/action/xeno_action/activable/psy_crush/proc/check_distance(atom/target, silent)
	var/dist = get_dist(owner, target)
	if(dist > ability_range)
		to_chat(owner, span_warning("Too far for our reach... We need to be [dist - ability_range] steps closer!"))
		return FALSE
	else if(!line_of_sight(owner, target, 9))
		to_chat(owner, span_warning("We can't focus properly without a clear line of sight!"))
		return FALSE
	return TRUE

///Increases the area of effect, or triggers the crush if we've reached max iterations
/datum/action/xeno_action/activable/psy_crush/proc/do_channel(turf/target)
	channel_loop_timer = null
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!check_distance(target) || isnull(xeno_owner) || xeno_owner.stat == DEAD)
		stop_crush(target)
		return
	if(current_iterations >= max_interations)
		crush(target)
		return
	playsound(target, 'sound/effects/woosh_swoosh.ogg', 30 + (current_iterations * 10))

	succeed_activate()

	var/list/turfs_to_add = list()
	for(var/turf/current_turf AS in target_turfs)
		var/list/turfs_to_check = get_adjacent_open_turfs(current_turf)
		for(var/turf/turf_to_check AS in turfs_to_check)
			if((turf_to_check in target_turfs) || (turf_to_check in turfs_to_add))
				continue
			turfs_to_add += turf_to_check
			effect_list += new /obj/effect/xeno/crush_warning(turf_to_check)
	target_turfs += turfs_to_add
	current_iterations ++
	if(can_use_action(xeno_owner, XACT_IGNORE_COOLDOWN))
		channel_loop_timer = addtimer(CALLBACK(src, .proc/do_channel, target), 8, TIMER_STOPPABLE)
		return
	stop_crush(target)

///crushes all turfs in the AOE
/datum/action/xeno_action/activable/psy_crush/proc/crush(turf/target)
	//note: do we need a check to see if we have sufficient plasma, due to the override?
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/crush_cost = plasma_cost * current_iterations
	if(crush_cost > xeno_owner.plasma_stored)
		to_chat(xeno_owner, span_warning("We need [crush_cost - xeno_owner.plasma_stored] more plasma!"))
		return
	if(!check_distance(target))
		stop_crush(target)
		return
	succeed_activate(plasma_cost * current_iterations)
	to_chat(owner, span_warning("We unleash our psychic might!"))
	playsound(target, 'sound/effects/EMPulse.ogg', 70)
	apply_filters(target_turfs)
	addtimer(CALLBACK(src, .proc/remove_all_filters), 2 SECONDS, TIMER_STOPPABLE)
	for(var/turf/effected_turf AS in target_turfs)
		for(var/i AS in effected_turf)
			if(iscarbon(i))
				var/mob/living/carbon/carbon_victim = i
				if(isxeno(carbon_victim) || carbon_victim.stat == DEAD)
					continue
				var/block = carbon_victim.get_soft_armor(BOMB)
				carbon_victim.apply_damage(35, BRUTE, blocked = block)
				carbon_victim.apply_damage(50, STAMINA, blocked = block)
				carbon_victim.adjust_stagger(6)
				carbon_victim.add_slowdown(8)
			else if(ismecha(i))
				var/obj/vehicle/sealed/mecha/mecha_victim = i
				mecha_victim.ex_act(EXPLODE_HEAVY)
			else if(isobj(i))
				var/obj/obj_victim = i
				if(istype(obj_victim, /obj/alien))
					continue
				obj_victim.ex_act(EXPLODE_LIGHT)
	stop_crush(target)

/// stops channeling and unregisters all listeners, resetting the ability
/datum/action/xeno_action/activable/psy_crush/proc/stop_crush(turf/target)
	SIGNAL_HANDLER
	if(channel_loop_timer)
		deltimer(channel_loop_timer)
		channel_loop_timer = null
	for(var/obj/effect/xeno/crush_warning/current_effect AS in effect_list)
		qdel(current_effect)
	current_iterations = 0
	target_turfs = list()
	effect_list = list()
	owner.remove_movespeed_modifier(MOVESPEED_ID_WARLOCK_CHANNELING)
	action_icon_state = "psy_crush"
	add_cooldown()
	UnregisterSignal(owner, list(SIGNAL_ADDTRAIT(TRAIT_FLOORED), SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), SIGNAL_ADDTRAIT(TRAIT_IMMOBILE)))

///Apply a filter on all items in the list of turfs
/datum/action/xeno_action/activable/psy_crush/proc/apply_filters(list/turfs)
	for(var/turf/targeted AS in turfs)
		targeted.add_filter("crushblur", 1, radial_blur_filter(0.3))
		filters_applied += targeted
		for(var/atom/movable/item AS in targeted.contents)
			item.add_filter("crushblur", 1, radial_blur_filter(0.3))
			filters_applied += item
	//GLOB.round_statistics.psy_crushes++
	//SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_crushes")

///Remove all filters of items in filters_applied
/datum/action/xeno_action/activable/psy_crush/proc/remove_all_filters()
	for(var/atom/thing AS in filters_applied)
		if(QDELETED(thing))
			continue
		thing.remove_filter("crushblur")
	filters_applied.Cut()

/obj/effect/xeno/crush_warning
	icon = 'icons/xeno/Effects.dmi'
	icon_state = "crush_warning"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = FLY_LAYER


// ***************************************
// *********** Psyblast
// ***************************************
/datum/action/xeno_action/activable/psy_blast
	name = "Psychic Blast"
	action_icon_state = "psy_blast"
	mechanics_text = "Launch a blast of psychic energy that deals light damage and knocks back enemies in its AOE. Must remain stationary for a few seconds to use."
	ability_name = "psychic blast"
	cooldown_timer = 6 SECONDS
	plasma_cost = 230
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_BLAST,
	)
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/psy_blast/on_cooldown_finish()
	to_chat(owner, span_notice("We feel our strength return. We are ready to unleash a psychic blast again."))
	return ..()

/datum/action/xeno_action/activable/psy_blast/action_activate()
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
		plasma_cost = selected_ammo.plasma_cost
		to_chat(xeno_owner, span_notice(selected_ammo.select_text))
		update_button_icon()
	return ..()


/datum/action/xeno_action/activable/psy_blast/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	if(!xeno_owner.check_state())
		return FALSE
	var/datum/ammo/energy/xeno/selected_ammo = xeno_owner.ammo
	if(selected_ammo.plasma_cost > xeno_owner.plasma_stored)
		if(!silent)
			to_chat(xeno_owner, span_warning("We need [selected_ammo.plasma_cost - xeno_owner.plasma_stored] more plasma!"))
		return FALSE

/datum/action/xeno_action/activable/psy_blast/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/turf/target = get_turf(A)

	if(!istype(target))
		return

	to_chat(xeno_owner, span_xenonotice("We channel our psychic power."))

	if(!do_after(xeno_owner, 1 SECONDS, FALSE, target, BUSY_ICON_DANGER))
		to_chat(xeno_owner, span_warning("Our focus is disrupted."))
		return fail_activate()

	if(!can_use_ability(target, FALSE))
		return fail_activate()

	xeno_owner.visible_message(span_xenowarning("\The [xeno_owner] launches a blast of psychic energy!"), \
	span_xenowarning("We launch a huge blast of psychic energy!"), null, 5)

	var/obj/projectile/hitscan/P = new /obj/projectile/hitscan(xeno_owner.loc)
	var/datum/ammo/energy/xeno/ammo_type = xeno_owner.ammo
	P.effect_icon = initial(ammo_type.hitscan_effect_icon)
	P.generate_bullet(ammo_type)
	P.fire_at(target, xeno_owner, null, P.ammo.max_range, P.ammo.shell_speed)
	playsound(xeno_owner, 'sound/weapons/guns/fire/volkite_4.ogg', 50)
	//if(istype(xeno_owner.ammo, /datum/ammo/energy/xeno/psy_blast))
	//	GLOB.round_statistics.psy_blasts++
	//	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_blasts")
	//else
	//	GLOB.round_statistics.psy_lances++
	//	SSblackbox.record_feedback("tally", "round_statistics", 1, "psy_lances")

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/activable/psy_blast/update_button_icon()
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/ammo/energy/xeno/ammo_type = xeno_owner.ammo
	action_icon_state = ammo_type.icon_state
	return ..()
