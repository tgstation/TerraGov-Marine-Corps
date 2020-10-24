// jobs for WC

//UNSC

/datum/job/unsc/marine/
	selection_color = "#57994e"
	job_category = JOB_CAT_UNSC

/datum/job/unsc/marine/basic
	title = "UNSC Marine"
	paygrade = "E2"
	comm_title = "Mar"
	access = list(ACCESS_UNSC_MARINE)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_MARINE_DROPSHIP)
	faction = FACTION_UNSC
	max_positions = -1 //infinite
	supervisors = "squad leader"
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
	access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_MEDIC, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_MEDIC, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY)
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
	access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_ENGINEER, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ENGINEERING)
	minimal_access = list(ACCESS_UNSC_MARINE, ACCESS_UNSC_ENGINEER, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGPREP, ACCESS_MARINE_ENGINEERING)
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
	jobtype = /datum/job/unsc/marine/basic
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
	selection_color = "#ff5757"
	job_category = JOB_CAT_INSURRECTION

/datum/job/insurrectionist/basic
	title = "Insurrectionist Fighter"
	paygrade = "INS"
	comm_title = "Ins"
	access = list(ACCESS_INSURRECTIONIST_SOLDIER)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER)
	faction = FACTION_INSURRECTION
	max_positions = -1 //infinite
	supervisors = "squad leader"
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
	access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_MEDIC)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_MEDIC)
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
	access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_ENGINEER)
	minimal_access = list(ACCESS_INSURRECTIONIST_SOLDIER, ACCESS_INSURRECTIONIST_ENGINEER)
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
	jobtype = /datum/job/insurrectionist/basic
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

//Covenant

/datum/job/covenant
	selection_color = "#944FBD"
	job_category = JOB_CAT_COVENANT
	faction = FACTION_COVENANT

/datum/job/covenant/sangheili/

/datum/job/covenant/sangheili/return_spawn_type(datum/preferences/prefs)
	if(prefs && prefs.species == "Sangheili")
		return /mob/living/carbon/human/species/covenant/sangheili


/datum/job/covenant/sangheili/radio_help_message(mob/M)
	. = ..()
	to_chat(M, {"\nYou are a Sangheili enlisted in the Covenant. You enforce the prophet's will and act as their hand throughout the galaxy."})


/datum/job/covenant/sangheili/minor
	title = "Sangheili Minor"
	paygrade = "MINOR"
	comm_title = "Sangheili Minor"
	access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGMINOR, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGMINOR, ACCESS_MARINE_DROPSHIP)
	max_positions = -1 //infinite
	supervisors = "Sangheili Officer, Sangheili Ultra, Sangheili General"
	outfit = /datum/outfit/job/covenant/sangheili/minor
	display_order = JOB_DISPLAY_ORDER_COVENANT_SANG_MINOR
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD


/datum/job/covenant/sangheili/ranger
	title = "Sangheili Ranger"
	paygrade = "RANGER"
	comm_title = "Sangheili Ranger"
	access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGRANGER, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGRANGER, ACCESS_MARINE_DROPSHIP)//might cause troubles in the future, making this have access_covenant
	max_positions = -1
	supervisors = "Sangheili Officer, Sangheili Ultra, Sangheili General"
	outfit = /datum/outfit/job/covenant/sangheili/ranger
	display_order = JOB_DISPLAY_ORDER_COVENANT_SANG_RANGER
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD


/datum/job/covenant/sangheili/officer
	title = "Sangheili Officer"
	paygrade = "OFFICER"
	comm_title = "Sangheili Officer"
	access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGOFFICER, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_COVENANT,ACCESS_COVENANT_SANGOFFICER, ACCESS_MARINE_DROPSHIP)
	max_positions = -1
	supervisors = "Sangheili Ultra, Sangheili General"
	display_order = JOB_DISPLAY_ORDER_COVENANT_SANG_OFFICER
	outfit = /datum/outfit/job/covenant/sangheili/officer
	skills_type = /datum/skills/SL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD


/datum/job/covenant/sangheili/specops
	title = "Special Operations Sangheili"
	paygrade = "SPECOPS"
	comm_title = "Sangheili Ranger"
	access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGSPEC, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGSPEC, ACCESS_MARINE_DROPSHIP)
	max_positions = -1
	supervisors = "Sangheili Ultra, Sangheili General"
	outfit = /datum/outfit/job/covenant/sangheili/specops
	display_order = JOB_DISPLAY_ORDER_COVENANT_SANG_SPECOPS
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD

