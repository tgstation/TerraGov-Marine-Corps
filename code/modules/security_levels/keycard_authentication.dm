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
	/// Has this event been authorized by a silicon. Most of the time, this means the AI.
	var/synth_activation = 0
	//1 = select event
	//2 = authenticate
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON


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

/obj/machinery/keycard_auth/update_icon()
	if(machine_stat &NOPOWER)
		icon_state = "auth_off"


/obj/machinery/keycard_auth/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	if(busy)
		return FALSE
	return TRUE


/obj/machinery/keycard_auth/interact(mob/user)
	. = ..()
	if(.)
		return

	if(issilicon(user))
		synth_activation = 1

	var/dat
	dat += "This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards."
	dat += "<br><hr><br>"

	if(screen == 1)
		dat += "Select an event to trigger:<ul>"
		dat += "<li><A href='?src=[text_ref(src)];trigger_event=Red alert'>Red alert</A></li>"

		dat += "<li><A href='?src=[text_ref(src)];trigger_event=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>"
		dat += "<li><A href='?src=[text_ref(src)];trigger_event=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>"
		dat += "</ul>"

	else if(screen == 2)
		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		dat += "<p><A href='?src=[text_ref(src)];reset=1'>Back</A>"

	else if(screen == 3)
		dat += "Do you want to trigger the following event using your Silicon Privileges: <b>[event]</b>"
		dat += "<p><A href='?src=[text_ref(src)];silicon_activate_event=1'>Activate</A>"
		dat += "<p><A href='?src=[text_ref(src)];reset=1'>Back</A>"

	var/datum/browser/popup = new(user, "keycard_auth", "<div align='center'>Keycard Authentication Device</div>", 500, 250)
	popup.set_content(dat)
	popup.open(FALSE)


/obj/machinery/keycard_auth/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["trigger_event"])
		event = href_list["trigger_event"]
		if(synth_activation)
			screen = 3
		else
			screen = 2

	if(href_list["silicon_activate_event"])
		trigger_event(event)
		log_game("[key_name(event_triggered_by)] triggered event [event].")
		message_admins("[ADMIN_TPMONTY(event_triggered_by)] triggered event [event].")
		reset()

	if(href_list["reset"])
		reset()

	updateUsrDialog()

/obj/machinery/keycard_auth/proc/reset()
	active = FALSE
	event = ""
	screen = 1
	confirmed = FALSE
	synth_activation = 0
	event_source = null
	icon_state = "auth_off"
	event_triggered_by = null
	event_confirmed_by = null

/obj/machinery/keycard_auth/proc/broadcast_request()
	icon_state = "auth_on"
	for(var/obj/machinery/keycard_auth/KA in GLOB.machines)
		if(KA == src)
			continue
		KA.reset()
		KA.receive_request(src)
	addtimer(CALLBACK(src, PROC_REF(finish_confirm)), confirm_delay)

/obj/machinery/keycard_auth/proc/finish_confirm()
	if(confirmed)
		confirmed = FALSE
		trigger_event(event)
		log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed event [event].")
		message_admins("[ADMIN_TPMONTY(event_triggered_by)] triggered and [ADMIN_TPMONTY(event_confirmed_by)] confirmed event [event].")
	reset()

/obj/machinery/keycard_auth/proc/receive_request(obj/machinery/keycard_auth/source)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	event_source = source
	busy = FALSE
	active = TRUE
	icon_state = "auth_on"
	addtimer(CALLBACK(src, PROC_REF(confirm)), confirm_delay)

/obj/machinery/keycard_auth/proc/confirm()
	event_source = null
	icon_state = "auth_off"
	active = FALSE
	busy = FALSE

/obj/machinery/keycard_auth/proc/trigger_event()
	switch(event)
		if("Red alert")
			GLOB.marine_main_ship.set_security_level(SEC_LEVEL_RED)
		if("Grant Emergency Maintenance Access")
			GLOB.marine_main_ship.make_maint_all_access()
		if("Revoke Emergency Maintenance Access")
			GLOB.marine_main_ship.revoke_maint_all_access()

/obj/machinery/door/airlock/allowed(mob/M)
	if(is_mainship_level(z) && GLOB.marine_main_ship.maint_all_access && (ACCESS_MARINE_ENGINEERING in req_access+req_one_access))
		return TRUE
	return ..(M)
