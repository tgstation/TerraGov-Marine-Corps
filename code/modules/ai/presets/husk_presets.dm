/mob/living/carbon/human/species/husk/ai/stay

/mob/living/carbon/human/species/husk/ai/stay/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/husk, get_turf(src))

/mob/living/carbon/human/species/husk/ai/patrol

/mob/living/carbon/human/species/husk/ai/patrol/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/husk/patrolling , null)

/mob/living/carbon/human/species/husk/ai/follower/Initialize(loc, atom_to_escort)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/husk, atom_to_escort)

/mob/living/carbon/human/species/husk/ai/patrol/fast
	race = "Fast husk"

/mob/living/carbon/human/species/husk/ai/patrol/tank
	race = "Tank husk"

/obj/effect/husk_basic_pack
	name = "Template for 6 basic zombies, plus a leader"

/obj/effect/husk_basic_pack/Initialize()
	. = ..()
	var/leader = new /mob/living/carbon/human/species/husk/ai/patrol(loc)
	for(var/i in 1 to 6)
		new /mob/living/carbon/human/species/husk/ai/follower(loc, leader)
	qdel(src)
