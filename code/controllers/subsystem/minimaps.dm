/**
 *  # Minimaps subsystem
 *
 * Handles updating and handling of the by-zlevel minimaps
 *
 * Minimaps are a low priority subsystem that fires relatively often
 * the Initialize proc for this subsystem draws the maps as one of the last initializing subsystems
 *
 * Fire() for this subsystem doens't actually updates anything, and purely just reapplies the overlays that it already tracks
 * actual updating of marker locations is handled by [/datum/controller/subsystem/minimaps/proc/on_move]
 * and zlevel changes are handled in [/datum/controller/subsystem/minimaps/proc/on_z_change]
 * tracking of the actual atoms you want to be drawn on is done by means of datums holding info pertaining to them with [/datum/hud_displays]
 *
 * Todo
 * *: add fetching of images to allow stuff like adding/removing xeno crowns easily
 * *: add a system for viscontents so things like minimap draw are more responsive
 */
SUBSYSTEM_DEF(minimaps)
	name = "Minimaps"
	init_order = INIT_ORDER_MINIMAPS
	priority = FIRE_PRIORITY_MINIMAPS
	wait = 10
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	///Minimap hud display datums sorted by zlevel
	var/list/datum/hud_displays/minimaps_by_z = list()
	///Assoc list of images we hold by their source
	var/list/image/images_by_source = list()
	///the update target datums, sorted by update flag type
	var/list/update_targets = list()
	///Nonassoc list of updators we want to have their overlays reapplied
	var/list/datum/minimap_updator/update_targets_unsorted = list()
	///Assoc list of removal callbacks to invoke to remove images from the raw lists
	var/list/datum/callback/removal_cbs = list()
	///list of holders for data relating to tracked zlevel and tracked atum
	var/list/datum/minimap_updator/updators_by_datum = list()
	///assoc list of hash = image of images drawn by players
	var/list/image/drawn_images = list()
	///list of callbacks we need to invoke late because Initialize happens early, or a Z-level was loaded after init
	var/list/list/datum/callback/earlyadds = list()
	///assoc list of minimap objects that are hashed so we have to update as few as possible
	var/list/hashed_minimaps = list()

/datum/controller/subsystem/minimaps/Initialize()
	for(var/datum/space_level/z_level AS in SSmapping.z_list)
		load_new_z(null, z_level)
	//RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(load_new_z))

	initialized = TRUE

	return SS_INIT_SUCCESS

/datum/controller/subsystem/minimaps/stat_entry(msg)
	msg = "Upd:[length(update_targets_unsorted)] Mark:[length(removal_cbs)]"
	return ..()

/datum/controller/subsystem/minimaps/Recover()
	minimaps_by_z = SSminimaps.minimaps_by_z
	images_by_source = SSminimaps.images_by_source
	update_targets = SSminimaps.update_targets
	update_targets_unsorted = SSminimaps.update_targets_unsorted
	removal_cbs = SSminimaps.removal_cbs
	updators_by_datum = SSminimaps.updators_by_datum
	drawn_images = SSminimaps.drawn_images

/datum/controller/subsystem/minimaps/fire(resumed)
	var/static/iteration = 0
	var/depthcount = 0
	for(var/datum/minimap_updator/updator AS in update_targets_unsorted)
		if(depthcount < iteration) //under high load update in chunks
			depthcount++
			continue
		updator.minimap.overlays = updator.raw_blips
		depthcount++
		iteration++
		if(MC_TICK_CHECK)
			return
	iteration = 0

