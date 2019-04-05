/datum/skills
	var/name //the name of the skillset
	var/cqc = SKILL_CQC_DEFAULT
	var/melee_weapons = SKILL_MELEE_DEFAULT

	var/firearms = SKILL_FIREARMS_DEFAULT
	var/pistols = SKILL_PISTOLS_DEFAULT
	var/shotguns = SKILL_SHOTGUNS_DEFAULT
	var/rifles = SKILL_RIFLES_DEFAULT
	var/smgs = SKILL_SMGS_DEFAULT
	var/heavy_weapons = SKILL_HEAVY_WEAPONS_DEFAULT
	var/smartgun = SKILL_SMART_DEFAULT
	var/spec_weapons = SKILL_SPEC_DEFAULT

	var/engineer = SKILL_ENGINEER_DEFAULT
	var/construction = SKILL_CONSTRUCTION_DEFAULT
	var/leadership = SKILL_LEAD_NOVICE
	var/medical = SKILL_MEDICAL_UNTRAINED
	var/surgery = SKILL_SURGERY_DEFAULT
	var/pilot = SKILL_PILOT_DEFAULT
	var/police = SKILL_POLICE_DEFAULT
	var/powerloader = SKILL_POWERLOADER_DEFAULT
	var/large_vehicle = SKILL_LARGE_VEHICLE_DEFAULT

	var/list/values = list()


/datum/skills/New()
	values = list("Close Quarter Combat" = cqc, "Melee Weapons" = melee_weapons, "Firearms" = firearms, "Pistols" = pistols, "Shotguns" = shotguns,\
	"Rifles" = rifles, "Submachine Guns" = smgs, "Heavy Weapons" = heavy_weapons, "Smartgun" = smartgun, "Specialist Weapons" = spec_weapons, \
	"Engineering" = engineer, "Construction" = construction, "Leadership" = leadership, "Medical" = medical, "Surgery" = surgery, \
	"Piloting" = pilot, "Police" = police, "Powerloaders" = powerloader, "Large Vehicles" = large_vehicle)


/datum/skills/pfc
	name = "Private"
	//same as default


/datum/skills/civilian
	name = "Civilian"
	cqc = SKILL_CQC_WEAK
	firearms = SKILL_FIREARMS_UNTRAINED
	melee_weapons = SKILL_MELEE_WEAK

/datum/skills/civilian/survivor
	name = "Survivor"
	engineer = SKILL_ENGINEER_ENGI //to hack airlocks so they're never stuck in a room.
	construction = SKILL_CONSTRUCTION_METAL
	medical = SKILL_MEDICAL_NOVICE

/datum/skills/civilian/survivor/doctor
	name = "Survivor Doctor"
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_EXPERT

/datum/skills/civilian/survivor/scientist
	name = "Survivor Scientist"
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_PROFESSIONAL

/datum/skills/civilian/survivor/chef
	name = "Survivor Chef"
	melee_weapons = SKILL_MELEE_TRAINED

/datum/skills/civilian/survivor/miner
	name = "Survivor Miner"
	powerloader = SKILL_POWERLOADER_TRAINED

/datum/skills/civilian/survivor/atmos
	name = "Survivor Atmos Tech"
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_MASTER

/datum/skills/civilian/survivor/marshal
	name = "Survivor Marshal"
	cqc = SKILL_CQC_MP
	firearms = SKILL_FIREARMS_DEFAULT
	melee_weapons = SKILL_MELEE_DEFAULT
	pistols = SKILL_PISTOLS_TRAINED
	police = SKILL_POLICE_MP

/datum/skills/civilian/survivor/prisoner
	name = "Survivor Prisoner"
	cqc = SKILL_CQC_DEFAULT
	firearms = SKILL_FIREARMS_DEFAULT
	melee_weapons = SKILL_MELEE_DEFAULT
	pistols = SKILL_PISTOLS_DEFAULT

/datum/skills/civilian/survivor/clown
	name = "Survivor Clown"
	cqc = SKILL_CQC_MP
	melee_weapons = SKILL_MELEE_SUPER


/datum/skills/combat_engineer
	name = "Combat Engineer"
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_ADVANCED
	leadership = SKILL_LEAD_BEGINNER

/datum/skills/combat_medic
	name = "Combat Medic"
	leadership = SKILL_LEAD_BEGINNER
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_TRAINED

/datum/skills/combat_medic/crafty
	name = "Crafty Combat Medic"
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL

/datum/skills/doctor
	name = "Doctor"
	cqc = SKILL_CQC_WEAK
	firearms = SKILL_FIREARMS_UNTRAINED
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_EXPERT
	melee_weapons = SKILL_MELEE_WEAK

/datum/skills/CMO
	name = "CMO"
	cqc = SKILL_CQC_WEAK
	firearms = SKILL_FIREARMS_UNTRAINED
	leadership = SKILL_LEAD_TRAINED
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_EXPERT
	melee_weapons = SKILL_MELEE_WEAK
	police = SKILL_POLICE_FLASH

