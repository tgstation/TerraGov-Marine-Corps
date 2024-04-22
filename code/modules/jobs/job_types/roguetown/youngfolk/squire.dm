/datum/job/roguetown/squire
	title = "Squire"
	flag = SQUIRE
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_races = list("Humen",
	"Humen",
	"Half-Elf")
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_YOUNG)

	tutorial = "Mom 'n' Da said you were going to be something, they had better aspirations for you than the life of a peasant. You practiced the basics in the field alongside your friends, swordfighting with sticks, chasing rabbits with grain flail, and helping around the house lifting heavy bags of grain. The Knight took notice of your potential and brought you on as his personal ward. You're going to be something someday. "

	outfit = /datum/outfit/job/roguetown/squire
	display_order = JDO_SQUIRE
	give_bank_account = TRUE

/datum/outfit/job/roguetown/squire/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
		armor = /obj/item/clothing/suit/roguetown/armor/chainmail
		shoes = /obj/item/clothing/shoes/roguetown/boots
		belt = /obj/item/storage/belt/rogue/leather
		beltr = /obj/item/storage/belt/rogue/pouch
		backr = /obj/item/storage/backpack/rogue/satchel
		if(H.mind)
			H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.change_stat("strength", 1)
			H.change_stat("perception", 1)
			H.change_stat("constitution", 1)
			H.change_stat("speed", 1)
	if(H.gender == FEMALE)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
		armor = /obj/item/clothing/suit/roguetown/armor/chainmail
		shoes = /obj/item/clothing/shoes/roguetown/boots
		belt = /obj/item/storage/belt/rogue/leather
		beltr = /obj/item/storage/belt/rogue/pouch
		backr = /obj/item/storage/backpack/rogue/satchel
		if(H.mind)
			H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.change_stat("strength", 1)
			H.change_stat("perception", 1)
			H.change_stat("constitution", 1)
			H.change_stat("speed", 1)
