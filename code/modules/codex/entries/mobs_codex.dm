/mob/living/carbon/Xenomorph/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	return general_entry?.antag_text

/mob/living/carbon/Xenomorph/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	return general_entry?.lore_text

/mob/living/carbon/Xenomorph/get_mechanics_info()
	. = ..()
	var/list/xeno_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.mechanics_text)
		xeno_strings += general_entry?.mechanics_text + "<br>"

	xeno_strings += "<br><U>Basic Statistics for this Xeno are as follows</U>:"

	xeno_strings += "Name: '[xeno_caste.caste_name]'"
	xeno_strings += "Tier: [tier_as_number()]"
	xeno_strings += "Melee slash damage: between [xeno_caste.melee_damage_lower] and [xeno_caste.melee_damage_upper]"
	xeno_strings += "Tackle damage: [xeno_caste.tackle_damage]"
	switch(mob_size)
		if(MOB_SIZE_BIG)
			xeno_strings += "Can smash walls: Yes"
		if(MOB_SIZE_XENO)
			xeno_strings += "Can smash walls: No"
	xeno_strings += "Max health: [xeno_caste.max_health]"
	xeno_strings += "Armor: [xeno_caste.armor_deflection]"
	xeno_strings += "Max plasma: [xeno_caste.plasma_max]"
	xeno_strings += "Plasma gain: [xeno_caste.plasma_gain]"
	xeno_strings += "Hive: [hive?.name]"

	if(xeno_caste.caste_flags & CASTE_EVOLUTION_ALLOWED)
		xeno_strings += "<br><U>This can evolve to</U>:"
		for(var/type in xeno_caste.evolves_to)
			var/datum/xeno_caste/Z = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
			xeno_strings += "[Z.caste_name]"

	if(length(actions))
		xeno_strings += "<br><U>This has the following abilities</U>:"
		for(var/X in actions)
			var/datum/action/xeno_action/A = X
			xeno_strings += "<U>[A.name]</U>: [A.mechanics_text]<br>"

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
	chest will violently burst out killing the host in the process. <br><br>Not suitable for pet ownership."
