/datum/element/accelerate_on_crossed/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_CROSSED_BY, .proc/accelerate_crosser)

///Speeds up xeno on crossed
/datum/element/accelerate_on_crossed/proc/accelerate_crosser(datum/source, atom/movable/crosser)
	if(isxeno(crosser))
		var/mob/living/carbon/xenomorph/X = crosser
		X.next_move_slowdown += X.xeno_caste.weeds_speed_mod
