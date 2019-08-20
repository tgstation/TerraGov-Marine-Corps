/datum/skills
	var/name = "Unassigned" //the name of the skills datum.
	var/datum/mind/owner
	var/datum/skillset/skillset

	var/list/skill_list = ALL_SKILL_TYPES

	var/list/skill_mods //contains the total skill modifier values. refer to __DEFINES/skills.dm for its usage in the macros.
	var/list/skill_mod_ids //contains the applied skill modifier IDs, sorted by skill. used in macros too.

	//used on /mob/proc/check_skills()
	var/cached_skills_dat

	//used to allow observers to bypass possible skill checks mainly found on examine().
	var/omnighost = FALSE

/datum/skills/New(mob/target, datum/skillset/S)
	if(!target)
		stack_trace("[type] created without an assigned mind owner arg.")
		return
	owner = target
	if(owner.current)
		owner.current += /mob/proc/check_skills
	for(var/A in skill_list)
		skill_list[A] = SKILL_LEVEL_NONE

/datum/skills/Destroy()
	if(owner)
		if(owner.current)
			owner.current -= /mob/proc/check_skills
		owner.cm_skills = null
		owner = null
	return ..()

/datum/skills/proc/add_skill_mod(skills, id, mod)
	if(!mod)
		return
	var/list/L = islist(skills) ? skills : list(skills)
	LAZYINITLIST(skill_mods)
	LAZYINITLIST(skill_mod_ids)
	for(var/A in L)
		LAZYINITLIST(skill_mod_ids[A])
		if(skill_mod_ids[A][id])
			continue
		skill_mods[A] += mod
		skill_mod_ids[A][id] = mod
		cached_skills_dat = null

/datum/skills/proc/remove_skill_mod(skills, id)
	if(!skill_mod_ids)
		return
	var/list/L = islist(skills) ? skills : list(skills)
	for(var/A in L)
		var/V = LAZYACCESS(skill_mod_ids[A], id)
		if(V)
			LAZYREMOVE(skill_mods[A], V)
			LAZYREMOVE(skill_mod_ids[A], id)
			cached_skills_dat = null
			if(!LAZYLEN(skill_mods))
				skill_mods = null
				skill_mod_ids = null

/datum/skills/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		if(var_name != NAMEOF(src, cached_skills_dat)) //so the check_skills() list can update.
			cached_skills_dat = null

/mob/proc/check_skills()
	set category = "IC"
	set name = "Check Skills"

	var/dat
	if(!mind)
		dat += "You have no mind!"
	else if(!mind.cm_skills)
		dat += "You don't have any skills restrictions. Enjoy."
	else
		var/datum/skills/S = mind.cm_skills
		if(S.cached_skills_dat)
			dat = S.cached_skills_dat
		else
			if(!S.skillset && !S.skill_mods)
				dat += "You are seemengly devoid of any sort of skill."
			else
				for(var/index in ALL_SKILL_TYPES)
					var/value = S.skillset[index]
					var/font_color
					if(S.skill_mods)
						value += S.skill_mods[index]
						font_color = S.skill_mods > 0 ? "#29b245" : "#ff0000"
					dat += "[index]: [font_color ? "<font color='#487553'><b>[value]</b></font>" : value]<br>"
			S.cached_skills_dat = dat

	var/datum/browser/popup = new(src, "skills", "<div align='center'>Skills</div>", 300, 600)
	popup.set_content(dat)
	popup.open(FALSE)


//skillset datums used to set the user's mind's skills, currently used on job initialization and changes, preverving skill mods.
/datum/skillset
	var/name

	var/cqc = SKILL_LEVEL_NONE
	var/melee_weapons = SKILL_LEVEL_NONE
	var/firearms = SKILL_LEVEL_TRAINED
	var/pistols = SKILL_LEVEL_NONE
	var/shotguns = SKILL_LEVEL_NONE
	var/rifles = SKILL_LEVEL_NONE
	var/smgs = SKILL_LEVEL_NONE
	var/heavy_weapons = SKILL_LEVEL_NONE
	var/smartgun = SKILL_LEVEL_INCOMPETENT
	var/spec_weapons = SKILL_LEVEL_INCOMPETENT
	var/engineer = SKILL_LEVEL_NONE
	var/construction = SKILL_LEVEL_NONE
	var/leadership = SKILL_LEVEL_NONE
	var/medical = SKILL_LEVEL_NONE
	var/surgery = SKILL_LEVEL_NONE
	var/pilot = SKILL_LEVEL_NONE
	var/police = SKILL_LEVEL_NONE
	var/powerloader = SKILL_LEVEL_NONE
	var/large_vehicle = SKILL_LEVEL_NONE

