/obj/item/storage/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/item/storage/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/item/storage/get_mechanics_info()
	var/list/storage_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		storage_strings += general_entry.mechanics_text + "<br>"
	
	var/list/slots = list()
	for(var/name in string_equip_flags)
		if(flags_equip_slot & string_equip_flags[name])
			slots += name

	if(slots.len)
		storage_strings += "It can be worn on your [english_list(slots)]."

	if(use_to_pickup)
		storage_strings += "It can be used to pickup objects."

	if(storage_slots)
		storage_strings += "It has [storage_slots] spaces for inventory."

	if(max_storage_space)
		storage_strings += "It can carry [max_storage_space] weight of stuff."

	if(max_w_class && !length(can_hold))
		storage_strings += "It can carry weight [max_w_class] things or lighter."

	if(length(can_hold))
		storage_strings += "<br><U>You can only carry the following in this</U>:"
		for(var/X in can_hold)
			var/obj/item/A = X
			storage_strings += "[initial(A.name)]"

	if(length(bypass_w_limit))
		storage_strings += "<br><U>You can also carry the following special items in this</U>:"
		for(var/X in bypass_w_limit)
			var/obj/item/A = X
			storage_strings += "[initial(A.name)]"

	if(length(cant_hold))
		storage_strings += "<br><U>You can specifically not carry these things in this</U>:"
		for(var/X in cant_hold)
			var/obj/item/A = X
			storage_strings += "[initial(A.name)]"

	. += jointext(storage_strings, "<br>")

/datum/codex_entry/suitcooler
	associated_paths = list(/obj/item/device/suit_cooling_unit)
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
