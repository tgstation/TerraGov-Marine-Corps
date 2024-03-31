/datum/job/roguetown/monk
	title = "Acolyte"
	flag = MONK
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 3
	spawn_positions = 4

	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Half-Elf",
	"Elf",
	"Dwarf",
	"Aasimar"
	)
	tutorial = "Chores, some more chores- Even more chores.. Oh how the life of a humble cleric is exhausting… You have faith, but even you know you gave up a life of adventure for that of the security in the Church. Assist the Priest in their daily tasks, maybe today will be the day something interesting happens."
	allowed_patrons = list("Astrata", "Dendor", "Necra")
	outfit = /datum/outfit/job/roguetown/monk

	display_order = JDO_MONK
	give_bank_account = TRUE

/datum/outfit/job/roguetown/monk
	name = "Acolyte"
	jobtype = /datum/job/roguetown/monk

/datum/outfit/job/roguetown/monk/pre_equip(mob/living/carbon/human/H)
	..()
	var/datum/patrongods/A = H.PATRON
	switch(A.name)
		if("Astrata")
			head = /obj/item/clothing/head/roguetown/roguehood/astrata
			neck = /obj/item/clothing/neck/roguetown/psicross/astrata
			wrists = /obj/item/clothing/wrists/roguetown/wrappings
			shoes = /obj/item/clothing/shoes/roguetown/sandals
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/astrata
			belt = /obj/item/storage/belt/rogue/leather/rope
			beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
			beltl = /obj/item/roguekey/church
		if("Dendor")
			head = /obj/item/clothing/head/roguetown/dendormask
			neck = /obj/item/clothing/neck/roguetown/psicross/dendor
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/dendor
			belt = /obj/item/storage/belt/rogue/leather/rope
			beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
			beltl = /obj/item/roguekey/church
		if("Necra")
			head = /obj/item/clothing/head/roguetown/necrahood
			neck = /obj/item/clothing/neck/roguetown/psicross/necra
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather/mourning
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/necra
			beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
			beltl = /obj/item/roguekey/church
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 4, TRUE)
		if(H.age == AGE_OLD)
			H.mind.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
		H.change_stat("intelligence", 1)
		H.change_stat("endurance", 1)
		H.change_stat("perception", -1)

	var/datum/devotion/cleric_holder/C = new /datum/devotion/cleric_holder(H, H.PATRON)
	C.holder_mob = H
	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)
	C.grant_spells(H)
