/*/mob/dead/new_player/proc/register_discord()
	set category = "Register"
	set name = "RegisterDiscord"
	
	if(!client)
		return
	if(client.discord_registration)
		to_chat(src, "<span class='warning'>You're currently registering, please wait.</span>")
		return
	if(client.discord_name())
		verbs -= /mob/dead/new_player/proc/register_discord
		to_chat(src, "<span class='warning'>You're already registered.</span>")
		return
	var/namey = input("Join the roguetown discord at https://discord.gg/9uYTPsRMKa, then input your discord ACCOUNT name below. (e.g. zeththemagician#1747)","ROGUETOWN") as text|null
	if(!namey || !ckey)
		return
	if(length(namey) > 37)
		to_chat(src, "<span class='warning'>Too many characters.</span>")
		return
	if(client.discord_registration)
		to_chat(src, "<span class='warning'>You're currently registering, please wait.</span>")
		return
	if(client.discord_name())
		to_chat(src, "<span class='warning'>You're already registered.</span>")
		return
	if(!check_discord_name(namey))
		to_chat(src, "<span class='warning'>That discord is already registered.</span>")
		return
	do_bot_thing_register(namey, ckey)
	client.discord_registration = namey
	var/name2 = input("Now message \"THE MESSENGER\" in the discord with the command below and then click OK to finish registration.","ROGUETOWN","!register [ckey]") as text|null
	if(!name2)
		client.discord_registration = null
		to_chat(src, "<span class='userdanger'>Registration cancelled.</span>")
		return
	to_chat(src, "<span class='userdanger'>Registering [namey], please wait....</span>")
	addtimer(CALLBACK(src, .proc/discordtimeout), 5 SECONDS, TIMER_STOPPABLE)

*/
/mob/dead/new_player/proc/discordtimeout()
	if(!client)
		return
	if(client.discord_name())
		return
	if(!do_bot_thing_regconfirm(ckey))
		client.discord_registration = null
		to_chat(src, "<span class='warning'>Discord registration timed out. Try again?</span>")
	else
		world.registery_discord(ckey)
		return
	if(client.discord_name)
		return
	client.discord_registration = null
	to_chat(src, "<span class='warning'>Discord registration timed out. Try again?</span>")

/proc/check_discord_name(namey)
	var/json_file = file("data/ckey2discord.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	for(var/X in json)
		if(json[X] == namey)
			return FALSE
	return TRUE

/proc/do_bot_thing_register(cord,keyy)
	spawn(-1)
		world.Export("http://85.214.207.37:1622/register_user?ckey=[keyy]&uid=[cord]")

/proc/do_bot_thing_regconfirm(keyy)
	var/list/http = world.Export("http://85.214.207.37:1622/register_user/check?ckey=[keyy]")
	if(!http)
		return
	var/F = file2text(http["CONTENT"])
	if(F)
		if(F == "1")
			return TRUE
		if(F == 1)
			return TRUE


/client/proc/discord_name()
	if(discord_name)
		return discord_name
	var/json_file = file("data/ckey2discord.json")
	if(!fexists(json_file))
		WRITE_FILE(json_file, "{}")
	var/list/json = json_decode(file2text(json_file))
	if(ckey in json)
		discord_name = json[ckey]
	return discord_name

/world/proc/registery_discord(keyy)
	if(!keyy)
		return
	for(var/client/C in GLOB.clients)
		if(C.ckey == keyy)
			var/json_file = file("data/ckey2discord.json")
			if(!fexists(json_file))
				WRITE_FILE(json_file, "{}")
			if(!C.discord_registration || C.discord_name())
				to_chat(C, "<span class='warning'>Something went wrong registering your discord!</span>")
				return
			var/list/json = json_decode(file2text(json_file))
			json[keyy] = C.discord_registration
			fdel(json_file)
			WRITE_FILE(json_file, json_encode(json))
			C.discord_name()
			C.discord_registration = null
			if(C.prefs)
				C.prefs.ShowChoices(C.mob,4)
			to_chat(C, "<span class='boldnotice'>Discord registration success!</span>")
/*			if(istype(C.mob, /mob/dead/new_player))
				var/mob/dead/new_player/N = C.mob
				N.verbs -= /mob/dead/new_player/proc/register_discord*/
			return
