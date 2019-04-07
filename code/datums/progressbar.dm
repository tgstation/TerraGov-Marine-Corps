#define PROGRESSBAR_HEIGHT 6

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/image/bar_bg
	var/image/bar_frame
	var/interval = 5
	var/frame_tag = 1
	var/bar_tag = 1
	var/bg_tag = 1
	var/datum/progressicon/prog_display
	var/shown = 0
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/U, goal_number, atom/target, datum/progressicon/new_display)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	user = U
	if(user)
		client = user.client

	if(!isnull(bar_tag))
		bar = image('icons/effects/progressbar.dmi', target, "prog_bar_[bar_tag]_0", PROG_BAR_LAYER)
		bar.plane = ABOVE_HUD_PLANE
		bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		LAZYINITLIST(user.progressbars)
		LAZYINITLIST(user.progressbars[bar.loc])
		var/list/bars = user.progressbars[bar.loc]
		bars.Add(src)
		listindex = LAZYLEN(bars)
		var/prog_height = (PROGRESSBAR_HEIGHT * (listindex - 1))
		bar.pixel_y = 32 + prog_height
		if(!isnull(frame_tag))
			bar_frame = image('icons/effects/progressbar.dmi', target, "prog_bar_[bar_tag]_frame", PROG_BAR_FRAME_LAYER)
			bar_frame.plane = ABOVE_HUD_PLANE
			bar_frame.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			bar_frame.pixel_y = 32 + prog_height
		if(!isnull(bg_tag))
			bar_bg = image('icons/effects/progressbar.dmi', target, "prog_bar_[bar_tag]_bg", PROG_BAR_BG_LAYER)
			bar_bg.plane = ABOVE_HUD_PLANE
			bar_bg.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			bar_bg.pixel_y = 32 + prog_height

	if(new_display)
		prog_display = new new_display

/datum/progressbar/proc/update(progress)
	if(!bar)
		return
	if (!(user?.client))
		shown = FALSE
		return
	if (user.client != client)
		if(client)
			client.images -= bar
			client.images -= bar_frame
			client.images -= bar_bg
		if(user.client)
			user.client.images += bar
			user.client.images += bar_frame
			user.client.images += bar_bg

	progress = CLAMP(progress, 0, goal)
	bar.icon_state = "prog_bar_[bar_tag]_[round(((progress / goal) * 100), interval)]"
	if (!shown)
		user.client.images += bar
		user.client.images += bar_frame
		user.client.images += bar_bg
		shown = TRUE

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y -= PROGRESSBAR_HEIGHT
	if(bar_frame)
		bar_frame.pixel_y -= PROGRESSBAR_HEIGHT
	if(bar_bg)
		bar_bg.pixel_y -= PROGRESSBAR_HEIGHT

/datum/progressbar/Destroy()
	if(bar)
		if(!QDELETED(user))
			if(!QDELETED(target))
				for(var/I in user.progressbars[bar.loc])
					var/datum/progressbar/P = I
					if(P != src && P.listindex > listindex)
						P.shiftDown()
			var/list/bars = user.progressbars[bar.loc]
			bars.Remove(src)
			if(!LAZYLEN(bars))
				LAZYREMOVE(user.progressbars, bar.loc)

		if(client)
			client.images -= bar
			client.images -= bar_frame
			client.images -= bar_bg
		qdel(bar)
		qdel(bar_frame)
		qdel(bar_bg)

	qdel(prog_display)

	return ..()

#undef PROGRESSBAR_HEIGHT

/datum/progressicon
	var/image/display
	var/display_tag = "generic"
	var/atom/display_owner = DISPLAY_ICON_USER
	var/display_offset = list("x" = 0, "y" = 32)

/datum/progressicon/New(mob/user, atom/target)
	. = ..()
	display_owner = display_owner == DISPLAY_ICON_TARG ? target : user
	if(!LAZYFIND(display_owner.display_icons, display_tag))
		display = image('icons/effects/progressicons.dmi', null, "busy_[display_tag]")
		display.pixel_x = display_offset[1]
		display.pixel_y = display_offset[2]
		display.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		display.plane = FLY_LAYER
		display_owner.add_overlay(display, TRUE)
		LAZYADD(display_owner.display_icons, display_tag)
	display_owner.display_icons[display_tag]++

/datum/progressicon/Destroy()
	if(QDELETED(display_owner))
		QDEL_NULL(display)
		return ..()
	display_owner.display_icons[display_tag]--
	if(!LAZYLEN(display_owner.display_icons[display_tag]))
		display_owner.cut_overlay(display, TRUE)
		QDEL_NULL(display)
	return ..()

/datum/progressicon/target
	display_owner = DISPLAY_ICON_TARG

/datum/progressicon/medical
	display_tag = "medical"
	display_offset = list("x" = 0, "y" = 0)

/datum/progressicon/medical/target
	display_owner = DISPLAY_ICON_TARG

/datum/progressicon/construction
	display_tag = "build"

/datum/progressicon/construction/target
	display_owner = DISPLAY_ICON_TARG

/datum/progressicon/friendly
	display_tag = "friendly"

/datum/progressicon/friendly/target
	display_owner = DISPLAY_ICON_TARG

/datum/progressicon/hostile
	display_tag = "hostile"

/datum/progressicon/hostile/target
	display_owner = DISPLAY_ICON_TARG

/datum/progressicon/clock
	display_tag = "clock"

/datum/progressicon/clock/target
	display_owner = DISPLAY_ICON_TARG

/datum/progressicon/bar
	display_tag = "bar"

/datum/progressicon/bar/target
	display_owner = DISPLAY_ICON_TARG
