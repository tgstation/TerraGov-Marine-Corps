		
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
	department_flag = CIVILIAN
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
