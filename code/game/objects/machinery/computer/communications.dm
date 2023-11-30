
#define STATE_DEFAULT 1
#define STATE_EVACUATION 2
#define STATE_EVACUATION_CANCEL 3
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
	icon_state = "computer_small"
	screen_overlay = "comm"
	req_access = list(ACCESS_MARINE_BRIDGE)
	circuit = /obj/item/circuitboard/computer/communications
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

/obj/machinery/computer/communications/bee
	machine_stat = BROKEN

/obj/machinery/computer/communications/bee/Initialize(mapload)
	. = ..()
	update_icon()


/obj/machinery/computer/communications/Topic(href, href_list)
	. = ..()
	if(.)
		return

	switch(href_list["operation"])
		if("main")
			state = STATE_DEFAULT

		if("login")
			if(isAI(usr))
				authenticated = 2
				updateUsrDialog()
				return
			var/mob/living/carbon/human/C = usr
			var/obj/item/card/id/I = C.get_active_held_item()
			if(istype(I))
				if(check_access(I))
					authenticated = 1
				if(ACCESS_MARINE_BRIDGE in I.access)
					authenticated = 2
			else
				I = C.wear_id
				if(istype(I))
					if(check_access(I))
						authenticated = 1
					if(ACCESS_MARINE_BRIDGE in I.access)
						authenticated = 2
		if("logout")
			authenticated = 0

		if("swipeidseclevel")
			var/mob/M = usr
			var/obj/item/card/id/I = M.get_active_held_item()
			if(istype(I))
				if((ACCESS_MARINE_CAPTAIN in I.access) || (ACCESS_MARINE_BRIDGE in I.access)) //Let heads change the alert level.
					switch(tmp_alertlevel)
						if(-INFINITY to SEC_LEVEL_GREEN)
							tmp_alertlevel = SEC_LEVEL_GREEN //Cannot go below green.
						if(SEC_LEVEL_BLUE to INFINITY)
							tmp_alertlevel = SEC_LEVEL_BLUE //Cannot go above blue.

					switch_alert_level(tmp_alertlevel)
				else
					to_chat(usr, span_warning("You are not authorized to do this."))
				tmp_alertlevel = SEC_LEVEL_GREEN //Reset to green.
				state = STATE_DEFAULT
			else
				to_chat(usr, span_warning("You need to swipe your ID."))

		if("announce")
			if(authenticated == 2)
				if(world.time < cooldown_message + COOLDOWN_COMM_MESSAGE)
					to_chat(usr, span_warning("Please allow at least [COOLDOWN_COMM_MESSAGE*0.1] second\s to pass between announcements."))
					return FALSE

				var/input = tgui_input_text(usr, "Please write a message to announce to the station crew.", "Priority Announcement", "",multiline = TRUE, encode = FALSE)
				if(!input || !(usr in view(1,src)) || authenticated != 2 || world.time < cooldown_message + COOLDOWN_COMM_MESSAGE)
					return FALSE

				var/filter_result = CAN_BYPASS_FILTER(usr) ? null : is_ic_filtered(input)
				if(filter_result)
					to_chat(usr, span_warning("That announcement contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[input]\"</span>"))
					SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
					REPORT_CHAT_FILTER_TO_USER(src, filter_result)
					log_filter("IC", input, filter_result)
					return FALSE

				if(NON_ASCII_CHECK(input))
					to_chat(usr, span_warning("That announcement contained charachters prohibited in IC chat! Consider reviewing the server rules."))
					return FALSE

				priority_announce(input, type = ANNOUNCEMENT_COMMAND)
				message_admins("[ADMIN_TPMONTY(usr)] has just sent a command announcement")
				log_game("[key_name(usr)] has just sent a command announcement.")
				cooldown_message = world.time

		if("award")
			if(!isliving(usr))
				to_chat(usr, span_warning("Only the Captain can award medals."))
				return
			var/mob/living/user = usr
			if(!ismarinecaptainjob(user.job))
				to_chat(usr, span_warning("Only the Captain can award medals."))
				return

			if(give_medal_award(loc))
				visible_message(span_notice("[src] prints a medal."))

		if("evacuation_start")
			if(state == STATE_EVACUATION)
				if(world.time < EVACUATION_TIME_LOCK) //Cannot call it early in the round.
					to_chat(usr, span_warning("TGMC protocol does not allow immediate evacuation. Please wait another [round((EVACUATION_TIME_LOCK-world.time)/600)] minutes before trying again."))
					return FALSE

				if(!SSticker?.mode)
					to_chat(usr, span_warning("The [SSmapping.configs[SHIP_MAP].map_name]'s distress beacon must be activated prior to evacuation taking place."))
					return FALSE

				if(GLOB.marine_main_ship.security_level < SEC_LEVEL_RED)
					to_chat(usr, span_warning("The ship must be under red alert in order to enact evacuation procedures."))
					return FALSE

				if(SSevacuation.flags_scuttle & FLAGS_SDEVAC_TIMELOCK)
					to_chat(usr, span_warning("The sensors do not detect a sufficient threat present."))
					return FALSE

				if(SSevacuation.flags_scuttle & FLAGS_EVACUATION_DENY)
					to_chat(usr, span_warning("The TGMC has placed a lock on deploying the evacuation pods."))
					return FALSE

				if(!SSevacuation.initiate_evacuation())
					to_chat(usr, span_warning("You are unable to initiate an evacuation procedure right now!"))
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
					to_chat(usr, span_warning("You are unable to cancel the evacuation right now!"))
					return FALSE

				spawn(35)//some time between AI announcements for evac cancel and SD cancel.
					if(SSevacuation.evac_status == EVACUATION_STATUS_STANDING_BY)//nothing changed during the wait
						//if the self_destruct is active we try to cancel it (which includes lowering alert level to red)
						if(!SSevacuation.cancel_self_destruct(1))
							//if SD wasn't active (likely canceled manually in the SD room), then we lower the alert level manually.
							GLOB.marine_main_ship.set_security_level(SEC_LEVEL_RED, TRUE) //both SD and evac are inactive, lowering the security level.

				log_game("[key_name(usr)] has canceled the emergency evacuation.")
				message_admins("[ADMIN_TPMONTY(usr)] has canceled the emergency evacuation.")
				return TRUE

			state = STATE_EVACUATION_CANCEL

		if("distress")
			if(state == STATE_DISTRESS)
				if(!CONFIG_GET(flag/infestation_ert_allowed))
					log_admin_private("[key_name(usr)] may have attempted a href exploit on a [src]. [AREACOORD(usr)].")
					message_admins("[ADMIN_TPMONTY(usr)] may be attempting a href exploit on a [src]. [ADMIN_VERBOSEJMP(usr)].")
					return FALSE

				if(!SSticker?.mode)
					return FALSE //Not a game mode?

				if(just_called || SSticker.mode.waiting_for_candidates)
					to_chat(usr, span_warning("The distress beacon has been just launched."))
					return FALSE

				if(SSticker.mode.on_distress_cooldown)
					to_chat(usr, span_warning("The distress beacon is currently recalibrating."))
					return FALSE

				var/Ship[] = SSticker.mode.count_humans_and_xenos(SSmapping.levels_by_trait(ZTRAIT_MARINE_MAIN_SHIP))
				var/ShipMarines[] = Ship[1]
				var/ShipXenos[] = Ship[2]
				var/All[] = SSticker.mode.count_humans_and_xenos()
				var/AllMarines[] = All[1]
				var/AllXenos[] = All[2]
				if((AllXenos < round(AllMarines * 0.8)) && (ShipXenos < round(ShipMarines * 0.5))) //If there's less humans (weighted) than xenos, humans get home-turf advantage
					to_chat(usr, span_warning("The sensors aren't picking up enough of a threat to warrant a distress beacon."))
					return FALSE

				SSticker.mode.distress_cancelled = FALSE
				just_called = TRUE

				var/datum/emergency_call/E = SSticker.mode.get_random_call()

				var/admin_response = admin_approval("<span color='prefix'>DISTRESS:</span> [ADMIN_TPMONTY(usr)] has called a Distress Beacon that was received by [E.name]. Humans: [AllMarines], Xenos: [AllXenos].",
					user_message = span_boldnotice("A distress beacon will launch in 60 seconds unless High Command responds otherwise."),
					options = list("approve" = "approve", "deny" = "deny", "deny without annoncing" = "deny without annoncing"),
					user = usr, admin_sound = sound('sound/effects/sos-morse-code.ogg', channel = CHANNEL_ADMIN))
				just_called = FALSE
				cooldown_request = world.time
				if(admin_response == "deny")
					SSticker.mode.distress_cancelled = TRUE
					priority_announce("The distress signal has been blocked, the launch tubes are now recalibrating.", "Distress Beacon")
					return FALSE
				if(admin_response =="deny without annoncing")
					SSticker.mode.distress_cancelled = TRUE
					return FALSE
				if(SSticker.mode.on_distress_cooldown || SSticker.mode.waiting_for_candidates)
					return FALSE
				SSticker.mode.activate_distress(E)
				E.base_probability = 0
				return TRUE
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
					var/text = messagetext[currmsg]
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
			stat_msg1 = reject_bad_text(tgui_input_text(usr, "Line 1", "Enter Message Text", stat_msg1, 40, encode = FALSE))

		if("setmsg2")
			stat_msg2 = reject_bad_text(tgui_input_text(usr, "Line 2", "Enter Message Text", stat_msg2, 40, encode = FALSE))

		if("messageTGMC")
			if(authenticated == 2)
				if(world.time < cooldown_central + COOLDOWN_COMM_CENTRAL)
					to_chat(usr, span_warning("Arrays recycling.  Please stand by."))
					return FALSE

				var/msg = tgui_input_text(usr, "Please choose a message to transmit to the TGMC High Command.  Please be aware that this process is very expensive, and abuse will lead to termination.  Transmission does not guarantee a response. There is a small delay before you may send another message. Be clear and concise.", "To abort, send an empty message.", "", encode = FALSE)
				if(!msg || !usr.Adjacent(src) || authenticated != 2 || world.time < cooldown_central + COOLDOWN_COMM_CENTRAL)
					return FALSE


				tgmc_message(msg, usr)
				to_chat(usr, span_notice("Message transmitted."))
				usr.log_talk(msg, LOG_SAY, tag = "TGMC announcement")
				cooldown_central = world.time

		if("securitylevel")
			tmp_alertlevel = text2num( href_list["newalertlevel"] )
			if(!tmp_alertlevel)
				tmp_alertlevel = SEC_LEVEL_GREEN
			if(isAI(usr))
				switch_alert_level(tmp_alertlevel)
				tmp_alertlevel = SEC_LEVEL_GREEN
				state = STATE_DEFAULT
			else
				state = STATE_CONFIRM_LEVEL

		if("changeseclevel")
			state = STATE_ALERT_LEVEL

		else
			return FALSE

	updateUsrDialog()


