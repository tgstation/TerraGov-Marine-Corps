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

//Executive Officer
/datum/job/executive_officer
	title = "Executive Officer"
	flag = EXECUTIVE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander"
	selection_color = "#ddddff"
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
		
//Bridge Officer
/datum/job/bridge_officer
	title = "Bridge Officer"
	flag = BRIDGE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Commander"
	selection_color = "#ddddff"
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
		
//Military Police
/datum/job/military_police
	title = "Military Police"
	flag = MPOLICE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the commander"
	selection_color = "#ffdddd"
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

//Sulaco Chief Medical Officer
/datum/job/sul_cmo
	title = "Sulaco Chief Medical Officer"
	flag = SULCMO
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander"
	selection_color = "#99FF99"
	access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_medical_officer(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/heads/cmo(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat/cmo(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		return 1
		
//Sulaco Doctor
/datum/job/sul_doc
	title = "Sulaco Doctor"
	flag = SULDOC
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Commander, the Sulaco Chief Medical Officer"
	selection_color = "#BBFFBB"
	access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)
		return 1
		
//Sulaco Chemist
/datum/job/sul_chem
	title = "Sulaco Chemist"
	flag = SULCHEM
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the Commander, the Sulaco Chief Medical Officer"
	selection_color = "#BBFFBB"
	access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/medic(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_med(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/medical(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/labcoat(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/device/pda/medical(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/firstaid/adv(H), slot_l_hand)
		H.equip_to_slot_or_del(new /obj/item/device/flashlight/pen(H), slot_s_store)
		return 1
		
//Sulaco Chief Engineer
/datum/job/sul_ce
	title = "Sulaco Chief Engineer"
	flag = SULCE
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander"
	selection_color = "#ffeeaa"
	access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/chief_engineer(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/pda/heads/ce(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/black(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		return 1
		
//Maintenance Tech
/datum/job/sul_eng
	title = "Maintenance Tech"
	flag = SULENG
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the Sulaco Chief Engineer, the Commander"
	selection_color = "#fff5cc"
	access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_access = list(access_medical_bay, access_medical_chem, access_medical_surgery, access_medical_genetics, access_medical_storage)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/engineer(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/orange(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/t_scanner(H), slot_r_store)
		H.equip_to_slot_or_del(new /obj/item/device/pda/engineering(H), slot_l_store)
		return 1
		
/* //SQUADLEAD
/datum/job/squadlead
	title = "Squad Leader"
	flag = SQUADLEAD
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander"
	selection_color = "#ffeeee"
	access = list()
	minimal_access = list()
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			// if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/slippers(H), slot_shoes)
		// H.equip_to_slot_or_del(new /obj/item/device/radio/marine(H), slot_l_store)
		// if(H.backbag == 1)
			// H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/marine(H), slot_r_hand)
		// else
			// H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/marine(H.back), slot_in_backpack)
		return 1 */
		
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
		switch(H.backbag)
			// if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/pj/red(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/slippers(H), slot_shoes)
		// H.equip_to_slot_or_del(new /obj/item/device/radio/marine(H), slot_l_store)
		// if(H.backbag == 1)
			// H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/marine(H), slot_r_hand)
		// else
			// H.equip_to_slot_or_del(new /obj/item/weapon/storage/box/marine(H.back), slot_in_backpack)
		return 1
