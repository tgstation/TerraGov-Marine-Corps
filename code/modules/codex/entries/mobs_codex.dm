/mob/living/carbon/xenomorph/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	return general_entry?.antag_text

/mob/living/carbon/xenomorph/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	return general_entry?.lore_text

/mob/living/carbon/xenomorph/get_mechanics_info()
	. = ..()
	var/list/xeno_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.mechanics_text)
		xeno_strings += general_entry?.mechanics_text + "<br>"

	xeno_strings += "<br><U>Basic Statistics for this Xeno are as follows</U>:"

	xeno_strings += "Name: '[xeno_caste.caste_name]'"
	xeno_strings += "Tier: [GLOB.tier_as_number[tier]]"
	xeno_strings += "Melee slash damage: [xeno_caste.melee_damage * xeno_melee_damage_modifier]"
	switch(mob_size)
		if(MOB_SIZE_BIG)
			xeno_strings += "Can smash walls: Yes"
		if(MOB_SIZE_XENO)
			xeno_strings += "Can smash walls: No"
	xeno_strings += "Max health: [xeno_caste.max_health]"
	var/list/armor_in_list = soft_armor.getList()
	for(var/armor_type in armor_in_list)
		xeno_strings += "Soft [armor_type] armor: [armor_in_list[armor_type]]"
	armor_in_list = hard_armor.getList()
	for(var/armor_type in armor_in_list)
		xeno_strings += "Hard [armor_type] armor: [armor_in_list[armor_type]]"
	xeno_strings += "Max plasma: [xeno_caste.plasma_max]"
	xeno_strings += "Plasma gain: [xeno_caste.plasma_gain]"
	xeno_strings += "Hive: [hive?.name]"

	if(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED)
		xeno_strings += "<br><U>This can evolve to</U>:"
		for(var/type in xeno_caste.evolves_to)
			xeno_strings += "[GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE].caste_name]"

	if(length(actions))
		xeno_strings += "<br><U>This has the following abilities</U>:"
		for(var/datum/action/ability/xeno_action/A in actions)
			xeno_strings += "<U>[A.name]</U>: [A.desc]<br>"

	. += jointext(xeno_strings, "<br>")


/datum/codex_entry/xenomorph
	display_name = "xenomorph"
	associated_paths = list(/mob/living/carbon/xenomorph)
	mechanics_text = "Xenomorphs are a hostile lifeform. They are very powerful individually and also in groups. \
	They reproduce by capturing hosts and impregnating them with facehuggers. Some time later the larva growing in the hosts \
	chest will violently burst out killing the host in the process. <br><br>Not suitable for pet ownership."