///Creates a minimap for a particular z level
/datum/controller/subsystem/minimaps/proc/load_new_z(datum/dcs, datum/space_level/z_level)
	SIGNAL_HANDLER

	var/level = z_level.z_value
	minimaps_by_z["[level]"] = new /datum/hud_displays
	if(!is_mainship_level(level) && !is_ground_level(level) && !is_away_level(level)) //todo: maybe move this around
		return
	var/icon/icon_gen = new('icons/UI_icons/minimap.dmi') //480x480 blank icon template for drawing on the map
	for(var/xval = 1 to world.maxx)
		for(var/yval = 1 to world.maxy) //Scan all the turfs and draw as needed
			var/turf/location = locate(xval,yval,level)
			if(isspaceturf(location))
				continue
			if(location.density)
				icon_gen.DrawBox(location.minimap_color, xval, yval)
				continue
			var/atom/movable/alttarget = (locate(/obj/machinery/door) in location) || (locate(/obj/structure/fence) in location)
			if(alttarget)
				icon_gen.DrawBox(alttarget.minimap_color, xval, yval)
				continue
			var/area/turfloc = location.loc
			if(turfloc.minimap_color)
				icon_gen.DrawBox(BlendRGB(location.minimap_color, turfloc.minimap_color, 0.5), xval, yval)
				continue
			icon_gen.DrawBox(location.minimap_color, xval, yval)
	icon_gen.Scale(480*2,480*2) //scale it up x2 to make it easer to see
	icon_gen.Crop(1, 1, min(icon_gen.Width(), 480), min(icon_gen.Height(), 480)) //then cut all the empty pixels

	//generation is done, now we need to center the icon to someones view,
	//this can be left out if you like it ugly and will halve SSinit time

	//calculate the offset of the icon
	var/largest_x = 0
	var/smallest_x = SCREEN_PIXEL_SIZE
	var/largest_y = 0
	var/smallest_y = SCREEN_PIXEL_SIZE
	for(var/xval=1 to SCREEN_PIXEL_SIZE step 2) //step 2 is twice as fast :)
		for(var/yval=1 to SCREEN_PIXEL_SIZE step 2) //keep in mind 1 wide giant straight lines will offset wierd but you shouldnt be mapping those anyway right???
			if(!icon_gen.GetPixel(xval, yval))
				continue
			if(xval > largest_x)
				largest_x = xval
			else if(xval < smallest_x)
				smallest_x = xval
			if(yval > largest_y)
				largest_y = yval
			else if(yval < smallest_y)
				smallest_y = yval

	minimaps_by_z["[level]"].x_offset = FLOOR((SCREEN_PIXEL_SIZE-largest_x-smallest_x)/2, 1)
	minimaps_by_z["[level]"].y_offset = FLOOR((SCREEN_PIXEL_SIZE-largest_y-smallest_y)/2, 1)

	icon_gen.Shift(EAST, minimaps_by_z["[level]"].x_offset)
	icon_gen.Shift(NORTH, minimaps_by_z["[level]"].y_offset)

	minimaps_by_z["[level]"].hud_image = icon_gen //done making the image!

	//lateload icons
	if(!earlyadds["[level]"])
		return

	for(var/datum/callback/callback AS in earlyadds["[level]"])
		callback.Invoke()
	earlyadds["[level]"] = null //then clear them

/**
 * Adds an atom to the processing updators that will have blips drawn on them
 * Arguments:
 * * target: the target we want to be updating the overlays on
 * * flags: flags for the types of blips we want to be updated
 * * ztarget: zlevel we want to be updated with
 */
/datum/controller/subsystem/minimaps/proc/add_to_updaters(atom/target, flags, ztarget)
	var/datum/minimap_updator/holder = new(target, ztarget)
	for(var/flag in bitfield2list(flags))
		LAZYADD(update_targets["[flag]"], holder)
		holder.raw_blips += minimaps_by_z["[ztarget]"].images_raw["[flag]"]
	updators_by_datum[target] = holder
	update_targets_unsorted += holder
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_updator))

/**
 * Removes a atom from the subsystems updating overlays
 */
/datum/controller/subsystem/minimaps/proc/remove_updator(atom/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_QDELETING)
	var/datum/minimap_updator/holder = updators_by_datum[target]
	updators_by_datum -= target
	for(var/key in update_targets)
		LAZYREMOVE(update_targets[key], holder)
	update_targets_unsorted -= holder

/**
 * Holder datum for a zlevels data, concerning the overlays and the drawn level itself
 * The individual image trackers have a raw and a normal list
 * raw lists just store the images, while the normal ones are assoc list of [tracked_atom] = image
 * the raw lists are to speed up the Fire() of the subsystem so we dont have to filter through
 */