/datum/skillset/proc/on_gain(datum/skills/S)
	set_skills(S)
	S.skillset = src

/datum/skillset/proc/on_loss(datum/skills/S)
	set_skills(S, TRUE)
	S.skillset = null

//It doesn't look neat, but couldn't think of a better solution that can preserve both potential "jobless/special" skills and the order of the base list.
/datum/skillset/proc/set_skills(datum/skills/S, remove = FALSE)
	if(!S)
		return

	S.name = remove ? "Unassigned" : name
	var/sign = remove ? -1 : 1
	S.skill_list[SKILL_CQC] += cqc * sign
	S.skill_list[SKILL_MELEE] += melee_weapons * sign
	S.skill_list[SKILL_FIREARMS] += firearms * sign
	S.skill_list[SKILL_PISTOLS] += pistols * sign
	S.skill_list[SKILL_SHOTGUNS] += shotguns * sign
	S.skill_list[SKILL_RIFLES] += rifles * sign
	S.skill_list[SKILL_SMG] += smgs * sign
	S.skill_list[SKILL_HEAVY_WEAPONS] += heavy_weapons * sign
	S.skill_list[SKILL_SMARTGUN] += smartgun * sign
	S.skill_list[SKILL_SPEC_WEAPONS] += spec_weapons * sign
	S.skill_list[SKILL_ENGINEERING] += engineer * sign
	S.skill_list[SKILL_CONSTRUCTION] += construction * sign
	S.skill_list[SKILL_LEADERSHIP] += leadership * sign
	S.skill_list[SKILL_MEDICAL] += medical * sign
	S.skill_list[SKILL_SURGERY] += surgery * sign
	S.skill_list[SKILL_PILOTING] += pilot * sign
	S.skill_list[SKILL_POLICE] += police * sign
	S.skill_list[SKILL_POWERLOADERS] += powerloader * sign
	S.skill_list[SKILL_LARGE_VEHICLES] += large_vehicle * sign


/datum/skillset/pfc
	name = "Private"
	//same as default

/datum/skillset/civilian
	name = "Civilian"
	cqc = SKILL_LEVEL_INCOMPETENT
	firearms = SKILL_LEVEL_NONE
	melee_weapons = SKILL_LEVEL_INCOMPETENT

/datum/skillset/civilian/survivor
	name = "Survivor"
	engineer = SKILL_LEVEL_PROFESSIONAL //to hack airlocks so they're never stuck in a room.
	firearms = SKILL_LEVEL_TRAINED
	construction = SKILL_LEVEL_NOVICE
	medical = SKILL_LEVEL_NOVICE

/datum/skillset/civilian/survivor/doctor
	name = "Survivor Doctor"
	medical = SKILL_LEVEL_PROFESSIONAL
	surgery = SKILL_LEVEL_EXPERT
	firearms = SKILL_LEVEL_NONE

/datum/skillset/civilian/survivor/scientist
	name = "Survivor Scientist"
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_PROFESSIONAL
	firearms = SKILL_LEVEL_NONE

/datum/skillset/civilian/survivor/chef
	name = "Survivor Chef"
	melee_weapons = SKILL_LEVEL_TRAINED
	firearms = SKILL_LEVEL_NONE

/datum/skillset/civilian/survivor/miner
	name = "Survivor Miner"
	powerloader = SKILL_LEVEL_TRAINED

/datum/skillset/civilian/survivor/atmos
	name = "Survivor Atmos Tech"
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_EXPERT

/datum/skillset/civilian/survivor/marshal
	name = "Survivor Marshal"
	cqc = SKILL_LEVEL_TRAINED
	firearms = SKILL_LEVEL_TRAINED
	melee_weapons = SKILL_LEVEL_NONE
	pistols = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED

