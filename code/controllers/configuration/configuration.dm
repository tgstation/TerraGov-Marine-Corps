/datum/controller/configuration
	name = "Configuration"

	var/directory = "config"

	var/warned_deprecated_configs = FALSE
	var/hiding_entries_by_type = TRUE //Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/list/maplist
	var/list/defaultmaps
	/// List of all modes that can be choose by admins
	var/list/modes
	var/list/gamemode_cache
	/// List of all modes that can be voted by the players
	var/list/votable_modes
	var/list/mode_names

	var/motd
	var/policy

	/// A regex that matches words blocked IC
	var/static/regex/ic_filter_regex

	/// A regex that matches words blocked OOC
	var/static/regex/ooc_filter_regex

	/// A regex that matches words blocked IC, but not in PDAs
	var/static/regex/ic_bomb_vest_filter_regex

	/// A regex that matches words soft blocked IC
	var/static/regex/soft_ic_filter_regex

	/// A regex that matches words soft blocked OOC
	var/static/regex/soft_ooc_filter_regex

	/// A regex that matches words soft blocked IC, but not in PDAs
	var/static/regex/soft_ic_bomb_vest_filter_regex

	/// An assoc list of blocked IC words to their reasons
	var/static/list/ic_filter_reasons

	/// An assoc list of words that are blocked IC, but not in PDAs, to their reasons
	var/static/list/ic_bomb_vest_filter_reasons

	/// An assoc list of words that are blocked both IC and OOC to their reasons
	var/static/list/shared_filter_reasons

	/// An assoc list of soft blocked IC words to their reasons
	var/static/list/soft_ic_filter_reasons

	/// An assoc list of words that are soft blocked IC, but not in PDAs, to their reasons
	var/static/list/soft_ic_bomb_vest_filter_reasons

	/// An assoc list of words that are soft blocked both IC and OOC to their reasons
	var/static/list/soft_shared_filter_reasons

/datum/controller/configuration/proc/admin_reload()
	if(IsAdminAdvancedProcCall())
		return
	log_admin("[key_name(usr)] has forcefully reloaded the configuration from disk.")
	message_admins("[ADMIN_TPMONTY(usr)] has forcefully reloaded the configuration from disk.")
	full_wipe()
	Load(world.params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])


/datum/controller/configuration/proc/Load(_directory)
	if(IsAdminAdvancedProcCall()) //If admin proccall is detected down the line it will horribly break everything.
		return
	if(_directory)
		directory = _directory
	if(entries)
		CRASH("/datum/controller/configuration/Load() called more than once!")
	InitEntries()
	LoadModes()
	if(fexists("[directory]/config.txt") && LoadEntries("config.txt") <= 1)
		var/list/legacy_configs = list("dbconfig.txt")
		for(var/I in legacy_configs)
			if(fexists("[directory]/[I]"))
				log_config("No $include directives found in config.txt! Loading legacy [legacy_configs.Join("/")] files...")
				for(var/J in legacy_configs)
					LoadEntries(J)
				break
	loadmaplist(CONFIG_GROUND_MAPS_FILE, GROUND_MAP)
	loadmaplist(CONFIG_SHIP_MAPS_FILE, SHIP_MAP)
	LoadMOTD()
	LoadPolicy()
	LoadChatFilter()

	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	if(Master)
		Master.OnConfigLoad()


/datum/controller/configuration/proc/full_wipe()
	if(IsAdminAdvancedProcCall())
		return
	entries_by_type.Cut()
	QDEL_LIST_ASSOC_VAL(entries)
	entries = null
	for(var/list/L in maplist)
		QDEL_LIST_ASSOC_VAL(L)
	maplist = null
	QDEL_LIST_ASSOC_VAL(defaultmaps)
	defaultmaps = null


/datum/controller/configuration/Destroy()
	full_wipe()
	config = null

	return ..()


/datum/controller/configuration/proc/InitEntries()
	var/list/_entries = list()
	entries = _entries
	var/list/_entries_by_type = list()
	entries_by_type = _entries_by_type

	for(var/I in typesof(/datum/config_entry))	//typesof is faster in this case
		var/datum/config_entry/E = I
		if(initial(E.abstract_type) == I)
			continue
		E = new I
		var/esname = E.name
		var/datum/config_entry/test = _entries[esname]
		if(test)
			log_config("Error: [test.type] has the same name as [E.type]: [esname]! Not initializing [E.type]!")
			qdel(E)
			continue
		_entries[esname] = E
		_entries_by_type[I] = E


