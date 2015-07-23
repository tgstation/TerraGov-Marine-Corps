
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
	access = list(access_marine_prep, access_marine_leader)
	minimal_access = list(access_marine_prep, access_marine_leader)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_underoos(H), slot_w_uniform)
		H.implant_loyalty(src)
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
	access = list(access_marine_prep, access_marine_engprep, access_sulaco_engineering)
	minimal_access = list(access_marine_prep, access_marine_engprep, access_sulaco_engineering)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_underoos(H), slot_w_uniform)
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
	access = list(access_marine_prep, access_marine_medprep, access_sulaco_medbay)
	minimal_access = list(access_marine_prep, access_marine_medprep, access_sulaco_medbay)
	minimal_player_age = 7
	equip(var/mob/living/carbon/human/H)
		if(!H)	return 0
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_underoos(H), slot_w_uniform)
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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_underoos(H), slot_w_uniform)
		H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/specrag(H), slot_head)
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
		H.equip_to_slot_or_del(new /obj/item/clothing/under/marine_underoos(H), slot_w_uniform)
		return 1