/datum/skillset/civilian/survivor/prisoner
	name = "Survivor Prisoner"
	cqc = SKILL_LEVEL_NONE
	firearms = SKILL_LEVEL_TRAINED
	melee_weapons = SKILL_LEVEL_NONE
	pistols = SKILL_LEVEL_NONE

/datum/skillset/civilian/survivor/clown
	name = "Survivor Clown"
	cqc = SKILL_LEVEL_TRAINED
	melee_weapons = SKILL_LEVEL_PROFESSIONAL
	firearms = SKILL_LEVEL_NONE


/datum/skillset/combat_engineer
	name = "Combat Engineer"
	engineer = SKILL_LEVEL_PROFESSIONAL
	construction = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_NOVICE

/datum/skillset/combat_medic
	name = "Combat Medic"
	leadership = SKILL_LEVEL_NOVICE
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_TRAINED

/datum/skillset/combat_medic/crafty
	name = "Crafty Combat Medic"
	construction = SKILL_LEVEL_NOVICE
	engineer = SKILL_LEVEL_NOVICE

/datum/skillset/doctor
	name = "Doctor"
	cqc = SKILL_LEVEL_INCOMPETENT
	firearms = SKILL_LEVEL_NONE
	medical = SKILL_LEVEL_EXPERT
	surgery = SKILL_LEVEL_EXPERT
	melee_weapons = SKILL_LEVEL_INCOMPETENT

/datum/skillset/CMO
	name = "CMO"
	cqc = SKILL_LEVEL_INCOMPETENT
	firearms = SKILL_LEVEL_NONE
	leadership = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_EXPERT
	surgery = SKILL_LEVEL_EXPERT
	melee_weapons = SKILL_LEVEL_INCOMPETENT
	police = SKILL_LEVEL_NOVICE

/datum/skillset/synthetic
	name = SYNTHETIC
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_EXPERT
	firearms = SKILL_LEVEL_PROFESSIONAL
	smartgun = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_EXPERT
	surgery = SKILL_LEVEL_EXPERT
	pilot = SKILL_LEVEL_TRAINED
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_EXPERT
	large_vehicle = SKILL_LEVEL_TRAINED

/datum/skillset/early_synthetic
	name = "Early Synthetic"
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_EXPERT
	firearms = SKILL_LEVEL_PROFESSIONAL
	smartgun = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_PROFESSIONAL
	surgery = SKILL_LEVEL_PROFESSIONAL
	melee_weapons = SKILL_LEVEL_PROFESSIONAL
	pilot = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_TRAINED
	large_vehicle = SKILL_LEVEL_TRAINED


/datum/skillset/captain
	name = CAPTAIN
	engineer = SKILL_LEVEL_PROFESSIONAL
	construction = SKILL_LEVEL_PROFESSIONAL
	smartgun = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_EXPERT
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_NOVICE
	police = SKILL_LEVEL_NOVICE
	powerloader = SKILL_LEVEL_TRAINED

/datum/skillset/FO
	name = FIELD_COMMANDER
	engineer = SKILL_LEVEL_PROFESSIONAL //to fix CIC apc.
	construction = SKILL_LEVEL_TRAINED
	smartgun = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_EXPERT
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_NOVICE
	police = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_TRAINED
	pistols = SKILL_LEVEL_TRAINED
	cqc = SKILL_LEVEL_NOVICE
	melee_weapons = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED


/datum/skillset/SO
	name = STAFF_OFFICER
	construction = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_PROFESSIONAL
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_NOVICE

/datum/skillset/pilot
	name = PILOT_OFFICER
	pilot = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_TRAINED

/datum/skillset/MP
	name = "Military Police"
	cqc = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED

/datum/skillset/CMP
	name = COMMAND_MASTER_AT_ARMS
	cqc = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_TRAINED

/datum/skillset/CE
	name = CHIEF_SHIP_ENGINEER
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_EXPERT
	leadership = SKILL_LEVEL_EXPERT
	police = SKILL_LEVEL_NOVICE
	powerloader = SKILL_LEVEL_TRAINED

/datum/skillset/RO
	name = "Requisition Officer"
	construction = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_TRAINED