/datum/controller/configuration/proc/RemoveEntry(datum/config_entry/CE)
	entries -= CE.name
	entries_by_type -= CE.type


/datum/controller/configuration/proc/LoadEntries(filename, list/stack = list())
	if(IsAdminAdvancedProcCall())
		return

	var/filename_to_test = world.system_type == MS_WINDOWS ? lowertext(filename) : filename
	if(filename_to_test in stack)
		log_config("Warning: Config recursion detected ([english_list(stack)]), breaking!")
		return
	stack = stack + filename_to_test

	log_config("Loading config file [filename]...")
	var/list/lines = file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		L = trim(L)
		if(!L)
			continue

		var/firstchar = L[1]
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, length(firstchar) + 1)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + length(L[pos]))
		else
			entry = lowertext(L)

		if(!entry)
			continue

		if(entry == "$include")
			if(!value)
				log_config("Warning: Invalid $include directive: [value]")
			else
				LoadEntries(value, stack)
				++.
			continue

		var/datum/config_entry/E = _entries[entry]
		if(!E)
			log_config("Unknown setting in configuration: '[entry]'")
			continue

		if(lockthis)
			E.protection |= CONFIG_ENTRY_LOCKED

		if(E.deprecated_by)
			var/datum/config_entry/new_ver = entries_by_type[E.deprecated_by]
			var/new_value = E.DeprecationUpdate(value)
			var/good_update = istext(new_value)
			log_config("Entry [entry] is deprecated and will be removed soon. Migrate to [new_ver.name]![good_update ? " Suggested new value is: [new_value]" : ""]")
			if(!warned_deprecated_configs)
				DelayedMessageAdmins("This server is using deprecated configuration settings. Please check the logs and update accordingly.")
				warned_deprecated_configs = TRUE
			if(good_update)
				value = new_value
				E = new_ver
			else
				warning("[new_ver.type] is deprecated but gave no proper return for DeprecationUpdate()")

		var/validated = E.ValidateAndSet(value)
		if(!validated)
			log_config("Failed to validate setting \"[value]\" for [entry]")
		else
			if(E.modified && !E.dupes_allowed)
				log_config("Duplicate setting for [entry] ([value], [E.resident_file]) detected! Using latest.")

		E.resident_file = filename

		if(validated)
			E.modified = TRUE

	++.


/datum/controller/configuration/can_vv_get(var_name)
	return (var_name != NAMEOF(src, entries_by_type) || !hiding_entries_by_type) && ..()


/datum/controller/configuration/vv_edit_var(var_name, var_value)
	var/list/banned_edits = list(NAMEOF(src, entries_by_type), NAMEOF(src, entries), NAMEOF(src, directory))
	return !(var_name in banned_edits) && ..()


/datum/controller/configuration/stat_entry(msg)
	msg = "Edit"
	return msg


/datum/controller/configuration/proc/Get(entry_type)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to retrieve an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_HIDDEN) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Get" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config access of [entry_type] attempted by [key_name(usr)]")
		return
	return E.config_entry_value


/datum/controller/configuration/proc/Set(entry_type, new_val)
	var/datum/config_entry/E = entry_type
	var/entry_is_abstract = initial(E.abstract_type) == entry_type
	if(entry_is_abstract)
		CRASH("Tried to set an abstract config_entry: [entry_type]")
	E = entries_by_type[entry_type]
	if(!E)
		CRASH("Missing config entry for [entry_type]!")
	if((E.protection & CONFIG_ENTRY_LOCKED) && IsAdminAdvancedProcCall() && GLOB.LastAdminCalledProc == "Set" && GLOB.LastAdminCalledTargetRef == "[REF(src)]")
		log_admin_private("Config rewrite of [entry_type] to [new_val] attempted by [key_name(usr)]")
		return
	return E.ValidateAndSet("[new_val]")


