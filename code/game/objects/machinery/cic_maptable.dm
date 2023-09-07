/obj/machinery/cic_maptable
	name = "map table"
	desc = "A table that displays a map of the current target location"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "maptable"
	interaction_flags = INTERACT_MACHINE_DEFAULT
	use_power = IDLE_POWER_USE
	density = TRUE
	idle_power_usage = 2
	///flags that we want to be shown when you interact with this table
	var/allowed_flags = MINIMAP_FLAG_MARINE
	///by default Zlevel 2, groundside is targetted
	var/targetted_zlevel = 2
	///minimap obj ref that we will display to users
	var/atom/movable/screen/minimap/map

/obj/machinery/cic_maptable/Destroy()
	map = null
	return ..()

/obj/machinery/cic_maptable/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!user.client)
		return
	if(!map)
		map = SSminimaps.fetch_minimap_object(targetted_zlevel, allowed_flags)
	user.client.screen += map
	if(isobserver(user))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))


//Bugfix to handle cases for ghosts/observers that dont automatically close uis on move.
/obj/machinery/cic_maptable/proc/on_move(mob/dead/observer/source, oldloc)
	SIGNAL_HANDLER
	if(!istype(source))
		CRASH("on_move called by non observer")
	if(Adjacent(source))
		return
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	source.unset_interaction()

/obj/machinery/cic_maptable/on_unset_interaction(mob/user)
	. = ..()
	user.client.screen -= map

/obj/machinery/cic_maptable/droppod_maptable
	name = "Athena tactical map console"
	desc = "A map that display the planetside AO, specialized in revealing potential areas to drop pod. This is especially useful to see where the frontlines and marines are at so that anyone droppodding can decide where to land. Pray that your land nav skills are robust to not get lost!"
	icon_state = "droppodtable"

/obj/machinery/cic_maptable/som_maptable
	allowed_flags = MINIMAP_FLAG_MARINE_SOM

/obj/machinery/cic_maptable_big
	name = "map table"
	desc = "A table that displays a map of the current target location that also allows drawing onto it"
	interaction_flags = INTERACT_MACHINE_DEFAULT
	use_power = IDLE_POWER_USE
	density = TRUE
	idle_power_usage = 2
	icon = 'icons/Marine/mainship_props96.dmi'
	icon_state = "maptable"
	layer = ABOVE_OBJ_LAYER
	pixel_x = -16
	pixel_y = -14
	coverage = 75
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE
	/// List of references to the tools we will be using to shape what the map looks like
	var/list/atom/movable/screen/drawing_tools = list(
		/atom/movable/screen/minimap_tool/draw_tool/red,
		/atom/movable/screen/minimap_tool/draw_tool/yellow,
		/atom/movable/screen/minimap_tool/draw_tool/purple,
		/atom/movable/screen/minimap_tool/draw_tool/blue,
		/atom/movable/screen/minimap_tool/draw_tool/erase,
		/atom/movable/screen/minimap_tool/label,
		/atom/movable/screen/minimap_tool/clear,
	)
	/// the Zlevel that this tablet will be allowed to edit
	var/editing_z = 2
	/// The minimap flag we will be allowing to edit
	var/minimap_flag = MINIMAP_FLAG_MARINE
	///minimap obj ref that we will display to users
	var/atom/movable/screen/minimap/map

/obj/machinery/cic_maptable_big/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)
	var/list/atom/movable/screen/actions = list()
	for(var/path in drawing_tools)
		actions += new path(null, editing_z, minimap_flag)
	drawing_tools = actions

/obj/machinery/cic_maptable_big/Destroy()
	. = ..()
	QDEL_LIST(drawing_tools)

/obj/machinery/cic_maptable_big/examine(mob/user)
	. = ..()
	. += span_warning("Note that abuse may result in a command role ban.")

/obj/machinery/cic_maptable_big/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!user.client)
		return
	if(user.skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_EXPERT)
		user.balloon_alert(user, "Can't use that!")
		return
	if(is_banned_from(user.client.ckey, GLOB.roles_allowed_minimap_draw))
		to_chat(user, span_boldwarning("You have been banned from a command role. You may not use [src] until the ban has been lifted."))
		return
	if(!map)
		map = SSminimaps.fetch_minimap_object(editing_z, minimap_flag)
	user.client.screen += map
	user.client.screen += drawing_tools

///Handles closing the map, including removing all on-screen indicators and similar
/obj/machinery/cic_maptable_big/on_unset_interaction(mob/user)
	. = ..()
	user.client.screen -= map
	user.client.screen -= drawing_tools
	user.client.mouse_pointer_icon = null
	for(var/atom/movable/screen/minimap_tool/tool AS in drawing_tools)
		tool.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP))
