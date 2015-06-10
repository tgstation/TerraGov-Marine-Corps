
/turf/simulated/floor/gm //Basic groundmap turf parent
	name = "ground dirt"
	icon = 'icons/ground_map.dmi'
	icon_state = "desert"
	floor_tile = null
	heat_capacity = 500000 //Shouldn't be possible, but you never know...

	ex_act(severity) //Should make it indestructable
		return

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	burn_tile() //All these should make the turf completely unmodifiable. Don't want people slapping plating and stuff down
		return

	break_tile()
		return

	make_plating()
		return

	attackby() //This should fix everything else. No cables, etc
		return

/turf/simulated/floor/gm/dirt
	name = "dirt"
	icon_state = "desert"

/turf/simulated/floor/gm/dirt/New()
	..()
	if(rand(0,15) == 0)
		icon_state = "desert[pick("0","1","2","3")]"

/turf/simulated/floor/gm/grass
	name = "grass"
	icon_state = "grass1"

/turf/simulated/floor/gm/dirtgrassborder
	name = "grass"
	icon_state = "grassdirt_edge"

/turf/simulated/floor/gm/river
	name = "river"
	icon_state = "seashallow"

/turf/simulated/floor/gm/river/New()
	..()
	overlays += image("icon"='icons/ground_map.dmi',"icon_state"="riverwater","layer"=MOB_LAYER+0.1)

/turf/simulated/floor/gm/coast
	name = "coastline"
	icon_state = "beach"

/turf/simulated/floor/gm/riverdeep
	name = "river"
	icon_state = "seadeep"

/turf/simulated/floor/gm/riverdeep/New()
	..()
	overlays += image("icon"='icons/ground_map.dmi',"icon_state"="water","layer"=MOB_LAYER+0.1)

//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/jungle
	name = "jungle foliage"
	icon = 'icons/ground_map.dmi'
	density = 0
	anchored = 1
	unacidable = 1 // can toggle it off anyway
	layer = MOB_LAYER+0.1

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
	icon = 'icons/ground_map64.dmi'
	desc = "What an enormous tree!"

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

/obj/structure/jungle/vines_lite
	name = "vines"
	desc = "A mass of twisted vines."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	layer = MOB_LAYER-0.1

/obj/structure/jungle/vines_heavy
	name = "vines"
	desc = "A thick, coiled mass of twisted vines."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Hvy1"
	layer = MOB_LAYER-0.1

/obj/structure/jungle/tree/grasscarpet
	name = "thick grass"
	desc = "A thick mat of dense grass."
	icon_state = "grasscarpet"
	layer = MOB_LAYER-0.1
