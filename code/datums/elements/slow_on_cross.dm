/datum/element/slowing_on_crossed
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///How much it slow down on crossed
	var/slow_amount = 0
	///connections list for
	var/static/list/connections = list(
		//COMSIG_ATOM_ENTERED = /atom.proc/slow_down_crosser
	)

/datum/element/slowing_on_crossed/Attach(datum/target, slow_amount)
	. = ..()
	src.slow_amount = slow_amount
	target.AddElement(/datum/element/connect_loc, connections) //tivi todo
	//RegisterSignal(target, COMSIG_MOVABLE_CROSSED_BY, .proc/slow_down_crosser)

///Slows down human and vehicle on cross
/datum/element/slowing_on_crossed/proc/slow_down_crosser(datum/source, atom/movable/crosser)
	if(crosser.throwing || crosser.buckled)
		return

	if(isvehicle(crosser))
		var/obj/vehicle/vehicle = crosser
		vehicle.last_move_time += slow_amount
		return

	if(!ishuman(crosser))
		return

	if(CHECK_MULTIPLE_BITFIELDS(crosser.flags_pass, HOVERING))
		return

	var/mob/living/carbon/human/victim = crosser

	if(victim.lying_angle)
		return

	victim.next_move_slowdown += slow_amount
