#define PATREONT1 "[global.config.directory]/roguetown/patreon/p1.txt"
#define PATREONT2 "[global.config.directory]/roguetown/patreon/p2.txt"
#define PATREONT3 "[global.config.directory]/roguetown/patreon/p3.txt"
#define PATREONT4 "[global.config.directory]/roguetown/patreon/p4.txt"
#define PATREONT5 "[global.config.directory]/roguetown/patreon/p5.txt"

#define PATREON_FILE "data/Members_7968561.csv"

GLOBAL_LIST_EMPTY(patreont1)
GLOBAL_LIST_EMPTY(patreont2)
GLOBAL_LIST_EMPTY(patreont3)
GLOBAL_LIST_EMPTY(patreont4)
GLOBAL_LIST_EMPTY(patreont5)
GLOBAL_LIST_EMPTY(allpatreons)
GLOBAL_VAR(PatreonsLoaded)

/proc/load_patreons()
	if(GLOB.PatreonsLoaded)
		return
	var/csv_file = file(PATREON_FILE)
	var/list/csvlist
	if(fexists(csv_file))
		csvlist = world.file2list(csv_file)

	for(var/line in world.file2list(PATREONT1))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.patreont1 |= ckey(line)
		GLOB.allpatreons |= ckey(line)

	for(var/line in csvlist)
		if(findtext(line, "ROGUETOWN SILVER"))
			if(findtext(line, "Active patron"))
				var/index = findtext(line, ",")
				var/indexs = findtext(line, ",",index+1)
				var/player_email = copytext(line,index+1,indexs)
//				player_email = sanitize_simple(player_email,list("@"="AT","."="DOT"))
				var/find_ckey = patemail2ckey(player_email)
				if(find_ckey)
					GLOB.patreont1 |= find_ckey

	for(var/line in world.file2list(PATREONT2))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.patreont2 |= ckey(line)
		GLOB.allpatreons |= ckey(line)

	for(var/line in csvlist)
		if(findtext(line, "ROGUETOWN GOLD"))
			if(findtext(line, "Active patron"))
				var/index = findtext(line, ",")
				var/indexs = findtext(line, ",",index+1)
				var/player_email = copytext(line,index+1,indexs)
//				player_email = sanitize_simple(player_email,list("@"="AT","."="DOT"))
				var/find_ckey = patemail2ckey(player_email)
				if(find_ckey)
					GLOB.patreont2 |= find_ckey

	for(var/line in world.file2list(PATREONT3))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.patreont3 |= ckey(line)
		GLOB.allpatreons |= ckey(line)

	for(var/line in csvlist)
		if(findtext(line, "ROGUETOWN MYTHRIL"))
			if(findtext(line, "Active patron"))
				var/index = findtext(line, ",")
				var/indexs = findtext(line, ",",index+1)
				var/player_email = copytext(line,index+1,indexs)
//				player_email = sanitize_simple(player_email,list("@"="AT","."="DOT"))
				var/find_ckey = patemail2ckey(player_email)
				if(find_ckey)
					GLOB.patreont3 |= find_ckey

	for(var/line in world.file2list(PATREONT4))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.patreont4 |= ckey(line)
		GLOB.allpatreons |= ckey(line)

	for(var/line in csvlist)
		if(findtext(line, "ROGUETOWN MERCHANT"))
			if(findtext(line, "Active patron"))
				var/index = findtext(line, ",")
				var/indexs = findtext(line, ",",index+1)
				var/player_email = copytext(line,index+1,indexs)
//				player_email = sanitize_simple(player_email,list("@"="AT","."="DOT"))
				var/find_ckey = patemail2ckey(player_email)
				if(find_ckey)
					GLOB.patreont4 |= find_ckey

	for(var/line in world.file2list(PATREONT5))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.patreont5 |= ckey(line)
		GLOB.allpatreons |= ckey(line)

	for(var/line in csvlist)
		if(findtext(line, "ROGUETOWN LORD"))
			if(findtext(line, "Active patron"))
				var/index = findtext(line, ",")
				var/indexs = findtext(line, ",",index+1)
				var/player_email = copytext(line,index+1,indexs)
//				player_email = sanitize_simple(player_email,list("@"="AT","."="DOT"))
				var/find_ckey = patemail2ckey(player_email)
				if(find_ckey)
					GLOB.patreont5 |= find_ckey

	GLOB.PatreonsLoaded = TRUE

