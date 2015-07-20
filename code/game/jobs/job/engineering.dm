//Sulaco Chief Engineer
/datum/job/sul_ce
	title = "Chief Engineer"
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
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/E(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/device/pda/heads/ce(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		//H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat/white(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/marine(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
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
	flag = SULENG
	department_flag = ENGI
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	supervisors = "the Sulaco Chief Engineer, the Commander"
	selection_color = "#fff5cc"
	access = list(access_sulaco_engineering)
	minimal_access = list(access_sulaco_engineering)
	minimal_player_age = 0
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		switch(H.backbag)
			if(2) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
			if(3) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
			if(4) H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(H), slot_back)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/officer/E(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/white(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/belt/utility/full(H), slot_belt)
		//H.equip_to_slot_or_del(new /obj/item/clothing/head/hardhat(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/device/t_scanner(H), slot_r_store)
		H.equip_to_slot_or_del(new /obj/item/device/pda/engineering(H), slot_l_store)
		H.equip_to_slot_or_del(new /obj/item/device/radio/headset/headset_eng(H), slot_l_ear)
		H.equip_to_slot_or_del(new /obj/item/clothing/gloves/yellow(H), slot_gloves)
		spawn(10)
			H << "You are a Sulaco maintenance technician!"
			H << "Your boss is the Chief Engineer. Follow his or her orders!"
			H << "Your first priority is to make sure the Supermatter engine is running smoothly."
			H << "Don't fuck up!"
		return 1