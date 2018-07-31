
//skill defines


//firearms skill (general knowledge of guns) (hidden skill)
//increase or decrase accuracy, recoil, and firing delay of rifles and smgs.
#define SKILL_FIREARMS_UNTRAINED 0	//civilian
#define SKILL_FIREARMS_DEFAULT 	1	//marines (allow tactical reloads)
#define SKILL_FIREARMS_TRAINED	2	//special training

//pistols skill
//increase or decrase accuracy, recoil, and firing delay of pistols and revolvers.
#define SKILL_PISTOLS_DEFAULT 	0	//marines
#define SKILL_PISTOLS_TRAINED	1	//special training

//smgs skill
//increase or decrase accuracy, recoil, and firing delay of submachineguns.
#define SKILL_SMGS_DEFAULT 	0	//marines
#define SKILL_SMGS_TRAINED	1	//special training

//rifles skill
//increase or decrase accuracy, recoil, and firing delay of rifles.
#define SKILL_RIFLES_DEFAULT 	0	//marines
#define SKILL_RIFLES_TRAINED	1	//special training

//shotguns skill
//increase or decrase accuracy, recoil, and firing delay of shotguns.
#define SKILL_SHOTGUNS_DEFAULT 	0	//marines
#define SKILL_SHOTGUNS_TRAINED	1	//special training

//heavy weapons skill
//increase or decrase accuracy, recoil, and firing delay of heavy weapons (non spec weapons, e.g. flamethrower).
#define SKILL_HEAVY_WEAPONS_DEFAULT 	0	//marines
#define SKILL_HEAVY_WEAPONS_TRAINED		1	//special training



//smartgun skill
//increase or decrase accuracy, recoil, and firing delay for smartgun, and whether we can use smartguns at all.
#define SKILL_SMART_DEFAULT 		-4 //big negative so the effects are far worse than pistol/rifle untrained
#define SKILL_SMART_USE				-3 //can use smartgun
#define SKILL_SMART_TRAINED			0 //default for smartgunner
#define SKILL_SMART_EXPERT			1
#define SKILL_SMART_MASTER			2



//spec_weapons skill
//hidden. who can and can't use specialist weapons
#define SKILL_SPEC_DEFAULT		0
#define SKILL_SPEC_ROCKET		1 //can use the demolitionist specialist gear
#define SKILL_SPEC_SCOUT		2
#define SKILL_SPEC_SNIPER		3
#define SKILL_SPEC_GRENADIER	4
#define SKILL_SPEC_PYRO			5
#define SKILL_SPEC_TRAINED		6 //can use all specialist gear



//construction skill
#define SKILL_CONSTRUCTION_DEFAULT	0
#define SKILL_CONSTRUCTION_METAL 	1	//metal barricade construction (CT)
#define SKILL_CONSTRUCTION_PLASTEEL 2	//plasteel barricade,(Req)(combat engi)
#define SKILL_CONSTRUCTION_ADVANCED	3	//windows and girder construction
#define SKILL_CONSTRUCTION_MASTER	4	//building machine&computer frames (MT, CE)




// engineer skill
#define SKILL_ENGINEER_DEFAULT	0
#define SKILL_ENGINEER_METAL 	1	//metal barricade repair && c4 use
#define SKILL_ENGINEER_PLASTEEL 2	//plasteel barricade repair
#define SKILL_ENGINEER_ENGI 	3	//hacking&&planet engine fixing&&apc building (combat engi)
#define SKILL_ENGINEER_MT 		4	//Telecomms fixing, faster engine fixing (MT)
//higher levels give faster Almayer engine repair.


//medical skill
#define SKILL_MEDICAL_DEFAULT	0
#define SKILL_MEDICAL_CHEM		1 // recognizing chemicals, using autoinjectors & hyposprays with any chemicals (SL)
#define SKILL_MEDICAL_MEDIC		2 //syringe use & defib use (Combat Medic)
#define SKILL_MEDICAL_DOCTOR	3
#define SKILL_MEDICAL_CMO		4
//higher levels means faster syringe use and better defibrillation


//surgery skill
#define SKILL_SURGERY_DEFAULT	0
#define SKILL_SURGERY_TRAINED	1 //can do surgery (Doctor)
#define SKILL_SURGERY_EXPERT	2 //faster surgery (CMO)
//higher levels means faster surgery.





//police skill, hidden
#define SKILL_POLICE_DEFAULT 	0
#define SKILL_POLICE_FLASH 		1 //flash use (CE, CMO, any officer starting with a flash)
#define SKILL_POLICE_MP 		2 //all police gear use, can strip someone's clothes simultaneously (MP)


//cqc skill
//higher disarm chance on humans(+5% per level)
//slight increase in punch damage.
#define SKILL_CQC_WEAK		-1
#define SKILL_CQC_DEFAULT	0
#define SKILL_CQC_TRAINED	1
#define SKILL_CQC_MP		2 //no risk of accidental weapon discharge upon disarming (MP)
#define SKILL_CQC_MASTER	5


//powerloader skill
//hidden
//proficiency with powerloader, changes powerloader speed.
#define SKILL_POWERLOADER_DEFAULT	0
#define SKILL_POWERLOADER_DABBLING	1 //Pilot
#define SKILL_POWERLOADER_TRAINED	2 //CT, Req
#define SKILL_POWERLOADER_PRO		3 //MT
#define SKILL_POWERLOADER_MASTER	4 //CE


//leadership skill
#define SKILL_LEAD_NOVICE			0 //Anyone but the above. Using SL items is possible but painfully slow
#define SKILL_LEAD_BEGINNER			1 //All non-Standard Marines
#define SKILL_LEAD_TRAINED			2 //SL
#define SKILL_LEAD_EXPERT			3 //SOs
#define SKILL_LEAD_MASTER			4 //XO, CO


//melee_weapons skill
//buff to melee weapon attack damage(+30% dmg per level)
#define SKILL_MELEE_WEAK		-1
#define SKILL_MELEE_DEFAULT		0
#define SKILL_MELEE_TRAINED		1
#define SKILL_MELEE_SUPER		2


//pilot skill, hidden
#define SKILL_PILOT_DEFAULT		0
#define SKILL_PILOT_TRAINED		1 //Pilot


//endurance skill TBD



////////////////////////////////////////////////

//gun skill categories, matches the name of the job knowledge types for gun proficiency.
#define GUN_SKILL_FIREARMS		"firearms"
#define GUN_SKILL_PISTOLS		"pistols"
#define GUN_SKILL_SHOTGUNS		"shotguns"
#define GUN_SKILL_SMGS			"smgs"
#define GUN_SKILL_RIFLES		"rifles"
#define GUN_SKILL_HEAVY_WEAPONS	"heavy_weapons"
#define GUN_SKILL_SMARTGUN		"smartgun"
#define GUN_SKILL_SPEC			"spec_weapons"


//multitile vehicle skills
#define SKILL_LARGE_VEHICLE_DEFAULT 0
#define SKILL_LARGE_VEHICLE_TRAINED 1
