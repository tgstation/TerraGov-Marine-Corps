/**
 * Base class for all random spawners.
 */
/obj/effect/spawner/random
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_loot"
	layer = OBJ_LAYER
	/// Stops persistent lootdrop spawns from being shoved into lockers
	anchored = TRUE
	/// A list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)
	var/list/loot
	/// The subtypes AND type to combine with the loot list
	var/list/loot_type_path
	/// The subtypes (this excludes the provided path) to combine with the loot list
	var/list/loot_subtype_path
	/// How many items will be spawned
	var/spawn_loot_count = 1
	/// If the same item can be spawned twice
	var/spawn_loot_double = TRUE
	/// Whether the items should be distributed to offsets 0,1,-1,2,-2,3,-3.. This overrides pixel_x/y on the spawner itself
	var/spawn_loot_split = FALSE
	/// Whether the spawner should spawn all the loot in the list
	var/spawn_all_loot = FALSE
	/// The chance for the spawner to create loot (ignores spawn_loot_count)
	var/spawn_loot_chance = 100
	/// Determines how big of a range (in tiles) we should scatter things in.
	var/spawn_scatter_radius = 0
	/// Whether the items should have a random pixel_x/y offset (maxium offset distance is ±16 pixels for x/y)
	var/spawn_random_offset = FALSE
	///does the spawned structure need to retain its direction on spawn?
	var/spawn_with_original_direction = FALSE
	///do we attempt to force a direction on spawn?
	var/spawn_force_direction = FALSE

/obj/effect/spawner/random/Initialize(mapload)
	. = ..()
	spawn_loot()
	qdel(src)

///If the spawner has any loot defined, randomly picks some and spawns it. Does not cleanup the spawner.
/obj/effect/spawner/random/proc/spawn_loot(lootcount_override)
	if(!prob(spawn_loot_chance))
		return

	var/list/spawn_locations = get_spawn_locations(spawn_scatter_radius)
	var/spawn_loot_count = lootcount_override ? lootcount_override : src.spawn_loot_count

	if(!length(spawn_locations))
		return

	if(spawn_all_loot)
		spawn_loot_count = INFINITY
		spawn_loot_double = FALSE

	if(loot_type_path)
		loot += typesof(loot_type_path)

	if(loot_subtype_path)
		loot += subtypesof(loot_subtype_path)

	if(!length(loot))
		return

	var/loot_spawned = 0
	while((spawn_loot_count > loot_spawned) && length(loot))
		var/lootspawn = pick_weight_recursive(loot)
		if(!spawn_loot_double)
			loot.Remove(lootspawn)
		if(!lootspawn)
			return
		var/turf/spawn_loc = loc
		if(spawn_scatter_radius > 0)
			spawn_loc = pick_n_take(spawn_locations)

		var/atom/movable/spawned_loot = new lootspawn(spawn_loc)
		if(!spawn_with_original_direction)
			spawned_loot.setDir(dir)

		if(spawn_force_direction) //overrides direction if set
			spawned_loot.setDir(spawn_force_direction)

		if(spawn_loot_split && loot_spawned)
			spawned_loot.pixel_x = spawned_loot.pixel_y = ((!(loot_spawned%2)*loot_spawned/2)*-1)+((loot_spawned%2)*(loot_spawned+1)/2*1)
		else if(spawn_random_offset)
			spawned_loot.pixel_x = rand(-16, 16)
			spawned_loot.pixel_y = rand(-16, 16)
		else
			spawned_loot.pixel_x = pixel_x
			spawned_loot.pixel_y = pixel_y

		loot_spawned++

///If the spawner has a spawn_scatter_radius set, this creates a list of nearby turfs available
/obj/effect/spawner/random/proc/get_spawn_locations(radius)
	var/list/scatter_locations = list()

	for(var/turf/turf_in_view in range(radius, get_turf(src)))
		if(!turf_in_view.density)
			scatter_locations += turf_in_view

	return scatter_locations

//do not place spawners below this line, they belong in a different file
