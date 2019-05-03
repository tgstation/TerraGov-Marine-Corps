/datum/progressbar
	var/goal = 1
	var/last_progress
	var/bar_tag = PROG_BAR_GENERIC
	var/bg_tag = PROG_BG_GENERIC
	var/frame_tag = PROG_FRAME_GENERIC
	var/image/progress/bar/bar
	var/image/progress/bg/bg
	var/image/progress/frame/frame
	var/list/prog_displays
	var/shown = FALSE
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/U, goal_number, atom/target, user_display, target_display)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	user = U
	if(user)
		client = user.client
	if(user_display)
		var/datum/progressicon/D = new (U, user_display)
		LAZYADD(prog_displays, D)
	if(target_display)
		var/datum/progressicon/D = new (target, target_display)
		LAZYADD(prog_displays, D)
	if(!bar_tag)
		return
	bar = new bar_tag
	bar.loc = target
	LAZYINITLIST(user.progressbars)
	LAZYINITLIST(user.progressbars[bar.loc])
	LAZYOR(user.progbar_towers, bar.loc)
	var/list/bars = user.progressbars[bar.loc]
	listindex = LAZYLEN(bars)
	var/elevation = PROGRESSBAR_STANDARD_HEIGHT
	if(listindex)
		var/datum/progressbar/P = bars[listindex]
		elevation = P.bar.height
	bar.pixel_y += 32 - elevation + user.progbar_towers[bar.loc]
	user.progbar_towers[bar.loc] += bar.height
	bars.Add(src)
	if(frame_tag)
		frame = new frame_tag
		bar.overlays += frame_tag
	if(bg_tag)
		bg = new bg_tag
		bar.underlays += bg_tag
	animate(bar, pixel_y = bar.pixel_y + elevation, alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/proc/update(progress)
	if(!bar)
		return
	if (!(user?.client))
		shown = FALSE
		return
	if (user.client != client)
		if(client)
			client.images -= bar
		if(user.client)
			user.client.images += bar
			client = user.client
	progress = CLAMP(progress, 0, goal)
	last_progress = progress
	bar.update_icon(progress, goal)
	if (!shown)
		user.client.images += bar
		shown = TRUE

/datum/progressbar/proc/shiftDown(height)
	--listindex
	animate(bar, pixel_y = bar.pixel_y - height, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/Destroy()
	if(bar)
		if(last_progress && last_progress != goal)
			bar.icon_state = "[initial(bar.icon_state)]_fail"
		if(!QDELETED(user))
			if(!QDELETED(bar.loc))
				for(var/I in user.progressbars[bar.loc])
					var/datum/progressbar/P = I
					if(P != src && P.listindex > listindex)
						P.shiftDown(bar.height)
			var/list/bars = user.progressbars[bar.loc]
			bars.Remove(src)
			if(!LAZYLEN(bars))
				LAZYREMOVE(user.progressbars, bar.loc)
			user.progbar_towers[bar.loc] -= bar.height
			if(user.progbar_towers[bar.loc] <= 0)
				LAZYREMOVE(user.progbar_towers, bar.loc)
		INVOKE_ASYNC(bar, /image/progress/proc/fade_out, client, frame, bg)

	QDEL_LIST(prog_displays)

	return ..()

/image/progress
	icon = 'icons/effects/progressbar.dmi'
	plane = ABOVE_HUD_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

/image/progress/proc/fade_out(client, bar_bg, bar_frame)
	animate(src, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	addtimer(CALLBACK(src, .proc/letsdeleteourself, client, bar_bg, bar_frame), PROGRESSBAR_ANIMATION_TIME + 1)

/image/progress/proc/letsdeleteourself(client/client, bar_bg, bar_frame)
	if(client)
		client.images -= src
	qdel(bar_bg)
	qdel(bar_frame)
	qdel(src)

/image/progress/bar
	icon_state = "prog_bar_1"
	layer = HUD_LAYER
	alpha = 0
	var/interval = 5
	var/height = PROGRESSBAR_STANDARD_HEIGHT

/image/progress/bar/proc/update_icon(progress, goal)
	icon_state = "[initial(icon_state)]_[round(((progress / goal) * 100), interval)]"

/image/progress/bg
	icon_state = "prog_bar_1_bg"
	appearance_flags = APPEARANCE_UI

/image/progress/frame
	icon_state = "prog_bar_1_frame"
	appearance_flags = APPEARANCE_UI


/datum/progressbar/battery
	bar_tag = PROG_BAR_BATTERY
	frame_tag = PROG_FRAME_BATTERY

/image/progress/bar/battery
	icon_state = "prog_bar_2"
	interval = 10

/image/progress/frame/battery
	icon_state = "prog_bar_2_frame"

/datum/progressbar/traffic
	bar_tag = PROG_BAR_TRAFFIC
	frame_tag = PROG_FRAME_TRAFFIC

/image/progress/bar/traffic
	icon_state = "prog_bar_2"
	interval = 25

/image/progress/frame/traffic
	icon_state = "prog_bar_3_frame"

/datum/progressbar/mono
	bar_tag = PROG_BAR_GRAYSCALE

/image/progress/bar/mono
	icon_state = "prog_bar_3"

/datum/progressbar/brass
	bar_tag = PROG_BAR_BRASS
	frame_tag = PROG_FRAME_BRASS

/image/progress/bar/mono/brass
	color = "#FFDF28"

/image/progress/frame/brass
	icon_state = "prog_bar_4_frame"

/datum/progressbar/clock
	bar_tag = PROG_BAR_CLOCK
	frame_tag = PROG_FRAME_CLOCK
	bg_tag = PROG_BG_CLOCK

/image/progress/bar/clock
	icon_state = "prog_bar_5"
	interval = 4
	height = 12

/image/progress/frame/clock
	icon_state = "prog_bar_5_frame"

/image/progress/bg/clock
	icon_state = "prog_bar_2_bg"

/image/progress/bar/clock/mono
	icon_state = "prog_bar_4"

/datum/progressicon
	var/image/progress/display/display
	var/image/progress/display/display_tag = BUSY_ICON_GENERIC
	var/atom/target

/datum/progressicon/New(atom/T, image/progress/display/new_display)
	. = ..()
	if(new_display)
		display_tag = new_display
	target = T
	LAZYINITLIST(target.display_icons)
	for(var/A in target.display_icons)
		var/image/progress/display/D = A
		if(D.icon_state == initial(display_tag.icon_state))
			display = D
			break
	if(!display)
		display = new display_tag
		target.overlays += display
		target.display_icons.Add(display)
	target.display_icons[display]++

/datum/progressicon/Destroy()
	if(QDELETED(target))
		QDEL_NULL(display)
		return ..()
	target.display_icons[display]--
	if(target.display_icons[display] <= 0)
		LAZYREMOVE(target.display_icons, display)
		target.overlays -= display
		QDEL_NULL(display)
	return ..()

/image/progress/display
	icon = 'icons/effects/progressicons.dmi'
	icon_state = "busy_generic"
	plane = FLY_LAYER
	alpha = 255
	pixel_y = 32

/image/progress/display/medical
	icon_state = "busy_medical"
	pixel_y = 0

/image/progress/display/construction
	icon_state = "busy_build"

/image/progress/display/friendly
	icon_state = "busy_friendly"

/image/progress/display/hostile
	icon_state = "busy_hostile"

/image/progress/display/clock
	icon_state = "busy_clock"

/image/progress/display/clock/alt
	icon_state = "busy_clock2"

/image/progress/display/danger
	icon_state = "busy_danger"

/image/progress/display/bar
	icon_state = "busy_bar"

/image/progress/display/unskilled
	icon_state = "busy_questionmark"

