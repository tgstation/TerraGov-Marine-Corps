/datum/element/accelerate_on_crossed/Attach(datum/target)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = /atom.proc/accelerate_crosser,
	)
	target.AddElement(/datum/element/connect_loc, connections)

///Speeds up xeno on crossed
/atom/proc/accelerate_crosser(datum/source, atom/movable/crosser)
	SIGNAL_HANDLER
	if(isxeno(crosser))
		var/mob/living/carbon/xenomorph/X = crosser
		X.next_move_slowdown += X.xeno_caste.weeds_speed_mod