/datum/job/covenant/sangheili/ultra
	title = "Sangheili Ultra"
	paygrade = "ULTRA"
	comm_title = "Sangheili Ultra"
	access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGULTRA, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGULTRA, ACCESS_MARINE_DROPSHIP)
	max_positions = 1
	supervisors = "Sangheili General"
	display_order = JOB_DISPLAY_ORDER_COVENANT_SANG_ULTRA
	outfit = /datum/outfit/job/covenant/sangheili/ultra
	skills_type = /datum/skills/SL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD

/datum/job/covenant/sangheili/general
	title = "Sangheili General"
	paygrade = "GENERAL"
	comm_title = "Sangheili General"
	access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGGENERAL, ACCESS_MARINE_DROPSHIP)
	minimal_access = list(ACCESS_COVENANT, ACCESS_COVENANT_SANGGENERAL, ACCESS_MARINE_DROPSHIP)
	max_positions = -1
	supervisors = ""
	display_order = JOB_DISPLAY_ORDER_COVENANT_SANG_GENERAL
	outfit = /datum/outfit/job/covenant/sangheili/general
	skills_type = /datum/skills/SL
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_BOLD_NAME_ON_SELECTION|JOB_FLAG_PROVIDES_SQUAD_HUD




/datum/outfit/job/covenant/sangheili/minor
	name = "Sangheili Minor"
	jobtype = /datum/job/covenant/sangheili/minor
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/covenant/sangheili/ranger
	name = "Sangheili Ranger"
	jobtype = /datum/job/covenant/sangheili/ranger
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/covenant/sangheili/officer
	name = "Sangheili Officer"
	jobtype = /datum/job/covenant/sangheili/officer
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/covenant/sangheili/specops
	name = "Sangheili Special Operations"
	jobtype = /datum/job/covenant/sangheili/specops
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/covenant/sangheili/ultra
	name = "Sangheili Ultra"
	jobtype = /datum/job/covenant/sangheili/ultra
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/job/covenant/sangheili/general
	name = "Sangheili General"
	jobtype = /datum/job/covenant/sangheili/general
	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/unsc
	back = /obj/item/storage/backpack/marine/satchel

//GCPD

/datum/job/gcpd/chief
	title = "Colonial Police Chief"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	display_order = JOB_DISPLAY_ORDER_GCPD_CHIEF
	skills_type = /datum/skills/civilian/survivor/gcpd
	faction = FACTION_GCPD
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_PROVIDES_BANK_ACCOUNT
	outfit = /datum/outfit/job/gcpd/chief


/datum/job/gcpd/cop
	title = "Colonial Police Officer"
	access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	minimal_access = list(ACCESS_CIVILIAN_PUBLIC, ACCESS_CIVILIAN_RESEARCH, ACCESS_CIVILIAN_ENGINEERING, ACCESS_CIVILIAN_LOGISTICS)
	display_order = JOB_DISPLAY_ORDER_GCPD_CHIEF
	skills_type = /datum/skills/civilian/survivor/gcpd
	faction = FACTION_GCPD
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_PROVIDES_BANK_ACCOUNT
	outfit = /datum/outfit/job/gcpd/cop

/datum/outfit/job/gcpd/cop
	name = "Colonial Police Officer"
	jobtype = /datum/job/gcpd/cop

	w_uniform = /obj/item/clothing/under/marine/gcpd
	wear_suit = /obj/item/clothing/suit/storage/marine/gcpd
	glasses = /obj/item/clothing/glasses/hud/security/gcpd
	ears = /obj/item/radio/headset/gcpd
	shoes = /obj/item/clothing/shoes/marine/gcpd
	head = /obj/item/clothing/head/tgmccap/gcpd
	back = /obj/item/storage/backpack/satchel/sec

/datum/outfit/job/gcpd/chief
	name = "Colonial Police Chief"
	jobtype = /datum/job/gcpd/chief

	w_uniform = /obj/item/clothing/under/marine/gcpd
	wear_suit = /obj/item/clothing/suit/storage/marine/gcpd_h
	glasses = /obj/item/clothing/glasses/hud/security/gcpd
	ears = /obj/item/radio/headset/gcpd
	shoes = /obj/item/clothing/shoes/marine/gcpd
	head = /obj/item/clothing/head/helmet/marine/gcpd
	back = /obj/item/storage/backpack/satchel/sec
