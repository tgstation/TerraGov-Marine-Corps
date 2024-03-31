
/proc/add_roundplayed(key)
	var/json_file = file("data/roundsplayed.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(islist(key))
		var/list/L = key
		for(var/K in L)
			var/curtriumphs = 0
			if(json[K])
				curtriumphs = json[K]
			curtriumphs += 1
			json[K] = curtriumphs
	else
		var/curtriumphs = 0
		if(json[key])
			curtriumphs = json[key]
		curtriumphs += 1
		json[key] = curtriumphs

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/proc/get_roundsplayed(key)
	var/json_file = file("data/roundsplayed.json")
	if(!fexists(json_file))
		return 0
	var/list/json = json_decode(file2text(json_file))

	if(json[key])
		return json[key]
	return 0

/proc/add_nightsurvive(key)
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/nightsurvive.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(islist(key))
		var/list/L = key
		for(var/K in L)
			var/curtriumphs = 0
			if(json[K])
				curtriumphs = json[K]
			curtriumphs += 1
			json[K] = curtriumphs
	else
		var/curtriumphs = 0
		if(json[key])
			curtriumphs = json[key]
		curtriumphs += 1
		json[key] = curtriumphs

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/proc/get_nightsurvive(key)
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/nightsurvive.json")
	if(!fexists(json_file))
		return 0
	var/list/json = json_decode(file2text(json_file))

	if(json[key])
		return json[key]
	return 0