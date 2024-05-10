//One off mob spawners
/obj/effect/landmark/mob_spawner
	name = "MOB SPAWNER"
	///The type of mob to spawn
	var/mob/living/mob_spawn
	///Spawn probability
	var/spawn_prob = 100

/obj/effect/landmark/mob_spawner/Initialize(mapload)
	. = ..()
	if(prob(spawn_prob))
		new mob_spawn(loc)
	qdel(src)

/obj/effect/landmark/mob_spawner/monkey
	name = "monkey spawner"
	icon = 'icons/mob/human_races/r_monkey.dmi'
	icon_state = "monke"
	mob_spawn = /mob/living/carbon/human/species/monkey
	spawn_prob = 50

/obj/effect/landmark/mob_spawner/farwa
	name = "farwa spawner"
	icon = 'icons/mob/human_races/r_farwa.dmi'
	icon_state = "monke"
	mob_spawn = /mob/living/carbon/human/species/monkey/farwa
	spawn_prob = 50
