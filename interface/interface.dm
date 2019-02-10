//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set desc = "Visit the wiki."
	set hidden = TRUE
	if(CONFIG_GET(string/wikiurl))
		if(alert("This will open the wiki in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(CONFIG_GET(string/wikiurl))
	else
		to_chat(src, "<span class='warning'>The wiki URL is not set in the server configuration.</span>")
	return

/client/verb/forum()
	set name = "forum"
	set desc = "Visit the forum."
	set hidden = TRUE
	if(CONFIG_GET(string/forumurl))
		if(alert("This will open the forum in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(CONFIG_GET(string/forumurl))
	else
		to_chat(src, "<span class='warning'>The forum URL is not set in the server configuration.</span>")
	return

/client/verb/rules()
	set name = "rules"
	set desc = "Read our rules."
	set hidden = TRUE
	if(CONFIG_GET(string/rulesurl))
		if(alert("This will open the rules in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(CONFIG_GET(string/rulesurl))
	else
		to_chat(src, "<span class='warning'>The rules URL is not set in the server configuration.</span>")
	return

/client/verb/patreon()
	set name = "Patreon"
	set desc = "Like our server? Buy us and get satisfaction for your efforts."
	set hidden = TRUE
	if(CONFIG_GET(string/donationurl))
		if(alert("This will open our donation page in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(CONFIG_GET(string/donationurl))
	else
		to_chat(src, "<span class='warning'>The donation URL is not set in the server configuration.</span>")
	return


/client/verb/discord()
	set name = "Discord"
	set desc = "Like our server? Buy us and get satisfaction for your efforts."
	set hidden = TRUE

	if(!CONFIG_GET(string/discordurl))
		to_chat(src, "<span class='warning'>The Discord URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our Discord in your browser. Are you sure?", "Confirmation", "Yes", "No") != "Yes")
		return

	src << link(CONFIG_GET(string/discordurl))


/client/verb/submitbug()
	set name = "Submit Bug"
	set desc = "Submit a bug."
	set hidden = TRUE
	if(CONFIG_GET(string/githuburl))
		if(alert("This will open our bug tracker page in your browser. Are you sure?",,"Yes","No")=="No")
			return
		src << link(CONFIG_GET(string/githuburl))
	else
		to_chat(src, "<span class='warning'>The bug tracker URL is not set in the server configuration.</span>")
	return

/client/verb/webmap()
	var/ship_link
	var/ground_link
	set name = "webmap"
	set desc = "Opens the webmap"
	set hidden = TRUE
	var/choice = alert("Do you want to view the ground or the ship?",,"Ship","Ground","Cancel")
	switch(choice)
		if("Ship")
			switch(MAIN_SHIP_NAME)
				if("TGS Theseus")
					ship_link = CONFIG_GET(string/shipurl)
			if(!ship_link)
				to_chat(src, "<span class='warning'>This ship map has no webmap setup.</span>")
				return
			src << link(ship_link)
		if("Ground")
			switch(GLOB.map_tag)
				if("Ice Colony")
					ground_link = CONFIG_GET(string/icecolonyurl)
				if("LV-624")
					ground_link = CONFIG_GET(string/lv624url)
				if("Solaris Ridge")
					ground_link = CONFIG_GET(string/bigredurl)
				if("Prison Station")
					ground_link = CONFIG_GET(string/prisonstationurl)
				if("Whiskey Outpost")
					ground_link = CONFIG_GET(string/whiskeyoutposturl)
			if(!ground_link)
				to_chat(src, "<span class='warning'>This ground map has no webmap setup.</span>")
				return
			src << link(ground_link)
		else
			return
	return

/client/verb/hotkeys_help()
	set name = "Hotkeys"
	set category = "OOC"

	var/hotkey_mode = {"<font color='purple'>
Hotkey-Mode: (hotkey-mode must be on)
\tTAB = toggle hotkey-mode
\ta = left
\ts = down
\td = right
\tw = up
\tq = drop
\te = equip
\tr = throw
\tm = me
\tt = say
\to = ooc
\tspace = unique-action (commonly for pumping shotguns)
\tx = swap-hand
\tz = activate held object (or y)
\t1 = help-intent
\t2 = disarm-intent
\t3 = grab-intent
\t4 = harm-intent
</font>"}

	var/other = {"<font color='purple'>
Any-Mode: (hotkey doesn't need to be on)
\tCtrl+a = left
\tCtrl+s = down
\tCtrl+d = right
\tCtrl+w = up
\tCtrl+q = drop
\tCtrl+e = equip
\tCtrl+r = throw
\tCtrl+x = swap-hand
\tCtrl+z = activate held object (or Ctrl+y)
\tCtrl+o = ooc
\tspace = unique-action (commonly for pumping shotguns)
\tCtrl+1 = help-intent
\tCtrl+2 = disarm-intent
\tCtrl+3 = grab-intent
\tCtrl+4 = harm-intent
\tDEL = pull
\tINS = cycle-intents-right
\tHOME = drop
\tPGUP = swap-hand
\tPGDN = activate held object
\tEND = throw
</font>"}

	var/admin = {"<font color='purple'>
Admin:
\tF3 = Asay (adminsay)
\tF5 = Aghost (admin-ghost)
\tF6 = player-panel
\tF7 = admin-pm
\tF8 = Invisimin
</font>"}

	src << hotkey_mode
	src << other
	if(holder)
		src << admin
