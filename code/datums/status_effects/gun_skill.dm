/datum/status_effect/gun_skill
	id = "gun_skill"
	alert_type = null
	///reference to particle effect holder is present for this stack, initially a reference to the type to use
	var/obj/effect/abstract/particle_holder/particles = /particles/gun_skill

/datum/status_effect/gun_skill/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()
	if(!.)
		return
	particles = new(owner, particles)

/datum/status_effect/gun_skill/Destroy()
	if(particles)
		QDEL_NULL(particles)
	return ..()

//Base accuracy effect
/datum/status_effect/gun_skill/accuracy
	///How much the owner's accuracy will be modified by. Positive or negative.
	var/accuracy_modifier = 0

/datum/status_effect/gun_skill/accuracy/on_apply()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.adjust_mob_accuracy(accuracy_modifier)
	return TRUE

/datum/status_effect/gun_skill/accuracy/on_remove()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.adjust_mob_accuracy(-accuracy_modifier)

/datum/status_effect/gun_skill/accuracy/buff
	id = "gun_skill_accuracy_buff"
	accuracy_modifier = 25
	particles = /particles/gun_skill/accuracy/buff

/datum/status_effect/gun_skill/accuracy/debuff
	id = "gun_skill_accuracy_debuff"
	accuracy_modifier = -25
	particles = /particles/gun_skill/accuracy/debuff

//Base scatter effect
/datum/status_effect/gun_skill/scatter
	///How much the owner's scatter will be modified by. Positive or negative.
	var/scatter_modifier = 0

/datum/status_effect/gun_skill/scatter/on_apply()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.adjust_mob_scatter(scatter_modifier)
	return TRUE

/datum/status_effect/gun_skill/scatter/on_remove()
	if(!isliving(owner))
		return FALSE
	var/mob/living/living_owner = owner
	living_owner.adjust_mob_scatter(-scatter_modifier)

/datum/status_effect/gun_skill/scatter/buff
	id = "gun_skill_scatter_buff"
	scatter_modifier = -20
	particles = /particles/gun_skill/scatter/buff

/datum/status_effect/gun_skill/scatter/debuff
	id = "gun_skill_scatter_debuff"
	scatter_modifier = 20
	particles = /particles/gun_skill/scatter/debuff


//particle effects
/particles/gun_skill
	count = 30
	spawning = 3
	gravity = list(0, -0.03)
	icon = 'icons/effects/particles/generic_particles.dmi'
	lifespan = 10
	fade = 8
	color = 1
	color_change = 0.05
	position = generator(GEN_SPHERE, 0, 14, NORMAL_RAND)

/particles/gun_skill/accuracy
	icon_state = list("cross" = 1, "x" = 1)

/particles/gun_skill/accuracy/buff
	gradient = list(1, "#00ff00", 2, "#ff0", "loop")
	count = 10
	spawning = 1

/particles/gun_skill/accuracy/debuff
	gradient = list(1, "#f00", 2, "#ff0", "loop")

/particles/gun_skill/scatter

/particles/gun_skill/scatter/buff
	icon_state = "up_arrow"
	gradient = list(1, "#00ff00", 2, "#ff0", "loop")
	count = 10
	spawning = 1

/particles/gun_skill/scatter/debuff
	icon_state = "down_arrow"
	gradient = list(1, "#f00", 2, "#ff0", "loop")
