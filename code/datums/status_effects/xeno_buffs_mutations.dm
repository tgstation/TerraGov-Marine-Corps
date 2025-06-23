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

/**
 * Buffs
 */

/datum/status_effect/xenomorph_damage_modifier
	id = "xenomorph_damage_modifier"
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	duration = 7 SECONDS
	// How much should the xenomorph owner's melee_damage_modifier be increased by?
	var/damage_modifier = 0

/datum/status_effect/xenomorph_damage_modifier/on_creation(mob/living/new_owner, new_damage_modifier)
	owner = new_owner
	damage_modifier = new_damage_modifier
	return ..()

/datum/status_effect/xenomorph_damage_modifier/on_apply()
	. = ..()
	if(!isxeno(owner) || !damage_modifier)
		return FALSE
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier += damage_modifier
	xeno_owner.add_filter("[id]_outline", 3, outline_filter(1, COLOR_VIVID_RED))

/datum/status_effect/xenomorph_damage_modifier/on_remove()
	if(!isxeno(owner) || !damage_modifier)
		return
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.xeno_melee_damage_modifier -= damage_modifier
	xeno_owner.remove_filter("[id]_outline")

/datum/status_effect/xenomorph_damage_modifier/mutation_runner_frenzy
	id = "mutation_runner_frenzy"

/datum/status_effect/xenomorph_damage_modifier/mutation_drone_revenge
	id = "mutation_drone_revenge"
	duration = 10 SECONDS

/datum/status_effect/xenomorph_damage_modifier/mutation_drone_revenge/on_apply()
	. = ..()
	if(!.)
		return
	owner.emote("roar2")

/datum/status_effect/xenomorph_movespeed_modifier
	id = "xenomorph_movespeed_modifier"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 4 SECONDS
	var/movespeed_id = MOVESPEED_ID_XENOMORPH_MOVESPEED_MODIFIER
	// The amount used for the movespeed modifier.
	var/movespeed_modifier

/datum/status_effect/xenomorph_movespeed_modifier/on_creation(mob/living/new_owner, new_movespeed_modifier)
	owner = new_owner
	movespeed_modifier = new_movespeed_modifier
	return ..()

/datum/status_effect/xenomorph_movespeed_modifier/on_apply()
	. = ..()
	if(!isxeno(owner) || !movespeed_modifier)
		return FALSE
	owner.add_movespeed_modifier(movespeed_id, TRUE, 0, NONE, TRUE, movespeed_modifier)

/datum/status_effect/xenomorph_movespeed_modifier/on_remove()
	if(!isxeno(owner) || !movespeed_modifier)
		return
	owner.remove_movespeed_modifier(movespeed_id)

/datum/status_effect/xenomorph_movespeed_modifier/queen_screech
	id = "queen_screech_movespeed_modifier"
	movespeed_id = MOVESPEED_ID_QUEEN_SCREECH

/**
 * Debuffs
 */

/atom/movable/screen/alert/status_effect/draining_dread
	name = "Draining Dread"
	desc = "A dreadful presence. You take constant stamina damage until this expires."
	icon_state = "dread"

/datum/status_effect/draining_dread
	id = "draining_dread"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /atom/movable/screen/alert/status_effect/draining_dread
	var/stamina_damage = 0

/datum/status_effect/draining_dread/on_creation(mob/living/new_owner, set_stamina_damage)
	owner = new_owner
	if(set_stamina_damage)
		stamina_damage = set_stamina_damage
	return ..()

/datum/status_effect/draining_dread/on_apply()
	. = ..()
	if(!stamina_damage)
		return FALSE

/datum/status_effect/draining_dread/tick(delta_time)
	. = ..()
	var/mob/living/living_owner = owner
	living_owner.do_jitter_animation(250, 1, 3)
	living_owner.adjustStaminaLoss(stamina_damage)
