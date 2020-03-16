#define SSJOB_OVERRIDE_JOBS_START (1<<0)

#define JOB_DISPLAY_ORDER_DEFAULT 0

#define JOB_DISPLAY_ORDER_XENO_QUEEN			1
#define JOB_DISPLAY_ORDER_XENOMORPH				2
#define JOB_DISPLAY_ORDER_CAPTAIN				3
#define JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER		4
#define JOB_DISPLAY_ORDER_STAFF_OFFICER			5
#define JOB_DISPLAY_ORDER_PILOT_OFFICER			6
#define JOB_DISPLAY_ORDER_TANK_CREWMAN			7
#define JOB_DISPLAY_ORDER_CORPORATE_LIAISON		8
#define JOB_DISPLAY_ORDER_SYNTHETIC				9
#define JOB_DISPLAY_ORDER_AI					10
#define JOB_DISPLAY_ORDER_CHIEF_MP				11
#define JOB_DISPLAY_ORDER_MILITARY_POLICE		12
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER		13
#define JOB_DISPLAY_ORDER_SHIP_TECH				14
#define JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER	15
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER	16
#define JOB_DISPLAY_ORDER_DOCTOR				17
#define JOB_DISPLAY_ORDER_MEDIAL_RESEARCHER		18
#define JOB_DISPLAY_ORDER_SQUAD_LEADER			19
#define JOB_DISPLAY_ORDER_SQUAD_SPECIALIST		20
#define JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER		21
#define JOB_DISPLAY_ORDER_SQUAD_CORPSMAN		22
#define JOB_DISPLAY_ORDER_SUQAD_ENGINEER		23
#define JOB_DISPLAY_ORDER_SQUAD_MARINE			24
#define JOB_DISPLAY_ORDER_SURVIVOR				25

#define JOB_FLAG_SPECIALNAME (1<<0)
#define JOB_FLAG_LATEJOINABLE (1<<1) //Can this job be selected for prefs to join as?
#define JOB_FLAG_ROUNDSTARTJOINABLE (1<<2) //Joinable at roundstart
#define JOB_FLAG_NOHEADSET (1<<3) //Doesn't start with a headset on spawn.
#define JOB_FLAG_ALLOWS_PREFS_GEAR (1<<4) //Allows preference loadouts.
#define JOB_FLAG_PROVIDES_BANK_ACCOUNT (1<<5) //$$$
#define JOB_FLAG_OVERRIDELATEJOINSPAWN (1<<6) //AIs and xenos, for example.
#define JOB_FLAG_ADDTOMANIFEST (1<<7) //Add info to datacore.
#define JOB_FLAG_ISCOMMAND (1<<8)
#define JOB_FLAG_BOLD_NAME_ON_SELECTION (1<<9)
#define JOB_FLAG_PROVIDES_SQUAD_HUD (1<<10)
#define JOB_FLAG_HIDE_CURRENT_POSITIONS (1<<11) //You can't see how many people have joined as on the latejoin menu.

#define CAPTAIN "Captain"
#define EXECUTIVE_OFFICER "Executive Officer" //Currently disabled.
#define FIELD_COMMANDER "Field Commander"
#define STAFF_OFFICER "Staff Officer"
#define PILOT_OFFICER "Pilot Officer"
#define REQUISITIONS_OFFICER "Requisitions Officer"
#define CHIEF_SHIP_ENGINEER "Chief Ship Engineer"
#define CHIEF_MEDICAL_OFFICER "Chief Medical Officer"
#define COMMAND_MASTER_AT_ARMS "Command Master at Arms"
#define TANK_CREWMAN "Tank Crewman"
#define CORPORATE_LIAISON "Corporate Liaison"
#define SYNTHETIC "Synthetic"
#define MASTER_AT_ARMS "Master at Arms"
#define SHIP_TECH "Ship Technician"
#define MEDICAL_OFFICER "Medical Officer"
#define MEDICAL_RESEARCHER "Medical Researcher"
#define SQUAD_LEADER "Squad Leader"
#define SQUAD_SPECIALIST "Squad Specialist"
#define SQUAD_SMARTGUNNER "Squad Smartgunner"
#define SQUAD_CORPSMAN "Squad Corpsman"
#define SQUAD_ENGINEER "Squad Engineer"
#define SQUAD_MARINE "Squad Marine"
#define SILICON_AI "AI"

