//terrify mobs scream
/datum/advclass/barbarian
	name = "Barbarian"
	tutorial = "Barbarians are humen men who live in the outskirts of society, \
	living off the land and bathing in the red glory of combat."
	allowed_sexes = list("male")
	allowed_races = list("Humen",
	"Humen")
	outfit = /datum/outfit/job/roguetown/adventurer/barbarian


/datum/outfit/job/roguetown/adventurer/barbarian/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
	belt = /obj/item/storage/belt/rogue/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	if(prob(13))
		head = /obj/item/clothing/head/roguetown/helmet/horned
	if(prob(55))
		backr = /obj/item/storage/backpack/rogue/satchel
	if(prob(23))
		armor = /obj/item/clothing/suit/roguetown/armor/leather
	if(prob(23))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/hide
	if(prob(5))
		cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	if(prob(33))
		shoes = /obj/item/clothing/shoes/roguetown/boots
	var/randy = rand(1,5)
	switch(randy)
		if(1 to 2)
			beltr = /obj/item/rogueweapon/stoneaxe/woodcut
			H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 1, TRUE)
		if(3 to 4)
			beltr = /obj/item/rogueweapon/sword/iron
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		if(5)
			beltr = /obj/item/rogueweapon/mace/woodclub
			H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 1, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 1)
	H.change_stat("intelligence", -3)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	if(H.dna?.species)
		H.dna.species.soundpack_m = new /datum/voicepack/male/warrior()