/datum/hud_displays
	///Actual icon of the drawn zlevel with all of it's atoms
	var/icon/hud_image
	///Assoc list of updating images; list("[flag]" = list([source] = blip)
	var/list/images_assoc = list()
	///Raw list containing updating images by flag; list("[flag]" = list(blip))
	var/list/images_raw = list()
	///x offset of the actual icon to center it to screens
	var/x_offset = 0
	///y offset of the actual icons to keep it to screens
	var/y_offset = 0

/datum/hud_displays/New()
	..()
	for(var/flag in GLOB.all_minimap_flags)
		images_assoc["[flag]"] = list()
		images_raw["[flag]"] = list()

/**
 * Holder datum to ease updating of atoms to update
 */
/datum/minimap_updator
	/// Atom to update with the overlays
	var/atom/minimap
	///Target zlevel we want to be updating to
	var/ztarget = 0
	/// list of overlays we update
	var/raw_blips

/datum/minimap_updator/New(minimap, ztarget)
	..()
	src.minimap = minimap
	src.ztarget = ztarget
	raw_blips = list()

/**
 * Adds an atom we want to track with blips to the subsystem
 * Arguments:
 * * target: atom we want to track
 * * hud_flags: tracked HUDs we want this atom to be displayed on
 * * marker: image or mutable_appearance we want to be using on the map
 */
/datum/controller/subsystem/minimaps/proc/add_marker(atom/target, hud_flags = NONE, image/blip)
	if(!isatom(target) || !hud_flags || !blip)
		CRASH("Invalid marker added to subsystem")

	if(!initialized || !(minimaps_by_z["[target.z]"])) //the minimap doesn't exist yet, z level was probably loaded after init
		for(var/datum/callback/callback AS in earlyadds["[target.z]"])
			if(callback.arguments[1] == target)
				return
		LAZYADDASSOC(earlyadds, "[target.z]", CALLBACK(src, PROC_REF(add_marker), target, hud_flags, blip))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_earlyadd), override = TRUE) //Override required for late z-level loading to prevent hard dels where an atom is initiated during z load, but is qdel'd before it finishes
		return

	var/turf/target_turf = get_turf(target)

	blip.pixel_x = MINIMAP_PIXEL_FROM_WORLD(target_turf.x) + minimaps_by_z["[target_turf.z]"].x_offset
	blip.pixel_y = MINIMAP_PIXEL_FROM_WORLD(target_turf.y) + minimaps_by_z["[target_turf.z]"].y_offset

	images_by_source[target] = blip
	for(var/flag in bitfield2list(hud_flags))
		minimaps_by_z["[target_turf.z]"].images_assoc["[flag]"][target] = blip
		minimaps_by_z["[target_turf.z]"].images_raw["[flag]"] += blip
		for(var/datum/minimap_updator/updator AS in update_targets["[flag]"])
			if(target_turf.z == updator.ztarget)
				updator.raw_blips += blip
	if(ismovableatom(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_z_change))
		blip.RegisterSignal(target, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/image, minimap_on_move))
	removal_cbs[target] = CALLBACK(src, PROC_REF(removeimage), blip, target, hud_flags)
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(remove_marker), override = TRUE) //override for atoms that were on a late loaded z-level, overrides the remove_earlyadd above

///Removes the object from the earlyadds list, in case it was qdel'd before the z-level was fully loaded
/datum/controller/subsystem/minimaps/proc/remove_earlyadd(atom/source)
	SIGNAL_HANDLER
	remove_marker(source)
	for(var/datum/callback/callback in earlyadds["[source.z]"])
		if(callback.arguments[1] != source)
			continue
		earlyadds["[source.z]"] -= callback
		UnregisterSignal(source, COMSIG_QDELETING)
		return

/**
 * removes an image from raw tracked lists, invoked by callback
 */
/datum/controller/subsystem/minimaps/proc/removeimage(image/blip, atom/target, hud_flags)
	var/turf/target_turf = get_turf(target)
	for(var/flag in bitfield2list(hud_flags))
		minimaps_by_z["[target_turf.z]"].images_raw["[flag]"] -= blip
		for(var/datum/minimap_updator/updator AS in update_targets["[flag]"])
			if(updator.ztarget == target_turf.z)
				updator.raw_blips -= blip
	blip.UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	removal_cbs -= target

