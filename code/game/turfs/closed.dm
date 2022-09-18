

//turfs with density = TRUE
/turf/closed
	density = TRUE
	opacity = TRUE

///Base state, for icon_state updates.
	var/walltype
	///The neighbours
	var/junctiontype = NONE
	///used for plasmacutter deconstruction
	var/open_turf_type = /turf/open/floor/plating

/turf/closed/mineral
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	smoothing_behavior = NONE
	smoothing_groups = NONE
	open_turf_type = /turf/open/floor/plating/ground/desertdam/cave/inner_cave_floor

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

/turf/closed/mineral/smooth
	name = "rock"
	icon = 'icons/turf/walls/lvwall.dmi'
	icon_state = "lvwall-0-0-0-0"
	walltype = "lvwall"
	smoothing_behavior = DIAGONAL_SMOOTHING
	smoothing_groups = SMOOTH_MINERAL_STRUCTURES

/turf/closed/mineral/smooth/indestructible
	resistance_flags = RESIST_ALL

/turf/closed/mineral/smooth/snowrock
	icon = 'icons/turf/walls/snowwall.dmi'
	icon_state = "snowwall-0-0-0-0"
	walltype = "snowwall"

/turf/closed/mineral/smooth/snowrock/indestructible
	resistance_flags = RESIST_ALL

/turf/closed/mineral/smooth/bigred
	icon = 'icons/turf/walls/redwall.dmi'
	icon_state = "red_wall-0-0-0-0"
	walltype = "red_wall"

/turf/closed/mineral/smooth/bigred/indestructible
	resistance_flags = RESIST_ALL

/turf/closed/mineral/bigred
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "redrock"
	smoothing_behavior = NO_SMOOTHING //big red does not currently have its own 3/4ths cave tileset, so it uses the old one without smoothing
	smoothing_groups = NONE

/turf/closed/mineral/indestructible
	name = "impenetrable rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock_dark"
	smoothing_behavior = DIAGONAL_SMOOTHING
	smoothing_groups = SMOOTH_MINERAL_STRUCTURES
	resistance_flags = RESIST_ALL

//Ground map dense jungle
/turf/closed/gm
	icon = 'icons/turf/walls/jungle.dmi'
	icon_state = "jungle-0-0-0-0"
	desc = "Some thick jungle."
	smoothing_behavior = DIAGONAL_SMOOTHING
	smoothing_groups = SMOOTH_FLORA
	walltype = "jungle"
	open_turf_type = /turf/open/ground/jungle/clear

/turf/closed/gm/tree
	name = "dense jungle trees"
	icon_state = "jungletree"
	desc = "Some thick jungle trees."

	//Not yet
/turf/closed/gm/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			ChangeTurf(/turf/open/ground/grass)

/turf/closed/gm/dense
	name = "dense jungle wall"
	resistance_flags = PLASMACUTTER_IMMUNE

//desertdam rock
/turf/closed/desertdamrockwall
	name = "rockwall"
	icon = 'icons/turf/walls/cave.dmi'
	icon_state = "cave_wall-0-0-0-0"
	color = "#c9a37b"
	walltype = "cave_wall"
	smoothing_behavior = DIAGONAL_SMOOTHING
	smoothing_groups = SMOOTH_GENERAL_STRUCTURES
	open_turf_type = /turf/open/floor/plating/ground/desertdam/cave/inner_cave_floor

/turf/closed/desertdamrockwall/invincible
	resistance_flags = RESIST_ALL

/turf/closed/desertdamrockwall/invincible/perimeter
	name = "wall"
	icon_state = "pwall"
	icon = 'icons/turf/shuttle.dmi'

//lava rock
/turf/closed/brock
	name = "basalt rock"
	icon = 'icons/turf/lava.dmi'
	icon_state = "brock"
	open_turf_type = /turf/open/lavaland/basalt


/turf/closed/brock/Initialize(mapload)
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

//ICE WALLS-----------------------------------//
//Ice Wall
/turf/closed/ice
	name = "dense ice wall"
	icon = 'icons/turf/icewall.dmi'
	icon_state = "Single"
	desc = "It is very thick."
	open_turf_type = /turf/open/floor/plating/ground/ice

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

