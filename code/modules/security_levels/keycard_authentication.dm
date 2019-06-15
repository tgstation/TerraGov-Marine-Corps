/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	var/active = 0 //This gets set to 1 on all devices except the one where the initial request was made.
	var/event = ""
	var/screen = 1
	var/confirmed = 0 //This variable is set by the device that confirms the request.
	var/confirm_delay = 20 //(2 seconds)
	var/busy = 0 //Busy when waiting for authentication or an event request has been sent from this device.
	var/obj/machinery/keycard_auth/event_source
	var/mob/event_triggered_by
	var/mob/event_confirmed_by
	//1 = select event
	//2 = authenticate
	anchored = TRUE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

/obj/machinery/keycard_auth/attack_ai(mob/user as mob)
	to_chat(user, "The station AI is not to interact with these devices.")
	return

/obj/machinery/keycard_auth/attack_paw(mob/user as mob)
	to_chat(user, "You are too primitive to use this device.")
	return

/obj/machinery/keycard_auth/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")

	else if(istype(I, /obj/item/card/id))
		var/obj/item/card/id/ID = I
		if(!(ACCESS_MARINE_BRIDGE in ID.access))
			return

		if(active && event_source)
			event_source.confirmed = TRUE
			event_source.event_confirmed_by = user
			
		else if(screen == 2)
			event_triggered_by = user
			broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices

/obj/machinery/keycard_auth/power_change()
	. = ..()
	if(machine_stat &NOPOWER)
		icon_state = "auth_off"

/obj/machinery/keycard_auth/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	if(user.stat || machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(busy)
		to_chat(user, "This device is busy.")
		return

	user.set_interaction(src)

	var/dat

	dat += "This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards."
	dat += "<br><hr><br>"

	if(screen == 1)
		dat += "Select an event to trigger:<ul>"
		dat += "<li><A href='?src=\ref[src];triggerevent=Red alert'>Red alert</A></li>"

		dat += "<li><A href='?src=\ref[src];triggerevent=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>"
		dat += "<li><A href='?src=\ref[src];triggerevent=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>"
		dat += "</ul>"

		var/datum/browser/popup = new(user, "keycard_auth", "<div align='center'>Keycard Authentication Device</div>", 500, 250)
		popup.set_content(dat)
		popup.open(FALSE)
	if(screen == 2)
		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		dat += "<p><A href='?src=\ref[src];reset=1'>Back</A>"

		var/datum/browser/popup = new(user, "keycard_auth", "<div align='center'>Keycard Authentication Device</div>", 500, 250)
		popup.set_content(dat)
		popup.open(FALSE)


/obj/machinery/keycard_auth/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(busy)
		to_chat(usr, "This device is busy.")
		return
	if(usr.stat || machine_stat & (BROKEN|NOPOWER))
		to_chat(usr, "This device is without power.")
		return
	if(href_list["triggerevent"])
		event = href_list["triggerevent"]
		screen = 2
	if(href_list["reset"])
		reset()

	updateUsrDialog()
	return

/obj/machinery/keycard_auth/proc/reset()
	active = 0
	event = ""
	screen = 1
	confirmed = 0
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in GLOB.machines)
		if(KA == src) continue
		KA.reset()
		spawn()
			KA.receive_request(src)

	sleep(confirm_delay)
	if(confirmed)
		confirmed = 0
		trigger_event(event)
		log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event].")
		message_admins("[ADMIN_TPMONTY(event_triggered_by)] triggered and [ADMIN_TPMONTY(event_confirmed_by)] confirmed event [event].")
	reset()

/obj/machinery/keycard_auth/proc/receive_request(var/obj/machinery/keycard_auth/source)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	event_source = source
	busy = 1
	active = 1
	icon_state = "auth_on"

	sleep(confirm_delay)

	event_source = null
	icon_state = "auth_off"
	active = 0
	busy = 0

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red alert")
			set_security_level(SEC_LEVEL_RED)
		if("Grant Emergency Maintenance Access")
			make_maint_all_access()
		if("Revoke Emergency Maintenance Access")
			revoke_maint_all_access()


var/global/maint_all_access = 0

/proc/make_maint_all_access()
	maint_all_access = 1
	priority_announce("The maintenance access requirement has been revoked on all airlocks.", "Attention!", sound = 'sound/misc/notice1.ogg')

/proc/revoke_maint_all_access()
	maint_all_access = 0
	priority_announce("The maintenance access requirement has been readded on all maintenance airlocks.", "Attention!", sound = 'sound/misc/notice2.ogg')

/obj/machinery/door/airlock/allowed(mob/M)
	if(maint_all_access && src.check_access_list(list(ACCESS_MARINE_ENGINEERING)))
		return 1
	return ..(M)
