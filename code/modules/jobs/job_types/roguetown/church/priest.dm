
/datum/job/roguetown/priest
	title = "Priest"
	flag = PRIEST
	department_flag = CHURCHMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	selection_color = JCOLOR_CHURCH
	f_title = "Priestess"
	allowed_races = list("Humen","Humen","Elf", "Dwarf","Half-Elf",	"Aasimar")
	allowed_patrons = list("Astrata")
	tutorial = "The Divine is all that matters in a world of the immoral. The Weeping God left his children to rule over us mortals and you will preach their wisdom to any who still heed their will. The faithless are growing in number, it is up to you to shepard them to a Gods-fearing future."
	whitelist_req = FALSE
	outfit = /datum/outfit/job/roguetown/priest

	display_order = JDO_PRIEST
	give_bank_account = 115
	min_pq = -4

/datum/outfit/job/roguetown/priest/pre_equip(mob/living/carbon/human/H)
	..()
	H.verbs |= /mob/living/carbon/human/proc/coronate_lord
	H.verbs |= /mob/living/carbon/human/proc/churchexcommunicate
	H.verbs |= /mob/living/carbon/human/proc/churchannouncement
	neck = /obj/item/clothing/neck/roguetown/psicross/astrata
	head = /obj/item/clothing/head/roguetown/priestmask
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	pants = /obj/item/clothing/under/roguetown/tights/black
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	beltl = /obj/item/keyring/priest
	belt = /obj/item/storage/belt/rogue/leather/rope
	beltr = /obj/item/storage/belt/rogue/pouch/coins/rich
	id = /obj/item/clothing/ring/active/nomag
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/priest
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/templar)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/convertrole/monk)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/holy, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
		if(H.age == AGE_OLD)
			H.mind.adjust_skillrank(/datum/skill/magic/holy, 1, TRUE)
		H.change_stat("strength", -1)
		H.change_stat("intelligence", 2)
		H.change_stat("constitution", -2)
		H.change_stat("endurance", 1)
		H.change_stat("speed", -2)
	var/datum/devotion/cleric_holder/C = new /datum/devotion/cleric_holder(H, H.PATRON) // This creates the cleric holder used for devotion spells
	C.holder_mob = H
	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)
	C.grant_spells_priest(H)

//	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)
//		H.underwear = "Femleotard"
//		H.underwear_color = CLOTHING_BLACK
//		H.update_body()


/mob/living/carbon/human/proc/coronate_lord()
	set name = "Coronate"
	set category = "Priest"
	if(!mind)
		return
	if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
		to_chat(src, "<span class='warning'>I need to do this in the chapel.</span>")
		return FALSE
	for(var/mob/living/carbon/human/HU in get_step(src, src.dir))
		if(!HU.mind)
			continue
		if(HU.mind.assigned_role == "King")
			continue
		if(!HU.head)
			continue
		if(!istype(HU.head, /obj/item/clothing/head/roguetown/crown/serpcrown))
			continue
		for(var/mob/living/carbon/human/HL in GLOB.human_list)
			if(HL.mind)
				if(HL.mind.assigned_role == "King")
					HL.mind.assigned_role = "Ex-King"
			if(HL.job == "King")
				HL.job = "Ex-King"
			if(HL.mind)
				if(HL.mind.assigned_role == "Queen")
					HL.mind.assigned_role = "Ex-Queen"
			if(HL.job == "Queen")
				HL.job = "Ex-Queen"
		switch(HU.gender)
			if("male")
				HU.mind.assigned_role = "King"
				HU.job = "King"
			if("female")
				HU.mind.assigned_role = "Queen"
				HU.job = "Queen"
		SSticker.rulermob = HU
		var/dispjob = mind.assigned_role
		GLOB.badomens -= "nolord"
		say("By the authority of the gods, I pronounce you Ruler of all Rockhill!")
		priority_announce("[real_name] the [dispjob] has named [HU.real_name] the inheritor of ROGUETOWN!", title = "Long Live [HU.real_name]!", sound = 'sound/misc/bell.ogg')
		return

