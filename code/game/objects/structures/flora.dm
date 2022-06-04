/obj/structure/flora
	anchored = TRUE
	max_integrity = 25
	coverage = 30
	var/on_fire = FALSE

/obj/structure/flora/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(70))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(50))
				qdel(src)


/obj/structure/flora/flamer_fire_act(burnlevel)
	take_damage(burnlevel, BURN, "fire")

/obj/structure/flora/fire_act()
	take_damage(25, BURN, "fire")


//TREES

/obj/structure/flora/tree
	name = "tree"
	desc = "A large tree."
	density = TRUE
	pixel_x = -16
	max_integrity = 500
	layer = ABOVE_FLY_LAYER
	var/log_amount = 10

/obj/structure/flora/tree/Initialize()
	. = ..()
	AddTransparencyComponent()

//Adds the transparency component, exists to be overridden for different args.
/obj/structure/flora/tree/proc/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency)

/obj/structure/flora/tree/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500)
		if(EXPLODE_HEAVY)
			take_damage(rand(140, 300))
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100))
	START_PROCESSING(SSobj, src)


/obj/structure/flora/tree/deconstruct(disassembled = TRUE)
	density = FALSE
	var/obj/structure/flora/stump/S = new(loc)
	S.name = "[name] stump"
	return ..()


/obj/structure/flora/tree/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!I.sharp && I.force <= 0)
		return

	if(I.hitsound)
		playsound(get_turf(src), I.hitsound, 50, 0, 0)

	user.visible_message(span_notice("[user] begins to cut down [src] with [I]."),span_notice("You begin to cut down [src] with [I]."), "You hear the sound of sawing.")
	var/cut_force = min(1, I.force)
	var/cutting_time = clamp(10, 20, 100 / cut_force) SECONDS
	if(!do_after(user, cutting_time , TRUE, src, BUSY_ICON_BUILD))
		return

	user.visible_message(span_notice("[user] fells [src] with the [I]."),span_notice("You fell [src] with the [I]."), "You hear the sound of a tree falling.")
	playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 10 , 0, 0)
	for(var/i in 1 to log_amount)
		new /obj/item/grown/log(get_turf(src))

	var/obj/structure/flora/stump/S = new(loc)
	S.name = "[name] stump"

	qdel(src)

/obj/structure/flora/tree/flamer_fire_act(burnlevel)
	take_damage(burnlevel/6, BURN, "fire")


/obj/structure/flora/tree/update_overlays()
	. = ..()
	if(on_fire)
		. += image(icon, "fire")

/obj/structure/flora/stump
	name = "stump"
	desc = "This represents our promise to cut down as many trees as possible."
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_stump"
	density = FALSE
	pixel_x = -16

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine"

/obj/structure/flora/tree/pine/Initialize()
	. = ..()
	icon_state = "[icon_state][rand(1, 3)]"

/obj/structure/flora/tree/xmas
	icon = 'icons/obj/flora/pinetrees.dmi'
	name = "xmas tree"
	icon_state = "pine_c"

/obj/structure/flora/tree/xmas/presents
	icon_state = "pinepresents"
	desc = "A wondrous decorated Christmas tree. It has presents!"
	var/gift_type = /obj/item/gift/marine
	var/list/ckeys_that_took = list()

/obj/structure/flora/tree/xmas/presents/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!user.ckey)
		return

	if(ckeys_that_took[user.ckey])
		to_chat(user, span_warning("There are no presents with your name on."))
		return
	to_chat(user, span_warning("After a bit of rummaging, you locate a gift with your name on it!"))
	ckeys_that_took[user.ckey] = TRUE
	var/obj/item/G = new gift_type(src)
	user.put_in_hands(G)

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree"

/obj/structure/flora/tree/dead/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency, 0, 1, 0, 0)

/obj/structure/flora/tree/dead/Initialize()
	. = ..()
	icon_state = "[icon_state][rand(1, 6)]"

/obj/structure/flora/tree/joshua
	name = "joshua tree"
	desc = "A tall tree covered in spiky-like needles, covering it's trunk."
	icon = 'icons/obj/flora/joshuatree.dmi'
	icon_state = "joshua"
	pixel_x = 0

/obj/structure/flora/tree/joshua/Initialize()
	. = ..()
	icon_state = "[icon_state][rand(1,4)]"

/obj/structure/flora/tree/jungle
	name = "jungle tree"
	icon_state = "tree"
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency, -1, 1, 2, 2)

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'

/obj/structure/flora/tree/jungle/small/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency)

/obj/structure/flora/tree/jungle/Initialize()
	. = ..()
	icon_state = "[icon_state][rand(1, 6)]"

//GRASS

/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = TRUE

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/Initialize()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"

/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/Initialize()
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/Initialize()
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"

//grayscale tall grass
/obj/structure/flora/grass/tallgrass
	name = "tall grass"
	icon = 'icons/obj/flora/tallgrass.dmi'
	icon_state = "tallgrass"
	layer = TALL_GRASS_LAYER
	opacity = TRUE

