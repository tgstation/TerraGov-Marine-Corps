/datum/controller/configuration
	name = "Configuration"

	var/directory = "config"

	var/warned_deprecated_configs = FALSE
	var/hiding_entries_by_type = TRUE //Set for readability, admins can set this to FALSE if they want to debug it
	var/list/entries
	var/list/entries_by_type

	var/list/list/maplist
	var/list/defaultmaps

	var/list/modes // allowed modes
	var/list/gamemode_cache
	var/list/votable_modes // votable modes
	var/list/mode_names

	var/motd

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
	var/list/lines = world.file2list("[directory]/[filename]")
	var/list/_entries = entries
	for(var/L in lines)
		L = trim(L)
		if(!L)
			continue

		var/firstchar = copytext(L, 1, 2)
		if(firstchar == "#")
			continue

		var/lockthis = firstchar == "@"
		if(lockthis)
			L = copytext(L, 2)

		var/pos = findtext(L, " ")
		var/entry = null
		var/value = null

		if(pos)
			entry = lowertext(copytext(L, 1, pos))
			value = copytext(L, pos + 1)
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
				addtimer(CALLBACK(GLOBAL_PROC, /proc/message_admins, "This server is using deprecated configuration settings. Please check the logs and update accordingly."), 0)
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


/datum/controller/configuration/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Debug", src)
	stat("[name]:", statclick)


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
	votable_modes = list()
	for(var/T in gamemode_cache)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()
		if(M.config_tag)
			if(!(M.config_tag in modes)) //Ensure each mode is added only once
				modes += M.config_tag
				mode_names[M.config_tag] = M.name
				if(M.votable)
					votable_modes += M.config_tag
		qdel(M)


/datum/controller/configuration/proc/LoadMOTD()
	var/motd = file2text("[directory]/motd.txt")
	var/tm_info = GLOB.revdata.GetTestMergeInfo()
	if(motd || tm_info)
		motd = motd ? "[motd]<br>[tm_info]" : tm_info
	GLOB.motd = motd


/datum/controller/configuration/proc/loadmaplist(filename, maptype)
	log_config("Loading config file [filename]...")
	filename = "[directory]/[filename]"
	var/list/Lines = world.file2list(filename)

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
