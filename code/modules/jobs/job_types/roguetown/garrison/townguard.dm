/datum/job/roguetown/guardsman
	title = "Town Guard"
	flag = GUARDSMAN
	department_flag = GARRISON
	faction = "Station"
	total_positions = 0
	spawn_positions = 10
	selection_color = JCOLOR_SOLDIER
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dwarf",
	"Aasimar",
	"Half-Elf"
	)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "You've enough training to point your spear in the right direction, and you've enough mammons in your pocket to want to keep this job: But you know youre just as disposable as the last poor bastards to call themselves a Guard."
	display_order = JDO_TOWNGUARD
	whitelist_req = TRUE

	outfit = /datum/outfit/job/roguetown/guardsman
	give_bank_account = 16
	min_pq = -4

	/// Chance to be spawned as a bowman instead
	var/bowman_chance = 35
	/// Amount of bowmen spawned so far
	var/bowman_amount = 0
	/// Maximum amount of crossbowmen that can be spawned
	var/bowman_max = 3
	/// bowman outfit
	var/bowman_outfit = /datum/outfit/job/roguetown/guardsman/bowman

/datum/job/roguetown/guardsman/get_outfit(mob/living/carbon/human/wearer, visualsOnly = FALSE, announce = TRUE, latejoin = FALSE, preference_source = null)
	if((bowman_amount < bowman_max) && prob(bowman_chance))
		bowman_amount++
		return bowman_outfit
	return ..()

/datum/job/roguetown/guardsman/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
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

/datum/outfit/job/roguetown/guardsman
	name = "Town Guard"
	/// Whether or not we are a bowman
	var/is_bowman = FALSE

/datum/outfit/job/roguetown/guardsman/pre_equip(mob/living/carbon/human/H)
	. = ..()
	pants = /obj/item/clothing/under/roguetown/trou/leather
	cloak = /obj/item/clothing/cloak/stabard/guard
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/merc
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail
	neck = /obj/item/clothing/neck/roguetown/gorget
	shoes = /obj/item/clothing/shoes/roguetown/boots
	beltl = /obj/item/keyring/guard
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/rogueweapon/mace/cudgel
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1)
	if(is_bowman)
		backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
		beltr = /obj/item/quiver/bolts //replaces mace
	else
		backl = null
	if(H.mind)
		assign_skills(H)
	if(H.gender == FEMALE)
		var/acceptable = list("Tomboy", "Bob", "Curly Short")
		if(!(H.hairstyle in acceptable))
			H.hairstyle = pick(acceptable)
			H.update_hair()
	H.verbs |= /mob/proc/haltyell
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)

/datum/outfit/job/roguetown/guardsman/proc/assign_skills(mob/living/carbon/human/guard)
	guard.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	guard.change_stat("strength", 1)
	guard.change_stat("perception", 1)
	guard.change_stat("endurance", 1)
	guard.change_stat("speed", 1)

/datum/outfit/job/roguetown/guardsman/bowman
	name = "Town Bowman Guard"
	is_bowman = TRUE

/datum/outfit/job/roguetown/guardsman/bowman/assign_skills(mob/living/carbon/human/guard)
	guard.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 1, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	guard.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	guard.change_stat("perception", 2)
	guard.change_stat("endurance", 1)
	guard.change_stat("speed", 2)

/mob/proc/haltyell()
	set name = "HALT!"
	set category = "Noises"
	emote("haltyell")
