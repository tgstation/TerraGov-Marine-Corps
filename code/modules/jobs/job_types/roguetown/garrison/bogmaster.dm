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
		"Half-Elf",
		"Tiefling",
		"Dark Elf"
	)
	tutorial = "You are the most experienced idiot to volunteer to the Bog Guard... What a mistake that was. Your job is to keep the bogmen in line and to ensure the routes to the keep are safe. May the ten have mercy on you..."
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	display_order = JDO_BOGMASTER
	whitelist_req = TRUE
	outfit = /datum/outfit/job/roguetown/bogmaster
	give_bank_account = 35
	min_pq = 5

/datum/job/roguetown/bogmaster/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
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

/datum/outfit/job/roguetown/bogmaster/pre_equip(mob/living/carbon/human/H)
	. = ..()
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/stabard/bog
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt/bog
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
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/bogconvert)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 5, TRUE)
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
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 3)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)

	H.verbs |= /mob/proc/haltyell
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)

/obj/effect/proc_holder/spell/self/bogconvert
	name = "Recruit Bogmen"
	desc = "!"
	antimagic_allowed = TRUE
	charge_max = 100

/obj/effect/proc_holder/spell/self/bogconvert/cast(list/targets,mob/user = usr)
	. = ..()
	var/list/targets = list()
	for(var/mob/living/carbon/human/not_bogged in get_hearers_in_view(3, user))
		//need a mind
		if(!not_bogged.mind)
			continue
		//only migrants and peasants
		if(!(not_bogged.job in GLOB.peasant_positions) && \
			!(not_bogged.job in GLOB.serf_positions) && \
			!(not_bogged.job in GLOB.allmig_positions))
			continue
		//need to see their damn face
		if(!not_bogged.get_face_name(null))
			continue
		targets[not_bogged.name] = not_bogged
	if(!length(targets))
		to_chat(user, "<span class='warning'>There are no potential recruits nearby.</span>")
		return
	var/inputty = input("Select a potential bogman!", "BOGMASTER") as text|null in targets
	if(inputty)
		var/mob/living/carbon/human/bogman = targets[inputty]
		if(!QDELETED(bogman) && (bogman in get_hearers_in_view(3, user)))
			INVOKE_ASYNC(src, PROC_REF(convert), bogman, user)
	else
		to_chat(user, "<span class='warning'>Recruitment cancelled.</span>")

/obj/effect/proc_holder/spell/self/bogconvert/proc/convert(mob/living/carbon/human/bogman, mob/living/carbon/human/bogmaster)
	if(QDELETED(bogman) || QDELETED(bogmaster))
		return
	bogmaster.say("Serve the bog!", forced = "bogconvert")
	var/prompt = alert(bogman, "Do you wish to join the Bog Guard?", "Bog Recruitment", "Yes", "No")
	if(prompt != "Yes" || QDELETED(bogman) || QDELETED(bogmaster) || !(bogmaster in get_hearers_in_view(3, bogman)))
		return
	bogman.say("FOR THE BOG!", forced = "bogconvert")
	bogman.job = "Bog Guard"
