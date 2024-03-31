/datum/skill/combat
	name = "Combat"
	desc = ""

/datum/skill/combat/proc/get_skill_parry_modifier(level) //added parry drain/neg in parries and dodges
	switch(level)
		if(SKILL_LEVEL_NONE)
			return 0
		if(SKILL_LEVEL_NOVICE)
			return 5
		if(SKILL_LEVEL_APPRENTICE)
			return 10
		if(SKILL_LEVEL_JOURNEYMAN)
			return 15
		if(SKILL_LEVEL_EXPERT)
			return 20
		if(SKILL_LEVEL_MASTER)
			return 25
		if(SKILL_LEVEL_LEGENDARY)
			return 35

/datum/skill/combat/proc/get_skill_dodge_drain(level) //added parry drain/neg in parries and dodges
	switch(level)
		if(SKILL_LEVEL_NONE)
			return 30
		if(SKILL_LEVEL_NOVICE)
			return 60
		if(SKILL_LEVEL_APPRENTICE)
			return 90
		if(SKILL_LEVEL_JOURNEYMAN)
			return 120
		if(SKILL_LEVEL_EXPERT)
			return 180
		if(SKILL_LEVEL_MASTER)
			return 240
		if(SKILL_LEVEL_LEGENDARY)
			return 300

/datum/skill/combat/knives
	name = "Knife-fighting"

/datum/skill/combat/swords
	name = "Sword-fighting"

/datum/skill/combat/polearms
	name = "Polearms"

/datum/skill/combat/axesmaces
	name = "Axes & Maces"

/datum/skill/combat/whipsflails
	name = "Whips & Flails"

/datum/skill/combat/bows
	name = "Archery"

/datum/skill/combat/crossbows
	name = "Crossbows"

/datum/skill/combat/wrestling
	name = "Wrestling"

/datum/skill/combat/unarmed
	name = "Fist-fighting"