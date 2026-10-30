/atom/movable/screen/paper_map_extras
	/// minimap action this extra button is owned by
	var/obj/item/paper_map/papermap

/atom/movable/screen/paper_map_extras/Destroy()
	papermap = null
	return ..()

/atom/movable/screen/paper_map_extras/minimap_z_indicator
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "zindicator"
	screen_loc = ui_ai_floor_indicator

///sets the currently indicated relative floor
/atom/movable/screen/paper_map_extras/minimap_z_indicator/proc/set_indicated_z(newz)
	if(!newz)
		return
	var/list/linked_zs = SSmapping.get_connected_levels(newz)
	if(!length(linked_zs))
		return
	linked_zs = sort_list(linked_zs, /proc/cmp_numeric_asc)
	var/relativez = linked_zs.Find(newz)
	var/text = "Floor<br/>[relativez]"
	maptext = MAPTEXT_TINY_UNICODE("<div align='center' valign='middle' style='position:relative; top:0px; left:0px'>[text]</div>")

/atom/movable/screen/paper_map_extras/minimap_z_up
	name = "go up"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "up"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = ui_ai_godownup

/atom/movable/screen/paper_map_extras/minimap_z_up/Click(location,control,params)
	flick("uppressed",src)
	var/currentz = papermap.targetted_zlevel
	var/list/linked_zs = SSmapping.get_connected_levels(currentz)
	if(!length(linked_zs))
		return
	linked_zs = sort_list(linked_zs, /proc/cmp_numeric_asc)
	var/relativez = linked_zs.Find(currentz)
	if(relativez == length(linked_zs))
		return //topmost z with nothing above. we still play effects just dont do anything
	papermap.change_z_shown(null, ++currentz)

/atom/movable/screen/paper_map_extras/minimap_z_down
	name = "go down"
	icon = 'icons/mob/screen_ai.dmi'
	icon_state = "down"
	mouse_over_pointer = MOUSE_HAND_POINTER
	screen_loc = ui_ai_godownup

/atom/movable/screen/paper_map_extras/minimap_z_down/Click(location,control,params)
	flick("downpressed",src)
	var/currentz = papermap.targetted_zlevel
	var/list/linked_zs = SSmapping.get_connected_levels(currentz)
	if(!length(linked_zs))
		return
	linked_zs = sort_list(linked_zs, /proc/cmp_numeric_asc)
	var/relativez = linked_zs.Find(currentz)
	if(relativez == 1)
		return //bottommost z with nothing below. we still play effects just dont do anything
	papermap.change_z_shown(null, --currentz)

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
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/paper_map_extras/minimap_z_indicator/z_indicator
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/paper_map_extras/minimap_z_up/z_up
	///button granted when you're on a multiz level that lets you check above and below you
	var/atom/movable/screen/paper_map_extras/minimap_z_down/z_down
	///the mob that is currently using this map
	var/mob/interactee

/obj/item/paper_map/Initialize(mapload)
	. = ..()
	locator = new
	z_indicator = new
	z_indicator.papermap = src
	z_up = new
	z_up.papermap = src
	z_down = new
	z_down.papermap = src
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, PROC_REF(change_z_shown))

/obj/item/paper_map/Destroy()
	map = null
	interactee = null
	QDEL_NULL(locator)
	QDEL_NULL(z_indicator)
	QDEL_NULL(z_up)
	QDEL_NULL(z_down)
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
	if(length(SSmapping.get_connected_levels(targetted_zlevel)) > 1)
		user.client.screen += z_indicator
		z_indicator.set_indicated_z(targetted_zlevel)
		user.client.screen += z_up
		user.client.screen += z_down
	RegisterSignal(src, COMSIG_ITEM_UNEQUIPPED, PROC_REF(close_map))
	RegisterSignal(src, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_change))

///Handles closing the map, including removing all on-screen indicators and similar
/obj/item/paper_map/proc/close_map(datum/source, mob/unequipper, slot)
	SIGNAL_HANDLER
	unequipper.client.screen -= SSminimaps.fetch_minimap_object(targetted_zlevel, minimap_flag)
	map = null
	interactee = null
	if(length(SSmapping.get_connected_levels(targetted_zlevel)) > 1)
		unequipper.client.screen -= z_indicator
		unequipper.client.screen -= z_up
		unequipper.client.screen -= z_down
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
	z_indicator.set_indicated_z(newz)
	map = SSminimaps.fetch_minimap_object(newz, minimap_flag)
	interactee.client?.screen += map
	handle_locator(interactee)

/obj/item/paper_map/marine
	minimap_flag = MINIMAP_FLAG_MARINE

/obj/item/paper_map/som
	minimap_flag = MINIMAP_FLAG_MARINE_SOM

/obj/item/paper_map/shipside
	targetted_zlevel = 4