/proc/check_patreon_lvl(var/ckey)
	if(!ckey)
		return
	for(var/X in GLOB.temporary_donators)
		if(X == ckey)
			return GLOB.temporary_donators[X]
	if(!GLOB.PatreonsLoaded)
		return get_patreon_manual(ckey)
	var/num1 = 0
	if(ckey in GLOB.patreont1)
		num1 = 1
	if(ckey in GLOB.patreont2)
		num1 = 2
	if(ckey in GLOB.patreont3)
		num1 = 3
	if(ckey in GLOB.patreont4)
		num1 = 4
	if(ckey in GLOB.patreont5)
		num1 = 5
	return num1

/proc/get_patreon_manual(ckey)
	var/the_email
	var/json_file = file("data/patemail2ckey.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	for(var/email in json)
		if(json[email] == ckey)
			the_email = email
			break

	if(!the_email)
		return 0

	var/list/csvlist
	var/csv_file = file(PATREON_FILE)
	if(fexists(csv_file))
		csvlist = world.file2list(csv_file)
	for(var/line in csvlist)
		if(findtext(line, the_email))
			if(findtext(line, "Active patron"))
				if(findtext(line, "ROGUETOWN SILVER"))
					return 1
				if(findtext(line, "ROGUETOWN GOLD"))
					return 2
				if(findtext(line, "ROGUETOWN MYTHRIL"))
					return 3
				if(findtext(line, "ROGUETOWN MERCHANT"))
					return 4
				if(findtext(line, "ROGUETOWN LORD"))
					return 5
			return 0

#undef PATREONT1
#undef PATREONT2
#undef PATREONT3
#undef PATREONT4
#undef PATREONT5

GLOBAL_LIST_INIT(pleveloneverbs, world.pleveloneverbs())
GLOBAL_PROTECT(pleveloneverbs)
/world/proc/pleveloneverbs()
	return list(
	)

GLOBAL_LIST_INIT(pleveltwoverbs, world.pleveltwoverbs())
GLOBAL_PROTECT(pleveltwoverbs)
/world/proc/pleveltwoverbs()
	return list(
	)

GLOBAL_LIST_INIT(plevelthreeverbs, world.plevelthreeverbs())
GLOBAL_PROTECT(plevelthreeverbs)
/world/proc/plevelthreeverbs()
	return list(
	)

GLOBAL_LIST_INIT(plevelfourverbs, world.plevelfourverbs())
GLOBAL_PROTECT(plevelfourverbs)
/world/proc/plevelfourverbs()
	return list(
	)

GLOBAL_LIST_INIT(plevelfiveverbs, world.plevelfiveverbs())
GLOBAL_PROTECT(plevelfiveverbs)
/world/proc/plevelfiveverbs()
	return list(
	)

/client/proc/add_patreon_verbs()
	set waitfor = 0
	var/plev = check_patreon_lvl(ckey)

	if(plev > 1)
		verbs |= GLOB.pleveloneverbs
	if(plev > 2)
		verbs |= GLOB.pleveltwoverbs
	if(plev > 3)
		verbs |= GLOB.plevelthreeverbs
	if(plev > 4)
		verbs |= GLOB.plevelfourverbs
	if(plev > 5)
		verbs |= GLOB.plevelfiveverbs

GLOBAL_LIST_EMPTY(hiderole)


GLOBAL_LIST_EMPTY(anonymize)

/mob/dead/new_player/verb/anonymize()
	set category = "Options"
	set name = "Anonymize"
	if(!client)
		return
	if(get_playerquality(client.ckey) <= -5)
		client.prefs.anonymize = FALSE
		client.prefs.save_preferences()
		to_chat(src, "<span class='warning'>Your PQ is too low!</span>")
		return
//	if(!check_whitelist(client.ckey))
//		to_chat(src, "<span class='warning'>Whitelisted players only.</span>")
//		return
	if(client.prefs.anonymize == TRUE)
		if(alert(src, "Disable Anonymize? (Not Recommended)", "ROGUETOWN", "YES", "NO") == "YES")
			if(GLOB.respawncounts[client.ckey])
				to_chat(src, "<span class='warning'>You have already spawned.</span>")
				return
			client.prefs.anonymize = FALSE
			client.prefs.save_preferences()
			to_chat(src, "No longer anonymous.")
			GLOB.anonymize -= client.ckey
	else
		if(alert(src, "Enable Anonymize? This will hide your BYOND name from anyone except \
		Dungeon Masters while playing here, useful for dealing with negative OOC bias or \
		maintaining privacy from other BYOND users.", "ROGUETOWN", "YES", "NO") == "YES")
			if(GLOB.respawncounts[client.ckey])
				to_chat(src, "<span class='warning'>You have already spawned.</span>")
				return
			client.prefs.anonymize = TRUE
			client.prefs.save_preferences()
			to_chat(src, "Anonymous... OK")
			GLOB.anonymize |= client.ckey

GLOBAL_LIST_EMPTY(temporary_donators)


/client/proc/patreonlevel()
	if(patreonlevel != -1)
		return patreonlevel
	else
		patreonlevel = check_patreon_lvl(ckey)
		return patreonlevel

/proc/patemail2ckey(input)
	if(!input)
		return
	var/json_file = file("data/patemail2ckey.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	var/list/donatorss = json[input]
	if(isnull(donatorss))
		return
	for(var/X in donatorss)
		return X
/*
/mob/dead/new_player/proc/register_patreon()
	set name = "RegisterPatreon"
	set category = "Register"
	if(client)
		if(client.patreonlevel())
			return
	var/name = input("Enter your patreon DISPLAY NAME exactly as it appears on Patreon.","ROGUETOWN") as text|null
	if(!name)
		return
	var/email = input("Enter your patreon EMAIL ADDRESS exactly as it appears on Patreon.","ROGUETOWN") as text|null
	if(!email)
		return
	if(!patreon_lookup(name) || !patreon_lookup(email) || !findtext(email, "@"))
		to_chat(src, "<span class='warning'>We couldn't find that name/email combo.</span> <span class='info'>Donator status is updated weekly before every playtest. If you have waited a week, seek help in our DISCORD SERVER (https://discord.gg/9uYTPsRMKa)</span>")
		return
//	var/saniemail = sanitize_simple(email,list("@"="AT","."="DOT"))
	var/fug = patemail2ckey(email)
	if(fug && (fug != ckey))
		to_chat(src, "<span class='warning'>That Patreon is already registered to a different player.</span> <span class='info'>Donator status is updated weekly before every playtest. If you have waited a week, seek help in our DISCORD SERVER (https://discord.gg/9uYTPsRMKa)</span>")
		return
	add_patreon(ckey,email)
	client.patreonlevel = -1
	to_chat(src, "<span class='boldnotice'>Patreon registered.</span>")
	var/shown_patreon_level = client.patreonlevel()
	if(!shown_patreon_level)
		shown_patreon_level = "NONE"
	switch(shown_patreon_level)
		if(1)
			shown_patreon_level = "Silver"
		if(2)
			shown_patreon_level = "Gold"
		if(3)
			shown_patreon_level = "Mythril"
		if(4)
			shown_patreon_level = "Merchant"
		if(5)
			shown_patreon_level = "Lord"
	to_chat(src, "<span class='info'>Your Donator Level: [shown_patreon_level]</span>")
*/
/proc/add_patreon(ckey,email)
	if(!email || !ckey)
		return
	var/csv_file = file(PATREON_FILE)
	var/list/csvlist
	if(fexists(csv_file))
		csvlist = world.file2list(csv_file)
	for(var/line in csvlist)
		if(findtext(line, email))
			if(findtext(line, "ROGUETOWN SILVER"))
				GLOB.patreont1 |= ckey
			if(findtext(line, "ROGUETOWN GOLD"))
				GLOB.patreont2 |= ckey
			if(findtext(line, "ROGUETOWN MYTHRIL"))
				GLOB.patreont3 |= ckey
			if(findtext(line, "ROGUETOWN MERCHANT"))
				GLOB.patreont4 |= ckey
			if(findtext(line, "ROGUETOWN LORD"))
				GLOB.patreont5 |= ckey
			break

	var/json_file = file("data/patemail2ckey.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	json[email] = list(ckey)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/proc/patreon_lookup(name)
	if(name == "Active patron")
		return FALSE
	var/csv_file = file(PATREON_FILE)
	var/list/csvlist
	if(fexists(csv_file))
		csvlist = world.file2list(csv_file)
	for(var/line in csvlist)
		if(findtext(line, name))
			if(findtext(line, "Active patron"))
				return TRUE

#undef PATREON_FILE
