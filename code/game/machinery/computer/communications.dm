
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

#define COOLDOWN_COMM_MESSAGE 600
#define COOLDOWN_COMM_REQUEST 3000
#define COOLDOWN_COMM_CENTRAL 300

//Note: Commented out procs are things I left alone and did not revise. Usually AI-related interactions.

// The communications computer
/obj/machinery/computer/communications
	name = "communications console"
	desc = "This can be used for various important functions."
	icon_state = "comm"
	req_access = list(ACCESS_MARINE_BRIDGE)
	circuit = "/obj/item/circuitboard/computer/communications"
	var/prints_intercept = 1
	var/authenticated = 0
	var/list/messagetitle = list()
	var/list/messagetext = list()
	var/currmsg = 0
	var/aicurrmsg = 0
	var/state = STATE_DEFAULT
	var/aistate = STATE_DEFAULT
	var/cooldown_message = 0 //Based on world.time.
	var/cooldown_request = 0
	var/cooldown_central = 0
	var/tmp_alertlevel = 0

	var/status_display_freq = "1435"
	var/stat_msg1
	var/stat_msg2

	var/datum/announcement/priority/command/crew_announcement = new

/obj/machinery/computer/communications/New()
	..()
	crew_announcement.newscast = 1
	start_processing()

/obj/machinery/computer/communications/process()
	if(..())
		if(state != STATE_STATUSDISPLAY)
			updateDialog()

