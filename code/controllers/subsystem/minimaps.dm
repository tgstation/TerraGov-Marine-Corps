/**
 *  # Minimaps subsystem
 *
 * Handles updating and handling of the by-zlevel minimaps
 *
 * Minimaps are a low priority subsystem that fires relatively often
 * the Initialize proc for this subsystem draws the maps as one of the last initializing subsystems
 *
 * Fire() for this subsystem doens't actually updates anything, and purely just reapplies the overlays that it already tracks
 * actual updating of locations is handled by [/datum/controller/subsystem/minimaps/proc/on_move]
 * and zlevel changes are handled in [/datum/controller/subsystem/minimaps/proc/on_z_change]
 * tracking of the actual atoms you want to be drawn on is done by means of datums holding info pertaining to them with [/datum/hud_displays]
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
	///the update target datums, sorted by update type
	var/list/update_targets = list()
	///Nonassoc list of targets we want to be stripped of their overlays during the SS fire
	var/list/atom/update_targets_unsorted = list()
	///Assoc list of removal callbacks to invoke to remove images from the raw lists
	var/list/datum/callback/removal_cbs = list()
	///list of holders for data relating to tracked zlevel and tracked atum
	var/list/datum/minimap_updator/updators_by_datum = list()
	///list of callbacks we need to invoke late because Initialize happens early
	var/list/datum/callback/earlyadds = list()

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
		icon_gen.Crop(0, 0, MINIMAP_PIXEL_FROM_WORLD(world.maxx), MINIMAP_PIXEL_FROM_WORLD(world.maxy)) //then cut all the empty pixels
		minimaps_by_z["[level]"].hud_image = icon_gen
	initialized = TRUE

	for(var/i=1 to length(earlyadds)) //lateload icons
		earlyadds[i].Invoke()
	earlyadds = null //then clear them
	return ..()

/datum/controller/subsystem/minimaps/Recover()
	minimaps_by_z = SSminimaps.minimaps_by_z
	images_by_source = SSminimaps.images_by_source
	update_targets = SSminimaps.update_targets
	update_targets_unsorted = SSminimaps.update_targets_unsorted
	removal_cbs = SSminimaps.removal_cbs
	updators_by_datum = SSminimaps.updators_by_datum

/datum/controller/subsystem/minimaps/fire(resumed)
	for(var/iter=1 to length(update_targets_unsorted))
		update_targets_unsorted[iter].overlays.Cut() //clear the old overlays, no we cant cache it because they wont update
	for(var/datum/minimap_updator/xenoupdators AS in update_targets[MINIMAP_STRING_XENO])
		xenoupdators.minimap.overlays = minimaps_by_z["[xenoupdators.ztarget]"].xeno_images_raw.Copy()	//special handling for the first one in queue for that speed
	for(var/datum/minimap_updator/marineupdators AS in update_targets[MINIMAP_STRING_MARINE])
		marineupdators.minimap.overlays += minimaps_by_z["[marineupdators.ztarget]"].marine_images_raw
	for(var/datum/minimap_updator/alphaupdators AS in update_targets[MINIMAP_STRING_ALPHA])
		alphaupdators.minimap.overlays += minimaps_by_z["[alphaupdators.ztarget]"].alpha_images_raw
	for(var/datum/minimap_updator/bravoupdators AS in update_targets[MINIMAP_STRING_BRAVO])
		bravoupdators.minimap.overlays += minimaps_by_z["[bravoupdators.ztarget]"].bravo_images_raw
	for(var/datum/minimap_updator/charlieupdators AS in update_targets[MINIMAP_STRING_CHARLIE])
		charlieupdators.minimap.overlays += minimaps_by_z["[charlieupdators.ztarget]"].charlie_images_raw
	for(var/datum/minimap_updator/deltaupdators AS in update_targets[MINIMAP_STRING_DELTA])
		deltaupdators.minimap.overlays += minimaps_by_z["[deltaupdators.ztarget]"].delta_images_raw

/**
 * Adds an atom to the processing updators that will have blips drawn on them
 * Arguments:
 * * target: the target we want to be updating the overlays on
 * * flags: flags for the types of blips we want to be updated
 * * ztarget: zlevel we want to be updated with
 */
/datum/controller/subsystem/minimaps/proc/add_to_updaters(atom/target, flags, ztarget)
	var/datum/minimap_updator/holder = new(target, ztarget)
	if(flags & MINIMAP_FLAG_XENO)
		LAZYADD(update_targets[MINIMAP_STRING_XENO], holder)
	if(flags & MINIMAP_FLAG_MARINE)
		LAZYADD(update_targets[MINIMAP_STRING_MARINE], holder)
	if(flags & MINIMAP_FLAG_ALPHA)
		LAZYADD(update_targets[MINIMAP_STRING_ALPHA], holder)
	if(flags & MINIMAP_FLAG_BRAVO)
		LAZYADD(update_targets[MINIMAP_STRING_BRAVO], holder)
	if(flags & MINIMAP_FLAG_CHARLIE)
		LAZYADD(update_targets[MINIMAP_STRING_CHARLIE], holder)
	if(flags & MINIMAP_FLAG_DELTA)
		LAZYADD(update_targets[MINIMAP_STRING_DELTA], holder)
	updators_by_datum[target] = holder
	update_targets_unsorted += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/remove_updator)

