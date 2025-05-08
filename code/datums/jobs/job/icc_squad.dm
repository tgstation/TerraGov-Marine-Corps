/datum/job/icc_squad
	job_category =  JOB_CAT_UNASSIGNED
	supervisors = "ICC high command"
	selection_color = "#ffeeee"
	faction = FACTION_ICC
	minimap_icon = "icc"

/datum/job/icc_squad/radio_help_message(mob/M)
	. = ..()
	to_chat(M, "You're a part of a militia group known as the "+ FACTION_ICC + ". Your goal is protect colonists and ward off xenomorphs. NTC may interfere with your operations, let them, until it is immoral.")

//ICC Standard
/datum/job/icc_squad/standard
	title = "ICC Standard"
	paygrade = "ICC1"
	comm_title = "ICC"
	skills_type = /datum/skills/crafty
	access = list(ACCESS_ICC_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
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
	jobtype = /datum/job/icc_squad/standard

	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/mainship/marine/icc

//ICC Medic
/datum/job/icc_squad/medic
	title = "ICC Medic"
	paygrade = "ICC2"
	comm_title = "ICC"
	skills_type = /datum/skills/combat_medic/crafty
	access = list(ACCESS_ICC_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY)
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
	jobtype = /datum/job/icc_squad/medic

	id = /obj/item/card/id/dogtag/corpsman
	ears = /obj/item/radio/headset/mainship/marine/icc

//ICC Spec
/datum/job/icc_squad/spec
	title = "ICC Guardsman"
	paygrade = "ICC3"
	comm_title = "ICC"
	skills_type = /datum/skills/specialist
	access = list(ACCESS_ICC_GUARDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
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
	jobtype = /datum/job/icc_squad/spec

	id = /obj/item/card/id/dogtag/specialist
	ears = /obj/item/radio/headset/mainship/marine/icc

//ICC Squad Leader
/datum/job/icc_squad/leader
	title = "ICC Squad Leader"
	paygrade = "ICC4"
	comm_title = "ICC"
	skills_type = /datum/skills/sl/icc
	access = list(ACCESS_ICC_LEADPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG)
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
	jobtype = /datum/job/icc_squad/leader

	id = /obj/item/card/id/dogtag/leader
	ears = /obj/item/radio/headset/mainship/marine/icc
	glasses = /obj/item/clothing/glasses/hud/health


