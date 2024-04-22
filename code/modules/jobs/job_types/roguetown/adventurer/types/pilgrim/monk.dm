/datum/advclass/monk
	name = "Monk"
	allowed_sexes = list("male", "female")
	tutorial = "A traveling monk of the God Ravox, unmatched in unarmed combat and with an unwavering devotion to Justice."
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Elf",
	"Half-Elf",
	"Dwarf",
	"Aasimar"
	)
	outfit = /datum/outfit/job/roguetown/adventurer/monk
	isvillager = FALSE
	ispilgrim = FALSE
	vampcompat = FALSE


/datum/outfit/job/roguetown/adventurer/monk/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/roguehood
	neck = /obj/item/clothing/neck/roguetown/psicross
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
	armor = /obj/item/clothing/suit/roguetown/shirt/robe
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltl = /obj/item/storage/belt/rogue/pouch/coins/poor
	backl = /obj/item/storage/backpack/rogue/backpack
	r_hand = /obj/item/rogueweapon/woodstaff
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
		H.change_stat("strength", 3)
		H.change_stat("intelligence", 1)
		H.change_stat("endurance", 2)
		H.change_stat("perception", -1)
	if(H.PATRON != /datum/patrongods/ravox)
//		H.PATRON = GLOB.patronlist["Ravox"]
		H.PATRON = new /datum/patrongods/ravox
		to_chat(H, "<span class='warning'> My patron had not endorsed my practices in my younger years. I've since grown acustomed to [H.PATRON].")
