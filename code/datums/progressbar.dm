/datum/progressbar
	var/goal = 1
	var/last_progress = 0
	var/bar_tag = PROG_BAR_GENERIC
	var/bg_tag = PROG_BG_GENERIC
	var/frame_tag = PROG_FRAME_GENERIC
	var/mutable_appearance/progress/bar/bar
	var/mutable_appearance/progress/bg/bg
	var/mutable_appearance/progress/frame/frame
	var/datum/progressicon/prog_display
	var/shown = FALSE
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/U, goal_number, atom/target, mutable_appearance/progress/display/new_display)
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
	bar = new bar_tag ()
	bar.loc = target
	LAZYINITLIST(user.progressbars)
	LAZYINITLIST(user.progressbars[bar.loc])
	LAZYINITLIST(user.progbar_towers)
	var/list/bars = user.progressbars[bar.loc]
	listindex = LAZYLEN(bars)
	var/tower_height = user.progbar_towers[bar.loc]
	var/datum/progressbar/floor_below = bars[listindex]
	var/elevation = floor_below ? floor_below.bar.height : PROGRESSBAR_STANDARD_HEIGHT
	bar.pixel_y += 32 + tower_height - elevation
	tower_height += bar.height
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
			var/tower_height = user.progbar_towers[bar.loc]
			bars.Remove(src)
			if(!LAZYLEN(bars))
				LAZYREMOVE(user.progressbars, bar.loc)
			tower_height -= bar.height
			if(tower_height <= 0)
				LAZYREMOVE(user.progbar_towers, bar.loc)
		INVOKE_ASYNC(bar, /mutable_appearance/progress/proc/fade_out, client, frame, bg)

	qdel(prog_display)

	return ..()

/mutable_appearance/progress
	icon = 'icons/effects/progressbar.dmi'
	plane = ABOVE_HUD_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

/mutable_appearance/progress/proc/fade_out(client, bar_bg, bar_frame)
	animate(src, alpha = 0, time = PROGRESSBAR_ANIMATION_TIME)
	addtimer(CALLBACK(src, .proc/letsdeleteourself, client, bar_bg, bar_frame), PROGRESSBAR_ANIMATION_TIME + 1)

/mutable_appearance/progress/proc/letsdeleteourself(client/client, bar_bg, bar_frame)
	if(client)
		client.images -= src
	qdel(bar_bg)
	qdel(bar_frame)
	qdel(src)

/mutable_appearance/progress/bar
	icon_state = "prog_bar_1"
	layer = HUD_LAYER
	alpha = 0
	var/interval = 5
	var/height = PROGRESSBAR_STANDARD_HEIGHT

/mutable_appearance/progress/bar/proc/update_icon(progress, goal)
	icon_state = "[initial(icon_state)]_[round(((progress / goal) * 100), interval)]"

/mutable_appearance/progress/bg
	icon_state = "prog_bar_1_bg"
	appearance_flags = APPEARANCE_UI

/mutable_appearance/progress/frame
	icon_state = "prog_bar_1_frame"
	appearance_flags = APPEARANCE_UI


/datum/progressbar/battery
	bar_tag = PROG_BAR_BATTERY
	frame_tag = PROG_FRAME_BATTERY

/mutable_appearance/progress/bar/battery
	icon_state = "prog_bar_2"
	interval = 10

/mutable_appearance/progress/frame/battery
	icon_state = "prog_bar_2_frame"

/datum/progressbar/traffic
	bar_tag = PROG_BAR_TRAFFIC
	frame_tag = PROG_FRAME_TRAFFIC

/mutable_appearance/progress/bar/traffic
	icon_state = "prog_bar_2"
	interval = 25

/mutable_appearance/progress/frame/traffic
	icon_state = "prog_bar_3_frame"

/datum/progressbar/mono
	bar_tag = PROG_BAR_GRAYSCALE

/mutable_appearance/progress/bar/mono
	icon_state = "prog_bar_3"

/datum/progressbar/brass
	bar_tag = PROG_BAR_BRASS
	frame_tag = PROG_FRAME_BRASS

/mutable_appearance/progress/bar/mono/brass
	color = "#FFDF28"

/mutable_appearance/progress/frame/brass
	icon_state = "prog_bar_4_frame"

/datum/progressbar/clock
	bar_tag = PROG_BAR_CLOCK
	frame_tag = PROG_FRAME_CLOCK
	bg_tag = PROG_BG_CLOCK

/mutable_appearance/progress/bar/clock
	icon_state = "prog_bar_5"
	interval = 4
	height = 12

/mutable_appearance/progress/frame/clock
	icon_state = "prog_bar_5_frame"

/mutable_appearance/progress/bg/clock
	icon_state = "prog_bar_2_bg"

/mutable_appearance/progress/bar/clock/mono
	icon_state = "prog_bar_4"

/datum/progressicon
	var/mutable_appearance/progress/display/display
	var/itag
	var/atom/target

/datum/progressicon/New(mob/user, atom/target, mutable_appearance/progress/display/new_display)
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


/mutable_appearance/progress/display
	icon = 'icons/effects/progressicons.dmi'
	icon_state = "busy_generic"
	plane = FLY_LAYER
	var/owner = DISPLAY_ICON_USER
	var/icontag = "generic"

/mutable_appearance/progress/display/New()
	. = ..()
	icon_state = "busy_[icontag]"

/mutable_appearance/progress/display/target
	owner = DISPLAY_ICON_TARG

/mutable_appearance/progress/display/medical
	icontag = "medical"
	pixel_y = 0

/mutable_appearance/progress/display/medical/target
	owner = DISPLAY_ICON_TARG

/mutable_appearance/progress/display/construction
	icontag = "build"

/mutable_appearance/progress/display/construction/target
	owner = DISPLAY_ICON_TARG

/mutable_appearance/progress/display/friendly
	icontag = "friendly"

/mutable_appearance/progress/display/friendly/target
	owner = DISPLAY_ICON_TARG

/mutable_appearance/progress/display/hostile
	icontag = "hostile"

/mutable_appearance/progress/display/hostile/target
	owner = DISPLAY_ICON_TARG

/mutable_appearance/progress/display/clock
	icontag = "clock"

/mutable_appearance/progress/display/clock/target
	owner = DISPLAY_ICON_TARG

/mutable_appearance/progress/display/bar
	icontag = "bar"

/mutable_appearance/progress/display/bar/target
	owner = DISPLAY_ICON_TARG