/obj/machinery/computer/communications/Topic(href, href_list)
	if(..()) r_FAL

	usr.set_interaction(src)

	switch(href_list["operation"])
		if("main") state = STATE_DEFAULT

		if("login")
			var/mob/living/carbon/human/C = usr
			var/obj/item/card/id/I = C.get_active_hand()
			if(istype(I))
				if(check_access(I)) authenticated = 1
				if(ACCESS_MARINE_COMMANDER in I.access)
					authenticated = 2
					crew_announcement.announcer = GetNameAndAssignmentFromId(I)
			else
				I = C.wear_id
				if(istype(I))
					if(check_access(I)) authenticated = 1
					if(ACCESS_MARINE_COMMANDER in I.access)
						authenticated = 2
						crew_announcement.announcer = GetNameAndAssignmentFromId(I)
		if("logout")
			authenticated = 0
			crew_announcement.announcer = ""

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_active_hand()
			if(istype(I))
				if(ACCESS_MARINE_COMMANDER in I.access || ACCESS_MARINE_BRIDGE in I.access) //Let heads change the alert level.
					switch(tmp_alertlevel)
						if(-INFINITY to SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN //Cannot go below green.
						if(SEC_LEVEL_BLUE to INFINITY) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot go above blue.

					var/old_level = security_level
					set_security_level(tmp_alertlevel)
					if(security_level != old_level)
						//Only notify the admins if an actual change happened
						log_game("[key_name(usr)] has changed the security level to [get_security_level()].")
						message_admins("[key_name_admin(usr)] has changed the security level to [get_security_level()].")
						switch(security_level)
							if(SEC_LEVEL_GREEN) feedback_inc("alert_comms_green",1)
							if(SEC_LEVEL_BLUE) feedback_inc("alert_comms_blue",1)
				else
					usr << "<span class='warning'>You are not authorized to do this.</span>"
				tmp_alertlevel = SEC_LEVEL_GREEN //Reset to green.
				state = STATE_DEFAULT
			else
				usr << "<span class='warning'>You need to swipe your ID.</span>"

		if("announce")
			if(authenticated == 2)
				if(world.time < cooldown_message + COOLDOWN_COMM_MESSAGE)
					usr << "<span class='warning'>Please allow at least [COOLDOWN_COMM_MESSAGE*0.1] second\s to pass between announcements.</span>"
					r_FAL
				var/input = input(usr, "Please write a message to announce to the station crew.", "Priority Announcement", "") as message|null
				if(!input || !(usr in view(1,src)) || authenticated != 2 || world.time < cooldown_message + COOLDOWN_COMM_MESSAGE) r_FAL

				crew_announcement.Announce(input, to_xenos = 0)
				cooldown_message = world.time

		if("award")
			if(!usr.mind || usr.mind.assigned_role != "Commander")
				usr << "<span class='warning'>Only the Commander can award medals.</span>"
				return
			if(give_medal_award(loc))
				visible_message("<span class='notice'>[src] prints a medal.</span>")

		if("evacuation_start")
			if(state == STATE_EVACUATION)

				if(world.time < EVACUATION_TIME_LOCK) //Cannot call it early in the round.
					usr << "<span class='warning'>USCM protocol does not allow immediate evacuation. Please wait another [round((EVACUATION_TIME_LOCK-world.time)/600)] minutes before trying again.</span>"
					r_FAL

				if(!ticker || !ticker.mode || !ticker.mode.has_called_emergency)
					usr << "<span class='warning'>The [MAIN_SHIP_NAME]'s distress beacon must be activated prior to evacuation taking place.</span>"
					r_FAL

				if(security_level < SEC_LEVEL_RED)
					usr << "<span class='warning'>The ship must be under red alert in order to enact evacuation procedures.</span>"
					r_FAL

				if(EvacuationAuthority.flags_scuttle & FLAGS_EVACUATION_DENY)
					usr << "<span class='warning'>The USCM has placed a lock on deploying the evacuation pods.</span>"
					r_FAL

				if(!EvacuationAuthority.initiate_evacuation())
					usr << "<span class='warning'>You are unable to initiate an evacuation procedure right now!</span>"
					r_FAL

				EvacuationAuthority.enable_self_destruct()

				log_game("[key_name(usr)] has called for an emergency evacuation.")
				message_admins("[key_name_admin(usr)] has called for an emergency evacuation.", 1)
				post_status("shuttle")
				r_TRU

			state = STATE_EVACUATION

		if("evacuation_cancel")
			if(state == STATE_EVACUATION_CANCEL)
				if(!EvacuationAuthority.cancel_evacuation())
					usr << "<span class='warning'>You are unable to cancel the evacuation right now!</span>"
					r_FAL

				spawn(35)//some time between AI announcements for evac cancel and SD cancel.
					if(EvacuationAuthority.evac_status == EVACUATION_STATUS_STANDING_BY)//nothing changed during the wait
						 //if the self_destruct is active we try to cancel it (which includes lowering alert level to red)
						if(!EvacuationAuthority.cancel_self_destruct(1))
							//if SD wasn't active (likely canceled manually in the SD room), then we lower the alert level manually.
							set_security_level(SEC_LEVEL_RED, TRUE) //both SD and evac are inactive, lowering the security level.

				log_game("[key_name(usr)] has canceled the emergency evacuation.")
				message_admins("[key_name_admin(usr)] has canceled the emergency evacuation.", 1)
				r_TRU

			state = STATE_EVACUATION_CANCEL

		if("distress")
			if(state == STATE_DISTRESS)

				//Comment to test
				if(world.time < DISTRESS_TIME_LOCK)
					usr << "<span class='warning'>The distress beacon cannot be launched this early in the operation. Please wait another [round((DISTRESS_TIME_LOCK-world.time)/600)] minutes before trying again.</span>"
					r_FAL

				if(!ticker || !ticker.mode) r_FAL //Not a game mode?

				if(ticker.mode.has_called_emergency)
					usr << "<span class='warning'>The [MAIN_SHIP_NAME]'s distress beacon is already broadcasting.</span>"
					r_FAL

				if(ticker.mode.distress_cooldown)
					usr << "<span class='warning'>The distress beacon is currently recalibrating.</span>"
					r_FAL

				 //Comment block to test
				if(world.time < cooldown_request + COOLDOWN_COMM_REQUEST)
					usr << "<span class='warning'>The distress beacon has recently broadcast a message. Please wait.</span>"
					r_FAL

				//Currently only counts aliens, but this will likely need to change with human opponents.
				//I think this should instead count human losses, so that a distress beacon is available when a certain number of dead pile up.
				//Comment block to test
				var/L[] = ticker.mode.count_humans_and_xenos(list(MAIN_SHIP_Z_LEVEL))

				if(L[2] < round(L[1] * 0.5))
					log_game("[key_name(usr)] has attemped to call a distress beacon, but it was denied due to lack of threat on the ship.")
					message_admins("[key_name(usr)] has attemped to call a distress beacon, but it was denied due to lack of threat on the ship.", 1)
					usr << "<span class='warning'>The sensors aren't picking up enough of a threat on the ship to warrant a distress beacon.</span>"
					r_FAL

				for(var/client/C in admins)
					if((R_ADMIN|R_MOD) & C.holder.rights)
						C << 'sound/effects/sos-morse-code.ogg'
				message_mods("[key_name(usr)] has requested a Distress Beacon! (<A HREF='?_src_=holder;ccmark=\ref[usr]'>Mark</A>) (<A HREF='?_src_=holder;distress=\ref[usr]'>SEND</A>) (<A HREF='?_src_=holder;ccdeny=\ref[usr]'>DENY</A>) (<A HREF='?_src_=holder;adminplayerobservejump=\ref[usr]'>JMP</A>) (<A HREF='?_src_=holder;CentcommReply=\ref[usr]'>RPLY</A>)")
				usr << "<span class='notice'>A distress beacon request has been sent to USCM Central Command.</span>"
						//unanswered_distress += usr

				//spawn(600) //1 minute in deciseconds
					//if(usr in unanswered_distress)
						//unanswered_distress -= usr
						//ticker.mode.activate_distress()
						//log_game("A distress beacon requested by [key_name_admin(usr)] was automatically sent due to not receiving an answer within a minute.")
						//message_admins("A distress beacon requested by [key_name_admin(usr)] was automatically sent due to not receiving an answer within a minute.", 1)

				cooldown_request = world.time
				r_TRU

			state = STATE_DISTRESS

		if("messagelist")
			currmsg = 0
			state = STATE_MESSAGELIST

		if("viewmessage")
			state = STATE_VIEWMESSAGE
			if (!currmsg)
				if(href_list["message-num"]) 	currmsg = text2num(href_list["message-num"])
				else 							state = STATE_MESSAGELIST

		if("delmessage")
			state = (currmsg) ? STATE_DELMESSAGE : STATE_MESSAGELIST

		if("delmessage2")
			if(authenticated)
				if(currmsg)
					var/title = messagetitle[currmsg]
					var/text  = messagetext[currmsg]
					messagetitle.Remove(title)
					messagetext.Remove(text)
					if(currmsg == aicurrmsg) aicurrmsg = 0
					currmsg = 0
				state = STATE_MESSAGELIST
			else state = STATE_VIEWMESSAGE


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

		if("messageUSCM")
			if(authenticated == 2)
				if(world.time < cooldown_central + COOLDOWN_COMM_CENTRAL)
					usr << "<span class='warning'>Arrays recycling.  Please stand by.</span>"
					r_FAL
				var/input = stripped_input(usr, "Please choose a message to transmit to USCM.  Please be aware that this process is very expensive, and abuse will lead to termination.  Transmission does not guarantee a response. There is a small delay before you may send another message. Be clear and concise.", "To abort, send an empty message.", "")
				if(!input || !(usr in view(1,src)) || authenticated != 2 || world.time < cooldown_central + COOLDOWN_COMM_CENTRAL) r_FAL

				Centcomm_announce(input, usr)
				usr << "<span class='notice'>Message transmitted.</span>"
				log_say("[key_name(usr)] has made an USCM announcement: [input]")
				cooldown_central = world.time

		if("securitylevel")
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel) tmp_alertlevel = 0
			state = STATE_CONFIRM_LEVEL

		if("changeseclevel")
			state = STATE_ALERT_LEVEL

		else r_FAL

	updateUsrDialog()

