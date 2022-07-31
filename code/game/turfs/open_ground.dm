//LV ground

/turf/open/ground //Basic groundmap turf parent
	name = "ground dirt"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "desert"

/turf/open/ground/AfterChange()
	. = ..()
	baseturfs = type

/turf/open/ground/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/ground/attackby() //This should fix everything else. No cables, etc
	return

/turf/open/ground/grass/beach
	icon_state = "grassbeach"

/turf/open/ground/grass/beach/corner
	icon_state = "gbcorner"

/turf/open/ground/river
	name = "river"
	icon_state = "seashallow"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

/atom/movable/effect/river_overlay
	name = "river_overlay"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = RIVER_OVERLAY_LAYER
	plane = FLOOR_PLANE


/turf/open/ground/river/Initialize()
	. = ..()
	if(!has_catwalk)
		var/atom/movable/effect/river_overlay/R = new(src)
		R.overlays += image("icon"='icons/turf/ground_map.dmi',"icon_state"="riverwater","layer"=RIVER_OVERLAY_LAYER)


/turf/open/ground/river/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(has_catwalk)
		return
	if(iscarbon(arrived))
		var/mob/living/carbon/C = arrived
		var/river_slowdown = 1.75

		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			cleanup(H)

		else if(isxeno(C))
			if(!isxenoboiler(C))
				river_slowdown = 1.3
			else
				river_slowdown = -0.5

		if(C.on_fire)
			C.ExtinguishMob()

		C.next_move_slowdown += river_slowdown


/turf/open/ground/river/proc/cleanup(mob/living/carbon/human/H)
	if(H.back?.clean_blood())
		H.update_inv_back()
	if(H.wear_suit?.clean_blood())
		H.update_inv_wear_suit()
	if(H.w_uniform?.clean_blood())
		H.update_inv_w_uniform()
	if(H.gloves?.clean_blood())
		H.update_inv_gloves()
	if(H.shoes?.clean_blood())
		H.update_inv_shoes()
	H.clean_blood()


/turf/open/ground/river/poison/Initialize()
	. = ..()
	if(has_catwalk)
		return
	var/atom/movable/effect/river_overlay/R = new(src)
	R.overlays += image("icon"='icons/effects/effects.dmi',"icon_state"="greenglow","layer"=RIVER_OVERLAY_LAYER)


/turf/open/ground/river/poison/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!isliving(arrived))
		return
	var/mob/living/L = arrived
	L.apply_damage(55, TOX)
	UPDATEHEALTH(L)


/turf/open/ground/coast
	name = "coastline"
	icon_state = "beach"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND

/turf/open/ground/coast/corner
	icon_state = "beachcorner"

/turf/open/ground/coast/corner2
	icon_state = "beachcorner2"

/turf/open/ground/riverdeep
	name = "river"
	icon_state = "seadeep"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

/turf/open/ground/riverdeep/Initialize()
	. = ..()
	if(!has_catwalk)
		var/atom/movable/effect/river_overlay/R = new(src)
		R.overlays += image("icon"='icons/turf/ground_map.dmi',"icon_state"="water","layer"=RIVER_OVERLAY_LAYER)

//Desert River
/turf/open/ground/river/desertdam
	name = "river"
	icon = 'icons/turf/desertdam_map.dmi'
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER

/turf/open/ground/river/desertdam/Initialize() //needed to avoid visual bugs with the river
	return

//shallow water
/turf/open/ground/river/desertdam/clean/shallow
	icon_state = "shallow_water_clean"

//shallow water transition to deep
/turf/open/ground/river/desertdam/clean/shallow_edge
	icon_state = "shallow_to_deep_clean_water"

/turf/open/ground/river/desertdam/clean/shallow_edge/corner
	icon_state = "shallowcorner1"

/turf/open/ground/river/desertdam/clean/shallow_edge/corner2
	icon_state = "shallowcorner2"

/turf/open/ground/river/desertdam/clean/shallow_edge/alt
	icon_state = "shallow_to_deep_clean_water1"

//deep water
/turf/open/ground/river/desertdam/clean/deep_water_clean
	icon_state = "deep_water_clean"

//shallow water coast
/turf/open/ground/river/desertdam/clean/shallow_water_desert_coast
	icon_state = "shallow_water_desert_coast"

/turf/open/ground/river/desertdam/clean/shallow_water_desert_coast/edge
	icon_state = "shallow_water_desert_coast_edge"

//desert floor waterway
/turf/open/ground/river/desertdam/clean/shallow_water_desert_waterway
	icon_state = "desert_waterway"

/turf/open/ground/river/desertdam/clean/shallow_water_desert_waterway/edge
	icon_state = "desert_waterway_edge"

//shallow water cave coast
/turf/open/ground/river/desertdam/clean/shallow_water_cave_coast
	icon_state = "shallow_water_cave_coast"

//cave floor waterway
/turf/open/ground/river/desertdam/clean/shallow_water_cave_waterway
	icon_state = "shallow_water_cave_waterway"

/turf/open/ground/river/desertdam/clean/shallow_water_cave_waterway/edge
	icon_state = "shallow_water_cave_waterway_edge"

//TOXIC
/turf/open/ground/river/desertdam/toxic
	name = "toxic river"
	icon_state = "shallow_water_toxic"

//shallow water
/turf/open/ground/river/desertdam/toxic/shallow_water_toxic
	icon_state = "shallow_water_toxic"

//shallow water transition to deep
/turf/open/ground/river/desertdam/toxic/shallow_edge_toxic
	icon_state = "shallow_to_deep_toxic_water"

/turf/open/ground/river/desertdam/toxic/shallow_edge_toxic/alt
	icon_state = "shallow_to_deep_toxic_water1"

