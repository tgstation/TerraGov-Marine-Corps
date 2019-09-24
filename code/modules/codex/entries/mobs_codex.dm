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
	xeno_strings += "Tier: [tier_as_number()]"
	xeno_strings += "Melee slash damage: [xeno_caste.melee_damage]"
	xeno_strings += "Tackle damage: [xeno_caste.tackle_damage]"
	switch(mob_size)
		if(MOB_SIZE_BIG)
			xeno_strings += "Can smash walls: Yes"
		if(MOB_SIZE_XENO)
			xeno_strings += "Can smash walls: No"
	xeno_strings += "Max health: [xeno_caste.max_health]"
	for(var/armor_type in GLOB.armour_to_descriptive_term)
		switch(armor.getRating(armor_type))
			if(0)
				xeno_strings += "Has no protection against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(1 to 20)
				xeno_strings += "Barely has protection against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(21 to 30)
				xeno_strings += "Has a very small defense against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(31 to 40)
				xeno_strings += "Has a small amount of protection against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(41 to 50)
				xeno_strings += "Has a moderate defense against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(51 to 60)
				xeno_strings += "Has a strong defense against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(61 to 70)
				xeno_strings += "Is very strong against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(71 to 80)
				xeno_strings += "Has a very robust defense against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(81 to 99)
				xeno_strings += "Is nigh-invulerable against [GLOB.armour_to_descriptive_term[armor_type]]."
			if(100 to INFINITY)
				xeno_strings += "Has godly protection against [GLOB.armour_to_descriptive_term[armor_type]]."
	xeno_strings += "Max plasma: [xeno_caste.plasma_max]"
	xeno_strings += "Plasma gain: [xeno_caste.plasma_gain]"
	xeno_strings += "Hive: [hive?.name]"

	if(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED)
		xeno_strings += "<br><U>This can evolve to</U>:"
		for(var/type in xeno_caste.evolves_to)
			xeno_strings += "[GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE].caste_name]"

	if(length(actions))
		xeno_strings += "<br><U>This has the following abilities</U>:"
		for(var/datum/action/xeno_action/A in actions)
			xeno_strings += "<U>[A.name]</U>: [A.mechanics_text]<br>"

	. += jointext(xeno_strings, "<br>")


/datum/codex_entry/xenomorph
	display_name = "xenomorph"
	associated_paths = list(/mob/living/carbon/xenomorph)
	mechanics_text = "Xenomorphs are a hostile lifeform. They are very powerful individually and also in groups. \
	They reproduce by capturing hosts and impregnating them with facehuggers. Some time later the larva growing in the hosts \
	chest will violently burst out killing the host in the process. <br><br>Not suitable for pet ownership."
