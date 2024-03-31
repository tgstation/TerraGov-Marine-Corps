
/obj/item/bait
	name = "bag of bait"
	desc = ""
	icon_state = "bait"
	icon = 'icons/roguetown/items/misc.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/check_counter = 0
	var/list/attracted_types = list(/mob/living/simple_animal/hostile/retaliate/rogue/bigrat = 10,
										/mob/living/simple_animal/hostile/retaliate/rogue/goat = 33,
									/mob/living/simple_animal/hostile/retaliate/rogue/goatmale = 33,
									/mob/living/simple_animal/hostile/retaliate/rogue/chicken = 55)
	var/attraction_chance = 100
	var/deployed = 0
	resistance_flags = FLAMMABLE

/obj/item/bait/Initialize()
	. = ..()
	check_counter = world.time

/obj/item/bait/attack_self(mob/user)
	. = ..()
	user.visible_message("<span class='notice'>[user] begins deploying the bait...</span>", \
						"<span class='notice'>I begin deploying the bait...</span>")
	if(do_after(user, 100, target = src)) //rogtodo hunting skill
		user.dropItemToGround(src)
		START_PROCESSING(SSobj, src)
		name = "bait"
		icon_state = "[icon_state]1"
		deployed = 1

/obj/item/bait/attack_hand(mob/user)
	if(deployed)
		user.visible_message("<span class='notice'>[user] begins gathering up the bait...</span>", \
							"<span class='notice'>I begin gathering up the bait...</span>")
		if(do_after(user, 100, target = src)) //rogtodo hunting skill
			STOP_PROCESSING(SSobj, src)
			name = initial(name)
			deployed = 0
			icon_state = initial(icon_state)
			..()
	else
		..()

/obj/item/bait/process()
	if(deployed)
		if(world.time > check_counter + 10 SECONDS)
			check_counter = world.time
			var/area/A = get_area(src)
			if(A.outdoors)
				var/list/possible_targets = list()
				for(var/obj/item/bait/B in range(7, src))
					if(B == src)
						continue
					if(can_see(src, B, 7))
						possible_targets += B
				if(possible_targets.len)
					return
				possible_targets = list()
				for(var/obj/structure/flora/roguetree/RT in range(7, src))
					if(can_see(src, RT, 7))
						possible_targets += RT
				for(var/obj/structure/flora/roguegrass/bush/RT in range(7, src))
					if(can_see(src, RT, 7))
						possible_targets += RT
				if(!possible_targets.len)
					return
				var/cume = 0
				for(var/mob/living/carbon/human/L in viewers(src, 7))
					if(L.stat == CONSCIOUS)
						cume++
				if(!cume)
					if(prob(attraction_chance))
//						var/turf/T = get_turf(pick(possible_targets))
						var/turf/T = get_turf(src)
						if(T)
							var/mob/M = pickweight(attracted_types)
							new M(T)
							qdel(src)
					else
						qdel(src)
	..()

/obj/item/bait/sweet
	name = "bag of sweetbait"
	icon_state = "baitp"
	attracted_types = list(/mob/living/simple_animal/hostile/retaliate/rogue/goat = 33,
							/mob/living/simple_animal/hostile/retaliate/rogue/goatmale = 33,
							/mob/living/simple_animal/hostile/retaliate/rogue/saiga = 20,
							/mob/living/simple_animal/hostile/retaliate/rogue/saigabuck = 20,
							/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 20)


/obj/item/bait/bloody
	name = "bag of bloodbait"
	icon_state = "baitb"
	attracted_types = list(/mob/living/simple_animal/hostile/retaliate/rogue/wolf = 20,
						/mob/living/simple_animal/hostile/retaliate/rogue/bigrat = 10)