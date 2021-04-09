/obj/effect/lighting_mask_holder
	name = ""
	anchored = TRUE
	appearance_flags = NONE	//Removes TILE_BOUND meaning that the lighting mask will be visible even if the source turf is not.
	var/atom/movable/lighting_mask/held_mask

/obj/effect/lighting_mask_holder/proc/assign_mask(atom/movable/lighting_mask/mask)
	vis_contents += mask
	//add_overlay(mask)
	held_mask = mask
	mask.mask_holder = src

//This may be a bug with byond, but we can control when the vis_contents is rendered
//by updating this objects matrix with the item in vis_contents being on RESET_TRANSFORM.
//Because shadows extend further than the light source, we need to be able to order the light
//to stop rendering when it is out of view, and to do this we simple need to know the bounds
//of the mask (including shadow) and the bounds of the mask without the shadow.
/obj/effect/lighting_mask_holder/proc/update_matrix(actual_bound_top, actual_bound_bottom, actual_bound_left, actual_bound_right, radius)
	//transform = matrix() tivi todo
	//transform = actual_bound_top

/obj/effect/lighting_mask_holder/Destroy(force)
	QDEL_NULL(held_mask)
	return ..()

/obj/effect/lighting_mask_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	held_mask.calculate_lighting_shadows()

//tivi todo experiment with removing holder
