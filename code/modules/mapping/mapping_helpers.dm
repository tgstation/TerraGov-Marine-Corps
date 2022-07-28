//Landmarks and other helpers which speed up the mapping process and reduce the number of unique instances/subtypes of items/turf/ect

///Maximum amount of items per turf allowed to be sorted by mapping_helper/stack/sort
#define MAX_SORTER_AMOUNT 128
///Maximum amount of tries the stack/displace has to find a valid turf
#define MAX_DISPLACE_TRIES 5

/obj/effect/baseturf_helper //Set the baseturfs of every turf in the /area/ it is placed.
	name = "baseturf editor"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""

	var/list/baseturf_to_replace
	var/baseturf

	layer = POINT_LAYER

/obj/effect/baseturf_helper/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/baseturf_helper/LateInitialize()
	if(!baseturf_to_replace)
		baseturf_to_replace = typecacheof(/turf/open/space)
	else if(!length(baseturf_to_replace))
		baseturf_to_replace = list(baseturf_to_replace = TRUE)
	else if(baseturf_to_replace[baseturf_to_replace[1]] != TRUE) // It's not associative
		var/list/formatted = list()
		for(var/i in baseturf_to_replace)
			formatted[i] = TRUE
		baseturf_to_replace = formatted

	var/area/our_area = get_area(src)
	for(var/i in get_area_turfs(our_area, z))
		replace_baseturf(i)

	qdel(src)

/obj/effect/baseturf_helper/proc/replace_baseturf(turf/thing)
	var/list/baseturf_cache = thing.baseturfs
	if(length(baseturf_cache))
		for(var/i in baseturf_cache)
			if(baseturf_to_replace[i])
				baseturf_cache -= i
		if(!baseturf_cache.len)
			thing.assemble_baseturfs(baseturf)
		else
			thing.PlaceOnBottom(null, baseturf)
	else if(baseturf_to_replace[thing.baseturfs])
		thing.assemble_baseturfs(baseturf)
	else
		thing.PlaceOnBottom(null, baseturf)



/obj/effect/baseturf_helper/space
	name = "space baseturf editor"
	baseturf = /turf/open/space
/*
/obj/effect/baseturf_helper/asteroid
	name = "asteroid baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid

/obj/effect/baseturf_helper/asteroid/airless
	name = "asteroid airless baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/airless

/obj/effect/baseturf_helper/asteroid/basalt
	name = "asteroid basalt baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/basalt

/obj/effect/baseturf_helper/asteroid/snow
	name = "asteroid snow baseturf editor"
	baseturf = /turf/open/floor/plating/asteroid/snow

/obj/effect/baseturf_helper/beach/sand
	name = "beach sand baseturf editor"
	baseturf = /turf/open/floor/plating/beach/sand

/obj/effect/baseturf_helper/beach/water
	name = "water baseturf editor"
	baseturf = /turf/open/floor/plating/beach/water

/obj/effect/baseturf_helper/lava
	name = "lava baseturf editor"
	baseturf = /turf/open/lava/smooth

/obj/effect/baseturf_helper/lava_land/surface
	name = "lavaland baseturf editor"
	baseturf = /turf/open/lava/smooth/lava_land_surface
*/

/obj/effect/mapping_helpers
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = ""
	var/late = FALSE

/obj/effect/mapping_helpers/Initialize()
	. = ..()
	return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_QDEL


//airlock helpers
/obj/effect/mapping_helpers/airlock
	layer = DOOR_HELPER_LAYER

/obj/effect/mapping_helpers/airlock/cyclelink_helper
	name = "airlock cyclelink helper"
	icon_state = "airlock_cyclelink_helper"

/obj/effect/mapping_helpers/airlock/cyclelink_helper/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	//var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	//if(airlock)
	//	if(airlock.cyclelinkeddir)
	//		log_world("### MAP WARNING, [src] at [AREACOORD(src)] tried to set [airlock] cyclelinkeddir, but it's already set!")
	//	else
	//		airlock.cyclelinkeddir = dir
	//else
		//log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")


/obj/effect/mapping_helpers/airlock/locked
	name = "airlock lock helper"
	icon_state = "airlock_locked_helper"

