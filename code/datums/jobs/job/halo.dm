// jobs for WC

//UNSC

/datum/job/unsc/marine
	title = "UNSC Marine"
	paygrade = "E2"
	comm_title = "Mar"
	access = list(ACCESS_UNSC_MARINE)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_MARINE_DROPSHIP)
	faction = FACTION_UNSC
	max_positions = -1 //infinite
	supervisors = "squad leader"
	selection_color = "#57994e"
	job_category = JOB_CAT_UNSC
	outfit = /datum/outfit/job/unsc
	display_order = JOB_DISPLAY_ORDER_UNSC_MARINE
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD


/datum/job/unsc/marine/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a marine in the esteemed United Nations Space Command. You enforce order and maintain peace across the galaxy."})

/datum/job/unsc/marine/medic
	title = "UNSC Combat Medic"
	paygrade = "E3"
	comm_title = "Med"
	access = list(ACCESS_UNSC_MARINE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	max_positions = 6
	supervisors = "squad leader"
	outfit = /datum/outfit/job/unsc/medic
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_UNSC_MEDIC
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD

/datum/job/unsc/marine/medic/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nKeep your fellow marines combat ready and make sure your squad is functional."})


/datum/job/unsc/marine/engineer
	title = "UNSC Combat Engineer"
	paygrade = "E3"
	comm_title = "Engi"
	access = list(ACCESS_UNSC_MARINE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ENGINEERING)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ENGINEERING)
	max_positions = 6
	supervisors = "squad leader"
	outfit = /datum/outfit/job/unsc/engineer
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_UNSC_ENGINEER
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD

/datum/job/unsc/marine/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nSupport your squad with controlled demolitions and construct barricades to assist."})


/datum/job/unsc/marine/leader
	title = "UNSC Squad Leader"
	paygrade = "E6"
	comm_title = "SL"
	access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_LEADER)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_LEADER, ACCESS_MARINE_DROPSHIP)
	max_positions = 1
	supervisors = "commanding officer"
	display_order = JOB_DISPLAY_ORDER_UNSC_LEADER
	outfit = /datum/outfit/job/unsc/leader
	skills_type = /datum/skills/SL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD


/datum/job/unsc/marine/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are an NCO in the UNSC, charged with leading a squad of marines. Keep your unit cohesive, and make sure everyone escapes with their lives."})


/datum/outfit/job/unsc
	name = "UNSC Marine"
	jobtype = /datum/job/unsc/marine
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/unsc/medic
	name = "UNSC Combat Medic"
	jobtype = /datum/job/unsc/marine/medic
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/corpsman

/datum/outfit/job/unsc/engineer
	name = "UNSC Combat Engineer"
	jobtype = /datum/job/unsc/marine/engineer
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/engineerpack

/datum/outfit/job/unsc/leader
	name = "UNSC Squad Leader"
	jobtype = /datum/job/unsc/marine/leader
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

//Innies

/datum/job/insurrectionist
	title = "Insurrectionist Fighter"
	paygrade = "INS"
	comm_title = "Ins"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER)
	faction = FACTION_INSURRECTION
	max_positions = -1 //infinite
	supervisors = "squad leader"
	selection_color = "#ff5757"
	job_category = JOB_CAT_INSURRECTION
	outfit = /datum/outfit/job/insurrection
	display_order = JOB_DISPLAY_ORDER_INSURRECTIONIST
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST


/datum/job/insurrectionist/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are an insurrectionist, fighting the tyranny of the UNSC. Avenge Far Isle."})

/datum/job/insurrectionist/medic
	title = "Insurrectionist Bonesetter"
	paygrade = "INS"
	comm_title = "Med"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	max_positions = 6
	supervisors = "squad leader"
	outfit = /datum/outfit/job/insurrection/medic
	skills_type = /datum/skills/combat_medic
	display_order = JOB_DISPLAY_ORDER_INSURRECTIONIST_MEDIC
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST


/datum/job/insurrectionist/medic/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a well-respected insurrectionist bonesetter. Aid your brothers in combat and keep them fighting."})


/datum/job/insurrectionist/engineer
	title = "Insurrectionist Sapper"
	paygrade = "INS"
	comm_title = "Engi"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ENGINEERING)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ENGINEERING)
	max_positions = 6
	supervisors = "squad leader"
	outfit = /datum/outfit/job/insurrection/engineer
	skills_type = /datum/skills/combat_engineer
	display_order = JOB_DISPLAY_ORDER_INSURRECTIONIST_ENGINEER
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST

/datum/job/insurrectionist/engineer/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a crafty insurrectionist sapper. Help your brothers by using explosives and constructing barricades."})


/datum/job/insurrectionist/leader
	title = "Insurrectionist Warlord"
	paygrade = "INSL"
	comm_title = "Warlord"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_LEADER)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_LEADER, ACCESS_MARINE_DROPSHIP)
	max_positions = 1
	supervisors = ""
	display_order = JOB_DISPLAY_ORDER_INSURRECTIONIST_LEADER
	outfit = /datum/outfit/job/insurrection/leader
	skills_type = /datum/skills/SL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION


/datum/job/insurrectionist/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are an insurrectionist warlord. Lead your squad against the UNSC, and maintain unit cohesion."})

//outfits

/datum/outfit/job/insurrection
	name = "Insurrectionist"
	jobtype = /datum/job/insurrectionist
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/innie
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/insurrection/medic
	name = "Insurrectionist Bonesetter"
	jobtype = /datum/job/insurrectionist/medic
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/innie
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/insurrection/engineer
	name = "Insurrectionist Sapper"
	jobtype = /datum/job/insurrectionist/engineer
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/innie
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/insurrection/leader
	name = "Insurrectionist Warlord"
	jobtype = /datum/job/insurrectionist/leader
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/innie
	back = /obj/item/storage/backpack/lightpack
	l_hand = /obj/item/storage/bible/koran
