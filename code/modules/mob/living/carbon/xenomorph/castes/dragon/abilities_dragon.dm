
/datum/action/xeno_action/activable/tail_stab
	name = "Tail Stab"
	// action_icon_state = "todo"
	desc = "Stab a human with your tail, immobilizing it, and setting it on fire after a moment."
	use_state_flags = XACT_USE_STAGGERED
	plasma_cost = 100
	cooldown_timer = 7 SECONDS
	var/tail_stab_range = 2
	var/tail_stab_delay = 1.5 SECONDS

/datum/action/xeno_action/activable/tail_stab/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!. || owner.do_actions)
		return FALSE
	var/mob/living/target_living = target
	if(!isliving(target) || target_living.stat == DEAD)
		if(!silent)
			owner.balloon_alert(owner, "We can't tail stab that!")
		return FALSE
	// TODO, replace this with something that deals with densities, not sight
	if(!line_of_sight(owner, target, tail_stab_delay))
		if(!silent)
			owner.balloon_alert(owner, "You can't reach the target from here!")
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/tail_stab/use_ability(mob/living/carbon/human/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	target.apply_damage(owner_xeno.xeno_caste.melee_damage * owner_xeno.xeno_melee_damage_modifier)
	playsound(owner_xeno, 'sound/weapons/alien_tail_attack.ogg', 50, TRUE)
	log_combat(owner_xeno, target, "fire tailkstabbed")
	owner_xeno.balloon_alert_to_viewers("has tail-stabbed [target]")
	owner_xeno.face_atom(target)
	target.Immobilize(tail_stab_delay)
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 10)
	owner_xeno.do_attack_animation(target, ATTACK_EFFECT_GRAB)
	var/tail_stab_start_time = world.time

	if(!do_after(owner_xeno, tail_stab_delay))
		owner_xeno.balloon_alert(owner_xeno, "You give up on lighting [target] on fire!")
		// Remove the remaining stun that's left
		target.AdjustImmobilized(world.time - tail_stab_start_time - tail_stab_delay)
		add_cooldown(cooldown_timer * 0.5)
		return succeed_activate() 
	owner_xeno.do_attack_animation(target, ATTACK_EFFECT_REDSTAB)
	owner_xeno.balloon_alert_to_viewers("has set [target] on fire with their tail!")
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 40)
	add_cooldown()
	return succeed_activate()

/datum/action/xeno_action/activable/xeno_spit/fireball
	name = "Spit a fireball"
	desc = "Belch a fiery fireball at your foes."
	var/flying_spit_delay = 1.5 SECONDS
	var/flying_spit_type = /datum/ammo/flamethrower/dragon_fire/flying

/datum/action/xeno_action/activable/xeno_spit/fireball/alternate_fire_at(obj/projectile/newspit, mob/living/carbon/xenomorph/spitter_xeno)
	if(istype(newspit, /datum/ammo/flamethrower/dragon_fire))
		var/datum/ammo/flamethrower/dragon_fire/dragon_spit = newspit
		dragon_spit.hivenumber = spitter_xeno.hivenumber

	if(spitter_xeno.has_status_effect(STATUS_EFFECT_FLIGHT))
		return flight_spit(newspit, owner)
	// Hover spit uses normal spit, but with a different animation
	else if(spitter_xeno.has_status_effect(STATUS_EFFECT_HOVER))
		return hover_spit(newspit, owner)
	else
		// False will make it spit normally
		return FALSE

// The flight spit drops down from above, as the dragon is invisible while flying
/datum/action/xeno_action/activable/xeno_spit/fireball/proc/flight_spit(obj/projectile/newspit, mob/living/carbon/xenomorph/spitter_xeno)
	var/turf/target_turf = get_turf(target)
	var/obj/effect/effect = new /obj/effect(target_turf)
	effect.icon = 'icons/misc/mark.dmi'
	effect.icon_state = "X"
	effect.color = "purple"
	QDEL_IN(effect, 3 SECONDS)
	
	newspit.dir = SOUTH
	animate(newspit, pixel_y = 0, time = flying_spit_delay, easing = CIRCULAR_EASING)
	addtimer(CALLBACK(src, .proc/flight_spit_drop, newspit, target_turf), flying_spit_delay)
	return continue_autospit()

