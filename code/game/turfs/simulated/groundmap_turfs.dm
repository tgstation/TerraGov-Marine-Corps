
/turf/unsimulated/floor/gm //Basic groundmap turf parent
	name = "ground dirt"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "desert"
//	floor_tile = null
	heat_capacity = 500000 //Shouldn't be possible, but you never know...

	ex_act(severity) //Should make it indestructable
		return

	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	attackby() //This should fix everything else. No cables, etc
		return

/turf/unsimulated/floor/gm/dirt
	name = "dirt"
	icon_state = "desert"

/turf/unsimulated/floor/gm/dirt/New()
	..()
	if(rand(0,15) == 0)
		icon_state = "desert[pick("0","1","2","3")]"

/turf/unsimulated/floor/gm/grass
	name = "grass"
	icon_state = "grass1"

//Ground map walls
/turf/unsimulated/wall/gm
	name = "dense jungle"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "wall2"
	desc = "Some thick jungle."
	density = 1
	opacity = 1

	//Not yet
	ex_act(severity)
		switch(severity)
			if(1.0)
				src.ChangeTurf(/turf/unsimulated/floor/gm/grass)
				return
			if(2.0)
				return
			if(3.0)
				return
	fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		return

	attackby() //Put machete-cutting here later
		return


/turf/unsimulated/wall/gm/dense
	name = "dense jungle wall"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "wall2"

	New()
		spawn(1)
			if(rand(0,15) == 0)
				icon_state = "wall1"
			else if (rand(0,20) == 0)
				icon_state = "wall3"
			else
				icon_state = "wall2"


/turf/unsimulated/floor/gm/dirtgrassborder
	name = "grass"
	icon_state = "grassdirt_edge"

/turf/unsimulated/floor/gm/river
	name = "river"
	icon_state = "seashallow"

/turf/unsimulated/floor/gm/river/New()
	..()
	overlays += image("icon"='icons/turf/ground_map.dmi',"icon_state"="riverwater","layer"=MOB_LAYER+0.1)

/turf/unsimulated/floor/gm/river/proc/cleanup(var/mob/living/carbon/human/M)
	if(!M || !istype(M)) return

	if(M.back)
		if(M.back.clean_blood())
			M.update_inv_back(0)
	if(M.wear_suit)
		if(M.wear_suit.clean_blood())
			M.update_inv_wear_suit(0)
	if(M.w_uniform)
		if(M.w_uniform.clean_blood())
			M.update_inv_w_uniform(0)
	if(M.gloves)
		if(M.gloves.clean_blood())
			M.update_inv_gloves(0)
	if(M.shoes)
		if(M.shoes.clean_blood())
			M.update_inv_shoes(0)
	M.clean_blood()

/turf/unsimulated/floor/gm/coast
	name = "coastline"
	icon_state = "beach"

/turf/unsimulated/floor/gm/riverdeep
	name = "river"
	icon_state = "seadeep"

/turf/unsimulated/floor/gm/riverdeep/New()
	..()
	overlays += image("icon"='icons/turf/ground_map.dmi',"icon_state"="water","layer"=MOB_LAYER+0.1)

//*********************//
// Generic undergrowth //
//*********************//

/obj/structure/jungle
	name = "jungle foliage"
	icon = 'icons/turf/ground_map.dmi'
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
	icon = 'icons/obj/flora/ground_map64.dmi'
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



//Sulaco walls. They use wall instead of shuttle code so they overlap and we can do fun stuff to them without using unsimulated shuttle things.
/turf/simulated/wall/sulaco
	name = "spaceship hull"
	desc = "A huge chunk of metal used to separate rooms on spaceships from the cold void of space."
	icon = 'icons/turf/walls.dmi'
	icon_state = "sulaco0"
	hull = 1 //Can't be deconstructed

	damage_cap = 8000 //As tough as R_walls.
	max_temperature = 28000 //K, walls will take damage if they're next to a fire hotter than this
	walltype = "sulaco" //Changes all the sprites and icons.
/*
	attackby(obj/item/W as obj, mob/user as mob) //Can't be dismantled, thermited, etc. Can be xeno-acided still.
		user << "This wall is much too tough for you to do anything to with [W]."
		return
*/

/turf/simulated/wall/sulaco/ex_act(severity)
	switch(severity)
		if(1.0)
			src.ChangeTurf(/turf/simulated/floor/plating)
		if(2.0)
			if(prob(75))
				take_damage(rand(100, 250))
			else
				dismantle_wall(1,1)
		if(3.0)
			take_damage(rand(0, 250))

	return

