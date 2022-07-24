/mob/living/carbon/human/species/zombie/ai/stay
	race = "Zombie"

/mob/living/carbon/human/species/zombie/ai/stay/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie/idle, null)

/mob/living/carbon/human/species/zombie/ai/patrol
	race = "Zombie"

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

/mob/living/carbon/human/species/zombie/ai/patrol/strong
	race = "Strong zombie"

/atom/movable/effect/zombie_basic_pack
	name = "Template for 6 basic zombies, plus a leader"

/atom/movable/effect/zombie_basic_pack/Initialize()
	. = ..()
	var/leader = new /mob/living/carbon/human/species/zombie/ai/patrol(loc)
	for(var/i in 1 to 6)
		new /mob/living/carbon/human/species/zombie/ai/follower(loc, leader)
	qdel(src)
