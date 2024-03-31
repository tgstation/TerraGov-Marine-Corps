/datum/job/roguetown/veteran
	title = "Veteran"
	flag = GUARDSMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list("Humen",
	"Elf",
	"Dwarf",
	"Aasimar",
	"Half-Elf")
	tutorial = "Youve known combat your entire life. There isnt a way to kill a man you havent practiced in the tapestries of war itself. You wouldnt call yourself a hero, those belong to the men left rotting in the fields of where you practiced your ancient trade. You dont sleep well at night anymore, you dont like remembering what youve had to do to survive. Trading adventure for stable pay was the only logical solution, and maybe someday youll get to lay down the blade.."
	allowed_ages = list(AGE_OLD)
	display_order = JDO_VET
	whitelist_req = TRUE

	outfit = /datum/outfit/job/roguetown/veteran
	give_bank_account = 35
	min_pq = 5

/datum/outfit/job/roguetown/veteran/pre_equip(mob/living/carbon/human/H)
	..()
	pants = /obj/item/clothing/under/roguetown/trou/leather
	cloak = /obj/item/clothing/cloak/half/vet
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guardsecond
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots
	beltl = /obj/item/keyring/guardcastle
	belt = /obj/item/storage/belt/rogue/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.change_stat("strength", 2)
		H.change_stat("perception", 1)
		H.change_stat("intelligence", 3)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)

	if(H.charflaw)
		if(H.charflaw.type != /datum/charflaw/noeyer)
			if(H.charflaw.type != /datum/charflaw/noeyel)
				var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_ARM)
				if(O)
					O.drop_limb()
					qdel(O)
				O = H.get_bodypart(BODY_ZONE_L_ARM)
				if(O)
					O.drop_limb()
					qdel(O)
				H.regenerate_limb(BODY_ZONE_R_ARM)
				H.regenerate_limb(BODY_ZONE_L_ARM)
				H.charflaw = new /datum/charflaw/noeyer()
				if(!istype(H.wear_mask, /obj/item/clothing/mask/rogue/eyepatch))
					qdel(H.wear_mask)
					mask = /obj/item/clothing/mask/rogue/eyepatch

	H.verbs |= /mob/proc/haltyell
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)
