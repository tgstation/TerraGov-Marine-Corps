/mob/living/carbon/human/species/zombie/ai/stay

/mob/living/carbon/human/species/zombie/ai/stay/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie, get_turf(src))

/mob/living/carbon/human/species/zombie/ai/patrol

/mob/living/carbon/human/species/zombie/ai/patrol/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie/patrolling , null)

/mob/living/carbon/human/species/zombie/ai/follower/Initialize(loc, atom_to_escort)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie, atom_to_escort)

/mob/living/carbon/human/species/zombie/ai/patrol/fast
	race = "Fast zombie"

/mob/living/carbon/human/species/zombie/ai/patrol/tank
	race = "Tank zombie"

/obj/effect/zombie_basic_pack
	name = "Template for 6 basic zombies, plus a leader"

/obj/effect/zombie_basic_pack/Initialize()
	. = ..()
	var/leader = new /mob/living/carbon/human/species/zombie/ai/patrol(loc)
	for(var/i in 1 to 6)
		new /mob/living/carbon/human/species/zombie/ai/follower(loc, leader)
	qdel(src)
