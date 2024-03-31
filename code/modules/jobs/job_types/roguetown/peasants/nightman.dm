/datum/job/roguetown/nightman
	title = "Nightmaster"
	flag = JESTER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0

	allowed_sexes = list("male")
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Elf",
	"Half-Elf"
	)

	tutorial = "The Nightmaster is technically a noble. Owner of the Whitevein Lounge, a decaying bathhouse converted into a den of low-lifes. A troublemaking rake that the others hate to tolerate."

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	outfit = /datum/outfit/job/roguetown/nightman
	display_order = JDO_NIGHTMAN
	give_bank_account = TRUE

/datum/outfit/job/roguetown/nightman/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	pants = /obj/item/clothing/under/roguetown/trou/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor/nightman
	beltr = /obj/item/keyring/nightman
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger = 1)
	ADD_TRAIT(H, RTRAIT_GOODLOVER, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("intelligence", -1)
	if(H.dna?.species)
		if(H.dna.species.id == "human")
			H.dna.species.soundpack_m = new /datum/voicepack/male/zeth()
		if(H.dna.species.id == "elf")
			armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
		if(H.dna.species.id == "dwarf")
			armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
