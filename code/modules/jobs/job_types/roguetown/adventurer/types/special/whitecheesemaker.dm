/datum/advclass/whitecheese
	name = "WHITE CHEESE"
	allowed_sexes = list("male")
	allowed_races = list("Humen",
							"Humen")
	outfit = /datum/outfit/job/roguetown/adventurer/whitecheese
	plevel_req = 999
	special_req = TRUE
	maxchosen = 1
	isvillager = FALSE
	horse = /mob/living/simple_animal/hostile/retaliate/rogue/saigabuck/tame/saddled

/datum/outfit/job/roguetown/adventurer/whitecheese
	name = "WHITE CHEESE"

/datum/outfit/job/roguetown/adventurer/whitecheese/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 6, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/crafting, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/carpentry, rand(4,5), TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/masonry, rand(1,2), TRUE)

	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/nobleboot
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	beltl = /obj/item/storage/belt/rogue/pouch/coins/rich

	if(H.dna?.species)
		if(H.dna.species.id == "human")
			H.dna.species.soundpack_m = new /datum/voicepack/male/evil/blkknight()

	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_BREADY, TRAIT_GENERIC)
	H.change_stat("intelligence", 3)
	H.change_stat("strength", 4)
	H.change_stat("endurance", 4)
	H.change_stat("constitution", 4)
	H.change_stat("speed", 2)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/lightningbolt)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fetch)

	H.ambushable = FALSE