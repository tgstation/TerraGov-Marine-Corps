/proc/get_playerquality(key, text)
	if(!key)
		return
	var/the_pq = 0
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/pq_num.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(json[ckey(key)])
		the_pq = json[ckey(key)]
	if(!the_pq)
		the_pq = 0
	if(!text)
		return the_pq
	else
		if(the_pq >= 100)
			return "<span style='color: #00ff00;'>Legendary</span>"
		if(the_pq >= 70)
			return "<span style='color: #74cde0;'>Exceptional</span>"
		if(the_pq >= 30)
			return "<span style='color: #47b899;'>Great</span>"
		if(the_pq >= 5)
			return "<span style='color: #58a762;'>Good</span>"
		if(the_pq >= -4)
			return "Normal"
		if(the_pq >= -30)
			return "<span style='color: #be6941;'>Poor</span>"
		if(the_pq >= -70)
			return "<span style='color: #cd4232;'>Terrible</span>"
		if(the_pq >= -99)
			return "<span style='color: #e2221d;'>Abysmal</span>"
		if(the_pq <= -100)
			return "<span style='color: #ff00ff;'>Shitter</span>"
		return "Normal"

/proc/adjust_playerquality(amt, key, admin, reason)
	var/curpq = 0
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/pq_num.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	if(json[key])
		curpq = json[key]
	curpq += amt
	curpq = CLAMP(curpq, -100, 100)
	json[key] = curpq
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	if(reason || admin)
		var/thing = ""
		if(amt > 0)
			thing += "+[amt]"
		if(amt < 0)
			thing += "[amt]"
		if(admin)
			thing += " by [admin]"
		if(reason)
			thing += " for reason: [reason]"
		if(amt == 0)
			if(!reason && !admin)
				return
			if(admin)
				thing = "NOTE from [admin]: [reason]"
			else
				thing = "NOTE: [reason]"
		thing += " ([GLOB.rogue_round_id])"
		thing += "\n"
		text2file(thing,"data/player_saves/[copytext(key,1,2)]/[key]/playerquality.txt")

		var/msg
		if(!amt)
			msg = "[key] triggered event [msg]"
		else
			if(amt > 0)
				msg = "[key] ([amt])"
			else
				msg = "[key] ([amt])"
		if(admin)
			msg += " - GM: [admin]"
		if(reason)
			msg += " - RSN: [reason]"
		do_bot_thing_pq(msg)

/client/proc/check_pq()
	set category = "GameMaster"
	set name = "CheckPQ"
	if(!holder)
		return
	var/selection = alert(src, "Check VIA...", "Check PQ", "Character List", "Player List", "Player Name")
	if(!selection)
		return
	var/list/selections = list()
	var/theykey
	if(selection == "Character List")
		for(var/mob/living/H in GLOB.player_list)
			selections[H.real_name] = H.ckey
		if(!selections.len)
			to_chat(src, "<span class='boldwarning'>No characters found.</span>")
			return
		selection = input("Which Character?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player List")
		for(var/client/C in GLOB.clients)
			var/usedkey = C.ckey
//			if(!check_rights(R_ADMIN,0))
//				if(C.ckey in GLOB.anonymize)
//					usedkey = get_fake_key(C.ckey)
			selections[usedkey] = C.ckey
		selection = input("Which Player?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player Name")
		selection = input("Which Player?", "CKEY", "") as text|null
		if(!selection)
			return
		theykey = selection
	if(!fexists("data/player_saves/[copytext(theykey,1,2)]/[theykey]/preferences.sav"))
		to_chat(src, "<span class='boldwarning'>User does not exist.</span>")
		return
	var/popup_window_data = "<center>[selection]</center>"
	popup_window_data += "<center>PQ: [get_playerquality(theykey, TRUE, TRUE)] ([get_playerquality(theykey, FALSE, TRUE)])</center>"