/**
 * Removes a atom from the subsystems updating overlays
 */
/datum/controller/subsystem/minimaps/proc/remove_updator(atom/target)
	SIGNAL_HANDLER
	var/datum/minimap_updator/holder = updators_by_datum[target]
	updators_by_datum -= target
	LAZYREMOVE(update_targets[MINIMAP_STRING_XENO], holder)
	LAZYREMOVE(update_targets[MINIMAP_STRING_MARINE], holder)
	LAZYREMOVE(update_targets[MINIMAP_STRING_ALPHA], holder)
	LAZYREMOVE(update_targets[MINIMAP_STRING_BRAVO], holder)
	LAZYREMOVE(update_targets[MINIMAP_STRING_CHARLIE], holder)
	LAZYREMOVE(update_targets[MINIMAP_STRING_DELTA], holder)
	update_targets_unsorted -= target

/**
 * Holder datum for a zlevels data, concerning the overlays and the drawn level itself
 * The individual image trackers have a raw and a normal list
 * raw lists just store the images, while the normal ones are assoc list of [tracked_atom] = image
 * the raw lists are to speed up the Fire() of the subsystem so we dont have to filter through
 */
/datum/hud_displays
	///Actual icon of the drawn zlevel with all of it's atoms
	var/icon/hud_image
	var/list/xeno_images = list()
	var/list/xeno_images_raw = list()
	var/list/marine_images = list()
	var/list/marine_images_raw = list()
	var/list/alpha_images = list()
	var/list/alpha_images_raw = list()
	var/list/bravo_images = list()
	var/list/bravo_images_raw = list()
	var/list/charlie_images = list()
	var/list/charlie_images_raw = list()
	var/list/delta_images = list()
	var/list/delta_images_raw = list()

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
 * * zlevel: zlevel we want thhis atom to be tracked for
 * * hud_flags: tracked HUDs we want this atom to be displayed on
 * * iconstate: iconstate for the blip we want to be used for this tracked atom
 * * icon: icon file we want to use for this blip, 'icons/UI_icons/map_blips.dmi' by efault
 */
/datum/controller/subsystem/minimaps/proc/add_marker(atom/target, zlevel, hud_flags = NONE, iconstate, icon = 'icons/UI_icons/map_blips.dmi')
	if(!isatom(target) || !zlevel || !hud_flags || !iconstate || !icon)
		CRASH("Invalid marker added to subsystem")
	if(!initialized)
		earlyadds += CALLBACK(src, .proc/add_marker, target, zlevel, hud_flags, iconstate, icon)
		return
	var/image/blip = image(icon, iconstate, pixel_x = MINIMAP_PIXEL_FROM_WORLD(target.x), pixel_y = MINIMAP_PIXEL_FROM_WORLD(target.y))
	images_by_source[target] = blip
	if(hud_flags & MINIMAP_FLAG_XENO)
		minimaps_by_z["[zlevel]"].xeno_images[target] = blip
		minimaps_by_z["[zlevel]"].xeno_images_raw += blip
	if(hud_flags & MINIMAP_FLAG_MARINE)
		minimaps_by_z["[zlevel]"].marine_images[target] = blip
		minimaps_by_z["[zlevel]"].marine_images_raw += blip
	if(hud_flags & MINIMAP_FLAG_ALPHA)
		minimaps_by_z["[zlevel]"].alpha_images[target] = blip
		minimaps_by_z["[zlevel]"].alpha_images_raw += blip
	if(hud_flags & MINIMAP_FLAG_BRAVO)
		minimaps_by_z["[zlevel]"].bravo_images[target] = blip
		minimaps_by_z["[zlevel]"].bravo_images_raw += blip
	if(hud_flags & MINIMAP_FLAG_CHARLIE)
		minimaps_by_z["[zlevel]"].charlie_images[target] = blip
		minimaps_by_z["[zlevel]"].charlie_images_raw += blip
	if(hud_flags & MINIMAP_FLAG_DELTA)
		minimaps_by_z["[zlevel]"].delta_images[target] = blip
		minimaps_by_z["[zlevel]"].delta_images_raw += blip
	if(ismovableatom(target))
		RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/on_z_change)
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_move)
	removal_cbs[target] = CALLBACK(src, .proc/removeimage, blip, target)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/remove_marker)

/**
 * removes an image from raw tracked lists, invoked by callback
 */