/obj/structure/flora/grass/tallgrass/tallgrasscorner
	name = "tall grass"
	icon_state = "tallgrass_corner"

//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = TRUE

/obj/structure/flora/bush/Initialize()
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-05"

/obj/structure/flora/pottedplant/one
	icon_state = "plant-01"

/obj/structure/flora/pottedplant/two
	icon_state = "plant-02"

/obj/structure/flora/pottedplant/ten
	icon_state = "plant-10"

/obj/structure/flora/pottedplant/eighteen
	icon_state = "plant-18"

/obj/structure/flora/pottedplant/twentyone
	icon_state = "plant-21"

/obj/structure/flora/pottedplant/twentytwo
	icon_state = "plant-22"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = TRUE

/obj/structure/flora/ausbushes/Initialize()
	. = ..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/Initialize()
	. = ..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/Initialize()
	. = ..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/Initialize()
	. = ..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/Initialize()
	. = ..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/Initialize()
	. = ..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/Initialize()
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/Initialize()
	. = ..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/Initialize()
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/Initialize()
	. = ..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/Initialize()
	. = ..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/Initialize()
	. = ..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/Initialize()
	. = ..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/Initialize()
	. = ..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/Initialize()
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/Initialize()
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"


//Desert (Desert Dam)
//*********************//
// Generic undergrowth //
//*********************//
/obj/structure/flora/desert
	anchored = TRUE
	icon = 'icons/obj/flora/dam.dmi'
	var/icon_tag = null
	var/variations = null

/obj/structure/flora/desert/Initialize()
	. = ..()
	icon_state = "[icon_tag]_[rand(1,variations)]"

//GRASS
/obj/structure/flora/desert/grass
	name = "grass"
	icon_state = "lightgrass_1"
	icon_tag = "lightgrass"
	variations = 12

/obj/structure/flora/desert/grass/one
	icon_state = "lightgrass_1"

/obj/structure/flora/desert/grass/two
	icon_state = "lightgrass_2"

/obj/structure/flora/desert/grass/three
	icon_state = "lightgrass_3"

/obj/structure/flora/desert/grass/four
	icon_state = "lightgrass_4"

/obj/structure/flora/desert/grass/five
	icon_state = "lightgrass_5"

/obj/structure/flora/desert/grass/six
	icon_state = "lightgrass_6"

/obj/structure/flora/desert/grass/seven
	icon_state = "lightgrass_7"

/obj/structure/flora/desert/grass/eight
	icon_state = "lightgrass_8"

/obj/structure/flora/desert/grass/nine
	icon_state = "lightgrass_9"

/obj/structure/flora/desert/grass/ten
	icon_state = "lightgrass_10"

/obj/structure/flora/desert/grass/eleven
	icon_state = "lightgrass_11"

/obj/structure/flora/desert/grass/twelve
	icon_state = "lightgrass_12"

/obj/structure/flora/desert/grass/heavy
	icon_state = "heavygrass_1"
	icon_tag = "heavygrass"
	variations = 16

/obj/structure/flora/desert/grass/heavy/one
	icon_state = "heavygrass_1"

/obj/structure/flora/desert/grass/heavy/two
	icon_state = "heavygrass_2"

/obj/structure/flora/desert/grass/heavy/three
	icon_state = "heavygrass_3"

/obj/structure/flora/desert/grass/heavy/four
	icon_state = "heavygrass_4"

/obj/structure/flora/desert/grass/heavy/five
	icon_state = "heavygrass_5"

/obj/structure/flora/desert/grass/heavy/six
	icon_state = "heavygrass_6"

/obj/structure/flora/desert/grass/heavy/seven
	icon_state = "heavygrass_7"

/obj/structure/flora/desert/grass/heavy/eight
	icon_state = "heavygrass_8"

/obj/structure/flora/desert/grass/heavy/nine
	icon_state = "heavygrass_9"

/obj/structure/flora/desert/grass/heavy/ten
	icon_state = "heavygrass_10"

/obj/structure/flora/desert/grass/heavy/eleven
	icon_state = "heavygrass_11"

/obj/structure/flora/desert/grass/heavy/twelve
	icon_state = "heavygrass_12"

/obj/structure/flora/desert/grass/heavy/thirteen
	icon_state = "heavygrass_13"

/obj/structure/flora/desert/grass/heavy/fourteen
	icon_state = "heavygrass_14"

/obj/structure/flora/desert/grass/heavy/fifteen
	icon_state = "heavygrass_15"

/obj/structure/flora/desert/grass/heavy/sixteen
	icon_state = "heavygrass_16"

//BUSHES
/obj/structure/flora/desert/bush
	name = "bush"
	desc = "A small, leafy bush."
	icon_state = "tree_1"
	icon_tag = "tree"
	variations = 4

//CACTUS
/obj/structure/flora/desert/cactus
	name = "cactus"
	desc = "It's a small, spiky cactus."
	icon_state = "cactus_1"
	icon_tag = "cactus"
	variations = 12

/obj/structure/flora/desert/cactus/one
	icon_state = "cactus_1"

