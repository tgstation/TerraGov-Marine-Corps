
/mob/living/simple_animal/hostile/retaliate/rogue/cow
	icon = 'icons/roguetown/mob/monster/cow.dmi'
	name = "cow"
	desc = ""
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	emote_hear = list("brays.")
	emote_see = list("shakes its head.", "chews her cud.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	move_to_delay = 8
	animal_species = /mob/living/simple_animal/hostile/retaliate/rogue/bull
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 6,
						/obj/item/natural/hide=2)
	base_intents = list(/datum/intent/simple/headbutt)
	health = 80
	maxHealth = 80
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/wheat,/obj/item/reagent_containers/food/snacks/grown/oat)
	tame_chance = 25
	bonus_tame_chance = 15
	footstep_type = FOOTSTEP_MOB_SHOE
	pooptype = /obj/item/natural/poo/cow
	milkies = TRUE
	faction = list("cows")
	attack_verb_continuous = "headbutts"
	attack_verb_simple = "headbutt"
	melee_damage_lower = 10
	melee_damage_upper = 25
	STASPD = 2
	STACON = 20
	STASTR = 12
	childtype = list(/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet = 95, /mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet = 5)
	remains_type = /obj/effect/decal/remains/cow

/obj/effect/decal/remains/cow
	name = "remains"
	gender = PLURAL
	icon_state = "skele"
	icon = 'icons/roguetown/mob/monster/cow.dmi'

/mob/living/simple_animal/hostile/retaliate/rogue/cow/get_sound(input)
	switch(input)
		if("aggro")
			return pick('sound/vo/mobs/cow/aggro (1).ogg','sound/vo/mobs/cow/aggro (2).ogg','sound/vo/mobs/cow/aggro (3).ogg')
		if("pain")
			return pick('sound/vo/mobs/cow/pain (1).ogg','sound/vo/mobs/cow/pain (2).ogg')
		if("death")
			return pick('sound/vo/mobs/cow/death (1).ogg','sound/vo/mobs/cow/death (2).ogg')
		if("idle")
			return pick('sound/vo/mobs/cow/idle (1).ogg','sound/vo/mobs/cow/idle (2).ogg','sound/vo/mobs/cow/idle (3).ogg','sound/vo/mobs/cow/idle (4).ogg','sound/vo/mobs/cow/idle (5).ogg')


/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet
	name = "calf"
	desc = ""
	icon_state = "cowlet"
	icon_living = "cowlet"
	icon_dead = "cowlet_dead"
	icon_gib = "cowlet_gib"
	animal_species = null
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 1)
	base_intents = list(/datum/intent/simple/headbutt)
	health = 20
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	maxHealth = 20
	milkies = FALSE
	melee_damage_lower = 1
	melee_damage_upper = 6
	STACON = 5
	STASTR = 5
	STASPD = 5
	defprob = 50
	adult_growth = /mob/living/simple_animal/hostile/retaliate/rogue/cow

/mob/living/simple_animal/hostile/retaliate/rogue/cow/cowlet/get_emote_frequency()
	return 55100

/mob/living/simple_animal/hostile/retaliate/rogue/cow/simple_limb_hit(zone)
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

/mob/living/simple_animal/hostile/retaliate/rogue/cow/attack_hand(mob/living/carbon/M)
	if(!stat && M.used_intent.type == INTENT_DISARM && icon_state != icon_dead && !has_buckled_mobs())
		M.visible_message("<span class='warning'>[M] tips over [src].</span>",
			"<span class='notice'>I tip over [src].</span>")
		to_chat(src, "<span class='danger'>I am tipped over by [M]!</span>")
		Paralyze(60, ignore_canstun = TRUE)
		icon_state = "[initial(icon_state)]_tip"
		spawn(60)
			if(!stat && M)
				icon_state = icon_living
	else
		..()

/mob/living/simple_animal/hostile/retaliate/rogue/bull
	icon = 'icons/roguetown/mob/monster/cow.dmi'
	name = "cow"
	icon_state = "bull"
	icon_living = "bull"
	icon_dead = "bull_dead"
	icon_gib = "bull_gib"
	gender = MALE
	emote_hear = list("chews.")
	emote_see = list("shakes his head.", "chews his cud.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	move_to_delay = 8
	base_intents = list(/datum/intent/simple/headbutt)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/rogue/meat/steak = 6)
	faction = list("cows")
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	attack_same = 0
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
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/wheat,/obj/item/reagent_containers/food/snacks/grown/oat)
	footstep_type = FOOTSTEP_MOB_SHOE
	pooptype = /obj/item/natural/poo/cow
	STACON = 20
	STASTR = 12
	STASPD = 2
	remains_type = /obj/effect/decal/remains/cow

/mob/living/simple_animal/hostile/retaliate/rogue/bull/get_sound(input)
	switch(input)
		if("aggro")
			return pick('sound/vo/mobs/cow/aggro (1).ogg','sound/vo/mobs/cow/aggro (2).ogg','sound/vo/mobs/cow/aggro (3).ogg')
		if("pain")
			return pick('sound/vo/mobs/cow/pain (1).ogg','sound/vo/mobs/cow/pain (2).ogg')
		if("death")
			return pick('sound/vo/mobs/cow/death (1).ogg','sound/vo/mobs/cow/death (2).ogg')
		if("idle")
			return pick('sound/vo/mobs/cow/idle (1).ogg','sound/vo/mobs/cow/idle (2).ogg','sound/vo/mobs/cow/idle (3).ogg','sound/vo/mobs/cow/idle (4).ogg','sound/vo/mobs/cow/idle (5).ogg')

/mob/living/simple_animal/hostile/retaliate/rogue/bull/taunted(mob/user)
	emote("aggro")
	Retaliate()
	GiveTarget(user)
	return

/mob/living/simple_animal/hostile/retaliate/bull/simple_limb_hit(zone)
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

/mob/living/simple_animal/hostile/retaliate/bull/taunted(mob/user)
	Retaliate()
	GiveTarget(user)
	return

/mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet
	name = "calf"
	desc = ""
	gender = MALE
	icon_state = "bullet"
	icon_living = "bullet"
	icon_dead = "bullet_dead"
	icon_gib = "bullet_gib"
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
	adult_growth = /mob/living/simple_animal/hostile/retaliate/rogue/bull

/mob/living/simple_animal/hostile/retaliate/rogue/cow/bullet/get_emote_frequency()
	return 55100
