/**
 * Checks whether the target turf is in a valid state to accept a directional construction
 * such as windows or railings.
 *
 * Returns FALSE if the target turf cannot accept a directional construction.
 * Returns TRUE otherwise.
 *
 * Arguments:
 * * dest_turf - The destination turf to check for existing directional constructions
 * * test_dir - The prospective dir of some atom you'd like to put on this turf.
 * * is_fulltile - Whether the thing you're attempting to move to this turf takes up the entire tile or whether it supports multiple movable atoms on its tile.
 */
/proc/valid_build_direction(turf/dest_turf, test_dir, is_fulltile = FALSE)
	if(!dest_turf)
		return FALSE
	for(var/obj/turf_content in dest_turf)
		if(turf_content.obj_flags & BLOCKS_CONSTRUCTION_DIR)
			if(is_fulltile)  // for making it so fulltile things can't be built over directional things--a special case
				return FALSE
			if(turf_content.dir == test_dir)
				return FALSE
	return TRUE
