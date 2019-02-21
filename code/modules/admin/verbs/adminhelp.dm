/client/var/adminhelptimerid = 0	//a timer id for returning the ahelp verb
/client/var/datum/admin_help/current_ticket	//the current ticket the (usually) not-admin client is dealing with

//
//TICKET MANAGER
//


GLOBAL_DATUM_INIT(ahelp_tickets, /datum/admin_help_tickets, new)


/datum/admin_help_tickets
	var/list/active_tickets = list()
	var/list/closed_tickets = list()
	var/list/resolved_tickets = list()

	var/obj/effect/statclick/ticket_list/astatclick = new(null, null, AHELP_ACTIVE)
	var/obj/effect/statclick/ticket_list/cstatclick = new(null, null, AHELP_CLOSED)
	var/obj/effect/statclick/ticket_list/rstatclick = new(null, null, AHELP_RESOLVED)


/datum/admin_help_tickets/Destroy()
	QDEL_LIST(active_tickets)
	QDEL_LIST(closed_tickets)
	QDEL_LIST(resolved_tickets)
	QDEL_NULL(astatclick)
	QDEL_NULL(cstatclick)
	QDEL_NULL(rstatclick)
	return ..()


/datum/admin_help_tickets/proc/TicketByID(id)
	var/list/lists = list(active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.id == id)
				return J


/datum/admin_help_tickets/proc/TicketsByCKey(ckey)
	. = list()
	var/list/lists = list(active_tickets, closed_tickets, resolved_tickets)
	for(var/I in lists)
		for(var/J in I)
			var/datum/admin_help/AH = J
			if(AH.initiator_ckey == ckey)
				. += AH


//private
/datum/admin_help_tickets/proc/ListInsert(datum/admin_help/new_ticket)
	var/list/ticket_list
	switch(new_ticket.state)
		if(AHELP_ACTIVE)
			ticket_list = active_tickets
		if(AHELP_CLOSED)
			ticket_list = closed_tickets
		if(AHELP_RESOLVED)
			ticket_list = resolved_tickets
		else
			CRASH("Invalid ticket state: [new_ticket.state]")
	var/num_closed = ticket_list.len
	if(num_closed)
		for(var/I in 1 to num_closed)
			var/datum/admin_help/AH = ticket_list[I]
			if(AH.id > new_ticket.id)
				ticket_list.Insert(I, new_ticket)
				return
	ticket_list += new_ticket


//opens the ticket listings for one of the 3 states
/datum/admin_help_tickets/proc/BrowseTickets(state)
	var/list/l2b
	var/title
	switch(state)
		if(AHELP_ACTIVE)
			l2b = active_tickets
			title = "Active Tickets"
		if(AHELP_CLOSED)
			l2b = closed_tickets
			title = "Closed Tickets"
		if(AHELP_RESOLVED)
			l2b = resolved_tickets
			title = "Resolved Tickets"
	if(!l2b)
		return
	var/list/dat = list("<html><head><title>[title]</title></head>")
	dat += "<A href='?_src_=holder;[HrefToken()];ahelp_tickets=[state]'>Refresh</A><br><br>"
	for(var/I in l2b)
		var/datum/admin_help/AH = I
		if(AH.tier == TICKET_MENTOR && check_rights(R_ADMIN|R_MENTOR, FALSE))
			dat += "<span class='adminnotice'><span class='adminhelp'>#[AH.id] Mentor Ticket</span>: <A href='?_src_=holder;[HrefToken()];ahelp=[REF(AH)];ahelp_action=ticket'>[AH.initiator_key_name]: [AH.name]</A></span><br>"
		else if(AH.tier == TICKET_ADMIN && check_rights(R_ADMIN, FALSE))
			dat += "<span class='adminnotice'><span class='adminhelp'>#[AH.id] Admin Ticket</span>: <A href='?_src_=holder;[HrefToken()];ahelp=[REF(AH)];ahelp_action=ticket'>[AH.initiator_key_name]: [AH.name]</A></span><br>"
	usr << browse(dat.Join(), "window=ahelp_list[state];size=600x480")


