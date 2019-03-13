/obj/item/ammo_magazine/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/ammo_magazine/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/item/ammo_magazine/get_mechanics_info()
	var/list/ammo_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		ammo_strings += general_entry.mechanics_text + "<br>"

	if(w_class)
		ammo_strings += "Weight: [w_class]"

	if(max_rounds)
		ammo_strings += "Capacity: [max_rounds]."

	if(caliber)
		ammo_strings += "Caliber: [caliber]"

	if(default_ammo.iff_signal)
		ammo_strings += "IFF: Yes"
	else
		ammo_strings += "IFF: No"

	. += jointext(ammo_strings, "<br>")

