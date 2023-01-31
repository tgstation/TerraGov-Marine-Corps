
#define DRAGON_TAIL_STAB_DELAY 1.5 SECONDS
#define DRAGON_TAIL_STAB_RANGE 2
/datum/action/xeno_action/activable/tail_stab
	name = "Tail Stab"
	// action_icon_state = "todo"
	mechanics_text = "Stab a human with your tail, immobilizing it, and setting it on fire after a moment."
	use_state_flags = XACT_USE_STAGGERED
	plasma_cost = 100
	cooldown_timer = 7 SECONDS

/datum/action/xeno_action/activable/tail_stab/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(owner.do_actions)
		return FALSE
	var/mob/living/carbon/human/target_human = target
	if(!ishuman(target) || target_human.stat == DEAD)
		if(!silent)
			owner.balloon_alert("We can't tail stab that!")
		return FALSE
	// TODO, replace this with something that deals with densities, not sight
	if(!line_of_sight(owner, target, DRAGON_TAIL_STAB_RANGE))
		if(!silent)
			owner.balloon_alert("You can't reach the target from here!")
		return FALSE
	return TRUE

/datum/action/xeno_action/activable/tail_stab/use_ability(mob/living/carbon/human/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	target.apply_damage(owner_xeno.xeno_caste.melee_damage)
	playsound(owner_xeno, 'sound/weapons/alien_tail_attack.ogg', 50, TRUE)
	log_combat(owner_xeno, target, "fire tailkstabbed")
	owner_xeno.balloon_alert_to_viewers("has tail-stabbed [target]")
	owner_xeno.face_atom(target)
	target.Immobilize(DRAGON_TAIL_STAB_DELAY)
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 10)
	var/tail_stab_start_time = world.time

	if(!do_after(owner_xeno, DRAGON_TAIL_STAB_DELAY))
		owner_xeno.balloon_alert(owner_xeno, "You give up on lighting [target] on fire!")
		// Remove the remaining stun that's left
		target.AdjustImmobilized(world.time - tail_stab_start_time - DRAGON_TAIL_STAB_DELAY)
		add_cooldown(cooldown_timer * 0.5)
		return succeed_activate() 

	owner_xeno.balloon_alert_to_viewers("has set [target] on fire with their tail!")
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 40)
	add_cooldown()
	return succeed_activate()

/datum/action/xeno_action/activable/xeno_spit/fireball/modify_spit(obj/projectile/proj)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	var/datum/ammo/flamethrower/dragon_fire/spit
	if(!istype(proj, spit) && xeno_owner.hive)
		return
	spit = proj
	spit.hivenumber = xeno_owner.hivenumber

#undef DRAGON_TAIL_STAB_RANGE
#undef DRAGON_TAIL_STAB_DELAY

/datum/action/xeno_action/activable/xeno_spit/fireball
	name = "Spit a fireball"
	mechanics_text = "Belch a fiery fireball at your foes."

/datum/action/xeno_action/activable/xeno_spit/fireball/get_spit_type()
	var/mob/living/carbon/xenomorph/xeno = owner
	if(xeno.has_status_effect(STATUS_EFFECT_FLIGHT))
		xeno.ammo = /datum/ammo/flamethrower/dragon_fire/flying
	else
		xeno.ammo = /datum/ammo/flamethrower/dragon_fire

/datum/action/xeno_action/activable/xeno_spit/fireball/start_fire(datum/source, atom/object, turf/location, control, params, can_use_ability_flags)
	. = ..()
	if(!isliving(owner))
		return
	var/mob/living/living_owner = owner
	if(!living_owner.has_status_effect(STATUS_EFFECT_FLIGHT) || !living_owner.has_status_effect(STATUS_EFFECT_HOVER))
		return
	var/turf/turf = get_turf(current_target)
	var/obj/effect/effect = new /obj/effect(turf)
	effect.icon = 'icons/misc/mark.dmi'
	effect.icon_state = "X"
	effect.color = "purple"
	QDEL_IN(effect, 3 SECONDS)

/datum/action/xeno_action/flight
	name = "Skycall"
	mechanics_text = "Take flight and rain hell upon your enemies! Right click the action button to descend, and left click to ascend."
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
	if(owner_area.ceiling == CEILING_UNDERGROUND || owner_area.ceiling == CEILING_DEEP_UNDERGROUND)
		if(!silent)
			owner.balloon_alert("the ceiling here stops you from flying!")
		return FALSE
	for(var/area/area in blacklisted_areas)
		if(istype(owner_area, area))
			invalid_area = TRUE
			break
	if(invalid_area)
		if(!silent)
			owner.balloon_alert("can't fly in this area!")
		return FALSE

/datum/action/xeno_action/flight/action_activate()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	if(flight.hover_transition)
		return fail_activate()
	if(owner_xeno.has_status_effect(STATUS_EFFECT_FLIGHT))
		// Tempting to make this land you immediately,
		//  but having a way to inform the player how to do it themselves is better
		owner_xeno.balloon_alert(owner_xeno, "right click the action button to land!")
		return fail_activate()

	if(ascend_to_flight_or_hover())
		return succeed_activate()
	
	if(!do_after(owner_xeno, 10 SECONDS))
		owner_xeno.remove_status_effect(STATUS_EFFECT_FLIGHT)
		owner_xeno.AdjustImmobilized(-10 SECONDS)
		add_cooldown(1 MINUTES)
		return

/datum/action/xeno_action/flight/alternate_action_activate()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/is_hovering = istype(flight, STATUS_EFFECT_HOVER)
	if(!flight)
		return
	owner_xeno.Immobilize(flight.landing_delay, TRUE)
	owner_xeno.remove_status_effect(flight)
	if(is_hovering)
		// Full cooldown if we're landed on the ground.
		add_cooldown()
		return succeed_activate()
	if(flight.type == STATUS_EFFECT_FLIGHT)
		flight.transition_to_hover()

/datum/action/xeno_action/flight/proc/ascend_to_flight_or_hover(is_hovering = FALSE)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	var/old_effect = flight.type
	var/status_effect_to_add
	if(!flight)
		owner_xeno.balloon_alert_to_viewers("unfolds it's wings and flies low")
		status_effect_to_add = STATUS_EFFECT_HOVER
		owner_xeno.remove_status_effect(flight)
	else if(is_hovering)
		owner_xeno.visible_message("<span class='warning'>[owner_xeno] begins to ascend to the skies!</span>")
		status_effect_to_add = STATUS_EFFECT_FLIGHT
	if(!status_effect_to_add)
		return FALSE
	flight = owner_xeno.apply_status_effect(status_effect_to_add)
	var/takeoff_time = initial(flight.takeoff_flaps) * initial(flight.flap_delay) + 1 SECONDS
	owner_xeno.AdjustImmobilized(takeoff_time)
	if(!do_after(owner_xeno, takeoff_time))
		owner_xeno.remove_status_effect(flight)
		owner_xeno.AdjustImmobilized(-takeoff_time)
		flight = null
		if(status_effect_to_add != STATUS_EFFECT_HOVER)
			flight = owner_xeno.apply_status_effect(old_effect)
			if(status_effect_to_add == STATUS_EFFECT_FLIGHT)
				flight.hover_transition = TRUE
		return FALSE
	return TRUE

/datum/action/xeno_action/flight/remove_action(mob/living/L)
	. = ..()
	if(flight)
		L.remove_status_effect(flight)
