#define JOB_DISPLAY_ORDER_DEFAULT 0

#define JOB_DISPLAY_ORDER_CAPTAIN 1
#define JOB_DISPLAY_ORDER_EXECUTIVE_OFFICER 2
#define JOB_DISPLAY_ORDER_STAFF_OFFICER 3
#define JOB_DISPLAY_ORDER_PILOT_OFFICER 4
#define JOB_DISPLAY_ORDER_TANK_CREWMAN 5
#define JOB_DISPLAY_ORDER_CORPORATE_LIAISON 6
#define JOB_DISPLAY_ORDER_SYNTHETIC 7
#define JOB_DISPLAY_ORDER_CHIEF_MP 8
#define JOB_DISPLAY_ORDER_MILITARY_POLICE 9
#define JOB_DISPLAY_ORDER_CHIEF_ENGINEER 10
#define JOB_DISPLAY_ORDER_MAINTENANCE_TECH 11
#define JOB_DISPLAY_ORDER_REQUISITIONS_OFFICER 12
#define JOB_DISPLAY_ORDER_CARGO_TECH 13
#define JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER 14
#define JOB_DISPLAY_ORDER_DOCTOR 15
#define JOB_DISPLAY_ORDER_MEDIAL_RESEARCHER 16
#define JOB_DISPLAY_ORDER_SQUAD_LEADER 17
#define JOB_DISPLAY_ORDER_SQUAD_SPECIALIST 18
#define JOB_DISPLAY_ORDER_SQUAD_SMARTGUNNER 19
#define JOB_DISPLAY_ORDER_SQUAD_CORPSMAN 20
#define JOB_DISPLAY_ORDER_SUQAD_ENGINEER 21
#define JOB_DISPLAY_ORDER_SQUAD_MARINE 22


#define JOBS_COMMAND 		list("Captain", "Field Commander", "Intelligence Officer", "Pilot Officer", "Requisitions Officer", "Chief Ship Engineer", "Chief Medical Officer", "Synthetic", "Command Master at Arms")
#define JOBS_POLICE			list("Command Master at Arms", "Master at Arms")
#define JOBS_OFFICERS		list("Captain", "Field Commander", "Intelligence Officer", "Pilot Officer", "Tank Crewman", "Corporate Liaison", "Synthetic")
#define JOBS_ENGINEERING 	list("Chief Ship Engineer", "Ship Engineer")
#define JOBS_REQUISITIONS 	list("Requisitions Officer", "Cargo Technician")
#define JOBS_MEDICAL 		list("Chief Medical Officer", "Medical Officer", "Medical Researcher")
#define JOBS_MARINES		list("Squad Leader", "Squad Specialist", "Squad Smartgunner", "Squad Corpsman", "Squad Engineer", "Squad Marine")
#define JOBS_SQUADS			list("Alpha", "Bravo", "Charlie" ,"Delta")
#define JOBS_REGULAR_ALL	JOBS_OFFICERS + JOBS_POLICE + JOBS_ENGINEERING + JOBS_REQUISITIONS + JOBS_MEDICAL + JOBS_MARINES
#define JOBS_UNASSIGNED		list("Squad Marine")


#define ROLE_XENOMORPH "Xenomorph"
#define ROLE_XENO_QUEEN "Xeno Queen"
#define ROLE_SURVIVOR "Survivor"
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