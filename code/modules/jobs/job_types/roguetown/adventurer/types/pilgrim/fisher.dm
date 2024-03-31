/datum/advclass/fisher
	name = "Fisher"
	allowed_sexes = list("male", "female")
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Elf",
	"Dark Elf",
	"Half-Elf",
	"Dwarf",
	"Dwarf",
	"Aasimar"
	)
	outfit = /datum/outfit/job/roguetown/adventurer/fisher
	isvillager = TRUE
	ispilgrim = TRUE

/datum/outfit/job/roguetown/adventurer/fisher/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights/random
		shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/random
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		head = /obj/item/clothing/head/roguetown/fisherhat
		armor = /obj/item/clothing/suit/roguetown/armor/workervest
		backr = /obj/item/storage/backpack/rogue/satchel
		belt = /obj/item/storage/belt/rogue/leather/rope
		backl = /obj/item/fishingrod
		beltr = /obj/item/cooking/pan
		beltl = /obj/item/rogueweapon/huntingknife
		backpack_contents = list(/obj/item/natural/worms = 2,/obj/item/rogueweapon/shovel/small=1)
		if(H.mind)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/crafting, pick(1,2), TRUE)
			H.mind.adjust_skillrank(/datum/skill/labor/fishing, pick(4,5), TRUE)
			if(H.age == AGE_OLD)
				H.mind.adjust_skillrank(/datum/skill/labor/fishing, 1, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.change_stat("constitution", 2)
	else
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/random
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		neck = /obj/item/storage/belt/rogue/pouch
		head = /obj/item/clothing/head/roguetown/fisherhat
		backr = /obj/item/storage/backpack/rogue/satchel
		belt = /obj/item/storage/belt/rogue/leather/rope
		beltr = /obj/item/fishingrod
		beltl = /obj/item/rogueweapon/huntingknife
		backpack_contents = list(/obj/item/natural/worms = 2,/obj/item/rogueweapon/shovel/small=1)
		if(H.mind)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/crafting, pick(1,2), TRUE)
			H.mind.adjust_skillrank(/datum/skill/labor/fishing, pick(4,5), TRUE)
			if(H.age == AGE_OLD)
				H.mind.adjust_skillrank(/datum/skill/labor/fishing, 2, TRUE)
				H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.change_stat("constitution", 1)
