//
// Abstract Class
//

/mob/living/simple_animal/hostile/mimic
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "crate"
	icon_living = "crate"

	meat_type = /obj/item/reagent_container/food/snacks/carpmeat
	response_help = "touches the"
	response_disarm = "pushes the"
	response_harm = "hits the"
	speed = 4
	maxHealth = 250
	health = 250

	harm_intent_damage = 5
	melee_damage_lower = 8
	melee_damage_upper = 12
	attacktext = "attacks"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "mimic"
	move_to_delay = 8

/mob/living/simple_animal/hostile/mimic/FindTarget()
	. = ..()
	if(.)
		emote("growls at [.]")

/mob/living/simple_animal/hostile/mimic/death()
	..()
	cdel(src)

//
// Crate Mimic
//


//Aggro when you try to open them, or when taking damage. Will also pickup loot when spawns and drop it when dies.
/mob/living/simple_animal/hostile/mimic/crate
	attacktext = "bites"
	stop_automated_movement = 1
	wander = 0
	var/attempt_open = 0
/*
	New()
		set waitfor = 0
		..()
		sleep(10) //Make sure everything is spawned in.
		for(var/obj/item/I in loc)
			I.loc = src
	*/

	initialize()
		..()
		for(var/obj/item/I in loc)
			I.loc = src

	attack_hand()
		trigger()
		..()

	FindTarget()
		if(attempt_open) . = ..()

	DestroySurroundings()
		..()
		icon_state = prob(90)? "[initial(icon_state)]open" : initial(icon_state)

	AttackingTarget()
		. = ..()
		if(.) icon_state = initial(icon_state)

	adjustBruteLoss(damage)
		trigger()
		..(damage)

	LoseTarget()
		..()
		icon_state = initial(icon_state)

	LostTarget()
		..()
		icon_state = initial(icon_state)

	death()
		var/obj/structure/closet/crate/C = new(get_turf(src)) //Spawns a crate on death to put loot into.
		for(var/obj/O in src)
			O.loc = C
		..()

	AttackingTarget()
		var/mob/living/L = ..()
		if(istype(L))
			if(prob(15))
				L.KnockDown(2)
				L.visible_message("<span class='danger'>[src] knocks down [L]!</span>")

/mob/living/simple_animal/hostile/mimic/crate/proc/trigger()
	if(!attempt_open)
		visible_message("<span class='warning'>\icon[src] [src] starts to move!</span>")
		attempt_open = 1

//
// Copy Mimic
//

var/global/list/protected_objects = list(/obj/structure/table, /obj/structure/cable, /obj/structure/window, /obj/item/projectile)

/mob/living/simple_animal/hostile/mimic/copy

	health = 100
	maxHealth = 100
	var/mob/living/creator = null // the creator
	var/destroy_objects = 0
	var/knockdown_people = 0

/mob/living/simple_animal/hostile/mimic/copy/New(loc, var/obj/copy, var/mob/living/creator)
	..(loc)
	CopyObject(copy, creator)

/mob/living/simple_animal/hostile/mimic/copy/death()

	for(var/atom/movable/M in src)
		M.loc = get_turf(src)
	..()

/mob/living/simple_animal/hostile/mimic/copy/ListTargets()
	// Return a list of targets that isn't the creator
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/mimic/copy/proc/CopyObject(var/obj/O, var/mob/living/creator)

	if((istype(O, /obj/item) || istype(O, /obj/structure)) && !is_type_in_list(O, protected_objects))

		O.loc = src
		name = O.name
		desc = O.desc
		icon = O.icon
		icon_state = O.icon_state
		icon_living = icon_state

		if(istype(O, /obj/structure))
			health = (anchored * 50) + 50
			destroy_objects = 1
			if(O.density && O.anchored)
				knockdown_people = 1
				melee_damage_lower *= 2
				melee_damage_upper *= 2
		else if(istype(O, /obj/item))
			var/obj/item/I = O
			health = 15 * I.w_class
			melee_damage_lower = 2 + I.force
			melee_damage_upper = 2 + I.force
			move_to_delay = 2 * I.w_class

		maxHealth = health
		if(creator)
			src.creator = creator
			faction = "\ref[creator]" // very unique
		return 1
	return

/mob/living/simple_animal/hostile/mimic/copy/DestroySurroundings()
	if(destroy_objects)
		..()

/mob/living/simple_animal/hostile/mimic/copy/AttackingTarget()
	. =..()
	if(knockdown_people)
		var/mob/living/L = .
		if(istype(L))
			if(prob(15))
				L.KnockDown(1)
				L.visible_message("<span class='danger'>\the [src] knocks down \the [L]!</span>")