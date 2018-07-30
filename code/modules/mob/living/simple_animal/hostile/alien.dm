/mob/living/simple_animal/hostile/alien
	name = "alien hunter"
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Hunter Running"
	icon_living = "Hunter Running"
	icon_dead = "Hunter Dead"
	icon_gib = "syndicate_gib"
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = -1
	meat_type = /obj/item/reagent_container/food/snacks/xenomeat
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	a_intent = "harm"
	attack_sound = 'sound/weapons/alien_claw_flesh1.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "alien"
	wall_smash = 1
	status_flags = CANPUSH
	minbodytemp = 0
	heat_damage_per_tick = 20
	stop_automated_movement_when_pulled = 1
	break_stuff_probability = 90

/mob/living/simple_animal/hostile/alien/drone
	name = "alien drone"
	icon_state = "Drone Running"
	icon_living = "Drone Running"
	icon_dead = "Drone Dead"
	health = 60
	melee_damage_lower = 15
	melee_damage_upper = 15

// Still using old projectile code - commenting this out for now
// /mob/living/simple_animal/hostile/alien/sentinel
// 	name = "alien sentinel"
// 	icon_state = "Sentinel Running"
// 	icon_living = "Sentinel Running"
// 	icon_dead = "Sentinel Dead"
// 	health = 120
// 	melee_damage_lower = 15
// 	melee_damage_upper = 15
// 	ranged = 1
// 	projectiletype = /obj/item/projectile/neurotox
// 	projectilesound = 'sound/weapons/pierce.ogg'

/mob/living/simple_animal/hostile/alien/ravager
	name = "alien ravager"
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Running"
	icon_living = "Ravager Running"
	icon_dead = "Ravager Dead"
	melee_damage_lower = 25
	melee_damage_upper = 35
	maxHealth = 200
	health = 200

/obj/item/projectile/neurotox
	damage = 30
	icon_state = "toxin"

/mob/living/simple_animal/hostile/alien/death(gibbed, deathmessage = "lets out a waning guttural screech, green blood bubbling from its maw.")
	. = ..()
	if(!.) return //If they were already dead, it will return.
	playsound(src, 'sound/voice/alien_death.ogg', 50, 1)