/obj/effect/mapping_helpers/airlock/locked/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
	if(airlock)
		if(airlock.locked)
			log_world("### MAP WARNING, [src] at [AREACOORD(src)] tried to bolt [airlock] but it's already locked!")
		else
			airlock.locked = TRUE
			var/turf/current_turf = get_turf(airlock)
			current_turf.flags_atom |= AI_BLOCKED
	else
		log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")

/obj/effect/mapping_helpers/airlock/unres
	name = "airlock unresctricted side helper"
	icon_state = "airlock_unres_helper"

/obj/effect/mapping_helpers/airlock/unres/Initialize(mapload)
	. = ..()
	if(!mapload)
		log_world("### MAP WARNING, [src] spawned outside of mapload!")
		return
//	var/obj/machinery/door/airlock/airlock = locate(/obj/machinery/door/airlock) in loc
//	if(airlock)
//		airlock.unres_sides ^= dir
//	else
//		log_world("### MAP WARNING, [src] failed to find an airlock at [AREACOORD(src)]")


//needs to do its thing before spawn_rivers() is called
/*
INITIALIZE_IMMEDIATE(/obj/effect/mapping_helpers/no_lava)

/obj/effect/mapping_helpers/no_lava
	icon_state = "no_lava"

/obj/effect/mapping_helpers/no_lava/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	T.flags_1 |= NO_LAVA_GEN_1
*/

/*
//This helper applies components to things on the map directly.
/obj/effect/mapping_helpers/component_injector
	name = "Component Injector"
	late = TRUE
	var/target_type
	var/target_name
	var/component_type

//Late init so everything is likely ready and loaded (no warranty)
/obj/effect/mapping_helpers/component_injector/LateInitialize()
	if(!ispath(component_type,/datum/component))
		CRASH("Wrong component type in [type] - [component_type] is not a component")
	var/turf/T = get_turf(src)
	for(var/atom/A in T.GetAllContents())
		if(A == src)
			continue
		if(target_name && A.name != target_name)
			continue
		if(target_type && !istype(A,target_type))
			continue
		var/cargs = build_args()
		A.AddComponent(arglist(cargs))
		qdel(src)
		return

/obj/effect/mapping_helpers/component_injector/proc/build_args()
	return list(component_type)

/obj/effect/mapping_helpers/component_injector/infective
	name = "Infective Injector"
	icon_state = "component_infective"
	component_type = /datum/component/infective
	var/disease_type

/obj/effect/mapping_helpers/component_injector/infective/build_args()
	if(!ispath(disease_type,/datum/disease))
		CRASH("Wrong disease type passed in.")
	var/datum/disease/D = new disease_type()
	return list(component_type,D)
	*/

/obj/effect/mapping_helpers/stack
	name = "You shouldn't be seeing this."
	///Whether to not active and qdel itself after Init
	var/manual_use = FALSE
	///Whitelist to determine which atoms to affect. null = all
	var/list/whitelist = list()

/obj/effect/mapping_helpers/stack/Initialize()
	. = ..()
	whitelist = typecacheof(whitelist)
	if(manual_use)
		return late ? INITIALIZE_HINT_LATELOAD : INITIALIZE_HINT_NORMAL
	Run()

///Runs the stack mapping_helper's unique proc.
/obj/effect/mapping_helpers/stack/proc/Run()
	return

///Checks for tables and racks in specified turf and returns the height in pixels atoms should be shifted for.
/obj/effect/mapping_helpers/stack/proc/Check_Height_Table_Rack(turf/T)
	if(!T)
		return
	if(locate(/obj/structure/table) in T)
		return 6
	if(locate(/obj/structure/rack) in T)
		return 3

///Moves atom/movable/A into the specified pixel-position and applies an additive layer ontop of it.
/obj/effect/mapping_helpers/stack/proc/pixel_move_atom(atom/movable/A, xpos, ypos, add_layer)
	if(!A)
		return
	A.pixel_x = xpos ? xpos : A.pixel_x
	A.pixel_y = ypos ? ypos : A.pixel_y
	switch(add_layer)
		if(-1) // Reset layer
			A.layer = initial(A.layer)
		if(0.00001 to INFINITY) // Add add_layer to layer
			A.layer = initial(A.layer) + add_layer
		else // Auto-layer using pixel_x and pixel_y.
			A.layer = initial(A.layer) + (A.pixel_x * 0.00001) + (A.pixel_y * -0.001)



