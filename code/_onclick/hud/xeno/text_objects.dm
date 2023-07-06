
/atom/movable/screen/text/screen_timer
	maptext_x = 12
	maptext_y = -70
	var/maptext_string
	var/timer_id
	var/datum/weakref/owner_client_ref

/atom/movable/screen/text/screen_timer/Initialize(mapload, client/owner_client, timer, text)
	. = ..()
	if(!timer)
		stop_timer()
		CRASH("Invalid time ref for screen nuke timer!")
	maptext_string = text
	timer_id = timer
	owner_client_ref = WEAKREF(owner_client)
	START_PROCESSING(SSprocessing, src)

	owner_client.screen.Add(src)

/atom/movable/screen/text/screen_timer/process()
	if(!owner_client_ref)
		return
	var/client/client = owner_client_ref.resolve()
	// Lets make sure we never just run with no reason
	if(!client)
		stop_timer()
		return
	var/time_left = timeleft(timer_id)
	var/time_formatted = time2text(time_left, "mm:ss")
	var/result_text = replacetextEx(maptext_string, "${timer}", time_formatted)
	if(!result_text)
		result_text = result_text + "\n" + time_formatted
	maptext = result_text

/atom/movable/screen/text/screen_timer/proc/stop_timer()
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/text/screen_timer/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)
	if(!owner_client_ref)
		return
	var/client/client = owner_client_ref.resolve()
	if(!client)
		return
	if(src in client.screen)
		client.screen.Remove(src)
