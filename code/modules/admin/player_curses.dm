
#define CURSE_MASTER_LIST list("brokedick")

/proc/curse2trait(curse)
	if(!curse)
		return
	switch(curse)
		if("brokedick")
			return TRAIT_LIMPDICK

/proc/has_player_curse(key,curse)
	if(!key)
		return
	if(!curse)
		return
	var/list/json = get_player_curses(key)
	if(!json)
		return
	for(var/X in json)
		if(X == curse)
			return TRUE

/proc/get_player_curses(key)
	if(!key)
		return
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	if(json)
		return json

/proc/apply_player_curse(key, curse)
	if(!key)
		return
	if(!curse)
		return
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(json[curse])
		return
	json[curse] = 1
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))
	return TRUE

/proc/remove_player_curse(key, curse)
	if(!key)
		return
	if(!curse)
		return
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/curses.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(!json[curse])
		return
	json[curse] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))
	return TRUE