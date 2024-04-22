/datum/job/roguetown/bapprentice
	title = "Smithy Apprentice"
	flag = APPRENTICE
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_races = list("Humen",
	"Humen",
	"Half-Elf")
	allowed_ages = list(AGE_YOUNG)

	tutorial = "Long hours and back-breaking work wouldnt even describe a quarter of what you do in a day for your Master. Its exhausting, filthy and you dont get much freetime: but someday youll get your own smithy, and youll have TWICE as many apprentices as your master does."

	outfit = /datum/outfit/job/roguetown/bapprentice
	display_order = JDO_BAPP
	give_bank_account = TRUE

/datum/outfit/job/roguetown/bapprentice/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/craft/blacksmithing, pick(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/armorsmithing, pick(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/weaponsmithing, pick(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/crafting, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights/random
		shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
		shirt = null
		belt = /obj/item/storage/belt/rogue/leather/rope
		beltr = /obj/item/roguekey/blacksmith
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
		backr = /obj/item/storage/backpack/rogue/satchel
		wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	else
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/random
		shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
		belt = /obj/item/storage/belt/rogue/leather/rope
		beltr = /obj/item/roguekey/blacksmith
		cloak = /obj/item/clothing/cloak/apron/brown
		backr = /obj/item/storage/backpack/rogue/satchel
