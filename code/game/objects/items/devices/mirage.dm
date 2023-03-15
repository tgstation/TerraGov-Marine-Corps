/obj/item/explosive/grenade/mirage
	name = "mirage grenade"
	desc = "A special device that, when activated, produces a pair of holographic copies of the user."
	icon_state = "delivery"
	item_state = "delivery"
	dangerous = FALSE
	///the parent to be copied
	var/mob/living/current_user
	///How long the illusory fakes last
	var/illusion_lifespan = 15 SECONDS

/obj/item/explosive/grenade/mirage/activate(mob/user)
	. = ..()
	current_user = user
	icon_state = "delivery_active"

/obj/item/explosive/grenade/mirage/prime()
	if(current_user)
		var/mob/living/simple_animal/hostile/illusion/M = new(get_turf(src))
		M.copy_appearance(current_user, illusion_lifespan)
		var/mob/living/simple_animal/hostile/illusion/I = new(get_turf(src))
		I.copy_appearance(current_user, illusion_lifespan)
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
	density = FALSE//Its a fake you goof
	var/mob/living/parent
	var/life_span = INFINITY

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

/mob/living/simple_animal/hostile/illusion/proc/copy_appearance(mob/living/parent_mob, lifespan)
	parent = parent_mob
	appearance = parent.appearance
	life_span = world.time+lifespan
	faction = parent_mob.faction
	setDir(parent.dir)
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/on_parent_del)

/mob/living/simple_animal/hostile/illusion/proc/on_parent_del()
	SIGNAL_HANDLER
	parent = null

/mob/living/simple_animal/hostile/illusion/Destroy()
	parent = null
	return ..()
