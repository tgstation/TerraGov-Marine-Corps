//Chief Engineer
/datum/job/sul_ce
	title = "Chief Engineer"
	comm_title = "CE"
	flag = SULCE
	department_flag = ENGI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander"
	selection_color = "#ffeeaa"
	idtype = /obj/item/weapon/card/id/silver
	access = list(access_sulaco_CE, access_sulaco_engineering, access_sulaco_bridge)
	minimal_access = list(access_sulaco_CE, access_sulaco_engineering, access_sulaco_bridge)
	minimal_player_age = 3
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/ce(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/pda/heads/ce(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		//H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		spawn(10)
			H << "\red You are the Chief Engineer!"
			H << "Your job is to maintain the USS Sulaco and ensure things don't explode."
			H << "Your primary goal is to maintain the Supermatter engine."
			H << "The Engine is just about already set up, see the forums for a guide on what to do or ask an admin."
		return 1

//Maintenance Tech
/datum/job/sul_eng
	title = "Maintenance Tech"
	comm_title = "MT"
	flag = SULENG
	department_flag = ENGI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Chief Engineer, the Commander"
	selection_color = "#fff5cc"
	access = list(access_sulaco_engineering)
	minimal_access = list(access_sulaco_engineering)
	minimal_player_age = 0
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/industrial(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_eng(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/engi(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/brown(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/device/t_scanner(H), slot_r_store)
		H.equip_to_slot_or_del(new /obj/item/device/pda/engineering(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
		//H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves) There are plenty in lockers
		spawn(10)
			H << "You are a Sulaco maintenance technician!"
			H << "Your boss is the Chief Engineer. Follow his or her orders!"
			H << "Your first priority is to make sure the Supermatter engine is running smoothly."
			H << "Don't fuck up!"
		return 1

//Requisitions Officer
/datum/job/req_officer
	title = "Requisitions Officer"
	comm_title = "RO"
	flag = REQUI
	department_flag = COMMAND
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Commander, the Executive Officer"
	selection_color = "#9990B2"
	access = list(access_sulaco_cargo, access_sulaco_bridge)
	minimal_access = list(access_sulaco_cargo, access_sulaco_bridge)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/mcom(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/ro_suit(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/marine/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmcap/req(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marinesatchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
		//H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/RO(H), slot_wear_suit)

		H.implant_loyalty(src)
		spawn(10)
			H << "\red You are the Requisitions Officer!"
			H << "Your job is to dispense basic weapon attachments and extra supplies."
			H << "Commanders and Executive Officers have full access to the vendor."
			H << "You don't have to stay in your department all the time, but you should go if someone needs something."
			H << "You also have supply pads west of Requisitions. Overwatch might want crates put there for delivery."
		return 1

//Cargo Tech. Don't ask why this is in engineering
/datum/job/sul_cargo
	title = "Cargo Technician"
	comm_title = "CT"
	flag = SULCARG
	department_flag = ENGI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Requisitions Officer, the Commander"
	selection_color = "#BAAFD9"
	access = list(access_sulaco_cargo)
	minimal_access = list(access_sulaco_cargo)
	minimal_player_age = 0
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marinesatchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/rank/cargotech(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/marine(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_cargo(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/cmbandana/tan(H), slot_head)

		spawn(10)
			H << "You are a Sulaco cargo technician! AKA the delivery officer."
			H << "Your job is to help out the Requisitions Officer in dispensing goods and materials."
			H << "You should be respectful to your RO at all times, as they outrank you."
			H << "If your RO goes braindead you should take over."
			H << "You are also permitted to head to the planet to make deliveries if your RO approves."
			H << "Pay attention to the supply pads west of Requisition! Overwatch might want crates put there."
		return 1
