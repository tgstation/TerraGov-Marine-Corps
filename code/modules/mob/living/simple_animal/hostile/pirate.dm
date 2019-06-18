/mob/living/simple_animal/hostile/pirate
	name = "Pirate"
	desc = "Does what he wants cause a pirate is free."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "pirate_dead"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pushes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	speak_emote = list("yarrs")
	del_on_death = TRUE
	faction = "Pirate"


/mob/living/simple_animal/hostile/pirate/melee
	name = "Pirate Swashbuckler"
	icon_state = "piratemelee"
	icon_living = "piratemelee"
	icon_dead = "piratemelee_dead"
	melee_damage_lower = 30
	melee_damage_upper = 30
	armour_penetration = 35
	attacktext = "slashes"
	attack_sound = 'sound/weapons/blade1.ogg'

 
/mob/living/simple_animal/hostile/pirate/melee/space
	name = "Space Pirate Swashbuckler"
	icon_state = "piratespace"
	icon_living = "piratespace"
	icon_dead = "piratespace_dead"
	speed = 1


/mob/living/simple_animal/hostile/pirate/melee/Initialize()
	. = ..()
	SetLuminosity(2)


/mob/living/simple_animal/hostile/pirate/ranged
	name = "Pirate Gunner"
	icon_state = "pirateranged"
	icon_living = "pirateranged"
	icon_dead = "pirateranged_dead"
	projectilesound = 'sound/weapons/laser.ogg'
	ranged = 1
	rapid = 2
	rapid_fire_delay = 6
	retreat_distance = 5
	minimum_distance = 5


/mob/living/simple_animal/hostile/pirate/ranged/space
	name = "Space Pirate Gunner"
	icon_state = "piratespaceranged"
	icon_living = "piratespaceranged"
	icon_dead = "piratespaceranged_dead"
	speed = 1