/turf/open/ground/river/desertdam/toxic/shallow_edge_toxic/edge
	icon_state = "shallow_to_deep_toxic_edge"

//deep water
/turf/open/ground/river/desertdam/toxic/deep_water_toxic
	icon_state = "deep_water_toxic"

//shallow water coast
/turf/open/ground/river/desertdam/toxic/shallow_water_desert_coast_toxic
	icon_state = "shallow_water_desert_coast_toxic"

/turf/open/ground/river/desertdam/toxic/shallow_water_desert_coast_toxic/edge
	icon_state = "shallow_water_desert_coast_toxic_edge"

//desert floor waterway
/turf/open/ground/river/desertdam/toxic/shallow_water_desert_waterway_toxic
	icon_state = "desert_waterway_toxic"

/turf/open/ground/river/desertdam/toxic/shallow_water_desert_waterway_toxic/edge
	icon_state = "desert_waterway_toxic_edge"

//shallow water cave coast
/turf/open/ground/river/desertdam/toxic/shallow_water_cave_coast_toxic
	icon_state = "shallow_water_cave_coast_toxic"

/turf/open/ground/river/desertdam/toxic/shallow_water_cave_coast_toxic/edge
	icon_state = "shallow_water_cave_coast_toxic_edge"

//cave floor waterway
/turf/open/ground/river/desertdam/toxic/shallow_water_cave_waterway_toxic
	icon_state = "shallow_water_cave_waterway_toxic"

/turf/open/ground/river/desertdam/toxic/shallow_water_cave_waterway_toxic/edge
	icon_state = "shallow_water_cave_waterway_toxic_edge"

// Jungle turfs (Whiksey Outpost)

/turf/open/ground/jungle
	allow_construction = FALSE
	var/vines_spawn = TRUE
	var/plants_spawn = FALSE
	name = "wet grass"
	desc = "Thick, long wet grass"
	icon = 'icons/turf/jungle.dmi'
	icon_state = "grass1"
	var/icon_spawn_state = "grass1"
	shoefootstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	mediumxenofootstep = FOOTSTEP_GRASS


/turf/open/ground/jungle/Initialize(mapload, ...)
	. = ..()
	icon_state = icon_spawn_state

	if(plants_spawn && prob(40))
		if(prob(90))
			var/image/I
			if(prob(35))
				I = image('icons/obj/structures/jungle.dmi',"plant[rand(1,7)]")
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
	if(vines_spawn && prob(8))
		new /obj/structure/jungle/vines(src)


/turf/open/ground/jungle/proc/Spread(probability, prob_loss = 50)
	if(probability <= 0)
		return

	//to_chat(world, span_notice("Spread([probability])"))
	for(var/turf/open/ground/jungle/J in orange(1, src))
		if(!J.vines_spawn)
			continue

		var/turf/open/ground/jungle/P
		if(J.type == src.type)
			P = J
		else
			P = new src.type(J)

		if(prob(probability))
			P?.Spread(probability - prob_loss)


/turf/open/ground/jungle/clear
	vines_spawn = FALSE
	plants_spawn = FALSE
	icon_state = "grass_clear"
	icon_spawn_state = "grass3"

/turf/open/ground/jungle/path
	vines_spawn = FALSE
	name = "dirt"
	desc = "it is very dirty."
	icon = 'icons/turf/jungle.dmi'
	icon_state = "grass_path"
	icon_spawn_state = "dirt"


/turf/open/ground/jungle/path/Initialize(mapload, ...)
	. = ..()
	for(var/obj/structure/bush/B in src)
		qdel(B)


/turf/open/ground/jungle/impenetrable
	vines_spawn = TRUE
	icon_state = "grass_impenetrable"
	icon_spawn_state = "grass1"

/turf/open/ground/jungle/impenetrable/nobush
	vines_spawn = FALSE

/turf/open/ground/jungle/impenetrable/Initialize()
	. = ..()
	if(vines_spawn)
		var/obj/structure/bush/B = new(src)
		ENABLE_BITFIELD(B.resistance_flags, INDESTRUCTIBLE)


/turf/open/ground/jungle/water
	vines_spawn = FALSE
	name = "murky water"
	desc = "thick, murky water"
	icon = 'icons/misc/beach.dmi'
	icon_state = "water"
	icon_spawn_state = "water"
	can_bloody = FALSE
	shoefootstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	mediumxenofootstep = FOOTSTEP_WATER
	heavyxenofootstep = FOOTSTEP_WATER


/turf/open/ground/jungle/water/Initialize(mapload, ...)
	. = ..()
	for(var/obj/structure/bush/B in src)
		qdel(B)


/turf/open/ground/jungle/water/Entered(atom/movable/arrived, direction)
	. = ..()
	if(!istype(arrived, /mob/living))
		return
	var/mob/living/L = arrived
	//slip in the murky water if we try to run through it
	if(prob(10 + (L.m_intent == MOVE_INTENT_RUN ? 40 : 0)))
		to_chat(L, pick(span_notice(" You slip on something slimy."), span_notice("You fall over into the murk.")))
		L.Stun(40)
		L.Paralyze(20)

	//piranhas
	if(prob(25))
		to_chat(L, pick(span_warning(" Something sharp bites you!"),span_warning(" Sharp teeth grab hold of you!"),span_warning(" You feel something take a chunk out of your leg!")))
		L.apply_damage(1, BRUTE, sharp = TRUE)


/turf/open/ground/jungle/water/deep
	plants_spawn = FALSE
	density = TRUE
	icon_state = "water2"
	icon_spawn_state = "water2"


//ELEVATOR SHAFT-----------------------------------//
/turf/open/ground/empty
	name = "empty space"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	density = TRUE

/turf/open/ground/empty/is_weedable()
	return FALSE
