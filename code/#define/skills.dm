
//skill defines


//firearms skill
//increase or decrase accuracy, recoil, and firing delay of rifles and smgs.
#define SKILL_FIREARMS_UNTRAINED -1	//civilian
#define SKILL_FIREARMS_DEFAULT 	0	//marines
#define SKILL_FIREARMS_TRAINED	1	//special training

//pistols skill
//increase or decrase accuracy, recoil, and firing delay of pistols and revolvers.
#define SKILL_PISTOLS_UNTRAINED -1	//civilian
#define SKILL_PISTOLS_DEFAULT 	0	//marines
#define SKILL_PISTOLS_TRAINED	1	//special training


//smartgun skill
//increase or decrase accuracy, recoil, and firing delay for smartgun, and whether we can use smartguns at all.
#define SKILL_SMART_DEFAULT 		-4 //big negative so the effects are far worse than pistol/rifle untrained
#define SKILL_SMART_USE				-3 //can use smartgun
#define SKILL_SMART_TRAINED			0
#define SKILL_SMART_TRAINED_PLUS	1




//heavy_weapons skill
//hidden. who can and can't use specialist weapons
#define SKILL_HEAVY_DEFAULT	0
#define SKILL_HEAVY_TRAINED	1



// engineer skill
#define SKILL_ENGINEER_DEFAULT	0
#define SKILL_ENGINEER_METAL 	1	//metal barricade construction&repair,c4 use (CT)
#define SKILL_ENGINEER_PLASTEEL 2	//plasteel barricade&repair, girder construction (Req)
#define SKILL_ENGINEER_ENGI 	3	//hacking&&planet engine fixing&&apc building (combat engi)
#define SKILL_ENGINEER_MT 		4	//building machine&computer frames, faster engine fixing (MT)
//higher levels give faster Almayer engine repair.


//medical skill
#define SKILL_MEDICAL_DEFAULT	0
#define SKILL_MEDICAL_CHEM		1 // using autoinjectors & hyposprays with any chemicals (SL)
#define SKILL_MEDICAL_MEDIC		2 //syringe use & defib use (Combat Medic)
//level 3 currently does nothing.
#define SKILL_MEDICAL_SURGERY	4 //can do surgery (Doctor)
#define SKILL_MEDICAL_CMO		5 //faster surgery (CMO)
//higher levels means faster syringe use and surgery.



//police skill, hidden
#define SKILL_POLICE_DEFAULT 	0
#define SKILL_POLICE_FLASH 		1 //flash use (CE, CMO, any officer starting with a flash)
#define SKILL_POLICE_MP 		2 //all police gear use (MP)


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
#define SKILL_POWERLOADER_TRAINED	2 //CT, Req, Pilot
#define SKILL_POWERLOADER_PRO		3 //MT
#define SKILL_POWERLOADER_MASTER	4 //CE


//leadership skill
#define SKILL_LEAD_DEFAULT			0
#define SKILL_LEAD_BINOCS			1 //use of supply beacon, tactical binocs (all marines except standard)
#define SKILL_LEAD_SL				2 //use of orbital beacons, faster use of tactical binocs (SL)
#define SKILL_LEAD_OVERWATCH		3 //bridge console use (SO, CO, XO)
//level above: even faster binoc targeting use


//melee_weapons skill
//buff to melee weapon attack damage(+30% dmg per level)
#define SKILL_MELEE_WEAK		-1
#define SKILL_MELEE_DEFAULT		0
#define SKILL_MELEE_TRAINED		1
#define SKILL_MELEE_SUPER		2


//pilot skill, hidden
#define SKILL_PILOT_NONE		0
#define SKILL_PILOT_TRAINED		1 //Pilot


//endurance skill TBD



////////////////////////////////////////////////

//gun skill categories, matches the name of the job knowledge types for gun proficiency.
#define GUN_SKILL_FIREARMS	"firearms"
#define GUN_SKILL_PISTOLS	"pistols"
#define GUN_SKILL_SMARTGUN	"smartgun"
