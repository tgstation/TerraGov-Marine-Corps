
//turfs with density = FALSE
/turf/open
	var/is_groundmap_turf = FALSE //whether this a turf used as main turf type for the 'outside' of a map.
	var/allow_construction = TRUE //whether you can build things like barricades on this turf.
	var/slayer = 0 //snow layer
	var/wet = 0 //whether the turf is wet (only used by floors).


/turf/open/Entered(atom/A, atom/OL)
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(!C.lying && !(C.buckled && istype(C.buckled,/obj/structure/bed/chair)))
			if(ishuman(C))
				var/mob/living/carbon/human/H = C

				// Tracking blood
				var/list/bloodDNA = null
				var/bloodcolor=""
				if(H.shoes)
					var/obj/item/clothing/shoes/S = H.shoes
					if(S.track_blood && S.blood_DNA)
						bloodDNA = S.blood_DNA
						bloodcolor=S.blood_color
						S.track_blood--
				else
					if(H.track_blood && H.feet_blood_DNA)
						bloodDNA = H.feet_blood_DNA
						bloodcolor=H.feet_blood_color
						H.track_blood--

				if (bloodDNA)
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,H.dir,0,bloodcolor) // Coming
					var/turf/from = get_step(H,reverse_direction(H.dir))
					if(istype(from) && from)
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,H.dir,bloodcolor) // Going

					bloodDNA = null


			switch (wet)
				if(FLOOR_WET_WATER)
					if(!C.slip(null, 5, 3, TRUE))
						C.inertia_dir = 0

				if(FLOOR_WET_LUBE) //lube
					if(C.slip(null, 10, 10, FALSE, TRUE, 4))
						C.take_limb_damage(2)

				if(FLOOR_WET_ICE) // Ice
					if(!C.slip("icy floor", 4, 3, FALSE, TRUE, 1))
						C.inertia_dir = 0


	..()




/turf/open/examine(mob/user)
	..()
	ceiling_desc(user)




/turf/open/river
	can_bloody = FALSE




// Mars grounds

/turf/open/mars
	name = "sand"
	icon = 'icons/turf/bigred.dmi'
	icon_state = "mars_sand_1"
	is_groundmap_turf = TRUE


/turf/open/mars_cave
	name = "cave"
	icon = 'icons/turf/bigred.dmi'
	icon_state = "mars_cave_1"


/turf/open/mars_cave/New()
	..()

	spawn(10)
		var/r = rand(0, 2)

		if (r == 0 && icon_state == "mars_cave_2")
			icon_state = "mars_cave_3"

/turf/open/mars_dirt
	name = "dirt"
	icon = 'icons/turf/bigred.dmi'
	icon_state = "mars_dirt_1"


/turf/open/mars_dirt/New()
	..()
	spawn(10)
		var/r = rand(0, 32)

		if (r == 0 && icon_state == "mars_dirt_4")
			icon_state = "mars_dirt_1"
			return

		r = rand(0, 32)

		if (r == 0 && icon_state == "mars_dirt_4")
			icon_state = "mars_dirt_2"
			return

		r = rand(0, 6)

		if (r == 0 && icon_state == "mars_dirt_4")
			icon_state = "mars_dirt_7"





// Beach


/turf/open/beach
	name = "Beach"
	icon = 'icons/misc/beach.dmi'


/turf/open/beach/sand
	name = "Sand"
	icon_state = "sand"

/turf/open/beach/coastline
	name = "Coastline"
	icon = 'icons/misc/beach2.dmi'
	icon_state = "sandwater"

/turf/open/beach/water
	name = "Water"
	icon_state = "water"
	can_bloody = FALSE

/turf/open/beach/water/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water2","layer"=MOB_LAYER+0.1)

/turf/open/beach/water2
	name = "Water"
	icon_state = "water"
	can_bloody = FALSE

/turf/open/beach/water2/New()
	..()
	overlays += image("icon"='icons/misc/beach.dmi',"icon_state"="water5","layer"=MOB_LAYER+0.1)





//LV ground


/turf/open/gm //Basic groundmap turf parent
	name = "ground dirt"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "desert"


/turf/open/gm/ex_act(severity) //Should make it indestructable
	return

