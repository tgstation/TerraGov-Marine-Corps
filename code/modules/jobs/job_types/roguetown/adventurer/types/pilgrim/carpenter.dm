/datum/advclass/carpenter
	name = "Carpenter"
	allowed_sexes = list("male", "female")
	allowed_races = list("Humen",
	"Humen",
	"Dwarf",
	"Dwarf",
	"Half-Elf",
	"Tiefling",
	"Elf",
	"Aasimar"
	)
	outfit = /datum/outfit/job/roguetown/adventurer/carpenter
	isvillager = TRUE
	ispilgrim = TRUE

/datum/outfit/job/roguetown/adventurer/carpenter/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, rand(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, rand(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, rand(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, rand(2,3), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/carpentry, rand(4,5), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/masonry, rand(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/engineering, rand(2,3), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	head = /obj/item/clothing/head/roguetown/hatfur
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/hatblu
	armor = /obj/item/clothing/suit/roguetown/armor/workervest
	pants = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/rogueweapon/hammer/claw
	backl = /obj/item/storage/backpack/rogue/backpack
	H.change_stat("intelligence", 1)
	H.change_stat("constitution", 1)
	H.change_stat("speed", -1)
