/mob/living/simple_animal/hostile/retaliate/rogue/goat/Initialize()
	..()
	GLOB.farm_animals++
	if(tame)
		tamed()

/mob/living/simple_animal/hostile/retaliate/rogue/goat/Destroy()
	..()
	GLOB.farm_animals = max(GLOB.farm_animals - 1, 0)

/mob/living/simple_animal/hostile/retaliate/rogue/goat/find_food()
	..()
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		food = max(food + 30, 100)

/mob/living/simple_animal/hostile/retaliate/rogue/goat/tamed()
	..()
	deaggroprob = 50
	if(can_buckle)
		var/datum/component/riding/D = LoadComponent(/datum/component/riding)
		D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-2, 6), TEXT_WEST = list(2, 6)))
		D.set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
		D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
		D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
		D.set_vehicle_dir_layer(WEST, OBJ_LAYER)


/mob/living/simple_animal/hostile/retaliate/rogue/goat/update_icon()
	cut_overlays()
	..()
	if(stat != DEAD)
		if(ssaddle)
			var/mutable_appearance/saddlet = mutable_appearance(icon, "saddle-f-above", 4.3)
			add_overlay(saddlet)
			saddlet = mutable_appearance(icon, "saddle-f")
			add_overlay(saddlet)
		if(has_buckled_mobs())
			var/mutable_appearance/mounted = mutable_appearance(icon, "goat_mounted", 4.3)
			add_overlay(mounted)



/mob/living/simple_animal/hostile/retaliate/rogue/goat/Life()
	..()
	if(stat == CONSCIOUS)
		if(!pulledby)
			for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
				var/step = get_step(src, direction)
				if(step)
					if(locate(/obj/structure/spacevine) in step || locate(/obj/structure/glowshroom) in step)
						Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/rogue/goat
	icon = 'icons/roguetown/mob/monster/gote.dmi'
	name = "goat"
	desc = ""
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	icon_gib = "goat_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	emote_see = list("shakes her head.", "chews her cud.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	move_to_delay = 8
	animal_species = /mob/living/simple_animal/hostile/retaliate/rogue/goatmale
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4,
						/obj/item/reagent_containers/food/snacks/fat = 2,
						/obj/item/natural/hide = 2,
						/obj/item/natural/fur = 1)
	base_intents = list(/datum/intent/simple/headbutt)
	health = 80
	maxHealth = 80
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/wheat,/obj/item/reagent_containers/food/snacks/grown/oat,/obj/item/reagent_containers/food/snacks/grown/apple)
	tame_chance = 25
	bonus_tame_chance = 15
	footstep_type = FOOTSTEP_MOB_SHOE
	pooptype = /obj/item/natural/poo/horse
	milkies = TRUE
	faction = list("goats")
	attack_verb_continuous = "headbutts"
	attack_verb_simple = "headbutt"
	melee_damage_lower = 10
	melee_damage_upper = 25
	STASPD = 2
	STACON = 8
	STASTR = 12
	childtype = list(/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatlet = 90, /mob/living/simple_animal/hostile/retaliate/rogue/goat/goatletboy = 10)
	can_buckle = TRUE
	buckle_lying = 0
	can_saddle = FALSE
	remains_type = /obj/effect/decal/remains/cow

/mob/living/simple_animal/hostile/retaliate/rogue/goat/get_sound(input)
	switch(input)
		if("aggro")
			return pick('sound/vo/mobs/goat/aggro (1).ogg','sound/vo/mobs/goat/aggro (2).ogg')
		if("pain")
			return pick('sound/vo/mobs/goat/pain (1).ogg','sound/vo/mobs/goat/pain (2).ogg')
		if("death")
			return pick('sound/vo/mobs/goat/death (1).ogg','sound/vo/mobs/goat/death (2).ogg')
		if("idle")
			return pick('sound/vo/mobs/goat/idle (1).ogg','sound/vo/mobs/goat/idle (2).ogg','sound/vo/mobs/goat/idle (3).ogg')


/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatlet
	icon = 'icons/roguetown/mob/monster/gote.dmi'
	name = "goatlet"
	desc = ""
	icon_state = "goatlet"
	icon_living = "goatlet"
	icon_dead = "goatlet_dead"
	icon_gib = "goatlet_gib"
	animal_species = null
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1)
	base_intents = list(/datum/intent/simple/headbutt)
	health = 20
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	maxHealth = 20
	milkies = FALSE
	gender = FEMALE
	melee_damage_lower = 1
	melee_damage_upper = 6
	STACON = 5
	STASTR = 5
	STASPD = 5
	defprob = 50
	adult_growth = /mob/living/simple_animal/hostile/retaliate/rogue/goat
	can_buckle = FALSE
	buckle_lying = 0
	can_saddle = FALSE

/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatlet/get_emote_frequency()
	return 55100

