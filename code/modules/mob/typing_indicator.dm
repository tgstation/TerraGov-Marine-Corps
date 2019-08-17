/mob/proc/add_typing_indicator(emoting)
	if(stat != CONSCIOUS || !client.prefs.show_typing)
		return

	if(emoting)
		typing_indicator = image('icons/mob/talk.dmi', src, "emoting")
	else
		typing_indicator = image('icons/mob/talk.dmi', src, "typing")

	add_emote_overlay(typing_indicator, remove_delay = NONE)


/mob/proc/remove_typing_indicator(emoting)
	if(!typing_indicator)
		return

	remove_emote_overlay(client, typing_indicator, viewers())
	typing_indicator = null


/mob/verb/say_wrapper()
	set name = ".Say"
	set hidden = TRUE

	add_typing_indicator()
	var/message = input("", "Say") as text
	remove_typing_indicator()

	if(!message)
		return

	say_verb(message)


/mob/verb/me_wrapper()
	set name = ".Me"
	set hidden = TRUE

	add_typing_indicator(emoting = TRUE)
	var/message = input("", "Me \"text\"") as null|text
	remove_typing_indicator(emoting = TRUE)

	if(!message)
		return

	me_verb(message)
