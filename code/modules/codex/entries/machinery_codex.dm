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

	if(length(component_parts) > 0)
		machinery_strings += "<U>It is made from the following parts</U>:"
		for(var/X in component_parts)
			var/obj/A = X
			machinery_strings += "[initial(A.name)]"

	. += jointext(machinery_strings, "<br>")