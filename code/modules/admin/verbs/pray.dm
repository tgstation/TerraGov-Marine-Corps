/mob/verb/pray(msg as text)
	set category = "IC"
	set name = "Pray"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)

	if(!msg)
		return

	if(usr.client)
		if(usr.client.prefs.muted & MUTE_PRAY)
			to_chat(usr, "<span class='warning'>You cannot pray (muted).</span>")
			return
		if(client.handle_spam_prevention(msg, MUTE_PRAY))
			return

	var/mentor_msg = msg
	var/liaison = 0

	if(src.mind)
		if(src.mind.assigned_role == "Corporate Liaison")
			liaison = 1

	if(liaison)
		msg = "<b><font color=purple>LIAISON PRAY: </font><span class='notice'>[key_name(src, 1)] (<A HREF='?_src_=holder;mark=\ref[src]'>Mark</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[src]'>FLW</a>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"
		mentor_msg = "<b><font color=purple>LIAISON PRAY: </font><span class='notice'>[key_name(src, 1)] (<A HREF='?_src_=holder;mark=\ref[src]'>Mark</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[src]'>FLW</a>):</b> [mentor_msg]</span>"
	else
		msg = "<b><font color=purple>PRAY: </font><span class='notice'>[key_name(src, 1)] (<A HREF='?_src_=holder;mark=\ref[src]'>Mark</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[src]'>?</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[src]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[src]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[src]'>FLW</a>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;adminspawncookie=\ref[src]'>SC</a>):</b> [msg]</span>"
		mentor_msg = "<b><font color=purple>PRAY: </font><span class='notice'>[key_name(src, 1)] (<A HREF='?_src_=holder;mark=\ref[src]'>Mark</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[src]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[src]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[src]'>FLW</a>):</b> [mentor_msg]</span>"

	for(var/client/C in admins)
		if((C.prefs.toggles_chat & CHAT_PRAYER) && (C.holder.rights & (R_ADMIN|R_MOD)))
			to_chat(C, msg)
		else if((C.prefs.toggles_chat & CHAT_PRAYER) && (C.mob.stat == DEAD))
			to_chat(C, mentor_msg)

	if(liaison)
		to_chat(usr, "Your corporate overlords at Nanotrasen have received your message.")
	else
		to_chat(usr, "Your prayers have been received by the gods.")

	feedback_add_details("admin_verb","PR") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	//log_admin("HELP: [key_name(src)]: [msg]")

/proc/Centcomm_announce(var/text , var/mob/Sender , var/iamessage)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<span class='notice'> <b><font color=orange>TGMC[iamessage ? " IA" : ""]:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;ccmark=\ref[Sender]'>Mark</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[Sender]'>FLW</a>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[Sender]'>RPLY</A>):</b> [msg]</span>"
	for(var/client/C in admins)
		if((R_ADMIN|R_MOD) & C.holder.rights)
			to_chat(C, msg)
			C << 'sound/effects/sos-morse-code.ogg'

/proc/Syndicate_announce(var/text , var/mob/Sender)
	var/msg = copytext(sanitize(text), 1, MAX_MESSAGE_LEN)
	msg = "<b><font color=crimson>SYNDICATE:</font>[key_name(Sender, 1)] (<A HREF='?_src_=holder;mark=\ref[Sender]'>Mark</A>) (<A HREF='?_src_=holder;adminplayeropts=\ref[Sender]'>PP</A>) (<A HREF='?_src_=vars;Vars=\ref[Sender]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[Sender]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[Sender]'>JMP</A>) (<A HREF='?_src_=holder;adminplayerfollow=\ref[Sender]'>FLW</a>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>) (<A HREF='?_src_=holder;BlueSpaceArtillery=\ref[Sender]'>BSA</A>) (<A HREF='?_src_=holder;SyndicateReply=\ref[Sender]'>RPLY</A>):</b> [msg]"
	for(var/client/C in admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, msg)
