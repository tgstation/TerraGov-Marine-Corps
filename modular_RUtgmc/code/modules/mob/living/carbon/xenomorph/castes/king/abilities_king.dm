/datum/action/xeno_action/activable/off_guard/use_ability(atom/target)
	var/mob/living/carbon/human/human_target = target
	human_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_ACCURACY_DEBUFF, 8 SECONDS)
	human_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 8 SECONDS)
	human_target.apply_status_effect(/datum/status_effect/incapacitating/offguard_slowdown, 8 SECONDS)
	human_target.log_message("has been off-guarded by [owner]", LOG_ATTACK, color="pink")
	human_target.balloon_alert_to_viewers("confused")
	playsound(human_target, 'sound/effects/off_guard_ability.ogg', 50)

	add_cooldown()
	succeed_activate()