/obj/machinery/computer/communications/attack_ai(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/communications/attack_paw(var/mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/communications/attack_hand(var/mob/user as mob)
	if(..()) r_FAL

	//Should be refactored later, if there's another ship that can appear during a mode with a comm console.
	if(!istype(loc.loc, /area/almayer/command/cic)) //Has to be in the CIC. Can also be a generic CIC area to communicate, if wanted.
		usr << "<span class='warning'>Unable to establish a connection.</span>"
		r_FAL

	user.set_interaction(src)
	var/dat = "<head><title>Communications Console</title></head><body>"
	if(EvacuationAuthority.evac_status == EVACUATION_STATUS_INITIATING)
		dat += "<B>Evacuation in Progress</B>\n<BR>\nETA: [EvacuationAuthority.get_status_panel_eta()]<BR>"

/*
	if(istype(user, /mob/living/silicon))
		var/dat2 = interact_ai(user) // give the AI a different interact proc to limit its access
		if(dat2)
			dat +=  dat2
			user << browse(dat, "window=communications;size=400x500")
			onclose(user, "communications")
		r_FAL
*/
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
					dat += admins.len > 0 ? "<BR>\[ <A HREF='?src=\ref[src];operation=messageUSCM'>Send a message to USCM</A> \]" : "<BR>\[ USCM communication offline \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=award'>Award a medal</A> \]"
					dat += "<BR>\[ <A HREF='?src=\ref[src];operation=distress'>Send Distress Beacon</A> \]"
					switch(EvacuationAuthority.evac_status)
						if(EVACUATION_STATUS_STANDING_BY) dat += "<BR>\[ <A HREF='?src=\ref[src];operation=evacuation_start'>Initiate emergency evacuation</A> \]"
						if(EVACUATION_STATUS_INITIATING) dat += "<BR>\[ <A HREF='?src=\ref[src];operation=evacuation_cancel'>Cancel emergency evacuation</A> \]"

			else
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=login'>LOG IN</A> \]"

		if(STATE_EVACUATION)
			dat += "Are you sure you want to evacuate the [MAIN_SHIP_NAME]? \[ <A HREF='?src=\ref[src];operation=evacuation_start'>Confirm</A>\]"

		if(STATE_EVACUATION_CANCEL)
			dat += "Are you sure you want to cancel the evacuation of the [MAIN_SHIP_NAME]? \[ <A HREF='?src=\ref[src];operation=evacuation_cancel'>Confirm</A>\]"

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
				r_FAL

		if(STATE_DELMESSAGE)
			if (currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=delmessage2'>OK</A>|<A HREF='?src=\ref[src];operation=viewmessage'>Cancel</A> \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				r_FAL

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
				if(EvacuationAuthority.dest_status >= NUKE_EXPLOSION_ACTIVE)
					dat += "<font color='red'><b>The self-destruct mechanism is active. [EvacuationAuthority.evac_status != EVACUATION_STATUS_INITIATING ? "You have to manually deactivate the self-destruct mechanism." : ""]</b></font><BR>"
				switch(EvacuationAuthority.evac_status)
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
	user << browse(dat, "window=communications;size=400x500")
	onclose(user, "communications")

/*
/obj/machinery/computer/communications/proc/interact_ai(var/mob/living/silicon/ai/user as mob)
	var/dat = ""
	switch(aistate)
		if(STATE_DEFAULT)
			if(emergency_shuttle.location() && !emergency_shuttle.online())
				dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-callshuttle'>Call Emergency Shuttle</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-messagelist'>Message List</A> \]"
			dat += "<BR>\[ <A HREF='?src=\ref[src];operation=ai-status'>Set Status Display</A> \]"
		if(STATE_CALLSHUTTLE)
			dat += "Are you sure you want to call the shuttle? \[ <A HREF='?src=\ref[src];operation=ai-callshuttle2'>OK</A>|<A HREF='?src=\ref[src];operation=ai-main'>Cancel</A> \]"
		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; i<=messagetitle.len; i++)
				dat += "<BR><A HREF='?src=\ref[src];operation=ai-viewmessage;message-num=[i]'>[messagetitle[i]]</A>"
		if(STATE_VIEWMESSAGE)
			if (aicurrmsg)
				dat += "<B>[messagetitle[aicurrmsg]]</B><BR><BR>[messagetext[aicurrmsg]]"
				dat += "<BR><BR>\[ <A HREF='?src=\ref[src];operation=ai-delmessage'>Delete</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				r_FAL
		if(STATE_DELMESSAGE)
			if(aicurrmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=\ref[src];operation=ai-delmessage2'>OK</A>|<A HREF='?src=\ref[src];operation=ai-viewmessage'>Cancel</A> \]"
			else
				aistate = STATE_MESSAGELIST
				attack_hand(user)
				r_FAL

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

	dat += "<BR>\[ [(aistate != STATE_DEFAULT) ? "<A HREF='?src=\ref[src];operation=ai-main'>Main Menu</A>|" : ""]<A HREF='?src=\ref[user];mach_close=communications'>Close</A> \]"
	return dat
*/

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)

	/*var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency) r_FAL

	var/datum/signal/status_signal = new
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			log_admin("STATUS: [fingerprintslast] set status screen message with [src]: [data1] [data2]")
			//message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)*/

#undef STATE_DEFAULT
#undef STATE_MESSAGELIST
#undef STATE_VIEWMESSAGE
#undef STATE_DELMESSAGE
#undef STATE_STATUSDISPLAY
#undef STATE_ALERT_LEVEL
#undef STATE_CONFIRM_LEVEL
#undef COOLDOWN_COMM_MESSAGE
#undef COOLDOWN_COMM_REQUEST
#undef COOLDOWN_COMM_CENTRAL
