/obj/effect/decal/mars_rocks
	name = "rock"
	icon = 'icons/effects/mars/mars32.dmi'
	icon_state = "mars_tile1"

/obj/effect/decal/mars_rocks/rock
	name = "rock"
	icon_state = "rock1"

/obj/effect/decal/mars_rocks/rock/Initialize()
	. = ..()
	icon_state = "[name][rand(1,5)]"

/obj/effect/decal/mars_rocks/boulder
	name = "boulder"
	icon_state = "boulder1"

/obj/effect/decal/mars_rocks/boulder/Initialize()
	. = ..()
	icon_state = "[name][rand(1,4)]"

/obj/effect/decal/mars_rocks/crater
	name = "crater"
	icon_state = "mars_crater32"

/obj/effect/decal/mars_rocks/crater/medium
	name = "crater"
	icon = 'icons/effects/mars/mars64.dmi'
	icon_state = "mars_crater64"

/obj/effect/decal/mars_rocks/crater/large
	name = "crater"
	icon = 'icons/effects/mars/mars96.dmi'
	icon_state = "mars_crater96"
