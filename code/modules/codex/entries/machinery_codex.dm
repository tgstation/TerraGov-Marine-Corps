/obj/machinery/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/machinery/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/machinery/get_mechanics_info()
	var/list/machinery_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		machinery_strings += general_entry.mechanics_text + "<br>"

	if(use_power)
		machinery_strings += "This requires power to function."

	if(idle_power_usage)
		machinery_strings += "It uses [idle_power_usage] power when idle and [active_power_usage] power when active."

	if(machine_max_charge)
		machinery_strings += "It can hold [machine_max_charge] power in it's internal buffer."

	if(!CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		machinery_strings += "This can be destroyed."

	if(wrenchable == TRUE)
		machinery_strings += "This can be wrenched to allow it to be moved."
	else
		machinery_strings += "This cannot be wrenched to allow it to be moved."
/*
	if(length(req_access) > 0)
		machinery_strings += "<br><U>You have to have one of the following access requirements to access this normally</U>:"
		is_in_access_list(req_access)

	if(length(req_one_access) > 0)
		machinery_strings += "<br><U>You have to have one of the following access requirements to access this normally</U>:"
		is_in_access_list(req_one_access)
*/
	if(length(component_parts) > 0)
		machinery_strings += "<U>It is made from the following parts</U>:"
		for(var/X in component_parts)
			var/obj/A = X
			machinery_strings += "[initial(text2path(A).name)]"

	. += jointext(machinery_strings, "<br>")

/datum/codex_entry/emitter
	associated_paths = list(/obj/machinery/power/emitter)
	mechanics_text = "You must secure this in place with a wrench and weld it to the floor before using it. The emitter will only fire if it is installed above a cable endpoint. Clicking will toggle it on and off, at which point, so long as it remains powered, it will fire in a single direction in bursts of four."
	lore_text = "Lasers like this one have been in use for ages, in applications such as mining, cutting, and in the startup sequence of many advanced space station and starship engines."
	antag_text = "This baby is capable of slicing through walls, sealed lockers, and people."

/* do not use until someone reworks access. Then do something better.
proc/is_in_access_list(var/list/X)
	var/list/machinery_strings = list()
	if(ACCESS_MARINE_COMMANDER in X)
		machinery_strings += "Marine Captain"
	if(ACCESS_MARINE_LOGISTICS in X)
		machinery_strings += "Marine Logistics"
	if(ACCESS_MARINE_BRIG in X)
		machinery_strings += "Marine Brig"
	if(ACCESS_MARINE_ARMORY in X)
		machinery_strings += "Marine Armory"
	if(ACCESS_MARINE_CMO in X)
		machinery_strings += "Marine Chief Medical Officer"
	if(ACCESS_MARINE_CE in X)
		machinery_strings += "Marine Chief Engineer"
	if(ACCESS_MARINE_ENGINEERING in X)
		machinery_strings += "Marine Engineering"
	if(ACCESS_MARINE_MEDBAY in X)
		machinery_strings += "Marine Medbay"
	if(ACCESS_MARINE_PREP in X)
		machinery_strings += "Marine Prep"
	if(ACCESS_MARINE_MEDPREP in X)
		machinery_strings += "Marine Medic Prep"
	if(ACCESS_MARINE_ENGPREP in X)
		machinery_strings += "Marine Engineer Prep"
	if(ACCESS_MARINE_LEADER in X)
		machinery_strings += "Marine Squad Leader"
	if(ACCESS_MARINE_SPECPREP in X)
		machinery_strings += "Marine Specialist Prep"
	if(ACCESS_MARINE_RESEARCH in X)
		machinery_strings += "Marine Research"
	if(ACCESS_MARINE_SMARTPREP in X)
		machinery_strings += "Marine Smartgunner Prep"
	if(ACCESS_MARINE_ALPHA in X)
		machinery_strings += "Marine Alpha Squad"
	if(ACCESS_MARINE_BRAVO in X)
		machinery_strings += "Marine Bravo Squad"
	if(ACCESS_MARINE_CHARLIE in X)
		machinery_strings += "Marine Charlie Squad"
	if(ACCESS_MARINE_DELTA in X)
		machinery_strings += "Marine Delta Squad"
	if(ACCESS_MARINE_BRIDGE in X)
		machinery_strings += "Marine Bridge"
	if(ACCESS_MARINE_CHEMISTRY in X)
		machinery_strings += "Marine Chemistry"
	if(ACCESS_MARINE_CARGO in X)
		machinery_strings += "Marine Cargo"
	if(ACCESS_MARINE_DROPSHIP in X)
		machinery_strings += "Marine Dropship"
	if(ACCESS_MARINE_PILOT in X)
		machinery_strings += "Marine Pilot"
	if(ACCESS_MARINE_WO in X)
		machinery_strings += "Marine Warrent Officer"
	if(ACCESS_MARINE_RO in X)
		machinery_strings += "Marine Requisitions Officer"
	if(ACCESS_MARINE_TANK in X)
		machinery_strings += "Marine Tank Driver"
	if(ACCESS_CIVILIAN_PUBLIC in X)
		machinery_strings += "Civilian Public"
	if(ACCESS_CIVILIAN_LOGISTICS in X)
		machinery_strings += "Civilian Logistics"
	if(ACCESS_CIVILIAN_ENGINEERING in X)
		machinery_strings += "Civilian Engineering"
	if(ACCESS_CIVILIAN_RESEARCH in X)
		machinery_strings += "Civilian Research"
	return machinery_strings

*/