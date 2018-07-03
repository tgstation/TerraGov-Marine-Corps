//trees
/obj/structure/flora/tree
	name = "tree"
	anchored = 1
	density = 1
	pixel_x = -16
	layer = ABOVE_FLY_LAYER

/obj/structure/flora/tree/pine
	name = "pine tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/New()
	..()
	icon_state = "pine_[rand(1, 3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_c"

/obj/structure/flora/tree/pine/xmas/New()
	..()
	icon_state = "pine_c"

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	icon_state = "tree_1"

/obj/structure/flora/tree/dead/New()
	..()
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree/joshua
	name = "joshua tree"
	desc = "A tall tree covered in spiky-like needles, covering it's trunk."
	icon = 'icons/obj/flora/joshuatree.dmi'
	icon_state = "joshua_1"
	pixel_x = 0
/obj/structure/flora/tree/joshua/New()
	..()
	icon_state = "joshua_[rand(1,4)]"

//grass
/obj/structure/flora/grass
	name = "grass"
	icon = 'icons/obj/flora/snowflora.dmi'
	anchored = 1

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"

/obj/structure/flora/grass/brown/New()
	..()
	icon_state = "snowgrass[rand(1, 3)]bb"


/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"

/obj/structure/flora/grass/green/New()
	..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"

/obj/structure/flora/grass/both/New()
	..()
	icon_state = "snowgrassall[rand(1, 3)]"


//bushes
/obj/structure/flora/bush
	name = "bush"
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"
	anchored = 1

/obj/structure/flora/bush/New()
	..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/pottedplant
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-26"

//newbushes

/obj/structure/flora/ausbushes
	name = "bush"
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	anchored = 1

/obj/structure/flora/ausbushes/New()
	..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/reedbush
	icon_state = "reedbush_1"

/obj/structure/flora/ausbushes/reedbush/New()
	..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/leafybush
	icon_state = "leafybush_1"

/obj/structure/flora/ausbushes/leafybush/New()
	..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/palebush
	icon_state = "palebush_1"

/obj/structure/flora/ausbushes/palebush/New()
	..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/stalkybush
	icon_state = "stalkybush_1"

/obj/structure/flora/ausbushes/stalkybush/New()
	..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/grassybush
	icon_state = "grassybush_1"

/obj/structure/flora/ausbushes/grassybush/New()
	..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/fernybush
	icon_state = "fernybush_1"

/obj/structure/flora/ausbushes/fernybush/New()
	..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/sunnybush
	icon_state = "sunnybush_1"

/obj/structure/flora/ausbushes/sunnybush/New()
	..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/ausbushes/genericbush
	icon_state = "genericbush_1"

/obj/structure/flora/ausbushes/genericbush/New()
	..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/pointybush
	icon_state = "pointybush_1"

/obj/structure/flora/ausbushes/pointybush/New()
	..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/ausbushes/lavendergrass
	icon_state = "lavendergrass_1"

/obj/structure/flora/ausbushes/lavendergrass/New()
	..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/ausbushes/ywflowers
	icon_state = "ywflowers_1"

/obj/structure/flora/ausbushes/ywflowers/New()
	..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/brflowers
	icon_state = "brflowers_1"

/obj/structure/flora/ausbushes/brflowers/New()
	..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/ausbushes/ppflowers
	icon_state = "ppflowers_1"

/obj/structure/flora/ausbushes/ppflowers/New()
	..()
	icon_state = "ppflowers_[rand(1, 4)]"

/obj/structure/flora/ausbushes/sparsegrass
	icon_state = "sparsegrass_1"

/obj/structure/flora/ausbushes/sparsegrass/New()
	..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/ausbushes/fullgrass
	icon_state = "fullgrass_1"

/obj/structure/flora/ausbushes/fullgrass/New()
	..()
	icon_state = "fullgrass_[rand(1, 3)]"


//Desert (Desert Dam)
//*********************//
// Generic undergrowth //
//*********************//
/obj/structure/flora/desert
	anchored = 1
	icon = 'icons/obj/flora/dam.dmi'
	var/icon_tag = null
	var/variations = null

/obj/structure/flora/desert/New()
	..()
	icon_state = "[icon_tag]_[rand(1,variations)]"

//GRASS
/obj/structure/flora/desert/grass
	name = "grass"
	icon_state = "lightgrass_1"
	icon_tag = "lightgrass"
	variations = 12

/obj/structure/flora/desert/grass/heavy
	icon_state = "heavygrass_1"
	icon_tag = "heavygrass"
	variations = 16

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

/obj/structure/flora/desert/cactus/multiple
	name = "cacti"
	icon_state = "cactus_1"
	icon_tag = "cacti"


//Jungle (Whiskey Outpost)

//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/jungle
	name = "jungle foliage"
	icon = 'icons/turf/ground_map.dmi'
	density = 0
	anchored = 1
	unacidable = 1 // can toggle it off anyway
	layer = ABOVE_MOB_LAYER

/obj/structure/jungle/shrub
	name = "jungle foliage"
	desc = "Pretty thick scrub, it'll take something sharp and a lot of determination to clear away."
	icon_state = "grass4"

/obj/structure/jungle/plantbot1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "plantbot1"

/obj/structure/jungle/planttop1
	name = "strange tree"
	desc = "Some kind of bizarre alien tree. It oozes with a sickly yellow sap."
	icon_state = "planttop1"

/obj/structure/jungle/tree
	icon = 'icons/obj/flora/ground_map64.dmi'
	desc = "What an enormous tree!"
	layer = ABOVE_FLY_LAYER

/obj/structure/jungle/tree/bigtreeTR
	name = "huge tree"
	icon_state = "bigtreeTR"

/obj/structure/jungle/tree/bigtreeTL
	name = "huge tree"
	icon_state = "bigtreeTL"

/obj/structure/jungle/tree/bigtreeBOT
	name = "huge tree"
	icon_state = "bigtreeBOT"

/obj/structure/jungle/treeblocker
	name = "huge tree"
	icon_state = ""	//will this break it?? - Nope
	density = 1

/obj/structure/jungle/vines
	name = "vines"
	desc = "A mass of twisted vines."
	icon = 'icons/effects/spacevines.dmi'

/obj/structure/jungle/vines/attackby(obj/item/W, mob/living/user)
	if(W.sharp == IS_SHARP_ITEM_BIG)
		user << "<span class='warning'>You cut \the [src] away with \the [W].</span>"
		user.animation_attack_on(src)
		playsound(src, 'sound/effects/vegetation_hit.ogg', 25, 1)
		cdel(src)
	else
		. = ..()

/obj/structure/jungle/vines/New()
	..()
	icon_state = pick("Light1","Light2","Light3")

/obj/structure/jungle/vines/heavy
	desc = "A thick, coiled mass of twisted vines."
	opacity = 1

/obj/structure/jungle/vines/heavy/New()
	..()
	icon_state = pick("Hvy1","Hvy2","Hvy3","Med1","Med2","Med3")

/obj/structure/jungle/tree/grasscarpet
	name = "thick grass"
	desc = "A thick mat of dense grass."
	icon_state = "grasscarpet"
	layer = BELOW_MOB_LAYER