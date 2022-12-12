
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
		add_cooldown(5 SECONDS)
		return succeed_activate() 

	owner_xeno.balloon_alert_to_viewers("has set [target] on fire with their tail!")
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 40)
	add_cooldown()
	return succeed_activate()

#undef DRAGON_TAIL_STAB_RANGE
#undef DRAGON_TAIL_STAB_DELAY

/datum/action/xeno_action/activable/xeno_spit/fireball
	name = "Spit a fireball"
	mechanics_text = "Belch a fiery fireball at your foes."

/datum/action/xeno_action/activable/flight
	name = "Skycall"
	mechanics_text = "Take flight and rain hell upon your enemies!"
	cooldown_timer = 3 MINUTES
	var/list/blacklisted_areas = list(
		/area/shuttle/dropship,
		/area/shuttle/
	)

/datum/action/xeno_action/activable/flight/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(owner.do_actions)
		return FALSE
	var/invalid_area = FALSE
	for(var/area/area in blacklisted_areas)
		var/area/owner_area = get_area(get_turf(owner))
		if(istype(owner_area, area))
			invalid_area = TRUE
			break
	if(invalid_area)
		if(!silent)
			owner.balloon_alert("can't fly here!")
		return FALSE

/datum/action/xeno_action/activable/flight/on_activation()
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	// A status effect for better edge case handling
	owner_xeno.apply_status_effect(STATUS_EFFECT_FLIGHT)
	if(!do_after(owner_xeno, 10 SECONDS))
		owner_xeno.remove_status_effect(STATUS_EFFECT_FLIGHT)
