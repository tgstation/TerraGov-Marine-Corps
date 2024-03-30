
// Skill defines

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

/**
 * Firearms skill; Increase or decrase accuracy, recoil, and firing delay of most guns.
 * UNTRAINED = Civilian (Researcher, MD, CL)
 * DEFAULT = Allows tactical reloads (Marines)
 * TRAINED = Special training (CO)
 */
#define SKILL_FIREARMS_UNTRAINED 0
#define SKILL_FIREARMS_DEFAULT 1
#define SKILL_FIREARMS_TRAINED 2

///Damage mod for having the weapon specific skill above 0
#define FIREARM_SKILL_DAM_MOD 0.05

/**
 * Pistols skill; Increase or decrase accuracy, recoil, and firing delay of pistols and revolvers.
 * DEFAULT = Marines
 * TRAINED = Special training (Synths for tasers; ERT)
 */
#define SKILL_PISTOLS_DEFAULT 0
#define SKILL_PISTOLS_TRAINED 1

/**
 * SMG skill; Increase or decrase accuracy, recoil, and firing delay of SMGs.
 * DEFAULT = Marines
 * TRAINED = Special training (ERT)
 */
#define SKILL_SMGS_DEFAULT 0
#define SKILL_SMGS_TRAINED 1

/**
 * Rifles skill; Increase or decrase accuracy, recoil, and firing delay of rifles.
 * DEFAULT = Marines
 * TRAINED = Special training (ERT)
 */
#define SKILL_RIFLES_DEFAULT 0
#define SKILL_RIFLES_TRAINED 1

/**
 * Shotgun skill; Increase or decrase accuracy, recoil, and firing delay of shotguns.
 * DEFAULT = Marines
 * TRAINED = Special training (ERT)
 */
#define SKILL_SHOTGUNS_DEFAULT 0
#define SKILL_SHOTGUNS_TRAINED 1

/**
 * Heavy weapons skill; Increase or decrase accuracy, recoil, and firing delay of heavy weapons (eg. machineguns, pulse rifles, flamethrower).
 * DEFAULT = Marines
 * TRAINED = Special training (ERT)
 */
#define SKILL_HEAVY_WEAPONS_DEFAULT 0
#define SKILL_HEAVY_WEAPONS_TRAINED 1

/**
 * Smartgun skill; Increase or decrase accuracy, recoil, and firing delay for smartgun, and whether we can use smartguns at all.
 * DEFAULT = Big negative so the effects are far worse than pistol/rifle untrained
 * USE = Can use a smartgun (CO)
 * TRAINED = Smartgunners
 * EXPERT = Unused
 * MASTER = Deathsquad
 */
#define SKILL_SMART_DEFAULT -4
#define SKILL_SMART_USE -3
#define SKILL_SMART_TRAINED 0
#define SKILL_SMART_EXPERT 1
#define SKILL_SMART_MASTER 2

/**
 * Construction skill; higher levels means faster engine repair
 * DEFAULT = Untrained
 * METAL = Metal barricade construction with no fumble (TO)
 * PLASTEEL = Plasteel barricade construction with no fumble (RO, SL)
 * ADVANCED = Windows and girder construction (Squad Engineer, CO)
 * MASTER = Computer frames (ST, Synth, CSE)
 * INHUMAN = Early synth level (Early synth)
 */
#define SKILL_CONSTRUCTION_DEFAULT 0
#define SKILL_CONSTRUCTION_METAL 1
#define SKILL_CONSTRUCTION_PLASTEEL 2
#define SKILL_CONSTRUCTION_ADVANCED 3
#define SKILL_CONSTRUCTION_MASTER 4
#define SKILL_CONSTRUCTION_INHUMAN 5

/**
 * Engineer skill; higher levels means faster engine repair
 * DEFAULT = Untrained
 * METAL = Metal barricade repair with no fumble, ability to plant detpacks without them instantly exploding; vehicle repair w/o fumble (TC, AC, MP)
 * PLASTEEL = Plasteel cade repair w/o fumble; ability to rig cells to explode without random detonation (SL)
 * ENGI = Hacking, planet engine fixing, APC building (Squad Engineer, FC, CO, TO)
 * MASTER = Faster engine fixing, ability to read fuel cell amounts, computer deconstruction (ST, Synth, CSE)
 * INHUMAN = Early synth level (Early synth)
 */
#define SKILL_ENGINEER_DEFAULT 0
#define SKILL_ENGINEER_METAL 1
#define SKILL_ENGINEER_PLASTEEL 2
#define SKILL_ENGINEER_ENGI 3
#define SKILL_ENGINEER_MASTER 4
#define SKILL_ENGINEER_INHUMAN 5

/**
 * Medical skill; higher levels means faster syringe use and better defibrillation
 * UNTRAINED = Default
 * NOVICE = Premed or paramedic; recognizing chemicals (SL, survivors)
 * PRACTICED = Beginning intern (Squad Corpsman)
 * COMPETENT = General practitioner (Early Synth)
 * EXPERT = People who went to school for this (MD, Researcher, Synth)
 * MASTER = Modern-day Aesculapius (CMO)
 */
#define SKILL_MEDICAL_UNTRAINED 0
#define SKILL_MEDICAL_NOVICE 1
#define SKILL_MEDICAL_PRACTICED 2
#define SKILL_MEDICAL_COMPETENT 3
#define SKILL_MEDICAL_EXPERT 4
#define SKILL_MEDICAL_MASTER 5

