// These may have some say.dm bugs regarding understanding common,
// might be worth adapting the bugs into a feature and using these
// subtypes as a basis for non-common-speaking alien foreigners. ~ Z

/mob/living/carbon/human/species/monkey
	race = "Monkey"
	initial_language_holder = /datum/language_holder/monkey

/mob/living/carbon/human/species/monkey/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/human/monkey) //monkey business

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
	race = "Mothellian"

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

/mob/living/carbon/human/species/zombie/Initialize(mapload, datum/outfit/job/outfit)
	. = ..()
	a_intent = INTENT_HARM
	ASYNC
		if(!outfit)
			outfit = pick(GLOB.survivor_outfits)
		outfit = new outfit()
		var/datum/job/outfit_job = SSjob.type_occupations[outfit.jobtype]
		job = outfit_job
		if(SSticker.mode.zombie_ids)
			outfit.equip(src, FALSE, TRUE)
			outfit.handle_id(src)
			if(wear_id)
				wear_id.access = list()
				wear_id.iff_signal = NONE
		else
			outfit.equip(src, FALSE, FALSE)
			if(wear_id)
				QDEL_NULL(wear_id)
		job = SSjob.type_occupations[/datum/job/zombie]


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

/mob/living/carbon/human/species/prototype_supersoldier
	race = "Prototype Supersoldier"
