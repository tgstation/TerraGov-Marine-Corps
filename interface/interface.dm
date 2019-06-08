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
	set hidden = TRUE

	if(!CONFIG_GET(string/discordurl))
		to_chat(src, "<span class='warning'>The Discord URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our Discord in your browser. Are you sure?", "Confirmation", "Yes", "No") != "Yes")
		return

	src << link(CONFIG_GET(string/discordurl))


/client/verb/github()
	set name = "Github"
	set desc = "View the repository."
	set hidden = TRUE

	if(!CONFIG_GET(string/githuburl))
		to_chat(src, "<span class='warning'>The bug tracker URL is not set in the server configuration.</span>")
		return

	if(alert("This will open our bug tracker page in your browser. Are you sure?", "Github", "Yes", "No") != "Yes")
		return
	
	src << link(CONFIG_GET(string/githuburl))
		


/client/verb/webmap()
	set name = "webmap"
	set desc = "Opens the webmap"
	set hidden = TRUE

	var/ship_link = CONFIG_GET(string/shipurl)
	var/ground_link
	
	var/choice = alert("Do you want to view the ground or the ship?",,"Ship","Ground","Cancel")
	switch(choice)
		if("Ship")
			if(!ship_link)
				to_chat(src, "<span class='warning'>This ship map has no webmap setup.</span>")
				return
			src << link(ship_link)
		if("Ground")
			switch(SSmapping.config.map_name)
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
			src << link(ground_link)
		else
			return
	return


/client/verb/hotkeys_help()
	set category = "OOC"
	set name = "Hotkeys"

	var/dat = {"<b>Hotkey Mode:</b><br>
TAB = Toggle hotkey mode<br>
A = Left<br>
S = Down<br>
D = Right<br>
W = Up<br>
Q = Drop<br>
E = Draw / Equip<br>
H = Holster<br>
R = Throw<br>
M = Me<br>
T = Say<br>
O = OOC<br>
L = LOOC<br>
Space = Unique action (for many weapons)<br>
X = Swap hands<br>
Z = Activate held object<br>
1 = Help intent<br>
2 = Disarm intent<br>
3 = Grab intent<br>
4 = Harm intent<br>
5 = Toggle move intent<br>"}

	dat += {"<br><b>Any Mode:</b><br>
CTRL+A = Left<br>
CTRL+S = Down<br>
CTRL+D = Right<br>
CTRL+W = Up<br>
CTRL+Q = Drop<br>
CTRL+E = Draw / Equip<br>
CTRL+R = Throw<br>
CTRL+X = Swap hands<br>
CTRL+Z = Activate held object<br>
CTRL+O = OOC<br>
Space = Unique action (for many weapons)<br>
CTRL+1 = Help intent<br>
CTRL+2 = Disarm intent<br>
CTRL+3 = Grab intent<br>
CTRL+4 = Harm intent<br>
DEL = Pull<br>
INS = Cycle intents<br>
HOME = Drop<br>
PGUP = Swap hands<br>
PGDN = Activate held object<br>
END = Throw<br>"}

	if(check_rights(R_ADMIN, FALSE))
		dat +={"<br><b>Admin:</b><br>
F3 = ASAY<br>
F4 = MSAY<br>
F5 = DSAY"}

	var/datum/browser/browser = new(usr, "hotkeys", "<div align='center'>Hotkeys</div>", 300, 400)
	browser.set_content(dat)
	browser.open()