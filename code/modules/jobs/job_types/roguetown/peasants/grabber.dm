/datum/job/roguetown/grabber
	title = "Grabber"
	flag = GRABBER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0

	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Half-Elf",
	"Dwarf",
	"Dwarf"
	)

	tutorial = "Grabber is the lowest position in the Merchant\'s Guild reserved for the strong, loyal newcomers. They can be like family to the merchant in these foreign lands."

	outfit = /datum/outfit/job/roguetown/grabber
	display_order = JDO_GRABBER

/datum/outfit/job/roguetown/grabber/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
		if(H.gender == MALE)
			H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
		else
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	if(H.gender == MALE)
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
		pants = /obj/item/clothing/under/roguetown/tights/sailor
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		beltr = /obj/item/rogueweapon/mace/woodclub
		beltl = /obj/item/roguekey/shop
		belt = /obj/item/storage/belt/rogue/leather/rope
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
		if(prob(30))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor/red
		if(prob(23))
			armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
		H.change_stat("strength", 2)
		H.change_stat("intelligence", -3)
		H.change_stat("endurance", 3)
		H.change_stat("constitution", 2)
	else
		shoes = /obj/item/clothing/shoes/roguetown/gladiator
		pants = /obj/item/clothing/under/roguetown/tights/sailor
		beltr = /obj/item/rogueweapon/sword/cutlass
		neck = /obj/item/storage/belt/rogue/pouch/coins/poor
		beltl = /obj/item/roguekey/shop
		belt = /obj/item/storage/belt/rogue/leather/rope
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
		if(prob(23))
			armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
		if(prob(77))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor/red
		H.change_stat("strength", 1)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", -3)
		H.change_stat("endurance", 4)
		H.change_stat("speed", 3)
		H.change_stat("constitution", 1)
