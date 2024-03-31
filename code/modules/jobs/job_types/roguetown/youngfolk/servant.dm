/datum/job/roguetown/servant
	title = "Servant"
	flag = SERVANT
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	allowed_races = list("Humen",
	"Humen",
	"Half-Elf")
	allowed_ages = list(AGE_YOUNG)

	tutorial = "Granted a comfortable life in the Lord's manor as one of his servants! You will appreciate it more and more every day as you clean the floors and are beaten for nothing."

	outfit = /datum/outfit/job/roguetown/servant
	display_order = JDO_SERVANT
	give_bank_account = TRUE

/datum/outfit/job/roguetown/servant/pre_equip(mob/living/carbon/human/H)
	..()

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
	if(H.gender == MALE)
		pants = /obj/item/clothing/under/roguetown/tights
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
		shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
		belt = /obj/item/storage/belt/rogue/leather/rope
		neck = /obj/item/storage/belt/rogue/pouch
		beltr = /obj/item/keyring/servant
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/black
		H.change_stat("perception", 1)
	else
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
		shoes = /obj/item/clothing/shoes/roguetown/simpleshoes
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
		neck = /obj/item/storage/belt/rogue/pouch
		belt = /obj/item/storage/belt/rogue/leather/rope
		beltr = /obj/item/keyring/servant
		H.change_stat("perception", 1)