//	dat += "<table width=100%><tr><td width=33%><div style='text-align:left'><a href='?_src_=prefs;preference=playerquality;task=menu'><b>PQ:</b></a> [get_playerquality(user.ckey, text = TRUE)]</div></td><td width=34%><center><a href='?_src_=prefs;preference=triumphs;task=menu'><b>TRIUMPHS:</b></a> [user.get_triumphs() ? "\Roman [user.get_triumphs()]" : "None"]</center></td><td width=33%></td></tr></table>"
	popup_window_data += "<center><a href='?_src_=holder;[HrefToken()];cursemenu=[theykey]'>CURSES</a></center>"
	popup_window_data += "<table width=100%><tr><td width=33%><div style='text-align:left'>"
	popup_window_data += "Commends: <a href='?_src_=holder;[HrefToken()];readcommends=[theykey]'>[get_commends(theykey)]</a></div></td>"
	popup_window_data += "<td width=34%><center>ESL Points: [get_eslpoints(theykey)]</center></td>"
	popup_window_data += "<td width=33%><div style='text-align:right'>Rounds Survived: [get_roundsplayed(theykey)]</div></td></tr></table>"
	var/list/listy = world.file2list("data/player_saves/[copytext(theykey,1,2)]/[theykey]/playerquality.txt")
	if(!listy.len)
		popup_window_data += "<span class='info'>No data on record. Create some.</span>"
	else
		for(var/i = listy.len to 1 step -1)
			var/ya = listy[i]
			if(ya)
				popup_window_data += "<span class='info'>[listy[i]]</span><br>"
	var/datum/browser/noclose/popup = new(mob, "playerquality", "", 390, 320)
	popup.set_content(popup_window_data)
	popup.open()

/client/proc/adjust_pq()
	set category = "GameMaster"
	set name = "AdjustPQ"
	if(!holder)
		return
	var/selection = alert(src, "Adjust VIA...", "MODIFY PQ", "Character List", "Player List", "Player Name")
	var/list/selections = list()
	var/theykey
	if(selection == "Character List")
		for(var/mob/living/H in GLOB.player_list)
			selections[H.real_name] = H.ckey
		if(!selections.len)
			to_chat(src, "<span class='boldwarning'>No characters found.</span>")
			return
		selection = input("Which Character?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player List")
		for(var/client/C in GLOB.clients)
			var/usedkey = C.ckey
//			if(!check_rights(R_ADMIN,0))
//				if(C.ckey in GLOB.anonymize)
//					usedkey = get_fake_key(C.ckey)
			selections[usedkey] = C.ckey
		selection = input("Which Player?") as null|anything in sortList(selections)
		if(!selection)
			return
		theykey = selections[selection]
	if(selection == "Player Name")
		selection = input("Which Player?", "CKEY", "") as text|null
		if(!selection)
			return
		theykey = selection
	if(theykey == ckey)
		to_chat(src, "<span class='boldwarning'>That's you!</span>")
		return
	if(!fexists("data/player_saves/[copytext(theykey,1,2)]/[theykey]/preferences.sav"))
		to_chat(src, "<span class='boldwarning'>User does not exist.</span>")
		return
	var/amt2change = input("How much to modify the PQ by? (20 to -20, or 0 to just add a note)") as null|num
	if(!check_rights(R_ADMIN,0))
		amt2change = CLAMP(amt2change, -20, 20)
	var/raisin = stripped_input("State a short reason for this change", "Game Master", "", null)
	if(!amt2change && !raisin)
		return
	adjust_playerquality(amt2change, theykey, ckey(src.ckey), raisin)

/proc/add_commend(key, giver)
	if(!giver || !key)
		return
	var/curcomm = 0
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/commends.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	if(json[giver])
		curcomm = json[giver]
	curcomm++
	json[giver] = curcomm
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	//add the pq, only on the first commend
	if(curcomm == 1)
//	if(get_playerquality(key) < 29)
		adjust_playerquality(1, ckey(key))

/proc/get_commends(key)
	if(!key)
		return
	var/curcomm = 0
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/commends.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	for(var/X in json)
		curcomm += json[X]
	if(!curcomm)
		curcomm = 0
	return curcomm

/proc/add_eslpoint(key)
	if(!key)
		return
	var/curcomm = 0
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/esl.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	if(json["ESL"])
		curcomm = json["ESL"]

	curcomm++
	json["ESL"] = curcomm
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	if(get_playerquality(key) > -5)
		adjust_playerquality(-1, ckey(key))

/proc/get_eslpoints(key)
	if(!key)
		return
	var/curcomm = 0
	var/json_file = file("data/player_saves/[copytext(key,1,2)]/[key]/esl.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(json["ESL"])
		curcomm = json["ESL"]
	if(!curcomm)
		curcomm = 0
	return curcomm