/turf/open/gm/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/gm/attackby() //This should fix everything else. No cables, etc
	return


/turf/open/gm/dirt
	name = "dirt"
	icon_state = "desert"

/turf/open/gm/dirt/New()
	..()
	if(rand(0,15) == 0)
		icon_state = "desert[pick("0","1","2","3")]"

/turf/open/gm/grass
	name = "grass"
	icon_state = "grass1"

/turf/open/gm/dirt2
	name = "dirt"
	icon_state = "dirt"


/turf/open/gm/dirtgrassborder
	name = "grass"
	icon_state = "grassdirt_edge"

/turf/open/gm/dirtgrassborder2
	name = "grass"
	icon_state = "grassdirt2_edge"


/turf/open/gm/river
	name = "river"
	icon_state = "seashallow"
	can_bloody = FALSE

/turf/open/gm/river/New()
	..()
	overlays += image("icon"='icons/turf/ground_map.dmi',"icon_state"="riverwater","layer"=MOB_LAYER+0.1)


/turf/open/gm/river/Entered(atom/movable/AM)
	..()
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		var/river_slowdown = 1.75

		if(ishuman(C))
			var/mob/living/carbon/human/H = AM
			cleanup(H)
			if(H.gloves && rand(0,100) < 60)
				if(istype(H.gloves,/obj/item/clothing/gloves/yautja))
					var/obj/item/clothing/gloves/yautja/Y = H.gloves
					if(Y && istype(Y) && Y.cloaked)
						H << "<span class='warning'> Your bracers hiss and spark as they short out!</span>"
						Y.decloak(H)

		else if(isXeno(C))
			river_slowdown = 1.3
			if(isXenoBoiler(C))
				river_slowdown = -0.5

		if(C.on_fire)
			C.ExtinguishMob()

		C.next_move_slowdown += river_slowdown

/turf/open/gm/river/proc/cleanup(var/mob/living/carbon/human/M)
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


/turf/open/gm/river/poison/New()
	..()
	overlays += image("icon"='icons/effects/effects.dmi',"icon_state"="greenglow","layer"=MOB_LAYER+0.1)

/turf/open/gm/river/poison/Entered(mob/living/M)
	..()
	if(istype(M)) M.apply_damage(55,TOX)



/turf/open/gm/coast
	name = "coastline"
	icon_state = "beach"

/turf/open/gm/riverdeep
	name = "river"
	icon_state = "seadeep"
	can_bloody = FALSE

/turf/open/gm/riverdeep/New()
	..()
	overlays += image("icon"='icons/turf/ground_map.dmi',"icon_state"="water","layer"=MOB_LAYER+0.1)




//ELEVATOR SHAFT-----------------------------------//
/turf/open/gm/empty
	name = "empty space"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	density = 1

/turf/open/gm/empty/is_weedable()
	return FALSE



//Nostromo turfs

/turf/open/nostromowater
	name = "ocean"
	desc = "Its a long way down to the ocean from here."
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "seadeep"
	can_bloody = FALSE




//Desert Map

/turf/open/desertdam //Basic groundmap turf parent
	name = "desert dirt"
	icon = 'icons/turf/desertdam_map.dmi'
	icon_state = "desert1"
	is_groundmap_turf = TRUE

/turf/open/desert/dam/ex_act(severity) //Should make it indestructable
	return

/turf/open/desertdam/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/desertdam/attackby() //This should fix everything else. No cables, etc
	return

//desert floor
/turf/open/desertdam/desert
	name = "desert"
	icon_state = "desert1"


//asphalt road
/turf/open/desertdam/asphault
	name = "asphault"
	icon_state = "sunbleached_asphalt1"



//CAVE
/turf/open/desertdam/cave
	icon_state = "outer_cave_floor1"

//desert floor to outer cave floor transition
/turf/open/desertdam/cave/desert_into_outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_transition1"

//outer cave floor
/turf/open/desertdam/cave/outer_cave_floor
	name = "cave"
	icon_state = "outer_cave_floor1"

//outer to inner cave floor transition
/turf/open/desertdam/cave/outer_cave_to_inner_cave
	name = "cave"
	icon_state = "outer_cave_to_inner1"

