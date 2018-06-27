

//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as")

/client/verb/adminhelp()
	set category = "Admin"
	set name = "Adminhelp"

	if(say_disabled)	//This is here to try to identify lag problems
		usr << "\red Speech is currently admin-disabled."
		return

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		src << "<font color='red'>Error: Admin-PM: You cannot send adminhelps (Muted).</font>"
		return


	adminhelped = 1 //Determines if they get the message to reply by clicking the name.

	var/msg
	var/list/type = list ("Suggestion / Bug Report", "Gameplay / Roleplay Issue")
	var/selected_type = input("Pick a category.", "Admin Help", null, null) as null|anything in type
	if(selected_type == "Gameplay / Roleplay Issue")
		msg = input("Please enter your message:", "Admin Help", null, null) as message|null

	if(selected_type == "Suggestion / Bug Report")
		switch(alert("Adminhelps are not for suggestions or bug reports - they should be posted on our Gitlab.",,"Go to Gitlab","Cancel"))
			if("Go to Gitlab")
				src << link("https://gitlab.com/cmdevs/ColonialMarines/issues")
			else
				return

	var/selected_upper = uppertext(selected_type)

	if(src.handle_spam_prevention(msg,MUTE_ADMINHELP))
		return


	//clean the input msg
	if(!msg)	return
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg)	return
	var/original_msg = msg



	//explode the input msg into a list
	var/list/msglist = text2list(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	for(var/mob/M in mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)	indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = text2list(string, " ")
			var/surname_found = 0
			//surnames
			for(var/i=L.len, i>=1, i--)
				var/word = ckey(L[i])
				if(word)
					surnames[word] = M
					surname_found = i
					break
			//forenames
			for(var/i=1, i<surname_found, i++)
				var/word = ckey(L[i])
				if(word)
					forenames[word] = M
			//ckeys
			ckeys[M.ckey] = M

	var/ai_found = 0
	msg = ""
	var/list/mobs_found = list()
	for(var/original_word in msglist)
		var/word = ckey(original_word)
		if(word)
			if(!(word in adminhelp_ignored_words))
				if(word == "ai")
					ai_found = 1
				else
					var/mob/found = ckeys[word]
					if(!found)
						found = surnames[word]
						if(!found)
							found = forenames[word]
					if(found)
						if(!(found in mobs_found))
							mobs_found += found
							if(!ai_found && isAI(found))
								ai_found = 1
							msg += "<b><font color='black'>[original_word] (<A HREF='?_src_=holder;adminmoreinfo=\ref[found]'>?</A>)</font></b> "
							continue
			msg += "[original_word] "

	if(!mob)	return	//this doesn't happen

	var/mentor_msg = "<br><br><font color='#009900'><b>[selected_upper]: [get_options_bar(mob, 0, 0, 1, 0)]:</b></font> <br><font color='#DA6200'><b>[msg]</font></b><br>"
	msg = "<br><br><font color='#009900'><b>[selected_upper]: [get_options_bar(mob, 2, 1, 1)]:</b></font> <br><font color='#DA6200'><b>[msg]</font></b><br>"

	var/admin_number_afk = 0

	var/list/mentorholders = list()
	var/list/debugholders = list()
	var/list/adminholders = list()
	for(var/client/X in admins)
		if(R_MENTOR & X.holder.rights && !(R_ADMIN & X.holder.rights)) // we don't want to count admins twice. This list should be JUST mentors
			mentorholders += X
			if(X.is_afk())
				admin_number_afk++
		if(R_DEBUG & X.holder.rights) // Looking for anyone with +Debug which will be admins, developers, and developer mentors
			debugholders += X
			if(!(R_ADMIN & X.holder.rights))
				if(X.is_afk())
					admin_number_afk++
		if(R_ADMIN|R_MOD & X.holder.rights) // just admins here please
			adminholders += X
			if(X.is_afk())
				admin_number_afk++

	if("Gameplay/Roleplay Issue")
		if(mentorholders.len)
			for(var/client/X in mentorholders) // Mentors get a message without buttons and no character name
				if(X.prefs.toggles_sound & SOUND_ADMINHELP)
					X << 'sound/effects/adminhelp_new.ogg'
				X << mentor_msg
		if(adminholders.len)
			for(var/client/X in adminholders) // Admins get the full monty
				if(X.prefs.toggles_sound & SOUND_ADMINHELP)
					X << 'sound/effects/adminhelp_new.ogg'
				X << msg

	//show it to the person adminhelping too
	src << "<br><font color='#009900'><b>PM to Staff ([selected_type]): <font color='#DA6200'>[original_msg]</b></font><br>"

	// Adminhelp cooldown
	verbs -= /client/verb/adminhelp
	spawn(1200)
		verbs += /client/verb/adminhelp

	var/admin_number_present = admins.len - admin_number_afk
	log_admin("HELP: [key_name(src)]: [original_msg] - heard by [admin_number_present] non-AFK admins.")
//	if(admin_number_present <= 0)
//		if(!admin_number_afk)
//			send2adminirc("[selected_upper] from [key_name(src)]: [html_decode(original_msg)] - !!No admins online!!")
//		else
//			send2adminirc("[selected_upper] from [key_name(src)]: [html_decode(original_msg)] - !!All admins AFK ([admin_number_afk])!!")
//	else
//		send2adminirc("[selected_upper] from [key_name(src)]: [html_decode(original_msg)]")
	feedback_add_details("admin_verb","AH") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

	unansweredAhelps["[src.computer_id]"] = msg //We are gonna do it by CID, since any other way really gets fucked over by ghosting etc

	return

/proc/get_options_bar(whom, detail = 2, name = 0, link = 1, highlight_special = 1)
	if(!whom)
		return "<b>(*null*)</b>"
	var/mob/M
	var/client/C
	if(istype(whom, /client))
		C = whom
		M = C.mob
	else if(istype(whom, /mob))
		M = whom
		C = M.client
	else
		return "<b>(*not a mob*)</b>"

	var/ref_mob = "\ref[M]"
	switch(detail)
		if(0)
			return "<b>[key_name(C, link, name, highlight_special)]</b>"
		if(1)
			return "<b>[key_name(C, link, name, highlight_special)] \
			(<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>)</b>"
		if(2)
			return "<b>[key_name(C, link, name, highlight_special)] \
			(<A HREF='?_src_=holder;mark=[ref_mob]'>Mark</A>) \
			(<A HREF='?_src_=holder;noresponse=[ref_mob]'>NR</A>) \
			(<A HREF='?_src_=holder;warning=[ref_mob]'>Warn</A>) \
			(<A HREF='?_src_=holder;autoresponse=[ref_mob]'>AutoResponse...</A>) \
			(<A HREF='?_src_=holder;adminmoreinfo=[ref_mob]'>?</A>) \
			(<A HREF='?_src_=holder;adminplayeropts=[ref_mob]'>PP</A>) \
			(<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) \
			(<A HREF='?_src_=holder;subtlemessage=[ref_mob]'>SM</A>) \
			(<A HREF='?_src_=holder;adminplayerobservejump=[ref_mob]'>JMP</A>) \
			(<A HREF='?_src_=holder;check_antagonist=1'>CA</A>)</b>"
		if(3)
			return "<b>[key_name(C, link, name, highlight_special)] \
			(<A HREF='?_src_=vars;Vars=[ref_mob]'>VV</A>) \
			(<A HREF='?_src_=holder;adminplayerobservejump=[ref_mob]'>JMP</A>)</b>"
