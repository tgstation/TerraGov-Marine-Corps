/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	robust_searching = TRUE
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HARM
	check_friendly_fire = TRUE
	status_flags = CANPUSH
	del_on_death = TRUE
	dodging = TRUE
	rapid_melee = 2


/mob/living/simple_animal/hostile/syndicate/space
	icon_state = "syndicate_space"
	icon_living = "syndicate_space"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	speed = 1


/mob/living/simple_animal/hostile/syndicate/space/Initialize()
	. = ..()
	SetLuminosity(4)


/mob/living/simple_animal/hostile/syndicate/space/stormtrooper
	icon_state = "syndicate_stormtrooper"
	icon_living = "syndicate_stormtrooper"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250


/mob/living/simple_animal/hostile/syndicate/melee //dude with a knife and no shields
	melee_damage_lower = 15
	melee_damage_upper = 15
	icon_state = "syndicate_knife"
	icon_living = "syndicate_knife"
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	status_flags = NONE
	var/projectile_deflect_chance = 0


/mob/living/simple_animal/hostile/syndicate/melee/space
	icon_state = "syndicate_space_knife"
	icon_living = "syndicate_space_knife"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	speed = 1
	projectile_deflect_chance = 50


/mob/living/simple_animal/hostile/syndicate/melee/space/Initialize()
	. = ..()
	SetLuminosity(4)


/mob/living/simple_animal/hostile/syndicate/melee/space/stormtrooper
	icon_state = "syndicate_stormtrooper_knife"
	icon_living = "syndicate_stormtrooper_knife"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 50


/mob/living/simple_animal/hostile/syndicate/melee/sword
	melee_damage_lower = 30
	melee_damage_upper = 30
	icon_state = "syndicate_sword"
	icon_living = "syndicate_sword"
	attacktext = "slashes"
	attack_sound = 'sound/weapons/blade1.ogg'
	armour_penetration = 35
	status_flags = 0
	projectile_deflect_chance = 50


/mob/living/simple_animal/hostile/syndicate/melee/sword/Initialize()
	. = ..()
	SetLuminosity(2)


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(obj/item/projectile/Proj)
	if(prob(projectile_deflect_chance))
		visible_message("<span class='danger'>[src] blocks [Proj] with its shield!</span>")
		return FALSE
	return ..()


/mob/living/simple_animal/hostile/syndicate/melee/sword/space
	icon_state = "syndicate_space_sword"
	icon_living = "syndicate_space_sword"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	speed = 1
	projectile_deflect_chance = 50


/mob/living/simple_animal/hostile/syndicate/melee/sword/space/stormtrooper
	icon_state = "syndicate_stormtrooper_sword"
	icon_living = "syndicate_stormtrooper_sword"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250
	projectile_deflect_chance = 50


/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicate_pistol"
	icon_living = "syndicate_pistol"
	projectilesound = 'sound/weapons/gunshot.ogg'
	dodging = FALSE
	rapid_melee = TRUE


/mob/living/simple_animal/hostile/syndicate/ranged/infiltrator
	projectilesound = 'sound/weapons/gun_silenced_shot1.ogg'


/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicate_space_pistol"
	icon_living = "syndicate_space_pistol"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	speed = 1


/mob/living/simple_animal/hostile/syndicate/ranged/space/Initialize()
	. = ..()
	SetLuminosity(4)


/mob/living/simple_animal/hostile/syndicate/ranged/space/stormtrooper
	icon_state = "syndicate_stormtrooper_pistol"
	icon_living = "syndicate_stormtrooper_pistol"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250


/mob/living/simple_animal/hostile/syndicate/ranged/smg
	rapid = 2
	icon_state = "syndicate_smg"
	icon_living = "syndicate_smg"
	projectilesound = 'sound/weapons/gun_smg.ogg'


/mob/living/simple_animal/hostile/syndicate/ranged/smg/pilot
	name = "Syndicate Salvage Pilot"


/mob/living/simple_animal/hostile/syndicate/ranged/smg/space
	icon_state = "syndicate_space_smg"
	icon_living = "syndicate_space_smg"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	speed = 1


/mob/living/simple_animal/hostile/syndicate/ranged/smg/space/Initialize()
	. = ..()
	SetLuminosity(4)


/mob/living/simple_animal/hostile/syndicate/ranged/smg/space/stormtrooper
	icon_state = "syndicate_stormtrooper_smg"
	icon_living = "syndicate_stormtrooper_smg"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250


/mob/living/simple_animal/hostile/syndicate/ranged/shotgun
	rapid = 2
	rapid_fire_delay = 6
	minimum_distance = 3
	icon_state = "syndicate_shotgun"
	icon_living = "syndicate_shotgun"
	casingtype = /obj/item/ammo_casing/shell


/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space
	icon_state = "syndicate_space_shotgun"
	icon_living = "syndicate_space_shotgun"
	name = "Syndicate Commando"
	maxHealth = 170
	health = 170
	speed = 1


/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/Initialize()
	. = ..()
	SetLuminosity(4)


/mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/stormtrooper
	icon_state = "syndicate_stormtrooper_shotgun"
	icon_living = "syndicate_stormtrooper_shotgun"
	name = "Syndicate Stormtrooper"
	maxHealth = 250
	health = 250


/mob/living/simple_animal/hostile/syndicate/civilian
	minimum_distance = 10
	retreat_distance = 10
	obj_damage = 0


/mob/living/simple_animal/hostile/syndicate/civilian/Aggro()
	. = ..()
	summon_backup(15)
	say("GUARDS!!")