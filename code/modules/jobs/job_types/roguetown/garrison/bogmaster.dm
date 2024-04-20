/datum/job/roguetown/bogmaster
	title = "Bog Master"
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
	tutorial = "You are the most experienced idiot to volunteer to lead the Bog Guards... What a mistake that was... Your job is to keep the bogmen in line and to ensure the routes to the keep are safe. May the ten have mercy on you..."
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	display_order = JDO_BOGMASTER
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/bogmaster
	give_bank_account = 35
	min_pq = 5

/datum/job/roguetown/bogmaster/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "guard's tabard ([index])"

/datum/outfit/job/roguetown/bogmaster/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/guard
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/merc
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots
	beltl = /obj/item/keyring/guardcastle
	beltr = /obj/item/rogueweapon/sword
	belt = /obj/item/storage/belt/rogue/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backl = /obj/item/rogueweapon/shield/tower
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