/mob/living/carbon/human/proc/churchexcommunicate()
	set name = "Curse"
	set category = "Priest"
	if(stat)
		return
	var/inputty = input("Curse someone... (curse them again to remove it)", "Sinner Name") as text|null
	if(inputty)
		if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
			to_chat(src, "<span class='warning'>I need to do this from the chapel.</span>")
			return FALSE
		if(inputty in GLOB.excommunicated_players)
			GLOB.excommunicated_players -= inputty
			priority_announce("[real_name] has forgiven [inputty]. Once more walk in the light!", title = "Hail the Ten!", sound = 'sound/misc/bell.ogg')
			for(var/mob/living/carbon/human/H in GLOB.player_list)
				if(H.real_name == inputty)
					H.remove_stress(/datum/stressevent/psycurse)
			return
		var/found = FALSE
		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H == src)
				continue
			if(H.real_name == inputty)
				found = TRUE
				H.add_stress(/datum/stressevent/psycurse)
		if(!found)
			return FALSE
		GLOB.excommunicated_players += inputty
		priority_announce("[real_name] has put Xylix's curse of woe on [inputty] for offending the church!", title = "SHAME", sound = 'sound/misc/excomm.ogg')

/mob/living/carbon/human/proc/churchannouncement()
	set name = "Announcement"
	set category = "Priest"
	if(stat)
		return
	var/inputty = input("Make an announcement", "ROGUETOWN") as text|null
	if(inputty)
		if(!istype(get_area(src), /area/rogue/indoors/town/church/chapel))
			to_chat(src, "<span class='warning'>I need to do this from the chapel.</span>")
			return FALSE
		priority_announce("[inputty]", title = "The Priest Speaks", sound = 'sound/misc/bell.ogg')

/obj/effect/proc_holder/spell/self/convertrole/templar
	name = "Recruit Templar"
	new_role = "Templar"
	recruitment_faction = "Templars"
	recruitment_message = "Serve the ten, %RECRUIT!"
	accept_message = "FOR PSYDON!"
	refuse_message = "I refuse."
	charge_max = 200 //templars get cool spells, so higher cooldown

/obj/effect/proc_holder/spell/self/convertrole/templar/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
	. = ..()
	if(!.)
		return
	var/datum/devotion/cleric_holder/holder = new /datum/devotion/cleric_holder(recruit, recruit.PATRON)
	holder.holder_mob = recruit
	//Max devotion limit - Templars are stronger but cannot pray to gain more abilities
	holder.max_devotion = 200
	holder.update_devotion(50, 50)
	recruit.verbs |= list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)
	var/static/list/templar_spells = list(
		/obj/effect/proc_holder/spell/invoked/heal/lesser, 
		/obj/effect/proc_holder/spell/targeted/churn, 
		/obj/effect/proc_holder/spell/targeted/burialrite,
	)
	for(var/spell in templar_spells)
		recruit.mind?.AddSpell(new spell)

/obj/effect/proc_holder/spell/self/convertrole/monk
	name = "Recruit Acolyte"
	new_role = "Acolyte"
	recruitment_faction = "Church"
	recruitment_message = "Serve the ten, %RECRUIT!"
	accept_message = "FOR PSYDON!"
	refuse_message = "I refuse."

/obj/effect/proc_holder/spell/self/convertrole/monk/can_convert(mob/living/carbon/human/recruit)
	. = ..()
	if(!.)
		return
	if(!recruit.PATRON || !(recruit.PATRON in ALL_PATRON_NAMES_LIST))
		return FALSE

/obj/effect/proc_holder/spell/self/convertrole/monk/convert(mob/living/carbon/human/recruit, mob/living/carbon/human/recruiter)
	. = ..()
	if(!.)
		return
	var/datum/devotion/cleric_holder/holder = new /datum/devotion/cleric_holder(recruit, recruit.PATRON)
	holder.holder_mob = recruit
	holder.update_devotion(50, 50)
	holder.grant_spells(recruit)
	recruit.verbs |= list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)
