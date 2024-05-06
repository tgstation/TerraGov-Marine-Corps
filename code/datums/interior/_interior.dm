#define INTERIOR_BUFFER_TILES 1

/datum/interior
	///map template to load as the interior
	var/template = /datum/map_template
	///container that this interior is attached to; what we are the inside of
	var/atom/container
	///callback to execute when we want to eject the mob
	var/datum/callback/exit_callback
	///occupants that entered this interior through the intended way
	var/list/mob/occupants = list()
	///turf reservation where we will load our interior
	var/datum/turf_reservation/reservation
	///list of all loaded turfs. we keep this around in case we need to update linkages or similar
	var/list/turf/loaded_turfs = list()
	/// the interior area. you should only be using 1 area for the whole thing, if you're not, make this support it lol
	var/area/this_area

/datum/interior/New(atom/container, datum/callback/exit_callback)
	..()
	src.container = container
	src.exit_callback = exit_callback
	RegisterSignal(container, COMSIG_QDELETING, PROC_REF(handle_container_del))
	RegisterSignal(container, COMSIG_ATOM_ENTERED, PROC_REF(on_container_enter))
	INVOKE_NEXT_TICK(src, PROC_REF(init_map))

///actual inits the map, seperate proc because otherwise it fails linter due to "sleep in new"
/datum/interior/proc/init_map()
	var/datum/map_template/map = new template
	reservation = SSmapping.RequestBlockReservation(map.width + (INTERIOR_BUFFER_TILES*2), map.height + (INTERIOR_BUFFER_TILES*2))

	var/list/load_coords = reservation.bottom_left_coords.Copy()
	load_coords[1] = load_coords[1] + INTERIOR_BUFFER_TILES
	load_coords[2] = load_coords[2] + INTERIOR_BUFFER_TILES
	var/turf/load_loc = locate(load_coords[1], load_coords[2], load_coords[3])
	var/list/bounds = map.load(load_loc)
	this_area = load_loc.loc

	loaded_turfs = block(
		locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
		locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ])
	)

	connect_atoms()

/datum/interior/Destroy(force, ...)
	for(var/mob/occupant AS in occupants)
		mob_leave(occupant)
	exit_callback = null
	this_area = null
	loaded_turfs = null
	QDEL_NULL(reservation) //all the turfs/objs are deleted past this point
	container = null
	return ..()

///connects all atoms as needed to the interior. seperate so it can be used in debugging
/datum/interior/proc/connect_atoms()
	for(var/turf/tile AS in loaded_turfs)
		for(var/atom/subject AS in tile.GetAllContents())
			subject.link_interior(src)
		CHECK_TICK

///called when someone enters the container
/datum/interior/proc/on_container_enter(datum/source, atom/movable/moved_in, direction)
	SIGNAL_HANDLER
	if(ismob(moved_in))
		mob_enter(moved_in)

///called when we want to move a mob into the interior
/datum/interior/proc/mob_enter(mob/enterer)
	RegisterSignal(enterer, COMSIG_QDELETING, PROC_REF(handle_occupant_del))
	RegisterSignal(enterer, COMSIG_EXIT_AREA, PROC_REF(handle_area_leave))
	for(var/datum/action/minimap/user_map in enterer.actions)
		user_map.override_locator(container)
	occupants += enterer
	//teleporting the mob is on a case-by-case basis

///called when we want to remove a mob from the interior
/datum/interior/proc/mob_leave(mob/leaver, teleport = TRUE)
	UnregisterSignal(leaver, list(COMSIG_QDELETING, COMSIG_EXIT_AREA))
	occupants -= leaver
	exit_callback?.Invoke(leaver, src, teleport)
	for(var/datum/action/minimap/user_map in leaver.actions)
		user_map.clear_locator_override()

///called when a mob gets deleted while an occupant
/datum/interior/proc/handle_occupant_del(mob/source)
	SIGNAL_HANDLER
	mob_leave(source, FALSE)

///called when parent container is deleted
/datum/interior/proc/handle_container_del(atom/source)
	SIGNAL_HANDLER
	qdel(src)

///when someone who entered the "proper" way leaves the area, remove them as an occupant without teleporting
/datum/interior/proc/handle_area_leave(mob/source, area/oldarea, direction)
	SIGNAL_HANDLER
	if(get_area(source) != this_area)
		mob_leave(source, FALSE)

#undef INTERIOR_BUFFER_TILES

/area/interior
	name = "ERROR AREA DO NOT USE"
	base_lighting_alpha = 128

/turf/closed/interior
	resistance_flags = RESIST_ALL

/turf/open/interior
	resistance_flags = RESIST_ALL
