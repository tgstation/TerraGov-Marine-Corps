//Please use mob or src (not usr) in these procs. This way they can be called in the same fashion as procs.
/client/verb/wiki()
	set name = "wiki"
	set hidden = TRUE

	if(!CONFIG_GET(string/wikiurl))
		to_chat(src, "<span class='warning'>The wiki URL is not set in the server configuration.</span>")
		return

	if(alert("This will open the wiki in your browser. Are you sure?", "Wiki", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/wikiurl)))
		

/client/verb/forum()
	set name = "forum"
	set hidden = TRUE

	if(!CONFIG_GET(string/forumurl))
		to_chat(src, "<span class='warning'>The forum URL is not set in the server configuration.</span>")
		return

	if(alert("This will open the forum in your browser. Are you sure?", "Forum", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/forumurl)))


/client/verb/rules()
	set name = "rules"
	set hidden = TRUE

	if(!CONFIG_GET(string/rulesurl))
		to_chat(src, "<span class='warning'>The rules URL is not set in the server configuration.</span>")
		return

	if(alert("This will open the rules in your browser. Are you sure?", "Rules", "Yes", "No") != "Yes")
		return
	
	DIRECT_OUTPUT(src, link(CONFIG_GET(string/rulesurl)))


/client/verb/discord()
	set name = "discord"
	set hidden = TRUE

	if(!CONFIG_GET(string/discordurl))
		to_chat(src, "<span class='warning'>The Discord URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our Discord in your browser. Are you sure?", "Discord", "Yes", "No") != "Yes")
		return

	DIRECT_OUTPUT(src, link(CONFIG_GET(string/discordurl)))


/client/verb/github()
	set name = "github"
	set hidden = TRUE

	if(!CONFIG_GET(string/githuburl))
		to_chat(src, "<span class='warning'>The bug tracker URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our bug tracker page in your browser. Are you sure?", "Github", "Yes", "No") != "Yes")
		return
	
	DIRECT_OUTPUT(src, link(CONFIG_GET(string/githuburl)))
		

/client/verb/webmap()
	set name = "webmap"
	set hidden = TRUE

	var/ship_link = CONFIG_GET(string/shipurl)
	var/ground_link
	
	var/choice = alert("Do you want to view the ground or the ship?",,"Ship","Ground","Cancel")
	switch(choice)
		if("Ship")
			if(!ship_link)
				to_chat(src, "<span class='warning'>This ship map has no webmap setup.</span>")
				return
			DIRECT_OUTPUT(src, link(ship_link))
		if("Ground")
			switch(SSmapping.configs[GROUND_MAP].map_name)
				if("Ice Colony")
					ground_link = CONFIG_GET(string/icecolonyurl)
				if("LV624")
					ground_link = CONFIG_GET(string/lv624url)
				if("Big Red")
					ground_link = CONFIG_GET(string/bigredurl)
				if("Prison Station")
					ground_link = CONFIG_GET(string/prisonstationurl)
				if("Whiskey Outpost")
					ground_link = CONFIG_GET(string/whiskeyoutposturl)
			if(!ground_link)
				to_chat(src, "<span class='warning'>This ground map has no webmap setup.</span>")
				return
			DIRECT_OUTPUT(src, link(ground_link))