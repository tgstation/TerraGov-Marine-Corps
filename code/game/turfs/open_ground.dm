//LV ground

/turf/open/ground //Basic groundmap turf parent
	name = "ground dirt"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "desert"
	///Number of icon state variation this turf has
	var/icon_variants = 1

/turf/open/ground/update_icon_state()
	if(icon_variants < 2)
		return initial(icon_state)
	return "[initial(icon_state)]_[rand(1, icon_variants)]"

/turf/open/ground/AfterChange()
	. = ..()
	baseturfs = type

/turf/open/ground/fire_act(exposed_temperature, exposed_volume)
	return

/turf/open/ground/attackby() //This should fix everything else. No cables, etc
	return

/turf/open/ground/grass/beach
	icon_state = "grassbeach_edge"

/turf/open/ground/grass/beach/corner
	icon_state = "grassbeach_corner"

/turf/open/ground/grass/beach/corner2
	icon_state = "grassbeach_corner2"

/turf/open/ground/coast
	name = "coastline"
	icon_state = "beach"
	shoefootstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	mediumxenofootstep = FOOTSTEP_SAND
	minimap_color = MINIMAP_WATER
	smoothing_groups = list(
		SMOOTH_GROUP_RIVER,
	)

/turf/open/ground/coast/corner
	icon_state = "beachcorner"

/turf/open/ground/coast/corner2
	icon_state = "beachcorner2"

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
	if(vines_spawn && prob(8))
		new /obj/structure/flora/jungle/vines(src)


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

/turf/open/ground/jungle/impenetrable
	vines_spawn = TRUE
	icon_state = "grass_impenetrable"
	icon_spawn_state = "grass1"

/turf/open/ground/jungle/impenetrable/nobush
	vines_spawn = FALSE

//ELEVATOR SHAFT-----------------------------------//
/turf/open/ground/empty
	name = "empty space"
	icon = 'icons/turf/floors.dmi'
	icon_state = "black"
	density = TRUE

/turf/open/ground/empty/is_weedable()
	return FALSE
