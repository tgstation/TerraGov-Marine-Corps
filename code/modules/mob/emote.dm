// All mobs should have custom emote, really..
/mob/proc/custom_emote(var/m_type = EMOTE_VISIBLE, var/message = null, player_caused)
	var/comm_paygrade = ""

	if(stat || (!use_me && player_caused))
		if(player_caused)
			to_chat(src, "You are unable to emote.")
		return

	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		comm_paygrade = H.get_paygrade()

	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)
	if(m_type == EMOTE_AUDIBLE && muzzled)
		return

	var/input
	if(!message)
		input = copytext(sanitize(input(src, "Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
	else
		input = message

	if(input)
		message = "<B>[comm_paygrade][src]</B> [input]"
	else
		return


	if(message)
		log_message(message, LOG_EMOTE)


		for(var/mob/M in GLOB.player_list)
			if (!M.client)
				continue //skip monkeys and leavers
			if (istype(M, /mob/new_player))
				continue
			if(findtext(message," snores.")) //Because we have so many sleeping people.
				break
			if(M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		if(m_type == EMOTE_VISIBLE)
			visible_message(message, message)

		if(m_type == EMOTE_AUDIBLE)
			visible_message(null, null, message)


/mob/proc/emote_dead(var/message)
	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='danger'>You cannot send deadchat emotes (muted).</span>")
		return

	if(!(client.prefs.toggles_chat & CHAT_DEAD))
		to_chat(src, "<span class='danger'>You have deadchat muted.</span>")
		return

	if(!client.holder && !dsay_allowed)
		to_chat(src, "<span class='danger'>Deadchat is globally muted.</span>")
		return

	var/input
	if(!message)
		input = copytext(sanitize(input(src, "Choose an emote to display.") as text|null), 1, MAX_MESSAGE_LEN)
	else
		input = message

	if(input)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <b>[src]</b> [message]</span>"
	else
		return


	if(message)
		log_message(message, LOG_EMOTE)

		for(var/client/C in GLOB.clients)
			if(istype(C.mob, /mob/new_player))
				continue

			if(check_other_rights(C, R_ADMIN, FALSE) && (C.prefs.toggles_chat & CHAT_DEAD))
				to_chat(C, message)

			else if(C.mob.stat == DEAD && (C.prefs.toggles_chat & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				to_chat(C, message)


/mob/living/carbon/verb/show_emotes()
	set name = "Emotes"
	set desc = "Displays a list of usable emotes."
	set category = "IC"

	say("*help")