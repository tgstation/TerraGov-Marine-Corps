#define MINDFRAY_RANGE 8
/datum/action/ability/activable/mindfray
	name = "Mindfray"
	action_icon_state = "off_guard"
	desc = "Muddles the mind of an enemy, making it harder for them to focus their aim for a while."
	cooldown_duration = 20 SECONDS
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OFFGUARD,
	)

/datum/action/ability/activable/mindfray/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if(!line_of_sight(owner, A, 9))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > MINDFRAY_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/mindfray/use_ability(atom/target)
	var/mob/living/carbon/carbon_target = target
	carbon_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 100)
	carbon_target.apply_status_effect(STATUS_EFFECT_CONFUSED, 40)
	carbon_target.log_message("has been off-guarded by [owner]", LOG_ATTACK, color="pink")
	carbon_target.balloon_alert_to_viewers("confused")
	playsound(carbon_target, 'sound/effects/off_guard_ability.ogg', 50)

	add_cooldown()
