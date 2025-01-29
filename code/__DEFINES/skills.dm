// Skill defines
///UNARMED skill; higher disarm chance on humans(+5% per level); slight increase in punch damage.
#define SKILL_UNARMED "unarmed"

#define SKILL_UNARMED_WEAK -1
#define SKILL_UNARMED_DEFAULT 0
#define SKILL_UNARMED_TRAINED 1
#define SKILL_UNARMED_MP 2
#define SKILL_UNARMED_MASTER 5

///Unarmed damage mod from UNARMED skill
#define UNARMED_SKILL_DAMAGE_MOD 5
///Disarm chance mod from UNARMED skill
#define UNARMED_SKILL_DISARM_MOD 5

///Melee skill; 15% extra damage per skill level
#define SKILL_MELEE_WEAPONS "melee_weapons"

#define SKILL_MELEE_WEAK -1
#define SKILL_MELEE_DEFAULT 0
#define SKILL_MELEE_TRAINED 1
#define SKILL_MELEE_SUPER 2

///The amount of extra damage per melee skill level
#define MELEE_SKILL_DAM_BUFF 0.15

///Combat skill; Increase or decrase accuracy, recoil, damage, and firing delay of most guns; ability to tac reload
#define SKILL_COMBAT "combat"

#define SKILL_COMBAT_UNTRAINED 0
#define SKILL_COMBAT_DEFAULT 1
#define SKILL_COMBAT_TRAINED 2

///Damage mod for having the weapon specific skill above 0
#define COMBAT_SKILL_DAM_MOD 0.05

///Pistols skill; Increase accuracy, recoil, and damage of pistols and revolvers.
#define SKILL_PISTOLS "pistols"

#define SKILL_PISTOLS_DEFAULT 0
#define SKILL_PISTOLS_TRAINED 1

///SMG skill; Increase accuracy, recoil, and damage of SMGs.
#define SKILL_SMGS "smgs"

#define SKILL_SMGS_DEFAULT 0
#define SKILL_SMGS_TRAINED 1

///Rifles skill; Increase accuracy, recoil, and damage of rifles.
#define SKILL_RIFLES "rifles"

#define SKILL_RIFLES_DEFAULT 0
#define SKILL_RIFLES_TRAINED 1

///Shotgun skill; Increase accuracy, recoil, and damage of shotguns.
#define SKILL_SHOTGUNS "shotguns"

#define SKILL_SHOTGUNS_DEFAULT 0
#define SKILL_SHOTGUNS_TRAINED 1

///Heavy weapons skill; Increase accuracy, recoil, damage, and firing delay of heavy weapons (eg. machineguns, pulse rifles, flamethrower).
#define SKILL_HEAVY_WEAPONS "heavy_weapons"

#define SKILL_HEAVY_WEAPONS_DEFAULT 0
#define SKILL_HEAVY_WEAPONS_TRAINED 1

///Smartgun skill; Increase or decrase accuracy, recoil, damage, and firing delay for smartgun, and whether we can use smartguns at all.
#define SKILL_SMARTGUN "smartgun"

#define SKILL_SMART_DEFAULT -4
#define SKILL_SMART_USE -3
#define SKILL_SMART_TRAINED 0
#define SKILL_SMART_EXPERT 1
#define SKILL_SMART_MASTER 2

///Engineer skill; higher levels means faster engine repair and more integrity repair off welding
#define SKILL_ENGINEER "engineer"

#define SKILL_ENGINEER_DEFAULT 0
#define SKILL_ENGINEER_METAL 1
#define SKILL_ENGINEER_PLASTEEL 2
#define SKILL_ENGINEER_ENGI 3
#define SKILL_ENGINEER_EXPERT 4
#define SKILL_ENGINEER_MASTER 5

///Construction skill; higher levels means faster buidling
#define SKILL_CONSTRUCTION "construction"

#define SKILL_CONSTRUCTION_DEFAULT 0
#define SKILL_CONSTRUCTION_METAL 1
#define SKILL_CONSTRUCTION_PLASTEEL 2
#define SKILL_CONSTRUCTION_ADVANCED 3
#define SKILL_CONSTRUCTION_EXPERT 4
#define SKILL_CONSTRUCTION_MASTER 5

///Medical skill; higher levels means faster syringe use and better defibrillation
#define SKILL_MEDICAL "medical"

#define SKILL_MEDICAL_UNTRAINED 0
#define SKILL_MEDICAL_NOVICE 1
#define SKILL_MEDICAL_PRACTICED 2
#define SKILL_MEDICAL_COMPETENT 3
#define SKILL_MEDICAL_EXPERT 4
#define SKILL_MEDICAL_MASTER 5

///Surgery skill; higher levels means faster surgery, less fumble time to start surgery
#define SKILL_SURGERY "surgery"

#define SKILL_SURGERY_DEFAULT 0
#define SKILL_SURGERY_AMATEUR 1
#define SKILL_SURGERY_TRAINED 2
#define SKILL_SURGERY_PROFESSIONAL 3
#define SKILL_SURGERY_EXPERT 4
#define SKILL_SURGERY_MASTER 5

///Leadership skill; order strength + range of effect
#define SKILL_LEADERSHIP "leadership"

#define SKILL_LEAD_NOVICE 0
#define SKILL_LEAD_BEGINNER 1
#define SKILL_LEAD_TRAINED 2
#define SKILL_LEAD_EXPERT 3
#define SKILL_LEAD_MASTER 4

///Pilot skill, hidden; affects dropship weapon usage (not called anywhere on Condor)
#define SKILL_PILOT "pilot"

#define SKILL_PILOT_DEFAULT 0
#define SKILL_PILOT_TRAINED 1

///Police skill; use of special equipment
#define SKILL_POLICE "police"

#define SKILL_POLICE_DEFAULT 0
#define SKILL_POLICE_FLASH 1
#define SKILL_POLICE_MP 2

///Powerloader skill; movespeed when using a powerloader
#define SKILL_POWERLOADER "powerloader"

#define SKILL_POWERLOADER_DEFAULT 0
#define SKILL_POWERLOADER_DABBLING 1
#define SKILL_POWERLOADER_TRAINED 2
#define SKILL_POWERLOADER_PRO 3
#define SKILL_POWERLOADER_MASTER 4

///Multitile vehicle skill; can you use the vehicle or not
#define SKILL_LARGE_VEHICLE "large_vehicle"

#define SKILL_LARGE_VEHICLE_DEFAULT 0
#define SKILL_LARGE_VEHICLE_TRAINED 1
#define SKILL_LARGE_VEHICLE_EXPERIENCED 2
#define SKILL_LARGE_VEHICLE_VETERAN 3

///mech vehicle skill; can you use greyscale mechs or not
#define SKILL_MECH "mech"

#define SKILL_MECH_DEFAULT 0
#define SKILL_MECH_TRAINED 1

///Stamina skill - you do cardio, right?; buff stamina-related things
#define SKILL_STAMINA "stamina"

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
