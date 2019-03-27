#define PROGRESSBAR_HEIGHT 6

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/bar_tag = 0
	var/image/display
	var/display_tag
	var/atom/display_owner
	var/display_target = FALSE
	var/display_icon
	var/shown = 0
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/U, goal_number, atom/target)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	if(!isnull(bar_tag))
		bar = image('icons/effects/progressbar.dmi', target, "prog_bar_[bar_tag]_0", HUD_LAYER)
		bar.plane = ABOVE_HUD_PLANE
		bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	user = U
	if(user)
		client = user.client

	if(bar)
		LAZYINITLIST(user.progressbars)
		LAZYINITLIST(user.progressbars[bar.loc])
		var/list/bars = user.progressbars[bar.loc]
		bars.Add(src)
		listindex = bars.len
		bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))

	if(!isnull(display_tag))
		display_owner = display_target = TRUE ? target : user
		LAZYINITLIST(display_owner.display_icons)
		if(!LAZYFIND(display_owner.display_icons, display_tag))
			display = image('icons/effects/progressicons.dmi', null, "busy_[display_tag]")
			display.pixel_y = display_icon[3]
			display.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			display.plane = FLY_LAYER
			display_owner.add_overlay(display, TRUE)
			display_owner.display_icons.Add(display_tag)
		display_owner.display_icons[display_tag]++

/datum/progressbar/proc/get_display_target(display_icon)
	return

/datum/progressbar/proc/update(progress)
	if (!user?.client)
		shown = FALSE
		return
	if (user.client != client)
		client?.images -= bar
		user.client?.images += bar

	progress = CLAMP(progress, 0, goal)
	bar.icon_state = "prog_bar_[bar_tag]_[round(((progress / goal) * 100), 5)]"
	if (!shown)
		user.client.images += bar
		shown = TRUE

/datum/progressbar/proc/shiftDown()
	--listindex
	bar.pixel_y -= PROGRESSBAR_HEIGHT

/datum/progressbar/Destroy()
	for(var/I in user.progressbars[bar.loc])
		var/datum/progressbar/P = I
		if(P != src && P.listindex > listindex)
			P.shiftDown()

	var/list/bars = user.progressbars[bar.loc]
	bars.Remove(src)
	if(!bars.len)
		LAZYREMOVE(user.progressbars, bar.loc)

	client?.images -= bar
	qdel(bar)

	if(display)
		if(QDELETED(display_owner))
			qdel(display)
			return ..()
		display_owner.display_icons[display_target]--
		if(display_owner.display_icons[display_target] <= 0)
			display_owner.cut_overlay(display, TRUE)
			qdel(display)

	return ..()

#undef PROGRESSBAR_HEIGHT