/**
 * Sorts items in a neat diagonal line/ grid (best used on a stack of the same/ similar shaped items)
 * Only accepts items since mobs and structures are just generally too big to make look nicely stacked.
 */
/obj/effect/mapping_helpers/stack/sort
	name = "Item Stack Sorter"
	icon_state = "stack_sort"
	///Amount of rows
	var/max_vertical = 3
	///Amount of columns
	var/max_horizontal = 1
	///Horizontal offset for the entire stack
	var/offset_x = 0
	///Vertical offset for the entire stack
	var/offset_y = 0
	///Pixelshifting horizontally between each column
	var/displace_x = 3
	///Pixelshifting vertically between each column
	var/displace_y = -2
	///Pixelshifting horizontally between each item in a column
	var/shift_x = 3
	///Pixelshifting vertically between each item in a column
	var/shift_y = 4

/obj/effect/mapping_helpers/stack/sort/Run()
	///#th item in the current spot.
	var/current_item = 1
	///#th spot in list/spots
	var/current_spot = 1
	///Amount of rows and how many spots there are in a column
	var/rows = 1
	///Amount of columns and how many spots there are in a row
	var/columns = 1
	///Remaining amount of items needing to distribute across existing spots
	var/remaining = 0
	///Amount of items to stack onto every spot to fit all items in.
	var/spot_size = 1
	///Unorganized list of raw spot-data. tempspots = list("5" = list(1,6,8)). key is vertical pixel, value is a list of horizontal pixels.
	var/list/list/tempspots = list()
	///List of the keys from the assoc list tempspots. Used to sort the vertical pixels in descending order.
	var/list/numbersort = list()
	///Proper organized two-dimensional list of spots. spots[i] = list(y-pos, x-pos)
	var/list/spots = list()
	///Horizontal offset to be applied in the entire sort
	var/localoffset_x = offset_x + pixel_x // Just add in the pixel-shift if a third-party spawns us and expects this to work
	///Vertical offset to be applied in the entire sort
	var/localoffset_y = offset_y + pixel_y + Check_Height_Table_Rack(loc)
	///Total amount of items to sort
	var/amount = 0
	///List of items to sort
	var/list/items = list()

	for (var/obj/item/I in loc)
		if(length(whitelist) && !(is_type_in_typecache(I.type, whitelist)))
			continue

		items += I
		amount++

	if(amount > MAX_SORTER_AMOUNT) // Oh god what have you done!?
		log_world("### MAP WARNING, [src] had too many items to sort at [x],[y],[z]!")
		return
	if(max_vertical <= 0 || max_horizontal <= 0)
		log_world("### MAP WARNING, [src] had invalid var(s) at [x],[y],[z]!")
		return

	// Determine the amount of rows and columns by continuously spreading them out more horizontal starting from a overloaded vertical stack
	rows = amount
	while (rows > max_vertical) // Spread out items more horizontal if vertical space is full
		if (columns == max_horizontal) // Horizontal space is full, it's gonna be a full grid
			rows = max_vertical
			break;
		rows *= 0.5
		rows = CEILING(rows,1)
		columns++
	spots.len = rows * columns

	// Determine the amount of items in a spot as well as the offset
	if (amount > length(spots)) // All spots are full but we still got items to place
		spot_size = amount / length(spots)
		spot_size = FLOOR(spot_size, 1)
		remaining = MODULUS(amount, length(spots))

	// Locates the upper right corner of the sorting bounding box
	localoffset_y += ((columns - 1) * 0.5 * displace_y) + ((rows - 1) * 0.5 * shift_y)
	localoffset_y = FLOOR(localoffset_y, 1)
	localoffset_x += ((columns - 1) * 0.5 * displace_x) + ((rows - 1) * 0.5 * shift_x)
	localoffset_x = FLOOR(localoffset_x, 1)

	// Build the spots list with all locations in them using an assoc list
	for(var/current_row = 1, current_row <= rows, current_row++)
		for(var/current_column = 1, current_column <= columns, current_column++)
			var/pos_x = localoffset_x - ((current_column - 1) * displace_x) - ((current_row - 1) * shift_x)
			var/pos_y = localoffset_y - ((current_column - 1) * displace_y) - ((current_row - 1) * shift_y)
			if(tempspots["[pos_y]"] == null)
				tempspots["[pos_y]"] = list()
			tempspots["[pos_y]"].Add(pos_x)

	// Sort the list to be y-desc = list(x-asc,...)
	for(var/num in tempspots)
		numbersort.Add(text2num(num)) // Lets sort using numbers, not strings.
	numbersort = sortTim(numbersort, cmp = /proc/cmp_numeric_dsc)
	for(var/key in tempspots) // Keys are strings, values are numbers. Sort the values in ascending order.
		tempspots[key] = sortTim(tempspots[key], cmp = /proc/cmp_numeric_asc)

	// Organize a proper list to use
	for(var/number_key in numbersort) // numbersort is sorted in descending order. Starting with highest value going down here.
		for(var/i = 1, i <= length(tempspots["[number_key]"]), i++) // values in tempspots is sorted in ascending order.
			spots[current_spot] = list(number_key, tempspots["[number_key]"][i])
			current_spot++
	// list/spots is now a sorted two dimensional list with each entry being = list(y-pos, x-pos)

	// Put the items according to the organized spots list
	current_spot = 1
	current_item = 1
	for (var/obj/item/I in items)
		if (current_item > spot_size)
			if (remaining) // If we have for example 4 spots and 6 items to sort, we put 1 extra item in 2 spots
				remaining--
				pixel_move_atom(I, spots[current_spot][2], spots[current_spot][1] , 0.00001 * current_spot)
				current_spot++ // Populate the next spot
				current_item = 1
				continue
			current_spot++ // Populate the next spot
			current_item = 1
		pixel_move_atom(I, spots[current_spot][2], spots[current_spot][1] , 0.00001 * current_spot)
		current_item++

