#define J_FLAG_MARINE		(1<<0)

#define SQUAD_MARINE		(1<<0)
#define SQUAD_CORPSMAN		(1<<1)
#define SQUAD_ENGINEER		(1<<3)
#define SQUAD_SMARTGUNNER	(1<<4)
#define SQUAD_SPECIALIST	(1<<5)
#define SQUAD_LEADER		(1<<6)



#define J_FLAG_SHIP			(1<<1)

#define SHIP_CO				(1<<0)
#define SHIP_XO				(1<<1)
#define SHIP_SO				(1<<2)
#define SHIP_PO				(1<<3)
#define SHIP_TC				(1<<4)
#define SHIP_MP				(1<<5)
#define SHIP_CMP			(1<<6)
#define SHIP_CE				(1<<7)
#define SHIP_MT				(1<<8)
#define SHIP_RO				(1<<9)
#define SHIP_CT				(1<<10)
#define SHIP_CMO			(1<<11)
#define SHIP_DOCTOR			(1<<12)
#define SHIP_RESEARCHER		(1<<13)
#define SHIP_CL				(1<<14)
#define SHIP_SYNTH			(1<<15)



#define J_FLAG_UPP			(1<<2)

#define UPP_STANDARD		(1<<0)
#define UPP_MEDIC			(1<<1)
#define UPP_HEAVY			(1<<2)
#define UPP_LEADER			(1<<3)
#define UPP_COM_STANDARD	(1<<4)
#define UPP_COM_MEDIC		(1<<5)
#define UPP_COM_LEADER		(1<<6)



#define J_FLAG_FREELANCER	(1<<3)

#define FRE_STANDARD		(1<<0)
#define FRE_MEDIC			(1<<1)
#define FRE_LEADER			(1<<2)



#define J_FLAG_CLF			(1<<4)

#define CLF_STANDARD		(1<<0)
#define CLF_MEDIC			(1<<1)
#define CLF_LEADER			(1<<2)



#define J_FLAG_MERCENARY	(1<<5)

#define MERC_HEAVY			(1<<0)
#define MERC_MINER			(1<<1)
#define MERC_ENGINEER		(1<<2)



#define J_FLAG_PMC			(1<<6)

#define PMC_STANDARD		(1<<0)
#define PMC_GUNNER			(1<<1)
#define PMC_SNIPER			(1<<2)
#define PMC_LEADER			(1<<3)
#define PMC_DS_STANDARD		(1<<4)
#define PMC_DS_LEADER		(1<<5)



#define J_FLAG_MISC			(1<<7)

#define MISC_COLONIST		(1<<0)
#define MISC_PASSENGER		(1<<1)
#define MISC_PIZZA			(1<<2)
#define MISC_SPATIAL_AGENT	(1<<3)



#define J_FLAG_SURVIVOR		(1<<8)

#define SURV_ASSISTANT		(1<<0)
#define SURV_SCIENTIST		(1<<1)
#define SURV_DOCTOR			(1<<2)
#define SURV_LIAISON		(1<<3)
#define SURV_SECGUARD		(1<<4)
#define SURV_CIVILIAN		(1<<5)
#define SURV_CHEF			(1<<6)
#define SURV_BOTANIST		(1<<7)
#define SURV_ATMOS			(1<<8)
#define SURV_CHAPLAIN		(1<<9)
#define SURV_MINER			(1<<10)
#define SURV_SALESMAN		(1<<11)
#define SURV_COLMARSHAL		(1<<12)
#define SURV_CLOWN			(1<<13)


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


//prefflag
#define PREF_JOB_CO				(1 << 0)
#define PREF_JOB_FC				(1 << 1)
#define PREF_JOB_SO				(1 << 2)
#define PREF_JOB_PO				(1 << 3)
#define PREF_JOB_TC				(1 << 4)
#define PREF_JOB_MP				(1 << 5)
#define PREF_JOB_CMP			(1 << 6)
#define PREF_JOB_CE				(1 << 7)
#define PREF_JOB_MT				(1 << 8)
#define PREF_JOB_RO				(1 << 9)
#define PREF_JOB_CT				(1 << 10)
#define PREF_JOB_CMO			(1 << 11)
#define PREF_JOB_DOCTOR			(1 << 12)
#define PREF_JOB_RESEARCHER		(1 << 13)
#define PREF_JOB_CL				(1 << 14)
#define PREF_JOB_SYNTH			(1 << 15)
#define PREF_JOB_SQMARINE		(1 << 16)
#define PREF_JOB_SQCORPSMAN		(1 << 17)
#define PREF_JOB_SQENGINEER		(1 << 18)
#define PREF_JOB_SQSMARTGUNNER	(1 << 19)
#define PREF_JOB_SQSPECIALIST	(1 << 20)
#define PREF_JOB_SQLEADER		(1 << 21)

#define JOBS_PRIORITY_HIGH   1
#define JOBS_PRIORITY_MEDIUM 2
#define JOBS_PRIORITY_LOW    3
#define JOBS_PRIORITY_NEVER  4


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