/mob/living/carbon/Xenomorph/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/mob/living/carbon/Xenomorph/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/mob/living/carbon/Xenomorph/get_mechanics_info()
	. = ..()
	var/list/xeno_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		xeno_strings += general_entry.mechanics_text + "<br>"

	xeno_strings += "<br><U>Basic Statistics for this Xeno are as follows</U>:"

	xeno_strings += "Name: '[name]'"
	xeno_strings += "Tier: [tier]"
	xeno_strings += "Melee slash damage between: [xeno_caste.melee_damage_lower] and [xeno_caste.melee_damage_upper]"
	xeno_strings += "Tackle damage: [xeno_caste.tackle_damage]"
	if(wall_smash)
		xeno_strings += "Can smash walls: Yes"
	else
		xeno_strings += "Can smash walls: No"
	xeno_strings += "Max health: [xeno_caste.max_health]"
	xeno_strings += "Armor deflect: [xeno_caste.armor_deflection]"
	xeno_strings += "Max plasma: [xeno_caste.plasma_max]"
	xeno_strings += "Plasma gain: [xeno_caste.plasma_gain]"
	xeno_strings += "See in dark range: [see_in_dark]"
	if(hivenumber)
		switch(hivenumber)
			if(XENO_HIVE_NORMAL)
				xeno_strings += "Hive: Normal"
			if(XENO_HIVE_CORRUPTED)
				xeno_strings += "Hive: Corrupted"
			if(XENO_HIVE_ALPHA)
				xeno_strings += "Hive: Alpha"
			if(XENO_HIVE_BETA)
				xeno_strings += "Hive: Beta"
			if(XENO_HIVE_ZETA)
				xeno_strings += "Hive: Zeta"

	if(length(xeno_caste.evolves_to) > 0)
		xeno_strings += "<br><U>This can evolve to</U>:"
		for(var/type in xeno_caste.evolves_to)
			var/datum/xeno_caste/Z = GLOB.xeno_caste_datums[type][1]
			xeno_strings += "[Z.caste_name]"

	if(length(actions) > 0)	
		xeno_strings += "<br><U>This has the following abilities</U>:"
		for(var/X in actions)
			var/datum/action/xeno_action/A = X
			xeno_strings += "[A.name]: [A.mechanics_text]"

	. += jointext(xeno_strings, "<br>")

/datum/codex_entry/maint_drone
	display_name = "maintenance drone"
	associated_paths = list(/mob/living/silicon/robot/drone)
	mechanics_text = "Drones are player-controlled synthetics which are lawed to maintain their assigned vessel and not \
	interfere with anyone else, except for other drones. They hold a wide array of tools to build, repair, maintain, and clean. \
	They function similarly to other synthetics, in that they require recharging regularly, have laws, and are resilient to many hazards, \
	such as fire, radiation, vacuum, and more. Ghosts can join the round as a maintenance drone by using the appropriate verb in the 'ghost' tab. \
	An inactive drone can be rebooted by swiping an ID card on it with engineering or robotics access, and an active drone can be shut down in the same manner. \
	Maintenance drone presence can be requested to specific areas from any maintenance drone control console."
	antag_text = "A crypotgraphic sequencer, available via a traitor uplink, can be used to subvert the drone to your cause."

/datum/codex_entry/xenomorph
	display_name = "xenomorph"
	associated_paths = list(/mob/living/carbon/Xenomorph)
	mechanics_text = "Xenomorphs are a hostile lifeform. They are very powerful individually and also in groups. \
	They reproduce by capturing hosts and impregnating them with facehuggers. Some time later the larva growing in the hosts \
	chest will violently burst out killing the host in the process. Not suitable for pet ownership."