/obj/machinery/computer/communications/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	if(SSevacuation.evac_status == EVACUATION_STATUS_INITIATING)
		dat += "<B>Evacuation in Progress</B>\n<BR>\nETA: [SSevacuation.get_status_panel_eta()]<BR>"


	switch(state)
		if(STATE_DEFAULT)
			if(authenticated)
				dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=logout'>LOG OUT</A> \]"
				dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=changeseclevel'>Change alert level</A> \]"
				dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=status'>Set status display</A> \]"
				dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=messagelist'>Message list</A> \]"
				dat += "<BR><hr>"

				if(authenticated == 2)
					dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=announce'>Make an announcement</A> \]"
					dat += length(GLOB.admins) > 0 ? "<BR>\[ <A HREF='?src=[text_ref(src)];operation=messageTGMC'>Send a message to TGMC</A> \]" : "<BR>\[ TGMC communication offline \]"
					dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=award'>Award a medal</A> \]"
					if(CONFIG_GET(flag/infestation_ert_allowed)) // We only add the UI if the flag is allowed
						dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=distress'>Send Distress Beacon</A> \]"
					switch(SSevacuation.evac_status)
						if(EVACUATION_STATUS_STANDING_BY) dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=evacuation_start'>Initiate emergency evacuation</A> \]"
						if(EVACUATION_STATUS_INITIATING) dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=evacuation_cancel'>Cancel emergency evacuation</A> \]"

			else
				dat += "<BR>\[ <A HREF='?src=[text_ref(src)];operation=login'>LOG IN</A> \]"

		if(STATE_EVACUATION)
			dat += "Are you sure you want to evacuate the [SSmapping.configs[SHIP_MAP].map_name]? \[ <A HREF='?src=[text_ref(src)];operation=evacuation_start'>Confirm</A>\]"

		if(STATE_EVACUATION_CANCEL)
			dat += "Are you sure you want to cancel the evacuation of the [SSmapping.configs[SHIP_MAP].map_name]? \[ <A HREF='?src=[text_ref(src)];operation=evacuation_cancel'>Confirm</A>\]"

		if(STATE_DISTRESS)
			if(CONFIG_GET(flag/infestation_ert_allowed))
				dat += "Are you sure you want to trigger a distress signal? The signal can be picked up by anyone listening, friendly or not. \[ <A HREF='?src=[text_ref(src)];operation=distress'>Confirm</A>\]"

		if(STATE_MESSAGELIST)
			dat += "Messages:"
			for(var/i = 1; length(i<=messagetitle); i++)
				dat += "<BR><A HREF='?src=[text_ref(src)];operation=viewmessage;message-num=[i]'>[messagetitle[i]]</A>"

		if(STATE_VIEWMESSAGE)
			if (currmsg)
				dat += "<B>[messagetitle[currmsg]]</B><BR><BR>[messagetext[currmsg]]"
				if (authenticated)
					dat += "<BR><BR>\[ <A HREF='?src=[text_ref(src)];operation=delmessage'>Delete \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return FALSE

		if(STATE_DELMESSAGE)
			if (currmsg)
				dat += "Are you sure you want to delete this message? \[ <A HREF='?src=[text_ref(src)];operation=delmessage2'>OK</A>|<A HREF='?src=[text_ref(src)];operation=viewmessage'>Cancel</A> \]"
			else
				state = STATE_MESSAGELIST
				attack_hand(user)
				return FALSE

		if(STATE_STATUSDISPLAY)
			dat += "Set Status Displays<BR>"
			dat += "\[ <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=blank'>Clear</A> \]<BR>"
			dat += "\[ <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=time'>Station Time</A> \]<BR>"
			dat += "\[ <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=shuttle'>Shuttle ETA</A> \]<BR>"
			dat += "\[ <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=message'>Message</A> \]"
			dat += "<ul><li> Line 1: <A HREF='?src=[text_ref(src)];operation=setmsg1'>[ stat_msg1 ? stat_msg1 : "(none)"]</A>"
			dat += "<li> Line 2: <A HREF='?src=[text_ref(src)];operation=setmsg2'>[ stat_msg2 ? stat_msg2 : "(none)"]</A></ul><br>"
			dat += "\[ Alert: <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=alert;alert=default'>None</A> |"
			dat += " <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=alert;alert=redalert'>Red Alert</A> |"
			dat += " <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=alert;alert=lockdown'>Lockdown</A> |"
			dat += " <A HREF='?src=[text_ref(src)];operation=setstat;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR><HR>"

		if(STATE_ALERT_LEVEL)
			dat += "Current alert level: [GLOB.marine_main_ship.get_security_level()]<BR>"
			if(GLOB.marine_main_ship.security_level == SEC_LEVEL_DELTA)
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
				dat += "<A HREF='?src=[text_ref(src)];operation=securitylevel;newalertlevel=[SEC_LEVEL_BLUE]'>Blue</A><BR>"
				dat += "<A HREF='?src=[text_ref(src)];operation=securitylevel;newalertlevel=[SEC_LEVEL_GREEN]'>Green</A>"

		if(STATE_CONFIRM_LEVEL)
			dat += "Current alert level: [GLOB.marine_main_ship.get_security_level()]<BR>"
			dat += "Confirm the change to: [GLOB.marine_main_ship.get_security_level(tmp_alertlevel)]<BR>"
			dat += "<A HREF='?src=[text_ref(src)];operation=swipeidseclevel'>Swipe ID</A> to confirm change.<BR>"

	dat += "<BR>\[ [(state != STATE_DEFAULT) ? "<A HREF='?src=[text_ref(src)];operation=main'>Main Menu</A>|" : ""]\]"

	var/datum/browser/popup = new(user, "communications", "<div align='center'>Communications Console</div>", 400, 500)
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "communications")

/obj/machinery/computer/communications/proc/post_status(command, data1, data2)


/obj/machinery/computer/communications/proc/switch_alert_level(new_level)
	var/old_level = GLOB.marine_main_ship.security_level
	GLOB.marine_main_ship.set_security_level(new_level)
	if(GLOB.marine_main_ship.security_level == old_level)
		return //Only notify the admins if an actual change happened
	log_game("[key_name(usr)] has changed the security level from [GLOB.marine_main_ship.get_security_level(old_level)] to [GLOB.marine_main_ship.get_security_level()].")
	message_admins("[ADMIN_TPMONTY(usr)] has changed the security level from [GLOB.marine_main_ship.get_security_level(old_level)] to [GLOB.marine_main_ship.get_security_level()].")


#undef STATE_DEFAULT
#undef STATE_MESSAGELIST
#undef STATE_VIEWMESSAGE
#undef STATE_DELMESSAGE
#undef STATE_STATUSDISPLAY
#undef STATE_ALERT_LEVEL
#undef STATE_CONFIRM_LEVEL
