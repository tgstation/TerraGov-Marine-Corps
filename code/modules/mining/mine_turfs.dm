/**********************Mineral deposits**************************/


/turf/simulated/mineral //wall piece
	name = "Rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	oxygen = 20
	nitrogen = 80
	opacity = 1
	density = 1
	blocks_air = 1
	temperature = T20C

/turf/simulated/mineral/New()

	spawn(2)
		var/list/step_overlays = list("s" = NORTH, "n" = SOUTH, "w" = EAST, "e" = WEST)
		for(var/direction in step_overlays)
			var/turf/turf_to_check = get_step(src,step_overlays[direction])

			if(istype(turf_to_check,/turf/space) || istype(turf_to_check,/turf/simulated/floor) || istype(turf_to_check, /turf/unsimulated/floor))
				turf_to_check.overlays += image('icons/turf/walls.dmi', "rock_side_[direction]", 2.99) //Really high since it's an overhead turf and it shouldn't collide with anything else
