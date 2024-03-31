
/mob/living/simple_animal/hostile/retaliate/rogue/chicken
	name = "\improper chicken"
	desc = ""
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = FALSE
	base_intents = list(/datum/intent/simple/claw)
	speak_chance = 2
	turns_per_move = 5
	faction = list("chickens")
	butcher_results = list(/obj/item/reagent_containers/food/snacks/fat = 1, /obj/item/reagent_containers/food/snacks/rogue/meat/poultry = 1)
	var/egg_type = /obj/item/reagent_containers/food/snacks/egg
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/berries/rogue,/obj/item/natural/worms,/obj/item/reagent_containers/food/snacks/grown/wheat,/obj/item/reagent_containers/food/snacks/grown/oat)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	melee_damage_lower = 1
	melee_damage_upper = 8
	pooptype = /obj/item/natural/poo/horse
	health = 15
	maxHealth = 15
	ventcrawler = VENTCRAWLER_ALWAYS
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/list/layMessage = EGG_LAYING_MESSAGES
	var/list/validColors = list("brown","black","white")
	var/static/chicken_count = 0
	footstep_type = FOOTSTEP_MOB_BAREFOOT
	STACON = 6
	STASTR = 6
	STASPD = 1
	tame = TRUE

/mob/living/simple_animal/hostile/retaliate/rogue/chicken/get_sound(input)
	switch(input)
		if("pain")
			return pick('sound/vo/mobs/chikn/pain (1).ogg','sound/vo/mobs/chikn/pain (2).ogg','sound/vo/mobs/chikn/pain (3).ogg')
		if("death")
			return 'sound/vo/mobs/chikn/death.ogg'
		if("idle")
			return pick('sound/vo/mobs/chikn/idle (1).ogg','sound/vo/mobs/chikn/idle (2).ogg','sound/vo/mobs/chikn/idle (3).ogg','sound/vo/mobs/chikn/idle (4).ogg','sound/vo/mobs/chikn/idle (5).ogg','sound/vo/mobs/chikn/idle (6).ogg')


/mob/living/simple_animal/hostile/retaliate/rogue/chicken/simple_limb_hit(zone)
	if(!zone)
		return ""
	switch(zone)
		if(BODY_ZONE_PRECISE_R_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_L_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_NOSE)
			return "beak"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "beak"
		if(BODY_ZONE_PRECISE_HAIR)
			return "head"
		if(BODY_ZONE_PRECISE_EARS)
			return "head"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "wing"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "wing"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "leg"
		if(BODY_ZONE_HEAD)
			return "head"
		if(BODY_ZONE_R_LEG)
			return "leg"
		if(BODY_ZONE_L_LEG)
			return "leg"
		if(BODY_ZONE_R_ARM)
			return "wing"
		if(BODY_ZONE_L_ARM)
			return "wing"
	return ..()

/mob/living/simple_animal/hostile/retaliate/rogue/chicken/Initialize()
	. = ..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	++chicken_count

/mob/living/simple_animal/hostile/retaliate/rogue/chicken/Destroy()
	--chicken_count
	return ..()

/mob/living/simple_animal/hostile/retaliate/rogue/chicken/Life()
	..()
	if(!stat && (production > 29) && egg_type && isturf(loc) && !enemies.len)
		testing("laying egg with [production] production")
		if(locate(/obj/structure/fluff/nest) in loc)
			visible_message("<span class='alertalien'>[src] [pick(layMessage)]</span>")
			production = max(production - 30, 0)
			var/obj/item/reagent_containers/food/snacks/egg/E = new egg_type(get_turf(src))
			E.pixel_x = rand(-6,6)
			E.pixel_y = rand(-6,6)
			if(eggsFertile)
				if(chicken_count < MAX_CHICKENS && prob(50))
					E.fertile = TRUE
		else if(!stop_automated_movement)
			//look for nests
			var/list/foundnests = list()
			for(var/obj/structure/fluff/nest/N in oview(src))
				foundnests += N
			//if no nests, look for chaff and build one
			if(!foundnests.len)
				//look for chaff in our loc first, build nest
				var/obj/item/CH = locate(/obj/item/natural/fibers) in loc
				if(CH)
					qdel(CH)
					new /obj/structure/fluff/nest(loc)
					visible_message("<span class='notice'>[src] builds a nest.</span>")
				else
					CH = locate(/obj/item/grown/log/tree/stick) in loc
					if(CH)
						qdel(CH)
						new /obj/structure/fluff/nest(loc)
						visible_message("<span class='notice'>[src] builds a nest.</span>")
				//if cant find, look for chaff in view and move to it
				var/list/foundchaff = list()
				for(var/obj/item/natural/fibers/C in oview(src))
					foundchaff += C
				if(!foundchaff.len)
					for(var/obj/item/grown/log/tree/stick/S in oview(src))
						foundchaff += S
				if(foundchaff.len)
					stop_automated_movement = TRUE
					Goto(pick(foundchaff),move_to_delay)
					addtimer(CALLBACK(src, .proc/return_action), 15 SECONDS)
			else
				stop_automated_movement = TRUE
				Goto(pick(foundnests),move_to_delay)
				addtimer(CALLBACK(src, .proc/return_action), 15 SECONDS)


/obj/structure/fluff/nest
	name = "nest"
	desc = ""
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "nest"
	density = FALSE
	anchored = TRUE
	can_buckle = 1
	layer = 2.8
	max_integrity = 40
	static_debris = list(/obj/item/natural/fibers = 1)
