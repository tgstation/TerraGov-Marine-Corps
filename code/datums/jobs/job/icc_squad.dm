/datum/job/icc_squad
	job_category =  JOB_CAT_UNASSIGNED
	supervisors = "CM high command"
	selection_color = "#ffeeee"
	faction = FACTION_ICC
	minimap_icon = "icc"

/datum/job/icc_squad/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You are part of the colonial militia that formed shortly after Xenomorph invasion,
after ransacking the armories of the colonies owned by NTC, you took arms to fight against the Xenomorph assault.
Though soon they turned less lethal, danger still persists, especially those that are alone, namely survivors. Which is your job to protect now.
You are all former or current employees/colonists of Ninetails but there is still some tensions after what happened.
For that CM is closer to NTC than the rest, and believes SOM and Kaizoku to be vultures on top of a stillborn colonization"})

//ICC Standard
/datum/job/icc_squad/standard
	title = "CM Standard"
	paygrade = "CM1"
	comm_title = "CM"
	skills_type = /datum/skills/crafty
	access = list(ACCESS_ICC_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG, ACCESS_ICC_CARGO, ACCESS_ICC_TADPOLE)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/standard
	name = "CM Standard"
	jobtype = /datum/job/icc_squad/standard

	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/mainship/marine/icc

//ICC Medic
/datum/job/icc_squad/medic
	title = "CM Medic"
	paygrade = "CM2"
	comm_title = "CM"
	skills_type = /datum/skills/combat_medic/crafty
	access = list(ACCESS_ICC_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_ICC_CARGO, ACCESS_ICC_TADPOLE)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/medic
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/medic
	name = "CM Medic"
	jobtype = /datum/job/icc_squad/medic

	id = /obj/item/card/id/dogtag/corpsman
	ears = /obj/item/radio/headset/mainship/marine/icc

//ICC Spec
/datum/job/icc_squad/spec
	title = "CM Guardsman"
	paygrade = "CM3"
	comm_title = "CM"
	skills_type = /datum/skills/specialist
	access = list(ACCESS_ICC_GUARDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG, ACCESS_ICC_CARGO, ACCESS_ICC_TADPOLE)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/spec
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/spec
	name = "CM Specialist"
	jobtype = /datum/job/icc_squad/spec

	id = /obj/item/card/id/dogtag/specialist
	ears = /obj/item/radio/headset/mainship/marine/icc

//ICC Squad Leader
/datum/job/icc_squad/leader
	title = "CM Squad Leader"
	paygrade = "CM4"
	comm_title = "CM"
	skills_type = /datum/skills/sl/icc
	access = list(ACCESS_ICC_LEADPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS, ACCESS_MARINE_BRIG, ACCESS_ICC_CARGO, ACCESS_ICC_TADPOLE)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/icc_squad/leader
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/icc_squad/leader
	name = "CM Squad Leader"
	jobtype = /datum/job/icc_squad/leader

	id = /obj/item/card/id/dogtag/leader
	ears = /obj/item/radio/headset/mainship/marine/icc
	glasses = /obj/item/clothing/glasses/hud/health


