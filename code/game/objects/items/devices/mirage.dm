/obj/item/explosive/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a pair of holographic copies of the user."
	icon_state = "delivery"
	worn_icon_state = "delivery"
	dangerous = FALSE
	///the parent to be copied
	var/mob/living/current_user
	///How long the illusory fakes last
	var/illusion_lifespan = 15 SECONDS
	///Number of illusions we make
	var/mirage_quantity = 2

/obj/item/explosive/grenade/mirage/activate(mob/user)
	. = ..()
	current_user = user
	icon_state = "delivery_active"

/obj/item/explosive/grenade/mirage/prime()
	if(current_user)
		for(var/i = 1 to mirage_quantity)
			var/mob/living/simple_animal/hostile/illusion/illusion = new(get_turf(src))
			illusion.copy_appearance(current_user, illusion_lifespan)
	qdel(src)

/obj/item/explosive/grenade/mirage/Destroy()
	current_user = null
	return ..()

/mob/living/simple_animal/hostile/illusion
	name = "illusion"
	desc = "It's a fake!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "null"
	del_on_death = TRUE
	deathmessage = "vanishes into thin air!"
	friendly = "attacks"
	status_flags = GODMODE
	wall_smash = FALSE
	density = FALSE
	///The mob we are copying the appearance of
	var/mob/living/parent
	///World time when the illusion will end
	var/life_span = INFINITY
	///Timer to remove the hit effect
	var/timer_effect

/mob/living/simple_animal/hostile/illusion/Destroy()
	parent = null
	deltimer(timer_effect)
	return ..()

/mob/living/simple_animal/hostile/illusion/Life()
	. = ..()
	if(parent)
		appearance = parent.appearance
	if(world.time > life_span)
		death()

/mob/living/simple_animal/hostile/illusion/examine(mob/user)
	if(parent)
		return parent.examine(user)
	return ..()

/mob/living/simple_animal/hostile/illusion/projectile_hit()
	remove_filter(ILLUSION_HIT_FILTER)
	deltimer(timer_effect)
	add_filter(ILLUSION_HIT_FILTER, 2, wave_filter(20, 5))
	animate(get_filter(ILLUSION_HIT_FILTER), x = 0, y = 0, time = 0.5 SECONDS, easing = CIRCULAR_EASING|EASE_OUT)
	timer_effect = addtimer(CALLBACK(src, PROC_REF(remove_hit_filter)), 0.5 SECONDS, TIMER_STOPPABLE)
	return FALSE

///Sets the illusion to a specified mob
/mob/living/simple_animal/hostile/illusion/proc/copy_appearance(mob/living/parent_mob, lifespan)
	parent = parent_mob
	appearance = parent.appearance
	life_span = world.time+lifespan
	faction = parent_mob.faction
	setDir(parent.dir)
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_del))

///Clears parent if parent is deleted
/mob/living/simple_animal/hostile/illusion/proc/on_parent_del()
	SIGNAL_HANDLER
	parent = null

/// Remove the filter effect added when it was hit
/mob/living/simple_animal/hostile/illusion/proc/remove_hit_filter()
	remove_filter(ILLUSION_HIT_FILTER)
