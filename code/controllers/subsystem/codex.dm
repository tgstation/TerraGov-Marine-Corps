SUBSYSTEM_DEF(codex)
	name = "Codex"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_CODEX
	///Assoaciative list: key = type, value = /datum/codex_entry/[this item's entry]
	var/list/entries = list()
	var/list/entries_by_path = list()
	var/list/entries_by_string = list()
	var/list/index_file = list()
	var/list/search_cache = list()
	var/list/entry_cache = list()

/datum/controller/subsystem/codex/Initialize()

	/* THIS STUPID THING IS A LIE, IT DOES NOT GENERATE A CODEX ENTRY FOR EVERYTHING
	MAKE IT SO EVERY ATOM CALLS get_specific_codex_entry() INSTEAD, SCRAP THIS WHOLE THING

	maybe make an entry for everything that has a "add to codex" var set to TRUE, and set it to false for children
	of the atom that are basically the same (like toolbelts and their child that spawns full)

	entries by string and entries by path is inefficient, destroy it when you wake up*/
	var/list/things = subtypesof(/obj/item)
	for(var/obj/item/item AS in things)
		var/codex_path = item.codex_path
		if(!codex_path || entries[codex_path])
			continue

		//Can't do codex_path::get_specific_codex_entry() because it requires a constant path
		//So going to temporarily create a new instance of the codex_path and call the proc, then delete the item
		var/obj/item/item_to_be_catalogued = new codex_path()
		var/datum/codex_entry/entry = item_to_be_catalogued.get_specific_codex_entry()
		entries[codex_path] += entry

	// Create general hardcoded entries.
	for(var/ctype in typesof(/datum/codex_entry))
		var/datum/codex_entry/centry = ctype
		if(initial(centry.display_name) || initial(centry.associated_paths) || initial(centry.associated_strings))
			centry = new centry()
			for(var/associated_path in centry.associated_paths)
				entries_by_path[associated_path] = centry
			for(var/associated_string in centry.associated_strings)
				entries_by_string[associated_string] = centry
			if(centry.display_name)
				entries_by_string[centry.display_name] = centry

	// Create categorized entries.
	for(var/ctype in subtypesof(/datum/codex_category))
		var/datum/codex_category/cat = new ctype
		cat.Initialize()
		qdel(cat)

	// Create the index file for later use.
	for(var/thing in SScodex.entries_by_path)
		var/datum/codex_entry/entry = SScodex.entries_by_path[thing]
		index_file[entry.display_name] = entry
	for(var/thing in SScodex.entries_by_string)
		var/datum/codex_entry/entry = SScodex.entries_by_string[thing]
		index_file[entry.display_name] = entry
	index_file = sortTim(index_file, cmp=/proc/cmp_text_asc)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/codex/proc/get_codex_entry(datum/codex_entry/entry)
	if(!initialized || !entry)
		return
	var/searching = text_ref(entry)
	if(isatom(entry))
		var/atom/entity = entry
		if(entity.get_specific_codex_entry())
			entry_cache[searching] = entity.get_specific_codex_entry()
		else if(entries_by_string[lowertext(entity.name)])
			entry_cache[searching] = entries_by_string[lowertext(entity.name)]
		else if(entries_by_path[entity.type])
			entry_cache[searching] = entries_by_path[entity.type]
		return entry_cache[searching]

	if(!entry_cache[searching])
		if(istype(entry))
			entry_cache[searching] = entry
		else
			entry_cache[searching] = FALSE
			if(ispath(entry))
				entry_cache[searching] = entries_by_path[entry]

	return entry_cache[searching]

/datum/controller/subsystem/codex/proc/present_codex_entry(mob/presenting_to, datum/codex_entry/entry)
	if(entry && istype(presenting_to) && presenting_to.client)
		var/list/dat = list()
		if(entry.mechanics_text)
			dat += "<h3>OOC Information</h3>"
			dat += "<font color='#9ebcd8'>[entry.mechanics_text]</font>"
		if(entry.lore_text)
			dat += "<h3>Lore Information</h3>"
			dat += "<font color='#abdb9b'>[entry.lore_text]</font>"
		var/datum/browser/popup = new(presenting_to, "codex", "Codex - [entry.display_name]")
		popup.set_content(jointext(dat, null))
		popup.open()

/datum/controller/subsystem/codex/proc/retrieve_entries_for_string(searching)

	if(!initialized)
		return list()

	searching = sanitize(lowertext(trim(searching)))
	if(!searching)
		return list()
	if(!search_cache[searching])
		var/list/results
		if(entries_by_string[searching])
			results = list(entries_by_string[searching])
		else
			results = list()
			for(var/entry_title in entries_by_string)
				var/datum/codex_entry/entry = entries_by_string[entry_title]
				if(findtext(entry.display_name, searching) || \
					findtext(entry.lore_text, searching) || \
					findtext(entry.mechanics_text, searching) || \
					findtext(entry.antag_text, searching))
					results |= entry
		search_cache[searching] = dd_sortedObjectList(results)
	return search_cache[searching]


/datum/controller/subsystem/codex/can_interact(mob/user)
	return TRUE


/datum/controller/subsystem/codex/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["show_examined_info"] && href_list["show_to"])
		var/atom/showing_atom = locate(href_list["show_examined_info"])
		var/mob/showing_mob = locate(href_list["show_to"]) in GLOB.mob_list
		if(QDELETED(showing_atom) || QDELETED(showing_mob))
			return
		var/entry = get_codex_entry(showing_atom)
		if(entry && showing_mob.can_use_codex())
			present_codex_entry(showing_mob, entry)
			return TRUE

//TO-DO: Merge this with get_codex_entry maybe?
///Return all the information regarding a specific codex entry as a list; just provide an atom to get the entry for
/datum/controller/subsystem/codex/proc/get_codex_data(atom/target)
	var/list/data = list()
	var/datum/codex_entry/entry = get_codex_entry(target)
	if(entry)
		data["name"] = entry.display_name
		data["description"] = strip_html(entry.description)
		data["lore"] = strip_html(entry.lore_text)
		data["antag"] = entry.antag_text
		data["attributes"] = entry.attributes
		data["mechanics"] = entry.mechanics
		data["background"] = entry.background
		data["is_gun"] = entry.is_gun
		data["is_clothing"] = entry.is_clothing
	else
		data["name"] = null
	return data

///Return a list of matching codex entries for a given query
/datum/controller/subsystem/codex/proc/search_codex(query, minimum_characters = 3)
	if(length(query) < minimum_characters)
		return list()

	//List 1 is the display names for displaying in the UI
	//List 2 is references to the entries so the Codex datum fetches it if selected
	var/list/results = list(list(), list())
	var/list/matches = retrieve_entries_for_string(query)
	for(var/datum/codex_entry/entry in matches)
		results[1] += entry.display_name
		results[2] += entry
	return results
