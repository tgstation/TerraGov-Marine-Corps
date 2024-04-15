/datum/job/roguetown/watchman
	title = "Gatemaster"
	flag = WATCHMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_sexes = list("male", "female")
	allowed_races = list("Humen",
	"Humen"
	)
	tutorial = "Tales speak of the Gatemaster's legendary ability to stand still at a gate and ask people questions."
	display_order = JDO_GATEMASTER

	outfit = /datum/outfit/job/roguetown/watchman
	give_bank_account = 3
	min_pq = -4

/datum/outfit/job/roguetown/watchman
	name = "Gateman"
	jobtype = /datum/job/roguetown/watchman

/datum/outfit/job/roguetown/watchman/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/roguehood/red
	pants = /obj/item/clothing/under/roguetown/trou/leather
	cloak = /obj/item/clothing/cloak/stabard/guard
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/merc
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots
	beltl = /obj/item/keyring/gatemaster
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/mace/cudgel
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.change_stat("strength", 1)
		H.change_stat("perception", 1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)
	if(H.gender == FEMALE)
		var/acceptable = list("Tomboy", "Bob", "Curly Short")
		if(!(H.hairstyle in acceptable))
			H.hairstyle = pick(acceptable)
			H.update_hair()
	H.verbs |= /mob/proc/haltyell
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)