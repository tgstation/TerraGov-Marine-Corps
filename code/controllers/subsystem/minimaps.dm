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
 * There is a byond bug to be aware of when working with minimaps, see [/datum/hud_displays] and http://www.byond.com/forum/post/2661309
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
	///Nonassoc list of targets we want to be stripped of their overlays during the SS fire
	var/list/atom/update_targets_unsorted = list()
	///Assoc list of removal callbacks to invoke to remove images from the raw lists
	var/list/datum/callback/removal_cbs = list()
	///list of holders for data relating to tracked zlevel and tracked atum
	var/list/datum/minimap_updator/updators_by_datum = list()
	///list of callbacks we need to invoke late because Initialize happens early
	var/list/datum/callback/earlyadds = list()
	///assoc list of minimap objects that are hashed so we have to update as few as possible
	var/list/hashed_minimaps = list()

/datum/controller/subsystem/minimaps/Initialize(start_timeofday)
	for(var/level=1 to length(SSmapping.z_list))
		minimaps_by_z["[level]"] = new /datum/hud_displays
		if(!is_mainship_level(level) && !is_ground_level(level))
			continue
		var/icon/icon_gen = new('icons/UI_icons/minimap.dmi') //480x480 blank icon template for drawing on the map
		for(var/xval = 1 to world.maxx)
			for(var/yval = 1 to world.maxy) //Scan all the turfs and draw as needed
				var/turf/location = locate(xval,yval,level)
				if(isspaceturf(location))
					continue
				if(location.density)
					icon_gen.DrawBox(location.minimap_color, xval, yval)
					continue
				var/atom/movable/alttarget = locate(/obj/machinery/door) in location||locate(/obj/structure/fence) in location
				if(alttarget)
					icon_gen.DrawBox(alttarget.minimap_color, xval, yval)
					continue
				var/area/turfloc = location.loc
				icon_gen.DrawBox(turfloc.minimap_color, xval, yval)
		icon_gen.Scale(480*2,480*2) //scale it up x2 to make it easer to see
		icon_gen.Crop(1, 1, min(icon_gen.Width(), 480), min(icon_gen.Height(), 480)) //then cut all the empty pixels

		//generation is done, now we need to center the icon to someones view, this can be left out if you like it ugly and will halve SSinit time
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

	initialized = TRUE

	for(var/i=1 to length(earlyadds)) //lateload icons
		earlyadds[i].Invoke()
	earlyadds = null //then clear them
	return ..()

/datum/controller/subsystem/minimaps/stat_entry(msg)
	msg = "Upd:[length(update_targets_unsorted)] Mark: [length(removal_cbs)]"
	return ..()

/datum/controller/subsystem/minimaps/Recover()
	minimaps_by_z = SSminimaps.minimaps_by_z
	images_by_source = SSminimaps.images_by_source
	update_targets = SSminimaps.update_targets
	update_targets_unsorted = SSminimaps.update_targets_unsorted
	removal_cbs = SSminimaps.removal_cbs
	updators_by_datum = SSminimaps.updators_by_datum

/datum/controller/subsystem/minimaps/fire(resumed)
	var/static/iteration = 0
	if(!iteration) //on first iteration clear all overlays
		for(var/iter=1 to length(update_targets_unsorted))
			update_targets_unsorted[iter].overlays.Cut() //clear all the old overlays, no we cant cache it because they wont update
	//checks last fired flag to make sure under high load that things are performed in stages
	var/depthcount = 0
	for(var/flag in update_targets)
		if(depthcount < iteration) //under high load update in chunks
			depthcount++
			continue
		for(var/datum/minimap_updator/updator AS in update_targets[flag])
			updator.minimap.overlays += minimaps_by_z["[updator.ztarget]"].images_raw[flag]
		depthcount++
		iteration++
		if(MC_TICK_CHECK)
			return
	iteration = 0

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
	updators_by_datum[target] = holder
	update_targets_unsorted += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/remove_updator)

/**
 * Removes a atom from the subsystems updating overlays
 */
/datum/controller/subsystem/minimaps/proc/remove_updator(atom/target)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	var/datum/minimap_updator/holder = updators_by_datum[target]
	updators_by_datum -= target
	for(var/key in update_targets)
		LAZYREMOVE(update_targets[key], holder)
	update_targets_unsorted -= target

