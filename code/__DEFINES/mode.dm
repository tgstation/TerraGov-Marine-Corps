//=================================================
//Self destruct, nuke, and evacuation.
#define EVACUATION_TIME_LOCK 60 MINUTES
#define DISTRESS_TIME_LOCK 10 MINUTES
#define SHUTTLE_TIME_LOCK 10 MINUTES
#define SHUTTLE_LOCK_COOLDOWN 10 MINUTES
#define SHUTTLE_LOCK_TIME_LOCK 45 MINUTES
#define EVACUATION_AUTOMATIC_DEPARTURE 3 MINUTES //All pods automatically depart in 10 minutes, unless they are full or unable to launch for some reason.
#define EVACUATION_ESTIMATE_DEPARTURE ((evac_time + EVACUATION_AUTOMATIC_DEPARTURE - world.time) * 0.1)
#define EVACUATION_STATUS_STANDING_BY 0
#define EVACUATION_STATUS_INITIATING 1
#define EVACUATION_STATUS_IN_PROGRESS 2
#define EVACUATION_STATUS_COMPLETE 3

#define COOLDOWN_COMM_REQUEST 5 MINUTES
#define COOLDOWN_COMM_MESSAGE 1 MINUTES
#define COOLDOWN_COMM_CENTRAL 30 SECONDS

#define NUKE_EXPLOSION_INACTIVE 0
#define NUKE_EXPLOSION_ACTIVE	1
#define NUKE_EXPLOSION_IN_PROGRESS 2
#define NUKE_EXPLOSION_FINISHED 3

#define FLAGS_EVACUATION_DENY 1
#define FLAGS_SELF_DESTRUCT_DENY 2
//=================================================

#define ROLE_MODE_DEFAULT   0
#define ROLE_MODE_REPLACE   1
#define ROLE_MODE_ADD		2
#define ROLE_MODE_SUBTRACT	3


#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/game_mode/"+(MODE))))

#define MODE_INFESTATION		(1 << 0)
#define MODE_PREDATOR			(1 << 1)
#define MODE_NO_LATEJOIN		(1 << 2)
#define MODE_HAS_FINISHED		(1 << 3)
#define MODE_FOG_ACTIVATED 		(1 << 4)
#define MODE_INFECTION			(1 << 5)
#define MODE_HUMAN_ANTAGS		(1 << 6)

#define BE_ALIEN		(1 << 0)
#define BE_QUEEN		(1 << 1)
#define BE_SURVIVOR		(1 << 2)
#define BE_DEATHMATCH	(1 << 3)
#define BE_PREDATOR		(1 << 4)


#define BE_REV        (1 << 5)
#define BE_TRAITOR    (1 << 6)
#define BE_OPERATIVE  (1 << 7)
#define BE_CULTIST    (1 << 8)
#define BE_MONKEY     (1 << 9)
#define BE_NINJA      (1 << 10)
#define BE_RAIDER     (1 << 11)
#define BE_PLANT      (1 << 12)
#define BE_MUTINEER   (1 << 13)
#define BE_CHANGELING (1 << 14)

#define BE_SQUAD_STRICT (1 << 15)
//=================================================

var/list/be_special_flags = list(
	"Xenomorph" = BE_ALIEN,
	"Survivor" = BE_SURVIVOR,
	"End of Round Deathmatch" = BE_DEATHMATCH,
	"Predator" = BE_PREDATOR,
	"Queen" = BE_QUEEN

/*
	"Malf AI" = BE_MALF,
	"Revolutionary" = BE_REV,
	"Traitor" = BE_TRAITOR,
	"Operative" = BE_OPERATIVE,
	"Cultist" = BE_CULTIST,
	"Monkey" = BE_MONKEY,
	"Ninja" = BE_NINJA,
	"Raider" = BE_RAIDER,
	"Mutineer" = BE_MUTINEER,
	"Changeling" = BE_CHANGELING*/
	)

#define AGE_MIN 17			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be
//Number of marine players against which the Marine's gear scales
#define MARINE_GEAR_SCALING_NORMAL 30
#define MAX_GEAR_COST 5 //Used in chargen for loadout limit.
//=================================================

