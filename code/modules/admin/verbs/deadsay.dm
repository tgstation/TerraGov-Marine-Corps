/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite
	set hidden = 1

	if(!src.mob)
		return

	if(!(holder.rights & (R_ADMIN|R_MOD)) && mob.stat != DEAD)
		to_chat(src, "You must be an observer to use dsay.")
		return

	if(prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(prefs.toggles_chat & CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	var/stafftype = null

	stafftype = "[holder.rank]"

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	mob.log_talk(msg, LOG_DSAY)

	if(!msg)
		return

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>[stafftype]([src.holder.fakekey ? pick("BADMIN", "hornigranny", "TLF", "scaredforshadows", "KSI", "Silnazi", "HerpEs", "BJ69", "SpoofedEdd", "Uhangay", "Wario90900", "Regarity", "MissPhareon", "LastFish", "unMportant", "Deurpyn", "Fatbeaver") : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for(var/mob/M in player_list)
		if(istype(M, /mob/new_player))
			continue

		if(M.client?.holder && (M.client.holder.rights & (R_ADMIN|R_MOD)) && (M.client.prefs.toggles_chat & CHAT_DEAD)) // show the message to admins who have deadchat toggled on
			to_chat(M, rendered)

		else if(M.stat == DEAD && (M.client.prefs.toggles_chat & CHAT_DEAD)) // show the message to regular ghosts who have deadchat toggled on
			to_chat(M, rendered)

	feedback_add_details("admin_verb","D") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
