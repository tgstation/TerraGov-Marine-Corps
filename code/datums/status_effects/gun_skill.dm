/datum/status_effect/gun_skill
	id = "gun_skill"

//Base accuracy effect
/datum/status_effect/gun_skill/accuracy
	var/accuracy_modifier = 0

/datum/status_effect/gun_skill/accuracy/on_apply()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.ranged_accuracy_mod += accuracy_modifier
	return TRUE

/datum/status_effect/gun_skill/accuracy/on_remove()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.ranged_accuracy_mod -= accuracy_modifier

/datum/status_effect/gun_skill/accuracy/buff
	id = "gun_skill_accuracy_buff"
	accuracy_modifier = 25

/datum/status_effect/gun_skill/accuracy/debuff
	id = "gun_skill_accuracy_debuff"
	accuracy_modifier = -25

//Base scatter effect
/datum/status_effect/gun_skill/scatter
	var/scatter_modifier = 0

/datum/status_effect/gun_skill/scatter/on_apply()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.ranged_scatter_mod += scatter_modifier
	return TRUE

/datum/status_effect/gun_skill/scatter/on_remove()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.ranged_scatter_mod -= scatter_modifier

/datum/status_effect/gun_skill/scatter/buff
	id = "gun_skill_scatter_buff"
	scatter_modifier = 20

/datum/status_effect/gun_skill/scatter/debuff
	id = "gun_skill_scatter_debuff"
	scatter_modifier = -20
