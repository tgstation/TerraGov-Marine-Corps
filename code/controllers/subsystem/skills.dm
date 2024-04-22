/*!
This subsystem mostly exists to populate and manage the skill singletons.
*/

SUBSYSTEM_DEF(skills)
	name = "Skills"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_SKILLS
	///Dictionary of skill.type || skill ref
	var/list/all_skills = list()
	///Static assoc list of levels (ints) - strings
	var/list/level_names = list("<span class='info'>Weak</span>", "<span class='info'>Average</span>", "<span class='biginfo'>Skilled</span>", "<span class='biginfo'>Expert</span>", "<B>Master</B>", "<span class='greentext'>Legendary</span>")//This list is already in the right order, due to indexing


/datum/controller/subsystem/skills/Initialize(timeofday)
	InitializeSkills()
	return ..()

///Ran on initialize, populates the skills dictionary
/datum/controller/subsystem/skills/proc/InitializeSkills(timeofday)
	for(var/type in subtypesof(/datum/skill))
		var/datum/skill/ref = new type
		all_skills[type] = ref
