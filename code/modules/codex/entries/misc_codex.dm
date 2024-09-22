/obj/item/storage/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.antag_text)
		return general_entry.antag_text

/obj/item/storage/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.lore_text)
		return general_entry.lore_text

/obj/item/storage/get_mechanics_info()
	var/list/storage_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.mechanics_text)
		storage_strings += general_entry.mechanics_text + "<br>"

	var/list/slots = list()
	for(var/name in GLOB.string_equip_flags)
		if(equip_slot_flags & GLOB.string_equip_flags[name])
			slots += name

	if(length(slots))
		storage_strings += "It can be worn on your [english_list(slots)]."

	if(storage_datum.use_to_pickup)
		storage_strings += "It can be used to pickup objects."

	if(storage_datum.storage_slots)
		storage_strings += "It has [storage_datum.storage_slots] spaces for inventory."

	if(storage_datum.max_storage_space)
		storage_strings += "It can carry [storage_datum.max_storage_space] weight of stuff."

	if(storage_datum.max_w_class && !length(storage_datum.can_hold))
		storage_strings += "It can carry weight [storage_datum.max_w_class] things or lighter."

	if(length(storage_datum.can_hold))
		storage_strings += "<br><U>You can only carry the following in this</U>:"
		for(var/X in storage_datum.can_hold)
			var/obj/item/A = X
			//check if the weight classes of the items are smaller or equal to the maximum weight class.
			if(A.w_class <= src.storage_datum.max_w_class)
				storage_strings += "[initial(A.name)]"
				
	if(length(storage_datum.storage_type_limits))
		storage_strings += "<br><U>You can also carry the following special items in this</U>:"
		for(var/X in storage_datum.storage_type_limits)
			var/obj/item/A = X
			storage_strings += "[initial(A.name)]"

	if(length(storage_datum.cant_hold))
		storage_strings += "<br><U>You can specifically not carry these things in this</U>:"
		for(var/X in storage_datum.cant_hold)
			var/obj/item/A = X
			storage_strings += "[initial(A.name)]"

	. += jointext(storage_strings, "<br>")

/datum/codex_entry/suitcooler
	associated_paths = list(/obj/item/suit_cooling_unit)
	mechanics_text = "You may wear this instead of your backpack to cool yourself down. It is commonly used by full-body prosthetic users, \
	as it allows them to go into low pressure environments for more than few seconds without overhating. It runs off energy provided by internal power cell. \
	Remember to turn it on by clicking it when it's your in your hand before you put it on."

/datum/codex_entry/barsign
	associated_paths = list(/obj/structure/sign/double/barsign)
	mechanics_text = "If your ID has bar access, you may swipe it on this sign to alter its display."

/datum/codex_entry/utility_belt
	display_name = "M276 pattern toolbelt rig"
	mechanics_text = "It's a belt for holding your tools"
	lore_text = "Although it looks and feels like leather, the last cow was killed to make a steak dinner for the queen of France."
	antag_text = "I don't see how this could be used for antagonistic purposes."

