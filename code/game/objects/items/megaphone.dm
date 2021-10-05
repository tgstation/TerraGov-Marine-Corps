/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT

	var/spamcheck = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/megaphone/attack_self(mob/living/user)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, span_warning("You cannot speak in IC (muted)."))
			return
	if(!ishuman(user))
		to_chat(user, span_warning("You don't know how to use this!"))
		return

	if(spamcheck)
		to_chat(user, span_warning("\The [src] needs to recharge!"))
		return

	var/message = stripped_input(user, "Shout a message?", "Megaphone")
	if(!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(user, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[message]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return
	message = capitalize(message)
	user.log_talk(message, LOG_SAY, "(megaphone)")
	if ((src.loc == user && usr.stat == 0))
		user.send_speech("<FONT size=4>[message]</FONT>", message_language = user.get_default_language())

		spamcheck = TRUE
		addtimer(VARSET_CALLBACK(src, spamcheck, FALSE), 2 SECONDS)
