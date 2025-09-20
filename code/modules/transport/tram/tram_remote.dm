/obj/item/assembly/control/transport/remote
	// tg has unique sprites for this but im lazy
	icon_state = "signaller"
	worn_icon_state = "signaler"
	name = "tram remote"
	desc = "A remote control that can be linked to a tram. This can only go well."
	w_class = WEIGHT_CLASS_TINY
	options = RAPID_MODE
	///desired tram destination
	var/destination
	COOLDOWN_DECLARE(tram_remote)

/obj/item/assembly/control/transport/remote/Initialize(mapload)
	. = ..()
	if(!id_tag)
		id_tag = assign_random_name()
	SStransport.hello(src, name, id_tag)

//set tram destination
/obj/item/assembly/control/transport/remote/attack_hand_alternate(mob/living/user)
	. = ..()
	var/list/available_platforms = list()
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/platform as anything in SStransport.nav_beacons[specific_transport_id])
		LAZYADD(available_platforms, platform.name)

	var/selected_platform = tgui_input_list(user, "Available destinations", "Where to?", available_platforms)
	for(var/obj/effect/landmark/transport/nav_beacon/tram/platform/potential_platform as anything in SStransport.nav_beacons[specific_transport_id])
		if(potential_platform.name == selected_platform)
			destination = potential_platform.platform_code
			break

	balloon_alert(user, "set [selected_platform]")
	to_chat(user, span_notice("You change the platform ID on [src] to [selected_platform]."))

///set safety bypass
/obj/item/assembly/control/transport/remote/CtrlClick(mob/user)
	if(!Adjacent(user))
		return
	switch(options)
		if(!RAPID_MODE)
			options |= RAPID_MODE
		if(RAPID_MODE)
			options &= ~RAPID_MODE
	update_appearance()
	balloon_alert(user, "mode: [options ? "fast" : "safe"]")

/obj/item/assembly/control/transport/remote/examine(mob/user)
	. = ..()
	if(!specific_transport_id)
		. += "There is an X showing on the display."
		. += "Left-click to link to a tram."
		return
	. += "The rapid mode light is [options ? "on" : "off"]."
	if(!COOLDOWN_FINISHED(src, tram_remote))
		. += "The number on the display shows [DisplayTimeText(COOLDOWN_TIMELEFT(src, tram_remote), 1)]."
	else
		. += "The display indicates ready."
	. += "Left-click to dispatch tram."
	. += "Right-click to set destination."
	. += "Ctrl-click to toggle safety bypass."
	. += "Alt-click to change configured tram."

/obj/item/assembly/control/transport/remote/update_icon_state()
	. = ..()

	if(!specific_transport_id)
		icon_state = "tramremote_nis"
		return

	icon_state = "tramremote_ob"

/obj/item/assembly/control/transport/remote/update_overlays()
	. = ..()
	if(options & RAPID_MODE)
		. += mutable_appearance(icon, "tramremote_emag")

/obj/item/assembly/control/transport/remote/attack_self(mob/user)
	if(!specific_transport_id)
		link_tram(user)
		return

	if(COOLDOWN_FINISHED(src, tram_remote))
		balloon_alert(user, "cooldown: [DisplayTimeText(COOLDOWN_TIMELEFT(src, tram_remote), 1)]")
		return

	activate(user)
	COOLDOWN_START(src, tram_remote, 2 MINUTES)

///send our selected commands to the tram
/obj/item/assembly/control/transport/remote/activate(mob/user)
	if(!specific_transport_id)
		balloon_alert(user, "no tram linked!")
		return
	if(!destination)
		balloon_alert(user, "no destination!")
		return

	SEND_SIGNAL(src, COMSIG_TRANSPORT_REQUEST, specific_transport_id, destination, options)

// how i wish we had tgcode for clicks
/obj/item/assembly/control/transport/remote/AltClick(mob/user)
	if(!Adjacent(user))
		return
	link_tram(user)

/obj/item/assembly/control/transport/remote/proc/link_tram(mob/user)
	specific_transport_id = null
	var/list/transports_available
	for(var/datum/transport_controller/linear/tram/tram as anything in SStransport.transports_by_type[TRANSPORT_TYPE_TRAM])
		LAZYADD(transports_available, tram.specific_transport_id)

	specific_transport_id = tgui_input_list(user, "Available transports", "Select a transport", transports_available)

	if(specific_transport_id)
		balloon_alert(user, "tram linked")
	else
		balloon_alert(user, "link failed!")

	update_appearance()