/obj/effect/mapping_helpers/stack/sort/fivebythree
	max_vertical = 5
	max_horizontal = 3
	displace_x = 3
	displace_y = -2
	shift_x = 4
	shift_y = 3

/obj/effect/mapping_helpers/stack/sort/diagonalfivebythree
	max_vertical = 5
	max_horizontal = 3
	displace_x = 3
	displace_y = -2
	shift_x = 3
	shift_y = 3

/obj/effect/mapping_helpers/stack/sort/diamondthreebythree
	max_vertical = 3
	max_horizontal = 3
	displace_x = 4
	displace_y = -4
	shift_x = 4
	shift_y = 4

/obj/effect/mapping_helpers/stack/sort/blocktwobytwo
	max_vertical = 2
	max_horizontal = 2
	displace_x = 14
	displace_y = 0
	shift_x = 0
	shift_y = 6

/obj/effect/mapping_helpers/stack/sort/blocktwobythree
	max_vertical = 3
	max_horizontal = 2
	displace_x = 14
	displace_y = 0
	shift_x = 0
	shift_y = 6

/obj/effect/mapping_helpers/stack/sort/blockthreebythree
	max_vertical = 3
	max_horizontal = 3
	displace_x = 7
	displace_y = 0
	shift_x = 0
	shift_y = 6

// For use by admemes ingame. Varedit and call proc/Run()
/obj/effect/mapping_helpers/stack/sort/manual
	name = "Manual item stack sorter"
	desc = "Call proc/sort() to sort items. Don't forget to delete it if done."
	manual_use = TRUE

//Randomly sets atoms in a random pixel_x and pixel_y on this turf
/obj/effect/mapping_helpers/stack/shift
	name = "Atom pixel shifter"
	icon_state = "stack_shift"
	///Override to determine which atoms to shift.
	var/list/atom/movable/atoms = list()

///Pixelshifts all objects on the same turf or all objects specified in var/list/objects by -8 to 8 pixels in both axis.
/obj/effect/mapping_helpers/stack/shift/Run()

	if(length(atoms))
		for(var/atom/movable/A in atoms)
			pixel_move_atom(A, rand(-8, 8), rand(-8, 8) + Check_Height_Table_Rack(A.loc), null) // only -8 to +8 so people can always see at a glance on which turf the item is on.
	else
		for(var/atom/movable/A in loc)
			if(length(whitelist) && !(is_type_in_typecache(A.type, whitelist)))
				continue
			pixel_move_atom(A, rand(-8, 8), rand(-8, 8) + Check_Height_Table_Rack(loc), null)

