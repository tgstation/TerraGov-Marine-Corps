/proc/maprotate()
#ifndef TGS_V3_API
	return
#endif
	var/players = GLOB.clients.len
	var/list/mapvotes = list()
	//count votes
	for (var/client/c in GLOB.clients)
		var/vote = c.prefs.preferred_map
		if (!vote)
			if (config.defaultmap)
				mapvotes[config.defaultmap.name] += 1
			continue
#ifdef MAP_ID
		if (vote == MAP_ID)
			mapvotes[vote] += 0.5
		else
			mapvotes[vote] += 1
#else
	mapvotes[vote] += 1
#endif
	if (!length(mapvotes) < config.maplist)
		for (var/map in config.maplist-mapvotes)
			mapvotes[map] = 0.5

	//filter votes
	for (var/map in mapvotes&config.maplist)
		if (!map)
			mapvotes.Remove(map)
		var/datum/votablemap/VM = config.maplist[map]
		if (VM.voteweight <= 0)
			mapvotes.Remove(map)
			continue
		if (VM.minusers > 0 && players < VM.minusers)
			mapvotes.Remove(map)
			continue
		if (VM.maxusers > 0 && players > VM.maxusers)
			mapvotes.Remove(map)
			continue

		mapvotes[map] = mapvotes[map]*VM.voteweight

	var/pickedmap = pickweight(mapvotes)
	if (!pickedmap)
		return
	var/datum/votablemap/VM = config.maplist[pickedmap]
#ifdef MAP_ID
	if (pickedmap == MAP_ID)
		message_admins("Random map rotation has decided to extend the current map ([VM.friendlyname])")
		to_chat(world, "<span class='boldannounce'>Map rotation has chosen to extend the current map.</span>")
		return
#endif
	message_admins("Randomly rotating map to [VM.name]([VM.friendlyname])")
	. = changemap(VM)
	if (. == 0)
		to_chat(world, "<span class='boldannounce'>Map rotation has chosen [VM.friendlyname] for next round!</span>")

var/datum/votablemap/nextmap

/proc/changemap(var/datum/votablemap/VM)
#ifndef TGS_V3_API
	return
#endif
	ASSERT(istype(VM))
	ASSERT(!findtext(VM.name, ".")) //security
	var/tgs3_path = CONFIG_GET(string/tgs3_commandline_path)
	ASSERT(fexists(tgs3_path))
	var/instancename = GLOB.tgs.InstanceName()
	ASSERT(instancename)

	log_game("Changing map to [VM.name]([VM.friendlyname])")

	var/const/filename = "..\\..\\static\\maprotate.dm"
	fdel(filename)
	var/file = file(filename)

	file << "#include \"_maps\\[VM.name].dm\"\n#define MAP_OVERRIDE"
	. = shell("[tgs3_path] --instance [instancename] dm compile --wait") //don't judge me cyberboss
	if (.)
		message_admins("Failed to change map: Unknown error: Error code #[.]")
		log_game("Failed to change map: Unknown error: Error code #[.]")
		fdel(filename)
	else
		nextmap = VM

var/maprotatechecked = FALSE

/hook/roundend/proc/random_map_rotate()
	set waitfor = FALSE
#ifndef TGS_V3_API
	return TRUE
#endif
	if (!CONFIG_GET(flag/maprotation))
		return TRUE
	if (maprotatechecked)
		return TRUE

	maprotatechecked = TRUE

	//map rotate chance defaults to 200% of the length of the round (in minutes)
	if (!prob((world.time/600)*CONFIG_GET(number/maprotation_chance_delta)))
		return TRUE
	maprotate()

	return TRUE