/datum/job/pmc/squad
	job_category =  JOB_CAT_PMC
	supervisors = "ArcherCorp management"
	selection_color = "#ffeeee"
	faction = FACTION_NANOTRASEN

/datum/job/pmc/squad/get_spawn_message_information(mob/M)
	. = ..()
	. += separator_hr("[span_role_header("<b>[title] Information</b>")]")
	. += {"You're elite commandos of ArcherCorp Asset protection team, You are here in behalf of ArcherCorp's interests so stay in touch with your representative and strengthen up through gaining points and trading with NTC or other friendly factions while keeping observation.
	You are only obligated to intervene if NTC ship or FOB is under attack as it risks the entire campaign and investments made until this point. Otherwise Archercorp sees no reason to waste any more in this operation. Archercorp does not mind acquiring some value from the fallen colonies, as said."}
	/*. += {"You're elite commandos of NTC's Nine Tailed Fox PMC, you always thought infiltrators and recons were not hands on enough so you joined as an enforcer, and outperformed your peers to become one of the elite, just before deathsquad.
	You are usually called when things seem dire and your equipment is a great cost to the corporation (so are you to train.)
	Make it worth the cost and earn you and your family's luxury living again."}*/

//PMC Standard
/datum/job/pmc/squad/standard
	title = PMC_STANDARD
	paygrade = "PMC1"
	comm_title = "ACAP"
	minimap_icon = "pmc"
	total_positions = -1
	skills_type = /datum/skills/pmc
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/pmc/squad/standard
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)

/datum/outfit/job/pmc/squad/standard
	name = "AC Standard"
	jobtype = /datum/job/pmc/squad/standard

	id = /obj/item/card/id/dogtag/standard
	ears = /obj/item/radio/headset/mainship/marine/pmc


//PMC medic
/datum/job/pmc/squad/medic
	title = PMC_MEDIC
	paygrade = "PMC2"
	comm_title = "ACAP"
	minimap_icon = "pmc"
	skills_type = /datum/skills/combat_medic/pmc
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/pmc/squad/medic
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)

/datum/outfit/job/pmc/squad/medic
	name = "AC Medic"
	jobtype = /datum/outfit/job/pmc/squad/medic

	id = /obj/item/card/id/dogtag/corpsman
	ears = /obj/item/radio/headset/mainship/marine/pmc
	glasses = /obj/item/clothing/glasses/hud/health

//PMC Engineer
/datum/job/pmc/squad/engineer
	title = PMC_ENGINEER
	paygrade = "PMC2"
	comm_title = "ACAP"
	minimap_icon = "pmc"
	skills_type = /datum/skills/combat_engineer/pmc
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/pmc/squad/engineer
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)

/datum/outfit/job/pmc/squad/engineer
	name = "AC Engineer"
	jobtype = /datum/outfit/job/pmc/squad/engineer

	id = /obj/item/card/id/dogtag/engineer
	ears = /obj/item/radio/headset/mainship/marine/pmc
	glasses = /obj/item/clothing/glasses/hud/health

//PMC Gunner
/datum/job/pmc/squad/gunner
	title = PMC_GUNNER
	paygrade = "PMC2"
	comm_title = "ACAP"
	minimap_icon = "pmc"
	skills_type = /datum/skills/smartgunner/pmc
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_SMARTPREP, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	total_positions = -1
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/pmc/squad/gunner
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)

/datum/outfit/job/pmc/squad/gunner
	name = "AC Gunner"
	jobtype = /datum/job/pmc/squad/gunner

	id = /obj/item/card/id/dogtag/smartgun
	ears = /obj/item/radio/headset/mainship/marine/pmc


//PMC Specialist
/datum/job/pmc/squad/sniper
	title = PMC_SNIPER
	paygrade = "PMC3"
	comm_title = "ACAP"
	minimap_icon = "pmc"
	total_positions = 3
	skills_type = /datum/skills/specialist/pmc
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_MEDPREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_ENGINEERING, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/pmc/squad/sniper
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)

/datum/outfit/job/pmc/squad/sniper
	name = "AC Specialist"
	jobtype = /datum/job/pmc/squad/sniper

	id = /obj/item/card/id/dogtag/specialist
	ears = /obj/item/radio/headset/mainship/marine/pmc
	glasses = /obj/item/clothing/glasses/hud/health


//PMC Leader
/datum/job/pmc/squad/leader
	title = PMC_LEADER
	paygrade = "PMC4"
	comm_title = "ACAP"
	minimap_icon = "pmc"
	access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	minimal_access = list(ACCESS_MARINE_PREP, ACCESS_MARINE_LEADER, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_CIVILIAN_ENGINEERING, ACCESS_MARINE_REMOTEBUILD, ACCESS_NT_PMC_MEDICAL, ACCESS_NT_PMC_COMMON)
	skills_type = /datum/skills/sl/pmc
	total_positions = 5
	job_flags = JOB_FLAG_LATEJOINABLE|JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST|JOB_FLAG_PROVIDES_SQUAD_HUD|JOB_FLAG_CAN_SEE_ORDERS|JOB_FLAG_OVERRIDELATEJOINSPAWN
	outfit = /datum/outfit/job/pmc/squad/leader
	jobworth = list(
		/datum/job/xenomorph = LARVA_POINTS_REGULAR,
		/datum/job/terragov/squad/smartgunner = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/corpsman = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/squad/engineer = SMARTIE_POINTS_REGULAR,
		/datum/job/terragov/silicon/synthetic = SYNTH_POINTS_REGULAR,
		/datum/job/terragov/command/mech_pilot = MECH_POINTS_REGULAR,
	)

/datum/outfit/job/pmc/squad/leader
	name = "AC Leader"
	jobtype = /datum/job/pmc/squad/leader

	id = /obj/item/card/id/dogtag/leader
	ears = /obj/item/radio/headset/mainship/marine/pmc
	glasses = /obj/item/clothing/glasses/hud/health