/datum/controller/configuration/proc/LoadModes()
	gamemode_cache = typecacheof(/datum/game_mode, TRUE)
	modes = list()
	mode_names = list()
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = new T()
		if(!M.config_tag)
			continue
		if((M.config_tag in modes)) //Ensure each mode is added only once
			continue
		modes += M
		mode_names[M.config_tag] = M.name
	log_config("Loading config file [CONFIG_MODES_FILE]...")
	var/filename = "[directory]/[CONFIG_MODES_FILE]"
	var/list/Lines = file2list(filename)
	var/datum/game_mode/currentmode
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(t, 1, pos))
			data = copytext(t, pos + 1)
		else
			command = lowertext(t)

		if(!command)
			continue

		if(!currentmode && command != "mode")
			continue

		switch(command)
			if("mode")
				for(var/datum/game_mode/mode AS in modes)
					if(mode.config_tag == data)
						currentmode = mode
						break
			if("requiredplayers")
				currentmode.required_players = text2num(data)
			if("maximumplayers")
				currentmode.maximum_players = text2num(data)
			if("squadmaxnumber")
				currentmode.squads_max_number = text2num(data)
			if("deploytimelock")
				currentmode.deploy_time_lock = text2num(data) MINUTES
			if("votable")
				currentmode.votable = text2num(data)
			if("endmode")
				currentmode = null
			else
				log_config("Unknown command in map vote config: '[command]'")

	votable_modes = list()
	for(var/datum/game_mode/mode AS in modes)
		if(mode.votable)
			votable_modes += mode



/datum/controller/configuration/proc/LoadMOTD()
	GLOB.motd = file2text("[directory]/motd.txt")
/*
Policy file should be a json file with a single object.
Value is raw html.

Possible keywords :
Job titles / Assigned roles (ghost spawners for example) : Assistant , Captain , Ash Walker
Mob types : /mob/living/simple_animal/hostile/carp
Antagonist types : /datum/antagonist/highlander
Species types : /datum/species/lizard
special keywords defined in _DEFINES/admin.dm

Example config:
{
	"Assistant" : "Don't kill everyone",
	"/datum/antagonist/highlander" : "<b>Kill everyone</b>",
	"Ash Walker" : "Kill all spacemans"
}

*/
/datum/controller/configuration/proc/LoadPolicy()
	policy = list()
	var/rawpolicy = file2text("[directory]/policy.json")
	if(rawpolicy)
		var/parsed = safe_json_decode(rawpolicy)
		if(!parsed)
			log_config("JSON parsing failure for policy.json")
			DelayedMessageAdmins("JSON parsing failure for policy.json")
		else
			policy = parsed


/datum/controller/configuration/proc/loadmaplist(filename, maptype)
	log_config("Loading config file [filename]...")
	filename = "[directory]/[filename]"
	var/list/Lines = file2list(filename)

	var/datum/map_config/currentmap
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(t, 1, pos))
			data = copytext(t, pos + 1)
		else
			command = lowertext(t)

		if(!command)
			continue

		if(!currentmap && command != "map")
			continue

		switch(command)
			if("map")
				currentmap = load_map_config("_maps/[data].json")
				if(currentmap.defaulted)
					log_config("Failed to load map config for [data]!")
					currentmap = null
			if("minplayers", "minplayer")
				currentmap.config_min_users = text2num(data)
			if("maxplayers", "maxplayer")
				currentmap.config_max_users = text2num(data)
			if("weight", "voteweight")
				currentmap.voteweight = text2num(data)
			if("default", "defaultmap")
				LAZYINITLIST(defaultmaps)
				defaultmaps[maptype] = currentmap
			if("endmap")
				LAZYINITLIST(maplist)
				LAZYINITLIST(maplist[maptype])
				maplist[maptype][currentmap.map_name] = currentmap
				currentmap = null
			if("disabled")
				currentmap = null
			else
				log_config("Unknown command in map vote config: '[command]'")


/datum/controller/configuration/proc/pick_mode(mode_name)
	for(var/T in gamemode_cache)
		var/datum/game_mode/M = T
		var/ct = initial(M.config_tag)
		if(ct && ct == mode_name)
			return new T
	return new /datum/game_mode/extended()



