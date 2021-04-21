
/**
 * Bespoke Element for mobs to access when they want to view a HUD of the map
 * Keep it bespoke so we have to update as few objects as possible in the subsystem
 */
/datum/element/hud_map
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///Minimap we're going to be displaying and accessing
	var/obj/screen/minimap/map
	///map target we are going to be updating to
	var/mapz = 0
	///Minimap flags we are going to update for
	var/filter = NONE
	///Increment to clear the map when it's not in use anymore
	var/active_users = 0

/datum/element/hud_map/Attach(mob/target, ztarget, filtertargets)
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	mapz = ztarget
	filter = filtertargets
	RegisterSignal(target, COMSIG_MOVABLE_Z_CHANGED, .proc/change_map)
	if(!SSminimaps.minimaps_by_z["[ztarget]"] || !SSminimaps.minimaps_by_z["[ztarget]"].hud_image)
		return
	if(!map)
		map = new(null, ztarget, filtertargets)
	active_users++
	RegisterSignal(target, COMSIG_MOB_HUDMAP_TOGGLED, .proc/display_map_to)

///Displays the HUD display to the inputted mob source
/datum/element/hud_map/proc/display_map_to(mob/source)
	SIGNAL_HANDLER
	source.client.screen += map
	UnregisterSignal(source, COMSIG_MOB_HUDMAP_TOGGLED)
	RegisterSignal(source, COMSIG_MOB_HUDMAP_TOGGLED, .proc/undisplay_map)

///Undisplays the HUD display to the inputted mob source
/datum/element/hud_map/proc/undisplay_map(mob/source)
	SIGNAL_HANDLER
	source.client.screen -= map
	UnregisterSignal(source, COMSIG_MOB_HUDMAP_TOGGLED)
	RegisterSignal(source, COMSIG_MOB_HUDMAP_TOGGLED, .proc/display_map_to)

///When the zlevel of the owner changes this updates the element they will use to display
/datum/element/hud_map/proc/change_map(mob/source, oldz, newz)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOB_HUDMAP_TOGGLED)
	/**
	 * Wait why dont you use .?
	 * YEA WELL IT CRASHES THE SERVER APPARENTLY THANKS BYOND
	 */
	//source.client?.screen -= map
	if(source.client)
		source.client.screen -= map
	Detach(source)
	source.AddElement(/datum/element/hud_map, newz, filter)

/datum/element/hud_map/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOVABLE_Z_CHANGED,COMSIG_MOB_HUDMAP_TOGGLED))
	if(!--active_users)
		QDEL_NULL(map)


/obj/screen/minimap
	name = "Minimap"
	icon = null
	icon_state = ""
	layer = ABOVE_HUD_LAYER
	screen_loc = "1,1"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/minimap/Initialize(mapload, target, flags)
	. = ..()
	icon = SSminimaps.minimaps_by_z["[target]"].hud_image
	SSminimaps.add_to_updaters(src, flags, target)


/**
 * Action that gives the owner access to the minimap pool
 */
/datum/action/minimap
	name = "Toggle Minimap"
	action_icon_state = "minimap"
	///Flags to allow them to see
	var/minimap_flags = MINIMAP_FLAG_ALL
	///marker flags this will give the target, mostly used for marine minimaps
	var/marker_flags = MINIMAP_FLAG_ALL

/datum/action/minimap/action_activate()
	. = ..()
	SEND_SIGNAL(owner, COMSIG_MOB_HUDMAP_TOGGLED)

/datum/action/minimap/give_action(mob/M)
	. = ..()
	M.AddElement(/datum/element/hud_map, M.z, minimap_flags)

/datum/action/minimap/remove_action(mob/M)
	. = ..()
	M.RemoveElement(/datum/element/hud_map)

/datum/action/minimap/xeno
	minimap_flags = MINIMAP_FLAG_XENO

/datum/action/minimap/marine
	minimap_flags = MINIMAP_FLAG_MARINE
	marker_flags = MINIMAP_FLAG_MARINE

/datum/action/minimap/alpha
	minimap_flags = MINIMAP_FLAG_ALPHA
	marker_flags = MINIMAP_FLAG_ALPHA|MINIMAP_FLAG_MARINE

/datum/action/minimap/bravo
	minimap_flags = MINIMAP_FLAG_BRAVO
	marker_flags = MINIMAP_FLAG_BRAVO|MINIMAP_FLAG_MARINE

/datum/action/minimap/charlie
	minimap_flags = MINIMAP_FLAG_CHARLIE
	marker_flags = MINIMAP_FLAG_CHARLIE|MINIMAP_FLAG_MARINE

/datum/action/minimap/delta
	minimap_flags = MINIMAP_FLAG_DELTA
	marker_flags = MINIMAP_FLAG_DELTA|MINIMAP_FLAG_MARINE

/datum/action/minimap/observer
	minimap_flags = MINIMAP_FLAG_XENO|MINIMAP_FLAG_MARINE
	marker_flags = NONE
