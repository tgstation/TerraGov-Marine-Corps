//-----USS Almayer Turfs ---//

// alls

/turf/simulated/wall/almayer
	name = "hull"
	desc = "A huge chunk of metal used to seperate rooms and make up the ship."
	icon = 'icons/turf/almayer.dmi'
	icon_state = "testwall0"
//	mineral = "silver"
	walltype = "testwall"
	hull = 1 //1 = Can't be deconstructed by tools or thermite. Used for Sulaco walls

	damage = 0
	damage_cap = 10000 //Wall will break down to girders if damage reaches this point

	max_temperature = 18000 //K, walls will take damage if they're next to a fire hotter than this

	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer)

/turf/simulated/wall/almayer/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	icon_state = "testwall0"
	walltype = "testwall"
//	mineral = "testwall"


//Floors

/turf/simulated/floor/almayer
	icon = 'icons/turf/almayer.dmi'
	icon_state = "default"

/turf/simulated/floor/almayer/plating
	name = "plating"
	icon_state = "plating"
	floor_tile = null
	intact = 0

//Others

/obj/structure/window/reinforced/almayer
	name = "reinforced glass"
	desc = "A very tough looking window, probably bullet proof."
	icon = 'icons/turf/almayer.dmi'
	icon_state = "rwindow0"
	basestate = "rwindow"
	health = 600
	reinf = 1
	dir = 5

	tiles_with = list(
		/turf/simulated/wall,
		/obj/structure/falsewall,
		/obj/structure/falserwall,
		/obj/structure/window/reinforced/almayer)

/obj/structure/window/reinforced/almayer/New()
	spawn(10)
		relativewall()
		relativewall_neighbours()

/obj/structure/window/reinforced/almayer/update_nearby_icons()
	relativewall_neighbours()

/obj/structure/window/reinforced/almayer/update_icon()
	relativewall()