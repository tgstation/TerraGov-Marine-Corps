/datum/progressbar
	var/goal = 1
	var/last_progress = 0
	var/bar_tag = PROG_BAR_GENERIC
	var/bg_tag = PROG_BG_GENERIC
	var/frame_tag = PROG_FRAME_GENERIC
	var/image/progress/bar/bar
	var/image/progress/bg/bg
	var/image/progress/frame/frame
	var/datum/progressicon/prog_display
	var/shown = FALSE
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/U, goal_number, atom/target, image/progress/display/new_display)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	user = U
	if(user)
		client = user.client
	if(new_display)
		prog_display = new (U, target, new_display)
	if(!bar_tag)
		return
	bar = new bar_tag(target)
	LAZYINITLIST(user.progressbars)
	LAZYINITLIST(user.progressbars[bar.loc])
	var/list/bars = user.progressbars[bar.loc]
	bars.Add(src)
	listindex = LAZYLEN(bars)
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 2))
	if(frame_tag)
		frame = new frame_tag(bar)
	if(bg_tag)
		bg = new bg_tag(bar)
	animate(bar, pixel_y = bar.pixel_y + (PROGRESSBAR_HEIGHT * (listindex - 1)), alpha = 255, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

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
	progress = CLAMP(progress, 0, goal)
	bar.update_icon(progress, goal)
	if (!shown)
		user.client.images += bar
		shown = TRUE

/datum/progressbar/proc/shiftDown()
	--listindex
	animate(bar, pixel_y = bar.pixel_y - PROGRESSBAR_HEIGHT, time = PROGRESSBAR_ANIMATION_TIME, easing = SINE_EASING)

/datum/progressbar/Destroy()
	if(bar)
		if(last_progress != goal)
			bar.icon_state = "[initial(bar.icon_state)]_fail"
		if(!QDELETED(user))
			if(!QDELETED(bar.loc))
				for(var/I in user.progressbars[bar.loc])
					var/datum/progressbar/P = I
					if(P != src && P.listindex > listindex)
						P.shiftDown()
			var/list/bars = user.progressbars[bar.loc]
			bars.Remove(src)
			if(!LAZYLEN(bars))
				LAZYREMOVE(user.progressbars, bar.loc)
		INVOKE_ASYNC(bar, /image/progress/proc/fade_out, frame, bg)

	qdel(prog_display)

	return ..()

/image/progress
	icon = 'icons/effects/progressbar.dmi'
	plane = ABOVE_HUD_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA|KEEP_TOGETHER

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
	layer = LAYER_PROGBAR
	alpha = 0
	var/interval = 5

/image/progress/bar/proc/update_icon(progress, goal)
	icon_state = "[initial(icon_state)]_[round(((progress / goal) * 100), interval)]"

/image/progress/bg
	icon_state = "prog_bar_1_bg"
	layer = LAYER_PROGBAR_BG

/image/progress/frame
	icon_state = "prog_bar_1_frame"
	layer = LAYER_PROGBAR_FRAME

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

/datum/progressicon
	var/image/progress/display/display
	var/itag
	var/atom/target

/datum/progressicon/New(mob/user, atom/target, image/progress/display/new_display)
	. = ..()
	display = new_display
	target = initial(display.owner) == DISPLAY_ICON_TARG ? target : user
	itag = initial(display.icontag)
	if(!LAZYFIND(target.display_icons, itag))
		display = new display
		target.add_overlay(display, TRUE)
		LAZYADD(target.display_icons, itag)
	target.display_icons[itag]++

/datum/progressicon/Destroy()
	if(QDELETED(target))
		QDEL_NULL(display)
		return ..()
	target.display_icons[itag]--
	if(!LAZYLEN(target.display_icons[itag]))
		target.cut_overlay(display, TRUE)
		QDEL_NULL(display)
	return ..()


/image/progress/display
	icon = 'icons/effects/progressicons.dmi'
	icon_state = "busy_generic"
	plane = FLY_LAYER
	var/owner = DISPLAY_ICON_USER
	var/icontag = "generic"

/image/progress/display/New()
	. = ..()
	icon_state = "busy_[icontag]"

/image/progress/display/target
	owner = DISPLAY_ICON_TARG

/image/progress/display/medical
	icontag = "medical"
	pixel_y = 0

/image/progress/display/medical/target
	owner = DISPLAY_ICON_TARG

/image/progress/display/construction
	icontag = "build"

/image/progress/display/construction/target
	owner = DISPLAY_ICON_TARG

/image/progress/display/friendly
	icontag = "friendly"

/image/progress/display/friendly/target
	owner = DISPLAY_ICON_TARG

/image/progress/display/hostile
	icontag = "hostile"

/image/progress/display/hostile/target
	owner = DISPLAY_ICON_TARG

/image/progress/display/clock
	icontag = "clock"

/image/progress/display/clock/target
	owner = DISPLAY_ICON_TARG

/image/progress/display/bar
	icontag = "bar"

/image/progress/display/bar/target
	owner = DISPLAY_ICON_TARG
