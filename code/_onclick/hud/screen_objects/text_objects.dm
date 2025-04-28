
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
	/// Left side of the HTML tag for maptext, style is also included
	var/maptext_style_left = "<span class='maptext' style=font-size:12pt;text-align:center; align='top'>"
	/// End tag of the HTML tag for maptext
	var/maptext_style_right = "</span>"
	/// The actual displayed content of the maptext, use ${timer}, and it'll be replaced with the time left
	var/maptext_string
	/// Timer ID that we're tracking, the time left of this is displayed as maptext
	var/timer_id
	/// The list of mobs that we're attached to, and care about
	var/list/timer_mobs = list()

/atom/movable/screen/text/screen_timer/Initialize(
		mapload,
		datum/hud/hud_owner,
		list/mobs,
		timer,
		text,
		offset_x = 150,
		offset_y = -70,
		style_start,
		style_end,
	)
	. = ..()

	if(!islist(mobs) && mobs)
		mobs = list(mobs)
	// Copy the list just in case the arguments list is a list we don't want to modify
	if(length(mobs))
		mobs = mobs.Copy()
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

/atom/movable/screen/text/screen_timer/process()
	if(!timeleft(timer_id))
		delete_self()
		return
	update_maptext()

/// Adds the object to the client.screen of all mobs in the list, and registers the needed signals
/atom/movable/screen/text/screen_timer/proc/apply_to(list/mobs)
	if(!islist(mobs))
		if(!mobs)
			return
		mobs = list(mobs)
	if(!length(timer_mobs) && length(mobs))
		START_PROCESSING(SSprocessing, src)
	for(var/player in mobs)
		if(player in timer_mobs)
			continue
		if(istype(player, /datum/weakref))
			var/datum/weakref/ref = player
			player = ref.resolve()
		attach(player)
		RegisterSignal(player, COMSIG_MOB_LOGIN, PROC_REF(attach))
		timer_mobs += WEAKREF(player)

/// Removes the object from the client.screen of all mobs in the list, and unregisters the needed signals, while also stopping processing if there's no more mobs in the screen timers mob list
/atom/movable/screen/text/screen_timer/proc/remove_from(list/mobs)
	if(!islist(mobs))
		if(!mobs)
			return
		mobs = list(mobs)
	for(var/player in mobs)
		UnregisterSignal(player, COMSIG_MOB_LOGIN)
		if(player in timer_mobs)
			timer_mobs -= player
		if(istype(player, /datum/weakref))
			var/datum/weakref/ref = player
			player = ref.resolve()
		de_attach(player)
	if(!length(timer_mobs))
		STOP_PROCESSING(SSprocessing, src)

/// Updates the maptext to show the current time left on the timer
/atom/movable/screen/text/screen_timer/proc/update_maptext()
	var/time_formatted = time2text(timeleft(timer_id), "mm:ss")
	var/timer_text = replacetextEx(maptext_string, "${timer}", time_formatted)
	// If we don't find ${timer} in the string, just use the time formatted
	var/result_text = "[maptext_style_left][timer_text][maptext_style_right]"
	maptext = result_text

/// Adds the object to the client.screen of the mob, or removes it if add_to_screen is FALSE
/atom/movable/screen/text/screen_timer/proc/attach(mob/source, add_to_screen = TRUE)
	SIGNAL_HANDLER
	if(!source?.client)
		return
	var/client/client = source.client
	// this checks if the screen is already added or removed
	if(add_to_screen == (src in client.screen))
		return
	if(!ismob(source))
		CRASH("Invalid source passed to screen_timer/attach()!")
	if(add_to_screen)
		client.screen += src
	else
		client.screen -= src

/// Signal handler to run attach with specific args
/atom/movable/screen/text/screen_timer/proc/de_attach(mob/source)
	SIGNAL_HANDLER
	attach(source, FALSE)

/// Mainly a signal handler so we can run qdel()
/atom/movable/screen/text/screen_timer/proc/delete_self()
	SIGNAL_HANDLER
	// I noticed in testing that even when qdel() is run, it still keeps running processing, even though it should have stopped processing due to running Destroy
	STOP_PROCESSING(SSprocessing, src)
	qdel(src)

/atom/movable/screen/text/screen_timer/Destroy()
	. = ..()
	remove_from(timer_mobs)
	STOP_PROCESSING(SSprocessing, src)
