///Holder for lighting mask, this is done for ensuing correct render as a viscontents
/atom/movable/effect/lighting_mask_holder
	name = ""
	anchored = TRUE
	appearance_flags = NONE	//Removes TILE_BOUND meaning that the lighting mask will be visible even if the source turf is not.
	glide_size = INFINITY //prevent shadow jitter
	///The movable mask this holder is holding in its vis contents
	var/atom/movable/lighting_mask/held_mask

/atom/movable/effect/lighting_mask_holder/proc/assign_mask(atom/movable/lighting_mask/mask)
	vis_contents += mask
	held_mask = mask
	mask.mask_holder = src

/atom/movable/effect/lighting_mask_holder/Destroy(force)
	vis_contents -= held_mask
	QDEL_NULL(held_mask)
	return ..()

/atom/movable/effect/lighting_mask_holder/Moved(atom/OldLoc, Dir)
	. = ..()
	held_mask?.queue_mask_update()//held mask can be null when it is deleted
