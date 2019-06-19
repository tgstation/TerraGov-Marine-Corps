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
	for(var/name in GLOB.string_equip_flags)
		if(flags_equip_slot & GLOB.string_equip_flags[name])
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

/datum/codex_entry/Zippy_faction
	display_name = "Zippy pizza (faction)"
	lore_text = "A LLC company specializing in production and delivery of pizza, Zippy Pizza was founded in 2407 when John Zippy, \
	an eccentric billionare who had made his fortune in the food service industry, saw the ICC starship Far Horizon up for auction. Purchasing the \
	ship for near $400,000,000 was pricy, but refitting it and saving it from the scrapyard cost a similar amount. Once the refit was finished, \
	he had a private starship of his own, the only one in existence, which he then used to travel the stars. As a throwback to his early days, \
	he began running a pizza business out of the Horizon as an excuse. No one was more suprised than he was when it actually began to turn a profit! \
	<br><br> John Zippy died after only 5 years from old age, but Zippy Pizza and the Far Horizon still carry on his legacy as the only \
	interstellar-capable pizza company in existence, somehow managing to make something pay that shouldn't be possible."
	mechanics_text = "~1,500 people.<br><br>Standing army of 0.<br><br>1 FTL ship, the ICC Far Horizon. 4 medium-range shuttles<br><br>\
	++The furthest range of ANY pizza company.<br>\
	+Decent pizza, too!<br>\
	+Privately owned starship.<br>\
	-How the HELL are they making a profit?<br>\
	-No combat capability whatsoever<br>\
	--Will get tips by hook or by crook."