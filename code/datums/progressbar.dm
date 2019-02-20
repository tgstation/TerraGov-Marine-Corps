#define PROGRESSBAR_HEIGHT 6

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/bar_icon
	var/image/display
	var/display_icon
	var/atom/display_owner
	var/shown = 0
	var/mob/user
	var/client/client
	var/listindex

/datum/progressbar/New(mob/User, goal_number, atom/target, bar_var, display_var)
	. = ..()
	if (!istype(target))
		EXCEPTION("Invalid target given")
	if (goal_number)
		goal = goal_number
	bar_icon = bar_var
	bar = image('icons/effects/progessbar.dmi', target, "prog_bar[bar_icon]_0", HUD_LAYER)
	bar.plane = ABOVE_HUD_PLANE
	bar.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	user = User
	if(user)
		client = user.client

	LAZYINITLIST(user.progressbars)
	LAZYINITLIST(user.progressbars[bar.loc])
	var/list/bars = user.progressbars[bar.loc]
	bars.Add(src)
	listindex = bars.len
	bar.pixel_y = 32 + (PROGRESSBAR_HEIGHT * (listindex - 1))

	display_icon = display_var
	if(display_icon)
		display_owner = get_display_target(display_icon)
		LAZYINITLIST(user.busy_icons)
		LAZYINITLIST(user.busy_icons[display_owner])
		var/list/displays = user.busy_icons[display_owner]
		if(!displays.Find(display_icon))
			display = image('icons/effects/progessbar.dmi', display_owner, display_icon)
			display.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			display.plane = FLY_LAYER
			display_owner.add_overlay(display, TRUE)
			displays.Add(display_icon)
		else
			displays[display_icon]++

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
	bar.icon_state = "prog_bar[bar_icon]_[round(((progress / goal) * 100), 5)]"
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

	if(display_icon)
		var/displays = user.busy_icons[display_owner]
		for(var/I in displays)
			if(I == display_icon)
				displays[I]--
			if(!displays[I])
				display_owner.cut_overlay(I, TRUE)

	return ..()

#undef PROGRESSBAR_HEIGHT