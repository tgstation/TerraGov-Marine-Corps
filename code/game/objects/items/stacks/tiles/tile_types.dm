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
	if(!istype(T, /turf/open/floor/plating))
		return
	if(!use(1))
		return
	playsound(T, 'sound/weapons/genhit.ogg', 25, 1)
	T.PlaceOnTop(turf_type)

/obj/item/stack/tile/plasteel
	force = 6
	throwforce = 8
	throw_speed = 3
	throw_range = 6
	atom_flags = CONDUCT
	turf_type = /turf/open/floor

///Creates plating, used for space turfs only
/obj/item/stack/tile/plasteel/proc/build(turf/space_turf)
	if (istype(space_turf,/turf/open/space))
		space_turf.ChangeTurf(/turf/open/floor/plating/airless)
	else
		space_turf.ChangeTurf(/turf/open/floor/plating)


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
	attack_verb = list("bashes", "batters", "bludgeons", "thrashes", "smashes")
	turf_type = /turf/open/floor/light
	var/on = 1
	var/state = LIGHT_TILE_OK

/obj/item/stack/tile/light/Initialize(mapload, amount)
	. = ..()
	if(prob(5))
		state = LIGHT_TILE_BROKEN
	else if(prob(5))
		state = LIGHT_TILE_BREAKING
	else if(prob(10))
		state = LIGHT_TILE_FLICKERING

/obj/item/stack/tile/light/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/tool/crowbar))
		new /obj/item/stack/sheet/metal(user.loc)
		amount--
		new /obj/item/stack/light_w(user.loc)
		if(amount <= 0)
			user.temporarilyRemoveItemFromInventory(src)
			qdel(src)
