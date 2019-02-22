#define PROGRESSBAR_HEIGHT 6

/datum/progressbar
	var/goal = 1
	var/image/bar
	var/bar_icon
	var/image/display
	var/atom/display_owner
	var/display_icon
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
	bar = image('icons/effects/progressbar.dmi', target, "prog_bar[bar_icon]_0", HUD_LAYER)
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
		display_owner = display_icon[1] == USER_PROG_DISPLAY ? user : target
		var/busy_icon = display_icon[2]
		LAZYINITLIST(display_owner.display_icons)
		if(!LAZYFIND(display_owner.display_icons, busy_icon))
			display = image('icons/effects/progressicons.dmi', null, busy_icon)
			display.pixel_y = display_icon[3]
			display.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
			display.plane = FLY_LAYER
			display_owner.add_overlay(display, TRUE)
			display_owner.display_icons.Add(busy_icon)
		display_owner.display_icons[busy_icon]++

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

	if(display)
		if(QDELETED(display_owner))
			qdel(display)
			return ..()
		var/busy_icon = display_icon[2]
		display_owner.display_icons[busy_icon]--
		if(!display_owner.display_icons[busy_icon])
			display_owner.cut_overlay(display, TRUE)
			qdel(display)

	return ..()

#undef PROGRESSBAR_HEIGHT