/obj/effect/mapping_helpers/stack/shift/item
	name = "Item pixel shifter"
	whitelist = list(/obj/item)

// For use by admemes ingame. Varedit and call proc/Run()
/obj/effect/mapping_helpers/stack/shift/manual
	name = "Manual shifter"
	desc = "Call proc/Shift() to pixel-move items. Don't forget to delete it if done."
	manual_use = TRUE

//Randomly displaces objects around
/obj/effect/mapping_helpers/stack/displace
	name = "Atom  displacer"
	icon_state = "stack_displace"
	var/range_x = 2
	var/range_y = 2
	///Amount of tries per atom to displace
	var/tries = 5
	///Spawn a stack/shift and pass on the objects from displacement?
	var/pixelshift = FALSE

/obj/effect/mapping_helpers/stack/displace/Run()
	var/obj/effect/mapping_helpers/stack/shift/manual/shift

	if(pixelshift)
		shift = new(loc)

	for(var/atom/movable/A in loc) // Gotta make sure only whitelisted (if the whitelist is on) atoms pass through
		if(length(whitelist) && !(is_type_in_typecache(A.type, whitelist)))
			continue

		if(pixelshift)
			shift.atoms += A

		turf_search:
			for(var/i= 0, i < tries, i++)
				var/target_x = round(clamp(x + rand(-range_x , range_x), 0, 255), 1) //Why the fuck does it sometimes move items 4 tiles away instead of a maximum of two??
				var/target_y = round(clamp(y + rand(-range_y , range_y), 0, 255), 1)
				var/turf/T = locate(target_x, target_y, z)
				if (!T) //How?
					log_world("### MAP WARNING, [src] cannot find turf at [target_x], [target_y], [z]!")
					continue
				if (isopenturf(T)) // No walls
					if (!isspaceturf(T)) // No space
						if (!isspacearea(T.loc)) // Not in space
							for(var/obj/O in T) // No dense objects in turf, except for tables and racks
								if(O.density && !(istype(O, /obj/structure/table) || istype(O, /obj/structure/rack)))
									continue turf_search
							A.forceMove(T)
							break
	if(pixelshift) // Run the pixel-shifter with the atoms we displaced passed along.
		shift.Run()
		qdel(shift)

/obj/effect/mapping_helpers/stack/displace/item
	name = "Item displacer"
	pixelshift = TRUE
	whitelist = list(/obj/item)

/obj/effect/mapping_helpers/stack/displace/trash
	name = "Trash displacer"
	pixelshift = TRUE
	whitelist = list(/obj/item/trash)

/obj/effect/mapping_helpers/stack/displace/crate
	name = "Crate displacer"
	range_x = 1
	range_y = 1
	whitelist = list(
		/obj/structure/largecrate,
		/obj/structure/closet,
	)

/obj/effect/mapping_helpers/stack/displace/machinery
	name = "Machine displacer"
	whitelist = list(/obj/machinery)

/obj/effect/mapping_helpers/stack/displace/mob
	name = "Mob displacer"
	whitelist = list(
		/mob/living,
		/obj/effect/landmark/corpsespawner,
	)

/obj/effect/mapping_helpers/stack/displace/gun
	name = "Gun/ Ammo displacer"
	pixelshift = TRUE
	whitelist = list(
		/obj/item/weapon/gun,
		/obj/item/ammo_magazine,
		/obj/effect/spawner/random/gun,
		/obj/effect/spawner/random/ammo,
		/obj/effect/landmark/weapon_spawn,
		/obj/effect/spawner/random_set/gun,
		/obj/effect/spawner/random_set/machineguns,
		/obj/effect/spawner/random_set/rifle,
		/obj/effect/spawner/random_set/shotgun,
		/obj/effect/spawner/random_set/sidearms,
	)

// For use by admemes ingame. Varedit and call proc/Run()
/obj/effect/mapping_helpers/stack/displace/manual
	name = "Manual displacer"
	desc = "Call proc/Displace() to move items. Don't forget to delete it if done."
	manual_use = TRUE

#undef MAX_SORTER_AMOUNT
