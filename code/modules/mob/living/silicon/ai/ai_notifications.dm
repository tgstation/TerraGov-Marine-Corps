
/mob/living/silicon/ai/proc/notify_ai(mob/living/silicon/receivingai, message, ai_sound = null, atom/source = null, mutable_appearance/alert_overlay = null, action = NOTIFY_AI_ALERT, header = null, notify_volume = 100) //stripped down notify_ghost for AI

	if(ai_sound)
		SEND_SOUND(receivingai, sound(ai_sound, volume = notify_volume, channel = CHANNEL_NOTIFY))
	if(!source)
		return

	var/atom/movable/screen/alert/ai_notify/alertnotification = receivingai.throw_alert("[REF(source)]_notify_action", /atom/movable/screen/alert/ai_notify)
	if(!alertnotification)
		return
	if (header)
		alertnotification.name = header
	alertnotification.desc = message
	alertnotification.action = action
	alertnotification.target = source
	if(!alert_overlay)
		alert_overlay = new(source)

	alert_overlay.layer = FLOAT_LAYER
	alert_overlay.plane = FLOAT_PLANE

	alertnotification.add_overlay(alert_overlay)

///Receive notifications about OB laser dots that have been deployed
/mob/living/silicon/ai/proc/receive_laser_ob(datum/source, obj/effect/overlay/temp/laser_target/OB/incoming_laser)
	SIGNAL_HANDLER
	to_chat(src, span_notice("Orbital Bombardment laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	notify_ai(src, "<b> An Orbital Bombardment laser</b> has been detected at [AREACOORD_NO_Z(incoming_laser)]!", ai_sound = 'sound/effects/obalarm.ogg', source = incoming_laser, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about CAS laser dots that have been deployed
/mob/living/silicon/ai/proc/receive_laser_cas(datum/source, obj/effect/overlay/temp/laser_target/cas/incoming_laser)
	SIGNAL_HANDLER
	to_chat(src, span_notice("CAS laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	notify_ai(src, "<b> CAS laser detected. </b> Target: [AREACOORD_NO_Z(incoming_laser)]", ai_sound = 'sound/effects/binoctarget.ogg', source = incoming_laser, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about railgun laser dots that have been deployed
/mob/living/silicon/ai/proc/receive_laser_railgun(datum/source, obj/effect/overlay/temp/laser_target/cas/incoming_laser)
	SIGNAL_HANDLER
	to_chat(src, span_notice("Railgun laser detected. Target: [AREACOORD_NO_Z(incoming_laser)]"))
	notify_ai(src, "<b> Railgun laser detected. </b> Target: [AREACOORD_NO_Z(incoming_laser)]", ai_sound = 'sound/effects/binoctarget.ogg', source = incoming_laser, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about the xenos locking down the Alamo
/mob/living/silicon/ai/proc/receive_lockdown_warning(datum/source, obj/machinery/computer/shuttle/marine_dropship/lockedship)
	SIGNAL_HANDLER
	var/area/A = get_area(lockedship)
	to_chat(src, span_notice("Electronic corruption detected at [A]! Controls overridden!"))
	playsound_local(src, 'sound/voice/4_xeno_roars.ogg', 15)
	notify_ai(src, "<b> Electronic corruption detected at [A]! Controls overridden! </b>" , source = lockedship, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about the tad control equipment being destroyed
/mob/living/silicon/ai/proc/receive_tad_warning(datum/source, obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/ruinedtad)
	SIGNAL_HANDLER
	to_chat(src, span_notice("Telemetry from our mini dropship reports that the controls have become nonfunctional!"))
	notify_ai(src, "<b> Telemetry from our mini dropship reports that the controls have become nonfunctional! </b>", ai_sound = 'sound/voice/4_xeno_roars.ogg', source = ruinedtad, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about disks being generated
/mob/living/silicon/ai/proc/show_disk_complete(datum/source, obj/machinery/computer/nuke_disk_generator/generatingcomputer)
	SIGNAL_HANDLER
	var/area/A = get_area(generatingcomputer)
	to_chat(src, span_notice("A new disk has been generated at [A]!"))
	notify_ai(src, "<b> A new disk has been generated at [A]! </b>", ai_sound = 'sound/machines/fax.ogg', source = generatingcomputer, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about the nuclear bomb being armed
/mob/living/silicon/ai/proc/show_nuke_start(datum/source, obj/machinery/nuclearbomb/nukebomb)
	SIGNAL_HANDLER
	var/area/A = get_area(nukebomb)
	to_chat(src, span_notice("The nuclear bomb at [A] has been activated!"))
	notify_ai(src, "<b> The nuclear bomb at [A] has been activated! </b>", ai_sound = 'sound/machines/warning-buzzer.ogg', source = nukebomb, action = NOTIFY_AI_ALERT, notify_volume = 25)

///Receive notifications about a fresh clone being active
/mob/living/silicon/ai/proc/show_fresh_clone(datum/source, obj/machinery/cloning/vats/cloningtube)
	SIGNAL_HANDLER
	var/area/A = get_area(cloningtube)
	to_chat(src, span_notice("A fresh clone has awoken at [A]!"))
	notify_ai(src, "<b> A fresh clone has awoken at [A]! </b>", ai_sound = 'sound/machines/medevac_extend.ogg', source = cloningtube, action = NOTIFY_AI_ALERT, notify_volume = 15)

///Receive notifications about someone calling the AI via holopad
/mob/living/silicon/ai/proc/ping_ai(datum/source, obj/machinery/holopad/callingholopad)
	SIGNAL_HANDLER
	var/area/A = get_area(callingholopad)
	to_chat(src, span_notice("Your presence is requested at [A]!"))
	notify_ai(src, "<b> Your presence is requested at [A]! </b>", source = callingholopad, action = NOTIFY_AI_ALERT, notify_volume = 15)
