/*
Usage:
- Define mouse event procs on your (probably HUD) object and simply call the show and hide procs respectively:
	/atom/movable/screen/hud
		MouseEntered(location, control, params)
			usr.client.tooltip.show(params, title = src.name, content = src.desc)

		MouseExited()
			usr.client.tooltip.hide()

Customization:
- Theming can be done by passing the theme var to show() and using css in the html file to change the look
- For your convenience some pre-made themes are included

Notes:
- You may have noticed 90% of the work is done via javascript on the client. Gotta save those cycles man.
*/


/datum/tooltip
	var/client/owner
	var/control = "mainwindow.tooltip"
	var/showing = FALSE
	var/queueHide = FALSE
	var/init = FALSE
	var/atom/last_target


/datum/tooltip/New(client/C)
	if (C)
		owner = C
		var/datum/asset/stuff = get_asset_datum(/datum/asset/simple/jquery)
		stuff.send(owner)
		owner << browse(file2text('code/modules/tooltip/tooltip.html'), "window=[control]")

	..()


/datum/tooltip/proc/show(atom/movable/thing, params = null, title = null, content = null, theme = "default", special = "none")
	if (!thing || !params || (!title && !content) || !owner || !isnum(world.icon_size))
		return FALSE

	if (!isnull(last_target))
		UnregisterSignal(last_target, COMSIG_QDELETING)

	RegisterSignal(thing, COMSIG_QDELETING, PROC_REF(on_target_qdel))

	last_target = thing

	if (!init)
		//Initialize some vars
		init = TRUE
		owner << output(list2params(list(world.icon_size, control)), "[control]:tooltip.init")

	showing = TRUE

	if (title && content)
		title = "<h1>[title]</h1>"
		content = "<p>[content]</p>"
	else if (title && !content)
		title = "<p>[title]</p>"
	else if (!title && content)
		content = "<p>[content]</p>"

	// Strip macros from item names
	title = replacetext(title, "\proper", "")
	title = replacetext(title, "\improper", "")

	//Make our dumb param object
	params = {"{ "cursor": "[params]", "screenLoc": "[thing.screen_loc]" }"}

	//Send stuff to the tooltip
	var/view_size = getviewsize(owner.view)
	owner << output(list2params(list(params, view_size[1] , view_size[2], "[title][content]", theme, special)), "[control]:tooltip.update")

	//If a hide() was hit while we were showing, run hide() again to avoid stuck tooltips
	showing = FALSE
	if (queueHide)
		hide()

	return TRUE


/datum/tooltip/proc/hide()
	queueHide = showing ? TRUE : FALSE

	if (queueHide)
		addtimer(CALLBACK(src, PROC_REF(do_hide)), 0.1 SECONDS)
	else
		do_hide()

	return TRUE

/datum/tooltip/proc/on_target_qdel()
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(hide))
	last_target = null

/datum/tooltip/proc/do_hide()
	winshow(owner, control, FALSE)

/datum/tooltip/Destroy(force)
	last_target = null
	return ..()

//Open a tooltip for user, at a location based on params
//Theme is a CSS class in tooltip.html, by default this wrapper chooses a CSS class based on the user's UI_style (Midnight, Plasmafire, Retro, etc)
//Includes sanity.checks
/proc/openToolTip(mob/user = null, atom/movable/tip_src = null, params = null, title = "", content = "", theme = "")
	if(!istype(user) || !user.client?.tooltips)
		return
	if(!theme && user.client?.prefs?.ui_style)
		theme = lowertext(user.client.prefs.ui_style)
	if(!theme)
		theme = "default"
	user.client.tooltips.show(tip_src, params, title, content, theme)


//Arbitrarily close a user's tooltip
//Includes sanity checks.
/proc/closeToolTip(mob/user)
	if(!istype(user) || !user.client?.tooltips)
		return
	user.client.tooltips.hide()


