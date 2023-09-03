/datum/admins/proc/show_player_panel(mob/M in GLOB.mob_list)
	set category = null
	set name = "Show Player Panel"

	if(!check_rights(R_ADMIN))
		return

	if(!istype(M))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/body

	body += "<b>[M.name]</b>"

	if(M.client)
		body += " played by <b>[M.client]</b> "
		body += " <a href='?src=[ref];editrights=[(GLOB.admin_datums[M.client.ckey] || GLOB.deadmins[M.client.ckey]) ? "rank" : "add"];key=[M.key];close=1'>[M.client.holder ? M.client.holder.rank : "Player"]</a>"

	if(isnewplayer(M))
		body += " <b>Hasn't Entered Game</b> "
	else
		body += " | <a href='?src=[ref];revive=[REF(M)]'>Heal</a> | <a href='?src=[ref];sleep=[REF(M)]'>Sleep</a>"

	body += {"
		<br><br>
		<a href='?priv_msg=[M.ckey]'>PM</a> -
		<a href='?src=[ref];subtlemessage=[REF(M)]'>SM</a> -
		<a href='?_src_=vars;[HrefToken()];vars=[REF(M)]'>VV</a> -
		<a href='?src=[ref];spawncookie=[REF(M)]'>SC</a> -
		<a href='?src=[ref];spawnfortunecookie=[REF(M)]'>SFC</a> -
		<a href='?src=[ref];observejump=[REF(M)]'>JMP</a> -
		<a href='?src=[ref];observefollow=[REF(M)]'>FLW</a> -
		<a href='?src=[ref];individuallog=[REF(M)]'>LOGS</a></b><br>
		<b>Mob Type:</b> [M.type]<br>
		<b>Mob Location:</b> [AREACOORD(M.loc)]<br>"}

	if(isliving(M))
		var/mob/living/L = M
		body += "<b>Mob Faction:</b> [L.faction]<br>"
		if(L.job)
			body += "<b>Mob Role:</b> [L.job.title]<br>"

	body += "<b>CID:</b> [M.computer_id] | <b>IP:</b> [M.ip_address]<br>"
	if(M.client)
		body += "<br>\[<b>First Seen:</b> [M.client.player_join_date]\]\[<b>Byond account registered on:</b> [M.client.account_join_date]\]"
		if(M.client.related_accounts_cid || M.client.related_accounts_ip)
			//if(M.client.related_accounts_cid != "Requires database" && M.client.related_accounts_ip != "Requires database")
			body += "<br><b><font color=red>Player has related accounts</font></b> "
		body += "\[ <a href='?_src_=holder;[HrefToken()];showrelatedacc=cid;client=[REF(M.client)]'>CID related accounts</a> | "
		body += "<a href='?_src_=holder;[HrefToken()];showrelatedacc=ip;client=[REF(M.client)]'>IP related accounts</a> \]<br>"

	body += "<b>CentCom Galactic Ban DB: </b> "
	if(CONFIG_GET(string/centcom_ban_db))
		body += "<a href='?_src_=holder;[HrefToken()];centcomlookup=[M?.ckey]'>Search for ([M?.ckey])</a>"
	else
		body += "<i>Disabled</i>"

	body += "<br><br>"
	if(M.client)
		body += "<a href='?src=[ref];playtime=[REF(M)]'>Playtime</a> | "
		body += "<a href='?src=[ref];kick=[REF(M)]'>Kick</a> | "
		body += "<a href='?src=[ref];newbankey=[M.key];newbanip=[M.client.address];newbancid=[M.client.computer_id]'>Ban</a> | "
	else
		body += "<a href='?src=[ref];newbankey=[M.key]'>Ban</a> | "

	body += "<a href='?src=[ref];showmessageckey=[M.ckey]'>Notes</a> | "
	body += "<a href='?src=[ref];cryo=[REF(M)]'>Cryo</a>"

	if(M.client)
		body += "| <a href='?src=[ref];lobby=[REF(M)]'> Send back to Lobby</a>"

	body += "<br>"

	if(M.client?.prefs)
		var/muted = M.client.prefs.muted
		body += {"<br><b>Mute: </b>
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_IC]'><font color='[(muted & MUTE_IC) ? "#ff5e5e" : "white"]'>IC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_OOC]'><font color='[(muted & MUTE_OOC) ? "#ff5e5e" : "white"]'>OOC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_LOOC]'><font color='[(muted & MUTE_LOOC) ? "#ff5e5e" : "white"]'>LOOC</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_PRAY]'><font color='[(muted & MUTE_PRAY) ? "#ff5e5e" : "white"]'>PRAY</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_ADMINHELP]'><font color='[(muted & MUTE_ADMINHELP) ? "#ff5e5e" : "white"]'>ADMINHELP</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_DEADCHAT]'><font color='[(muted & MUTE_DEADCHAT) ? "#ff5e5e" : "white"]'>DEADCHAT</font></a> |
			<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_TTS]'><font color='[(muted & MUTE_TTS) ? "#ff5e5e" : "white"]'>TEXT TO SPEECH</font></a>
			(<a href='?src=[ref];mute=[REF(M)];mute_type=[MUTE_ALL]'><font color='[(muted & MUTE_ALL) ? "#ff5e5e" : "white"]'>ALL</font></a>)
		"}

	body += {"
		<br><br>
		<a href='?src=[ref];jumpto=[REF(M)]'>Jump To</a> |
		<a href='?src=[ref];getmob=[REF(M)]'>Get Mob</a> |
		<a href='?src=[ref];sendmob=[REF(M)]'>Send Mob</a>
		<br>
	"}

	body += {"<br>
		<b>Transformation:</b>
		<br> Special:
		<a href='?src=[ref];transform=observer;mob=[REF(M)]'>Observer</a> |
		<a href='?src=[ref];transform=ai;mob=[REF(M)]'>AI</a>
		<a href='?src=[ref];transform=sectoid;mob=[REF(M)]'>Sectoid</a> |
		<a href='?src=[ref];transform=SKELETON;mob=[REF(M)]'>SKELETON</a>
		<br> Humanoid:
		<a href='?src=[ref];transform=human;mob=[REF(M)]'>Human</a> |
		<a href='?src=[ref];transform=synthetic;mob=[REF(M)]'>Synthetic</a> |
		<a href='?src=[ref];transform=early_synth;mob=[REF(M)]'>Early_Synth</a> |
		<a href='?src=[ref];transform=vatborn;mob=[REF(M)]'>Vatborn</a> |
		<a href='?src=[ref];transform=vatgrown;mob=[REF(M)]'>Vatgrown</a> |
		<a href='?src=[ref];transform=combat_robot;mob=[REF(M)]'>Combat_Robot</a> |
		<a href='?src=[ref];transform=monkey;mob=[REF(M)]'>Monkey</a> |
		<a href='?src=[ref];transform=moth;mob=[REF(M)]'>Moth</a> |
		<a href='?src=[ref];transform=zombie;mob=[REF(M)]'>Zombie</a> |
		<br> Alien Tier 0:
		<a href='?src=[ref];transform=larva;mob=[REF(M)]'>Larva</a> |
		<a href='?src=[ref];transform=facehugger;mob=[REF(M)]'>Facehugger</a>
		<br> Alien Tier 1:
		<a href='?src=[ref];transform=runner;mob=[REF(M)]'>Runner</a> |
		<a href='?src=[ref];transform=drone;mob=[REF(M)]'>Drone</a> |
		<a href='?src=[ref];transform=sentinel;mob=[REF(M)]'>Sentinel</a> |
		<a href='?src=[ref];transform=defender;mob=[REF(M)]'>Defender</a> |
		<br> Alien Tier 2:
		<a href='?src=[ref];transform=hunter;mob=[REF(M)]'>Hunter</a> |
		<a href='?src=[ref];transform=bull;mob=[REF(M)]'>Bull</a> |
		<a href='?src=[ref];transform=warrior;mob=[REF(M)]'>Warrior</a> |
		<a href='?src=[ref];transform=spitter;mob=[REF(M)]'>Spitter</a> |
		<a href='?src=[ref];transform=hivelord;mob=[REF(M)]'>Hivelord</a> |
		<a href='?src=[ref];transform=carrier;mob=[REF(M)]'>Carrier</a> |
		<a href='?src=[ref];transform=wraith;mob=[REF(M)]'>Wraith</a>
		<br> Alien Tier 3:
		<a href='?src=[ref];transform=ravager;mob=[REF(M)]'>Ravager</a> |
		<a href='?src=[ref];transform=widow;mob=[REF(M)]'>Widow</a> |
		<a href='?src=[ref];transform=praetorian;mob=[REF(M)]'>Praetorian</a> |
		<a href='?src=[ref];transform=boiler;mob=[REF(M)]'>Boiler</a> |
		<a href='?src=[ref];transform=defiler;mob=[REF(M)]'>Defiler</a> |
		<a href='?src=[ref];transform=crusher;mob=[REF(M)]'>Crusher</a>
		<a href='?src=[ref];transform=gorger;mob=[REF(M)]'>Gorger</a>
		<a href='?src=[ref];transform=warlock;mob=[REF(M)]'>Warlock</a>
		<br> Alien Tier 4:
		<a href='?src=[ref];transform=queen;mob=[REF(M)]'>Queen</a> |
		<a href='?src=[ref];transform=shrike;mob=[REF(M)]'>Shrike</a> |
		<a href='?src=[ref];transform=hivemind;mob=[REF(M)]'>Hivemind</a> |
		<a href='?src=[ref];transform=king;mob=[REF(M)]'>King</a> |
		<br>
	"}


	if(!isnewplayer(M))
		body += "<br><br>"
		body += "<b>Other actions:</b>"
		body += "<br>"
		body += "<a href='?src=[ref];thunderdome=[REF(M)]'>Thunderdome</a> | "
		body += "<a href='?src=[ref];gib=[REF(M)]'>Gib</a>"

		if(isliving(M))
			body += "<br>"
			body += "<a href='?src=[ref];checkcontents=[REF(M)]'>Check Contents</a> | "
			body += "<a href='?src=[ref];offer=[REF(M)]'>Offer Mob</a> | "
			body += "<a href='?src=[ref];give=[REF(M)]'>Give Mob</a>"

			if(ishuman(M))
				body += "<br>"
				body += "<a href='?src=[ref];rankequip=[REF(M)]'>Rank and Equipment</a> | "
				body += "<a href='?src=[ref];editappearance=[REF(M)]'>Edit Appearance</a> | "
				body += "<a href='?src=[ref];randomname=[REF(M)]'>Randomize Name</a>"

	log_admin("[key_name(usr)] opened the player panel of [key_name(M)].")

	var/datum/browser/browser = new(usr, "player_panel_[key_name(M)]", "<div align='center'>Player Panel [key_name(M)]</div>", 575, 555)
	browser.set_content(body)
	browser.open()
