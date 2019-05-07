
#define STATE_DEFAULT 1
#define STATE_EVACUATION 2
#define STATE_EVACUATION_CANCEL	3
#define STATE_DISTRESS 4
#define STATE_MESSAGELIST 5
#define STATE_VIEWMESSAGE 6
#define STATE_DELMESSAGE 7
#define STATE_STATUSDISPLAY 8
#define STATE_ALERT_LEVEL 9
#define STATE_CONFIRM_LEVEL 10

//Note: Commented out procs are things I left alone and did not revise. Usually AI-related interactions.

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This can be used for various important functions."
	icon_state = "comm"
	req_access = list(ACCESS_MARINE_BRIDGE)
	circuit = "/obj/item/circuitboard/computer/communications"
	var/prints_intercept = TRUE
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/cooldown_message = FALSE //Based on world.time.
	var/cooldown_request = FALSE
	var/cooldown_central = FALSE
	var/just_called = FALSE
	var/tmp_alertlevel = SEC_LEVEL_GREEN

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2

	var/datum/announcement/priority/command/crew_announcement = new

/obj/machinery/computer/communications/New()
	. = ..()
	crew_announcement.newscast = TRUE
	start_processing()

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY)
			updateDialog()

/obj/machinery/computer/communications/Topic(href, href_list)
	. = ..()
	if(.)
		return FALSE

	usr.set_interaction(src)

	switch(href_list["operation"])
		if("main")
			state = STATE_DEFAULT

		if("login")
			var/mob/living/carbon/human/C = usr
			var/obj/item/card/id/I = C.get_active_held_item()
			if(istype(I))
				if(check_access(I))
					authenticated = 1
				if(ACCESS_MARINE_BRIDGE in I.access)
					authenticated = 2
					crew_announcement.announcer = GetNameAndAssignmentFromId(I)
			else
				I = C.wear_id
				if(istype(I))
					if(check_access(I))
						authenticated = 1
					if(ACCESS_MARINE_BRIDGE in I.access)
						authenticated = 2
						crew_announcement.announcer = GetNameAndAssignmentFromId(I)
		if("logout")
			authenticated = 0
			crew_announcement.announcer = ""

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_active_held_item()
			if(istype(I))
				if(ACCESS_MARINE_CAPTAIN in I.access || ACCESS_MARINE_BRIDGE in I.access) //Let heads change the alert level.
					switch(tmp_alertlevel)
						if(-INFINITY to SEC_LEVEL_GREEN)
							tmp_alertlevel = SEC_LEVEL_GREEN //Cannot go below green.
						if(SEC_LEVEL_BLUE to INFINITY)
							tmp_alertlevel = SEC_LEVEL_BLUE //Cannot go above blue.

					var/old_level = security_level
					set_security_level(tmp_alertlevel)
					if(security_level != old_level)
						//Only notify the admins if an actual change happened
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[ADMIN_TPMONTY(usr)] has changed the security level to [get_security_level()].")
				else
					to_chat(usr, "<span class='warning'>You are not authorized to do this.</span>")
				tmp_alertlevel = SEC_LEVEL_GREEN //Reset to green.
				state = STATE_DEFAULT
			else
				to_chat(usr, "<span class='warning'>You need to swipe your ID.</span>")

		if("announce")
			if(authenticated == 2)
				if(world.time < cooldown_message + COOLDOWN_COMM_MESSAGE)
					to_chat(usr, "<span class='warning'>Please allow at least [COOLDOWN_COMM_MESSAGE*0.1] second\s to pass between announcements.</span>")
					return FALSE

				var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement", "") as message|null
				if(!input || !(usr in view(1,src)) || authenticated != 2 || world.time < cooldown_message + COOLDOWN_COMM_MESSAGE)
					return FALSE

				crew_announcement.Announce(input, to_xenos = 0)
				cooldown_message = world.time

		if("award")
			if(!usr.mind || usr.mind.assigned_role != "Captain")
				to_chat(usr, "<span class='warning'>Only the Captain can award medals.</span>")
				return

			if(give_medal_award(loc))
				visible_message("<span class='notice'>[src] prints a medal.</span>")

		if("evacuation_start")
			if(state == STATE_EVACUATION)
				if(world.time < EVACUATION_TIME_LOCK) //Cannot call it early in the round.
					to_chat(usr, "<span class='warning'>TGMC protocol does not allow immediate evacuation. Please wait another [round((EVACUATION_TIME_LOCK-world.time)/600)] minutes before trying again.</span>")
					return FALSE

				if(!SSticker?.mode)
					to_chat(usr, "<span class='warning'>The [CONFIG_GET(string/ship_name)]'s distress beacon must be activated prior to evacuation taking place.</span>")
					return FALSE

				if(security_level < SEC_LEVEL_RED)
					to_chat(usr, "<span class='warning'>The ship must be under red alert in order to enact evacuation procedures.</span>")
					return FALSE

				if(SSevacuation.flags_scuttle & FLAGS_SDEVAC_TIMELOCK)
					to_chat(usr, "<span class='warning'>The sensors do not detect a sufficient threat present.</span>")
					return FALSE

				if(SSevacuation.flags_scuttle & FLAGS_EVACUATION_DENY)
					to_chat(usr, "<span class='warning'>The TGMC has placed a lock on deploying the evacuation pods.</span>")
					return FALSE

				if(!SSevacuation.initiate_evacuation())
					to_chat(usr, "<span class='warning'>You are unable to initiate an evacuation procedure right now!</span>")
					return FALSE

				if(!SSevacuation.dest_master)
					SSevacuation.prepare()
				SSevacuation.enable_self_destruct()

				log_game("[key_name(usr)] has called for an emergency evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] has called for an emergency evacuation.")
				post_status("shuttle")
				return TRUE

			state = STATE_EVACUATION

		if("evacuation_cancel")
			if(state == STATE_EVACUATION_CANCEL)
				if(!SSevacuation.cancel_evacuation())
					to_chat(usr, "<span class='warning'>You are unable to cancel the evacuation right now!</span>")
					return FALSE

				spawn(35)//some time between AI announcements for evac cancel and SD cancel.
					if(SSevacuation.evac_status == EVACUATION_STATUS_STANDING_BY)//nothing changed during the wait
						 //if the self_destruct is active we try to cancel it (which includes lowering alert level to red)
						if(!SSevacuation.cancel_self_destruct(1))
							//if SD wasn't active (likely canceled manually in the SD room), then we lower the alert level manually.
							set_security_level(SEC_LEVEL_RED, TRUE) //both SD and evac are inactive, lowering the security level.

				log_game("[key_name(usr)] has canceled the emergency evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] has canceled the emergency evacuation.")
				return TRUE

			state = STATE_EVACUATION_CANCEL

		if("distress")
			if(state == STATE_DISTRESS)
				if(world.time < DISTRESS_TIME_LOCK)
					to_chat(usr, "<span class='warning'>The distress beacon cannot be launched this early in the operation. Please wait another [round((DISTRESS_TIME_LOCK-world.time)/600)] minutes before trying again.</span>")
					return FALSE

				if(!SSticker?.mode)
					return FALSE //Not a game mode?

				if(just_called || SSticker.mode.waiting_for_candidates)
					to_chat(usr, "<span class='warning'>The distress beacon has been just launched.</span>")
					return FALSE

				if(SSticker.mode.on_distress_cooldown)
					to_chat(usr, "<span class='warning'>The distress beacon is currently recalibrating.</span>")
					return FALSE

				var/Ship[] = SSticker.mode.count_humans_and_xenos()
				var/ShipMarines[] = Ship[1]
				var/ShipXenos[] = Ship[2]
				var/Planet[] = SSticker.mode.count_humans_and_xenos(SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP))
				var/PlanetMarines[] = Planet[1]
				var/PlanetXenos[] = Planet[2]
				if((PlanetXenos < round(PlanetMarines * 0.8)) && (ShipXenos < round(ShipMarines * 0.5))) //If there's less humans (weighted) than xenos, humans get home-turf advantage
					log_game("[key_name(usr)] has attemped to call a distress beacon, but it was denied due to lack of threat.")
					to_chat(usr, "<span class='warning'>The sensors aren't picking up enough of a threat to warrant a distress beacon.</span>")
					return FALSE

				for(var/client/C in GLOB.admins)
					if(check_other_rights(C, R_ADMIN, FALSE))
						C << 'sound/effects/sos-morse-code.ogg'
						to_chat(C, "<span class='notice'><b><font color='purple'>DISTRESS:</font> [ADMIN_TPMONTY(usr)] has called a Distress Beacon. It will be sent in 60 seconds unless denied or sent early. (<A HREF='?src=[REF(C.holder)];[HrefToken(TRUE)];distress=[REF(usr)]'>SEND</A>) (<A HREF='?src=[REF(C.holder)];[HrefToken(TRUE)];deny=[REF(usr)]'>DENY</A>) (<a href='?src=[REF(C.holder)];[HrefToken(TRUE)];reply=[REF(usr)]'>REPLY</a>).</b></span>")
				to_chat(usr, "<span class='boldnotice'>A distress beacon will launch in 60 seconds unless High Command responds otherwise.</span>")

				SSticker.mode.distress_cancelled = FALSE
				just_called = TRUE
				spawn(1 MINUTES)
					just_called = FALSE
					cooldown_request = world.time
					if(SSticker.mode.distress_cancelled || SSticker.mode.on_distress_cooldown || SSticker.mode.waiting_for_candidates)
						return FALSE
					else
						SSticker.mode.activate_distress()
						log_game("A distress beacon requested by [key_name_admin(usr)] was automatically sent due to not receiving an answer within 60 seconds.")
						message_admins("A distress beacon requested by [ADMIN_TPMONTY(usr)] was automatically sent due to not receiving an answer within 60 seconds.")
						return TRUE
			else
				state = STATE_DISTRESS

		if("messagelist")
			currmsg = 0
			state = STATE_MESSAGELIST

		if("viewmessage")
			state = STATE_VIEWMESSAGE
			if(!currmsg)
				if(href_list["message-num"])
					currmsg = text2num(href_list["message-num"])
				else
					state = STATE_MESSAGELIST

		if("delmessage")
			state = (currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST

		if("delmessage2")
			if(authenticated)
				if(currmsg)
					var/title = messagetitle[currmsg]
					var/text  = messagetext[currmsg]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == aicurrmsg)
						aicurrmsg = 0
					currmsg = 0
				state = STATE_MESSAGELIST
			else
				state = STATE_VIEWMESSAGE


		if("status")
			state = STATE_STATUSDISPLAY

		// Status display stuff
		if("setstat")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", stat_msg1, stat_msg2)
				if("alert")
					post_status("alert", href_list["alert"])
				else
					post_status(href_list["statdisp"])

		if("setmsg1")
			stat_msg1 = reject_bad_text(trim(copytext(sanitize(input("Line 1", "Enter Message Text", stat_msg1) as text|null), 1, 40)), 40)
			updateDialog()

		if("setmsg2")
			stat_msg2 = reject_bad_text(trim(copytext(sanitize(input("Line 2", "Enter Message Text", stat_msg2) as text|null), 1, 40)), 40)
			updateDialog()

		if("messageTGMC")
			if(authenticated == 2)
				if(world.time < cooldown_central + COOLDOWN_COMM_CENTRAL)
					to_chat(usr, "<span class='warning'>Arrays recycling.  Please stand by.</span>")
					return FALSE

				var/msg = input(usr, "Please choose a message to transmit to the TGMC High Command.  Please be aware that this process is very expensive, and abuse will lead to termination.  Transmission does not guarantee a response. There is a small delay before you may send another message. Be clear and concise.", "To abort, send an empty message.", "")
				if(!msg || !usr.Adjacent(src) || authenticated != 2 || world.time < cooldown_central + COOLDOWN_COMM_CENTRAL)
					return FALSE


				tgmc_message(msg, usr)
				to_chat(usr, "<span class='notice'>Message transmitted.</span>")
				usr.log_talk(msg, LOG_SAY, tag = "TGMC announcement")
				cooldown_central = world.time

		if("securitylevel")
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel)
				tmp_alertlevel = 0
			state = STATE_CONFIRM_LEVEL

		if("changeseclevel")
			state = STATE_ALERT_LEVEL

		else return FALSE

	updateUsrDialog()

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/communications/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..())
		return FALSE

	//Should be refactored later, if there's another ship that can appear during a mode with a comm console.
	if(!istype(loc.loc, /area/almayer/command/cic)) //Has to be in the CIC. Can also be a generic CIC area to communicate, if wanted.
		to_chat(usr, "<span class='warning'>Unable to establish a connection.</span>")
		return FALSE

	user.set_interaction(src)
	var/dat
	if(SSevacuation.evac_status == EVACUATION_STATUS_INITIATING)
		dat += "<B>Evacuation in Progress</B>\n<BR>\nETA: [SSevacuation.get_status_panel_eta()]<BR>"


	switch(state)
		if(STATE_DEFAULT)
			if(authenticated)
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=logout'>LOG OUT</A> \]"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=changeseclevel'>Change alert level</A> \]"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=status'>Set status display</A> \]"
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=messagelist'>Message list</A> \]"
				dat += "<BR><hr>"

				if(authenticated == 2)
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=announce'>Make an announcement</A> \]"
					dat += length(GLOB.admins) > 0 ? "<BR>\[ <A HREF='?src=\ref[src];operation=messageTGMC'>Send a message to TGMC</A> \]" : "<BR>\[ TGMC communication offline \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=award'>Award a medal</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=distress'>Send Distress Beacon</A> \]"
					switch(SSevacuation.evac_status)
						if(EVACUATION_STATUS_STANDING_BY) dat += "<BR>\[ <A HREF='?src=\ref[src];operation=evacuation_start'>Initiate emergency evacuation</A> \]"
						if(EVACUATION_STATUS_INITIATING) dat += "<BR>\[ <A HREF='?src=\ref[src];operation=evacuation_cancel'>Cancel emergency evacuation</A> \]"

			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>LOG IN</A> \]"

		if(STATE_EVACUATION)
			dat += "Are you sure you want to evacuate the [CONFIG_GET(string/ship_name)]? \[ <A HREF='?src=\ref[src];operation=evacuation_start'>Confirm</A>\]"

		if(STATE_EVACUATION_CANCEL)
			dat += "Are you sure you want to cancel the evacuation of the [CONFIG_GET(string/ship_name)]? \[ <A HREF='?src=\ref[src];operation=evacuation_cancel'>Confirm</A>\]"

		if(STATE_DISTRESS)
			dat += "Are you sure you want to trigger a distress signal? The signal can be picked up by anyone listening, friendly or not. \[ <A HREF='?src=\ref[src];operation=distress'>Confirm</A>\]"

		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=viewmessage;message-num=[i]'>[messagetitle[i]]</A>"

		if(STATE_VIEWMESSAGE)
			if (currmsg)
				dat += "<B>[messagetitle[currmsg]]</B><BR><BR>[messagetext[currmsg]]"
				if (authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=delmessage'>Delete \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return FALSE

		if(STATE_DELMESSAGE)
			if (currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A>|<A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return FALSE

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=time'>Station Time</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=\ref[src];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=\ref[src];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=\ref[src];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=\ref[src];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"

		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			if(security_level == SEC_LEVEL_DELTA)
				if(SSevacuation.dest_status >= NUKE_EXPLOSION_ACTIVE)
					dat += "<font color='red'><b>The self-destruct mechanism is active. [SSevacuation.evac_status != EVACUATION_STATUS_INITIATING ? "You have to manually deactivate the self-destruct mechanism." : ""]</b></font><BR>"
				switch(SSevacuation.evac_status)
					if(EVACUATION_STATUS_INITIATING)
						dat += "<font color='red'><b>Evacuation initiated. Evacuate or rescind evacuation orders.</b></font>"
					if(EVACUATION_STATUS_IN_PROGRESS)
						dat += "<font color='red'><b>Evacuation in progress.</b></font>"
					if(EVACUATION_STATUS_COMPLETE)
						dat += "<font color='red'><b>Evacuation complete.</b></font>"
			else
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=\ref[src];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [get_security_level()]<BR>"
			dat += "Confirm the change to: [num2seclevel(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=\ref[src];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"

	dat += "<BR>\[ [(state != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=main'>Main Menu</A>|" : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"

	var/datum/browser/popup = new(user, "communications", "<div align='center'>Communications Console</div>", 400, 500)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "communications")

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

#undef STATE_DEFAULT
#undef STATE_MESSAGELIST
#undef STATE_VIEWMESSAGE
#undef STATE_DELMESSAGE
#undef STATE_STATUSDISPLAY
#undef STATE_ALERT_LEVEL
#undef STATE_CONFIRM_LEVEL
