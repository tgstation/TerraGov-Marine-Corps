// All mobs should have custom emote, really..
/mob/proc/custom_emote(var/m_type=1,var/message = null, player_caused)
	var/comm_paygrade = ""
	if(stat || (!use_me && player_caused))
		if(player_caused)
			src << "You are unable to emote."
		return
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		comm_paygrade = H.get_paygrade()
	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	if(m_type == 2 && muzzled) return

	var/input
	if(!message)
		input = copytext(sanitize(input(src,"Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
	else
		input = message
	if(input)
		message = "<B>[comm_paygrade][src]</B> [input]"
	else
		return


	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in player_list)
			if (!M.client)
				continue //skip monkeys and leavers
			if (istype(M, /mob/new_player))
				continue
			if(findtext(message," snores.")) //Because we have so many sleeping people.
				break
			if(M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		// Type 1 (Visual) emotes are sent to anyone in view of the item
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))

				if(O.status_flags & PASSEMOTES)

					for(var/obj/item/holder/H in O.contents)
						H.show_message(message, m_type)

					for(var/mob/living/M in O.contents)
						M.show_message(message, m_type)

				O.show_message(message, m_type)

		// Type 2 (Audible) emotes are sent to anyone in hear range
		// of the *LOCATION* -- this is important for pAIs to be heard
		else if (m_type & 2)
			for (var/mob/O in hearers(get_turf(src), null))

				if(O.status_flags & PASSEMOTES)

					for(var/obj/item/holder/H in O.contents)
						H.show_message(message, m_type)

					for(var/mob/living/M in O.contents)
						M.show_message(message, m_type)

				O.show_message(message, m_type)

/mob/proc/emote_dead(var/message)

	if(client.prefs.muted & MUTE_DEADCHAT)
		src << "\red You cannot send deadchat emotes (muted)."
		return

	if(!(client.prefs.toggles_chat & CHAT_DEAD))
		src << "\red You have deadchat muted."
		return

	if(!src.client.holder)
		if(!dsay_allowed)
			src << "\red Deadchat is globally muted"
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
		log_emote("Ghost/[src.key] : [message]")

		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue

			if(M.client && M.client.holder && (M.client.holder.rights & R_ADMIN|R_MOD) && (M.client.prefs.toggles_chat & CHAT_DEAD)) // Show the emote to admins/mods
				M << message

			else if(M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				M.show_message(message, 2)

/mob/living/carbon/verb/show_emotes()
	set name = "Emotes"
	set desc = "Displays a list of usable emotes."
	set category = "IC"

	usr.say("*help")
