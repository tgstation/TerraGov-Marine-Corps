//skill types
#define SKILL_CQC "Close Quarter Combat"
#define SKILL_MELEE "Melee Weapons"
#define SKILL_FIREARMS "Firearms"
#define SKILL_PISTOLS "Pistols"
#define SKILL_SHOTGUNS "Shotguns"
#define SKILL_RIFLES "Rifles"
#define SKILL_SMG "Submachine Guns"
#define SKILL_HEAVY_WEAPONS "Heavy Weapons"
#define SKILL_SMARTGUN "Smartgun"
#define SKILL_SPEC_WEAPONS "Specialist Weapons"
#define SKILL_ENGINEERING "Engineering"
#define SKILL_CONSTRUCTION "Construction"
#define SKILL_LEADERSHIP "Leadership"
#define SKILL_MEDICAL "Medical"
#define SKILL_SURGERY "Surgery"
#define SKILL_PILOTING "Piloting"
#define SKILL_POLICE "Police"
#define SKILL_POWERLOADERS "Powerloaders"
#define SKILL_LARGE_VEHICLES "Large Vehicles"

#define AMT_SKILL_TYPES 19 //keep these two updaed with each new skill added, thanks.

#define ALL_SKILL_TYPES list(SKILL_CQC, SKILL_MELEE, SKILL_FIREARMS, SKILL_PISTOLS, SKILL_SHOTGUNS,\
								SKILL_RIFLES, SKILL_SMG, SKILL_HEAVY_WEAPONS, SKILL_SMARTGUN, SKILL_SPEC_WEAPONS, \
								SKILL_ENGINEERING, SKILL_CONSTRUCTION, SKILL_LEADERSHIP, SKILL_MEDICAL, SKILL_SURGERY, \
								SKILL_PILOTING, SKILL_POLICE, SKILL_POWERLOADERS, SKILL_LARGE_VEHICLES)

//skill levels
#define SKILL_LEVEL_INCOMPETENT -1
#define SKILL_LEVEL_NONE 0
#define SKILL_LEVEL_NOVICE 1
#define SKILL_LEVEL_TRAINED 2
#define SKILL_LEVEL_PROFESSIONAL 3
#define SKILL_LEVEL_EXPERT 4
#define SKILL_LEVEL_MASTER 5

#define SKILL_LEVEL_MAX SKILL_LEVEL_MASTER
#define SKILL_LEVEL_MIN SKILL_LEVEL_INCOMPETENT

//skill-related fumble and delay times
#define SKILL_TASK_TRIVIAL		10
#define SKILL_TASK_VERY_EASY	20
#define SKILL_TASK_EASY			30
#define SKILL_TASK_AVERAGE		50
#define SKILL_TASK_TOUGH		80
#define SKILL_TASK_DIFFICULT	100
#define SKILL_TASK_CHALLENGING	150
#define SKILL_TASK_FORMIDABLE	200

#define DEFAULT_SKILLSET /datum/skillset/pfc

//D(irect) as in they don't perform the mind and skills datums existence sanity check. Use these only if their existence has been already checked.
#define D_GET_SKILL_MOD(user, skill) (user.mind.cm_skills.skill_mods ? user.mind.cm_skills.skill_mods[skill] : SKILL_LEVEL_NONE)
#define D_GET_SKILL(user, skill) (user.mind.cm_skills.skills_bypass ? SKILL_LEVEL_MASTER : CLAMP((user.mind.cm_skills.skill_list ? user.mind.cm_skills.skill_list[skill] : SKILL_LEVEL_NONE) + D_GET_SKILL_MOD(user, skill), SKILL_LEVEL_MIN, SKILL_LEVEL_MAX))
#define D_HAS_SKILL_LEVEL(user, skill, level) (D_GET_SKILL(user, skill) >= level)
#define D_GET_SKILL_MOD_ID(user, skill, id) (user.mind.cm_skills.skill_mod_ids && user.mind.cm_skills.skill_mod_ids[skill] ? user.mind.cm_skills.skill_mod_ids[skill[id]] : null)
#define D_GET_SKILL_DIFF(user, skill, level) abs(level - D_GET_SKILL(user, skill))

//safer to use versions of the macros above.
#define GET_SKILL(user, skill) (user.mind?.cm_skills ? D_GET_SKILL(user, skill) : SKILL_LEVEL_NONE)
#define HAS_SKILL_LEVEL(user, skill, level) (user.mind?.cm_skills ? D_HAS_SKILL_LEVEL(user, skill, level) : TRUE)

#define GET_SKILL_DIFF(user, skill, level) (user.mind?.cm_skills ? level - D_GET_SKILL(user, skill) : 0)

#define GET_SKILL_MOD(user, skill) (user.mind?.cm_skills ? D_GET_SKILL_MOD(user, skill) : null)
#define GET_SKILL_MOD_ID(user, skill, id) (user.mind?.cm_skills ? D_GET_SKILL_MOD_ID(user, skill, id) : null)

#define ADD_SKILL_MOD(user, skills, id, mod) (user.mind?.cm_skills?.add_skill_mod(user, skills, id, mod))

#define REMOVE_SKILL_MOD(user, skills, id) (user.mind?.cm_skills?.remove_skill_mod(user, skills, id))

//skill modifier ids.
#define SKILL_MOD_ASSIGNED_SL "assigned_squad_leader"