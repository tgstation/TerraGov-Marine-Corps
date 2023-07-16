
/// UI obj holders for all your maptext needs
/atom/movable/screen/text
	name = null
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/// A screen object that shows the time left on a timer
/atom/movable/screen/text/screen_timer
	screen_loc = "CENTER-7,CENTER-7"
	var/maptext_style_left = "<span class='maptext' style=font-size:16pt;text-align:center; align='top'>"
	var/maptext_style_right = "</span>"
	var/maptext_string
	var/timer_id
	var/list/timer_mobs = list()

/atom/movable/screen/text/screen_timer/Initialize(
		mapload,
		mobs,
		timer,
		text,
		style_start,
		style_end,
		offset_x = 12,
		offset_y = -70
	)
	. = ..()

	if(!islist(mobs))
		if(!mobs)
			return INITIALIZE_HINT_QDEL
		mobs = list(mobs)
	if(!timer)
		stack_trace("Invalid timer for screen nuke timer!")
		return INITIALIZE_HINT_QDEL
	if(style_start)
		maptext_style_left = style_start
	if(style_end)
		maptext_style_right = style_end
	maptext_string = text
	timer_id = timer
	maptext_x = offset_x
	maptext_y = offset_y
	update_maptext()
	if(length(mobs))
		apply_to(mobs)
		START_PROCESSING(SSprocessing, src)

/atom/movable/screen/text/screen_timer/process()
	if(!timeleft(timer_id))
		delete_self()
		return
	update_maptext()

/// Adds the object to the client.screen of all mobs in the list, and registers the needed signals
/atom/movable/screen/text/screen_timer/proc/apply_to(list/mobs)
	if(!length(timer_mobs) && length(mobs))
		START_PROCESSING(SSprocessing, src)
	for(var/mob/player in mobs)
		if(player in timer_mobs)
			continue
		attach(player.client)
		timer_mobs += player
		RegisterSignal(player, COMSIG_MOB_LOGIN, PROC_REF(attach))
		RegisterSignal(player, COMSIG_MOB_LOGOUT, PROC_REF(de_attach))

/// Gets rid of the object from the client.screen of all mobs in the list, and unregisters the needed signals
/atom/movable/screen/text/screen_timer/proc/remove_from(list/mobs)
	for(var/mob/player in mobs)
		if(player in timer_mobs)
			timer_mobs -= player
		de_attach(player.client)
		UnregisterSignal(player, COMSIG_MOB_LOGIN)
		UnregisterSignal(player, list(COMSIG_MOB_LOGOUT))
	if(!length(timer_mobs))
		STOP_PROCESSING(SSprocessing, src)

/// Updates the maptext to show the current time left on the timer
/atom/movable/screen/text/screen_timer/proc/update_maptext()
	var/time_left = timeleft(timer_id)
	var/time_formatted = time2text(time_left, "mm:ss")
	var/result_text = replacetextEx(maptext_string, "${timer}", time_formatted)
	if(!result_text)
		result_text = "[maptext_style_left][result_text][time_formatted][maptext_style_right]"
	maptext = result_text

// 
/atom/movable/screen/text/screen_timer/proc/attach(client/source, add_to_screen = TRUE)
	SIGNAL_HANDLER
	if(!source || (src in source.screen))
		return
	if(add_to_screen)
		source.screen += src
	else
		source.screen -= src

/atom/movable/screen/text/screen_timer/proc/de_attach(client/source)
	SIGNAL_HANDLER
	attach(source, FALSE)

/atom/movable/screen/text/screen_timer/proc/delete_self()
	SIGNAL_HANDLER
	// I noticed in testing that even when qdel() is run, it still keeps running processing, even though it should have stopped processing due to running Destroy
	STOP_PROCESSING(SSprocessing, src)
	qdel(src)

/atom/movable/screen/text/screen_timer/Destroy()
	. = ..()
	remove_from(timer_mobs)
	STOP_PROCESSING(SSprocessing, src)
