/obj/structure/droppod/launchpod(mob/user)
	. = ..()
	var/turf/target = locate(target_x, target_y, 2)
	var/obj/effect/overlay/pod_warning/laserpod = new /obj/effect/overlay/pod_warning(target)
	laserpod.dir = target
	QDEL_IN(laserpod, DROPPOD_TRANSIT_TIME + 1)
