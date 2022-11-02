/obj/flamer_fire/resin
	burnflags = BURN_HUMANS|BURN_SNOW
	color = "purple"

/datum/action/xeno_action/activable/tail_stab
	name = "Tail Stab"
	// action_icon_state = "todo"
	mechanics_text = "Stab your target with your flaming tail"
	use_state_flags = XACT_USE_STAGGERED
	plasma_cost = 100
	cooldown_timer = 7 SECONDS

/datum/action/xeno_action/activable/tail_stab/can_use_ability(atom/target, silent = FALSE, override_flags)
	if(owner.do_actions)
		return FALSE
	if(!line_of_sight(owner, target, 2))
		if(!silent)
			to_chat(span_notice("You can't reach the target from here!"))
		return FALSE

/datum/action/xeno_action/activable/tail_stab/use_ability(mob/living/carbon/human/target)
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	target.apply_damage(owner_xeno.xeno_caste.melee_damage)
	playsound(owner_xeno, 'sound/weapons/alien_tail_attack.ogg', 50, TRUE)
	log_combat(owner_xeno, target, "fire tailkstabbed")
	owner_xeno.balloon_alert_to_viewers("[owner_xeno] has tail-stabbed [target]")
	if(!do_after(owner_xeno, 1.5 SECONDS, TRUE, target, TRUE, TRUE, PROGRESS_GENERIC, CALLBACK(src, .proc/can_use_ability, target)))
		owner_xeno.balloon_alert(owner_xeno, "You give up on lighting [target] on fire!")
		return
	owner_xeno.balloon_alert_to_viewers("[owner_xeno] has set [target] on fire with their tail!")
	target.apply_status_effect(STATUS_EFFECT_DRAGONFIRE, 40)