//inner cave floor
/turf/open/desertdam/cave/inner_cave_floor
	name = "cave"
	icon_state = "inner_cave_1"

//River
/turf/open/desertdam/river
	icon_state = "shallow_water_clean"


//shallow water
/turf/open/desertdam/river/clean/shallow
	name = "river"
	icon_state = "shallow_water_clean"
//shallow water transition to deep
/turf/open/desertdam/river/clean/shallow_edge
	name = "river"
	icon_state = "shallow_to_deep_clean_water1"
//deep water
/turf/open/desertdam/river/clean/deep_water_clean
	name = "river"
	icon_state = "deep_water_clean"
//shallow water coast
/turf/open/desertdam/river/clean/shallow_water_desert_coast
	name = "river"
	icon_state = "shallow_water_desert_coast1"
//desert floor waterway
/turf/open/desertdam/river/clean/shallow_water_desert_waterway
	name = "river"
	icon_state = "desert_waterway1"
//shallow water cave coast
/turf/open/desertdam/river/clean/shallow_water_cave_coast
	name = "river"
	icon_state = "shallow_water_cave_coast1"
//cave floor waterway
/turf/open/desertdam/river/clean/shallow_water_cave_waterway
	name = "river"
	icon_state = "shallow_water_cave_waterway1"

//TOXIC
/turf/open/desertdam/river/toxic
	icon_state = "shallow_water_toxic"

//shallow water
/turf/open/desertdam/river/toxic/shallow_water_toxic
	name = "river"
	icon_state = "shallow_water_toxic"
//shallow water transition to deep
/turf/open/desertdam/river/toxic/shallow_edge_toxic
	name = "river"
	icon_state = "shallow_to_deep_toxic_water1"
//deep water
/turf/open/desertdam/river/toxic/deep_water_toxic
	name = "river"
	icon_state = "deep_water_toxic"
//shallow water coast
/turf/open/desertdam/river/toxic/shallow_water_desert_coast_toxic
	name = "river"
	icon_state = "shallow_water_desert_coast_toxic1"
//desert floor waterway
/turf/open/desertdam/river/toxic/shallow_water_desert_waterway_toxic
	name = "river"
	icon_state = "desert_waterway_toxic1"
//shallow water cave coast
/turf/open/desertdam/river/toxic/shallow_water_cave_coast_toxic
	name = "river"
	icon_state = "shallow_water_cave_coast_toxic1"
//cave floor waterway
/turf/open/desertdam/river/toxic/shallow_water_cave_waterway_toxic
	name = "river"
	icon_state = "shallow_water_cave_waterway_toxic1"







//Ice Colony grounds

//Ice Floor
/turf/open/ice
	name = "ice floor"
	icon = 'icons/turf/ice.dmi'
	icon_state = "ice_floor"


//Randomize ice floor sprite
/turf/open/ice/New()
	..()
	dir = pick(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)





// Colony tiles
/turf/open/asphalt
	name = "asphalt"
	icon = 'icons/turf/asphalt.dmi'
	icon_state = "asphalt"




// Jungle turfs (Whiksey Outpost)


/turf/open/jungle
	allow_construction = FALSE
	var/bushes_spawn = 1
	var/plants_spawn = 1
	name = "wet grass"
	desc = "Thick, long wet grass"
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "grass1"
	var/icon_spawn_state = "grass1"

/turf/open/jungle/New()
	icon_state = icon_spawn_state

	if(plants_spawn && prob(40))
		if(prob(90))
			var/image/I
			if(prob(35))
				I = image('code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi',"plant[rand(1,7)]")
			else
				if(prob(30))
					I = image('icons/obj/flora/ausflora.dmi',"reedbush_[rand(1,4)]")
				else if(prob(33))
					I = image('icons/obj/flora/ausflora.dmi',"leafybush_[rand(1,3)]")
				else if(prob(50))
					I = image('icons/obj/flora/ausflora.dmi',"fernybush_[rand(1,3)]")
				else
					I = image('icons/obj/flora/ausflora.dmi',"stalkybush_[rand(1,3)]")
			I.pixel_x = rand(-6,6)
			I.pixel_y = rand(-6,6)
			overlays += I
		else
			var/obj/structure/jungle_plant/J = new(src)
			J.pixel_x = rand(-6,6)
			J.pixel_y = rand(-6,6)
	if(bushes_spawn && prob(90))
		new /obj/structure/bush(src)



