/datum/job/roguetown/woodsman
	title = "Village Elder"
	flag = WOODSMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dwarf",
	"Aasimar",
	"Half-Elf"
	)
	allowed_ages = list(AGE_OLD)
	tutorial = "You are as venerable and ancient as the trees themselves, wise even for your years. The King may lead officially, but people look to you as Ealdorman to solve lesser issues. Remember the old ways of the law, not everything must end in bloodshed: no matter how much the Guards wish it were the case."
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/woodsman
	display_order = JDO_CHIEF
	min_pq = -4
	give_bank_account = 16

/datum/outfit/job/roguetown/woodsman
	name = "Village Elder"
	jobtype = /datum/job/roguetown/woodsman

/datum/outfit/job/roguetown/woodsman/pre_equip(mob/living/carbon/human/H)
	..()
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	cloak = /obj/item/clothing/cloak/raincloak/furcloak
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/mace/cudgel
	beltl = /obj/item/flashlight/flare/torch/lantern
	r_hand = /obj/item/rogueweapon/woodstaff
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.change_stat("strength", 5)
		H.change_stat("perception", 4)
		H.change_stat("endurance", 4)
		H.change_stat("speed", -3)
		H.change_stat("intelligence", 5)
	H.verbs |= /mob/proc/haltyell
