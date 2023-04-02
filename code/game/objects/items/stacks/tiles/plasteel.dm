/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = WEIGHT_CLASS_NORMAL
	force = 6.0
	throwforce = 8.0
	throw_speed = 3
	throw_range = 6
	flags_atom = CONDUCT
	max_amount = 60

/obj/item/stack/tile/plasteel/Initialize()
	. = ..()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)

/obj/item/stack/tile/plasteel/welder_act(mob/living/user, obj/item/I)
	. = ..()
	if(use(4))
		new /obj/item/stack/sheet/metal(get_turf(src))
	else
		balloon_alert(user, "Need 4 tiles")

/obj/item/stack/tile/plasteel/proc/build(turf/S as turf)
	if (istype(S,/turf/open/space))
		S.ChangeTurf(/turf/open/floor/plating/airless)
	else
		S.ChangeTurf(/turf/open/floor/plating)
