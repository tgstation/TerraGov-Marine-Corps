SUBSYSTEM_DEF(triumphs)
	name = "Triumphs"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_TRIUMPHS
	var/list/topten

//amke this queue events and do them all at once when the triumph subsystem fires, like clearing the list or adding tris.
//cache for get_triumphs and edit cache immediately

/datum/controller/subsystem/triumphs/Initialize()
	. = ..()
	if(!topten)
		topten = get_triumphs_top()

/mob/proc/adjust_triumphs(amt, counted = TRUE)
	if(!key)
		return
	else
		SStriumphs.triumph_adjust(amt, key)
	if(amt > 0)
		if(counted)
			SSticker.tri_gained += amt
		to_chat(src, "\n<font color='purple'>[amt] TRIUMPH(S) awarded.</font>")
	else if(amt < 0)
		if(counted)
			SSticker.tri_lost += amt
		to_chat(src, "\n<font color='purple'>[amt*-1] TRIUMPH(S) lost.</font>")

/client/proc/adjust_triumphs(amt, counted = TRUE)
	if(!ckey)
		return
	else
		SStriumphs.triumph_adjust(amt, ckey)

	if(amt > 0)
		if(counted)
			SSticker.tri_gained += amt
		to_chat(src, "\n<font color='purple'>[amt] TRIUMPH(S) awarded.</font>")
	else if(amt < 0)
		if(counted)
			SSticker.tri_lost += amt
		to_chat(src, "\n<font color='purple'>[amt*-1] TRIUMPH(S) lost.</font>")



/datum/mind/proc/adjust_triumphs(amt, counted = TRUE)
	if(!key)
		return
	else
		SStriumphs.triumph_adjust(amt, key)
	if(amt > 0)
		if(counted)
			SSticker.tri_gained += amt
		if(current)
			to_chat(current, "\n<font color='purple'>[amt] TRIUMPH(S) awarded.</font>")
	else if(amt < 0)
		if(counted)
			SSticker.tri_lost += amt
		if(current)
			to_chat(current, "\n<font color='purple'>[amt*-1] TRIUMPH(S) lost.</font>")

/mob/proc/show_triumphs_list()
	return SStriumphs.triumph_leaderboard(src)

/mob/proc/get_triumphs()
	if(!key)
		return
	return SStriumphs.get_triumphs(key)

/datum/controller/subsystem/triumphs/proc/triumph_adjust(amt, key)
	var/curtriumphs = 0
	var/json_file = file("data/triumphs.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))

	if(json[key])
		curtriumphs = json[key]
	curtriumphs += amt

	json[key] = curtriumphs

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

/datum/controller/subsystem/triumphs/proc/wipe_triumphs(key)
	var/json_file = file("data/triumphs.json")
	if(fexists(json_file))
		fdel(json_file)
//	WRITE_FILE(json_file, "{}")
//	var/list/json = json_decode(file2text(json_file))
	var/list/json = list()

	if(key)
		json[key] = 1

	WRITE_FILE(json_file, json_encode(json))

/datum/controller/subsystem/triumphs/proc/get_triumphs(key)
	var/json_file = file("data/triumphs.json")
	if(!fexists(json_file))
		return 0
	var/list/json = json_decode(file2text(json_file))

	if(json[key])
		return json[key]
	else
		triumph_adjust(0, key)
	return 0

/datum/controller/subsystem/triumphs/proc/triumph_leaderboard(mob/user)
	if(!topten || !topten.len)
		topten = get_triumphs_top()
	if(!topten || !topten.len)
		testing("FAILED TOPTEN")
		return
	if(!user)
		return
	var/list/outputt = list("<B>CHAMPIONS OF PSYDONIA</B><br>")

	outputt += "<hr><br>"
	var/vals = 0
	for(var/X in topten)
		vals++
		if(vals >= 21)
			break
		outputt += "[vals]. [X] - [topten[X]]<br>"

	if(outputt)
		user << browse(outputt.Join(),"window=topten;size=300x500")

/datum/controller/subsystem/triumphs/proc/get_triumphs_top(key)
	var/json_file = file("data/triumphs.json")
	if(!fexists(json_file))
		return list()
	var/list/json = json_decode(file2text(json_file))

	var/list/nulist = list()
	for(var/X in json)
		if(nulist.len)
			for(var/Y in nulist)
				if(nulist[Y] < json[X])
					nulist.Insert(nulist.Find(Y), X)
					nulist[X] = json[X]
					break
			if(nulist.Find(X))
				continue
		nulist += X
		nulist[X] = json[X]



//		for(var/Y in json)
//			if(Y == X)
//				continue
//			if(json[Y] > json[X])
//				json.Swap(json.Find(X),json.Find(Y))
//				break
	return nulist


/mob/dead/new_player/verb/hiderole()
	set category = "Triumphs"
	set name = "HideRole"
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		if(client.ckey in GLOB.hiderole)
			to_chat(src, "I am hidden until the next round.")
		else
			if(client.patreonlevel() >= 1)
				if(alert(src,"Hide your choice of role this round?","ROGUETOWN","YES","NO") == "YES")
					if(SSticker.current_state <= GAME_STATE_PREGAME)
						to_chat(src, "Anonymous... OK")
						GLOB.hiderole += client.ckey
					else
						to_chat(src, "It's too late.")
			else
				if(alert(src,"Hide your choice of role this round?","ROGUETOWN","YES","NO") == "YES")
					if(SSticker.current_state <= GAME_STATE_PREGAME)
						if(get_triumphs() >= 1)
							adjust_triumphs(-1)
							to_chat(src, "Anonymous... OK")
							GLOB.hiderole += client.ckey
						else
							to_chat(src, "I haven't TRIUMPHED enough.")
					else
						to_chat(src, "It's too late.")
	else
		to_chat(src, "It's too late.")

/mob/dead/new_player/verb/donatorupgrade()
	set category = "Triumphs"
	set name = "DonateTriumphs"
	if(!client)
		return
	var/plev = client.patreonlevel()
	var/amt = input(src, "Donate Triumphs (Gives you donator bonuses for one round)", "ROGUETOWN") as null|anything in list("10 TRI", "25 TRI", "50 TRI")
	var/added
	var/amt2take = 0
	if(amt == "10 TRI")
		added = 1
		amt2take = 10
	if(amt == "25 TRI")
		added = 2
		amt2take = 25
	if(amt == "50 TRI")
		added = 3
		amt2take = 50
	if(!amt2take || !added)
		return
	if(plev >= added)
		to_chat(src, "No need to trade for what you already possess.")
		return
	if(src.get_triumphs() < amt2take)
		to_chat(src, "<span class='warning'>I haven't TRIUMPHED enough.</span>")
		return
	src.adjust_triumphs(-1 * amt2take)
	GLOB.temporary_donators[ckey] = added
	client.patreonlevel = -1 //reset our shit
	var/shown_patreon_level = client.patreonlevel()
	client.add_patreon_verbs()
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
			shown_patreon_level = "Magistrate"
		if(5)
			shown_patreon_level = "Lord"
	to_chat(src, "<span class='info'>Your Patreon Level: [shown_patreon_level]</span>")

/mob/dead/new_player/verb/forcerogueworld()
	set category = "Triumphs"
	set name = "Rogueworld"
	set hidden=1
#ifdef TESTSERVER
	return
#endif
	if(!client)
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(src, "<span class='warning'>Too late.</span>")
		return
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.allmig || C.roguefight)
			to_chat(src, "<span class='warning'>Too late.</span>")
			return
		if(alert(src,"Force ROGUEWORLD? (30 TRI)","ROGUETOWN","YES","NO") == "YES")
			if(SSticker.current_state <= GAME_STATE_PREGAME)
				if(get_triumphs() >= 30)
					adjust_triumphs(-30)
					to_chat(world, "<span class='greentext'>ROGUEWORLD has been summoned by [client.ckey]!</span>")
					var/icon/ikon
					var/file_path = "icons/rogueworld_title.dmi"
					ASSERT(fexists(file_path))
					ikon = new(fcopy_rsc(file_path))
					if(SStitle.splash_turf && ikon)
						SStitle.splash_turf.icon = ikon
					for(var/mob/dead/new_player/player in GLOB.player_list)
						player.playsound_local(player, 'sound/music/wartitle.ogg', 100, TRUE)
					SSticker.isrogueworld = TRUE
					SSticker.failedstarts = 13
					SSticker.current_state = GAME_STATE_SETTING_UP
					Master.SetRunLevel(RUNLEVEL_SETUP)
					if(SSticker.start_immediately)
						SSticker.fire()
				else
					to_chat(src, "I haven't TRIUMPHED enough.")