/turf/open/jungle/proc/Spread(var/probability, var/prob_loss = 50)
	if(probability <= 0)
		return

	//world << "\blue Spread([probability])"
	for(var/turf/open/jungle/J in orange(1, src))
		if(!J.bushes_spawn)
			continue

		var/turf/open/jungle/P = null
		if(J.type == src.type)
			P = J
		else
			P = new src.type(J)

		if(P && prob(probability))
			P.Spread(probability - prob_loss)



/turf/open/jungle/clear
	bushes_spawn = 0
	plants_spawn = 0
	icon_state = "grass_clear"
	icon_spawn_state = "grass3"

/turf/open/jungle/path
	bushes_spawn = 0
	name = "dirt"
	desc = "it is very dirty."
	icon = 'code/WorkInProgress/Cael_Aislinn/Jungle/jungle.dmi'
	icon_state = "grass_path"
	icon_spawn_state = "dirt"

/turf/open/jungle/path/New()
	..()
	for(var/obj/structure/bush/B in src)
		cdel(B)

/turf/open/jungle/impenetrable
	bushes_spawn = 0
	icon_state = "grass_impenetrable"
	icon_spawn_state = "grass1"
	New()
		..()
		var/obj/structure/bush/B = new(src)
		B.indestructable = 1


/turf/open/jungle/water
	bushes_spawn = 0
	name = "murky water"
	desc = "thick, murky water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	icon_spawn_state = "water"
	can_bloody = FALSE


/turf/open/jungle/water/New()
	..()
	for(var/obj/structure/bush/B in src)
		cdel(B)

/turf/open/jungle/water/Entered(atom/movable/O)
	..()
	if(istype(O, /mob/living/))
		var/mob/living/M = O
		//slip in the murky water if we try to run through it
		if(prob(10 + (M.m_intent == MOVE_INTENT_RUN ? 40 : 0)))
			M << pick("\blue You slip on something slimy.","\blue You fall over into the murk.")
			M.Stun(2)
			M.KnockDown(1)

		//piranhas - 25% chance to be an omnipresent risk, although they do practically no damage
		if(prob(25))
			M << "\blue You feel something slithering around your legs."
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/open/jungle/water))
						M << pick("\red Something sharp bites you!","\red Sharp teeth grab hold of you!","\red You feel something take a chunk out of your leg!")
						M.apply_damage(rand(0,1), BRUTE, sharp=1)
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/open/jungle/water))
						M << pick("\red Something sharp bites you!","\red Sharp teeth grab hold of you!","\red You feel something take a chunk out of your leg!")
						M.apply_damage(rand(0,1), BRUTE, sharp=1)
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/open/jungle/water))
						M << pick("\red Something sharp bites you!","\red Sharp teeth grab hold of you!","\red You feel something take a chunk out of your leg!")
						M.apply_damage(rand(0,1), BRUTE, sharp=1)
			if(prob(50))
				spawn(rand(25,50))
					var/turf/T = get_turf(M)
					if(istype(T, /turf/open/jungle/water))
						M << pick("\red Something sharp bites you!","\red Sharp teeth grab hold of you!","\red You feel something take a chunk out of your leg!")
						M.apply_damage(rand(0,1), BRUTE, sharp=1)

/turf/open/jungle/water/deep
	plants_spawn = 0
	density = 1
	icon_state = "water2"
	icon_spawn_state = "water2"





//SHUTTLE 'FLOORS'
//not a child of turf/open/floor because shuttle floors are magic and don't behave like real floors.

/turf/open/shuttle
	name = "floor"
	icon_state = "floor"
	icon = 'icons/turf/shuttle.dmi'
	allow_construction = FALSE

/turf/open/shuttle/dropship
	name = "floor"
	icon_state = "rasputin1"


//not really plating, just the look
/turf/open/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/open/shuttle/brig // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/open/shuttle/escapepod
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "floor3"


// Elevator floors
/turf/open/shuttle/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "floor"

/turf/open/shuttle/elevator/grating
	icon_state = "floor_grating"


