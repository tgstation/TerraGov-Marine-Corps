/obj/machinery/cic_maptable
	name = "map table"
	desc = "A table that displays a map of the current target location"
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "maptable"
	interaction_flags = INTERACT_MACHINE_DEFAULT
	use_power = IDLE_POWER_USE
	density = TRUE
	idle_power_usage = 2
	light_range = 2
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	var/screen_overlay = "maptable_screen"
	///flags that we want to be shown when you interact with this table
	var/minimap_flag = MINIMAP_FLAG_MARINE
	///by default Zlevel 2, groundside is targetted
	var/targetted_zlevel = 2
	///minimap obj ref that we will display to users
	var/atom/movable/screen/minimap/map
	///List of currently interacting mobs
	var/list/mob/interactees = list()

/obj/machinery/cic_maptable/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, PROC_REF(change_targeted_z))
	update_icon()

/obj/machinery/cic_maptable/Destroy()
	map = null
	return ..()

/obj/machinery/cic_maptable/update_icon()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		set_light(0)
	else
		set_light(initial(light_range))

/obj/machinery/cic_maptable/update_overlays()
	. = ..()
	if(machine_stat & (BROKEN|DISABLED|NOPOWER))
		return
	. += emissive_appearance(icon, screen_overlay, alpha = src.alpha)
	. += mutable_appearance(icon, screen_overlay, alpha = src.alpha)

/obj/machinery/cic_maptable/interact(mob/user)
	. = ..()
	if(.)
		return
	if(interact_checks(user))
		return TRUE
	if(!map)
		map = SSminimaps.fetch_minimap_object(targetted_zlevel, minimap_flag)
	user.client.screen += map
	interactees += user
	if(isobserver(user))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

///Returns true if something prevents the user from interacting with this. used mainly with the drawtable
/obj/machinery/cic_maptable/proc/interact_checks(mob/user)
	if(!user.client)
		return TRUE

//Bugfix to handle cases for ghosts/observers that dont automatically close uis on move.
/obj/machinery/cic_maptable/proc/on_move(mob/dead/observer/source, oldloc)
	SIGNAL_HANDLER
	if(!istype(source))
		CRASH("on_move called by non observer")
	if(Adjacent(source))
		return
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
	source.unset_interaction()

///Updates the z-level this maptable views
/obj/machinery/cic_maptable/proc/change_targeted_z(datum/source, new_z)
	SIGNAL_HANDLER
	if(!isnum(new_z))
		return
	for(var/mob/user AS in interactees)
		on_unset_interaction(user)
	map = null
	targetted_zlevel = new_z

/obj/machinery/cic_maptable/on_unset_interaction(mob/user)
	. = ..()
	interactees -= user
	user?.client?.screen -= map

/obj/machinery/cic_maptable/droppod_maptable
	name = "Athena tactical map console"
	desc = "A map that display the planetside AO, specialized in revealing potential areas to drop pod. This is especially useful to see where the frontlines and marines are at so that anyone droppodding can decide where to land. Pray that your land nav skills are robust to not get lost!"
	icon_state = "droppodtable"
	screen_overlay = "droppodtable_emissive"

/obj/machinery/cic_maptable/som_maptable
	icon_state = "som_console"
	screen_overlay = "som_maptable_screen"
	minimap_flag = MINIMAP_FLAG_MARINE_SOM
	light_color = LIGHT_COLOR_FLARE

/obj/machinery/cic_maptable/no_flags
	minimap_flag = NONE

//Exactly the same but you can draw on the map
/obj/machinery/cic_maptable/drawable
	desc = "A table that displays a map of the current target location that also allows drawing onto it"
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

/obj/machinery/cic_maptable/drawable/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
	)
	AddElement(/datum/element/connect_loc, connections)

	var/list/atom/movable/screen/actions = list()
	for(var/path in drawing_tools)
		actions += new path(null, targetted_zlevel, minimap_flag)
	drawing_tools = actions

/obj/machinery/cic_maptable/drawable/Destroy()
	. = ..()
	QDEL_LIST(drawing_tools)

/obj/machinery/cic_maptable/drawable/examine(mob/user)
	. = ..()
	. += span_warning("Note that abuse may result in a command role ban.")

/obj/machinery/cic_maptable/drawable/interact_checks(mob/user)
	. = ..()
	if(.)
		return
	if(user.skills.getRating(SKILL_LEADERSHIP) < SKILL_LEAD_EXPERT)
		user.balloon_alert(user, "Can't use that!")
		return TRUE
	if(is_banned_from(user.client.ckey, GLOB.roles_allowed_minimap_draw))
		to_chat(user, span_boldwarning("You have been banned from a command role. You may not use [src] until the ban has been lifted."))
		return TRUE

/obj/machinery/cic_maptable/drawable/interact(mob/user)
	. = ..()
	if(.)
		return
	user.client.screen += drawing_tools

/obj/machinery/cic_maptable/drawable/on_unset_interaction(mob/user)
	. = ..()
	user?.client?.screen -= drawing_tools
	user?.client?.mouse_pointer_icon = null
	for(var/atom/movable/screen/minimap_tool/tool AS in drawing_tools)
		tool.UnregisterSignal(user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP))

///Updates the z-level this maptable views
/obj/machinery/cic_maptable/drawable/change_targeted_z(datum/source, new_z)
	. = ..()

	for(var/atom/movable/screen/minimap_tool/tool AS in drawing_tools)
		tool.zlevel = new_z
		tool.set_zlevel(new_z, tool.minimap_flag)

/obj/machinery/cic_maptable/drawable/big
	icon = 'icons/Marine/mainship_props96.dmi'
	layer = ABOVE_OBJ_LAYER
	pixel_x = -16
	pixel_y = -14
	coverage = 75
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE

/obj/machinery/cic_maptable/drawable/big/som
	minimap_flag = MINIMAP_FLAG_MARINE_SOM
	screen_overlay = "som_maptable_screen"
	light_color = LIGHT_COLOR_FLARE
	light_range = 3
