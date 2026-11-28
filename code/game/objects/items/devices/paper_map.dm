/obj/item/paper_map
	name = "paper map"
	desc = "An ancient tool used by primitives to help them navigate."
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "map"
	w_class = WEIGHT_CLASS_SMALL
	///Flags that we want to be shown when you interact with this map
	var/minimap_flag = MINIMAP_FLAG_LONE
	/// The Z level this map shows, groundside (2) by default.
	var/targetted_zlevel = 2
	///minimap obj ref that we will display to users
	var/atom/movable/screen/minimap/map
	///Minimap "You are here" indicator for when it's up
	var/atom/movable/screen/minimap_locator/locator
	///The floor indicator and buttons shown with the map when it has z levels above or below it
	var/datum/minimap_z_controls/z_controls
	///the mob that is currently using this map
	var/mob/interactee

/obj/item/paper_map/Initialize(mapload)
	. = ..()
	locator = new
	z_controls = new(CALLBACK(src, PROC_REF(change_z_shown), null))
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, PROC_REF(change_z_shown))

/obj/item/paper_map/Destroy()
	map = null
	interactee = null
	QDEL_NULL(locator)
	QDEL_NULL(z_controls)
	return ..()

/obj/item/paper_map/attack_self(mob/user)
	. = ..()
	if(!user.client)
		return
	interactee = user
	map = SSminimaps.fetch_minimap_object(targetted_zlevel, minimap_flag)
	if(locate(map) in user.client.screen)
		close_map(src, user)
		return
	user.client.screen += map
	handle_locator(user)
	z_controls.show_to(user, targetted_zlevel)
	RegisterSignal(src, COMSIG_ITEM_UNEQUIPPED, PROC_REF(close_map))
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))

///Handles closing the map, including removing all on-screen indicators and similar
/obj/item/paper_map/proc/close_map(datum/source, mob/unequipper, slot)
	SIGNAL_HANDLER
	unequipper.client.screen -= SSminimaps.fetch_minimap_object(targetted_zlevel, minimap_flag)
	map = null
	interactee = null
	z_controls.hide_from(unequipper)
	handle_locator(unequipper)
	UnregisterSignal(src, COMSIG_ITEM_UNEQUIPPED)
	UnregisterSignal(src, COMSIG_MOVABLE_Z_CHANGED)

///Handles showing/hiding the "you are here" locator on the minimap
/obj/item/paper_map/proc/handle_locator(mob/owner)
	if(!map)
		owner.client?.screen -= locator
		locator.UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		return
	if(!locate(locator) in owner.client.screen)
		if(owner.z == targetted_zlevel)
			owner.client?.screen += locator
			locator.update(owner)
			locator.RegisterSignal(owner, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/atom/movable/screen/minimap_locator, update))
		return
	if(owner.z != targetted_zlevel)
		owner.client?.screen -= locator
		locator.UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/obj/item/paper_map/proc/on_owner_z_change(atom/movable/source, oldz, newz)
	SIGNAL_HANDLER
	handle_locator(interactee)
	if((length(SSmapping.get_connected_levels(targetted_zlevel)) > 1) && (newz in SSmapping.get_connected_levels(targetted_zlevel)))
		change_z_shown(null, newz)

///Updates the z level shown on this map
/obj/item/paper_map/proc/change_z_shown(datum/source, newz)
	SIGNAL_HANDLER
	if(!isnum(newz))
		return
	if(!interactee)
		targetted_zlevel = newz
		return
	if(map)
		interactee.client?.screen -= map
	map = null

	targetted_zlevel = newz
	z_controls.set_shown_z(newz)
	map = SSminimaps.fetch_minimap_object(newz, minimap_flag)
	interactee.client?.screen += map
	handle_locator(interactee)

/obj/item/paper_map/marine
	minimap_flag = MINIMAP_FLAG_MARINE

/obj/item/paper_map/som
	minimap_flag = MINIMAP_FLAG_MARINE_SOM

/obj/item/paper_map/shipside
	targetted_zlevel = 4
