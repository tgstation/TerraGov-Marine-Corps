/obj/item/stack/tile
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	w_class = WEIGHT_CLASS_NORMAL
	force = 1
	throwforce = 1
	throw_speed = 5
	throw_range = 9
	max_amount = 60
	///The turf type this tile creates
	var/turf/open/floor/turf_type

/obj/item/stack/tile/Initialize(mapload)
	. = ..()
	pixel_x = rand(1, 14)
	pixel_y = rand(1, 14)

/obj/item/stack/tile/attack_turf(turf/T, mob/living/user)
	if(!turf_type)
		return
	if(T.type != /turf/open/floor/plating)
		return
	if(!use(1))
		return
	T.ChangeTurf(turf_type)

/obj/item/stack/tile/plasteel
	name = "floor tile"
	singular_name = "floor tile"
	desc = "Those could work as a pretty decent throwing weapon"
	icon_state = "tile"
	force = 6
	throwforce = 8
	throw_speed = 3
	throw_range = 6
	flags_atom = CONDUCT
	turf_type = /turf/open/floor

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


/obj/item/stack/tile/grass
	name = "grass tile"
	singular_name = "grass floor tile"
	desc = "A patch of grass like they often use on golf courses."
	icon_state = "tile_grass"
	turf_type = /turf/open/floor/grass

/obj/item/stack/tile/wood
	name = "wood floor tile"
	singular_name = "wood floor tile"
	desc = "An easy to fit wooden floor tile."
	icon_state = "tile-wood"
	turf_type = /turf/open/floor/wood

/obj/item/stack/tile/carpet
	name = "carpet"
	singular_name = "carpet"
	desc = "A piece of carpet. It is the same size as a normal floor tile!"
	icon_state = "tile-carpet"
	turf_type = /turf/open/floor/carpet

/obj/item/stack/tile/light
	name = "light tile"
	singular_name = "light floor tile"
	desc = "A floor tile, made out off glass. It produces light."
	icon_state = "tile_e"
	force = 3
	throwforce = 5
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	turf_type = /turf/open/floor/light
	var/on = 1
	var/state //0 = fine, 1 = flickering, 2 = breaking, 3 = broken

/obj/item/stack/tile/light/Initialize(mapload, amount)
	. = ..()
	if(prob(5))
		state = 3 //broken
	else if(prob(5))
		state = 2 //breaking
	else if(prob(10))
		state = 1 //flickering occasionally
	else
		state = 0 //fine

/obj/item/stack/tile/light/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/crowbar))
		new /obj/item/stack/sheet/metal(user.loc)
		amount--
		new /obj/item/stack/light_w(user.loc)
		if(amount <= 0)
			user.temporarilyRemoveItemFromInventory(src)
			qdel(src)
