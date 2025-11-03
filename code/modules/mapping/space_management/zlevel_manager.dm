// Populate the space level list and prepare space transitions
/datum/controller/subsystem/mapping/proc/InitializeDefaultZLevels()
	if (z_list)  // subsystem/Recover or badminnery, no need
		return

	z_list = list()
	z_level_to_plane_offset = list()
	z_level_to_lowest_plane_offset = list()
	var/list/default_map_traits = DEFAULT_MAP_TRAITS

	if (length(default_map_traits) != world.maxz)
		WARNING("More or less map attributes pre-defined ([length(default_map_traits)]) than existent z-levels ([world.maxz]). Ignoring the larger.")
		if (length(default_map_traits) > world.maxz)
			default_map_traits.Cut(world.maxz + 1)

	for (var/I in 1 to length(default_map_traits))
		var/list/features = default_map_traits[I]
		var/datum/space_level/S = new(I, features[DL_NAME], features[DL_TRAITS])
		manage_z_level(S, filled_with_space = FALSE)
	generate_z_level_linkages() // Default Zs don't use add_new_zlevel() so they don't automatically generate z-linkages.

/datum/controller/subsystem/mapping/proc/add_new_zlevel(name, traits = list(), z_type = /datum/space_level, contain_turfs = TRUE)
	UNTIL(!adding_new_zlevel)
	adding_new_zlevel = TRUE
	var/new_z = length(z_list) + 1
	if (world.maxz < new_z)
		world.incrementMaxZ()
		CHECK_TICK
	// TODO: sleep here if the Z level needs to be cleared
	var/datum/space_level/S = new z_type(new_z, name, traits)
	manage_z_level(S, filled_with_space = TRUE, contain_turfs = contain_turfs)
	generate_linkages_for_z_level(new_z)
	calculate_z_level_gravity(new_z)
	adding_new_zlevel = FALSE
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_NEW_Z, S)
	return S
/// Returns the /datum/space_level associated with the given z level.
/datum/controller/subsystem/mapping/proc/get_level(z) as /datum/space_level
	if (z_list && z >= 1 && z <= length(z_list))
		return z_list[z]
	CRASH("Unmanaged z-level [z]! maxz = [world.maxz], z_list.len = [z_list ? length(z_list) : "null"]")
