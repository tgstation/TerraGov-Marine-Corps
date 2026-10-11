///Waiting for confirmation
#define KEYCARD_AUTH_ACTIVE (1<<0)
/// Has this event been authorized by a silicon. Most of the time, this means the AI.
#define KEYCARD_AUTH_AI_ACTIVATION (1<<1)

//Swipe timer
#define KEYCARD_AUTH_SWIPE_TIME 2 SECONDS

#define KEYCARD_AUTH_SELECTION "keycard_auth_selection"
#define KEYCARD_AUTH_SWIPE_NEEDED "keycard_auth_swipe_needed"
#define KEYCARD_AUTH_AI_OVERRIDE "keycard_auth_ai_override"

///Grant maint access event
#define KEYCARD_AUTH_GRANT_MAINT_ACCESS "Grant Emergency Maintenance Access"
///Revoke maint access event
#define KEYCARD_AUTH_REVOKE_MAINT_ACCESS "Revoke Emergency Maintenance Access"

/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger station functions, which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 6
	power_channel = ENVIRON

	light_power = 0.5
	light_range = 0.7
	light_color = LIGHT_COLOR_BLUE

	///The event we are intending to trigger
	var/event = null
	///current state/screen we're on
	var/screen = KEYCARD_AUTH_SELECTION
	///basically used to distinguish the 2nd swipe from the first. Stinky.
	var/obj/machinery/keycard_auth/event_source
	///mob who triggered an event
	var/mob/event_triggered_by
	///Behavior flags
	var/keycard_flags
	///Reset timer for swiping
	var/reset_timer


/obj/machinery/keycard_auth/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(!istype(I, /obj/item/card/id))
		return
	var/obj/item/card/id/ID = I
	if(!(ACCESS_MARINE_BRIDGE in ID.access))
		return

	if((keycard_flags & KEYCARD_AUTH_ACTIVE) && event_source)
		event_source.finish_confirm(user)
		reset()

	else if(screen == KEYCARD_AUTH_SWIPE_NEEDED)
		event_triggered_by = user
		broadcast_request() //This is the device making the initial event request. It needs to broadcast to other devices

/obj/machinery/keycard_auth/update_icon()
	. = ..()
	if(!(keycard_flags & KEYCARD_AUTH_ACTIVE) || (machine_stat & (BROKEN|DISABLED|NOPOWER)))
		set_light(0)
		return
	else
		set_light(initial(light_range))

/obj/machinery/keycard_auth/update_icon_state()
	. = ..()
	if((keycard_flags & KEYCARD_AUTH_ACTIVE) && !(machine_stat & (BROKEN|DISABLED|NOPOWER)))
		icon_state = "auth_on"
	else
		icon_state = "auth_off"

/obj/machinery/keycard_auth/update_overlays()
	. = ..()
	if(!(keycard_flags & KEYCARD_AUTH_ACTIVE) || (machine_stat & (BROKEN|DISABLED|NOPOWER)))
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)

/obj/machinery/keycard_auth/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE
	return TRUE

/obj/machinery/keycard_auth/interact(mob/user)
	. = ..()
	if(.)
		return

	if(issilicon(user))
		keycard_flags |= KEYCARD_AUTH_AI_ACTIVATION

	var/dat
	dat += "This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards."
	dat += "<br><hr><br>"

	if(screen == KEYCARD_AUTH_SELECTION)
		dat += "Select an event to trigger:<ul>"
		for(var/iter_level_text AS in SSsecurity_level.available_levels)
			var/datum/security_level/iter_level_datum = SSsecurity_level.available_levels[iter_level_text]
			if(!(iter_level_datum.sec_level_flags & SEC_LEVEL_FLAG_CAN_SWITCH_WITH_AUTH))
				continue
			dat += "<li><A href='byond://?src=[text_ref(src)];trigger_event=[iter_level_datum.name]'>Set alert level to [iter_level_datum.name]</A></li>"

		dat += "<li><A href='byond://?src=[text_ref(src)];trigger_event=Grant Emergency Maintenance Access'>Grant Emergency Maintenance Access</A></li>"
		dat += "<li><A href='byond://?src=[text_ref(src)];trigger_event=Revoke Emergency Maintenance Access'>Revoke Emergency Maintenance Access</A></li>"
		dat += "</ul>"

	else if(screen == KEYCARD_AUTH_SWIPE_NEEDED)
		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		dat += "<p><A href='byond://?src=[text_ref(src)];reset=1'>Back</A>"

	else if(screen == KEYCARD_AUTH_AI_OVERRIDE)
		dat += "Do you want to trigger the following event using your Silicon Privileges: <b>[event]</b>"
		dat += "<p><A href='byond://?src=[text_ref(src)];silicon_activate_event=1'>Activate</A>"
		dat += "<p><A href='byond://?src=[text_ref(src)];reset=1'>Back</A>"

	var/datum/browser/popup = new(user, "keycard_auth", "<div align='center'>Keycard Authentication Device</div>", 500, 250)
	popup.set_content(dat)
	popup.open(FALSE)

