/turf/unsimulated/floor/mars
	name = "sand"
	icon = 'icons/turf/bigred.dmi'
	icon_state = "mars_sand_1"
	is_groundmap_turf = TRUE

/turf/unsimulated/floor/mars_cave
	name = "cave"
	icon = 'icons/turf/bigred.dmi'
	icon_state = "mars_cave_1"

/turf/unsimulated/floor/mars_cave/New()
	..()

	spawn(10)
		var/r = rand(0, 2)

		if (r == 0 && icon_state == "mars_cave_2")
			icon_state = "mars_cave_3"

/turf/unsimulated/floor/mars_dirt
	name = "dirt"
	icon = 'icons/turf/bigred.dmi'
	icon_state = "mars_dirt_1"

/turf/unsimulated/floor/mars_dirt/New()
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