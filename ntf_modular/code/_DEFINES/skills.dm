#define SKILL_SEX_DEFAULT 1
#define SKILL_SEX_TRAINED 2
#define SKILL_SEX_MASTER 3

/datum/skills
	var/sex = SKILL_SEX_DEFAULT

/datum/skills/ceo
	name = CHIEF_EXECUTIVE_OFFICER
	leadership = SKILL_LEAD_MASTER
	police = SKILL_POLICE_MP
	medical = SKILL_MEDICAL_MASTER
	surgery = SKILL_SURGERY_MASTER
	engineer = SKILL_ENGINEER_ENGI
	construction = SKILL_CONSTRUCTION_ADVANCED
	powerloader = SKILL_POWERLOADER_MASTER
	unarmed = SKILL_UNARMED_MASTER
	combat = SKILL_COMBAT_TRAINED
	smartgun = SKILL_SMART_TRAINED
	//wouldnt it be niceeeee aa a a aaa
	large_vehicle = SKILL_LARGE_VEHICLE_VETERAN
	mech = SKILL_MECH_TRAINED

/datum/skills/slut
	name = SQUAD_SLUT
	medical = SKILL_MEDICAL_NOVICE //gotta keep that puss tended
	combat = SKILL_COMBAT_DEFAULT //can still use guns
	construction = SKILL_CONSTRUCTION_METAL //build a cum shack
	stamina = SKILL_STAMINA_TRAINED //fucking is hard work
	sex = SKILL_SEX_TRAINED

/datum/skills/civilian/mo
	sex = SKILL_SEX_MASTER //Master at work