/mob/living/simple_animal/hostile/retaliate/rogue/goat/simple_limb_hit(zone)
	if(!zone)
		return ""
	switch(zone)
		if(BODY_ZONE_PRECISE_R_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_L_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_NOSE)
			return "snout"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "snout"
		if(BODY_ZONE_PRECISE_HAIR)
			return "head"
		if(BODY_ZONE_PRECISE_EARS)
			return "head"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "foreleg"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "foreleg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "stomach"
		if(BODY_ZONE_HEAD)
			return "head"
		if(BODY_ZONE_R_LEG)
			return "leg"
		if(BODY_ZONE_L_LEG)
			return "leg"
		if(BODY_ZONE_R_ARM)
			return "foreleg"
		if(BODY_ZONE_L_ARM)
			return "foreleg"

	return ..()

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale
	icon = 'icons/roguetown/mob/monster/gote.dmi'
	name = "goat"
	icon_state = "goatmale"
	icon_living = "goatmale"
	icon_dead = "goatmale_dead"
	icon_gib = "goatmale_gib"
	gender = MALE
	emote_see = list("shakes his head.", "chews his cud.")
	speak_chance = 1
	turns_per_move = 3
	see_in_dark = 6
	move_to_delay = 8
	base_intents = list(/datum/intent/simple/headbutt)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 4,
						/obj/item/reagent_containers/food/snacks/fat = 1,
						/obj/item/natural/hide = 2,
						/obj/item/natural/fur = 1)
	faction = list("goats")
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	attack_verb_continuous = "headbutts"
	attack_verb_simple = "headbutt"
	health = 150
	maxHealth = 150
	melee_damage_lower = 25
	melee_damage_upper = 50
	environment_smash = ENVIRONMENT_SMASH_NONE
	retreat_distance = 0
	minimum_distance = 0
	milkies = FALSE
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/wheat,/obj/item/reagent_containers/food/snacks/grown/oat,/obj/item/reagent_containers/food/snacks/grown/apple)
	footstep_type = FOOTSTEP_MOB_SHOE
	pooptype = /obj/item/natural/poo/horse
	STACON = 7
	STASTR = 12
	STASPD = 2
	can_buckle = TRUE
	buckle_lying = 0
	can_saddle = FALSE
	tame_chance = 25
	bonus_tame_chance = 15
	remains_type = /obj/effect/decal/remains/cow

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/update_icon()
	cut_overlays()
	..()
	if(stat != DEAD)
		if(ssaddle)
			var/mutable_appearance/saddlet = mutable_appearance(icon, "saddle-above", 4.3)
			add_overlay(saddlet)
			saddlet = mutable_appearance(icon, "saddle")
			add_overlay(saddlet)
		if(has_buckled_mobs())
			var/mutable_appearance/mounted = mutable_appearance(icon, "goatmale_mounted", 4.3)
			add_overlay(mounted)

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/tamed()
	..()
	deaggroprob = 20
	if(can_buckle)
		var/datum/component/riding/D = LoadComponent(/datum/component/riding)
		D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 6), TEXT_SOUTH = list(0, 6), TEXT_EAST = list(-2, 6), TEXT_WEST = list(2, 6)))
		D.set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
		D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
		D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
		D.set_vehicle_dir_layer(WEST, OBJ_LAYER)

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/Initialize()
	..()
	GLOB.farm_animals++
	if(tame)
		tamed()

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/Destroy()
	..()
	GLOB.farm_animals = max(GLOB.farm_animals - 1, 0)

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/get_sound(input)
	switch(input)
		if("aggro")
			return pick('sound/vo/mobs/goat/aggro (1).ogg','sound/vo/mobs/goat/aggro (2).ogg')
		if("pain")
			return pick('sound/vo/mobs/goat/pain (1).ogg','sound/vo/mobs/goat/pain (2).ogg')
		if("death")
			return pick('sound/vo/mobs/goat/death (1).ogg','sound/vo/mobs/goat/death (2).ogg')
		if("idle")
			return pick('sound/vo/mobs/goat/idle (1).ogg','sound/vo/mobs/goat/idle (2).ogg','sound/vo/mobs/goat/idle (3).ogg')

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/taunted(mob/user)
	emote("aggro")
	Retaliate()
	GiveTarget(user)
	return

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/eat_plants()
	..()
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		food = max(food + 30, 100)

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/Life()
	..()
	if(stat == CONSCIOUS)
		if(!pulledby)
			for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
				var/step = get_step(src, direction)
				if(step)
					if(locate(/obj/structure/spacevine) in step || locate(/obj/structure/glowshroom) in step)
						Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/rogue/goatmale/simple_limb_hit(zone)
	if(!zone)
		return ""
	switch(zone)
		if(BODY_ZONE_PRECISE_R_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_L_EYE)
			return "head"
		if(BODY_ZONE_PRECISE_NOSE)
			return "snout"
		if(BODY_ZONE_PRECISE_MOUTH)
			return "snout"
		if(BODY_ZONE_PRECISE_HAIR)
			return "head"
		if(BODY_ZONE_PRECISE_EARS)
			return "head"
		if(BODY_ZONE_PRECISE_NECK)
			return "neck"
		if(BODY_ZONE_PRECISE_L_HAND)
			return "foreleg"
		if(BODY_ZONE_PRECISE_R_HAND)
			return "foreleg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_R_FOOT)
			return "leg"
		if(BODY_ZONE_PRECISE_STOMACH)
			return "stomach"
		if(BODY_ZONE_HEAD)
			return "head"
		if(BODY_ZONE_R_LEG)
			return "leg"
		if(BODY_ZONE_L_LEG)
			return "leg"
		if(BODY_ZONE_R_ARM)
			return "foreleg"
		if(BODY_ZONE_L_ARM)
			return "foreleg"
	return ..()


/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatletboy
	icon = 'icons/roguetown/mob/monster/gote.dmi'
	name = "goatlet"
	desc = ""
	gender = MALE
	icon_state = "goatletboy"
	icon_living = "goatletboy"
	icon_dead = "goatletboy_dead"
	icon_gib = "goatletboyt_gib"
	animal_species = null
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1)
	base_intents = list(/datum/intent/simple/headbutt)
	health = 20
	maxHealth = 20
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	milkies = FALSE
	melee_damage_lower = 1
	melee_damage_upper = 6
	STACON = 5
	STASTR = 5
	STASPD = 5
	adult_growth = /mob/living/simple_animal/hostile/retaliate/rogue/goatmale
	can_buckle = FALSE
	buckle_lying = 0
	can_saddle = FALSE

/mob/living/simple_animal/hostile/retaliate/rogue/goat/goatletboy/get_emote_frequency()
	return 55100
