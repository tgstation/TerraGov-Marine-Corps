/obj/structure/flora
	anchored = TRUE
	max_integrity = 25
	coverage = 30
	var/on_fire = FALSE
	///number of icon variants this object has
	var/icon_variants = NONE

/obj/structure/flora/Initialize(mapload)
	. = ..()
	if(icon_variants)
		icon_state = "[initial(icon_state)]_[rand(1, icon_variants)]"

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
		if(EXPLODE_WEAK)
			if(prob(10))
				qdel(src)


/obj/structure/flora/flamer_fire_act(burnlevel)
	take_damage(burnlevel, BURN, FIRE)

/obj/structure/flora/fire_act()
	take_damage(25, BURN, FIRE)


//TREES

/obj/structure/flora/tree
	name = "tree"
	desc = "A large tree."
	density = TRUE
	pixel_x = -16
	max_integrity = 500
	layer = ABOVE_FLY_LAYER
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	var/log_amount = 10

/obj/structure/flora/tree/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_WOOD, -10, 5)

/obj/structure/flora/tree/Initialize(mapload)
	. = ..()
	AddTransparencyComponent()

//Adds the transparency component, exists to be overridden for different args.
/obj/structure/flora/tree/proc/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency)

/obj/structure/flora/tree/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(rand(140, 300), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 50), BRUTE, BOMB)
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
	if(!do_after(user, cutting_time , NONE, src, BUSY_ICON_BUILD))
		return

	user.visible_message(span_notice("[user] fells [src] with the [I]."),span_notice("You fell [src] with the [I]."), "You hear the sound of a tree falling.")
	playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 10 , 0, 0)
	for(var/i in 1 to log_amount)
		new /obj/item/grown/log(get_turf(src))

	var/obj/structure/flora/stump/S = new(loc)
	S.name = "[name] stump"

	qdel(src)

/obj/structure/flora/tree/flamer_fire_act(burnlevel)
	take_damage(burnlevel/6, BURN, FIRE)


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
	icon_variants = 3

/obj/structure/flora/tree/xmas
	icon = 'icons/obj/flora/pinetrees.dmi'
	name = "xmas tree"
	icon_state = "pine_c"
	icon_variants = NONE

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
	icon_variants = 6

/obj/structure/flora/tree/dead/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency, 0, 1, 0, 0)

/obj/structure/flora/tree/dead/drought
	name = "dead tree"
	desc = "A dead tree. Its probably seen better days."
	icon = 'icons/obj/flora/tall_trees.dmi'
	icon_state = "dead_tree"
	icon_variants = 3

/obj/structure/flora/tree/joshua
	name = "joshua tree"
	desc = "A tall tree covered in spiky-like needles, covering it's trunk."
	icon = 'icons/obj/flora/joshuatree.dmi'
	icon_state = "joshua"
	pixel_x = 0
	icon_variants = 4

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
	icon_variants = 6

/obj/structure/flora/tree/jungle/small/AddTransparencyComponent()
	AddComponent(/datum/component/largetransparency)

//GRASS

/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = TRUE

/obj/structure/flora/grass/brown
	icon_state = "snowgrass_bb"
	icon_variants = 3

/obj/structure/flora/grass/green
	icon_state = "snowgrass_gb"
	icon_variants = 3

/obj/structure/flora/grass/both
	icon_state = "snowgrassall"
	icon_variants = 3

//grayscale tall grass
/obj/structure/flora/grass/tallgrass
	name = "tall grass"
	icon = 'icons/obj/flora/tallgrass.dmi'
	icon_state = "tallgrass"
	layer = TALL_GRASS_LAYER
	opacity = TRUE
	color = "#7a8c54"

/obj/structure/flora/grass/tallgrass/tallgrasscorner
	name = "tall grass"
	icon_state = "tallgrass_corner"

/obj/structure/flora/grass/tallgrass/hideable
	layer = BUSH_LAYER

/obj/structure/flora/grass/tallgrass/hideable/tallgrasscorner
	icon_state = "tallgrass_corner"

/obj/structure/flora/grass/tallgrass/autosmooth
	name = "tall grass"
	icon = 'icons/obj/flora/smooth/tall_grass.dmi'
	icon_state = "tallgrass-icon"
	base_icon_state = "tallgrass"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TALL_GRASS)
	canSmoothWith = list(
		SMOOTH_GROUP_TALL_GRASS,
		SMOOTH_GROUP_ASTEROID_WARNING,
		SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS,
		SMOOTH_GROUP_MINERAL_STRUCTURES,
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_FLORA,
		SMOOTH_GROUP_WINDOW_FRAME,
	)

//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush"
	anchored = TRUE
	icon_variants = 6

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-05"

/obj/structure/flora/pottedplant/one
	icon_state = "plant-01"

