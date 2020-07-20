#define SKILLSID "skills-[cqc]-[melee_weapons]\
-[firearms]-[pistols]-[shotguns]-[rifles]-[smgs]-[heavy_weapons]-[smartgun]-[spec_weapons]\
-[engineer]-[construction]-[leadership]-[medical]-[surgery]-[pilot]-[police]-[powerloader]-[large_vehicle]"

#define SKILLSIDSRC(S) "skills-[S.cqc]-[S.melee_weapons]\
-[S.firearms]-[S.pistols]-[S.shotguns]-[S.rifles]-[S.smgs]-[S.heavy_weapons]-[S.smartgun]-[S.spec_weapons]\
-[S.engineer]-[S.construction]-[S.leadership]-[S.medical]-[S.surgery]-[S.pilot]-[S.police]-[S.powerloader]-[S.large_vehicle]"

/proc/getSkills(cqc = 0, melee_weapons = 0,\
firearms = 0, pistols = 0, shotguns = 0, rifles = 0, smgs = 0, heavy_weapons = 0, smartgun = 0, spec_weapons = 0,\
engineer = 0, construction = 0, leadership = 0, medical = 0, surgery = 0, pilot = 0, police = 0, powerloader = 0, large_vehicle = 0)
	. = locate(SKILLSID)
	if(!.)
		. = new /datum/skills(cqc, melee_weapons,\
			firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, spec_weapons,\
			engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle)

/proc/getSkillsType(skills_type = /datum/skills)
	var/datum/skills/new_skill = skills_type
	var/cqc = initial(new_skill.cqc)
	var/melee_weapons = initial(new_skill.melee_weapons)
	var/firearms = initial(new_skill.firearms)
	var/pistols = initial(new_skill.pistols)
	var/shotguns = initial(new_skill.shotguns)
	var/rifles = initial(new_skill.rifles)
	var/smgs = initial(new_skill.smgs)
	var/heavy_weapons = initial(new_skill.heavy_weapons)
	var/smartgun = initial(new_skill.smartgun)
	var/spec_weapons = initial(new_skill.spec_weapons)
	var/engineer = initial(new_skill.engineer)
	var/construction = initial(new_skill.construction)
	var/leadership = initial(new_skill.leadership)
	var/medical = initial(new_skill.medical)
	var/surgery = initial(new_skill.surgery)
	var/pilot = initial(new_skill.pilot)
	var/police = initial(new_skill.police)
	var/powerloader = initial(new_skill.powerloader)
	var/large_vehicle = initial(new_skill.large_vehicle)
	. = locate(SKILLSID)
	if(!.)
		. = new skills_type

/datum/skills
	datum_flags = DF_USE_TAG
	var/name = "Default/Custom"
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


/datum/skills/New(cqc, melee_weapons,\
firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, spec_weapons,\
engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle)
	if(!isnull(cqc))
		src.cqc = cqc
	if(!isnull(melee_weapons))
		src.melee_weapons = melee_weapons
	if(!isnull(firearms))
		src.firearms = firearms
	if(!isnull(pistols))
		src.pistols = pistols
	if(!isnull(shotguns))
		src.shotguns = shotguns
	if(!isnull(rifles))
		src.rifles = rifles
	if(!isnull(smgs))
		src.smgs = smgs
	if(!isnull(heavy_weapons))
		src.heavy_weapons = heavy_weapons
	if(!isnull(smartgun))
		src.smartgun = smartgun
	if(!isnull(spec_weapons))
		src.spec_weapons = spec_weapons
	if(!isnull(engineer))
		src.engineer = engineer
	if(!isnull(construction))
		src.construction = construction
	if(!isnull(leadership))
		src.leadership = leadership
	if(!isnull(medical))
		src.medical = medical
	if(!isnull(surgery))
		src.surgery = surgery
	if(!isnull(pilot))
		src.pilot = pilot
	if(!isnull(police))
		src.police = police
	if(!isnull(powerloader))
		src.powerloader = powerloader
	if(!isnull(large_vehicle))
		src.large_vehicle = large_vehicle
	tag = SKILLSIDSRC(src)

/datum/skills/proc/modifyRating(cqc, melee_weapons,\
firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, spec_weapons,\
engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle)
	return getSkills(src.cqc+cqc,\
	src.melee_weapons+melee_weapons,\
	src.firearms+firearms,\
	src.pistols+pistols,\
	src.shotguns+shotguns,\
	src.rifles+rifles,\
	src.smgs+smgs,\
	src.heavy_weapons+heavy_weapons,\
	src.smartgun+smartgun,\
	src.spec_weapons+spec_weapons,\
	src.engineer+engineer,\
	src.construction+construction,\
	src.leadership+leadership,\
	src.medical+medical,\
	src.surgery+surgery,\
	src.pilot+pilot,\
	src.police+police,\
	src.powerloader+powerloader,\
	src.large_vehicle+large_vehicle)

