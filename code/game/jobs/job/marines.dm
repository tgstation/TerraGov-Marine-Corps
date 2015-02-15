//Commander
/datum/job/captain
	title = "Commander"
	flag = COMMANDER
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Central Command"
	selection_color = "#ccccff"
	idtype = /obj/item/weapon/card/id/gold
	req_admin_notify = 1
	access = list() 			//See get_access()
	minimal_access = list() 	//See get_access()
	minimal_player_age = 14
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		var/obj/item/clothing/under/U = new /obj/item/clothing/under/marine/officer/commander(H)
		U.hastie = new /obj/item/clothing/tie/medal/gold/captain(U)
		var/obj/item/weapon/storage/backpack/mcommander/BPK = new/obj/item/weapon/storage/backpack/mcommander(H)
		new /obj/item/weapon/storage/box/survival(BPK)
		H.equip_to_slot_or_del(BPK, slot_back,1)
		H.equip_to_slot_or_del(U, slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marinechief/commander(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/commander(H), slot_head)
		var/obj/item/weapon/implant/loyalty/L = new/obj/item/weapon/implant/loyalty(H)
		L.imp_in = H
		L.implanted = 1
		world << "<b>[H.real_name] is the Marine Commander!</b>"
		var/datum/organ/external/affected = H.organs_by_name["head"]
		affected.implants += L
		L.part = affected
		return 1

	get_access()
		return get_all_marine_accesses()

//Marine
/datum/job/marine
	title = "Marine"
	flag = MARINE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	supervisors = "the commander"
	selection_color = "#ffeeee"
	access = list()
	minimal_access = list()
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/slippers(H), slot_shoes)
		// H.equip_to_slot_or_del(new /obj/item/device/radio/marine(H), slot_l_store)
		return 1

//Millitary Police
/datum/job/military_officer
	title = "Military Police"
	flag = MPOLICE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the commander"
	selection_color = "#ffeeee"
	access = list(access_logistics, access_sulaco_brig, access_sulaco_cells)
	minimal_access = list(access_logistics, access_sulaco_brig, access_sulaco_cells)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mmpo(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/mp(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine, slot_belt)
		return 1

//Logistics Officer
/datum/job/logistics_officer
	title = "Logistics Officer"
	flag = LOGISTICS
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the commander"
	selection_color = "#ffeeee"
	idtype = /obj/item/weapon/card/id/silver
	access = list(access_logistics, access_sulaco_brig, access_sulaco_cells)
	minimal_access = list(access_logistics, access_sulaco_brig, access_sulaco_cells)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/head/beret/marine/logisticsofficer(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/logistics(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		return 1

//Sulaco Medic
/datum/job/sulmed
	title = "Sulaco Medic"
	flag = SULMED
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the commander"
	selection_color = "#ffeeee"
	access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/slippers(H), slot_shoes)
		// H.equip_to_slot_or_del(new /obj/item/device/radio/marine(H), slot_l_store)
		return 1