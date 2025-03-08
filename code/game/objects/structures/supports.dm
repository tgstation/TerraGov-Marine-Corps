/obj/structure/support
	name = "wooden support pillar"
	desc = "This pillar seems to be holding up the ceiling, careful not to break it. The ceiling could collapse."
	icon = 'icons/turf/wood.dmi'
	icon_state = "wood0"
	density = TRUE

	obj_integrity = 250

	/// How far around the pillar is supported
	var/supported_range = 1
	/// The type of debris to spawn when the ceiling collaspses
	var/collapsed_type = /turf/closed/mineral

/obj/structure/support/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -40, 5)

/obj/structure/support/deconstruct(disassembled)
	collapse()
	. = ..()


/obj/structure/support/proc/collapse()
	playsound(loc, "explosion", 100, TRUE)
	var/list/turfs = RANGE_TURFS(supported_range, loc)
	for(var/i in turfs)
		var/turf/T = i
		if(T.density)
			continue
		var/list/baseturfs = islist(T.baseturfs) ? T.baseturfs : list(T.baseturfs)
		baseturfs |= T.type
		T.ChangeTurf(collapsed_type, baseturfs)
