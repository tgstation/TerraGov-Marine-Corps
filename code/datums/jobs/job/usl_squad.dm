/datum/job/usl_squad
	job_category =  JOB_CAT_VSD
	supervisors = "USL command"
	selection_color = "#ffeeee"
	faction = FACTION_USL
	minimap_icon = "pmc2"

/datum/job/usl_squad/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You're a part of an old PMC group which calls themselves the 'Vyacheslav Security Detail'. Your tasking is to follow SoM command, no excuse. Some circumstances may change this. Good luck."}

//USL Standard
/datum/job/usl_squad/standard
	title = "USL Standard"
	paygrade = "UPP1"
	comm_title = "UGNR"
	skills_type = /datum/skills/crafty
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/usl_squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/usl_squad/standard
	name = "USL Standard"
	jobtype = /datum/job/vsd_squad/standard

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som

//USL Spec
/datum/job/usl_squad/spec
	title = "USL Specialist"
	paygrade = "UPP6"
	comm_title = "USSGT"
	skills_type = /datum/skills/specialist/upp
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/usl_squad/spec
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/usl_squad/spec
	name = "USL Specialist"
	jobtype = /datum/job/vsd_squad/spec

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som

//USL Squad Leader
/datum/job/usl_squad/leader
	title = "USL Squad Leader"
	paygrade = "UPP8"
	comm_title = "ULT"
	skills_type = /datum/skills/sl/upp
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/usl_squad/leader
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/usl_squad/leader
	name = "USL Squad Leader"
	jobtype = /datum/job/vsd_squad/leader

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	glasses = /obj/item/clothing/glasses/hud/health


