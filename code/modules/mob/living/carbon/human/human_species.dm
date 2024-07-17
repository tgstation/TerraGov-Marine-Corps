// These may have some say.dm bugs regarding understanding common,
// might be worth adapting the bugs into a feature and using these
// subtypes as a basis for non-common-speaking alien foreigners. ~ Z

/mob/living/carbon/human/species/monkey
	race = "Monkey"

/mob/living/carbon/human/species/monkey/farwa
	race = "Farwa"

/mob/living/carbon/human/species/monkey/naera
	race = "Naera"

/mob/living/carbon/human/species/monkey/stok
	race = "Stok"

/mob/living/carbon/human/species/monkey/yiren
	race = "Yiren"

/mob/living/carbon/human/species/synthetic
	race = "Synthetic"

/mob/living/carbon/human/species/early_synthetic
	race = "Early Synthetic"

/mob/living/carbon/human/species/moth
	race = "Moth"

/datum/species/moth/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.moth_wings = pick(GLOB.moth_wings_list - "Burnt Off")

/mob/living/carbon/human/species/vatgrown
	race = "Vat-Grown Human"

/mob/living/carbon/human/species/sectoid
	race = "Sectoid"

/mob/living/carbon/human/species/vatborn
	race = "Vatborn"

/mob/living/carbon/human/species/skeleton
	race = "Skeleton"

/mob/living/carbon/human/species/zombie
	race = "Strong zombie"

/mob/living/carbon/human/species/zombie/Initialize(mapload)
	. = ..()
	var/datum/outfit/outfit = pick(GLOB.survivor_outfits)
	outfit = new outfit()
	INVOKE_ASYNC(outfit, TYPE_PROC_REF(/datum/outfit, equip), src)
	a_intent = INTENT_HARM

/mob/living/carbon/human/species/robot
	race = "Combat Robot"
	bubble_icon = "robot"

/mob/living/carbon/human/species/robot/alpharii
	race = "Hammerhead Combat Robot"

/mob/living/carbon/human/species/robot/charlit
	race = "Chilvaris Combat Robot"

/mob/living/carbon/human/species/robot/deltad
	race = "Ratcher Combat Robot"

/mob/living/carbon/human/species/robot/bravada
	race = "Sterling Combat Robot"
