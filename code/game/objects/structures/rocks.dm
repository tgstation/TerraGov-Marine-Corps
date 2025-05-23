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
	layer = ABOVE_NORMAL_TURF_LAYER
	allow_pass_flags = PASSABLE|PASS_DEFENSIVE_STRUCTURE

/obj/structure/rock/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(30))
				qdel(src)

/obj/structure/rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -40, 5, 1)

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

/obj/structure/rock/basalt/alt4
	name = "volcanic rock"
	icon_state = "basalt_5"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt5
	name = "volcanic rock"
	icon_state = "basalt_6"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt6
	name = "volcanic rock"
	icon_state = "basalt_7"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt7
	name = "volcanic rock"
	icon_state = "basalt_8"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt8
	name = "volcanic rock"
	icon_state = "basalt_9"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt9
	name = "volcanic rock"
	icon_state = "basalt_10"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt10
	name = "volcanic rock"
	icon_state = "basalt_11"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt11
	name = "volcanic rock"
	icon_state = "basalt_12"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt12
	name = "volcanic rock"
	icon_state = "basalt_13"
	color = "#c7bdbd"

/obj/structure/rock/basalt/alt13
	name = "volcanic rock"
	icon_state = "basalt_14"
	color = "#c7bdbd"

/obj/structure/rock/basalt/large_boulder
	name = "giant volcanic rock"
	icon = 'icons/obj/flora/rock_large.dmi'
	icon_state = "boulder_1"
	color = "#c7bdbd"
	bound_height = 64
	bound_width = 64
	max_integrity = 1200

/obj/structure/rock/basalt/large_boulder/altone
	icon_state = "boulder_2"

/obj/structure/rock/basalt/large_boulder/alttwo
	icon_state = "boulder_3"
	bound_height = 32
	bound_width = 64

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

/obj/structure/rock/dark
	name = "boulder"
	desc = "A large rock. It's not cooking anything."

/obj/structure/rock/dark/large
	icon = 'icons/obj/structures/boulder_largedark.dmi'
	icon_state = "boulder_largedark1"
	bound_height = 64
	bound_width = 64

/obj/structure/rock/dark/large/two
	icon_state = "boulder_largedark2"

/obj/structure/rock/dark/large/three
	icon_state = "boulder_largedark3"

/obj/structure/rock/dark/wide
	icon = 'icons/obj/structures/boulder_widedark.dmi'
	icon_state = "boulderwidedark"
	bound_height = 32
	bound_width = 64

/obj/structure/rock/dark/wide/two
	icon_state = "boulderwidedark2"

/obj/structure/rock/dark/small
	icon_state = "bouldersmalldark1"
	icon = 'icons/obj/structures/boulder_small.dmi'

/obj/structure/rock/dark/small/two
	icon_state = "bouldersmalldark2"

/obj/structure/rock/dark/small/three
	icon_state = "bouldersmalldark3"

// Cave props
/obj/structure/rock/dark/stalagmite
	icon = 'icons/obj/structures/prop/urban/urbanrandomprops.dmi'
	name = "stalagmite"
	icon_state = "stalagmite"
	desc = "A cave stalagmite."
	density = FALSE

/obj/structure/rock/dark/stalagmite/one
	icon_state = "stalagmite1"

/obj/structure/rock/dark/stalagmite/two
	icon_state = "stalagmite2"

/obj/structure/rock/dark/stalagmite/three
	icon_state = "stalagmite3"

/obj/structure/rock/dark/stalagmite/four
	icon_state = "stalagmite4"

/obj/structure/rock/dark/stalagmite/five
	icon_state = "stalagmite5"

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

/obj/structure/rock/variable/tinyrock
	name = "tiny rock pile"
	desc = "A pile of tiny pebbles..."
	icon_state = "tinyrock"
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	max_integrity = 100
	icon_variants = 8

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
	allow_pass_flags = PASS_LOW_STRUCTURE|PASSABLE|PASS_WALKOVER

/obj/structure/rock/variable/jungle_large/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
		COMSIG_TURF_CHECK_COVERED = TYPE_PROC_REF(/atom/movable, turf_cover_check),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/rock/variable/jungle_large/footstep_override(atom/movable/source, list/footstep_overrides)
	footstep_overrides[FOOTSTEP_CONCRETE] = layer

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
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)

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
	density = FALSE

/obj/structure/rock/variable/crystal_mound/Initialize(mapload)
	. = ..()
	update_icon()

/obj/structure/rock/variable/crystal_mound/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_emissive", src, alpha = src.alpha)
