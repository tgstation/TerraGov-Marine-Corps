/mob/living/simple_animal/hostile/hivebot
	name = "hivebot"
	desc = "A small robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "basic"
	icon_living = "basic"
	icon_dead = "basic"
	gender = NEUTER
	health = 15
	maxHealth = 15
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	projectilesound = 'sound/weapons/gunshot.ogg'
	faction = "Hivebot"
	check_friendly_fire = TRUE
	speak_emote = list("states")
	del_on_death = TRUE


/mob/living/simple_animal/hostile/hivebot/Initialize()
	. = ..()
	deathmessage = "[src] blows apart!"


/mob/living/simple_animal/hostile/hivebot/range
	name = "hivebot"
	desc = "A smallish robot, this one is armed!"
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5


/mob/living/simple_animal/hostile/hivebot/rapid
	icon_state = "ranged"
	icon_living = "ranged"
	icon_dead = "ranged"
	ranged = 1
	rapid = 3
	retreat_distance = 5
	minimum_distance = 5


/mob/living/simple_animal/hostile/hivebot/strong
	name = "strong hivebot"
	icon_state = "strong"
	icon_living = "strong"
	icon_dead = "strong"
	desc = "A robot, this one is armed and looks tough!"
	health = 80
	maxHealth = 80
	ranged = 1