/datum/job/icc_squad
	job_category =  JOB_CAT_MARINESOM
	supervisors = "ICC high command"
	selection_color = "#ffeeee"
	faction = FACTION_SOM
	minimap_icon = "icc"

/datum/job/icc_squad/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"Your fleet was sent to this sector to aid and command the SoM in this area. You have access to the entire SoM station. Make sure none of the SoM act up, keep them in check."})

//VSD Standard
/datum/job/icc_squad/standard
	title = "ICC Standard"
	paygrade = "ICC1"
	comm_title = "ICC"
	skills_type = /datum/skills/crafty
	access = list (ACCESS_SOM_COMMAND, ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/standard
	name = "ICC Standard"
	jobtype = /datum/job/vsd_squad/standard

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som

//VSD Medic
/datum/job/icc_squad/medic
	title = "ICC Medic"
	paygrade = "ICC2"
	comm_title = "ICC"
	skills_type = /datum/skills/combat_medic/crafty
	access = list (ACCESS_SOM_COMMAND, ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/medic
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/medic
	name = "ICC Medic"
	jobtype = /datum/job/vsd/medic

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/icc
	gloves = /obj/item/clothing/gloves/marine/icc
	shoes = /obj/item/clothing/shoes/marine/icc/knife
	back = /obj/item/storage/backpack/lightpack/icc
	belt = /obj/item/storage/belt/lifesaver/icc/ert
	glasses = /obj/item/clothing/glasses/hud/health

//VSD Spec
/datum/job/icc_squad/spec
	title = "ICC Guardsman"
	paygrade = "ICC3"
	comm_title = "ICC"
	skills_type = /datum/skills/specialist
	access = list (ACCESS_SOM_COMMAND, ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/spec
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/spec
	name = "ICC Specialist"
	jobtype = /datum/job/vsd_squad/spec

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som

//VSD Squad Leader
/datum/job/icc_squad/leader
	title = "ICC Squad Leader"
	paygrade = "ICC4"
	comm_title = "ICC"
	skills_type = /datum/skills/sl
	access = list (ACCESS_SOM_COMMAND, ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/leader
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/leader
	name = "ICC Squad Leader"
	jobtype = /datum/job/vsd_squad/leader

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	glasses = /obj/item/clothing/glasses/hud/health


