/datum/status_effect/stacking/gun_skill
	id = "gun_skill"
	tick_interval = 2 SECONDS
	delay_before_decay = 5 SECONDS
	stack_threshold = 100
	max_stacks = 100
	///reference to particle effect holder is present for this stack, initially a reference to the type to use
	var/obj/effect/abstract/particle_holder/particles = /particles/gun_skill

/datum/status_effect/stacking/gun_skill/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(!.)
		return
	particles = new(owner, particles)

/datum/status_effect/stacking/gun_skill/add_stacks(stacks_added)
	. = ..()
	if(!.)
		return
	particles.particles.spawning = stacks

/datum/status_effect/stacking/gun_skill/Destroy()
	if(particles)
		QDEL_NULL(particles)
	return ..()


/datum/status_effect/stacking/gun_skill/accuracy/buff
	id = "gun_skill_accuracy_buff"
	particles = /particles/gun_skill/accuracy/buff

/datum/status_effect/stacking/gun_skill/accuracy/debuff
	id = "gun_skill_accuracy_debuff"
	particles = /particles/gun_skill/accuracy/debuff

/datum/status_effect/stacking/gun_skill/scatter/buff
	id = "gun_skill_scatter_buff"
	particles = /particles/gun_skill/scatter/buff

/datum/status_effect/stacking/gun_skill/scatter/debuff
	id = "gun_skill_scatter_debuff"
	particles = /particles/gun_skill/scatter/debuff

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

/particles/gun_skill/accuracy/debuff
	gradient = list(1, "#f00", 2, "#ff0", "loop")

/particles/gun_skill/scatter

/particles/gun_skill/scatter/buff
	icon_state = "up_arrow"
	gradient = list(1, "#00ff00", 2, "#ff0", "loop")

/particles/gun_skill/scatter/debuff
	icon_state = "down_arrow"
	gradient = list(1, "#f00", 2, "#ff0", "loop")