/datum/skillset/MT
	name = SHIP_ENGINEER
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_EXPERT
	powerloader = SKILL_LEVEL_EXPERT

/datum/skillset/CT
	name = CARGO_TECHNICIAN
	construction = SKILL_LEVEL_NOVICE
	powerloader = SKILL_LEVEL_PROFESSIONAL




/datum/skillset/pfc/pmc
	name = "PMC Private"
	police = SKILL_LEVEL_TRAINED
	construction = SKILL_LEVEL_NOVICE
	engineer = SKILL_LEVEL_NOVICE


/datum/skillset/pfc/crafty
	name = "Crafty Private"
	construction = SKILL_LEVEL_NOVICE
	engineer = SKILL_LEVEL_NOVICE




/datum/skillset/SL
	name = SQUAD_LEADER
	cqc = SKILL_LEVEL_NOVICE
	construction = SKILL_LEVEL_TRAINED
	engineer = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_NOVICE
	surgery = SKILL_LEVEL_NOVICE



/datum/skillset/SL/upp
	name = "UPP Leader"
	firearms = SKILL_LEVEL_PROFESSIONAL
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_NOVICE
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED


/datum/skillset/SL/pmc
	name = "PMC Leader"
	firearms = SKILL_LEVEL_PROFESSIONAL
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED


/datum/skillset/specialist
	name = SQUAD_SPECIALIST
	cqc = SKILL_LEVEL_NOVICE
	construction = SKILL_LEVEL_NOVICE
	engineer = SKILL_LEVEL_NOVICE //to use c4 in scout set.
	smartgun = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_NOVICE
	spec_weapons = SKILL_LEVEL_TRAINED
	melee_weapons = SKILL_LEVEL_TRAINED

/datum/skillset/specialist/pmc
	name = "PMC Specialist"
	police = SKILL_LEVEL_TRAINED


/datum/skillset/specialist/upp
	name = "UPP Specialist"
	firearms = SKILL_LEVEL_PROFESSIONAL
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED



/datum/skillset/smartgunner
	name = SQUAD_SMARTGUNNER
	smartgun = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_NOVICE

/datum/skillset/smartgunner/pmc
	name = "PMC Smartgunner"
	cqc = SKILL_LEVEL_NOVICE
	construction = SKILL_LEVEL_NOVICE
	firearms = SKILL_LEVEL_PROFESSIONAL
	smartgun = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_NOVICE
	melee_weapons = SKILL_LEVEL_TRAINED
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED




/datum/skillset/commando
	name = "Commando"
	cqc = 3
	engineer = SKILL_LEVEL_PROFESSIONAL
	construction = SKILL_LEVEL_TRAINED
	firearms = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_NOVICE
	medical = SKILL_LEVEL_NOVICE
	surgery = SKILL_LEVEL_NOVICE
	melee_weapons = SKILL_LEVEL_TRAINED
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED


/datum/skillset/commando/medic
	name = "Commando Medic"
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_TRAINED

/datum/skillset/commando/leader
	name ="Commando Leader"
	leadership = SKILL_LEVEL_TRAINED

/datum/skillset/commando/deathsquad
	name = "Deathsquad"
	cqc = SKILL_LEVEL_MASTER
	smartgun = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_TRAINED



/datum/skillset/mercenary
	name = "Mercenary"
	cqc = SKILL_LEVEL_TRAINED
	engineer = SKILL_LEVEL_PROFESSIONAL
	construction = SKILL_LEVEL_TRAINED
	firearms = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_NOVICE
	medical = SKILL_LEVEL_NOVICE
	surgery = SKILL_LEVEL_NOVICE
	melee_weapons = SKILL_LEVEL_TRAINED
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED


/datum/skillset/spy
	name = "Spy"
	cqc = SKILL_LEVEL_NOVICE
	firearms = SKILL_LEVEL_PROFESSIONAL
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_NOVICE
	medical = SKILL_LEVEL_NOVICE
	surgery = SKILL_LEVEL_NOVICE
	powerloader = SKILL_LEVEL_TRAINED


/datum/skillset/admiral
	name = "Admiral"
	construction = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_EXPERT
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_NOVICE
	police = SKILL_LEVEL_NOVICE
	powerloader = SKILL_LEVEL_TRAINED


