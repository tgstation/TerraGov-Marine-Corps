
//skill defines

////////////////////////////////////////////////
///All skill string-var defines
#define SKILL_CQC "cqc"
#define SKILL_MELEE_WEAPONS "melee_weapons"
#define SKILL_FIREARMS "firearms"
#define SKILL_PISTOLS "pistols"
#define SKILL_SHOTGUNS "shotguns"
#define SKILL_RIFLES "rifles"
#define SKILL_SMGS "smgs"
#define SKILL_HEAVY_WEAPONS "heavy_weapons"
#define SKILL_SMARTGUN "smartgun"
#define SKILL_ENGINEER "engineer"
#define SKILL_CONSTRUCTION "construction"
#define SKILL_LEADERSHIP "leadership"
#define SKILL_MEDICAL "medical"
#define SKILL_SURGERY "surgery"
#define SKILL_PILOT "pilot"
#define SKILL_POLICE "police"
#define SKILL_POWERLOADER "powerloader"
#define SKILL_LARGE_VEHICLE "large_vehicle"
#define SKILL_STAMINA "stamina"
////////////////////////////////////////////////

// firearms skill (general knowledge of guns) (hidden skill)
///Increase or decrase accuracy, recoil, and firing delay of most guns.
#define SKILL_FIREARMS_UNTRAINED 0	// Civilian (Researcher, MD, CL, SO)
#define SKILL_FIREARMS_DEFAULT 1	// Marines (allow tactical reloads)
#define SKILL_FIREARMS_TRAINED 2	// Special training (CO)

///Damage mod for having the weapon specific skill above 0
#define FIREARM_SKILL_DAM_MOD 0.05

// pistols skill
///Increase or decrase accuracy, recoil, and firing delay of pistols and revolvers.
#define SKILL_PISTOLS_DEFAULT 0	// Marines
#define SKILL_PISTOLS_TRAINED 1	// Special training

// smgs skill
///Increase or decrase accuracy, recoil, and firing delay of submachineguns.
#define SKILL_SMGS_DEFAULT 0	// Marines
#define SKILL_SMGS_TRAINED 1	// Special training

// rifles skill
///Increase or decrase accuracy, recoil, and firing delay of rifles.
#define SKILL_RIFLES_DEFAULT 0	// marines
#define SKILL_RIFLES_TRAINED 1	// special training

// shotguns skill
// increase or decrase accuracy, recoil, and firing delay of shotguns.
#define SKILL_SHOTGUNS_DEFAULT 0	//marines
#define SKILL_SHOTGUNS_TRAINED 1	//special training

// heavy weapons skill
// increase or decrase accuracy, recoil, and firing delay of heavy weapons (non spec weapons, e.g. flamethrower).
#define SKILL_HEAVY_WEAPONS_DEFAULT 0	// marines
#define SKILL_HEAVY_WEAPONS_TRAINED 1	// special training

// smartgun skill
// increase or decrase accuracy, recoil, and firing delay for smartgun, and whether we can use smartguns at all.
#define SKILL_SMART_DEFAULT -4 // big negative so the effects are far worse than pistol/rifle untrained
#define SKILL_SMART_USE -3 // can use smartgun
#define SKILL_SMART_TRAINED 0 // default for smartgunner
#define SKILL_SMART_EXPERT 1
#define SKILL_SMART_MASTER 2

// construction skill
#define SKILL_CONSTRUCTION_DEFAULT 0
#define SKILL_CONSTRUCTION_METAL 1	// metal barricade construction
#define SKILL_CONSTRUCTION_PLASTEEL 2	// plasteel barricade,(RO, SL)
#define SKILL_CONSTRUCTION_ADVANCED 3	// windows and girder construction (Squad Engineer, CO)
#define SKILL_CONSTRUCTION_MASTER 4	// building machine & computer frames (ST)
#define SKILL_CONSTRUCTION_INHUMAN 5	// Early synth level (Early synth, CSE)

// engineer skill
#define SKILL_ENGINEER_DEFAULT 0
#define SKILL_ENGINEER_METAL 1	// metal barricade repair & c4 use
#define SKILL_ENGINEER_PLASTEEL 2	// plasteel barricade repair
#define SKILL_ENGINEER_ENGI 3	// hacking & planet engine fixing & apc building (Squad Engineer)
#define SKILL_ENGINEER_MASTER 4	// Telecomms fixing, faster engine fixing (ST, Synth)
#define SKILL_ENGINEER_INHUMAN 5	// Early synth level (Early synth, CSE)
// higher levels give faster engine repair.

