/datum/job/roguetown/bogguardsman
	title = "Bog Guard"
	flag = GUARDSMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 10
	spawn_positions = 10
	selection_color = JCOLOR_SOLDIER
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list("Humen",
		"Elf",
		"Dwarf",
		"Aasimar",
		"Half-Elf",
		"Tiefling",
		"Dark Elf"
	)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	tutorial = "You've handed your resume, which mostly consisted of showing up, and in exchange you have a spot among the Bog Guards. You have a roof over your head, coin in your pocket, and a thankless job protecting the outskirts of town against bandits and volfs."
	display_order = JDO_TOWNGUARD
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/bogguardsman
	give_bank_account = 16
	min_pq = -4

	/// Chance to be spawned as a crossbowman instead
	var/crossbowman_chance = 35
	/// Amount of crossbowmen spawned so far
	var/crossbowman_amount = 0
	/// Maximum amount of crossbowmen that can be spawned
	var/crossbowman_max = 3
	/// Crossbowman outfit
	var/crossbowman_outfit = /datum/outfit/job/roguetown/bogguardsman/crossbowman

/datum/job/roguetown/bogguardsman/get_outfit(mob/living/carbon/human/wearer, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, preference_source = null)
	if((crossbowman_amount < crossbowman_max) && prob(crossbowman_chance))
		crossbowman_amount++
		return crossbowman_outfit
	return ..()

/datum/job/roguetown/bogguardsman/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/bog))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "bogman's tabard ([index])"

/datum/outfit/job/roguetown/bogguardsman
	name = "Bog Guard"
	/// Whether or not we are a crossbowman
	var/is_crossbowman = FALSE

/datum/outfit/job/roguetown/bogguardsman/pre_equip(mob/living/carbon/human/H)
	. = ..()
	head = /obj/item/clothing/head/roguetown/helmet/skullcap
	armor = /obj/item/clothing/suit/roguetown/armor/gambeson
	cloak = /obj/item/clothing/cloak/stabard/bog
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/bog
	pants = /obj/item/clothing/under/roguetown/trou/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots
	beltl = /obj/item/keyring/guard
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/sword
	backr = /obj/item/storage/backpack/rogue/satchel
	if(is_crossbowman)
		backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
		beltr = /obj/item/quiver/bolts //replaces sword
	else
		backl = null
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1)
	if(H.mind)
		assign_skills(H)
	if(H.gender == FEMALE)
		var/acceptable = list("Tomboy", "Bob", "Curly Short")
		if(!(H.hairstyle in acceptable))
			H.hairstyle = pick(acceptable)
			H.update_hair()
	H.verbs |= /mob/proc/haltyell
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)

/datum/outfit/job/roguetown/bogguardsman/proc/assign_skills(mob/living/carbon/human/bogger)
	bogger.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	bogger.change_stat("strength", 1)
	bogger.change_stat("perception", 1)
	bogger.change_stat("endurance", 1)
	bogger.change_stat("speed", 1)

/datum/outfit/job/roguetown/bogguardsman/crossbowman
	name = "Bog Crossbow Guard"
	is_crossbowman = TRUE

/datum/outfit/job/roguetown/bogguardsman/crossbowman/assign_skills(mob/living/carbon/human/bogger)
	bogger.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 1, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/bows, 4, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/crossbows, 5, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	bogger.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	bogger.change_stat("perception", 2)
	bogger.change_stat("endurance", 1)
	bogger.change_stat("speed", 2)
