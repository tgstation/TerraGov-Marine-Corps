
//Marine jobs. All marines are genericized when they first log in, then it auto assigns them to squads.

/datum/job/squadleader
	title = "Squad Leader"
	flag = SQUADLE
	department_flag = MARINES
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	is_squad_job = 1
	supervisors = "the commander"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_engprep, access_marine_medprep, access_marine_specprep, access_marine_leader)
	minimal_access = list(access_marine_prep, access_marine_engprep, access_marine_medprep, access_marine_specprep, access_marine_leader)
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

/datum/job/squadengineer
	title = "Squad Engineer"
	flag = SQUADEN
	department_flag = MARINES
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	is_squad_job = 1
	supervisors = "the squad leader"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_engprep)
	minimal_access = list(access_marine_prep, access_marine_engprep)
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

/datum/job/squadmedic
	title = "Squad Medic"
	flag = SQUADME
	department_flag = MARINES
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	is_squad_job = 1
	supervisors = "the squad leader"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_medprep)
	minimal_access = list(access_marine_prep, access_marine_medprep)
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

/datum/job/squadspecial
	title = "Squad Specialist"
	flag = SQUADSP
	department_flag = MARINES
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	is_squad_job = 1
	supervisors = "the squad leader"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_specprep)
	minimal_access = list(access_marine_prep, access_marine_specprep)
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

/datum/job/squadmarine
	title = "Squad Marine"
	flag = SQUADMA
	department_flag = MARINES
	faction = "Station"
	total_positions = -1
	spawn_positions = -1
	is_squad_job = 1
	supervisors = "the squad leader"
	selection_color = "#ffeeee"
	access = list(access_marine_prep)
	minimal_access = list(access_marine_prep)
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