//Tickets statpanel
/datum/admin_help_tickets/proc/stat_entry()
	var/num_mentors_disconnected = 0
	var/num_admins_disconnected = 0
	var/num_mentors_active = 0
	var/num_admins_active = 0
	var/num_mentors_closed = 0
	var/num_admins_closed = 0
	var/num_mentors_resolved = 0
	var/num_admins_resolved = 0

	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.tier == TICKET_MENTOR)
			num_mentors_active++
		else if(AH.tier == TICKET_ADMIN)
			num_admins_active++

	for(var/I in closed_tickets)
		var/datum/admin_help/AH = I
		if(AH.tier == TICKET_MENTOR)
			num_mentors_closed++
		else if(AH.tier == TICKET_ADMIN)
			num_admins_closed++

	for(var/I in resolved_tickets)
		var/datum/admin_help/AH = I
		if(AH.tier == TICKET_MENTOR)
			num_mentors_resolved++
		else if(AH.tier == TICKET_ADMIN)
			num_admins_resolved++

	if(check_rights(R_ADMIN, FALSE))
		stat("Active Tickets:", astatclick.update("[num_mentors_active + num_admins_active]"))
	else if(check_rights(R_MENTOR, FALSE))
		stat("Active Tickets:", astatclick.update("[num_mentors_active]"))

	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.tier == TICKET_MENTOR && check_rights(R_ADMIN|R_MENTOR, FALSE))
			if(AH.initiator)
				stat("#[AH.id]. Mentor. [AH.initiator_key_name]:", AH.statclick.update())
			else
				++num_mentors_disconnected
		else if(AH.tier == TICKET_ADMIN && check_rights(R_ADMIN, FALSE))
			if(AH.initiator)
				stat("#[AH.id]. Admin. [AH.initiator_key_name]:", AH.statclick.update())
			else
				++num_admins_disconnected
	if(check_rights(R_ADMIN, FALSE) && (num_admins_disconnected || num_mentors_disconnected))
		stat("Disconnected:", astatclick.update("[num_mentors_disconnected + num_admins_disconnected]"))
	else if(check_rights(R_MENTOR, FALSE) && num_mentors_disconnected)
		stat("Disconnected:", astatclick.update("[num_mentors_disconnected]"))

	if(check_rights(R_ADMIN, FALSE))
		stat("Closed Tickets:", cstatclick.update("[num_mentors_closed + num_admins_closed]"))
	else if(check_rights(R_MENTOR, FALSE))
		stat("Closed Tickets:", cstatclick.update("[num_mentors_closed]"))

	if(check_rights(R_ADMIN, FALSE))
		stat("Resolved Tickets:", rstatclick.update("[num_mentors_resolved + num_admins_resolved]"))
	else if(check_rights(R_MENTOR, FALSE))
		stat("Resolved Tickets:", rstatclick.update("[num_mentors_resolved]"))


//Reassociate still open ticket if one exists
/datum/admin_help_tickets/proc/ClientLogin(client/C)
	C.current_ticket = CKey2ActiveTicket(C.ckey)
	if(C.current_ticket)
		C.current_ticket.initiator = C
		C.current_ticket.AddInteraction("Client reconnected.")


//Dissasociate ticket
/datum/admin_help_tickets/proc/ClientLogout(client/C)
	if(C.current_ticket)
		C.current_ticket.AddInteraction("Client disconnected.")
		C.current_ticket.initiator = null
		C.current_ticket = null


//Get a ticket given a ckey
/datum/admin_help_tickets/proc/CKey2ActiveTicket(ckey)
	for(var/I in active_tickets)
		var/datum/admin_help/AH = I
		if(AH.initiator_ckey == ckey)
			return AH


//
//TICKET LIST STATCLICK
//

/obj/effect/statclick/ticket_list
	var/current_state


/obj/effect/statclick/ticket_list/New(loc, name, state)
	current_state = state
	return ..()


/obj/effect/statclick/ticket_list/clicked()
	GLOB.ahelp_tickets.BrowseTickets(current_state)


//
//TICKET DATUM
//

/datum/admin_help
	var/id
	var/name
	var/state = AHELP_ACTIVE

	var/opened_at
	var/closed_at

	var/client/initiator	//the person who ahelped/was bwoinked
	var/initiator_ckey
	var/initiator_key_name
	var/heard_by_no_admins = FALSE

	var/marked = FALSE
	var/tier

	var/list/_interactions	//use AddInteraction() or, preferably, admin_ticket_log()

	var/obj/effect/statclick/ahelp/statclick

	var/static/ticket_counter = 0

