//ROCKS
/obj/structure/rock
	name = "rock"
	desc = "A rock. You shouldn't see this one."
	icon = 'icons/obj/flora/rocks2.dmi'
	icon_state = "basalt"
	max_integrity = 250
	coverage = 100
	density = TRUE
	anchored = TRUE
	layer = ABOVE_TURF_LAYER

/obj/structure/rock/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(30))
				qdel(src)

/obj/structure/rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/obj/structure/rock/basalt
	name = "volcanic rock"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	icon = 'icons/obj/flora/rocks2.dmi'
	icon_state = "basalt"

/obj/structure/rock/basalt/alt
	name = "volcanic rock"
	icon_state = "basalt1"

/obj/structure/rock/basalt/alt2
	name = "volcanic rock"
	icon_state = "basalt2"

/obj/structure/rock/basalt/alt3
	name = "volcanic rock"
	icon_state = "basalt3"

/obj/structure/rock/basalt/pile
	name = "rock pile"
	desc = "pile of volcanic rocks."
	density = FALSE
	icon_state = "lavarocks"

/obj/structure/rock/basalt/pile/alt
	name = "rock pile"
	icon_state = "lavarocks1"

/obj/structure/rock/basalt/pile/alt2
	name = "rock pile"
	icon_state = "lavarocks2"

/obj/structure/rock/basalt/pile/alt3
	name = "fossils"
	desc = "A pile of ancient fossils. There are some oddly shaped skulls in here..."
	icon_state = "lavarocks3"

/obj/structure/rock/stalagmite
	name = "stalagmite"
	desc = "An ancient mound of mineral deposits, typically found in caves."
	icon = 'icons/obj/structures/cave_decor.dmi'
	icon_state = "stalagmite"
	///number of icon variants this object has
	var/icon_variants = 6

/obj/structure/rock/stalagmite/Initialize(mapload)
	. = ..()
	icon_state = "[initial(icon_state)]_[rand(1, icon_variants)]"
