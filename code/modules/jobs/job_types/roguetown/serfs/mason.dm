/datum/job/roguetown/mason
	title = "Mason"
	flag = MASON
	department_flag = SERFS
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_races = list("Humen",
	"Humen",
	"Dwarf",
	"Dwarf",
	"Aasimar"
	)
	allowed_sexes = list(MALE, FEMALE)

	tutorial = "There are ancient secrets within stone, something your creed has known since man built upon dirt. Youve pride in your work, youre the only reason this place doesnt fall apart. The King could replace you in a heartbeat, prove to them why youre the Master Mason."

	outfit = /datum/outfit/job/roguetown/mason
	display_order = JDO_MASON
	give_bank_account = 8

/datum/outfit/job/roguetown/mason/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, rand(1,3), TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, rand(1,3), TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, rand(1,3), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, rand(4,5), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/carpentry, rand(4,5), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/masonry, rand(4,5), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/engineering, rand(2,4), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
	head = /obj/item/clothing/head/roguetown/hatfur
	if(prob(50))
		head = /obj/item/clothing/head/roguetown/hatblu
//	armor = /obj/item/clothing/suit/roguetown/armor/workervest
	cloak = /obj/item/clothing/cloak/apron/waist/brown
	pants = /obj/item/clothing/under/roguetown/trou
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/random
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/storage/belt/rogue/pouch/coins/mid
	beltl = /obj/item/rogueweapon/hammer/claw
	backl = /obj/item/storage/backpack/rogue/backpack
	backpack_contents = list(/obj/item/roguekey/mason = 1)
	H.change_stat("strength", 1)
	H.change_stat("intelligence", 1)
	H.change_stat("endurance", 1)
	H.change_stat("constitution", 1)
	H.change_stat("speed", -1)
