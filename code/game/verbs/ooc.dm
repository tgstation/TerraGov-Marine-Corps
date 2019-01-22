
var/global/normal_ooc_colour = "#002eb8"

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "<span class='warning'>Speech is currently admin-disabled.</span>")
		return

	if(!mob)
		return
	if(IsGuestKey(key))
		to_chat(src, "Guests may not use OOC.")
		return

	msg = trim(copytext(sanitize(msg), 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	if(!(prefs.toggles_chat & CHAT_OOC))
		to_chat(src, "<span class='warning'>You have OOC muted.</span>")
		return

	if(!holder)
		if(!ooc_allowed)
			to_chat(src, "<span class='warning'>OOC is globally muted</span>")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "<span class='warning'>OOC for dead mobs has been turned off.</span>")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "<span class='warning'>You cannot use OOC (muted).</span>")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	mob.log_talk(msg, LOG_OOC)

	var/display_colour = normal_ooc_colour
	if(holder && !holder.fakekey)
		switch(holder.rank)
			if("Host")
				display_colour = "#000000"	//black
			if("Manager")
				display_colour = "#800080"	//dark purple
			if("Headcoder")
				display_colour = "#800080"	//dark blue
			if("Headmin")
				display_colour = "#640000"	//dark red
			if("Headmentor")
				display_colour = "#004100"	//dark green
			if("Admin")
				display_colour = "#b4001e"	//red
			if("TrialAdmin")
				display_colour = "#f03200"	//darker orange
			if("AdminCandidate")
				display_colour = "#ff5a1e"	//lighter orange
			if("RetiredAdmin")
				display_colour = "#aa5050"	//light red
			if("Mentor")
				display_colour = "#008000"	//green
			if("Maintainer")
				display_colour = "#0064ff"	//different light blue
			if("Contributor")
				display_colour = "#1e4cd6"	//VERY slightly different light blue
			else
				display_colour = "#643200"	//brown, mostly /tg/ folks

		if(holder.rights & R_COLOR)
			if(CONFIG_GET(flag/allow_admin_ooccolor))
				display_colour = src.prefs.ooccolor

	for(var/client/C in clients)
		if(C.prefs.toggles_chat & CHAT_OOC)
			var/display_name = key
			if(holder?.fakekey)
				if(C.holder)
					display_name = "[holder.fakekey]/([src.key])"
				else
					display_name = holder.fakekey
			to_chat(C, "<font color='[display_colour]'><span class='ooc'>[src.donator ? "\[D\] " : ""]<span class='prefix'>OOC:</span> <EM>[display_name]:</EM> <span class='message'>[msg]</span></span></font>")
			/*
			if(holder)
				if(!holder.fakekey || C.holder)
					if(holder.rights & R_ADMIN)
						to_chat(C, "<font color=[config.allow_admin_ooccolor ? src.prefs.ooccolor :"#b82e00" ]><b><span class='prefix'>OOC:</span> <EM>[key][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>")
					else if(holder.rights & R_MOD)
						to_chat(C, "<font color=#184880><b><span class='prefix'>OOC:</span> <EM>[src.key][holder.fakekey ? "/([holder.fakekey])" : ""]:</EM> <span class='message'>[msg]</span></b></font>")
					else
						to_chat(C, "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[src.key]:</EM> <span class='message'>[msg]</span></span></font>")

				else
					to_chat(C, "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[holder.fakekey ? holder.fakekey : src.key]:</EM> <span class='message'>[msg]</span></span></font>")
			else
				to_chat(C, "<font color='[normal_ooc_colour]'><span class='ooc'><span class='prefix'>OOC:</span> <EM>[src.key]:</EM> <span class='message'>[msg]</span></span></font>")
			*/

/client/proc/set_ooc_color_global(newColor as color)
	set name = "OOC Text Color - Global"
	set desc = "Set to yellow for eye burning goodness."
	set category = "OOC"
	normal_ooc_colour = newColor

/client/verb/round_info()
	set name = "round_info"
	set desc = "Information about the current round"
	set category = "OOC"
	to_chat(usr, "The current map is [map_tag]")

/client/verb/setup_character()
	set name = "Game Preferences"
	set category = "OOC"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.ShowChoices(usr)

/client/verb/motd()
	set name = "MOTD"
	set category = "OOC"
	set desc ="Check the Message of the Day"
	var/join_motd = file2text("config/motd.txt")
	if( join_motd )
		to_chat(src, "<span class='motd'>[join_motd]</span>")
	else
		to_chat(src, "<span class='warning'>The motd is not set in the server configuration.</span>")
	return

/client/verb/stop_sounds()
	set name = "Stop Sounds"
	set category = "OOC"
	set desc = "Stop Current Sounds"
	src << sound(null)