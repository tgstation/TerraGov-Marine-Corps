/obj/item/clothing/head/helmet/headphones
	name = "Nanotrasen brand headphones"
	desc = "A pair of black headphones, perfect for playing any music, anywhere!"
	icon_state = "headphones"
	item_state = "headphones"
	var/musiclink
	var/list/queuedmusic

/obj/item/clothing/head/helmet/headphones/verb/addmusic()
	set category = "Headphones"
	set name = "Add music!"

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(usr, "<span class='warning'>Youtube-dl was not configured, action unavailable.</span>")
		return

	var/web_sound_input = input("Enter content URL (supported sites only)", "Play Internet Sound via youtube-dl") as text|null
	if(!istext(web_sound_input) || !length(web_sound_input))
		return

	web_sound_input = trim(web_sound_input)

	if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
		to_chat(usr, "<span class='warning'>Non-http(s) URls are not allowed.</span>")
		to_chat(usr, "<span class='warning'>For youtube-dl shortcuts like ytsearch: please use the appropriate full url from the website.</span>")
		return
	if(!musiclink)
		musiclink = web_sound_input
	else
		if(LAZYLEN(queuedmusic) >= 9)
			to_chat(usr, "<span class='warning'>Too many songs in queue!</span>")
			return
		LAZYADD(queuedmusic, web_sound_input)

/obj/item/clothing/head/helmet/headphones/verb/playmusic()
	set category = "Headphones"
	set name = "Play next song!"

	if(!musiclink)
		to_chat(usr, "<span class='warning'>You must have a valid song in the queue!</span>")
		return

	var/web_sound_url = ""
	var/list/music_extra_data = list()
	var/title

	var/list/output = world.shelleo("[CONFIG_GET(string/invoke_youtubedl)] --format \"bestaudio\[ext=mp3]/best\[ext=mp4]\[height<=360]/bestaudio\[ext=m4a]/bestaudio\[ext=aac]\" --dump-single-json --no-playlist -- \"[shell_url_scrub(musiclink)]\"")
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]

	musiclink = null

	if(errorlevel)
		to_chat(usr, "<span class='warning'>Youtube-dl URL retrieval FAILED: [stderr]</span>")
		return

	var/list/data = list()
	try
		data = json_decode(stdout)
	catch(var/exception/e)
		to_chat(usr, "<span class='warning'>Youtube-dl JSON parsing FAILED: [e]: [stdout]</span>")
		return

	if(data["url"])
		web_sound_url = data["url"]
		title = data["title"]
		music_extra_data["start"] = data["start_time"]
		music_extra_data["end"] = data["end_time"]

	if(web_sound_url && !findtext(web_sound_url, GLOB.is_http_protocol))
		to_chat(usr, "<span class='warning'>BLOCKED: Content URL not using http(s) protocol</span>")
		to_chat(usr, "<span class='warning'>The media provider returned a content URL that isn't using the HTTP or HTTPS protocol</span>")
		return

	var/client/C = usr?.client
	if(!C?.prefs)
		return
	if((C.prefs.toggles_sound & SOUND_MIDI) && C.chatOutput?.working && C.chatOutput.loaded)
		C.chatOutput.sendMusic(web_sound_url, music_extra_data)
		to_chat(C, "<span class='notice'>Now playing: <a href='[data["webpage_url"]]'>[title]</a></span>")
		log_game(" [C] has played <a href='[data["webpage_url"]]'>[title] on their [src]")

	if(queuedmusic)
		musiclink = popleft(queuedmusic)
		if(!length(queuedmusic))
			queuedmusic = null
	RegisterSignal(src, list(COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_PREQDELETED), .verb/stopmusic, TRUE)

/obj/item/clothing/head/helmet/headphones/verb/stopmusic()
	set category = "Headphones"
	set name = "Stop current music"

	var/client/C = usr?.client

	if(C.chatOutput?.working && C.chatOutput.loaded)
		C.chatOutput.stopMusic()
	UnregisterSignal(src, list(COMSIG_ITEM_UNEQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_PARENT_PREQDELETED))
