/datum/job/roguetown/knight
	title = "Knight"
	flag = KNIGHT
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	allowed_races = list("Humen",
	"Humen")
	allowed_sexes = list(MALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "A Knight with expert training; Born into petty nobility and raised as a squire from a young age, now you Guard the king as his knight, answer to his commands, and protect his honor. You're wholy dedicated to him, and his safety. Do not fail him."
	display_order = JDO_KNIGHT
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/knight
	give_bank_account = 22
	min_pq = 2

/datum/job/roguetown/knight/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		var/prev_real_name = H.real_name
		var/prev_name = H.name
		H.real_name = "Sir [prev_real_name]"
		H.name = "Sir [prev_name]"

/datum/outfit/job/roguetown/knight/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight
	gloves = /obj/item/clothing/gloves/roguetown/plate
	pants = /obj/item/clothing/under/roguetown/platelegs
	cloak = /obj/item/clothing/cloak/tabard/knight/guard
	neck = /obj/item/clothing/neck/roguetown/gorget
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/merc
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	beltl = /obj/item/keyring/guardcastle
	belt = /obj/item/storage/belt/rogue/leather/hand
	backr = /obj/item/storage/backpack/rogue/satchel
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		backl = /obj/item/rogueweapon/sword/long
		H.change_stat("strength", 4)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 2)
		H.change_stat("constitution", 2)
		H.change_stat("endurance", 3)
		H.change_stat("speed", -2)
		if(H.dna?.species)
			if(H.dna.species.id == "human")
				H.dna.species.soundpack_m = new /datum/voicepack/male/knight()

	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_NOSEGRAB, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)