/obj/structure/flora/pottedplant/two
	icon_state = "plant-02"

/obj/structure/flora/pottedplant/three
	icon_state = "plant-03"

/obj/structure/flora/pottedplant/four
	icon_state = "plant-04"

/obj/structure/flora/pottedplant/five
	icon_state = "plant-05"

/obj/structure/flora/pottedplant/six
	icon_state = "plant-06"

/obj/structure/flora/pottedplant/seven
	icon_state = "plant-07"

/obj/structure/flora/pottedplant/eight
	icon_state = "plant-08"

/obj/structure/flora/pottedplant/nine
	icon_state = "plant-09"

/obj/structure/flora/pottedplant/ten
	icon_state = "plant-10"

/obj/structure/flora/pottedplant/eleven
	icon_state = "plant-11"

/obj/structure/flora/pottedplant/twelve
	icon_state = "plant-12"

/obj/structure/flora/pottedplant/thirteen
	icon_state = "plant-13"

/obj/structure/flora/pottedplant/fourteen
	icon_state = "plant-14"

/obj/structure/flora/pottedplant/fifteen
	icon_state = "plant-15"

/obj/structure/flora/pottedplant/sixteen
	icon_state = "plant-16"

/obj/structure/flora/pottedplant/seventeen
	icon_state = "plant-17"

/obj/structure/flora/pottedplant/eighteen
	icon_state = "plant-18"

/obj/structure/flora/pottedplant/nineteen
	icon_state = "plant-19"

/obj/structure/flora/pottedplant/twenty
	icon_state = "plant-19"

/obj/structure/flora/pottedplant/twentyone
	icon_state = "plant-21"

/obj/structure/flora/pottedplant/twentytwo
	icon_state = "plant-22"

/obj/structure/flora/pottedplant/twentythree
	icon_state = "plant-23"

/obj/structure/flora/pottedplant/twentyfour
	icon_state = "plant-24"

/obj/structure/flora/pottedplant/twentyfive
	icon_state = "plant-25"

/obj/structure/flora/pottedplant/twentyfive
	icon_state = "plant-26"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush"
	anchored = TRUE
	icon_variants = 4

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush"
	icon_variants = 3

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush"
	icon_variants = 3

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush"
	icon_variants = 3

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush"
	icon_variants = 3

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers"
	icon_variants = 3

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers"
	icon_variants = 3

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass"
	icon_variants = 3

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass"
	icon_variants = 3


//Desert (Desert Dam)
//*********************//
// Generic undergrowth //
//*********************//
/obj/structure/flora/desert
	anchored = TRUE
	icon = 'icons/obj/flora/dam.dmi'

//GRASS
/obj/structure/flora/desert/grass
	name = "grass"
	icon_state = "lightgrass"
	icon_variants = 12

/obj/structure/flora/desert/grass/heavy
	icon_state = "heavygrass"
	icon_variants = 16

//BUSHES
/obj/structure/flora/desert/bush
	name = "bush"
	desc = "A small, leafy bush."
	icon_state = "tree"
	icon_variants = 4

//CACTUS
/obj/structure/flora/desert/cactus
	name = "cactus"
	desc = "It's a small, spiky cactus."
	icon_state = "cactus"
	icon_variants = 12

/obj/structure/flora/desert/cactus/multiple
	name = "cacti"
	icon_state = "cacti"


//Jungle (Whiskey Outpost)

//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/flora/jungle
	name = "jungle foliage"
	icon = 'icons/turf/ground_map.dmi'
	layer = ABOVE_MOB_LAYER

/obj/structure/flora/jungle/shrub
	name = "jungle foliage"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon_state = "grass4"

/obj/structure/flora/jungle/plantbot1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "plantbot1"

/obj/structure/flora/jungle/plantbot1/alien
	icon_state = "alienplant1"

/obj/structure/flora/jungle/planttop1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "planttop1"

/obj/structure/flora/jungle/bush
	name = "jungle bush"
	desc = "A small leafy plant."
	icon_state = "bush"
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_variants = 9
	layer = OBJ_LAYER

/obj/structure/flora/jungle/grass
	name = "jungle grass"
	desc = "some type of grass species."
	icon_state = "grass"
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_variants = 5
	layer = OBJ_LAYER

/obj/structure/flora/jungle/grass/thin
	icon_state = "grass_thin"

/obj/structure/flora/jungle/large_bush
	name = "large plant"
	desc = "A large leafy plant."
	icon_state = "bush"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	layer = ABOVE_MOB_LAYER
	pixel_x = -16
	pixel_y = -8
	icon_variants = 3

/obj/structure/flora/jungle/large_bush/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/largetransparency, 0, 0, 0, 1)

/obj/structure/flora/jungle/vines
	name = "vines"
	desc = "A mass of twisted vines."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light2"

