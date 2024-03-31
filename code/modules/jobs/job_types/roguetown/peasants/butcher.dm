/datum/job/roguetown/butcher
	title = "Butcher"
	flag = BEASTMASTER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Half-Elf",
	"Dwarf",
	"Tiefling",
	"Aasimar"
	)
	tutorial = "Some say youre a strange individual, some say youre a cheat while some claim you are a savant in the art of sausage making. Without your skilled hands and knifework most of the livestock around the town would be wasted. "

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)

	outfit = /datum/outfit/job/roguetown/beastmaster
	display_order = JDO_BUTCHER
	give_bank_account = TRUE

/datum/outfit/job/roguetown/beastmaster/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/labor/taming, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/tanning, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/labor/butchering, 5, TRUE)
	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/trou
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		belt = /obj/item/storage/belt/rogue/leather
		backl = /obj/item/storage/backpack/rogue/satchel
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	else
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		belt = /obj/item/storage/belt/rogue/leather
		shirt = /obj/item/clothing/suit/roguetown/shirt/dress/gen/random
		backl = /obj/item/storage/backpack/rogue/satchel
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
	if(H.mind)
		H.change_stat("strength", 1)
		H.change_stat("endurance", 1)
		H.change_stat("intelligence", -1)