// medical skill
#define SKILL_MEDICAL_UNTRAINED 0
#define SKILL_MEDICAL_NOVICE 1 // Premed or paramedic. Recognizing chemicals (SL, survivors)
#define SKILL_MEDICAL_PRACTICED 2 // Beginning intern (Squad Corpsman)
#define SKILL_MEDICAL_COMPETENT 3 // General practitioner (Survivor doc, early synth)
#define SKILL_MEDICAL_EXPERT 4 // Surgeons (MD, Researcher, Synth)
#define SKILL_MEDICAL_MASTER 5 // Modern-day Aesculapius (CMO)
// higher levels means faster syringe use and better defibrillation

// surgery skill
#define SKILL_SURGERY_DEFAULT 0 // untrained, really slow
#define SKILL_SURGERY_AMATEUR 1 // basic notions of first aid and biology (SL, SO)
#define SKILL_SURGERY_TRAINED 2 // semi-professional surgery (Squad Corpsman)
#define SKILL_SURGERY_PROFESSIONAL 3 // professional but unspecialized (Researcher)
#define SKILL_SURGERY_EXPERT 4 // specialized (MD)
#define SKILL_SURGERY_MASTER 5 // CMO
// higher levels means faster surgery.

// police skill, hidden
#define SKILL_POLICE_DEFAULT 0
#define SKILL_POLICE_FLASH 1 //flash use
#define SKILL_POLICE_MP 2 //all police gear use, can strip someone's clothes simultaneously

// cqc skill
// higher disarm chance on humans(+5% per level)
// slight increase in punch damage.
#define SKILL_CQC_WEAK -1
#define SKILL_CQC_DEFAULT 0
#define SKILL_CQC_TRAINED 1
#define SKILL_CQC_MP 2 // no risk of accidental weapon discharge upon disarming (MP)
#define SKILL_CQC_MASTER 5

// unarmed damage mod from CQC skill
#define CQC_SKILL_DAMAGE_MOD 5
// disarm chance mod from CQC skill
#define CQC_SKILL_DISARM_MOD 5

// powerloader skill
// hidden
// proficiency with powerloader, changes powerloader speed.
#define SKILL_POWERLOADER_DEFAULT 0
#define SKILL_POWERLOADER_DABBLING 1 // Squad Engineer
#define SKILL_POWERLOADER_TRAINED 2 // FC
#define SKILL_POWERLOADER_PRO 3 // Pilot
#define SKILL_POWERLOADER_MASTER 4 // CSE, RO, ST, Synths, Captain

// leadership skill
#define SKILL_LEAD_NOVICE 0 // Anyone. Using SL items is possible but painfully slow
#define SKILL_LEAD_BEGINNER 1 // All non-Standard Marines
#define SKILL_LEAD_TRAINED 2 // PO, CMO
#define SKILL_LEAD_EXPERT 3 // SL, SO, CSE
#define SKILL_LEAD_MASTER 4 // FC, CO, AI

// melee_weapons skill
// buff to melee weapon attack damage
#define SKILL_MELEE_WEAK -1
#define SKILL_MELEE_DEFAULT 0
#define SKILL_MELEE_TRAINED 1
#define SKILL_MELEE_SUPER 2

///The amount of extra damage per melee skill level
#define MELEE_SKILL_DAM_BUFF 0.15

// pilot skill, hidden
#define SKILL_PILOT_DEFAULT 0
#define SKILL_PILOT_TRAINED 1 //Pilot

// multitile and mech vehicle skills
#define SKILL_LARGE_VEHICLE_DEFAULT 0 // nothing
#define SKILL_LARGE_VEHICLE_TRAINED 1 // loader
#define SKILL_LARGE_VEHICLE_EXPERIENCED 2 // transport crew
#define SKILL_LARGE_VEHICLE_VETERAN 3 // mech pilot and assault crew

// stamina skill - you do cardio, right?
// buff stamina related things
#define SKILL_STAMINA_WEAK -1
#define SKILL_STAMINA_DEFAULT 0
#define SKILL_STAMINA_TRAINED 1
#define SKILL_STAMINA_SUPER 2

#define STAMINA_SKILL_COOLDOWN_MOD 2 SECONDS
#define STAMINA_SKILL_REGEN_MOD 0.15

////////////////////////////////////////////////

// skill-related fumble and delay times, in deciseconds
#define SKILL_TASK_TRIVIAL 10
#define SKILL_TASK_VERY_EASY 20
#define SKILL_TASK_EASY 30
#define SKILL_TASK_AVERAGE 50
#define SKILL_TASK_TOUGH 80
#define SKILL_TASK_DIFFICULT 100
#define SKILL_TASK_CHALLENGING 150
#define SKILL_TASK_FORMIDABLE 200
