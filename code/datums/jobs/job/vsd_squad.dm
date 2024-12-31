/datum/job/vsd_squad
	job_category =  JOB_CAT_VSD
	supervisors = "SoM command and V.S.D command"
	selection_color = "#ffeeee"
	faction = FACTION_SOM
	minimap_icon = "pmc2"

/datum/job/vsd_squad/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"You're a part of an old PMC group which calls themselves the 'Vyacheslav Security Detail'. Your tasking is to follow SoM command, no excuse. Some circumstances may
	change this. Good luck."})

//VSD Standard
/datum/job/vsd_squad/standard
	title = "VSD Standard"
	paygrade = "VSD1"
	comm_title = "JSGT"
	skills_type = /datum/skills/crafty
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/vsd_squad/standard
	name = "VSD Standard"
	jobtype = /datum/job/vsd_squad/standard

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som

//VSD Engineer
/datum/job/vsd_squad/engineer
	title = "VSD Engineer"
	paygrade = "VSD3"
	comm_title = "SGM"
	skills_type = /datum/skills/combat_engineer
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/engineer
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	minimap_icon = "pmc2"

/datum/outfit/job/vsd_squad/engineer
	name = "VSD Engineer"
	jobtype = /datum/job/vsd_squad/engineer

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	glasses = /obj/item/clothing/glasses/meson

//VSD Medic
/datum/job/vsd_squad/medic
	title = "VSD Medic"
	paygrade = "VSD2"
	comm_title = "SSGT"
	skills_type = /datum/skills/combat_medic/crafty
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/medic
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)
	minimap_icon = "pmc2"

/datum/outfit/job/vsd_squad/medic
	name = "VSD Medic"
	jobtype = /datum/job/vsd/medic

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/vsd
	gloves = /obj/item/clothing/gloves/marine/black
	shoes = /obj/item/clothing/shoes/marine/full
	belt = /obj/item/storage/belt/lifesaver/full/upp

//VSD Spec
/datum/job/vsd_squad/spec
	title = "VSD Specialist"
	paygrade = "VSD4"
	comm_title = "LT"
	skills_type = /datum/skills/specialist
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/spec
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/vsd_squad/spec
	name = "VSD Specialist"
	jobtype = /datum/job/vsd_squad/spec

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	glasses = /obj/item/clothing/glasses/night/vsd

//VSD Squad Leader
/datum/job/vsd_squad/leader
	title = "VSD Squad Leader"
	paygrade = "VSD5"
	comm_title = "COLGEN"
	skills_type = /datum/skills/sl
	access = list (ACCESS_SOM_DEFAULT, ALL_ANTAGONIST_ACCESS, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_SOM_MEDICAL, ACCESS_MARINE_CHEMISTRY)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/leader
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/vsd_squad/leader
	name = "VSD Squad Leader"
	jobtype = /datum/job/vsd_squad/leader

	id = /obj/item/card/id/dogtag/som
	ears = /obj/item/radio/headset/mainship/som
	glasses = /obj/item/clothing/glasses/night/vsd


