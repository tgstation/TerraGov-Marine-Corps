/mob/living/simple_animal/hostile/alien
	name = "alien hunter"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Hunter Running"
	icon_living = "Hunter Running"
	icon_dead = "Hunter Dead"
	icon_gib = "syndicate_gib"
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	a_intent = INTENT_HARM
	attack_sound = 'sound/weapons/alien_claw_flesh1.ogg'
	faction = "alien"
	stop_automated_movement_when_pulled = TRUE


/mob/living/simple_animal/hostile/alien/drone
	name = "alien drone"
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Drone Running"
	icon_living = "Drone Running"
	icon_dead = "Drone Dead"
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15


/mob/living/simple_animal/hostile/alien/ravager
	name = "alien ravager"
	icon_state = "Ravager Running"
	icon_living = "Ravager Running"
	icon_dead = "Ravager Dead"
	melee_damage_lower = 25
	melee_damage_upper = 35
	maxHealth = 200
	health = 200


/mob/living/simple_animal/hostile/alien/death(gibbed, deathmessage = "lets out a waning guttural screech, green blood bubbling from its maw.")
	. = ..()
	if(!.) 
		return
	playsound(src, 'sound/voice/alien_death.ogg', 50, 1)
