/datum/advclass/dbomb
	name = "Dwarf"
	tutorial = "Dwarves like to blow things up."
	allowed_sexes = list("male", "female")
	allowed_races = list("Dwarf","Dwarf")
	outfit = /datum/outfit/job/roguetown/adventurer/dbomb

/datum/outfit/job/roguetown/adventurer/dbomb/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/armingcap/dwarf
	if(prob(30))
		head = /obj/item/clothing/head/roguetown/helmet/horned
	pants = /obj/item/clothing/under/roguetown/trou
	shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
	belt = /obj/item/storage/belt/rogue/leather
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backl = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(/obj/item/bomb = 1, /obj/item/flint = 1)
	if(prob(50))
		beltl = /obj/item/rogueweapon/pick
	else
		beltl = /obj/item/rogueweapon/hammer
	if(prob(50))
		shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("endurance", 1)
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)