/obj/machinery/keycard_auth/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["trigger_event"])
		event = href_list["trigger_event"]
		if(keycard_flags & KEYCARD_AUTH_AI_ACTIVATION)
			screen = KEYCARD_AUTH_AI_OVERRIDE
		else
			screen = KEYCARD_AUTH_SWIPE_NEEDED

	if(href_list["silicon_activate_event"])
		event_triggered_by = usr
		trigger_event()
		log_game("[key_name(event_triggered_by)] triggered event [event].")
		message_admins("[ADMIN_TPMONTY(event_triggered_by)] triggered event [event].")
		reset()

	if(href_list["reset"])
		reset()

	updateUsrDialog()

///Resets us entirely
/obj/machinery/keycard_auth/proc/reset()
	keycard_flags &= ~(KEYCARD_AUTH_ACTIVE|KEYCARD_AUTH_AI_ACTIVATION)
	event = null
	screen = KEYCARD_AUTH_SELECTION
	event_source = null
	event_triggered_by = null
	deltimer(reset_timer)
	reset_timer = null
	update_appearance()

///Primes other keycard auths for ID swipe
/obj/machinery/keycard_auth/proc/broadcast_request()
	keycard_flags |= KEYCARD_AUTH_ACTIVE
	update_appearance()
	reset_timer = addtimer(CALLBACK(src, PROC_REF(reset)), KEYCARD_AUTH_SWIPE_TIME, TIMER_STOPPABLE)
	for(var/obj/machinery/keycard_auth/auth_machine in GLOB.machines)
		if(auth_machine == src)
			continue
		auth_machine.reset()
		auth_machine.receive_request(src)

///Has been notified by another machine for ID swipe
/obj/machinery/keycard_auth/proc/receive_request(obj/machinery/keycard_auth/source)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	event_source = source
	keycard_flags |= KEYCARD_AUTH_ACTIVE
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(reset)), KEYCARD_AUTH_SWIPE_TIME, TIMER_STOPPABLE)

///Cleans up after the timer (and turns on if we swiped)
/obj/machinery/keycard_auth/proc/finish_confirm(mob/event_confirmed_by)
	trigger_event()
	log_game("[key_name(event_triggered_by)] triggered and [key_name(event_confirmed_by)] confirmed keycard auth event [event].")
	message_admins("[ADMIN_TPMONTY(event_triggered_by)] triggered and [ADMIN_TPMONTY(event_confirmed_by)] confirmed keycard auth event [event].")
	reset()

///Triggers an event
/obj/machinery/keycard_auth/proc/trigger_event()
	var/potential_alert_level = SSsecurity_level.text_level_to_number(event)
	if(potential_alert_level)
		SSsecurity_level.set_level(potential_alert_level)
		return
	switch(event)
		if(KEYCARD_AUTH_GRANT_MAINT_ACCESS)
			make_maint_all_access()
		if(KEYCARD_AUTH_REVOKE_MAINT_ACCESS)
			revoke_maint_all_access()

//////////////////////////////////////////////////////
GLOBAL_VAR_INIT(maint_all_access, FALSE)
/// Enables all access for maintenance airlocks
/proc/make_maint_all_access()
	GLOB.maint_all_access = TRUE
	priority_announce(
		title = "Attention!",
		subtitle = "Shipside emergency declared.",
		message = "The maintenance access requirement has been revoked on all maintenance airlocks.",
		sound = 'sound/misc/notice1.ogg',
		color_override = "grey"
	)
	SSblackbox.record_feedback(FEEDBACK_NESTED_TALLY, "keycard_auth_events", 1, list("emergency maintenance access", "enabled"))

/// Disables all access for maintenance airlocks
/proc/revoke_maint_all_access()
	GLOB.maint_all_access = FALSE
	priority_announce(
		title = "Attention!",
		subtitle = "Shipside emergency revoked.",
		message = "The maintenance access requirement has been restored on all maintenance airlocks.",
		sound = 'sound/misc/notice2.ogg',
		color_override = "grey"
	)
	SSblackbox.record_feedback(FEEDBACK_NESTED_TALLY, "keycard_auth_events", 1, list("emergency maintenance access", "disabled"))

/obj/machinery/door/airlock/allowed(mob/M)
	if(is_mainship_level(z) && GLOB.maint_all_access && (ACCESS_MARINE_ENGINEERING in (req_access+req_one_access)))
		return TRUE
	return ..(M)
