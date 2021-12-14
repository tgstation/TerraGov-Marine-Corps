#define BOUND_MIN_X 1
#define BOUND_MIN_Y 2
#define BOUND_MAX_X 3
#define BOUND_MAX_Y 4

#define COORD_X 1
#define COORD_Y 2

#define MAP_SEGMENT_MAX_SIZE 32

/datum/game_map
	var/name

	var/datum/space_level/zlevel
	var/icon/generated_map
	var/list/bounds
	var/icon_size = 8
	var/max_size = 2000

	var/list/player_data

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

GLOBAL_LIST_INIT(jobs_to_icon, list(
	JOB_SQUAD_ENGI = "hard-hat",
	JOB_SQUAD_MEDIC = "hand-holding-medical",
	JOB_SQUAD_LEADER = "crown"
))

/datum/game_map/proc/update_map()
	player_data = list()
	for(var/mob/living/carbon/human/H as anything in GLOB.human_mob_list)
		if(H.z != zlevel.z_value)
			continue

		player_data += list(list(
			"name" = H.name,
			"coord" = get_coord(H),
			"icon" = GLOB.jobs_to_icon[H.job] || "user"
		))

/datum/game_map/proc/set_generated_map(var/F)
	get_map_bounds()
	generated_map = icon(F)

/datum/game_map/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/minimap)
	)

/datum/game_map/ui_state(mob/user)
	return GLOB.always_state

/datum/game_map/proc/get_coord(var/atom/A)
	. = list(A.x, A.y)


	.[COORD_X] -= bounds[BOUND_MIN_X]-1
	.[COORD_Y] -= bounds[BOUND_MIN_Y]-1

/datum/game_map/ui_data(mob/user)
	. = list()
	.["player_coord"] = get_coord(user)
	.["player_name"] = user.name

	.["player_data"] = player_data

/datum/game_map/ui_static_data(mob/user)
	. = list()
	.["map_size_x"] = generated_map.Width()
	.["map_size_y"] = generated_map.Height()
	.["map_name"] = name
	.["icon_size"] = icon_size

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
