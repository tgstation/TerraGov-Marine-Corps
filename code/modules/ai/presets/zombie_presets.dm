/mob/living/carbon/human/species/zombie/ai
	race = "Zombie"
	/// If set
	var/ai_type

/mob/living/carbon/human/species/zombie/ai/Initialize(mapload)
	. = ..()
	if(ai_type)
		AddComponent(/datum/component/ai_controller, ai_type, null)

/mob/living/carbon/human/species/zombie/ai/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/mob/living/carbon/human/species/zombie/ai/follower/Initialize(mapload, atom_to_escort)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/xeno/zombie, atom_to_escort)

/mob/living/carbon/human/species/zombie/ai/fast
	race = "Fast zombie"

/mob/living/carbon/human/species/zombie/ai/fast/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/fast/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/mob/living/carbon/human/species/zombie/ai/tank
	race = "Tank zombie"

/mob/living/carbon/human/species/zombie/ai/tank/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/tank/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/mob/living/carbon/human/species/zombie/ai/strong
	race = "Strong zombie"

/mob/living/carbon/human/species/zombie/ai/strong/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/strong/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/mob/living/carbon/human/species/zombie/ai/smoker
	race = "Smoker zombie"

/mob/living/carbon/human/species/zombie/ai/smoker/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/smoker/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/obj/effect/zombie_basic_pack
	name = "Template for 6 basic zombies, plus a leader"

/obj/effect/zombie_basic_pack/Initialize(mapload)
	. = ..()
	var/leader = new /mob/living/carbon/human/species/zombie/ai/patrol(loc)
	for(var/i in 1 to 6)
		new /mob/living/carbon/human/species/zombie/ai/follower(loc, leader)
	qdel(src)