//volcanic glass wall
/turf/closed/glass/thin
	name = "volcanic glass wall"
	icon = 'icons/turf/icewalllight.dmi'
	icon_state = "Single"
	desc = "Hardened volcanic glass."
	opacity = FALSE

/turf/closed/glass/thin/single
	icon_state = "Single"

/turf/closed/glass/thin/end
	icon_state = "End"

/turf/closed/glass/thin/straight
	icon_state = "Straight"

/turf/closed/glass/thin/corner
	icon_state = "Corner"

/turf/closed/glass/thin/junction
	icon_state = "T_Junction"

/turf/closed/glass/thin/intersection
	icon_state = "Intersection"

/turf/closed/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(CHECK_BITFIELD(resistance_flags, RESIST_ALL) || CHECK_BITFIELD(resistance_flags, PLASMACUTTER_IMMUNE))
			to_chat(user, span_warning("[P] can't cut through this!"))
			return
		else if(!P.start_cut(user, name, src))
			return
		else if(!do_after(user, PLASMACUTTER_CUT_DELAY, TRUE, src, BUSY_ICON_FRIENDLY))
			return
		else
			P.cut_apart(user, name, src) //purely a cosmetic effect

		//change targetted turf to a new one to simulate deconstruction
		ChangeTurf(open_turf_type)

//Ice Thin Wall
/turf/closed/ice/thin
	name = "thin ice wall"
	icon = 'icons/turf/icewalllight.dmi'
	icon_state = "Single"
	desc = "It is very thin."
	opacity = FALSE

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

//ROCK WALLS------------------------------//

//Icy Rock
/turf/closed/ice_rock
	name = "Icy rock"
	icon = 'icons/turf/rockwall.dmi'
	resistance_flags = PLASMACUTTER_IMMUNE
	open_turf_type = /turf/open/floor/plating/ground/ice

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
	plane = FLOOR_PLANE
	smoothing_behavior = NO_SMOOTHING
	resistance_flags = PLASMACUTTER_IMMUNE

/turf/closed/shuttle/re_corner/notdense
	icon_state = "re_cornergrass"
	density = FALSE

/turf/closed/shuttle/re_corner/jungle
	icon_state = "re_cornerjungle"
	density = FALSE

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

/turf/closed/shuttle/swall3
	icon_state = "swall3"

/turf/closed/shuttle/wall3/diagonal
	icon_state = "diagonalWall3"

/turf/closed/shuttle/wall4/diagonal
	icon_state = "diag_gray"

/turf/closed/shuttle/wall3/diagonal/white
	icon_state = "diagonalWall3white"

/turf/closed/shuttle/wall3/diagonal/plating
	icon_state = "diagonalWall3plating"
	opacity = FALSE

/turf/closed/shuttle/wall3/diagonal/sea
	icon_state = "diagonalWall3sea"
	opacity = FALSE

/turf/closed/shuttle/dropship
	icon = 'icons/turf/walls.dmi'
	icon_state = "rasputin1"
	plane = GAME_PLANE

/turf/closed/shuttle/ert
	icon = 'icons/turf/ert_shuttle.dmi'
	icon_state = "stan4"
	plane = GAME_PLANE


/turf/closed/shuttle/dropship1
	name = "\improper Alamo"
	icon = 'icons/turf/dropship.dmi'
	icon_state = "1"
	plane = GAME_PLANE

/turf/closed/shuttle/dropship1/transparent
	opacity = FALSE

/turf/closed/shuttle/dropship3
	name = "\improper Triumph"
	icon = 'icons/turf/dropship.dmi'
	icon_state = "1"
	plane = GAME_PLANE

/turf/closed/shuttle/dropship3/transparent
	opacity = FALSE

/turf/closed/shuttle/dropship2
	name = "\improper Normandy"
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"
	plane = GAME_PLANE

/turf/closed/shuttle/dropship2/transparent
	opacity = FALSE


/turf/closed/shuttle/escapepod
	name = "wall"
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "wall0"
	plane = GAME_PLANE


/turf/closed/banish_space //Brazil
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	icon = 'icons/turf/space.dmi'
	name = "phantom zone"
	icon_state = "0"
	can_bloody = FALSE
	light_power = 0.25
