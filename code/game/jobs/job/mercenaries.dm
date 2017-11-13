/datum/job/mercenaries
	special_role = "Mercenary"
	comm_title = "Merc"
	faction = "Unknown Mercenary Group"
	skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)

//Mercenary Heavy
/datum/job/mercenaries/heavy
	title = "Mercenary Enforcer"
	total_positions = 0
	spawn_positions = 0
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_CORPORATE)
	skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

//Mercenary Engineer
/datum/job/mercenaries/engineer
	title = "Mercenary Engineer"
	total_positions = 0
	spawn_positions = 0
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_CORPORATE)
	skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT

//Mercenary Worker
/datum/job/mercenaries/worker
	title = "Mercenary Worker"
	total_positions = 0
	spawn_positions = 0
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_CORPORATE)
	skills_list = list("cqc"=3,"endurance"=0,"engineer"=SKILL_ENGINEER_ENGI,"firearms"=SKILL_FIREARMS_TRAINED,"smartgun"=SKILL_SMART_DEFAULT,"heavy_weapons"=SKILL_HEAVY_DEFAULT,"leadership"=SKILL_LEAD_BEGINNER,"medical"=SKILL_MEDICAL_CHEM,"melee_weapons"=SKILL_MELEE_TRAINED,"pilot"=SKILL_PILOT_NONE,"pistols"=SKILL_PISTOLS_TRAINED,"police"=SKILL_POLICE_DEFAULT,"powerloader"=SKILL_POWERLOADER_DEFAULT)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT