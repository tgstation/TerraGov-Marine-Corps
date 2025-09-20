/atom/movable/screen/buildmode
	icon = 'icons/misc/buildmode.dmi'
	// If we don't do this, we get occluded by item action buttons
	plane = ABOVE_HUD_PLANE
	mouse_over_pointer = MOUSE_HAND_POINTER

	/// Holder for the build mode datum
	var/datum/buildmode/bd

/atom/movable/screen/buildmode/New(bld)
	bd = bld
	RegisterSignal(bd, COMSIG_QDELETING, PROC_REF(clean_bd))
	return ..()

///Clean the bd var
/atom/movable/screen/buildmode/proc/clean_bd()
	SIGNAL_HANDLER
	bd = null

/atom/movable/screen/buildmode/Destroy()
	bd = null
	return ..()

/atom/movable/screen/buildmode/mode
	name = "Toggle Mode"
	icon_state = "buildmode_basic"
	screen_loc = "NORTH,WEST"

/atom/movable/screen/buildmode/mode/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, LEFT_CLICK))
		bd.toggle_modeswitch()
	else if(LAZYACCESS(modifiers, RIGHT_CLICK))
		bd.mode.change_settings(usr.client)

	update_appearance()
	return TRUE

/atom/movable/screen/buildmode/mode/update_icon_state()
	. = ..()
	icon_state = bd.mode.get_button_iconstate()

/atom/movable/screen/buildmode/help
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"
	name = "Buildmode Help"

/atom/movable/screen/buildmode/help/Click()
	bd.mode.show_help(usr.client)
	return TRUE

/atom/movable/screen/buildmode/bdir
	icon_state = "build"
	screen_loc = "NORTH,WEST+2"
	name = "Change Dir"

///Updates the direction of the buildmode
/atom/movable/screen/buildmode/bdir/proc/update_dir()
	dir = bd.build_dir

/atom/movable/screen/buildmode/bdir/Click()
	bd.toggle_dirswitch()
	update_icon()
	return TRUE

// used to switch between modes
/atom/movable/screen/buildmode/modeswitch
	var/datum/buildmode_mode/modetype

/atom/movable/screen/buildmode/modeswitch/New(bld, mt)
	modetype = mt
	icon_state = "buildmode_[initial(modetype.key)]"
	name = initial(modetype.key)
	return ..(bld)

/atom/movable/screen/buildmode/modeswitch/Click()
	bd.change_mode(modetype)
	return TRUE

// used to switch between dirs
/atom/movable/screen/buildmode/dirswitch
	icon_state = "build"

/atom/movable/screen/buildmode/dirswitch/New(bld, dir)
	src.dir = dir
	name = dir2text(dir)
	return ..(bld)

/atom/movable/screen/buildmode/dirswitch/Click()
	bd.change_dir(dir)
	return TRUE

/atom/movable/screen/buildmode/quit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"
	name = "Quit Buildmode"

/atom/movable/screen/buildmode/quit/Click()
	bd.quit()
	return TRUE

/atom/movable/screen/buildmode/preview_item
	name = "Selected Item"
	icon_state = "template"
	screen_loc = "NORTH,WEST+4"