/datum/skills/proc/setRating(cqc, melee_weapons,\
firearms, pistols, shotguns, rifles, smgs, heavy_weapons, smartgun, spec_weapons,\
engineer, construction, leadership, medical, surgery, pilot, police, powerloader, large_vehicle)
	return getSkills((isnull(cqc) ? src.cqc : cqc),\
		(isnull(melee_weapons) ? src.melee_weapons : melee_weapons),\
		(isnull(firearms) ? src.firearms : firearms),\
		(isnull(pistols) ? src.pistols : pistols),\
		(isnull(shotguns) ? src.shotguns : shotguns),\
		(isnull(rifles) ? src.rifles : rifles),\
		(isnull(smgs) ? src.smgs : smgs),\
		(isnull(heavy_weapons) ? src.heavy_weapons : heavy_weapons),\
		(isnull(smartgun) ? src.smartgun : smartgun),\
		(isnull(spec_weapons) ? src.spec_weapons : spec_weapons),\
		(isnull(engineer) ? src.engineer : engineer),\
		(isnull(construction) ? src.construction : construction),\
		(isnull(leadership) ? src.leadership : leadership),\
		(isnull(medical) ? src.medical : medical),\
		(isnull(surgery) ? src.surgery : surgery),\
		(isnull(pilot) ? src.pilot : pilot),\
		(isnull(police) ? src.police : police),\
		(isnull(powerloader) ? src.powerloader : powerloader),\
		(isnull(large_vehicle) ? src.large_vehicle : large_vehicle))

/datum/skills/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = SKILLSID

#undef SKILLSID

/datum/skills/proc/getRating(rating)
	return vars[rating]

/datum/skills/proc/getList()
	return list("cqc" = cqc,\
		"melee_weapons" = melee_weapons,\
		"firearms" = firearms,\
		"pistols" = pistols,\
		"shotguns" = shotguns,\
		"rifles" = rifles,\
		"smgs" = smgs,\
		"heavy_weapons" = heavy_weapons,\
		"spec_weapons" = spec_weapons,\
		"smartgun" = smartgun,\
		"engineer" = engineer,\
		"construction" = construction,\
		"leadership" = leadership,\
		"medical" = medical,\
		"surgery" = surgery,\
		"pilot" = pilot,\
		"police" = police,\
		"powerloader" = powerloader,\
		"large_vehicle" = large_vehicle)

/datum/skills/civilian
	name = "Civilian"
	cqc = SKILL_CQC_WEAK
	firearms = SKILL_FIREARMS_UNTRAINED
	melee_weapons = SKILL_MELEE_WEAK

/datum/skills/civilian/survivor
	name = "Survivor"
	engineer = SKILL_ENGINEER_ENGI //to hack airlocks so they're never stuck in a room.
	firearms = SKILL_FIREARMS_DEFAULT
	construction = SKILL_CONSTRUCTION_METAL
	medical = SKILL_MEDICAL_NOVICE

/datum/skills/civilian/survivor/master
	name = "Survivor"
	firearms = SKILL_FIREARMS_DEFAULT
	medical = SKILL_MEDICAL_EXPERT
	surgery = SKILL_SURGERY_EXPERT
	construction = SKILL_CONSTRUCTION_MASTER
	engineer = SKILL_ENGINEER_MASTER
	powerloader = SKILL_POWERLOADER_MASTER
	police = SKILL_POLICE_FLASH

/datum/skills/civilian/survivor/doctor
	name = "Survivor Doctor"
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_EXPERT
	firearms = SKILL_FIREARMS_UNTRAINED

/datum/skills/civilian/survivor/scientist
	name = "Survivor Scientist"
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_PROFESSIONAL
	firearms = SKILL_FIREARMS_UNTRAINED

/datum/skills/civilian/survivor/chef
	name = "Survivor Chef"
	melee_weapons = SKILL_MELEE_TRAINED
	firearms = SKILL_FIREARMS_UNTRAINED

/datum/skills/civilian/survivor/miner
	name = "Survivor Miner"
	powerloader = SKILL_POWERLOADER_TRAINED

/datum/skills/civilian/survivor/atmos
	name = "Survivor Atmos Tech"
	engineer = SKILL_ENGINEER_MASTER
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
	firearms = SKILL_FIREARMS_UNTRAINED