/**
 * Called on zlevel change of a blip-atom so we can update the image lists as needed
 *
 * TODO gross amount of assoc usage and unneeded ALL FLAGS iteration
 */
/datum/controller/subsystem/minimaps/proc/on_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	var/image/blip
	for(var/flag in GLOB.all_minimap_flags)
		if(!minimaps_by_z["[oldz]"]?.images_assoc["[flag]"][source])
			continue
		if(!blip)
			blip = minimaps_by_z["[oldz]"].images_assoc["[flag]"][source]
		// todo maybe make update_targets also sort by zlevel?
		for(var/datum/minimap_updator/updator AS in update_targets["[flag]"])
			if(updator.ztarget == oldz)
				updator.raw_blips -= blip
			else if(updator.ztarget == newz)
				updator.raw_blips += blip
		minimaps_by_z["[newz]"].images_assoc["[flag]"][source] = blip
		minimaps_by_z["[oldz]"].images_assoc["[flag]"] -= source

		minimaps_by_z["[newz]"].images_raw["[flag]"] += blip
		minimaps_by_z["[oldz]"].images_raw["[flag]"] -= blip

/**
 * Simple proc, updates overlay position on the map when a atom moves
 */
/image/proc/minimap_on_move(atom/movable/source, oldloc)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		pixel_x = MINIMAP_PIXEL_FROM_WORLD(source.x) + SSminimaps.minimaps_by_z["[source.z]"].x_offset
		pixel_y = MINIMAP_PIXEL_FROM_WORLD(source.y) + SSminimaps.minimaps_by_z["[source.z]"].y_offset
		return

	var/atom/movable/movable_loc = source.loc
	source.override_minimap_tracking(source.loc)
	pixel_x = MINIMAP_PIXEL_FROM_WORLD(movable_loc.x) + SSminimaps.minimaps_by_z["[movable_loc.z]"].x_offset
	pixel_y = MINIMAP_PIXEL_FROM_WORLD(movable_loc.y) + SSminimaps.minimaps_by_z["[movable_loc.z]"].y_offset

///Used to handle minimap tracking inside other movables
/atom/movable/proc/override_minimap_tracking(atom/movable/loc)
	var/image/blip = SSminimaps.images_by_source[src]
	blip.RegisterSignal(loc, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/image, minimap_on_move))
	RegisterSignal(loc, COMSIG_ATOM_EXITED, PROC_REF(cancel_override_minimap_tracking))

///Stops minimap override tracking
/atom/movable/proc/cancel_override_minimap_tracking(atom/movable/source, atom/movable/mover)
	SIGNAL_HANDLER
	if(mover != src)
		return
	var/image/blip = SSminimaps.images_by_source[src]
	blip.UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(source, COMSIG_ATOM_EXITED)


/**
 * Removes an atom and it's blip from the subsystem
 */
/datum/controller/subsystem/minimaps/proc/remove_marker(atom/source)
	SIGNAL_HANDLER
	if(!removal_cbs[source]) //already removed
		return
	UnregisterSignal(source, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED))
	var/turf/source_turf = get_turf(source)
	for(var/flag in GLOB.all_minimap_flags)
		minimaps_by_z["[source_turf.z]"].images_assoc["[flag]"] -= source
	images_by_source -= source
	removal_cbs[source].Invoke()
	removal_cbs -= source


/**
 * Fetches a /atom/movable/screen/minimap instance or creates on if none exists
 * Note this does not destroy them when the map is unused, might be a potential thing to do?
 * Arguments:
 * * zlevel: zlevel to fetch map for
 * * flags: map flags to fetch from
 */
/datum/controller/subsystem/minimaps/proc/fetch_minimap_object(zlevel, flags)
	var/hash = "[zlevel]-[flags]"
	if(hashed_minimaps[hash])
		return hashed_minimaps[hash]
	var/atom/movable/screen/minimap/map = new(null, zlevel, flags)
	if (!map.icon) //Don't wanna save an unusable minimap for a z-level.
		CRASH("Empty and unusable minimap generated for '[zlevel]-[flags]'") //Can be caused by atoms calling this proc before minimap subsystem initializing.
	hashed_minimaps[hash] = map
	return map

