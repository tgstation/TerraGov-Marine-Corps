/**
 * Shell
 */
/atom/movable/screen/alert/status_effect/shell
	name = "Shell Mutation"
	desc = "Your Shell Mutation is taking effect."
	icon_state = "xenobuff_shell"

/datum/status_effect/mutation_shell_upgrade
	id = "mutation_upgrade_shell"
	alert_type = MUTATION_SHELL_ALERT

/**
 * Spur
 */
/atom/movable/screen/alert/status_effect/spur
	name = "Spur Mutation"
	desc = "Your Spur Mutation is taking effect."
	icon_state = "xenobuff_spur"

/datum/status_effect/mutation_spur_upgrade
	id = "mutation_upgrade_spur"
	alert_type = MUTATION_SPUR_ALERT

/datum/status_effect/mutation_runner_frenzy
	id = "mutation_runner_frenzy"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 7 SECONDS
	// How much should melee damage modifier increase by?
	var/damage_modifier = 0

/datum/status_effect/mutation_runner_frenzy/on_creation(mob/living/new_owner, new_damage_modifier)
	owner = new_owner
	damage_modifier = new_damage_modifier
	return ..()

/datum/status_effect/mutation_runner_frenzy/on_apply()
	. = ..()
	if(!isxeno(owner) || !damage_modifier)
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier += damage_modifier
	xeno_owner.add_filter("mutation_runner_frenzy_outline", 3, outline_filter(1, COLOR_VIVID_RED))

/datum/status_effect/mutation_runner_frenzy/on_remove()
	if(!isxeno(owner) || !damage_modifier)
		return
	xeno_owner.xeno_melee_damage_modifier -= damage_modifier
	xeno_owner.remove_filter("mutation_runner_frenzy_outline")

/**
 * Veil
 */
/atom/movable/screen/alert/status_effect/veil
	name = "Veil Mutation"
	desc = "Your Veil Mutation is taking effect."
	icon_state = "xenobuff_veil"

/datum/status_effect/mutation_veil_upgrade
	id = "mutation_upgrade_veil"
	alert_type = MUTATION_VEIL_ALERT
