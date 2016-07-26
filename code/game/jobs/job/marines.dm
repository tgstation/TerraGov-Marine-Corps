
//Marine jobs. All marines are genericized when they first log in, then it auto assigns them to squads.

/datum/job/squadleader
	title = "Squad Leader"
	comm_title = "SL"
	paygrade = 7
	flag = SQUADLE
	department_flag = MARINES
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	is_squad_job = 1
	supervisors = "the commander"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_leader)
	minimal_access = list(access_marine_prep, access_marine_leader)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/underoos(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
		H.implant_loyalty(src)
		return 1

/datum/job/squadengineer
	title = "Squad Engineer"
	comm_title = "Eng"
	paygrade = 4
	flag = SQUADEN
	department_flag = MARINES
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	is_squad_job = 1
	supervisors = "the squad leader"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_engprep, access_sulaco_engineering)
	minimal_access = list(access_marine_prep, access_marine_engprep, access_sulaco_engineering)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/underoos(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/tech(H), slot_back)
		return 1

/datum/job/squadmedic
	title = "Squad Medic"
	comm_title = "Med"
	paygrade = 4
	flag = SQUADME
	department_flag = MARINES
	faction = "Station"
	total_positions = 8
	spawn_positions = 8
	is_squad_job = 1
	supervisors = "the squad leader"
	selection_color = "#ffeeee"
	access = list(access_marine_prep, access_marine_medprep, access_sulaco_medbay)
	minimal_access = list(access_marine_prep, access_marine_medprep, access_sulaco_medbay)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/underoos(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine/medic(H), slot_back)
		return 1

/datum/job/squadspecial
	title = "Squad Specialist"
	comm_title = "Spc"
	paygrade = 5
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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/underoos(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
		return 1

/datum/job/squadmarine
	title = "Squad Marine"
	comm_title = "Mar"
	paygrade = 2
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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine/underoos(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/marine(H), slot_back)
		return 1
