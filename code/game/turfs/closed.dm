

//turfs with density = TRUE
/turf/closed
	density = 1
	opacity = 1





/turf/closed/mineral
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"

/turf/closed/mineral/Initialize(mapload)
    . = ..()
    for(var/direction in GLOB.cardinals)
        var/turf/turf_to_check = get_step(src, direction)
        if(istype(turf_to_check, /turf/open))
            var/image/rock_side = image(icon, "[icon_state]_side", dir = turn(direction, 180))
            switch(direction)
                if(NORTH)
                    rock_side.pixel_y += world.icon_size
                if(SOUTH)
                    rock_side.pixel_y -= world.icon_size
                if(EAST)
                    rock_side.pixel_x += world.icon_size
                if(WEST)
                    rock_side.pixel_x -= world.icon_size
            overlays += rock_side

/turf/closed/mineral/bigred
	name = "rock"
	icon_state = "redrock"


//Ground map dense jungle
/turf/closed/gm
	name = "dense jungle"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "wall2"
	desc = "Some thick jungle."

	//Not yet
/turf/closed/gm/ex_act(severity)
	switch(severity)
		if(1)
			ChangeTurf(/turf/open/ground/grass)


/turf/closed/gm/dense
	name = "dense jungle wall"
	icon = 'icons/turf/ground_map.dmi'
	icon_state = "wall2"

/turf/closed/gm/dense/Initialize()
	. = ..()
	if(rand(0,15) == 0)
		icon_state = "wall1"
	else if (rand(0,20) == 0)
		icon_state = "wall3"
	else
		icon_state = "wall2"




//desertdam rock
/turf/closed/desertdamrockwall
    name = "rockwall"
    icon = 'icons/turf/desertdam_map.dmi'
    icon_state = "cavewall1"








//ICE WALLS-----------------------------------//
//Ice Wall
/turf/closed/ice
	name = "dense ice wall"
	icon = 'icons/turf/icewall.dmi'
	icon_state = "Single"
	desc = "It is very thick."

/turf/closed/ice/single
	icon_state = "Single"

/turf/closed/ice/end
	icon_state = "End"

/turf/closed/ice/straight
	icon_state = "Straight"

/turf/closed/ice/corner
	icon_state = "Corner"

/turf/closed/ice/junction
	icon_state = "T_Junction"

/turf/closed/ice/intersection
	icon_state = "Intersection"



//Ice Thin Wall
/turf/closed/ice/thin
	name = "thin ice wall"
	icon = 'icons/turf/icewalllight.dmi'
	icon_state = "Single"
	desc = "It is very thin."
	opacity = 0

/turf/closed/ice/thin/single
	icon_state = "Single"

/turf/closed/ice/thin/end
	icon_state = "End"

/turf/closed/ice/thin/straight
	icon_state = "Straight"

/turf/closed/ice/thin/corner
	icon_state = "Corner"

/turf/closed/ice/thin/junction
	icon_state = "T_Junction"

/turf/closed/ice/thin/intersection
	icon_state = "Intersection"