/datum/skills/synthetic
	name = "Synthetic"
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_MASTER
	firearms = SKILL_FIREARMS_TRAINED
	smartgun = SKILL_SMART_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_EXPERT
	pilot = SKILL_PILOT_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_MASTER
	large_vehicle = SKILL_LARGE_VEHICLE_TRAINED

/datum/skills/early_synthetic
	name = "Early Synthetic"
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_MASTER
	firearms = SKILL_FIREARMS_TRAINED
	smartgun = SKILL_SMART_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_PROFESSIONAL
	melee_weapons = SKILL_MELEE_SUPER
	pilot = SKILL_PILOT_TRAINED
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_TRAINED
	large_vehicle = SKILL_LARGE_VEHICLE_TRAINED


/datum/skills/captain
	name = "Captain"
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_ADVANCED
	smartgun = SKILL_SMART_TRAINED
	leadership = SKILL_LEAD_MASTER
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	police = SKILL_POLICE_FLASH
	powerloader = SKILL_POWERLOADER_TRAINED

/datum/skills/FO
	name = "Field Commander"
	engineer = SKILL_ENGINEER_ENGI //to fix CIC apc.
	construction = SKILL_CONSTRUCTION_PLASTEEL
	smartgun = SKILL_SMART_TRAINED
	leadership = SKILL_LEAD_MASTER
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	cqc = SKILL_CQC_TRAINED
	melee_weapons = SKILL_MELEE_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED


/datum/skills/SO
	name = "Intelligence Officer"
	construction = SKILL_CONSTRUCTION_PLASTEEL
	leadership = SKILL_LEAD_EXPERT
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR

/datum/skills/pilot
	name = "Pilot Officer"
	pilot = SKILL_PILOT_TRAINED
	powerloader = SKILL_POWERLOADER_PRO
	leadership = SKILL_LEAD_TRAINED

/datum/skills/MP
	name = "Military Police"
	cqc = SKILL_CQC_MP
	police = SKILL_POLICE_MP

/datum/skills/CMP
	name = "Command Master at Arms"
	cqc = SKILL_CQC_MP
	police = SKILL_POLICE_MP
	leadership = SKILL_LEAD_TRAINED

/datum/skills/CE
	name = "Chief Ship Engineer"
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_MASTER
	leadership = SKILL_LEAD_MASTER
	police = SKILL_POLICE_FLASH
	powerloader = SKILL_POWERLOADER_TRAINED

/datum/skills/RO
	name = "Requisition Officer"
	construction = SKILL_CONSTRUCTION_PLASTEEL
	leadership = SKILL_LEAD_TRAINED
	powerloader = SKILL_POWERLOADER_TRAINED

/datum/skills/MT
	name = "Ship Engineer"
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_MASTER
	powerloader = SKILL_POWERLOADER_MASTER

/datum/skills/CT
	name = "Cargo Technician"
	construction = SKILL_CONSTRUCTION_METAL
	powerloader = SKILL_POWERLOADER_PRO




/datum/skills/pfc/pmc
	name = "PMC Private"
	police = SKILL_POLICE_MP
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL


/datum/skills/pfc/crafty
	name = "Crafty Private"
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL




/datum/skills/SL
	name = "Squad Leader"
	cqc = SKILL_CQC_TRAINED
	construction = SKILL_CONSTRUCTION_PLASTEEL
	engineer = SKILL_ENGINEER_PLASTEEL
	leadership = SKILL_LEAD_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR



/datum/skills/SL/upp
	name = "UPP Leader"
	firearms = SKILL_FIREARMS_TRAINED
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED


/datum/skills/SL/pmc
	name = "PMC Leader"
	firearms = SKILL_FIREARMS_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	police = SKILL_POLICE_MP


/datum/skills/specialist
	name = "Squad Specialist"
	cqc = SKILL_CQC_TRAINED
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL //to use c4 in scout set.
	smartgun = SKILL_SMART_TRAINED
	leadership = SKILL_LEAD_BEGINNER
	spec_weapons = SKILL_SPEC_TRAINED
	melee_weapons = SKILL_MELEE_TRAINED

/datum/skills/specialist/pmc
	name = "PMC Specialist"
	police = SKILL_POLICE_MP


/datum/skills/specialist/upp
	name = "UPP Specialist"
	firearms = SKILL_FIREARMS_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED



/datum/skills/smartgunner
	name = "Squad Smartgunner"
	smartgun = SKILL_SMART_TRAINED
	leadership = SKILL_LEAD_BEGINNER

/datum/skills/smartgunner/pmc
	name = "PMC Smartgunner"
	cqc = SKILL_CQC_TRAINED
	construction = SKILL_CONSTRUCTION_METAL
	firearms = SKILL_FIREARMS_TRAINED
	smartgun = SKILL_SMART_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED
	leadership = SKILL_LEAD_BEGINNER
	melee_weapons = SKILL_MELEE_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	police = SKILL_POLICE_MP




