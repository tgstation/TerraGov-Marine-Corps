#define SPIDER_IDLE 		(1<<0)
#define SPINNING_WEB		(1<<1)
#define LAYING_EGGS 		(1<<2)
#define MOVING_TO_TARGET 	(1<<3)
#define SPINNING_COCOON 	(1<<4)


/mob/living/simple_animal/hostile/poison
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin


/mob/living/simple_animal/hostile/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)


//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "hits"
	maxHealth = 200
	health = 200
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	faction = "Spider"
	var/busy = SPIDER_IDLE
	flags_pass = PASSTABLE
	move_to_delay = 6
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'
	see_in_dark = 4
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	var/playable_spider = FALSE


/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	maxHealth = 40
	health = 40
	melee_damage_lower = 5
	melee_damage_upper = 10
	poison_per_bite = 3
	var/atom/movable/cocoon_target
	var/fed = 0
	var/static/list/consumed_mobs = list() //the tags of mobs that have been consumed by nurse spiders to lay eggs


//hunters have the most poison and move the fastest, so they can find prey
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	poison_per_bite = 5
	move_to_delay = 5


//vipers are the rare variant of the hunter, no IMMEDIATE damage but so much poison medical care will be needed fast.
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper
	name = "viper"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 40
	health = 40
	melee_damage_lower = 1
	melee_damage_upper = 1
	poison_per_bite = 12
	move_to_delay = 4
	poison_type = /datum/reagent/toxin
	speed = 1


//tarantulas are really tanky, regenerating (maybe), hulky monster but are also extremely slow, so.
/mob/living/simple_animal/hostile/poison/giant_spider/tarantula
	name = "tarantula"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	maxHealth = 300 // woah nelly
	health = 300
	melee_damage_lower = 35
	melee_damage_upper = 40
	poison_per_bite = 0
	move_to_delay = 8
	speed = 7
	status_flags = NONE
	mob_size = MOB_SIZE_BIG


//midwives are the queen of the spiders, can send messages to all them and web faster. That rare round where you get a queen spider and turn your 'for honor' players into 'r6siege' players will be a fun one.
/mob/living/simple_animal/hostile/poison/giant_spider/nurse/midwife
	name = "midwife"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes."
	icon_state = "midwife"
	icon_living = "midwife"
	icon_dead = "midwife_dead"
	maxHealth = 40
	health = 40


/mob/living/simple_animal/hostile/poison/giant_spider/ice //spiders dont usually like tempatures of 140 kelvin who knew
	name = "giant ice spider"
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/ice
	name = "giant ice spider"
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114, 228, 250)


/mob/living/simple_animal/hostile/poison/giant_spider/hunter/ice
	name = "giant ice spider"
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)


/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_action()
	. = ..()
	if(!.)
		return FALSE
	if(AIStatus == AI_IDLE)
		//1% chance to skitter madly away
		if(!busy && prob(1))
			stop_automated_movement = TRUE
			Goto(pick(urange(20, src, 1)), move_to_delay)
			spawn(50)
				stop_automated_movement = FALSE
				walk(src, 0)
		return TRUE


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/GiveUp(C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(cocoon_target == C && get_dist(src,cocoon_target) > 1)
				cocoon_target = null
			busy = FALSE
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_action()
	. = ..()
	if(!.)
		busy = SPIDER_IDLE
		stop_automated_movement = FALSE
		return

	var/list/can_see = view(src, 10)
	if(!busy && prob(30))	//30% chance to stop wandering and do something
		for(var/mob/living/C in can_see)
			if(C.stat != CONSCIOUS && !istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && !C.anchored)
				cocoon_target = C
				busy = MOVING_TO_TARGET
				Goto(C, move_to_delay)
				//give up if we can't reach them after 10 seconds
				GiveUp(C)
				return

		for(var/obj/O in can_see)
			if(O.anchored)
				continue

			if(isitem(O) || isstructure(O) || ismachinery(O))
				cocoon_target = O
				busy = MOVING_TO_TARGET
				stop_automated_movement = 1
				Goto(O, move_to_delay)
				//give up if we can't reach them after 10 seconds
				GiveUp(O)

	else if(busy == MOVING_TO_TARGET && cocoon_target)
		if(get_dist(src, cocoon_target) <= 1)
			cocoon()


/mob/living/simple_animal/hostile/poison/giant_spider/nurse/proc/cocoon()
	if(stat != DEAD && cocoon_target && !cocoon_target.anchored)
		if(cocoon_target == src)
			to_chat(src, "<span class='warning'>You can't wrap yourself!</span>")
			return
		if(istype(cocoon_target, /mob/living/simple_animal/hostile/poison/giant_spider))
			to_chat(src, "<span class='warning'>You can't wrap other spiders!</span>")
			return
		if(!Adjacent(cocoon_target))
			to_chat(src, "<span class='warning'>You can't reach [cocoon_target]!</span>")
			return
		if(busy == SPINNING_COCOON)
			to_chat(src, "<span class='warning'>You're already spinning a cocoon!</span>")
			return //we're already doing this, don't cancel out or anything
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>","<span class='notice'>You begin wrapping [cocoon_target] into a cocoon.</span>")
		stop_automated_movement = TRUE
		walk(src, 0)
		if(do_after(src, 50, target = cocoon_target))
			if(busy == SPINNING_COCOON)
				var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
				if(isliving(cocoon_target))
					var/mob/living/L = cocoon_target
					if(L.blood_volume && (L.stat != DEAD || !consumed_mobs[L.tag])) //if they're not dead, you can consume them anyway
						consumed_mobs[L.tag] = TRUE
						fed++
						visible_message("<span class='danger'>[src] sticks a proboscis into [L] and sucks a viscous substance out.</span>","<span class='notice'>You suck the nutriment out of [L], feeding you enough to lay a cluster of eggs.</span>")
						L.death() //you just ate them, they're dead.
					else
						to_chat(src, "<span class='warning'>[L] cannot sate your hunger!</span>")
				cocoon_target.forceMove(C)

				if(cocoon_target.density || ismob(cocoon_target))
					C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	cocoon_target = null
	busy = SPIDER_IDLE
	stop_automated_movement = FALSE


#undef SPIDER_IDLE
#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON