//Colonial Marines Modified Larva - Apophis - 27FEB2015

/mob/living/carbon/alien/Larva
	name = "Alien Larva"
	real_name = "Alien Larva"
	adult_form = /mob/living/carbon/human
	speak_emote = list("hisses")
	icon = 'icons/xeno/Colonial_Aliens1x1.dmi'
//	caste = "Bloody Larva"
	icon_state = "Bloody Larva"
	language = "Hivemind"
	melee_damage_lower = 3
	melee_damage_upper = 6
	amount_grown = 0
	max_grown = 200
	maxHealth = 25
	health = 25


/mob/living/carbon/alien/larva/New()
	..()
	add_language("Xenomorph") //Bonus language.
	internal_organs += new /datum/organ/internal/xenos/hivenode(src)