///fetches the drawing icon for a minimap flag and returns it, creating it if needed. assumes minimap_flag is ONE flag
/datum/controller/subsystem/minimaps/proc/get_drawing_image(zlevel, minimap_flag)
	var/hash = "[zlevel]-[minimap_flag]"
	if(drawn_images[hash])
		return drawn_images[hash]
	var/image/blip = new // could use MA but yolo
	blip.icon = icon('icons/UI_icons/minimap.dmi')
	minimaps_by_z["[zlevel]"].images_raw["[minimap_flag]"] += blip
	drawn_images[hash] = blip
	return blip

///Default HUD screen minimap object
/atom/movable/screen/minimap
	name = "Minimap"
	icon = null
	icon_state = ""
	layer = ABOVE_HUD_LAYER
	screen_loc = "1,1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///assoc list of mob choices by clicking on coords. only exists fleetingly for the wait loop in [/proc/get_coords_from_click]
	var/list/mob/choices_by_mob

/atom/movable/screen/minimap/Initialize(mapload, target, flags)
	. = ..()
	if(!SSminimaps.minimaps_by_z["[target]"])
		return
	choices_by_mob = list()
	icon = SSminimaps.minimaps_by_z["[target]"].hud_image
	SSminimaps.add_to_updaters(src, flags, target)

/atom/movable/screen/minimap/Destroy()
	SSminimaps.hashed_minimaps -= src
	return ..()

/**
 * lets the user get coordinates by clicking the actual map
 * Returns a list(x_coord, y_coord)
 * note: sleeps until the user makes a choice or they disconnect
 */
/atom/movable/screen/minimap/proc/get_coords_from_click(mob/user)
	//lord forgive my shitcode
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	while(!choices_by_mob[user] && user.client)
		stoplag(1)
	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	. = choices_by_mob[user]
	choices_by_mob -= user

/**
 * Handles fetching the targetted coordinates when the mob tries to click on this map
 * does the following:
 * turns map targetted pixel into a list(x, y)
 * gets z level of this map
 * x and y minimap centering is reverted, then the x2 scaling of the map is removed
 * round up to correct if an odd pixel was clicked and make sure its valid
 */