/datum/controller/subsystem/minimaps/proc/removeimage(image/blip, atom/target)
	minimaps_by_z["[target.z]"].xeno_images_raw -= blip
	minimaps_by_z["[target.z]"].marine_images_raw -= blip
	minimaps_by_z["[target.z]"].alpha_images_raw -= blip
	minimaps_by_z["[target.z]"].bravo_images_raw -= blip
	minimaps_by_z["[target.z]"].charlie_images_raw -= blip
	minimaps_by_z["[target.z]"].delta_images_raw -= blip
	removal_cbs -= target

/**
 * Called on zlevel change of a blip-atom so we can update the image lists as needed
 */
/datum/controller/subsystem/minimaps/proc/on_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	if(minimaps_by_z["[oldz]"]?.xeno_images[source])
		minimaps_by_z["[newz]"].xeno_images[source] = minimaps_by_z["[oldz]"].xeno_images[source]
		minimaps_by_z["[oldz]"].xeno_images -= source
		minimaps_by_z["[oldz]"].xeno_images_raw -= minimaps_by_z["[newz]"].xeno_images[source]
		minimaps_by_z["[newz]"].xeno_images_raw += minimaps_by_z["[newz]"].xeno_images[source]

	if(minimaps_by_z["[oldz]"]?.marine_images[source])
		minimaps_by_z["[newz]"].marine_images[source] = minimaps_by_z["[oldz]"].marine_images[source]
		minimaps_by_z["[oldz]"].marine_images -= source
		minimaps_by_z["[oldz]"].marine_images_raw -= minimaps_by_z["[newz]"].marine_images[source]
		minimaps_by_z["[newz]"].marine_images_raw += minimaps_by_z["[newz]"].marine_images[source]

	if(minimaps_by_z["[oldz]"]?.alpha_images[source])
		minimaps_by_z["[newz]"].alpha_images[source] = minimaps_by_z["[oldz]"].alpha_images[source]
		minimaps_by_z["[oldz]"].alpha_images -= source
		minimaps_by_z["[oldz]"].alpha_images_raw -= minimaps_by_z["[newz]"].alpha_images[source]
		minimaps_by_z["[newz]"].alpha_images_raw += minimaps_by_z["[newz]"].alpha_images[source]

	if(minimaps_by_z["[oldz]"]?.bravo_images[source])
		minimaps_by_z["[newz]"].bravo_images[source] = minimaps_by_z["[oldz]"].bravo_images[source]
		minimaps_by_z["[oldz]"].bravo_images -= source
		minimaps_by_z["[oldz]"].bravo_images_raw -= minimaps_by_z["[newz]"].bravo_images[source]
		minimaps_by_z["[newz]"].bravo_images_raw += minimaps_by_z["[newz]"].bravo_images[source]

	if(minimaps_by_z["[oldz]"]?.charlie_images[source])
		minimaps_by_z["[newz]"].charlie_images[source] = minimaps_by_z["[oldz]"].charlie_images[source]
		minimaps_by_z["[oldz]"].charlie_images -= source
		minimaps_by_z["[oldz]"].charlie_images_raw -= minimaps_by_z["[newz]"].charlie_images[source]
		minimaps_by_z["[newz]"].charlie_images_raw += minimaps_by_z["[newz]"].charlie_images[source]

	if(minimaps_by_z["[oldz]"]?.delta_images[source])
		minimaps_by_z["[newz]"].delta_images[source] = minimaps_by_z["[oldz]"].delta_images[source]
		minimaps_by_z["[oldz]"].delta_images -= source
		minimaps_by_z["[oldz]"].delta_images_raw -= minimaps_by_z["[newz]"].delta_images[source]
		minimaps_by_z["[newz]"].delta_images_raw += minimaps_by_z["[newz]"].delta_images[source]

/**
 * Simple proc, updates overlay position on the map when a atom moves
 */
/datum/controller/subsystem/minimaps/proc/on_move(atom/movable/source, oldloc)
	SIGNAL_HANDLER
	images_by_source[source].pixel_x = MINIMAP_PIXEL_FROM_WORLD(source.x)
	images_by_source[source].pixel_y = MINIMAP_PIXEL_FROM_WORLD(source.y)

/**
 * Removes an atom nd it's blip from the subsystem
 */
/datum/controller/subsystem/minimaps/proc/remove_marker(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	minimaps_by_z["[source.z]"].xeno_images -= source
	minimaps_by_z["[source.z]"].marine_images -= source
	minimaps_by_z["[source.z]"].alpha_images -= source
	minimaps_by_z["[source.z]"].bravo_images -= source
	minimaps_by_z["[source.z]"].charlie_images -= source
	minimaps_by_z["[source.z]"].delta_images -= source
	images_by_source -= source
	removal_cbs[source].Invoke()
	removal_cbs -= source
