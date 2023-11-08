//ROCKS
/obj/structure/rock
	name = "rock"
	desc = "A rock. You shouldn't see this one."
	icon = 'icons/obj/flora/rocks2.dmi'
	icon_state = "basalt"
	max_integrity = 250
	coverage = 100
	soft_armor = list(MELEE = 75, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 30, BIO = 100, FIRE = 100, ACID = 25)
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
	icon_state = "basalt_1"

/obj/structure/rock/basalt/alt
	name = "volcanic rock"
	icon_state = "basalt_2"

/obj/structure/rock/basalt/alt2
	name = "volcanic rock"
	icon_state = "basalt_3"

/obj/structure/rock/basalt/alt3
	name = "volcanic rock"
	icon_state = "basalt_4"

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

//randomised icons
/obj/structure/rock/variable
	///number of icon variants this object has
	var/icon_variants = 1

/obj/structure/rock/variable/Initialize(mapload)
	. = ..()
	icon_state = "[initial(icon_state)]_[rand(1, icon_variants)]"

/obj/structure/rock/variable/basalt
	name = "rock"
	desc = "A large imposing rock."
	icon_state = "basalt"
	icon_variants = 4

/obj/structure/rock/variable/stalagmite
	name = "stalagmite"
	desc = "An ancient mound of mineral deposits, typically found in caves."
	icon = 'icons/obj/structures/cave_decor.dmi'
	icon_state = "stalagmite"
	icon_variants = 6

/obj/structure/rock/variable/jungle
	name = "rock"
	desc = "A large bunch of slippery looking rocks."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "rock"
	density = FALSE
	icon_variants = 5

/obj/structure/rock/variable/jungle/big
	desc = "A large imposing rock."
	icon_state = "big_rock"
	density = TRUE
	icon_variants = 4

/obj/structure/rock/variable/jungle_large
	name = "rocks"
	desc = "A large bunch of slippery looking rocks."
	icon = 'icons/obj/flora/largejungleflora.dmi'
	icon_state = "rocks"
	max_integrity = 350
	coverage = 75
	bound_height = 64
	bound_width = 64
	icon_variants = 4

//drought rocks
/obj/structure/rock/variable/drought
	name = "rock"
	desc = "Some dusty rocks."
	icon = 'icons/obj/flora/desert_flora.dmi'
	icon_state = "drought"
	density = FALSE
	icon_variants = 32

//crystal
/obj/structure/rock/crystal
	name = "strange crystal"
	desc = "A strange glowing crystal. Not sure if you should touch it."
	icon = 'icons/obj/flora/crystals.dmi'
	icon_state = "big_crystal"
	light_range = 2
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_GREEN

/obj/structure/rock/crystal/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/rock/crystal/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)

/obj/structure/rock/crystal/small
	icon_state = "small_crystal"
	light_range = 1

/obj/structure/rock/variable/crystal_mound
	name = "strange crystal"
	desc = "Some strange crystals seem to be pushing out of the ground here..."
	icon = 'icons/obj/flora/crystals.dmi'
	icon_state = "crystal_mound"
	icon_variants = 3
	light_range = 0.5
	light_power = 0.5
	light_color = LIGHT_COLOR_EMISSIVE_GREEN

/obj/structure/rock/variable/crystal_mound/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/rock/variable/crystal_mound/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)
