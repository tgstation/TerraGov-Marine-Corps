
var/global/normal_ooc_colour = "#002eb8"

/client/verb/ooc(msg as text)
	set name = "OOC" //Gave this shit a shorter name so you only have to time out "ooc" rather than "ooc message" to use it --NeoFite
	set category = "OOC"

	if(say_disabled)	//This is here to try to identify lag problems
		to_chat(usr, "\red Speech is currently admin-disabled.")
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
		to_chat(src, "\red You have OOC muted.")
		return

	if(!holder)
		if(!ooc_allowed)
			to_chat(src, "\red OOC is globally muted")
			return
		if(!dooc_allowed && (mob.stat == DEAD))
			to_chat(usr, "\red OOC for dead mobs has been turned off.")
			return
		if(prefs.muted & MUTE_OOC)
			to_chat(src, "\red You cannot use OOC (muted).")
			return
		if(handle_spam_prevention(msg,MUTE_OOC))
			return
		if(findtext(msg, "byond://"))
			to_chat(src, "<B>Advertising other servers is not allowed.</B>")
			log_admin("[key_name(src)] has attempted to advertise in OOC: [msg]")
			message_admins("[key_name_admin(src)] has attempted to advertise in OOC: [msg]")
			return

	log_ooc("[mob.name]/[key] : [msg]")

	var/display_colour = normal_ooc_colour
	if(holder && !holder.fakekey)
		display_colour = "#2e78d9"	//light blue
		if(holder.rights & R_MOD && !(holder.rights & R_ADMIN))
			display_colour = "#184880"	//dark blue
		if(holder.rights & R_DEBUG && !(holder.rights & R_ADMIN))
			display_colour = "#1b521f"	//dark green
		else if(holder.rights & R_COLOR)
			if(config.allow_admin_ooccolor)
				display_colour = src.prefs.ooccolor
			else
				display_colour = "#b82e00"	//orange
	if(donator)
		display_colour = src.prefs.ooccolor

	for(var/client/C in clients)
		if(C.prefs.toggles_chat & CHAT_OOC)
			var/display_name = src.key
			if(holder)
				if(holder.fakekey)
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
		to_chat(src, "\red The motd is not set in the server configuration.")
	return

/client/verb/stop_sounds()
	set name = "Stop Sounds"
	set category = "OOC"
	set desc = "Stop Current Sounds"
	src << sound(null)