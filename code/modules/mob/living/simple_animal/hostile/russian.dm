/mob/living/simple_animal/hostile/russian
	name = "Russian"
	desc = "For the Motherland!"
	icon_state = "russianmelee"
	icon_living = "russianmelee"
	icon_dead = "russianmelee_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 4
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "punches"
	a_intent = "harm"
	var/corpse = /obj/effect/landmark/corpsespawner/russian
	var/weapon1 = /obj/item/tool/kitchen/knife
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "russian"
	status_flags = CANPUSH


/mob/living/simple_animal/hostile/russian/ranged
	icon_state = "russianranged"
	icon_living = "russianranged"
	corpse = /obj/effect/landmark/corpsespawner/russian/ranged
	weapon1 = /obj/item/weapon/gun/pistol
	ranged = 1
	projectiletype = /obj/item/projectile
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = null


/mob/living/simple_animal/hostile/UPP
	name = "UPP Soldier"
	desc = "A soldier in the service of the UPP Navy."
	icon_state = "uppmarine"
	icon_living = "uppmarine"
	icon_dead = "uppmarinedead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 4
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "punches"
	a_intent = "harm"
	//var/corpse = /obj/effect/landmark/corpsespawner/russian
	//var/weapon1 = /obj/item/tool/kitchen/knife
	min_oxy = 5
	max_oxy = 0
	min_tox = 0
	max_tox = 1
	min_co2 = 0
	max_co2 = 5
	min_n2 = 0
	max_n2 = 0
	unsuitable_atoms_damage = 15
	faction = "russian"
	status_flags = CANPUSH


/mob/living/simple_animal/hostile/UPP/ranged
	//weapon1 = /obj/item/weapon/gun/projectile/mateba
	ranged = 1
	projectiletype = /obj/item/projectile
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = null


/mob/living/simple_animal/hostile/russian/death()
	..()
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	cdel(src)
	return
/*
/mob/living/simple_animal/hostile/russian/UPP
	name = "UPP Soldier"
	icon_state = "uppmarine"
	icon_living = "uppmarine"
	icon_dead = "uppmarinedead"
*/