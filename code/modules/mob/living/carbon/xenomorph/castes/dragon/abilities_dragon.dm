/datum/ammo/flamethrower/dragon_fire
	fire_color = "purple"
	burn_flags = BURN_HUMANS|BURN_SNOW

/obj/flamer_fire/resin
	burnflags = BURN_HUMANS|BURN_SNOW
	color = "purple"

#define DRAGON_TAIL_STAB_DELAY 1.5 SECONDS
/datum/action/xeno_action/activable/tail_stab
	name = "Tail Stab"
	// action_icon_state = "todo"
	mechanics_text = "Stab a human with your tail, immobilizing it, and setting it on fire after a moment."
	use_state_flags = XACT_USE_STAGGERED
	plasma_cost = 100
	cooldown_timer = 7 SECONDS

/datum/action/xeno_action/activable/tail_stab/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(owner.do_actions)
		return FALSE
	var/mob/living/carbon/human/target_human = target
	if(!ishuman(target) || target_human.stat == DEAD)
		if(!silent)
			owner.balloon_alert("We can't tail stab that!")
		return FALSE
	if(!line_of_sight(owner, target, 2))
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
	if(!do_after(owner_xeno, DRAGON_TAIL_STAB_DELAY, extra_checks=CALLBACK(.proc/can_use_ability, target)))
		owner_xeno.balloon_alert(owner_xeno, "You give up on lighting [target] on fire!")
		add_cooldown(3 SECONDS)
		return succeed_activate()
	owner_xeno.balloon_alert_to_viewers("has set [target] on fire with their tail!")
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 40)
	add_cooldown()
	return succeed_activate()

#undef DRAGON_TAIL_STAB_DELAY

/datum/action/xeno_action/activable/xeno_spit/fireball
	name = "Shoot selected Projectile"
	mechanics_text = "Belch the selected projectile at your foes."


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

/datum/action/xeno_action/activable/flight/on_activation()

// Mostly re-used from hivemind
/mob/living/carbon/xenomorph/proc/toggle_flight(invincibility = TRUE)
	if(status_flags & INCORPOREAL)
		invisibility = initial(invisibility)
		status_flags = initial(status_flags)
		// upgrade = initial(upgrade)
		resistance_flags = initial(resistance_flags)
		flags_pass = initial(flags_pass)
		density = initial(flags_pass)
		throwpass = initial(throwpass)
	else
		invisibility = INVISIBILITY_MAXIMUM
		status_flags = invincibility ? GODMODE | INCORPOREAL : INCORPOREAL
		// upgrade = XENO_UPGRADE_ZERO
		resistance_flags = BANISH_IMMUNE
		flags_pass = NONE
		density = TRUE
		throwpass = FALSE

	update_wounds()
	update_icon()
	update_action_buttons()