//call this on its own to create a ticket, don't manually assign current_ticket
//msg is the title of the ticket: usually the ahelp text
//is_bwoink is TRUE if this ticket was started by an admin PM
/datum/admin_help/New(msg, client/C, is_bwoink, tickettier)
	//clean the input msg
	msg = sanitize(copytext(msg,1,MAX_MESSAGE_LEN))
	if(!msg || !C || !C.mob)
		qdel(src)
		return

	id = ++ticket_counter
	opened_at = world.time

	name = msg

	tier = tickettier

	initiator = C
	initiator_ckey = initiator.ckey
	initiator_key_name = key_name(initiator, FALSE, TRUE)
	if(initiator.current_ticket)	//This is a bug
		stack_trace("Multiple ahelp current_tickets.")
		initiator.current_ticket.AddInteraction("Ticket erroneously left open by code.")
		initiator.current_ticket.Close()
	initiator.current_ticket = src

	if(tier == TICKET_ADMIN)
		TimeoutVerb()

	statclick = new(null, src)
	_interactions = list()

	if(is_bwoink)
		AddInteraction("<font color='blue'>[key_name_admin(usr)] PM'd [LinkedReplyName()]</font>")
		if(tier == TICKET_MENTOR)
			message_staff("Ticket [TicketHref("#[id]")] created.")
		else if(tier == TICKET_ADMIN)
			message_admins("Ticket [TicketHref("#[id]")] created.")
		marked = usr.client
	else
		MessageNoRecipient(msg)

		//send it to irc if nobody is on and tell us how many were on
		var/admin_number_present = send2irc_adminless_only(initiator_ckey, "Ticket #[id]: [name]")
		log_admin_private("Ticket #[id]: [key_name(initiator)]: [name] - heard by [admin_number_present] non-AFK staff.")
		if(admin_number_present <= 0)
			to_chat(C, "<span class='notice'>No active admins are online.</span>")
			heard_by_no_admins = TRUE

	GLOB.ahelp_tickets.active_tickets += src


/datum/admin_help/Destroy()
	RemoveActive()
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	return ..()


/datum/admin_help/proc/AddInteraction(formatted_message)
	if(heard_by_no_admins && usr && usr.ckey != initiator_ckey)
		heard_by_no_admins = FALSE
		send2irc(initiator_ckey, "Ticket #[id]: Answered by [key_name(usr)]")
	_interactions += "[stationTimestamp()]: [formatted_message]"

//Removes the ahelp verb and returns it after 2 minutes
/datum/admin_help/proc/TimeoutVerb()
	initiator.verbs -= /client/verb/adminhelp
	initiator.adminhelptimerid = addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 1200, TIMER_STOPPABLE) //2 minute cooldown of admin helps


//private
/datum/admin_help/proc/FullMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = ADMIN_FULLMONTY_NONAME(initiator.mob)


//private
/datum/admin_help/proc/HalfMonty(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = "[ADMIN_JMP(initiator.mob)] [ADMIN_FLW(initiator.mob)] [ADMIN_SM(initiator.mob)]"


//private
/datum/admin_help/proc/ClosureLinks(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=mark'>MARK</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reject'>REJECT</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=icissue'>IC</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RESOLVE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=tier'>TIER</A>)"


//private
/datum/admin_help/proc/ClosureLinksMentor(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	. = " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=mark'>MARK</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=close'>CLOSE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=resolve'>RESOLVE</A>)"
	. += " (<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=tier'>TIER</A>)"


//private
/datum/admin_help/proc/LinkedReplyName(ref_src)
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=reply'>[initiator_key_name]</A>"


//private
/datum/admin_help/proc/TicketHref(msg, ref_src, action = "ticket")
	if(!ref_src)
		ref_src = "[REF(src)]"
	return "<A HREF='?_src_=holder;[HrefToken(TRUE)];ahelp=[ref_src];ahelp_action=[action]'>[msg]</A>"


//message from the initiator without a target, all admins will see this
//won't bug irc
/datum/admin_help/proc/MessageNoRecipient(msg)
	var/ref_src = "[REF(src)]"

	AddInteraction("<font color='red'>[LinkedReplyName(ref_src)]: [msg]</font>")

	//Send this to the relevant people
	for(var/client/X in GLOB.admins)
		if(tier == TICKET_MENTOR && check_other_rights(X, R_ADMIN|R_MENTOR, FALSE))
			if(X.prefs.toggles_sound & SOUND_ADMINHELP)
				SEND_SOUND(X, sound('sound/effects/adminhelp.ogg'))
			to_chat(X, "<span class='adminnotice'><span class='adminhelp'>Mentor Ticket [TicketHref("#[id]", ref_src)]</span><b>: [LinkedReplyName(ref_src)] [check_other_rights(X, R_ADMIN, FALSE) ? FullMonty(ref_src) : HalfMonty(ref_src)] [check_other_rights(X, R_ADMIN, FALSE) ? ClosureLinks(ref_src) : ClosureLinksMentor(ref_src)]:</b> <span class='linkify'>[keywords_lookup(msg)]</span></span>")
		if(tier == TICKET_ADMIN && check_other_rights(X, R_ADMIN, FALSE))
			if(X.prefs.toggles_sound & SOUND_ADMINHELP)
				SEND_SOUND(X, sound('sound/effects/adminhelp.ogg'))
			to_chat(X, "<span class='adminnotice'><span class='adminhelp'>Admin Ticket [TicketHref("#[id]", ref_src)]</span><b>: [LinkedReplyName(ref_src)] [FullMonty(ref_src)] [ClosureLinks(ref_src)]:</b> <span class='linkify'>[keywords_lookup(msg)]</span></span>")

	//show it to the person adminhelping too
	to_chat(initiator, "<span class='adminnotice'>PM to-<b>[tier == TICKET_ADMIN ? "Admins" : "Mentors"]</b>: <span class='linkify'>[msg]</span></span>")


//Reopen a closed ticket
/datum/admin_help/proc/Reopen()
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	if(state == AHELP_ACTIVE)
		to_chat(usr, "<span class='warning'>This ticket is already open.</span>")
		return

	if(GLOB.ahelp_tickets.CKey2ActiveTicket(initiator_ckey))
		to_chat(usr, "<span class='warning'>This user already has an active ticket, cannot reopen this one.</span>")
		return

	statclick = new(null, src)
	GLOB.ahelp_tickets.active_tickets += src
	GLOB.ahelp_tickets.closed_tickets -= src
	GLOB.ahelp_tickets.resolved_tickets -= src
	state = AHELP_ACTIVE
	closed_at = null
	if(initiator)
		initiator.current_ticket = src

	AddInteraction("<font color='purple'>Reopened by [key_name_admin(usr)]</font>")
	message_admins("Ticket [TicketHref("#[id]")] reopened by [ADMIN_TPMONTY(usr)].")
	log_admin_private("Ticket (#[id]) reopened by [key_name(usr)].")
	TicketPanel()	//can only be done from here, so refresh it


//Change the tier
/datum/admin_help/proc/Tier()
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	var/msg
	if(tier == TICKET_MENTOR)
		tier = TICKET_ADMIN
		msg = "an admin ticket"
		AddInteraction("<font color='red'>Made admin ticket by: [key_name_admin(usr)].</font>")
		message_admins("Ticket [TicketHref("#[id]")] has been made [msg] by [ADMIN_TPMONTY(usr)].")
	else if(tier == TICKET_ADMIN)
		tier = TICKET_MENTOR
		msg = "a mentor ticket"
		AddInteraction("<font color='red'>Made mentor ticket by: [key_name_admin(usr)].</font>")
		message_staff("Ticket [TicketHref("#[id]")] has been made [msg] by [ADMIN_TPMONTY(usr)].")
		if(is_mentor(usr.client) && usr.client.prefs.toggles_sound & SOUND_ADMINHELP)
			SEND_SOUND(usr.client, sound('sound/effects/adminhelp.ogg'))
	log_admin_private("Ticket (#[id]) has been made [msg] by [key_name(usr)].")


//Mark it
/datum/admin_help/proc/Mark()
	if(state != AHELP_ACTIVE)
		return
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	if(marked)
		if(marked == usr.client)
			return
		if(alert("This ticket has already been marked by [marked], do you want to replace them?", "Confirmation", "Yes", "No") != "Yes")
			return
		if(tier == TICKET_MENTOR)
			message_staff("Ticket [TicketHref("#[id]")] has been re-marked by [ADMIN_TPMONTY(usr)].")
		else if(tier == TICKET_ADMIN)
			message_admins("Ticket [TicketHref("#[id]")] has been re-marked by [ADMIN_TPMONTY(usr)].")
		marked = usr.client
		return
	marked = usr.client
	if(tier == TICKET_MENTOR)
		message_staff("Ticket [TicketHref("#[id]")] has been marked by [ADMIN_TPMONTY(usr)].")
	else if(tier == TICKET_ADMIN)
		message_admins("Ticket [TicketHref("#[id]")] has been marked by [ADMIN_TPMONTY(usr)].")
	log_admin_private("Ticket (#[id]) has been made marked by [key_name(usr)].")


//private
/datum/admin_help/proc/RemoveActive()
	if(state != AHELP_ACTIVE)
		return
	closed_at = world.time
	QDEL_NULL(statclick)
	GLOB.ahelp_tickets.active_tickets -= src
	if(initiator && initiator.current_ticket == src)
		initiator.current_ticket = null


//Mark open ticket as closed/meme
/datum/admin_help/proc/Close(key_name = key_name_admin(usr), silent = FALSE, force = FALSE)
	if(!force && tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	if(state != AHELP_ACTIVE)
		return
	RemoveActive()
	state = AHELP_CLOSED
	GLOB.ahelp_tickets.ListInsert(src)
	AddInteraction("<font color='red'>Closed by [key_name].</font>")
	if(!silent)
		log_admin_private("Ticket (#[id]) closed by [key_name(usr)].")
		if(tier == TICKET_MENTOR)
			message_staff("Ticket [TicketHref("#[id]")] closed by [ADMIN_TPMONTY(usr)].")
		else if(tier == TICKET_ADMIN)
			message_admins("Ticket [TicketHref("#[id]")] closed by [ADMIN_TPMONTY(usr)].")


//Mark open ticket as resolved/legitimate, returns ahelp verb
/datum/admin_help/proc/Resolve(key_name = key_name_admin(usr), silent = FALSE)
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	if(state != AHELP_ACTIVE)
		return
	RemoveActive()
	state = AHELP_RESOLVED
	GLOB.ahelp_tickets.ListInsert(src)

	addtimer(CALLBACK(initiator, /client/proc/giveadminhelpverb), 50)

	AddInteraction("<font color='green'>Resolved by [key_name].</font>")
	if(tier == TICKET_MENTOR)
		to_chat(initiator, "<span class='adminhelp'>Your mentor ticket has been resolved, if you need to ask something again, feel free to send another one.</span>")
	if(tier == TICKET_ADMIN)
		to_chat(initiator, "<span class='adminhelp'>Your ticket has been resolved by an admin. The Adminhelp verb will be returned to you shortly.</span>")
	if(!silent)
		log_admin_private("Ticket (#[id]) resolved by [key_name(usr)].")
		if(tier == TICKET_MENTOR)
			message_staff("Ticket [TicketHref("#[id]")] resolved by [ADMIN_TPMONTY(usr)].")
		else if(tier == TICKET_ADMIN)
			message_admins("Ticket [TicketHref("#[id]")] resolved by [ADMIN_TPMONTY(usr)].")


//Close and return ahelp verb, use if ticket is incoherent
/datum/admin_help/proc/Reject(key_name = key_name_admin(usr))
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	if(state != AHELP_ACTIVE)
		return
	if(initiator)
		initiator.giveadminhelpverb()

		SEND_SOUND(initiator, sound('sound/effects/adminhelp.ogg'))
		if(tier == TICKET_MENTOR)
			to_chat(initiator, "<font color='red' size='2'><b>- Mentorhelp Rejected! -</b></font>")
			to_chat(initiator, "Your issue may have been non-sensical. Please try describing it more in detail.")
		else if(tier == TICKET_ADMIN)
			to_chat(initiator, "<font color='red' size='4'><b>- Adminhelp Rejected! -</b></font>")
			to_chat(initiator, "<font color='red'><b>Your admin help was rejected.</b> The adminhelp verb has been returned to you so that you may try again.</font>")
			to_chat(initiator, "Please try to be calm, clear, and descriptive in admin helps, do not assume the admin has seen any related events, and clearly state the names of anybody you are reporting.")
	message_admins("Ticket [TicketHref("#[id]")] rejected by [ADMIN_TPMONTY(usr)].")
	log_admin_private("Ticket (#[id]) rejected by [key_name(usr)].")
	AddInteraction("Rejected by [key_name].")
	Close(silent = TRUE)


//Resolve ticket with IC Issue message
/datum/admin_help/proc/ICIssue(key_name = key_name_admin(usr))
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	if(state != AHELP_ACTIVE)
		return

	var/msg = "<font color='red' size='4'><b>- Adminhelp marked as IC! -</b></font><br>"
	msg += "<font color='red'>Whatever your query was, you will have to find out using IC mean, the staff won't reveal anything relevant.</font>"
	msg += "<font color='red'>Your character will frequently die, sometimes without even a possibility of avoiding it. Events will often be out of your control. No matter how good or prepared you are, sometimes you just lose.</font>"

	if(initiator)
		to_chat(initiator, msg)

	message_admins("Ticket [TicketHref("#[id]")] marked as IC by [ADMIN_TPMONTY(usr)].")
	log_admin_private("Ticket (#[id]) marked as IC by [key_name(usr)].")
	AddInteraction("Marked as IC issue by [key_name]")
	Resolve(silent = TRUE)


//Show the ticket panel
/datum/admin_help/proc/TicketPanel()
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		var/data = "<html><head><title>Access Denied</title></head><body>Access Denied</body></html>"
		usr << browse(data, "window=ahelp[id];size=620x480")
	var/list/dat = list("<html><head><title>Ticket #[id]</title></head>")
	var/ref_src = "[REF(src)]"
	dat += "<h4>[tier == TICKET_MENTOR ? "Mentor" : "Admin"] Ticket #[id]: [LinkedReplyName(ref_src)]</h4>"
	dat += "<b>State: "
	switch(state)
		if(AHELP_ACTIVE)
			dat += "<font color='red'>OPEN</font>"
		if(AHELP_RESOLVED)
			dat += "<font color='green'>RESOLVED</font>"
		if(AHELP_CLOSED)
			dat += "CLOSED"
		else
			dat += "UNKNOWN"
	if(marked)
		dat += " <font color='red'>MARKED BY [marked]</font> "
	else
		dat += " UNMARKED "
	dat += "</b>\t[TicketHref("Refresh", ref_src)]\t[TicketHref("Re-Title", ref_src, "retitle")]"
	if(state != AHELP_ACTIVE)
		dat += "\t[TicketHref("Reopen", ref_src, "reopen")]"
	dat += "<br><br>Opened at: [stationTimestamp(wtime = opened_at)] (Approx [DisplayTimeText(world.time - opened_at)] ago)"
	if(closed_at)
		dat += "<br>Closed at: [stationTimestamp(wtime = closed_at)] (Approx [DisplayTimeText(world.time - closed_at)] ago)"
	dat += "<br>Current time: [stationTimestamp()]"
	dat += "<br><br>"
	if(initiator)
		if(check_rights(R_ADMIN, FALSE))
			dat += "<b>Actions:</b> [FullMonty(ref_src)] [ClosureLinks(ref_src)]<br>"
		else if(check_rights(R_MENTOR, FALSE))
			dat += "<b>Actions:</b> [HalfMonty(ref_src)] [ClosureLinksMentor(ref_src)]<br>"
	else
		if(check_rights(R_ADMIN, FALSE))
			dat += "<b>DISCONNECTED</b>\t[ClosureLinks(ref_src)]<br>"
		else if(check_rights(R_MENTOR, FALSE))
			dat += "<b>DISCONNECTED</b>\t[ClosureLinksMentor(ref_src)]<br>"
	dat += "<br><b>Log:</b><br><br>"
	for(var/I in _interactions)
		dat += "[I]<br>"

	usr << browse(dat.Join(), "window=ahelp[id];size=620x480")


/datum/admin_help/proc/Retitle()
	if(tier == TICKET_ADMIN && !check_rights(R_ADMIN, FALSE))
		return
	var/new_title = input(usr, "Enter a title for the ticket", "Rename Ticket", name) as text|null
	if(new_title)
		name = new_title
		if(tier == TICKET_MENTOR)
			message_staff("Ticket [TicketHref("#[id]")] titled [name] by [ADMIN_TPMONTY(usr)].")
		else if(tier == TICKET_ADMIN)
			message_admins("Ticket [TicketHref("#[id]")] titled [name] by [ADMIN_TPMONTY(usr)].")
		//not saying the original name cause it could be a long ass message
		log_admin_private("Ticket (#[id]) titled [name] by [key_name(usr)].")
	TicketPanel()	//we have to be here to do this


//Forwarded action from admin/Topic
/datum/admin_help/proc/Action(action)
	switch(action)
		if("ticket")
			TicketPanel()
		if("retitle")
			Retitle()
		if("reject")
			Reject()
		if("reply")
			usr.client.ticket_reply(initiator)
		if("icissue")
			ICIssue()
		if("close")
			Close()
		if("resolve")
			Resolve()
		if("reopen")
			Reopen()
		if("tier")
			Tier()
		if("mark")
			Mark()


//
// TICKET STATCLICK
//

/obj/effect/statclick/ahelp
	var/datum/admin_help/ahelp_datum


/obj/effect/statclick/ahelp/Initialize(mapload, datum/admin_help/AH)
	ahelp_datum = AH
	. = ..()


/obj/effect/statclick/ahelp/update()
	return ..(ahelp_datum.name)


/obj/effect/statclick/ahelp/clicked()
	ahelp_datum.TicketPanel()


/obj/effect/statclick/ahelp/Destroy()
	ahelp_datum = null
	return ..()


//
// CLIENT PROCS
//

/client/proc/giveadminhelpverb()
	src.verbs |= /client/verb/adminhelp
	deltimer(adminhelptimerid)
	adminhelptimerid = 0


// Used for methods where input via arg doesn't work
/client/proc/get_adminhelp()
	var/msg = input(src, "Please describe your problem concisely and an admin will help as soon as they're able.", "Adminhelp contents") as text
	adminhelp(msg)


/client/verb/adminhelp(msg as text)
	set category = "Admin"
	set name = "Adminhelp"

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='warning'>Error: You cannot send adminhelps (Muted).</span>")
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP))
		return

	msg = trim(msg)

	if(!msg)
		return

	if(current_ticket)
		if(alert(usr, "You already have a ticket open. Is this for the same issue?",,"Yes","No") != "No")
			if(current_ticket)
				current_ticket.MessageNoRecipient(msg)
				current_ticket.TimeoutVerb()
				return
			else
				to_chat(usr, "<span class='warning'>Ticket not found, creating new one...</span>")
		else
			current_ticket.AddInteraction("[key_name_admin(usr)] opened a new ticket.")
			current_ticket.Close(key_name_admin(usr), TRUE, TRUE)

	new /datum/admin_help(msg, src, FALSE, TICKET_ADMIN)


/client/verb/mentorhelp(msg as text)
	set category = "Admin"
	set name = "Mentorhelp"

	//handle muting and automuting
	if(prefs.muted & MUTE_ADMINHELP)
		to_chat(src, "<span class='warning'>Error: You cannot send mentorhelps (Muted).</span>")
		return

	if(handle_spam_prevention(msg, MUTE_ADMINHELP))
		return

	msg = trim(msg)

	if(!msg)
		return

	if(current_ticket)
		if(alert(usr, "You already have a ticket open. Is this for the same issue?",,"Yes","No") != "No")
			if(current_ticket)
				current_ticket.MessageNoRecipient(msg)
				return
			else
				to_chat(usr, "<span class='warning'>Ticket not found, creating new one...</span>")
		else
			current_ticket.AddInteraction("[key_name_admin(usr)] opened a new ticket.")
			current_ticket.Close(key_name_admin(usr), TRUE, TRUE)

	new /datum/admin_help(msg, src, FALSE, TICKET_MENTOR)


//
// LOGGING
//

//Use this proc when an admin takes action that may be related to an open ticket on what
//what can be a client, ckey, or mob
/proc/admin_ticket_log(what, message)
	var/client/C
	var/mob/Mob = what
	if(istype(Mob))
		C = Mob.client
	else
		C = what
	if(istype(C) && C.current_ticket)
		C.current_ticket.AddInteraction(message)
		return C.current_ticket
	if(istext(what))	//ckey
		var/datum/admin_help/AH = GLOB.ahelp_tickets.CKey2ActiveTicket(what)
		if(AH)
			AH.AddInteraction(message)
			return AH


//
// HELPER PROCS
//

/proc/get_admin_counts(requiredflags = R_BAN)
	. = list("total" = list(), "noflags" = list(), "afk" = list(), "stealth" = list(), "present" = list())
	for(var/client/X in GLOB.admins)
		.["total"] += X
		if(requiredflags != 0 && !check_other_rights(X, requiredflags, FALSE))
			.["noflags"] += X
		else if(X.is_afk())
			.["afk"] += X
		else if(X.holder.fakekey)
			.["stealth"] += X
		else
			.["present"] += X


/proc/send2irc_adminless_only(source, msg, requiredflags = R_BAN)
	var/list/adm = get_admin_counts(requiredflags)
	var/list/activemins = adm["present"]
	. = activemins.len
	if(. <= 0)
		var/final = ""
		var/list/afkmins = adm["afk"]
		var/list/stealthmins = adm["stealth"]
		var/list/powerlessmins = adm["noflags"]
		var/list/allmins = adm["total"]
		if(!afkmins.len && !stealthmins.len && !powerlessmins.len)
			final = "[msg] - No admins online"
		else
			final = "[msg] - All admins stealthed\[[english_list(stealthmins)]\], AFK\[[english_list(afkmins)]\], or lacks +BAN\[[english_list(powerlessmins)]\]! Total: [allmins.len] "
		send2irc(source,final)
		send2otherserver(source,final)


/proc/send2irc(msg,msg2)
	msg = replacetext(replacetext(msg, "\proper", ""), "\improper", "")
	msg2 = replacetext(replacetext(msg2, "\proper", ""), "\improper", "")
	world.TgsTargetedChatBroadcast("[msg] | [msg2]", TRUE)


/proc/send2otherserver(source,msg,type = "Ahelp")
	var/comms_key = CONFIG_GET(string/comms_key)
	if(!comms_key)
		return
	var/list/message = list()
	message["message_sender"] = source
	message["message"] = msg
	message["source"] = "([CONFIG_GET(string/cross_comms_name)])"
	message["key"] = comms_key
	message += type

	var/list/servers = CONFIG_GET(keyed_list/cross_server)
	for(var/I in servers)
		world.Export("[servers[I]]?[list2params(message)]")


/proc/ircadminwho()
	var/list/message = list("Admins: ")
	var/list/admin_keys = list()
	for(var/adm in GLOB.admins)
		var/client/C = adm
		admin_keys += "[C][C.holder.fakekey ? "(Stealth)" : ""][C.is_afk() ? "(AFK)" : ""]"

	for(var/admin in admin_keys)
		if(LAZYLEN(message) > 1)
			message += ", [admin]"
		else
			message += "[admin]"

	return jointext(message, "")


/proc/keywords_lookup(msg,irc)

	//This is a list of words which are ignored by the parser when comparing message contents for names. MUST BE IN LOWER CASE!
	var/list/adminhelp_ignored_words = list("unknown","the","a","an","of","monkey","alien","as", "i")

	//explode the input msg into a list
	var/list/msglist = splittext(msg, " ")

	//generate keywords lookup
	var/list/surnames = list()
	var/list/forenames = list()
	var/list/ckeys = list()
	var/founds = ""
	for(var/mob/M in GLOB.mob_list)
		var/list/indexing = list(M.real_name, M.name)
		if(M.mind)
			indexing += M.mind.name

		for(var/string in indexing)
			var/list/L = splittext(string, " ")
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
							founds += "Name: [found.name]([found.real_name]) Key: [found.key] Ckey: [found.ckey] "
							msg += "[original_word]<font size='1' color='black'>(<A HREF='?_src_=holder;[HrefToken(TRUE)];moreinfo=[REF(found)]'>?</A>|<A HREF='?_src_=holder;[HrefToken(TRUE)];observefollow=[REF(found)]'>FLW</A>)</font> "
							continue
		msg += "[original_word] "
	if(irc)
		if(founds == "")
			return "Search Failed"
		else
			return founds

	return msg