/**
 * Holder datum for a zlevels data, concerning the overlays and the drawn level itself
 * The individual image trackers have a raw and a normal list
 * raw lists just store the images, while the normal ones are assoc list of [tracked_atom] = image
 * the raw lists are to speed up the Fire() of the subsystem so we dont have to filter through
 * WARNING!
 * There is a byond bug: http://www.byond.com/forum/post/2661309
 * That that forces us to use a seperate list ref when accessing the lists of this datum
 * Yea it hurts me too
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

/datum/minimap_updator/New(minimap, ztarget)
	..()
	src.minimap = minimap
	src.ztarget = ztarget

/**
 * Adds an atom we want to track with blips to the subsystem
 * Arguments:
 * * target: atom we want to track
 * * zlevel: zlevel we want this atom to be tracked for
 * * hud_flags: tracked HUDs we want this atom to be displayed on
 * * iconstate: iconstate for the blip we want to be used for this tracked atom
 * * icon: icon file we want to use for this blip, 'icons/UI_icons/map_blips.dmi' by default
 * * overlay_iconstates: list of iconstates to use as overlay. Used for xeno leader icons.
 */
/datum/controller/subsystem/minimaps/proc/add_marker(atom/target, zlevel, hud_flags = NONE, iconstate, icon = 'icons/UI_icons/map_blips.dmi', list/overlay_iconstates)
	if(!isatom(target) || !zlevel || !hud_flags || !iconstate || !icon)
		CRASH("Invalid marker added to subsystem")
	if(!initialized)
		earlyadds += CALLBACK(src, .proc/add_marker, target, zlevel, hud_flags, iconstate, icon)
		return

	var/image/blip = image(icon, iconstate, pixel_x = MINIMAP_PIXEL_FROM_WORLD(target.x) + minimaps_by_z["[zlevel]"].x_offset, pixel_y = MINIMAP_PIXEL_FROM_WORLD(target.y) + minimaps_by_z["[zlevel]"].y_offset)

	for(var/i in overlay_iconstates)
		blip.overlays += image(icon, i)

	images_by_source[target] = blip
	for(var/flag in bitfield2list(hud_flags))
		minimaps_by_z["[zlevel]"].images_assoc["[flag]"][target] = blip
		var/ref = minimaps_by_z["[zlevel]"].images_raw["[flag]"] //what the fuck? you might be thinking, yea well this is a byond bug thanks
		ref += blip //workaround see http://www.byond.com/forum/post/2661309
	if(ismovableatom(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/on_z_change)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_move)
	removal_cbs[target] = CALLBACK(src, .proc/removeimage, blip, target)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/remove_marker)



/**
 * removes an image from raw tracked lists, invoked by callback
 */
/datum/controller/subsystem/minimaps/proc/removeimage(image/blip, atom/target)
	for(var/flag in GLOB.all_minimap_flags)
		var/ref = minimaps_by_z["[target.z]"].images_raw["[flag]"]
		ref -= blip // see above http://www.byond.com/forum/post/2661309
	removal_cbs -= target

/**
 * Called on zlevel change of a blip-atom so we can update the image lists as needed
 */
/datum/controller/subsystem/minimaps/proc/on_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	for(var/flag in GLOB.all_minimap_flags)
		if(!minimaps_by_z["[oldz]"]?.images_assoc["[flag]"][source])
			continue
		//see previous byond bug comments http://www.byond.com/forum/post/2661309
		var/ref_old = minimaps_by_z["[oldz]"].images_assoc["[flag]"][source]
		minimaps_by_z["[newz]"].images_assoc["[flag]"][source] = ref_old
		var/rawold = minimaps_by_z["[oldz]"].images_raw["[flag]"]
		var/rawnew = minimaps_by_z["[newz]"].images_raw["[flag]"]
		rawold -= ref_old
		rawnew += ref_old
		var/anotherref = minimaps_by_z["[oldz]"].images_assoc["[flag]"]
		anotherref -= source

/**
 * Simple proc, updates overlay position on the map when a atom moves
 */
/datum/controller/subsystem/minimaps/proc/on_move(atom/movable/source, oldloc)
	SIGNAL_HANDLER
	if(!source.z)
		return //this can happen legitimately when you go into pipes, it shouldnt but thats how it is
	images_by_source[source].pixel_x = MINIMAP_PIXEL_FROM_WORLD(source.x) + minimaps_by_z["[source.z]"].x_offset
	images_by_source[source].pixel_y = MINIMAP_PIXEL_FROM_WORLD(source.y) + minimaps_by_z["[source.z]"].y_offset

/**
 * Removes an atom and it's blip from the subsystem
 */
/datum/controller/subsystem/minimaps/proc/remove_marker(atom/source)
	SIGNAL_HANDLER
	if(!removal_cbs[source]) //already removed
		return
	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED))
	for(var/flag in GLOB.all_minimap_flags)
		var/ref = minimaps_by_z["[source.z]"].images_assoc["[flag]"]
		ref -=  source //see above
	images_by_source -= source
	removal_cbs[source].Invoke()
	removal_cbs -= source


