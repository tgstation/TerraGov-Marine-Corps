/datum/job/vsd_squad
	job_category =  JOB_CAT_VSD
	supervisors = "Kaizoku Corporation high command."
	selection_color = "#ffeeee"
	faction = FACTION_VSD
	minimap_icon = "pmc2"

/datum/job/vsd_squad/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You are trained loyal mercenaries of Kaizoku Corporation, though in company rumors are Kaizoku is backed by Yakuza Syndicate which nuked the Corporate Sector. Surely it is unbased else it would be disasterous.
Kaizoku is in the corporate council that leads Phantom City, or what's left of it for now. Therefore it shares a table with Ninetails and all the other megacorps, which makes it vital they play along to ensure survival and prosperity of the corporation.
and at the same time Kaizoku is pressured into playing along with SOM by their said similiarly powerful shareholder, Keep in mind your situation when choosing who to support when it is time, with enough justification you can get around accusations."}

//VSD Standard
/datum/job/vsd_squad/standard
	title = "KZ Standard"
	paygrade = "KZ1"
	comm_title = "JSGT"
	skills_type = /datum/skills/crafty
	access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_CARGO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	minimal_access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_CARGO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/vsd_squad/standard
	name = "KZ Standard"
	jobtype = /datum/job/vsd_squad/standard

	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/mainship/vsd

//VSD Engineer
/datum/job/vsd_squad/engineer
	title = "KZ Engineer"
	paygrade = "KZ3"
	comm_title = "SGM"
	skills_type = /datum/skills/combat_engineer
	access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_CARGO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	minimal_access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_CARGO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
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
	name = "KZ Engineer"
	jobtype = /datum/job/vsd_squad/engineer

	id = /obj/item/card/id/dogtag/engineer
	ears = /obj/item/radio/headset/mainship/vsd
	glasses = /obj/item/clothing/glasses/meson

//VSD Medic
/datum/job/vsd_squad/medic
	title = "KZ Medic"
	paygrade = "KZ2"
	comm_title = "SSGT"
	skills_type = /datum/skills/combat_medic
	access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_CARGO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	minimal_access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_CARGO, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
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
	name = "KZ Medic"
	jobtype = /datum/job/vsd/medic

	id = /obj/item/card/id/dogtag/corpsman
	ears = /obj/item/radio/headset/mainship/vsd

//VSD Spec
/datum/job/vsd_squad/spec
	title = "KZ Specialist"
	paygrade = "KZ4"
	comm_title = "LT"
	skills_type = /datum/skills/specialist
	access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_SPECPREP, ACCESS_VSD_LEADPREP, ACCESS_VSD_CARGO, ACCESS_VSD_TADPOLE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	minimal_access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_SPECPREP, ACCESS_VSD_LEADPREP, ACCESS_VSD_CARGO, ACCESS_VSD_TADPOLE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/spec
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/vsd_squad/spec
	name = "KZ Specialist"
	jobtype = /datum/job/vsd_squad/spec

	id = /obj/item/card/id/dogtag/specialist
	ears = /obj/item/radio/headset/mainship/vsd

//VSD Squad Leader
/datum/job/vsd_squad/leader
	title = "KZ Squad Leader"
	paygrade = "KZ5"
	comm_title = "COLGEN"
	skills_type = /datum/skills/sl
	access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_LEADPREP, ACCESS_VSD_CARGO, ACCESS_VSD_TADPOLE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	minimal_access = list (ACCESS_VSD_PREP, ACCESS_VSD_MEDPREP, ACCESS_VSD_ENGPREP, ACCESS_VSD_LEADPREP, ACCESS_VSD_CARGO, ACCESS_VSD_TADPOLE, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_SOM_MEDICAL)
	display_order = JOB_DISPLAY_ORDER_SQUAD_MARINE
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/vsd_squad/leader
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/som/squad/veteran = VETERAN_POINTS_REGULAR,
	)

/datum/outfit/job/vsd_squad/leader
	name = "KZ Squad Leader"
	jobtype = /datum/job/vsd_squad/leader

	id = /obj/item/card/id/dogtag/leader
	ears = /obj/item/radio/headset/mainship/vsd