#define JOB_CAT_COMMAND "Command"
#define JOB_CAT_SILICON "Silicon"
#define JOB_CAT_REQUISITIONS "Requisitions"
#define JOB_CAT_POLICE "Police"
#define JOB_CAT_MEDICAL "Medical"
#define JOB_CAT_ENGINEERING "Engineering"
#define JOB_CAT_CIVILIAN "Civilian"
#define JOB_CAT_MARINE "Marine"
#define JOB_CAT_XENO "Xenomorph"
#define JOB_CAT_UNASSIGNED "Unassigned"

GLOBAL_LIST_EMPTY(jobs_command)
GLOBAL_LIST_INIT(jobs_police, list(COMMAND_MASTER_AT_ARMS, MASTER_AT_ARMS)) //TO DO: Turn all of these into associative lists generated dynamically, like jobs_command
GLOBAL_LIST_INIT(jobs_officers, list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, PILOT_OFFICER, TANK_CREWMAN, CORPORATE_LIAISON, SYNTHETIC, SILICON_AI))
GLOBAL_LIST_INIT(jobs_engineering, list(CHIEF_SHIP_ENGINEER, SHIP_TECH))
GLOBAL_LIST_INIT(jobs_requisitions, list(REQUISITIONS_OFFICER))
GLOBAL_LIST_INIT(jobs_medical, list(CHIEF_MEDICAL_OFFICER, MEDICAL_OFFICER, MEDICAL_RESEARCHER))
GLOBAL_LIST_INIT(jobs_marines, list(SQUAD_LEADER, SQUAD_SPECIALIST, SQUAD_SMARTGUNNER, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_MARINE))
GLOBAL_LIST_INIT(jobs_regular_all, list(CAPTAIN, FIELD_COMMANDER, STAFF_OFFICER, PILOT_OFFICER, REQUISITIONS_OFFICER, CHIEF_SHIP_ENGINEER, \
CHIEF_MEDICAL_OFFICER, SYNTHETIC, SILICON_AI, COMMAND_MASTER_AT_ARMS, MASTER_AT_ARMS, TANK_CREWMAN, CORPORATE_LIAISON, SHIP_TECH, \
MEDICAL_OFFICER, MEDICAL_RESEARCHER, SQUAD_LEADER, SQUAD_SPECIALIST, SQUAD_SMARTGUNNER, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_MARINE))


#define ROLE_XENOMORPH "Xenomorph"
#define ROLE_XENO_QUEEN "Xeno Queen"
#define ROLE_ERT "Emergency Response Team"


//Playtime tracking system, see jobs_exp.dm
#define EXP_TYPE_LIVING			"Living"
#define EXP_TYPE_REGULAR_ALL	"Any"
#define EXP_TYPE_COMMAND		"Command"
#define EXP_TYPE_ENGINEERING	"Engineering"
#define EXP_TYPE_MEDICAL		"Medical"
#define EXP_TYPE_MARINES		"Marines"
#define EXP_TYPE_REQUISITIONS	"Requisitions"
#define EXP_TYPE_POLICE			"Police"
#define EXP_TYPE_SILICON		"Silicon"
#define EXP_TYPE_SPECIAL		"Special"
#define EXP_TYPE_GHOST			"Ghost"
#define EXP_TYPE_ADMIN			"Admin"

// hypersleep bay flags
#define CRYO_MED		"Medical"
#define CRYO_SEC		"Security"
#define CRYO_ENGI		"Engineering"
#define CRYO_REQ		"Requisitions"
#define CRYO_ALPHA		"Alpha Squad"
#define CRYO_BRAVO		"Bravo Squad"
#define CRYO_CHARLIE	"Charlie Squad"
#define CRYO_DELTA		"Delta Squad"


#define XP_REQ_INTERMEDIATE 60
#define XP_REQ_EXPERIENCED 180

// how much a job is going to contribute towards burrowed larva. see config for points required to larva. old balance was 1 larva per 3 humans.
#define LARVA_POINTS_SHIPSIDE 1
#define LARVA_POINTS_SHIPSIDE_STRONG 2
#define LARVA_POINTS_REGULAR 3
#define LARVA_POINTS_STRONG 6

#define SURVIVOR_POINTS_REGULAR 1

#define SPEC_POINTS_REGULAR 1
#define SMARTIE_POINTS_REGULAR 1
#define SPEC_POINTS_MEDIUM 2
#define SMARTIE_POINTS_MEDIUM 2
#define SPEC_POINTS_HIGH 3
#define SMARTIE_POINTS_HIGH 3

#define SQUAD_MAX_POSITIONS(total_positions) CEILING(total_positions / length(SSjob.active_squads), 1)
