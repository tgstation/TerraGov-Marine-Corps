#define BOUND_MIN_X 1
#define BOUND_MIN_Y 2
#define BOUND_MAX_X 3
#define BOUND_MAX_Y 4

#define COORD_X 1
#define COORD_Y 2

#define MAP_SEGMENT_MAX_SIZE 32

GLOBAL_LIST_EMPTY(minimap_blips)

/datum/game_map
	///The name of the map
	var/name
	///Which space level is this linked to
	var/datum/space_level/zlevel
	///The dmi file where the image of the map is stored
	var/icon/generated_map
	///Coordinate bound
	var/list/bounds
	///The size of the icon
	var/icon_size = 8
	///A limit on the size
	var/max_size = 2000
	///List of all blips
	var/list/visible_objects_data

/datum/game_map/New(var/datum/space_level/zlevel)
	. = ..()
	src.zlevel = zlevel
	name = replacetext(lowertext(zlevel.name), " ", "_")

/datum/game_map/proc/get_map_bounds()
	var/z_value = zlevel.z_value
	var/minx = world.maxx
	var/miny = world.maxy
	var/maxx = 1
	var/maxy = 1

	for(var/turf/turf_to_check as anything in block(locate(1, 1, z_value), locate(world.maxx, world.maxy, z_value)))
		if(turf_to_check.type == world.turf)
			continue
		minx = min(minx, turf_to_check.x)
		miny = min(miny, turf_to_check.y)
		maxx = max(maxx, turf_to_check.x)
		maxy = max(maxy, turf_to_check.y)

	while(icon_size > 0 && (maxx * icon_size > max_size || maxy * icon_size > max_size))
		icon_size--

	bounds = list(
		BOUND_MIN_X = minx,
		BOUND_MIN_Y = miny,
		BOUND_MAX_X = maxx,
		BOUND_MAX_Y = maxy
	)

///Generate the current map image as a dmi
/datum/game_map/proc/generate_map()
	generated_map = icon('icons/minimap_template.dmi', "template")
	var/z_value = zlevel.z_value
	get_map_bounds()
	generated_map.Scale(bounds[BOUND_MAX_X]*icon_size, bounds[BOUND_MAX_Y]*icon_size)

	for(var/turf/turf_to_render as anything in block(\
		locate(bounds[BOUND_MIN_X], bounds[BOUND_MIN_Y], z_value),\
		locate(bounds[BOUND_MAX_X], bounds[BOUND_MAX_Y], z_value)))
		if(turf_to_render.flags_atom & TURF_HIDE_MINIMAP)
			continue

		var/icon/I = getFlatIcon(turf_to_render)
		I.Scale(icon_size, icon_size)
		generated_map.Blend(I, ICON_UNDERLAY,\
			(turf_to_render.x - bounds[BOUND_MIN_X])*icon_size,\
			(turf_to_render.y - bounds[BOUND_MIN_Y])*icon_size)

		for(var/A in turf_to_render)
			var/atom/movable/AM = A
			if((AM.flags_atom & SHOW_ON_MINIMAP) && AM.loc == turf_to_render)
				I = getFlatIcon(AM)
				if(!I)
					continue
				I.Scale(\
					icon_size*(I.Width()/world.icon_size), \
					icon_size*(I.Height()/world.icon_size))

				generated_map.Blend(I, ICON_OVERLAY,\
					(turf_to_render.x - bounds[BOUND_MIN_X])*icon_size,\
					(turf_to_render.y - bounds[BOUND_MIN_Y])*icon_size)

	generated_map = icon(generated_map, frame=1)

	fcopy(generated_map, "[MINIMAP_FILE_DIR][name].dmi")

///Update all the blips on the map
/datum/game_map/proc/update_map()
	visible_objects_data = list()
	for(var/datum/minimap/map_blip AS in GLOB.minimap_blips)
		visible_objects_data += list(list(
			"name" = map_blip.holder.name,
			"coordinate" = get_coord(map_blip.holder),
			"image" = map_blip.minimap_blip,
			"marker_flags" = map_blip.marker_flags,
		))

/datum/game_map/proc/set_generated_map(var/F)
	get_map_bounds()
	generated_map = icon(F)

/datum/game_map/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/minimap_blip),
		get_asset_datum(/datum/asset/simple/minimap),
	)

/datum/game_map/ui_state(mob/user)
	return GLOB.always_state

/datum/game_map/proc/get_coord(var/atom/A)
	. = list()
	.["x"] = A.x - bounds[BOUND_MIN_X]-1
	.["y"] = A.y - bounds[BOUND_MIN_Y]-1

/datum/game_map/ui_data(mob/user)
	. = list()
	.["player_data"] = list(
		"name" = user.name,
		"coordinate" = get_coord(user),
		"minimap_flags" = user.minimap_flags
	)
	.["visible_objects_data"] = visible_objects_data

/datum/game_map/ui_static_data(mob/user)
	. = list()
	.["map_size_x"] = generated_map.Width()
	.["map_size_y"] = generated_map.Height()
	.["map_name"] = name
	.["view_size"] = 32

/datum/game_map/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Minimap", "Minimap")
		ui.open()
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/update_ui_wrapper, TRUE)

/datum/game_map/ui_close(mob/user)
	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/game_map/proc/update_ui_wrapper(var/mob/M)
	SIGNAL_HANDLER
	SStgui.try_update_ui(M, src)

#undef BOUND_MIN_X
#undef BOUND_MIN_Y
#undef BOUND_MAX_X
#undef BOUND_MAX_Y
#undef COORD_X
#undef COORD_Y

///The holder of the minimap, can be used in an action or else
/datum/minimap
	///Where will we draw the map
	var/atom/movable/holder
	///What image is printed on the minimap
	var/minimap_blip = ""
	///What can see the holder on minimap
	var/marker_flags = MINIMAP_FLAG_ALL
	///The game_map shown
	var/datum/game_map/map

/datum/minimap/New(atom/movable/holder, minimap_blip, marker_flags, z_level = null)
	src.holder = holder 
	src.minimap_blip = minimap_blip
	src.marker_flags = marker_flags
	set_game_map(null, null, isnull(z_level) ? holder.z : z_level)
	RegisterSignal(holder, COMSIG_MOVABLE_Z_CHANGED, .proc/set_game_map)
	GLOB.minimap_blips += src

/datum/minimap/Destroy()
	GLOB.minimap_blips -= src
	return ..()

///Set the map that will be shown
/datum/minimap/proc/set_game_map(datum/source, old_z, new_z)
	SIGNAL_HANDLER
	if(old_z == new_z)
		return
	map?.ui_close()
	for(var/datum/game_map/potential_map AS in SSminimap.minimaps)
		if(potential_map.zlevel.z_value == new_z)
			map = potential_map
			return
	map = null

///Show the minimap to either the holder or the mob in argument
/datum/minimap/proc/show_minimap(mob/user)
	if(!map)
		return
	if(!user)
		if(!ismob(holder))
			return
		user = holder 
	map.ui_interact(user)

/datum/action/minimap
	name = "Toggle Minimap"
	action_icon_state = "minimap"
	///The minimap blip associated with this action
	var/datum/minimap/minimap

/datum/action/minimap/give_action(mob/M, datum/minimap/minimap)
	. = ..()
	src.minimap = minimap 

/datum/action/minimap/action_activate()
	minimap.show_minimap(owner)
