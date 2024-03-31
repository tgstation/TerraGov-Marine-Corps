/datum/job/roguetown/merchant
	title = "Merchant"
	flag = MERCHANT
	department_flag = SERFS
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dwarf",
	"Tiefling",
	"Aasimar"
	)
	tutorial = "You were born into wealth, learning from before you could talk about the basics of mathematics. Counting coins is a simple pleasure for any person, but youve made it an artform. These people are addicted to your wares and you are the literal beating heart of this economy: Dont let these filthy-covered troglodytes ever forget that."

	display_order = JDO_MERCHANT

	outfit = /datum/outfit/job/roguetown/merchant
	bypass_lastclass = TRUE
	give_bank_account = 22

/datum/outfit/job/roguetown/merchant/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 6, TRUE)
		H.mind.adjust_skillrank(/datum/skill/labor/mathematics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
	ADD_TRAIT(H, RTRAIT_SEEPRICES, type)
	if(H.gender == MALE)
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
		belt = /obj/item/storage/belt/rogue/leather/rope
		beltl = /obj/item/keyring/merchant
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
		pants = /obj/item/clothing/under/roguetown/tights/sailor
		neck = /obj/item/clothing/neck/roguetown/horus
		armor = /obj/item/clothing/suit/roguetown/shirt/robe/merchant
		head = /obj/item/clothing/head/roguetown/chaperon
		id = /obj/item/clothing/ring/gold
		H.change_stat("intelligence", 2)
		H.change_stat("perception", 1)
		H.change_stat("strength", -2)
		if(H.dna?.species)
			if(H.dna.species.id == "human")
				H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	else
		shoes = /obj/item/clothing/shoes/roguetown/gladiator
		beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
		belt = /obj/item/storage/belt/rogue/leather/rope
		beltl = /obj/item/roguekey/merchant
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
		neck = /obj/item/clothing/neck/roguetown/horus
		armor = /obj/item/clothing/suit/roguetown/shirt/robe/merchant
		pants = /obj/item/clothing/under/roguetown/tights/sailor
		head = /obj/item/clothing/head/roguetown/chaperon
		id = /obj/item/clothing/ring/gold
		H.change_stat("intelligence", 2)
		H.change_stat("perception", 1)
		H.change_stat("strength", -2)
	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)