/datum/controller/configuration/proc/LoadChatFilter()
	if(!fexists("[directory]/word_filter.toml"))
		load_legacy_chat_filter()
		return

	log_config("Loading config file word_filter.toml...")
	var/list/result = rustg_raw_read_toml_file("[directory]/word_filter.toml")
	if(!result["success"])
		var/message = "The word filter is not configured correctly! [result["content"]]"
		log_config(message)
		DelayedMessageAdmins(message)
		return
	var/list/word_filter = json_decode(result["content"])

	ic_filter_reasons = try_extract_from_word_filter(word_filter, "ic")
	ic_bomb_vest_filter_reasons = try_extract_from_word_filter(word_filter, "bombvest")
	shared_filter_reasons = try_extract_from_word_filter(word_filter, "shared")
	soft_ic_filter_reasons = try_extract_from_word_filter(word_filter, "soft_ic")
	soft_ic_bomb_vest_filter_reasons = try_extract_from_word_filter(word_filter, "soft_bombvest")
	soft_shared_filter_reasons = try_extract_from_word_filter(word_filter, "soft_shared")

	update_chat_filter_regexes()

/datum/controller/configuration/proc/load_legacy_chat_filter()
	if (!fexists("[directory]/in_character_filter.txt"))
		return

	log_config("Loading config file in_character_filter.txt...")

	ic_filter_reasons = list()
	ic_bomb_vest_filter_reasons = list()
	shared_filter_reasons = list()
	soft_ic_filter_reasons = list()
	soft_ic_bomb_vest_filter_reasons = list()
	soft_shared_filter_reasons = list()

	for (var/line in world.file2list("[directory]/in_character_filter.txt"))
		if (!line)
			continue
		if (findtextEx(line, "#", 1, 2))
			continue
		// The older filter didn't apply to PDA
		ic_bomb_vest_filter_reasons[line] = "No reason available"

	update_chat_filter_regexes()

/// Will update the internal regexes of the chat filter based on the filter reasons
/datum/controller/configuration/proc/update_chat_filter_regexes()
	ic_filter_regex = compile_filter_regex(ic_filter_reasons + shared_filter_reasons)
	ic_bomb_vest_filter_regex = compile_filter_regex(ic_filter_reasons + ic_bomb_vest_filter_reasons + shared_filter_reasons)
	ooc_filter_regex = compile_filter_regex(shared_filter_reasons)
	soft_ic_filter_regex = compile_filter_regex(soft_ic_filter_reasons + soft_shared_filter_reasons)
	soft_ic_bomb_vest_filter_regex = compile_filter_regex(soft_ic_filter_reasons + soft_ic_bomb_vest_filter_reasons + soft_shared_filter_reasons)
	soft_ooc_filter_regex = compile_filter_regex(soft_shared_filter_reasons)

/datum/controller/configuration/proc/try_extract_from_word_filter(list/word_filter, key)
	var/list/banned_words = word_filter[key]

	if (isnull(banned_words))
		return list()
	else if (!islist(banned_words))
		var/message = "The word filter configuration's '[key]' key was invalid, contact someone with configuration access to make sure it's setup properly."
		log_config(message)
		DelayedMessageAdmins(message)
		return list()

	var/list/formatted_banned_words = list()

	for (var/banned_word in banned_words)
		formatted_banned_words[lowertext(banned_word)] = banned_words[banned_word]
	return formatted_banned_words

/datum/controller/configuration/proc/compile_filter_regex(list/banned_words)
	if (isnull(banned_words) || banned_words.len == 0)
		return null

	var/static/regex/should_join_on_word_bounds = regex(@"^\w+$")

	// Stuff like emoticons needs another split, since there's no way to get ":)" on a word bound.
	// Furthermore, normal words need to be on word bounds, so "(adminhelp)" gets filtered.
	var/list/to_join_on_whitespace_splits = list()
	var/list/to_join_on_word_bounds = list()

	for (var/banned_word in banned_words)
		if (findtext(banned_word, should_join_on_word_bounds))
			to_join_on_word_bounds += REGEX_QUOTE(banned_word)
		else
			to_join_on_whitespace_splits += REGEX_QUOTE(banned_word)

	// We don't want a whitespace_split part if there's no stuff that requires it
	var/whitespace_split = to_join_on_whitespace_splits.len > 0 ? @"(?:(?:^|\s+)(" + jointext(to_join_on_whitespace_splits, "|") + @")(?:$|\s+))" : ""
	var/word_bounds = @"(\b(" + jointext(to_join_on_word_bounds, "|") + @")\b)"
	var/regex_filter = whitespace_split != "" ? "([whitespace_split]|[word_bounds])" : word_bounds
	return regex(regex_filter, "i")

//Message admins when you can.
/datum/controller/configuration/proc/DelayedMessageAdmins(text)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(message_admins), text), 1, TIMER_UNIQUE)