/obj/structure/flora/desert/cactus/two
	icon_state = "cactus_2"

/obj/structure/flora/desert/cactus/three
	icon_state = "cactus_3"

/obj/structure/flora/desert/cactus/four
	icon_state = "cactus_4"

/obj/structure/flora/desert/cactus/five
	icon_state = "cactus_5"

/obj/structure/flora/desert/cactus/six
	icon_state = "cactus_6"

/obj/structure/flora/desert/cactus/seven
	icon_state = "cactus_7"

/obj/structure/flora/desert/cactus/eight
	icon_state = "cactus_8"

/obj/structure/flora/desert/cactus/nine
	icon_state = "cactus_9"

/obj/structure/flora/desert/cactus/ten
	icon_state = "cactus_10"

/obj/structure/flora/desert/cactus/eleven
	icon_state = "cactus_11"

/obj/structure/flora/desert/cactus/twelve
	icon_state = "cactus_12"

/obj/structure/flora/desert/cactus/multiple
	name = "cacti"
	icon_state = "cactus_1"
	icon_tag = "cacti"

/obj/structure/flora/desert/cactus/multiple/one
	icon_state = "cacti_1"

/obj/structure/flora/desert/cactus/multiple/two
	icon_state = "cacti_2"

/obj/structure/flora/desert/cactus/multiple/three
	icon_state = "cacti_3"

/obj/structure/flora/desert/cactus/multiple/four
	icon_state = "cacti_4"

/obj/structure/flora/desert/cactus/multiple/five
	icon_state = "cacti_5"

/obj/structure/flora/desert/cactus/multiple/six
	icon_state = "cacti_6"

/obj/structure/flora/desert/cactus/multiple/seven
	icon_state = "cacti_7"

/obj/structure/flora/desert/cactus/multiple/eight
	icon_state = "cacti_8"

/obj/structure/flora/desert/cactus/multiple/nine
	icon_state = "cacti_9"

/obj/structure/flora/desert/cactus/multiple/ten
	icon_state = "cacti_10"

/obj/structure/flora/desert/cactus/multiple/eleven
	icon_state = "cacti_11"

/obj/structure/flora/desert/cactus/multiple/twelve
	icon_state = "cacti_12"


//Jungle (Whiskey Outpost)

//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/jungle
	name = "jungle foliage"
	icon = 'icons/turf/ground_map.dmi'
	density = FALSE
	anchored = TRUE
	resistance_flags = UNACIDABLE
	layer = ABOVE_MOB_LAYER

/obj/structure/jungle/shrub
	name = "jungle foliage"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon_state = "grass4"

/obj/structure/jungle/plantbot1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "plantbot1"

/obj/structure/jungle/plantbot1/alien
	icon_state = "alienplant1"

/obj/structure/jungle/planttop1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "planttop1"

/obj/structure/jungle/vines
	name = "vines"
	desc = "A mass of twisted vines."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light2"

/obj/structure/jungle/vines/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.sharp != IS_SHARP_ITEM_BIG || !isliving(user))
		return

	var/mob/living/L = user

	to_chat(L, span_warning("You cut \the [src] away with \the [I]."))
	L.do_attack_animation(src, used_item = I)
	playsound(src, 'sound/effects/vegetation_hit.ogg', 25, 1)
	qdel(src)

/obj/structure/jungle/vines/Initialize()
	. = ..()
	icon_state = pick("Light1","Light2","Light3")

/obj/structure/jungle/vines/heavy
	desc = "A thick, coiled mass of twisted vines."
	opacity = TRUE

/obj/structure/jungle/vines/heavy/Initialize()
	. = ..()
	icon_state = pick("Hvy1","Hvy2","Hvy3","Med1","Med2","Med3")

/obj/structure/jungle/tree/grasscarpet
	name = "thick grass"
	desc = "A thick mat of dense grass."
	icon_state = "grasscarpet"
	layer = BELOW_MOB_LAYER

//ROCKS
/obj/structure/flora/rock
	name = "volcanic rock"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	icon = 'icons/obj/flora/rocks2.dmi'
	density = TRUE
	max_integrity = 250
	layer = ABOVE_TURF_LAYER
	coverage = 100
	icon_state = "basalt"

/obj/structure/flora/rock/alt
	name = "volcanic rock"
	icon_state = "basalt1"

/obj/structure/flora/rock/alt2
	name = "volcanic rock"
	icon_state = "basalt2"

/obj/structure/flora/rock/alt3
	name = "volcanic rock"
	icon_state = "basalt3"

/obj/structure/flora/rock/pile
	name = "rock pile"
	desc = "pile of volcanic rocks."
	density = FALSE
	icon_state = "lavarocks"

/obj/structure/flora/rock/pile/alt
	name = "rock pile"
	icon_state = "lavarocks1"

/obj/structure/flora/rock/pile/alt2
	name = "rock pile"
	icon_state = "lavarocks2"

/obj/structure/flora/rock/pile/alt3
	name = "fossils"
	desc = "A pile of ancient fossils. There are some oddly shaped skulls in here..."
	icon_state = "lavarocks3"
