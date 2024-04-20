/datum/job/roguetown/bogguardsman
	title = "Bog Guard"
	flag = GUARDSMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	selection_color = JCOLOR_SOLDIER
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dwarf",
	"Aasimar",
	"Half-Elf"
	)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	tutorial = "You've handed your resume, which mostly consisted of showing up, and in exchange you have a spot among the Bog Guards. You have a roof over your head, coin in your pocket, and a thankless job protecting the outskirts of town."
	display_order = JDO_TOWNGUARD
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/bogguardsman
	give_bank_account = 16
	min_pq = -4

/datum/job/roguetown/bogguardsman/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
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

/datum/outfit/job/roguetown/bogguardsman/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/helmet/skullcap
	pants = /obj/item/clothing/under/roguetown/trou/leather
	cloak = /obj/item/clothing/cloak/stabard/guard
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/merc
	armor = /obj/item/clothing/suit/roguetown/armor/plate/half
	neck = /obj/item/clothing/neck/roguetown/coif
	shoes = /obj/item/clothing/shoes/roguetown/boots
	beltl = /obj/item/keyring/guard
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/sword
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
