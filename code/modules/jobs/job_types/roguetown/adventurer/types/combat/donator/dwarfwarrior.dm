
/datum/advclass/dwarfwarrior
	name = "Dwarf Warrior"
	tutorial = "Dwarf Warriors are the bread and butter of their miliary sworn to defend their mountain fortress. Armed with either a battle axe or mace, they are a force to be reckoned with."
	allowed_sexes = list("male", "female")
	allowed_races = list("Dwarf","Dwarf")
	outfit = /datum/outfit/job/roguetown/adventurer/dwarfwarrior
	maxchosen = 2

/datum/outfit/job/roguetown/adventurer/dwarfwarrior/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/winged
	pants = /obj/item/clothing/under/roguetown/trou
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backr = /obj/item/rogueweapon/shield/wood
	if(prob(25))
		mask = /obj/item/clothing/mask/rogue/facemask
	if(prob(25))
		gloves = /obj/item/clothing/gloves/roguetown/chain
	else
		gloves = /obj/item/clothing/gloves/roguetown/angle
	if(prob(50))
		beltl = /obj/item/rogueweapon/mace/steel
	else
		beltl = /obj/item/rogueweapon/stoneaxe/battle

	H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.change_stat("constitution", 2)
	H.change_stat("speed", -1)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 2)
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)