/obj/structure/flora/jungle/vines/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.sharp != IS_SHARP_ITEM_BIG || !isliving(user))
		return

	var/mob/living/L = user

	to_chat(L, span_warning("You cut \the [src] away with \the [I]."))
	L.do_attack_animation(src, used_item = I)
	playsound(src, 'sound/effects/vegetation_hit.ogg', 25, 1)
	qdel(src)

/obj/structure/flora/jungle/vines/Initialize(mapload)
	. = ..()
	icon_state = pick("Light1","Light2","Light3")

/obj/structure/flora/jungle/vines/heavy
	desc = "A thick, coiled mass of twisted vines."
	opacity = TRUE

/obj/structure/flora/jungle/vines/heavy/Initialize(mapload)
	. = ..()
	icon_state = pick("Hvy1","Hvy2","Hvy3","Med1","Med2","Med3")


//drought map flora
/obj/structure/flora/drought
	icon = 'icons/obj/flora/desert_flora.dmi'

//GRASS
/obj/structure/flora/drought/grass
	name = "grass"
	desc = "Some dried up grass."
	icon_state = "drygrass"
	icon_variants = 15

/obj/structure/flora/drought/tall_cactus
	name = "cactus"
	desc = "Some tall, spikey looking cactus."
	icon_state = "tall_cactus"
	icon_variants = 3
	density = TRUE

/obj/structure/flora/drought/short_cactus
	name = "cactus"
	desc = "Some short, spikey looking cactus."
	icon_state = "short_cactus"
	icon_variants = 3

/obj/structure/flora/drought/barrel_cactus
	name = "cactus"
	desc = "Some plump, spikey looking cactus."
	icon_state = "barrel"
	icon_variants = 6

/obj/structure/flora/drought/leafy_plant
	name = "plant"
	desc = "A tough looking little plant."
	icon_state = "leafy_plant"
	icon_variants = 3

/obj/structure/flora/drought/yucca
	name = "yucca bush"
	desc = "A hardy little bush. Its flowers are said to have medicinal properties."
	icon_state = "yucca"
	icon_variants = 2

/obj/structure/flora/drought/xander
	name = "xander bush"
	desc = "A tough little shrub. Supposedly has medicinal properties when dried."
	icon_state = "xander"
	icon_variants = 2

/obj/structure/flora/drought/broc
	name = "broc flower tree"
	desc = "A small desert shrub. It doesn't look terribly happy."
	icon_state = "broc_flower"
	icon_variants = 2

/obj/structure/flora/drought/aster
	name = "aster bush"
	desc = "A tough little shrub. It produces pretty blue flowers."
	icon_state = "aster"
	icon_variants = 2

/obj/structure/flora/drought/ash
	name = "ash rose"
	desc = "A tough little shrub with wickly sharp thorns. The flowers are prized for their strong aroma."
	icon_state = "ash_rose"
	icon_variants = 2

//cave flora
/obj/structure/flora/drought/shroom
	name = "fungus"
	desc = "A small patch of brown fungus. Eating them is probably a terrible idea."
	icon_state = "shroom"
	icon_variants = 3

/obj/structure/flora/drought/shroom/glow
	name = "glowing fungus"
	desc = "A small patch of luminescent fungus. Eating them is definitely a terrible idea."
	icon_state = "glowshroom"

/obj/structure/flora/drought/shroom/blight
	name = "blight mushroom"
	desc = "A small patch of blight mushrooms. Extremely toxic."
	icon_state = "blightshroom"

/obj/structure/flora/drought/shroom/brain
	name = "ash rose"
	desc = "A small patch of brain fungus. Apparently delicious when correctly prepared."
	icon_state = "brainshroom"

/obj/structure/flora/drought/shroom/fire
	name = "ash rose"
	desc = "A small patch of fire mushrooms. Doesn't actually cause fire."
	icon_state = "fireshroom"

/obj/structure/flora/drought/shroom/gut
	name = "ash rose"
	desc = "A small patch of gut mushrooms. Is supposed to cause a prolonged, agonising death."
	icon_state = "gutshroom"

/obj/structure/flora/drought/shroom/nara_root
	name = "ash rose"
	desc = "A small patch of nara root fungus. Supposedly has healing properties."
	icon_state = "narashroom"

/obj/structure/flora/drought/shroom/lure_weed
	name = "lure weed"
	desc = "A long, tough little fungus."
	icon_state = "lureweed"

/obj/structure/flora/drought/broc/cave
	desc = "A small desert shrub. It looks surprisingly happy in the gloom."
	icon_state = "broc_flower_cave"
	icon_variants = 2

/obj/structure/flora/drought/xander/cave
	desc = "A tough little plant. Supposedly has medicinal properties when dried."
	icon_state = "xander_cave"
	icon_variants = 2
