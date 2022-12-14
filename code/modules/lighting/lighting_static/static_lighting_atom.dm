
/atom
	///The light source, datum. Dont fuck with this directly
	var/tmp/datum/static_light_source/static_light
	///Static light sources currently attached to this atom, this includes ones owned by atoms inside this atom
	var/tmp/list/static_light_sources

///Pretty simple, just updates static lights on this atom
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