/mob/dead/new_player/verb/wipetriumphs()
	set category = "Triumphs"
	set name = "WipeTriumphs"
	if(!client)
		return
	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(src, "<span class='warning'>Too late.</span>")
		return
	if(alert(src,"Burn down the hall of TRIUMPHS?","ROGUETOWN","YES","NO") == "YES")
		if(SSticker.current_state <= GAME_STATE_PREGAME)
			if(get_triumphs() >= 1000)
				to_chat(world, "<span class='redtext'>[client.ckey] burns the hall of triumphs to the ground!</span>")
				SStriumphs.wipe_triumphs(key)
			else
				to_chat(src, "I haven't TRIUMPHED enough.")

/client/proc/adjusttriumph()
	set category = "GameMaster"
	set name = "Adjust Triumphs"
	var/input = input(src, "how much") as num
	if(mob && input)
		mob.adjust_triumphs(input)

#ifdef TESTSERVER
/client/verb/adjusttriumphnerds()
	set category = "DEBUGTEST"
	set name = "Adjust Triumphs"
	var/input = input(src, "how much") as num
	if(mob && input)
		mob.adjust_triumphs(input)

/*
/client/verb/scalethingz()
	set category = "DEBUGTEST"
	set name = "scale thing"
	if(!isliving(mob))
		return
	var/atom/thing = input(mob, "what thing", "ROGUETOWN") as null|anything in range(mob, 2)
	var/input = input(mob, "scale?") as num
	if(input && thing)
		var/matrix/M = new
		M.Scale(input,input)
		thing.transform = M*/
#endif

/*
/mob/dead/ghost/verb/hiderole()
	set category = "Triumphs"
	set name = "Invade"
	var/plev = client.patreonlevel()
	if(src in GLOB.ambush_candidates)
		to_chat(src, "I leave the invader queue.")
		ambush_candidates -= src
		return
	if(alert(src,"Invade another player? (You will join an ambush)","ROGUETOWN","YES","NO") == "YES")
		if((get_triumphs() < 5) && (plev < 3))
			to_chat(src, "I haven't TRIUMPHED enough.")
			return
		else
			ambush_candidates |= src
			to_chat(src, "I join the invader queue.")


	//to_chat(src, "It's my turn to invade, but I didn't have enough triumphs.")
	//ambush_candidates -= src
*/
/*
/mob/dead/new_player/verb/paramsthing()
	set category = "DEBUGTEST"
	set name = "Paramstest"
	var/list/L = list()
	L["fuck"] = "negro"
	testing("list [list2params(L)]")
*/