/atom/movable/screen/minimap/proc/on_click(datum/source, atom/A, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	// we only care about absolute coords because the map is fixed to 1,1 so no client stuff
	var/list/pixel_coords = params2screenpixel(modifiers["screen-loc"])
	var/zlevel = SSminimaps.updators_by_datum[src].ztarget
	var/x = (pixel_coords[1] - SSminimaps.minimaps_by_z["[zlevel]"].x_offset) / 2
	var/y = (pixel_coords[2] - SSminimaps.minimaps_by_z["[zlevel]"].y_offset) / 2
	var/c_x = clamp(CEILING(x, 1), 1, world.maxx)
	var/c_y = clamp(CEILING(y, 1), 1, world.maxy)
	choices_by_mob[source] = list(c_x, c_y)
	return COMSIG_MOB_CLICK_CANCELED

/atom/movable/screen/minimap_locator
	name = "You are here"
	icon = 'icons/UI_icons/map_blips.dmi'
	icon_state = "locator"
	layer = INTRO_LAYER // 1 above minimap
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

///updates the screen loc of the locator so that it's on the movers location on the minimap
/atom/movable/screen/minimap_locator/proc/update(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	var/turf/mover_turf = get_turf(mover)
	var/x_coord = mover_turf.x * 2
	var/y_coord = mover_turf.y * 2
	x_coord += SSminimaps.minimaps_by_z["[mover_turf.z]"].x_offset
	y_coord += SSminimaps.minimaps_by_z["[mover_turf.z]"].y_offset
	// + 1 because tiles start at 1
	var/x_tile = FLOOR(x_coord/32, 1) + 1
	// -3 to center the image
	var/x_pixel = x_coord % 32 - 3
	var/y_tile = FLOOR(y_coord/32, 1) + 1
	var/y_pixel = y_coord % 32 - 3
	screen_loc = "[x_tile]:[x_pixel],[y_tile]:[y_pixel]"

/**
 * Action that gives the owner access to the minimap pool
 */
/datum/action/minimap
	name = "Toggle Minimap"
	action_icon_state = "minimap"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_TOGGLE_MINIMAP,
	)
	///Flags to allow the owner to see others of this type
	var/minimap_flags = MINIMAP_FLAG_ALL
	///marker flags this will give the target, mostly used for marine minimaps
	var/marker_flags = MINIMAP_FLAG_ALL
	///boolean as to whether the minimap is currently shown
	var/minimap_displayed = FALSE
	///Minimap object we'll be displaying
	var/atom/movable/screen/minimap/map
	///Overrides what the locator tracks aswell what z the map displays as opposed to always tracking the minimap's owner. Default behavior when null.
	var/atom/movable/locator_override
	///Minimap "You are here" indicator for when it's up
	var/atom/movable/screen/minimap_locator/locator
	///Sets a fixed z level to be tracked by this minimap action instead of being influenced by the owner's / locator override's z level.
	var/default_overwatch_level = 0

/datum/action/minimap/New(Target, new_minimap_flags, new_marker_flags)
	. = ..()
	locator = new
	if(new_minimap_flags)
		minimap_flags = new_minimap_flags
	if(new_marker_flags)
		marker_flags = new_marker_flags

/datum/action/minimap/Destroy()
	map = null
	locator_override = null
	QDEL_NULL(locator)
	return ..()

/datum/action/minimap/action_activate()
	. = ..()
	if(!map)
		return
	if(!locator_override && ismovableatom(owner.loc))
		override_locator(owner.loc)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	if(minimap_displayed)
		owner.client.screen -= map
		owner.client.screen -= locator
		locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
	else
		if(locate(/atom/movable/screen/minimap) in owner.client.screen) //This seems like the most effective way to do this without some wacky code
			to_chat(owner, span_warning("You already have a minimap open!"))
			return
		owner.client.screen += map
		owner.client.screen += locator
		locator.update(tracking)
		locator.RegisterSignal(tracking, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
	minimap_displayed = !minimap_displayed

///Overrides the minimap locator to a given atom
/datum/action/minimap/proc/override_locator(atom/movable/to_track)
	var/atom/movable/tracking = locator_override ? locator_override : owner
	var/atom/movable/new_track = to_track ? to_track : owner
	if(locator_override)
		UnregisterSignal(locator_override, COMSIG_QDELETING)
	if(owner)
		UnregisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED)
	if(!minimap_displayed)
		locator_override = to_track
		if(to_track)
			RegisterSignal(to_track, COMSIG_QDELETING, TYPE_PROC_REF(/datum/action/minimap, clear_locator_override))
			if(owner.loc == to_track)
				RegisterSignal(to_track, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/action/minimap, on_exit_check))
		if(owner)
			RegisterSignal(new_track, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
			var/turf/old_turf = get_turf(tracking)
			if(!old_turf.z || old_turf.z != new_track.z)
				on_owner_z_change(new_track, old_turf.z, new_track.z)
		return
	locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
	locator_override = to_track
	if(to_track)
		RegisterSignal(to_track, COMSIG_QDELETING, TYPE_PROC_REF(/datum/action/minimap, clear_locator_override))
		if(owner.loc == to_track)
			RegisterSignal(to_track, COMSIG_ATOM_EXITED, TYPE_PROC_REF(/datum/action/minimap, on_exit_check))
	RegisterSignal(new_track, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
	var/turf/old_turf = get_turf(tracking)
	if(old_turf.z != new_track.z)
		on_owner_z_change(new_track, old_turf.z, new_track.z)
	locator.RegisterSignal(new_track, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
	locator.update(new_track)

///checks if we should clear override if the owner exits this atom
/datum/action/minimap/proc/on_exit_check(datum/source, atom/movable/mover)
	SIGNAL_HANDLER
	if(mover && mover != owner)
		return
	clear_locator_override()

///CLears the locator override in case the override target is deleted
/datum/action/minimap/proc/clear_locator_override()
	SIGNAL_HANDLER
	UnregisterSignal(locator_override, list(COMSIG_QDELETING, COMSIG_ATOM_EXITED))
	if(owner)
		UnregisterSignal(locator_override, COMSIG_MOVABLE_Z_CHANGED)
		RegisterSignal(owner, COMSIG_MOVABLE_Z_CHANGED)
		var/turf/owner_turf = get_turf(owner)
		if(owner_turf.z != locator_override.z)
			on_owner_z_change(owner, locator_override.z, owner_turf.z)
	if(minimap_displayed)
		locator.UnregisterSignal(locator_override, COMSIG_MOVABLE_MOVED)
		locator.RegisterSignal(owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
		locator.update(owner)
	locator_override = null

/datum/action/minimap/give_action(mob/M)
	. = ..()
	var/atom/movable/tracking = locator_override ? locator_override : M
	RegisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))
	if(default_overwatch_level)
		if(!SSminimaps.minimaps_by_z["[default_overwatch_level]"] || !SSminimaps.minimaps_by_z["[default_overwatch_level]"].hud_image)
			return
		map = SSminimaps.fetch_minimap_object(default_overwatch_level, minimap_flags)
		return
	if(!SSminimaps.minimaps_by_z["[tracking.z]"] || !SSminimaps.minimaps_by_z["[tracking.z]"].hud_image)
		return
	map = SSminimaps.fetch_minimap_object(tracking.z, minimap_flags)

/datum/action/minimap/remove_action(mob/M)
	var/atom/movable/tracking = locator_override ? locator_override : M
	if(minimap_displayed)
		owner.client?.screen -= map
		owner.client?.screen -= locator
		locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
		minimap_displayed = FALSE
	UnregisterSignal(tracking, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/**
 * Updates the map when the owner changes zlevel
 */
/datum/action/minimap/proc/on_owner_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	var/atom/movable/tracking = locator_override ? locator_override : owner
	if(minimap_displayed)
		owner.client?.screen -= map
	map = null
	if(default_overwatch_level)
		if(!SSminimaps.minimaps_by_z["[default_overwatch_level]"] || !SSminimaps.minimaps_by_z["[default_overwatch_level]"].hud_image)
			if(minimap_displayed)
				owner.client?.screen -= locator
				locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
				minimap_displayed = FALSE
			return
		map = SSminimaps.fetch_minimap_object(default_overwatch_level, minimap_flags)
		if(minimap_displayed)
			if(owner.client)
				owner.client.screen += map
			else
				minimap_displayed = FALSE
		return
	if(!SSminimaps.minimaps_by_z["[newz]"] || !SSminimaps.minimaps_by_z["[newz]"].hud_image)
		if(minimap_displayed)
			owner.client?.screen -= locator
			locator.UnregisterSignal(tracking, COMSIG_MOVABLE_MOVED)
			minimap_displayed = FALSE
		return
	map = SSminimaps.fetch_minimap_object(newz, minimap_flags)
	if(minimap_displayed)
		if(owner.client)
			owner.client.screen += map
		else
			minimap_displayed = FALSE



/datum/action/minimap/xeno
	minimap_flags = MINIMAP_FLAG_XENO

/datum/action/minimap/researcher
	minimap_flags = MINIMAP_FLAG_MARINE|MINIMAP_FLAG_EXCAVATION_ZONE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/marine
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/marine/external //Avoids keybind conflicts between inherent mob minimap and bonus minimap from consoles, CAS or similar.
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_TOGGLE_EXTERNAL_MINIMAP,
	)

/datum/action/minimap/marine/external/som
	minimap_flags = MINIMAP_FLAG_MARINE_SOM
	marker_flags = MINIMAP_FLAG_MARINE_SOM

/datum/action/minimap/ai	//I'll keep this as seperate type despite being identical so it's easier if people want to make different aspects different.
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/som
	minimap_flags = MINIMAP_FLAG_MARINE_SOM
	marker_flags = MINIMAP_FLAG_MARINE_SOM

/datum/action/minimap/observer
	minimap_flags = MINIMAP_FLAG_XENO|MINIMAP_FLAG_MARINE|MINIMAP_FLAG_MARINE_SOM|MINIMAP_FLAG_EXCAVATION_ZONE
	marker_flags = NONE