//Various roles and their suggested bitflags or defines.

#define ROLEGROUP_MARINE_COMMAND		1

#define ROLE_COMMANDING_OFFICER			1
#define ROLE_EXECUTIVE_OFFICER			2
#define ROLE_BRIDGE_OFFICER				4
#define ROLE_MILITARY_POLICE			8
#define ROLE_CORPORATE_LIAISON			16
#define ROLE_REQUISITION_OFFICER		32
#define ROLE_PILOT_OFFICER				64
#define ROLE_CHIEF_MP					128
#define ROLE_SYNTHETIC					256
#define ROLE_TANK_OFFICER				512
//=================================================

#define ROLEGROUP_MARINE_ENGINEERING 	2

#define ROLE_CHIEF_ENGINEER				1
#define ROLE_MAINTENANCE_TECH			2
#define ROLE_REQUISITION_TECH			4
//=================================================

#define ROLEGROUP_MARINE_MED_SCIENCE 	4

#define ROLE_CHIEF_MEDICAL_OFFICER		1
#define ROLE_CIVILIAN_DOCTOR			2
#define ROLE_CIVILIAN_RESEARCHER		4
//=================================================

#define ROLEGROUP_MARINE_SQUAD_MARINES 	8

#define ROLE_MARINE_LEADER			1
#define ROLE_MARINE_MEDIC			2
#define ROLE_MARINE_ENGINEER		4
#define ROLE_MARINE_STANDARD		8
#define ROLE_MARINE_SPECIALIST		16
#define ROLE_MARINE_SMARTGUN		32
//=================================================

#define ROLE_ADMIN_NOTIFY			1
#define ROLE_ADD_TO_SQUAD			2
#define ROLE_ADD_TO_DEFAULT			4
#define ROLE_ADD_TO_MODE			8
#define ROLE_WHITELISTED			16
//=================================================

//Role defines, specifically lists of roles for job bans and the like.
#define ROLES_COMMAND 		list("Commander","Executive Officer","Staff Officer","Pilot Officer","Tank Crewman","Military Police","Corporate Liaison","Requisitions Officer","Chief Engineer","Chief Medical Officer","Chief MP")
#define ROLES_OFFICERS		list("Commander","Executive Officer","Staff Officer","Pilot Officer","Tank Crewman","Chief MP","Military Police","Corporate Liaison", "Synthetic")
#define ROLES_ENGINEERING 	list("Chief Engineer","Maintenance Tech")
#define ROLES_REQUISITION 	list("Requisitions Officer","Cargo Technician")
#define ROLES_MEDICAL 		list("Chief Medical Officer","Doctor","Researcher")
#define ROLES_MARINES		list("Squad Leader","Squad Specialist","Squad Smartgunner","Squad Medic","Squad Engineer","Squad Marine")
#define ROLES_SQUAD_ALL		list("Alpha","Delta")
#define ROLES_REGULAR_ALL	ROLES_OFFICERS + ROLES_ENGINEERING + ROLES_REQUISITION + ROLES_MEDICAL + ROLES_MARINES
#define ROLES_UNASSIGNED	list("Squad Marine")
//=================================================

//=================================================
#define WHITELIST_YAUTJA_UNBLOODED	1
#define WHITELIST_YAUTJA_BLOODED	2
#define WHITELIST_YAUTJA_ELITE		4
#define WHITELIST_YAUTJA_ELDER		8
#define WHITELIST_PREDATOR			(WHITELIST_YAUTJA_UNBLOODED|WHITELIST_YAUTJA_BLOODED|WHITELIST_YAUTJA_ELITE|WHITELIST_YAUTJA_ELDER)
#define WHITELIST_COMMANDER			16
#define WHITELIST_SYNTHETIC			32
#define WHITELIST_ARCTURIAN			64
#define WHITELIST_ALL				(WHITELIST_YAUTJA_UNBLOODED|WHITELIST_YAUTJA_BLOODED|WHITELIST_YAUTJA_ELITE|WHITELIST_YAUTJA_ELDER|WHITELIST_COMMANDER|WHITELIST_SYNTHETIC|WHITELIST_ARCTURIAN)
//=================================================