/datum/skills/commando
	name = "Commando"
	cqc = 3
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_PLASTEEL
	firearms = SKILL_FIREARMS_TRAINED
	leadership = SKILL_LEAD_BEGINNER
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	melee_weapons = SKILL_MELEE_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED


/datum/skills/commando/medic
	name = "Commando Medic"
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_TRAINED

/datum/skills/commando/leader
	name ="Commando Leader"
	leadership = SKILL_LEAD_TRAINED

/datum/skills/commando/deathsquad
	name = "Deathsquad"
	cqc = SKILL_CQC_MASTER
	smartgun = SKILL_SMART_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_TRAINED



/datum/skills/mercenary
	name = "Mercenary"
	cqc = SKILL_CQC_MP
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_PLASTEEL
	firearms = SKILL_FIREARMS_TRAINED
	leadership = SKILL_LEAD_BEGINNER
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	melee_weapons = SKILL_MELEE_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED


/datum/skills/spy
	name = "Spy"
	cqc = SKILL_CQC_TRAINED
	firearms = SKILL_FIREARMS_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_ADVANCED
	leadership = SKILL_LEAD_BEGINNER
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	powerloader = SKILL_POWERLOADER_TRAINED


/datum/skills/admiral
	name = "Admiral"
	construction = SKILL_CONSTRUCTION_PLASTEEL
	leadership = SKILL_LEAD_MASTER
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	police = SKILL_POLICE_FLASH
	powerloader = SKILL_POWERLOADER_TRAINED


/datum/skills/ninja
	name = "Ninja"
	cqc = SKILL_CQC_MASTER
	construction = SKILL_CONSTRUCTION_METAL
	leadership = SKILL_LEAD_BEGINNER
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	melee_weapons = SKILL_MELEE_SUPER

/datum/skills/tank_crew
	name = "Tank Crew"
	large_vehicle = SKILL_LARGE_VEHICLE_TRAINED
	powerloader = SKILL_POWERLOADER_DABBLING
	leadership = SKILL_LEAD_TRAINED
	engineer = SKILL_ENGINEER_METAL

/datum/skills/spatial_agent
	name = "Spatial Agent"
	engineer = SKILL_ENGINEER_MT
	construction = SKILL_CONSTRUCTION_MASTER
	firearms = SKILL_FIREARMS_TRAINED
	smartgun = SKILL_SMART_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED
	medical = SKILL_MEDICAL_MASTER
	cqc = SKILL_CQC_MASTER
	surgery = SKILL_SURGERY_EXPERT
	melee_weapons = SKILL_MELEE_SUPER
	leadership = SKILL_LEAD_MASTER
	pilot = SKILL_PILOT_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_MASTER
	large_vehicle = SKILL_LARGE_VEHICLE_TRAINED

//======//I.o.M.\\======\\

/datum/skills/imperial
	name = "Guardsman"
	cqc = SKILL_CQC_TRAINED
	melee_weapons = SKILL_MELEE_TRAINED
	
	// guardsmen don't use pistol, so he doesn't have experience with them, unless they use boltpistols
	// shotguns too
	firearms = SKILL_FIREARMS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
     	// smgs too

/datum/skills/imperial/SL
	name = "Guardsman Sergeant" // veteran guardsman, practically better in all
	
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	smartgun = SKILL_SMART_USE // can use smartgun
	spec_weapons = SKILL_SPEC_TRAINED
	
	// higher SL skills
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_ADVANCED
	leadership = SKILL_LEAD_EXPERT
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_TRAINED

/datum/skills/imperial/medicae
	name = "Guardsman Medicae" // medic
	leadership = SKILL_LEAD_BEGINNER // normal medics have it
	medical = SKILL_MEDICAL_COMPETENT // was told to add skills
	surgery = SKILL_SURGERY_PROFESSIONAL

/datum/skills/imperial/astartes
	name = "Space Marine" // practically a god
	cqc = SKILL_CQC_MASTER
	melee_weapons = SKILL_MELEE_SUPER // chainswords are literally used about the same or more than their boltpistols

	firearms = SKILL_FIREARMS_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	smgs = SKILL_SMGS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
	smartgun = SKILL_SMART_TRAINED
	spec_weapons = SKILL_SPEC_TRAINED

	//endurance = 0 - does nothing
	engineer = SKILL_ENGINEER_PLASTEEL
	construction = SKILL_CONSTRUCTION_PLASTEEL
	leadership = SKILL_LEAD_TRAINED
	medical = SKILL_MEDICAL_NOVICE
	surgery = SKILL_SURGERY_AMATEUR
	powerloader = SKILL_POWERLOADER_DABBLING

/datum/skills/imperial/astartes/apothecary
	name = "Space Marine Apothecary" // a slightly less stronger space marine with medical skills
	cqc = 4 // below SKILL_CQC_MASTER, no define for it
	melee_weapons = SKILL_MELEE_TRAINED
	
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_EXPERT

