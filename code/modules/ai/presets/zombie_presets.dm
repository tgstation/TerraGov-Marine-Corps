/mob/living/carbon/human/species/zombie/ai
	race = "Zombie"
	/// If set
	var/ai_type

/mob/living/carbon/human/species/zombie/ai/Initialize(mapload, atom_to_escort)
	. = ..()
	if(ai_type)
		AddComponent(/datum/component/ai_controller, ai_type, atom_to_escort)

/mob/living/carbon/human/species/zombie/ai/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

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

/mob/living/carbon/human/species/zombie/ai/hunter
	race = "Hunter zombie"

/mob/living/carbon/human/species/zombie/ai/hunter/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/hunter/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/mob/living/carbon/human/species/zombie/ai/boomer
	race = "Boomer zombie"

/mob/living/carbon/human/species/zombie/ai/boomer/stay
	ai_type = /datum/ai_behavior/xeno/zombie/idle

/mob/living/carbon/human/species/zombie/ai/boomer/patrol
	ai_type = /datum/ai_behavior/xeno/zombie/patrolling

/obj/effect/zombie_pack
	name = "spawns a pack of zombies, plus a leader"
	///Leader zombie typepath
	var/leader_type = /mob/living/carbon/human/species/zombie/ai/patrol
	///Minion zombie typepath
	var/minion_type = /mob/living/carbon/human/species/zombie/ai/patrol
	///Number of minion zombies
	var/minion_number = 6

/obj/effect/zombie_pack/Initialize(mapload)
	. = ..()
	var/leader = new leader_type(loc)
	for(var/i in 1 to minion_number)
		new minion_type(loc, leader)
	qdel(src)

/obj/effect/zombie_pack/tank
	leader_type = /mob/living/carbon/human/species/zombie/ai/tank/patrol

/obj/effect/zombie_pack/smoker
	leader_type = /mob/living/carbon/human/species/zombie/ai/smoker/patrol

/obj/effect/zombie_pack/hunter
	leader_type = /mob/living/carbon/human/species/zombie/ai/hunter/patrol

/obj/effect/zombie_pack/boomer
	leader_type = /mob/living/carbon/human/species/zombie/ai/boomer/patrol

/obj/effect/zombie_pack/fast_pack
	leader_type = /mob/living/carbon/human/species/zombie/ai/fast/patrol
	minion_type = /mob/living/carbon/human/species/zombie/ai/fast/patrol
