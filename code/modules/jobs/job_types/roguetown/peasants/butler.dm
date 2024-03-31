/datum/job/roguetown/butler
	title = "Butler"
	flag = BUTLER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 2
	spawn_positions = 3

	f_title = "Maid"
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dwarf",
	"Dwarf",
	"Aasimar",
	"Half-Elf"
	)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)

	tutorial = "Servitude unto death, your blade a charcuterie of artisanal cheeses and meat, your armor wit and classical training. You dont consider yourself a slave, if anything youre a part of the family now. You alone have raised Kings, Queens, Princesses and Princees; without you the royals would have all starved to death."

	outfit = /datum/outfit/job/roguetown/butler
	display_order = JDO_BUTLER
	give_bank_account = 5

/datum/outfit/job/roguetown/butler/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 3, TRUE)

	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
		shoes = /obj/item/clothing/shoes/roguetown/shortboots
		belt = /obj/item/storage/belt/rogue/leather
		beltr = /obj/item/keyring/servant
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/black
		H.change_stat("strength", -1)
		H.change_stat("intelligence", 1)
		H.change_stat("perception", 1)
	else
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen
		shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
		cloak = /obj/item/clothing/cloak/apron/waist
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		beltr = /obj/item/keyring/servant
		H.change_stat("strength", -1)
		H.change_stat("intelligence", 1)
		H.change_stat("perception", 1)

