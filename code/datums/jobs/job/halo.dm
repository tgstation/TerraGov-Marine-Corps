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
	skills_type = /datum/skills/SL
	display_order = JOB_DISPLAY_ORDER_UNSC_MARINE
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD



/datum/job/unsc/marine/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a marine in the esteemed United Nations Space Command. You enforce peace across the galaxy."})


/datum/job/unsc/marine/leader
	title = "UNSC Squad Leader"
	paygrade = "E6"
	comm_title = "SL"
	access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_LEADER)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_LEADER, ACCESS_MARINE_DROPSHIP)
	max_positions = 2 // 2 squads for the first test
	supervisors = "commanding officer"
	display_order = JOB_DISPLAY_ORDER_UNSC_LEADER
	outfit = /datum/outfit/job/unsc/leader
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD


/datum/job/unsc/marine/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are an NCO in the UNSC, charged with leading a squad of marines. Keep your unit cohesive, and make sure everyone escapes with their lives."})


/datum/outfit/job/unsc
	name = "UNSC Marine"
	jobtype = /datum/job/unsc/marine
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc





/datum/outfit/job/unsc/leader
	name = "UNSC Squad Leader"
	jobtype = /datum/job/unsc/marine/leader
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc

//Innies

/datum/job/insurrectionist
	title = "Insurrectionist"
	paygrade = "INS"
	comm_title = "Ins"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER)
	faction = FACTION_INSURRECTION
	max_positions = -1 //infinite
	supervisors = "squad leader"
	selection_color = "#ff5757"
	job_category = JOB_CAT_INSURRECTION
	outfit = /datum/outfit/job/unsc
	skills_type = /datum/skills/SL //so everyone can use meds and tools
	outfit = /datum/outfit/job/insurrection
	display_order = JOB_DISPLAY_ORDER_INSURRECTIONIST
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST


/datum/job/insurrectionist/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are an insurrectionist, fighting the tyranny of the UNSC. Avenge Far Isle."})



/datum/job/insurrectionist/leader
	title = "Insurrectionist Squad Leader"
	paygrade = "INSL"
	comm_title = "InsL"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_LEADER)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_LEADER, ACCESS_MARINE_DROPSHIP)
	max_positions = 2 // 2 squads for the first test
	supervisors = ""
	display_order = JOB_DISPLAY_ORDER_INSURRECTIONIST_LEADER
	outfit = /datum/outfit/job/insurrection/leader
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION



/datum/job/insurrectionist/leader/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are an insurrectionist leader. Lead your squad against the UNSC, and maintain unit cohesion."})

//outfits

/datum/outfit/job/insurrection
	name = "Insurrectionist"
	jobtype = /datum/job/insurrectionist
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/innie

/datum/outfit/job/insurrection/leader
	name = "Insurrection Squad Leader"
	jobtype = /datum/job/insurrectionist/leader
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/innie
