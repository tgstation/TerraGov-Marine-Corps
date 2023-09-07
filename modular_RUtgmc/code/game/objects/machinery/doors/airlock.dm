/obj/machinery/door/airlock/attack_facehugger(mob/living/carbon/xenomorph/facehugger/M, isrightclick = FALSE)
	for(var/atom/movable/AM in get_turf(src))
		if(AM != src && AM.density && !AM.CanPass(M, M.loc))
			to_chat(M, span_warning("\The [AM] prevents you from squeezing under \the [src]!"))
			return
	if(locked || welded) //Can't pass through airlocks that have been bolted down or welded
		to_chat(M, span_warning("\The [src] is locked down tight. You can't squeeze underneath!"))
		return
	M.visible_message(span_warning("\The [M] scuttles underneath \the [src]!"), \
	span_warning("You squeeze and scuttle underneath \the [src]."), null, 5)
	M.forceMove(loc)