/**
 * Surgery skill; higher levels means faster surgery, less fumble time to start surgery
 * DEFAULT = Untrained, really slow
 * AMATEUR = Basic notions of first aid and biology (SL, SO, Cap, FC)
 * TRAINED = Professional but unspecialized (Researcher, Early Synth)
 * EXPERT = Specialized (MD, Synth)
 * MASTER = A most masterful anatomist, like Da Vinci (CMO)
 */
#define SKILL_SURGERY_DEFAULT 0
#define SKILL_SURGERY_AMATEUR 1
#define SKILL_SURGERY_TRAINED 2
#define SKILL_SURGERY_PROFESSIONAL 3
#define SKILL_SURGERY_EXPERT 4
#define SKILL_SURGERY_MASTER 5

/**
 * Police skill; use of special equipment
 * DEFAULT = Untrained
 * FLASH = Flash use
 * MP = Baton use, can strip someone's clothes simultaneously
 */
#define SKILL_POLICE_DEFAULT 0
#define SKILL_POLICE_FLASH 1
#define SKILL_POLICE_MP 2

/**
 * CQC skill; higher disarm chance on humans(+5% per level); slight increase in punch damage.
 * WEAK = Civilian roles (CL, MD, RSR, CMO)
 * DEFAULT = Default
 * TRAINED = FC, SL
 * MP = No risk of accidental weapon discharge upon disarming (unused)
 * MASTER = Synths
 */
#define SKILL_CQC_WEAK -1
#define SKILL_CQC_DEFAULT 0
#define SKILL_CQC_TRAINED 1
#define SKILL_CQC_MP 2
#define SKILL_CQC_MASTER 5

///Unarmed damage mod from CQC skill
#define CQC_SKILL_DAMAGE_MOD 5
///Disarm chance mod from CQC skill
#define CQC_SKILL_DISARM_MOD 5

/**
 * Powerloader skill; movespeed when using a powerloader (broken currently)
 * DEFAULT = Untrained
 * DABBLING = Squad Engineer
 * TRAINED = FC
 * PRO = Pilot
 * MASTER = CSE, RO, ST, Synths, CO, AI
 */
#define SKILL_POWERLOADER_DEFAULT 0
#define SKILL_POWERLOADER_DABBLING 1
#define SKILL_POWERLOADER_TRAINED 2
#define SKILL_POWERLOADER_PRO 3
#define SKILL_POWERLOADER_MASTER 4


/**
 * Leadership skill; order strength + range of effect
 * DEFAULT = Untrained; Using SL items is possible but painfully slow
 * BEGINNER = All non-Standard Marines
 * TRAINED = PO, CMO
 * EXPERT = SL, SO, CSE
 * MASTER = FC, CO, AI
 */
#define SKILL_LEAD_NOVICE 0
#define SKILL_LEAD_BEGINNER 1
#define SKILL_LEAD_TRAINED 2
#define SKILL_LEAD_EXPERT 3
#define SKILL_LEAD_MASTER 4

/**
 * Melee skill; 15% extra damage per skill level
 * WEAK = Non-combat roles (MD, RSR, CMO, CL, Synths, Vat growns when they're new)
 * DEFAULT = Marines
 * TRAINED = Gimmicks and ERT
 * SUPER = Gimmicks and Spatial Agents
 */
#define SKILL_MELEE_WEAK -1
#define SKILL_MELEE_DEFAULT 0
#define SKILL_MELEE_TRAINED 1
#define SKILL_MELEE_SUPER 2

///The amount of extra damage per melee skill level
#define MELEE_SKILL_DAM_BUFF 0.15

///Pilot skill, hidden; affects nothing (not called anywhere)
#define SKILL_PILOT_DEFAULT 0
#define SKILL_PILOT_TRAINED 1

/**
 * Multitile vehicle skill; can you use the vehicle or not
 * DEFAULT = Marines
 * TRAINED = Loader
 * EXPERIENCED = Transport Crewman
 * VETERAN = MP and Assault Crewman
 */
#define SKILL_LARGE_VEHICLE_DEFAULT 0
#define SKILL_LARGE_VEHICLE_TRAINED 1
#define SKILL_LARGE_VEHICLE_EXPERIENCED 2
#define SKILL_LARGE_VEHICLE_VETERAN 3

/**
 * Stamina skill - you do cardio, right?; buff stamina related things
 * WEAK = Unused
 * DEFAULT = Marines
 * TRAINED = Unused
 * SUPER = Unused
 */
#define SKILL_STAMINA_WEAK -1
#define SKILL_STAMINA_DEFAULT 0
#define SKILL_STAMINA_TRAINED 1
#define SKILL_STAMINA_SUPER 2

///Stamina cooldown after you use it and before it starts to regenerate
#define STAMINA_SKILL_COOLDOWN_MOD 2 SECONDS
///Stamina skill regen multiplier increase for when stamina skill goes up
#define STAMINA_SKILL_REGEN_MOD 0.15

///Skill-related fumble and delay times; in deciseconds
#define SKILL_TASK_TRIVIAL 10
#define SKILL_TASK_VERY_EASY 20
#define SKILL_TASK_EASY 30
#define SKILL_TASK_AVERAGE 50
#define SKILL_TASK_TOUGH 80
#define SKILL_TASK_DIFFICULT 100
#define SKILL_TASK_CHALLENGING 150
#define SKILL_TASK_FORMIDABLE 200
