/datum/job/roguetown/sheriff
	title = "Sheriff"
	flag = SHERIFF
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 0
	spawn_positions = 1

	allowed_races = list("Humen",
	"Humen",
	"Aasimar")
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_SHERIFF
	tutorial = "Law and Order, your divine reason for existence. These animals are undeserving of your protection, for it is their sons and daughters roving the countryside with blade in hand; how many men have you lost this week just to the horrors in the woods alone? Are you the one to stand between this town and chaos, or will you fail it like they expect you to?"
	whitelist_req = FALSE
	outfit = /datum/outfit/job/roguetown/sheriff
	give_bank_account = 26
	min_pq = 2

/datum/outfit/job/roguetown/sheriff/pre_equip(mob/living/carbon/human/H)
	..()
	pants = /obj/item/clothing/under/roguetown/trou/leather
	armor = /obj/item/clothing/suit/roguetown/armor/brigandine/sheriff
	neck = /obj/item/clothing/neck/roguetown/gorget
	shirt = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	shoes = /obj/item/clothing/shoes/roguetown/boots
	backr = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltl = /obj/item/rogueweapon/sword/sabre
	beltr = /obj/item/rogueweapon/mace/cudgel
	cloak = /obj/item/clothing/cloak/cape/guard
	backpack_contents = list(/obj/item/keyring/sheriff = 1)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/guardconvert)
		H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.change_stat("strength", 5)
		H.change_stat("perception", 2)
		H.change_stat("intelligence", 1)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)
		H.change_stat("fortune", 1)
	if(H.gender == FEMALE)
		var/acceptable = list("Tomboy", "Bob", "Curly Short")
		if(!(H.hairstyle in acceptable))
			H.hairstyle = pick(acceptable)
			H.update_hair()
	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)
	H.verbs |= /mob/proc/haltyell

/obj/effect/proc_holder/spell/self/guardconvert
	name = "Recruit Guardsmen"
	desc = "!"
	antimagic_allowed = TRUE
	charge_max = 100

/obj/effect/proc_holder/spell/self/guardconvert/cast(list/targets,mob/user = usr)
	. = ..()
	var/list/recruitment = list()
	for(var/mob/living/carbon/human/not_guard in get_hearers_in_view(3, user))
		//need a mind
		if(!not_guard.mind)
			continue
		//only migrants and peasants
		if(!(not_guard.job in GLOB.peasant_positions) && \
			!(not_guard.job in GLOB.serf_positions) && \
			!(not_guard.job in GLOB.allmig_positions))
			continue
		//need to see their damn face
		if(!not_guard.get_face_name(null))
			continue
		recruitment[not_guard.name] = not_guard
	if(!length(recruitment))
		to_chat(user, "<span class='warning'>There are no potential recruits nearby.</span>")
		return
	var/inputty = input("Select a potential guardsman!", "SHERIFF") as anything in targets
	if(inputty)
		var/mob/living/carbon/human/guardsman = recruitment[inputty]
		if(!QDELETED(guardsman) && (guardsman in get_hearers_in_view(3, user)))
			INVOKE_ASYNC(src, PROC_REF(convert), guardsman, user)
	else
		to_chat(user, "<span class='warning'>Recruitment cancelled.</span>")

/obj/effect/proc_holder/spell/self/guardconvert/proc/convert(mob/living/carbon/human/guardsman, mob/living/carbon/human/bogmaster)
	if(QDELETED(guardsman) || QDELETED(bogmaster))
		return
	bogmaster.say("Serve the king!", forced = "guardconvert")
	var/prompt = alert(guardsman, "Do you wish to join the Bog Guard?", "Bog Recruitment", "Yes", "No")
	if(prompt != "Yes" || QDELETED(guardsman) || QDELETED(bogmaster) || !(bogmaster in get_hearers_in_view(3, guardsman)))
		return
	guardsman.say("FOR THE KING!", forced = "guardconvert")
	guardsman.job = "Town Guard"
