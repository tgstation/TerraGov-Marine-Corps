/**
 * proc for playing a screen_text on a mob.
 * enqueues it if a screen text is running and plays i otherwise
 * Arguments:
 * * text: text we want to be displayed
 * * alert_type: typepath for screen text type we want to play here
 */
/mob/proc/play_screen_text(text, alert_type = /obj/screen/text/screen_text)
	if(!client)
		return
	var/obj/screen/text/screen_text/text_box = new alert_type()
	text_box.text_to_play = text
	LAZYADD(client.screen_texts, text_box)
	if(LAZYLEN(client.screen_texts) == 1) //lets only play one at a time, for thematic effect and prevent overlap
		INVOKE_ASYNC(text_box, /obj/screen/text/screen_text.proc/play_to_client, client)
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
	///letters to update by per text to per play_delay
	var/letters_per_update = 1

	///opening styling for the message
	var/style_open = "<span class='maptext' style=text-align:center valign='top'>"
	///closing styling for the message
	var/style_close = "</span>"
	///var for the text we are going to play
	var/text_to_play

/**
 * proc for actually playing this screen_text on a mob.
 * Arguments:
 * * player: client to play to
 */
/obj/screen/text/screen_text/proc/play_to_client(client/player)
	player?.screen += src
	if(fade_in_time)
		animate(src, alpha = 255)
	var/list/lines_to_skip = list()
	var/static/html_locate_regex = regex("<.*>")
	var/tag_position = findtext(text_to_play, html_locate_regex)
	var/reading_tag = TRUE
	while(tag_position)
		if(reading_tag)
			if(text_to_play[tag_position] == ">")
				reading_tag = FALSE
				lines_to_skip += tag_position
			else
				lines_to_skip += tag_position
			tag_position++
		else
			tag_position = findtext(text_to_play, html_locate_regex, tag_position)
			reading_tag = TRUE
	for(var/letter = 2 to length(text_to_play) + letters_per_update step letters_per_update)
		if(letter in lines_to_skip)
			continue
		maptext = "[style_open][copytext_char(text_to_play, 1, letter)][style_close]"
		sleep(play_delay)
	addtimer(CALLBACK(src, .proc/after_play, player), fade_out_delay)

///handles post-play effects like fade out after the fade out delay
/obj/screen/text/screen_text/proc/after_play(client/player)
	if(!fade_out_time)
		end_play(player)
		return
	animate(src, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, .proc/end_play, player), fade_out_time)

///ends the play then deletes this screen object and plays the next one in queue if it exists
/obj/screen/text/screen_text/proc/end_play(client/player)
	player.screen -= src
	LAZYREMOVE(player.screen_texts, src)
	qdel(src)
	if(!LAZYLEN(player.screen_texts))
		return
	player.screen_texts[1].play_to_client(player)