/datum/skillset/ninja
	name = "Ninja"
	cqc = SKILL_LEVEL_MASTER
	construction = SKILL_LEVEL_NOVICE
	leadership = SKILL_LEVEL_NOVICE
	medical = SKILL_LEVEL_NOVICE
	surgery = SKILL_LEVEL_NOVICE
	melee_weapons = SKILL_LEVEL_PROFESSIONAL

/datum/skillset/tank_crew
	name = "Tank Crew"
	large_vehicle = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_NOVICE
	leadership = SKILL_LEVEL_TRAINED
	engineer = SKILL_LEVEL_NOVICE

/datum/skillset/spatial_agent
	name = "Spatial Agent"
	engineer = SKILL_LEVEL_EXPERT
	construction = SKILL_LEVEL_EXPERT
	firearms = SKILL_LEVEL_PROFESSIONAL
	smartgun = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_MASTER
	cqc = SKILL_LEVEL_MASTER
	surgery = SKILL_LEVEL_EXPERT
	melee_weapons = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_EXPERT
	pilot = SKILL_LEVEL_TRAINED
	pistols = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED
	police = SKILL_LEVEL_TRAINED
	powerloader = SKILL_LEVEL_EXPERT
	large_vehicle = SKILL_LEVEL_TRAINED

//======//I.o.M.\\======\\

/datum/skillset/imperial
	name = "Guardsman"
	cqc = SKILL_LEVEL_NOVICE
	melee_weapons = SKILL_LEVEL_TRAINED
	
	// guardsmen don't use pistol, so he doesn't have experience with them, unless they use boltpistols
	// shotguns too
	firearms = SKILL_LEVEL_PROFESSIONAL
	rifles = SKILL_LEVEL_TRAINED
	// smgs too

/datum/skillset/imperial/SL
	name = "Guardsman Sergeant" // veteran guardsman, practically better in all
	
	heavy_weapons = SKILL_LEVEL_TRAINED
	smartgun = SKILL_LEVEL_NONE // can use smartgun
	spec_weapons = SKILL_LEVEL_TRAINED
	
	// higher SL skills
	engineer = SKILL_LEVEL_PROFESSIONAL
	construction = SKILL_LEVEL_PROFESSIONAL
	leadership = SKILL_LEVEL_PROFESSIONAL
	medical = SKILL_LEVEL_TRAINED
	surgery = SKILL_LEVEL_TRAINED

/datum/skillset/imperial/medicae
	name = "Guardsman Medicae" // medic
	leadership = SKILL_LEVEL_NOVICE // normal medics have it
	medical = SKILL_LEVEL_PROFESSIONAL // was told to add skills
	surgery = SKILL_LEVEL_PROFESSIONAL

/datum/skillset/imperial/astartes
	name = "Space Marine" // practically a god
	cqc = SKILL_LEVEL_MASTER
	melee_weapons = SKILL_LEVEL_MASTER // chainswords are literally used about the same or more than their boltpistols

	firearms = SKILL_LEVEL_PROFESSIONAL
	pistols = SKILL_LEVEL_TRAINED
	shotguns = SKILL_LEVEL_TRAINED
	rifles = SKILL_LEVEL_TRAINED
	smgs = SKILL_LEVEL_TRAINED
	heavy_weapons = SKILL_LEVEL_TRAINED
	smartgun = SKILL_LEVEL_TRAINED
	spec_weapons = SKILL_LEVEL_TRAINED

	//endurance = 0 - does nothing
	engineer = SKILL_LEVEL_TRAINED
	construction = SKILL_LEVEL_TRAINED
	leadership = SKILL_LEVEL_TRAINED
	medical = SKILL_LEVEL_NOVICE
	surgery = SKILL_LEVEL_NOVICE
	powerloader = SKILL_LEVEL_NOVICE

/datum/skillset/imperial/astartes/apothecary
	name = "Space Marine Apothecary" // a slightly less stronger space marine with medical skills
	cqc = SKILL_LEVEL_EXPERT
	melee_weapons = SKILL_LEVEL_TRAINED
	
	medical = SKILL_LEVEL_EXPERT
	surgery = SKILL_LEVEL_EXPERT