/datum/action/xeno_action/activable/xeno_spit/fireball/proc/flight_spit_drop(obj/projectile/newspit, turf/target_turf)
	// Make a list of all the mobs in the turf
	var/list/mobs_in_turf = list()
	if(!current_target || !isliving(current_target))
		for(var/mob/living/mob_in_turf in target_turf)
			mobs_in_turf += mob_in_turf
	else
		mobs_in_turf += current_target
	// We don't want to run this multiple times, because this causes fire to be spawned, and that causes damage
	var/mob/living/mob_to_hurt = pick(mobs_in_turf) 
	mob_to_hurt.do_projectile_hit(newspit)

	qdel(newspit)

// The hover spit should account for the dragon's offset
/datum/action/xeno_action/activable/xeno_spit/fireball/proc/hover_spit(obj/projectile/newspit, mob/living/carbon/xenomorph/spitter_xeno)
	ENABLE_BITFIELD(newspit.ammo?.flags_ammo_behavior, AMMO_PASS_THROUGH_MOVABLE)
	newspit.pixel_y = spitter_xeno.pixel_y
	animate(newspit, pixel_y = 0, time = flying_spit_delay, easing = LINEAR_EASING)
	// False will make it spit normally
	return FALSE

/datum/action/xeno_action/flight
	name = "Skycall"
	desc = "Take flight and rain hell upon your enemies! Right click the action button to descend, and left click to ascend."
	cooldown_timer = 3 MINUTES
	var/list/blacklisted_areas = list(
		/area/shuttle/dropship,
		/area/shuttle
	)
	var/datum/status_effect/xeno/dragon_flight/flight

/datum/action/xeno_action/flight/can_use_action(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(owner.do_actions)
		return FALSE
	var/invalid_area = FALSE
	var/area/owner_area = get_area(owner)
	if(owner_area.ceiling != CEILING_NONE)
		if(!silent)
			owner.balloon_alert(owner, "the ceiling here stops you from flying!")
		return FALSE
	for(var/area/area in blacklisted_areas)
		if(istype(owner_area, area))
			invalid_area = TRUE
			break
	if(invalid_area)
		if(!silent)
			owner.balloon_alert(owner, "can't fly in this area!")
		return FALSE

/datum/action/xeno_action/flight/action_activate()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(flight?.hover_transition)
		return fail_activate()
	// If we're already at max height, tell them how to descend
	if(istype(flight, STATUS_EFFECT_FLIGHT))
		// Tempting to make this land you immediately,
		//  but having a way to inform the player how to do it themselves is better
		owner_xeno.balloon_alert(owner_xeno, "right click the action button to land!")
		return fail_activate()
	var/old_flight_landing_delay = flight ? flight.landing_delay : 0
	if(!ascend_to_flight_or_hover())
		return
	
	if(!do_after(owner_xeno, 10 SECONDS))
		if(old_flight_landing_delay)
			owner_xeno.AdjustImmobilized(-old_flight_landing_delay)
		alternate_action_activate(TRUE)
		return fail_activate()

/datum/action/xeno_action/flight/alternate_action_activate(silent = FALSE)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(!flight)
		if(!silent)
			owner_xeno.balloon_alert(owner_xeno, "you're not flying!")
		fail_activate()
		return
	owner_xeno.Immobilize(flight.landing_delay, TRUE)
	owner_xeno.remove_status_effect(flight)
	switch(flight.type)
		if(STATUS_EFFECT_FLIGHT)
			flight = flight.transition_to_hover()
		if(STATUS_EFFECT_HOVER)
			// Full cooldown if we're landed on the ground.
			add_cooldown()
			land()

/datum/action/xeno_action/flight/proc/ascend_to_flight_or_hover(is_hovering = FALSE)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/status_effect_to_add
	if(!flight)
		owner_xeno.balloon_alert_to_viewers("unfolds it's wings and begins to ascend!")
		status_effect_to_add = STATUS_EFFECT_HOVER

	else if(is_hovering)
		owner_xeno.visible_message("<span class='warning'>[owner_xeno] begins to ascend to the skies!</span>")
		status_effect_to_add = STATUS_EFFECT_FLIGHT

	if(!status_effect_to_add)
		return FALSE

	flight = owner_xeno.apply_status_effect(status_effect_to_add)
	var/takeoff_time = initial(flight.takeoff_flaps) * initial(flight.flap_delay) + 1 SECONDS
	owner_xeno.AdjustImmobilized(takeoff_time)
	return TRUE

/datum/action/xeno_action/flight/proc/land()
	if(!flight)
		CRASH("Somehow called land() while not even flying, or the pointer to the flight effect was missing")
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.remove_status_effect(flight)
	flight = null

/datum/action/xeno_action/flight/remove_action(mob/living/L)
	. = ..()
	if(flight)
		land()
