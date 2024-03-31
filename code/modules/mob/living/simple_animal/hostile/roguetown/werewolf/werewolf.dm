
/mob/living/simple_animal/hostile/rogue/werewolf
	name = "WEREWOLF"
	desc = ""
	icon = 'icons/roguetown/mob/monster/werewolf.dmi'
	icon_state = "wwolf_m"
	icon_living = "wwolf_m"
	icon_dead = "wwolf_m"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	speak_chance = 80
	maxHealth = 220
	health = 220
	melee_damage_lower = 15
	melee_damage_upper = 18
	STASTR = 20
	STAEND = 20
	STASPD = 20
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = BLADEWOOSH_LARGE
	dextrous = TRUE
	held_items = list(null, null)
//	base_intents = list(INTENT_HELP, INTENT_GRAB, /datum/intent/simple/claw/wwolf)
	faction = list("wolves")
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	footstep_type = FOOTSTEP_MOB_HEAVY

/mob/living/simple_animal/hostile/rogue/werewolf/Initialize()
	..()
	regenerate_icons()
	ADD_TRAIT(src, TRAIT_SIMPLE_WOUNDS, TRAIT_GENERIC)