/turf/closed/attackby(obj/item/W, mob/user)
	. = ..()
	if(istype(W, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = W
		if(!ismineralturf(src) && !istype(src, /turf/closed/gm/dense) && !istype(src, /turf/closed/ice) && !istype(src, /turf/closed/desertdamrockwall))
			to_chat(user, "<span class='warning'>[P] can't cut through this!</span>")
			return
		if(!P.start_cut(user, src.name, src))
			return
		if(do_after(user, PLASMACUTTER_CUT_DELAY, TRUE, src, BUSY_ICON_BUILD))
			P.cut_apart(user, src.name, src)
			if(ismineralturf(src) || istype(src, /turf/closed/desertdamrockwall))
				ChangeTurf(/turf/open/floor/plating/ground/desertdam/cave/inner_cave_floor)
			else if(istype(src, /turf/closed/gm/dense))
				ChangeTurf(/turf/open/ground/jungle/clear)
			else
				ChangeTurf(/turf/open/floor/plating/ground/ice)


//Ice Secret Wall
/turf/closed/ice/secret
	icon_state = "ice_wall_0"
	desc = "There is something inside..."


//ROCK WALLS------------------------------//

//Icy Rock
/turf/closed/ice_rock
	name = "Icy rock"
	icon = 'icons/turf/rockwall.dmi'

/turf/closed/ice_rock/single
	icon_state = "single"

/turf/closed/ice_rock/singlePart
	icon_state = "single_part"

/turf/closed/ice_rock/singleT
	icon_state = "single_tshape"

/turf/closed/ice_rock/singleEnd
	icon_state = "single_ends"

/turf/closed/ice_rock/fourway
	icon_state = "4-way"

/turf/closed/ice_rock/corners
	icon_state = "full_corners"

//Directional walls each have 4 possible sprites and are
//randomized on New().
/turf/closed/ice_rock/northWall
	icon_state = "north_wall"

/turf/closed/ice_rock/northWall/New()
	. = ..()
	setDir(pick(NORTH,SOUTH,EAST,WEST))

/turf/closed/ice_rock/southWall
	icon_state = "south_wall"

/turf/closed/ice_rock/southWall/New()
	. = ..()
	setDir(pick(NORTH,SOUTH,EAST,WEST))

/turf/closed/ice_rock/westWall
	icon_state = "west_wall"

/turf/closed/ice_rock/westWall/New()
	. = ..()
	setDir(pick(NORTH,SOUTH,EAST,WEST))

/turf/closed/ice_rock/eastWall
	icon_state = "east_wall"

/turf/closed/ice_rock/eastWall/New()
	. = ..()
	setDir(pick(NORTH,SOUTH,EAST,WEST))


//SHUTTLE 'WALLS'
//not a child of turf/closed/wall because shuttle walls are magical, don't smoothes with normal walls, etc

/turf/closed/shuttle
	name = "wall"
	icon_state = "wall1"
	icon = 'icons/turf/shuttle.dmi'

/turf/closed/shuttle/diagonal
	icon_state = "diagonalWall"

/turf/closed/shuttle/diagonal/plating
	icon_state = "diagonalWallplating"
	opacity = FALSE

/turf/closed/shuttle/diagonal/sea
	icon_state = "diagonalWallsea"
	opacity = FALSE

/turf/closed/shuttle/wall3
	icon_state = "wall3"

/turf/closed/shuttle/wall3/diagonal
	icon_state = "diagonalWall3"

/turf/closed/shuttle/wall3/diagonal/plating
	icon_state = "diagonalWall3plating"
	opacity = FALSE

/turf/closed/shuttle/wall3/diagonal/sea
	icon_state = "diagonalWall3sea"
	opacity = FALSE

/turf/closed/shuttle/dropship
	icon = 'icons/turf/walls.dmi'
	icon_state = "rasputin1"

/turf/closed/shuttle/ert
	icon = 'icons/turf/ert_shuttle.dmi'
	icon_state = "stan4"


/turf/closed/shuttle/dropship1
	name = "\improper Alamo"
	icon = 'icons/turf/dropship.dmi'
	icon_state = "1"

/turf/closed/shuttle/dropship1/transparent
	opacity = 0

/turf/closed/shuttle/dropship2
	name = "\improper Normandy"
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"

/turf/closed/shuttle/dropship2/transparent
	opacity = 0

/turf/closed/shuttle/escapepod
	name = "wall"
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "wall0"




// Elevator walls (directional)
/turf/closed/shuttle/elevator
	icon = 'icons/turf/elevator.dmi'
	icon_state = "wall"

// Wall with gears that animate when elevator is moving
/turf/closed/shuttle/elevator/gears
	icon_state = "wall_gear"

/turf/closed/shuttle/elevator/gears/proc/start()
	icon_state = "wall_gear_animated"

/turf/closed/shuttle/elevator/gears/proc/stop()
	icon_state = "wall_gear"

// Special wall icons
/turf/closed/shuttle/elevator/research
	icon_state = "wall_research"

/turf/closed/shuttle/elevator/dorm
	icon_state = "wall_dorm"

/turf/closed/shuttle/elevator/freight
	icon_state = "wall_freight"

/turf/closed/shuttle/elevator/arrivals
	icon_state = "wall_arrivals"

// Elevator Buttons
/turf/closed/shuttle/elevator/button
	name = "elevator buttons"

/turf/closed/shuttle/elevator/button/research
	icon_state = "wall_button_research"

/turf/closed/shuttle/elevator/button/dorm
	icon_state = "wall_button_dorm"

/turf/closed/shuttle/elevator/button/freight
	icon_state = "wall_button_freight"

/turf/closed/shuttle/elevator/button/arrivals
	icon_state = "wall_button_arrivals"
