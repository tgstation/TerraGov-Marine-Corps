
/atom
	var/tmp/datum/static_light_source/static_light // Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/list/static_light_sources       // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.

/atom/proc/static_update_light()
	set waitfor = FALSE
	if (QDELETED(src))
		return

	if (!light_power || !light_range) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(static_light)
	else
		if(!ismovableatom(loc)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if(static_light) // Update the light or create it if it does not exist.
			static_light.update(.)
		else
			static_light = new/datum/static_light_source(src, .)
