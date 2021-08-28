/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = WEIGHT_CLASS_NORMAL
	force = 6.0
	materials = list(/datum/material/metal = 1000)
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	flags_atom = CONDUCT
	max_amount = 60

/obj/item/stack/tile/plasteel/Initialize()
	. = ..()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)

/*
/obj/item/stack/tile/plasteel/attack_self(mob/user as mob)
	if (usr.stat)
		return
	var/T = user.loc
	if (!( istype(T, /turf) ))
		to_chat(user, span_warning("You must be on the ground!"))
		return
	if (!isspaceturf(T))
		to_chat(user, span_warning("You cannot build on or repair this turf!"))
		return
	src.build(T)
	use(1)

*/

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)
	if (istype(S,/turf/open/space))
		S.ChangeTurf(/turf/open/floor/plating/airless)
	else
		S.ChangeTurf(/turf/open/floor/plating)
//	var/turf/open/floor/W = S.ReplaceWithFloor()
//	W.make_plating()