/**
 * Fetches a /obj/screen/minimap instance or creates on if none exists
 * Note this does not destroy them when the map is unused, might be a potential thing to do?
 * Arguments:
 * * zlevel: zlevel to fetch map for
 * * flags: map flags to fetch from
 */
/datum/controller/subsystem/minimaps/proc/fetch_minimap_object(zlevel, flags)
	var/hash = "[zlevel]-[flags]"
	if(hashed_minimaps[hash])
		return hashed_minimaps[hash]
	var/obj/screen/minimap/map = new(null, zlevel, flags)
	if (!map.icon) //Don't wanna save an unusable minimap for a z-level.
		CRASH("Empty and unusable minimap generated for '[zlevel]-[flags]'") //Can be caused by atoms calling this proc before minimap subsystem initializing.
	hashed_minimaps[hash] = map
	return map

///Default HUD screen minimap object
/obj/screen/minimap
	name = "Minimap"
	icon = null
	icon_state = ""
	layer = ABOVE_HUD_LAYER
	screen_loc = "1,1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/minimap/Initialize(mapload, target, flags)
	. = ..()
	if(!SSminimaps.minimaps_by_z["[target]"])
		return
	icon = SSminimaps.minimaps_by_z["[target]"].hud_image
	SSminimaps.add_to_updaters(src, flags, target)


/**
 * Action that gives the owner access to the minimap pool
 */
/datum/action/minimap
	name = "Toggle Minimap"
	action_icon_state = "minimap"
	///Flags to allow the owner to see others of this type
	var/minimap_flags = MINIMAP_FLAG_ALL
	///marker flags this will give the target, mostly used for marine minimaps
	var/marker_flags = MINIMAP_FLAG_ALL
	///boolean as to whether the minimap is currently shown
	var/minimap_displayed = FALSE
	///Minimap object we'll be displaying
	var/obj/screen/minimap/map
	///This is mostly for the AI & other things which do not move groundside.
	var/default_overwatch_level = 0

/datum/action/minimap/Destroy()
	map = null
	return ..()

/datum/action/minimap/action_activate()
	. = ..()
	if(!map)
		return
	if(minimap_displayed)
		owner.client.screen -= map
	else
		owner.client.screen += map
	minimap_displayed = !minimap_displayed

/datum/action/minimap/give_action(mob/M)
	. = ..()

	if(default_overwatch_level)
		map = SSminimaps.fetch_minimap_object(default_overwatch_level, minimap_flags)
	else
		RegisterSignal(M, COMSIG_MOVABLE_Z_CHANGED, .proc/on_owner_z_change)
	RegisterSignal(M, COMSIG_KB_TOGGLE_MINIMAP, .proc/action_activate)
	if(!SSminimaps.minimaps_by_z["[M.z]"] || !SSminimaps.minimaps_by_z["[M.z]"].hud_image)
		return
	map = SSminimaps.fetch_minimap_object(M.z, minimap_flags)

/datum/action/minimap/remove_action(mob/M)
	. = ..()
	if(minimap_displayed)
		owner.client.screen -= map
		minimap_displayed = FALSE
	UnregisterSignal(M, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_KB_TOGGLE_MINIMAP))

/**
 * Updates the map when the owner changes zlevel
 */
/datum/action/minimap/proc/on_owner_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	if(minimap_displayed)
		owner.client.screen -= map
		minimap_displayed = FALSE
	map = null
	if(!SSminimaps.minimaps_by_z["[newz]"] || !SSminimaps.minimaps_by_z["[newz]"].hud_image)
		return
	if(default_overwatch_level)
		map = SSminimaps.fetch_minimap_object(default_overwatch_level, minimap_flags)
		return
	map = SSminimaps.fetch_minimap_object(newz, minimap_flags)

/datum/action/minimap/xeno
	minimap_flags = MINIMAP_FLAG_XENO

/datum/action/minimap/researcher
	minimap_flags = MINIMAP_FLAG_MARINE|MINIMAP_FLAG_EXCAVATION_ZONE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/marine
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/ai
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE
	default_overwatch_level = 2

/datum/action/minimap/marine/rebel
	minimap_flags = MINIMAP_FLAG_MARINE_REBEL
	marker_flags = MINIMAP_FLAG_MARINE_REBEL

/datum/action/minimap/som
	minimap_flags = MINIMAP_FLAG_MARINE_SOM
	marker_flags = MINIMAP_FLAG_MARINE_SOM

/datum/action/minimap/observer
	minimap_flags = MINIMAP_FLAG_XENO|MINIMAP_FLAG_MARINE|MINIMAP_FLAG_MARINE_REBEL|MINIMAP_FLAG_MARINE_SOM|MINIMAP_FLAG_EXCAVATION_ZONE
	marker_flags = NONE