/datum/skills/combat_engineer
	name = "Combat Engineer"
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_ADVANCED
	leadership = SKILL_LEAD_BEGINNER
	powerloader = SKILL_POWERLOADER_DABBLING

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
	name = SYNTHETIC
	engineer = SKILL_ENGINEER_MASTER
	construction = SKILL_CONSTRUCTION_MASTER
	firearms = SKILL_FIREARMS_UNTRAINED
	medical = SKILL_MEDICAL_EXPERT
	cqc = SKILL_CQC_MASTER
	surgery = SKILL_SURGERY_EXPERT
	pilot = SKILL_PILOT_TRAINED
	melee_weapons = SKILL_MELEE_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_MASTER
	large_vehicle = SKILL_LARGE_VEHICLE_TRAINED

/datum/skills/early_synthetic
	name = "Early Synthetic"
	engineer = SKILL_ENGINEER_MASTER
	construction = SKILL_CONSTRUCTION_MASTER
	firearms = SKILL_FIREARMS_UNTRAINED
	medical = SKILL_MEDICAL_COMPETENT
	cqc = SKILL_CQC_MASTER
	surgery = SKILL_SURGERY_PROFESSIONAL
	melee_weapons = SKILL_MELEE_SUPER
	pilot = SKILL_PILOT_TRAINED
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_MASTER
	large_vehicle = SKILL_LARGE_VEHICLE_TRAINED

/datum/skills/captain
	name = CAPTAIN
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_ADVANCED
	smartgun = SKILL_SMART_TRAINED
	leadership = SKILL_LEAD_MASTER
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	police = SKILL_POLICE_MP
	powerloader = SKILL_POWERLOADER_TRAINED

/datum/skills/FO
	name = FIELD_COMMANDER
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
	name = STAFF_OFFICER
	construction = SKILL_CONSTRUCTION_PLASTEEL
	leadership = SKILL_LEAD_EXPERT
	medical = SKILL_MEDICAL_PRACTICED
	surgery = SKILL_SURGERY_AMATEUR
	police = SKILL_POLICE_FLASH

/datum/skills/pilot
	name = PILOT_OFFICER
	pilot = SKILL_PILOT_TRAINED
	powerloader = SKILL_POWERLOADER_PRO
	leadership = SKILL_LEAD_TRAINED

/datum/skills/CE
	name = CHIEF_SHIP_ENGINEER
	engineer = SKILL_ENGINEER_MASTER
	construction = SKILL_CONSTRUCTION_MASTER
	leadership = SKILL_LEAD_MASTER
	police = SKILL_POLICE_FLASH
	powerloader = SKILL_POWERLOADER_MASTER

/datum/skills/RO
	name = "Requisition Officer"
	construction = SKILL_CONSTRUCTION_PLASTEEL
	leadership = SKILL_LEAD_TRAINED
	powerloader = SKILL_POWERLOADER_MASTER
	police = SKILL_POLICE_MP//You broke into the wrong req bucko

/datum/skills/ST
	name = SHIP_TECH
	engineer = SKILL_ENGINEER_MASTER
	construction = SKILL_CONSTRUCTION_MASTER
	powerloader = SKILL_POWERLOADER_MASTER

/datum/skills/pmc
	name = "PMC Private"
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL

/datum/skills/crafty
	name = "Crafty Private"
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL

/datum/skills/SL
	name = SQUAD_LEADER
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

/datum/skills/specialist
	name = SQUAD_SPECIALIST
	cqc = SKILL_CQC_TRAINED
	construction = SKILL_CONSTRUCTION_METAL
	engineer = SKILL_ENGINEER_METAL //to use c4 in scout set.
	smartgun = SKILL_SMART_TRAINED
	leadership = SKILL_LEAD_BEGINNER
	spec_weapons = SKILL_SPEC_TRAINED
	melee_weapons = SKILL_MELEE_TRAINED

/datum/skills/specialist/pmc
	name = "PMC Specialist"
	engineer = SKILL_ENGINEER_METAL

/datum/skills/specialist/upp
	name = "UPP Specialist"
	firearms = SKILL_FIREARMS_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED

/datum/skills/smartgunner
	name = SQUAD_SMARTGUNNER
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
	engineer = SKILL_ENGINEER_MASTER
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
	engineer = SKILL_ENGINEER_MASTER
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


/datum/skills/sectoid
	name = "Sectoid"

	cqc = SKILL_CQC_TRAINED
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_PLASTEEL
	firearms = SKILL_FIREARMS_TRAINED
	medical = SKILL_MEDICAL_COMPETENT
	surgery = SKILL_SURGERY_EXPERT//how else will they probe marines?
	melee_weapons = SKILL_MELEE_TRAINED
	pistols = SKILL_PISTOLS_TRAINED
	smgs = SKILL_SMGS_TRAINED
	rifles = SKILL_RIFLES_TRAINED
	shotguns = SKILL_SHOTGUNS_TRAINED
	heavy_weapons = SKILL_HEAVY_WEAPONS_TRAINED
