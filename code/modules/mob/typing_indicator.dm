/mob/proc/toggle_typing_indicator(emoting)
	var/image/typing_indicator

	if(emoting)
		typing_indicator = image('icons/mob/talk.dmi', src, "emoting")
	else
		typing_indicator = image('icons/mob/talk.dmi', src, "typing")

	if(!(client?.prefs?.show_typing))
		remove_emote_overlay(client, typing_indicator, viewers())
		return

	if(typing)
		remove_emote_overlay(client, typing, viewers())
		typing = null

	else if(stat == CONSCIOUS)
		typing = typing_indicator
		add_emote_overlay(typing, remove_delay = NONE)


/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	toggle_typing_indicator()
	var/message = input("", "Say") as text
	toggle_typing_indicator()

	if(!message)
		return

	say_verb(message)


/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	toggle_typing_indicator(emoting = TRUE)
	var/message = input("", "Me") as text
	toggle_typing_indicator(emoting = TRUE)

	if(!message)
		return

	me_verb(message)