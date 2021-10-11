/client
	///lazylist of screen_texts in
	var/list/obj/screen/text/screen_text/screen_texts

/**
 * proc for playing a screen_text on a mob.
 * enqueues it if a screen text is running and plays i otherwise
 * Arguments:
 * * text: text we want to be displayed. do not use html formatting here
 * * title: text we play before text. seperately formatted, do not use html formatting here
 * * alert_type: typepath for screen text type we want to play here
 */
/mob/proc/play_screen_text(text, title, alert_type = /obj/screen/text/screen_text)
	if(!client)
		return
	var/obj/screen/text/screen_text/text_box = new alert_type()
	text_box.text_to_play = text
	text_box.title_to_play = title
	LAZYADD(client.screen_texts, text_box)
	if(LAZYLEN(client.screen_texts) == 1) //lets only play one at a time, for thematic effect and prevent overlap
		text_box.play_to_client(client)
		return
	client.screen_texts += text_box


/obj/screen/text/screen_text
	icon = null
	icon_state = null
	alpha = 255

	maptext_height = 64
	maptext_width = 480
	maptext_x = 0
	maptext_y = 0
	screen_loc = "LEFT,TOP-3"

	///Time taken to fade in as we start printing text
	var/fade_in_time = 0
	///Time before fade out after printing is finished
	var/fade_out_delay = 2 SECONDS
	///Time taken when fading out after fade_out_delay
	var/fade_out_time = 0.5 SECONDS
	///delay between playing each letter. in general use 1 for fluff and 0.5 for time sensitive messsages
	var/play_delay = 0.5

	///opening styling for the title
	var/title_style
	///closing styling for the title
	var/title_close
	///opening styling for the message
	var/style_open = "<span class='maptext' style=text-align:center valign='top'>"
	///closing styling for the message
	var/style_close = "</span>"
	///Var for the seperately styled title we are going to play
	var/title_to_play
	///var for the text we are going to play
	var/text_to_play

/**
 * proc for actually playing this screen_text on a mob.
 * Arguments:
 * * player: client to play to
 */
/obj/screen/text/screen_text/proc/play_to_client(client/player)
	player.screen += src
	if(fade_in_time)
		animate(src, alpha = 255)
	for(var/letter=2 to length(title_to_play)+1)
		maptext = "[title_style][copytext_char(title_to_play, 1, letter)][title_close]"
		sleep(play_delay)
	for(var/letter=2 to length(text_to_play)+1)
		maptext = "[title_style][title_to_play][title_close][style_open][copytext_char(text_to_play, 1, letter)][style_close]"
		sleep(play_delay)
	addtimer(CALLBACK(src, .proc/after_play, player), fade_out_delay)

///handles post-play effects like fade out after the fade out delay
/obj/screen/text/screen_text/proc/after_play(client/player)
	if(!fade_out_time)
		end_play(player)
		return
	animate(src, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, .proc/end_play, player), fade_out_time)

///ends the play then deletes this screen object and plalys the next one in queue if it exists
/obj/screen/text/screen_text/proc/end_play(client/player)
	player.screen -= src
	LAZYREMOVE(player.screen_texts, src)
	qdel(src)
	if(!LAZYLEN(player.screen_texts))
		return
	player.screen_texts[1].play_to_client(player)
