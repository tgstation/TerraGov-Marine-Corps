

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

/turf/closed/Initialize(mapload)
	. = ..()
	add_debris_element()

/turf/closed/hitby(atom/movable/AM, speed = 5)
	AM.stop_throw()
	AM.turf_collision(src, speed)
	return TRUE

/turf/closed/mineral
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	open_turf_type = /turf/open/floor/plating/ground/desertdam/cave/inner_cave_floor
	minimap_color = MINIMAP_BLACK
	resistance_flags = UNACIDABLE

/turf/closed/mineral/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/turf/closed/mineral/Initialize(mapload)
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/turf_to_check = get_step(src, direction)
		if(!isnull(turf_to_check) && !turf_to_check.density)
			var/image/rock_side = image(icon, "[icon_state]_side", dir = REVERSE_DIR(direction))
			switch(direction)
				if(NORTH)
					rock_side.pixel_y += world.icon_size
				if(SOUTH)
					rock_side.pixel_y -= world.icon_size
				if(EAST)
					rock_side.pixel_x += world.icon_size
				if(WEST)
					rock_side.pixel_x -= world.icon_size
			if(!isspaceturf(turf_to_check))
				minimap_color = MINIMAP_SOLID
			overlays += rock_side

/turf/closed/mineral/attack_alien(mob/living/carbon/xenomorph/xeno_user, isrightclick = FALSE)
	. = ..()
	if(isxenobehemoth(xeno_user))
		xeno_user.do_attack_animation(src)
		playsound(src, 'sound/effects/behemoth/earth_pillar_eating.ogg', 10, TRUE)
		xeno_user.visible_message(span_xenowarning("\The [xeno_user] eats away at the [src.name]!"), \
		span_xenonotice(pick(
			"We eat away at the stone. It tastes good, as expected of our primary diet.",
			"Mmmmm... Delicious rock. A fitting meal for the hardiest of creatures.",
			"This boulder -- its flavor fills us with glee. Our palate is thoroughly satisfied.",
			"These minerals are tasty! We want more!",
			"Eating this stone makes us think; is our hide tougher? It is. It must be...",
			"A delectable flavor. Just one bite is not enough...",
			"One bite, two bites... why not just finish the whole rock?",
			"The stone. The rock. The boulder. Its name matters not when we consume it.",
			"Delicious, delectable, simply exquisite. Just a few more minerals and it'd be perfect...")), null, 5)

/turf/closed/mineral/smooth
	name = "rock"
	icon = 'icons/turf/walls/lvwall.dmi'
	base_icon_state = "lvwall"
	icon_state = "lvwall-0"
	walltype = "lvwall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_MINERAL_STRUCTURES)
	canSmoothWith = list(SMOOTH_GROUP_MINERAL_STRUCTURES)

/turf/closed/mineral/smooth/outdoor
	open_turf_type = /turf/open/floor/plating/ground/mars/random/dirt

/turf/closed/mineral/smooth/indestructible
	name = "tough rock"
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/mineral/smooth/snowrock
	icon = 'icons/turf/walls/snowwall.dmi'
	icon_state = "snowwall-0"
	walltype = "snowwall"
	base_icon_state = "snowwall"

/turf/closed/mineral/smooth/snowrock/indestructible
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/mineral/smooth/frostwall
	icon = 'icons/turf/walls/frostwall.dmi'
	icon_state = "frostwall-0"
	walltype = "frostwall"
	base_icon_state = "frostwall"

/turf/closed/mineral/smooth/frostwall/indestructible
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/mineral/smooth/darkfrostwall
	icon = 'icons/turf/walls/darkfrostwall.dmi'
	icon_state = "darkfrostwall-0"
	walltype = "darkfrostwall"
	base_icon_state = "darkfrostwall"
	resistance_flags = PLASMACUTTER_IMMUNE|UNACIDABLE

/turf/closed/mineral/smooth/darkfrostwall/indestructible
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/mineral/smooth/bluefrostwall
	icon = 'icons/turf/walls/bluefrostwall.dmi'
	icon_state = "bluefrostwall-0"
	walltype = "bluefrostwall"
	base_icon_state = "bluefrostwall"
	smoothing_groups = list(SMOOTH_GROUP_ICE_WALL)
	canSmoothWith = list(SMOOTH_GROUP_ICE_WALL)

/turf/closed/mineral/smooth/bluefrostwall/indestructible
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/mineral/smooth/bigred
	icon = 'icons/turf/walls/redwall.dmi'
	icon_state = "red_wall-0"
	walltype = "red_wall"
	base_icon_state = "red_wall"

/turf/closed/mineral/smooth/bigred/indestructible
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/mineral/bigred
	name = "rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "redrock" //big red does not currently have its own 3/4ths cave tileset, so it uses the old one without smoothing

/turf/closed/mineral/indestructible
	name = "impenetrable rock"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock_dark"
	resistance_flags = RESIST_ALL

//desertdam rock, seen in certain EORD maps. Surprisingly not seen in Desert Dam.
/turf/closed/mineral/smooth/desertdamrockwall
	name = "rockwall"
	icon = 'icons/turf/walls/cave.dmi'
	icon_state = "cave-0"
	color = "#c9a37b"
	walltype = "cave"
	base_icon_state = "cave"
/turf/closed/mineral/smooth/desertdamrockwall/indestructible
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

//Ground map dense jungle
/turf/closed/gm
	icon = 'icons/turf/walls/jungle.dmi'
	icon_state = "junglewall-0"
	desc = "Some thick jungle."
	resistance_flags = UNACIDABLE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_FLORA)
	canSmoothWith = list(SMOOTH_GROUP_FLORA)
	base_icon_state = "junglewall"
	walltype = "junglewall"
	open_turf_type = /turf/open/ground/jungle/clear

/turf/closed/gm/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_LEAF, -10, 5)

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
	resistance_flags = PLASMACUTTER_IMMUNE|UNACIDABLE
	minimap_color = MINIMAP_BLACK
	icon_state = "wall-dense"

/turf/closed/gm/dense/Initialize(mapload)
	. = ..()
	for(var/direction in GLOB.cardinals)
		var/turf/turf_to_check = get_step(src, direction)
		if(!isnull(turf_to_check) && !turf_to_check.density && !isspaceturf(turf_to_check))
			minimap_color = MINIMAP_SOLID

//Orange Border (What else am I meant to call it?)
/turf/closed/perimeter
	name = "wall"
	resistance_flags = RESIST_ALL
	base_icon_state = "pwall"
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
			var/image/rock_side = image(icon, "[icon_state]_side", dir = REVERSE_DIR(direction))
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

/turf/closed/ice/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

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
		if(CHECK_BITFIELD(resistance_flags, PLASMACUTTER_IMMUNE))
			to_chat(user, span_warning("[P] can't cut through this!"))
			return
		else if(!P.start_cut(user, name, src))
			return
		else if(!do_after(user, PLASMACUTTER_CUT_DELAY, NONE, src, BUSY_ICON_FRIENDLY))
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
	resistance_flags = PLASMACUTTER_IMMUNE|UNACIDABLE
	open_turf_type = /turf/open/floor/plating/ground/ice

/turf/closed/ice_rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SNOW, -10, 5, 1)

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
	resistance_flags = PLASMACUTTER_IMMUNE

/turf/closed/shuttle/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

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

/turf/closed/shuttle/ert/engines/left
	icon_state = "leftengine_1"

/turf/closed/shuttle/ert/engines/left/two
	icon_state = "leftengine_2"

/turf/closed/shuttle/ert/engines/left/three
	icon_state = "leftengine_3"

/turf/closed/shuttle/ert/engines/right
	icon_state = "rightengine_1"

/turf/closed/shuttle/ert/engines/right/two
	icon_state = "rightengine_2"

/turf/closed/shuttle/ert/engines/right/three
	icon_state = "rightengine_3"

/turf/closed/shuttle/dropship1
	name = "\improper Alamo"
	icon = 'icons/turf/dropship.dmi'
	icon_state = "1"
	plane = GAME_PLANE
	resistance_flags = RESIST_ALL|PLASMACUTTER_IMMUNE

/turf/closed/shuttle/dropship1/transparent
	opacity = FALSE

/turf/closed/shuttle/dropship1/edge
	icon_state = "shuttle_interior_edge"

/turf/closed/shuttle/dropship1/edge/alt
	icon_state = "shuttle_interior_edgealt"

/turf/closed/shuttle/dropship1/aisle
	icon_state = "shuttle_interior_aisle"

/turf/closed/shuttle/dropship1/door
	icon_state = "shuttle_rear_door"

/turf/closed/shuttle/dropship1/window
	icon_state = "shuttle_window_glass"
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship1/panel
	icon_state = "shuttle_interior_panel"

/turf/closed/shuttle/dropship1/engineone
	icon_state = "shuttle_interior_backengine"

/turf/closed/shuttle/dropship1/enginetwo
	icon_state = "shuttle_interior_backengine2"

/turf/closed/shuttle/dropship1/enginethree
	icon_state = "shuttle_interior_backengine3"

/turf/closed/shuttle/dropship1/enginefour
	icon_state = "shuttle_interior_backengine4"

/turf/closed/shuttle/dropship1/enginefive
	icon_state = "shuttle_interior_backengine5"

/turf/closed/shuttle/dropship1/fins
	icon_state = "shuttle_exterior_fins"

/turf/closed/shuttle/dropship1/panels
	icon_state = "shuttle_exterior_panels"

/turf/closed/shuttle/dropship1/corners
	icon_state = "shuttle_exterior_corners"

/turf/closed/shuttle/dropship1/front
	icon_state = "shuttle_exterior_front"

/turf/closed/shuttle/dropship1/wall
	icon_state = "shuttle_interior_wall"

/turf/closed/shuttle/dropship1/interiorwindow
	icon_state = "shuttle_interior_inwards"
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship1/interiormisc
	icon_state = "shuttle_interior_threeside"

/turf/closed/shuttle/dropship1/cornersalt
	icon_state = "shuttle_interior_corneralt"

/turf/closed/shuttle/dropship1/cornersalt2
	icon_state = "shuttle_interior_alt2"

/turf/closed/shuttle/dropship1/finleft
	icon_state = "shuttle_exterior_finnleft"

/turf/closed/shuttle/dropship1/finright
	icon_state = "shuttle_exterior_finnright"

/turf/closed/shuttle/dropship1/finback
	icon_state = "shuttle_exterior_finback"

/turf/closed/shuttle/dropship_white
	name = "wall"
	icon = 'icons/turf/ert_shuttle.dmi'

/turf/closed/shuttle/dropship_white/engine_corner
	icon_state = "white_shuttle_back"

/turf/closed/shuttle/dropship_white/top_corner
	icon_state = "white_shuttle_topcorner"

/turf/closed/shuttle/dropship_white/top_corner/alt
	icon_state = "white_shuttle_topcorner_alt"

/turf/closed/shuttle/dropship_white/backhatch
	icon_state = "white_shuttle_backhatch"

/turf/closed/shuttle/dropship_white/interior_corner
	icon_state = "white_shuttle_interior_corner"

/turf/closed/shuttle/dropship_white/interior_wall
	icon_state = "white_shuttle_interior_wall"

/turf/closed/shuttle/dropship_white/logo_wall
	icon_state = "white_shuttle_logo_wall_one"

/turf/closed/shuttle/dropship_white/logo_wall/two
	icon_state = "white_shuttle_logo_wall_two"

/turf/closed/shuttle/dropship_white/logo_wall/three
	icon_state = "white_shuttle_logo_wall_three"

/turf/closed/shuttle/dropship_white/logo_wall/four
	icon_state = "white_shuttle_logo_wall_four"

/turf/closed/shuttle/dropship_white/backwall
	icon_state = "white_shuttle_back_wall"

/turf/closed/shuttle/dropship_white/cockpit_window
	icon_state = "white_shuttle_cockpit_window"


/turf/closed/shuttle/dropship_dark
	name = "wall"
	icon = 'icons/turf/ert_shuttle.dmi'

/turf/closed/shuttle/dropship_dark/engine_corner
	icon_state = "dark_shuttle_back"

/turf/closed/shuttle/dropship_dark/top_corner
	icon_state = "dark_shuttle_topcorner"

/turf/closed/shuttle/dropship_dark/top_corner/alt
	icon_state = "dark_shuttle_topcorner_alt"

/turf/closed/shuttle/dropship_dark/backhatch
	icon_state = "dark_shuttle_backhatch"

/turf/closed/shuttle/dropship_dark/interior_corner
	icon_state = "dark_shuttle_interior_corner"

/turf/closed/shuttle/dropship_dark/interior_wall
	icon_state = "dark_shuttle_interior_wall"

/turf/closed/shuttle/dropship_dark/logo_wall
	icon_state = "dark_shuttle_logo_wall_one"

/turf/closed/shuttle/dropship_dark/backwall
	icon_state = "dark_shuttle_back_wall"

/turf/closed/shuttle/dropship_dark/cockpit_window
	icon_state = "dark_shuttle_cockpit_window"


/turf/closed/shuttle/dropship_regular
	name = "wall"
	icon = 'icons/turf/ert_shuttle.dmi'

/turf/closed/shuttle/dropship_regular/engine_corner
	icon_state = "regular_shuttle_back"

/turf/closed/shuttle/dropship_regular/top_corner
	icon_state = "regular_shuttle_topcorner"

/turf/closed/shuttle/dropship_regular/top_corner/alt
	icon_state = "regular_shuttle_topcorner_alt"

/turf/closed/shuttle/dropship_regular/backhatch
	icon_state = "regular_shuttle_backhatch"

/turf/closed/shuttle/dropship_regular/interior_corner
	icon_state = "regular_shuttle_interior_corner"

/turf/closed/shuttle/dropship_regular/interior_wall
	icon_state = "regular_shuttle_interior_wall"

/turf/closed/shuttle/dropship_regular/backwall
	icon_state = "regular_shuttle_back_wall"

/turf/closed/shuttle/dropship_regular/cockpit_window
	icon_state = "regular_shuttle_cockpit_window"

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

/turf/closed/shuttle/dropship2/edge
	icon_state = "shuttle_interior_edge"

/turf/closed/shuttle/dropship2/edge/alt
	icon_state = "shuttle_interior_edgealt"

/turf/closed/shuttle/dropship2/aisle
	icon_state = "shuttle_interior_aisle"

/turf/closed/shuttle/dropship2/door
	icon_state = "shuttle_rear_door"

/turf/closed/shuttle/dropship2/window
	icon_state = "shuttle_window_glass"
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship2/panel
	icon_state = "shuttle_interior_panel"

/turf/closed/shuttle/dropship2/engineone
	icon_state = "shuttle_interior_backengine"

/turf/closed/shuttle/dropship2/engineone/alt
	icon_state = "shuttle_engine_alt"

/turf/closed/shuttle/dropship2/enginetwo
	icon_state = "shuttle_interior_backengine2"

/turf/closed/shuttle/dropship2/enginethree
	icon_state = "shuttle_interior_backengine3"

/turf/closed/shuttle/dropship2/enginefour
	icon_state = "shuttle_interior_backengine4"

/turf/closed/shuttle/dropship2/enginefive
	icon_state = "shuttle_interior_backengine5"

/turf/closed/shuttle/dropship2/engine_sidealt
	icon_state = "shuttle_side_engine_alt"

/turf/closed/shuttle/dropship2/fins
	icon_state = "shuttle_exterior_fins"

/turf/closed/shuttle/dropship2/panels
	icon_state = "shuttle_exterior_panels"

/turf/closed/shuttle/dropship2/corners
	icon_state = "shuttle_exterior_corners"

/turf/closed/shuttle/dropship2/front
	icon_state = "shuttle_exterior_front"

/turf/closed/shuttle/dropship2/wall
	icon_state = "shuttle_interior_wall"

/turf/closed/shuttle/dropship2/walltwo
	icon_state = "shuttle_wall_left"

/turf/closed/shuttle/dropship2/walltwo/alt
	icon_state = "shuttle_wall_left_alt"

/turf/closed/shuttle/dropship2/wallthree
	icon_state = "shuttle_wall_right"

/turf/closed/shuttle/dropship2/wallthree/alt
	icon_state = "shuttle_wall_right_alt"

/turf/closed/shuttle/dropship2/interiorwindow
	icon_state = "shuttle_interior_inwards"

/turf/closed/shuttle/dropship2/singlewindow
	icon_state = "shuttle_single_window"
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship2/singlewindow/tadpole
	icon_state = "shuttle_single_window"
	resistance_flags = NONE

/turf/closed/shuttle/dropship2/interiormisc
	icon_state = "shuttle_interior_threeside"

/turf/closed/shuttle/dropship2/cornersalt
	icon_state = "shuttle_interior_corneralt"

/turf/closed/shuttle/dropship2/cornersalt2
	icon_state = "shuttle_interior_alt2"

/turf/closed/shuttle/dropship2/finleft
	icon_state = "shuttle_exterior_finnleft"

/turf/closed/shuttle/dropship2/finright
	icon_state = "shuttle_exterior_finnright"

/turf/closed/shuttle/dropship2/finback
	icon_state = "shuttle_exterior_finback"

/turf/closed/shuttle/dropship2/rearcorner
	icon_state = "shuttle_rearcorner"

/turf/closed/shuttle/dropship2/glassone
	icon_state = "shuttle_glass1"
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship2/glassone/tadpole
	icon_state = "shuttle_glass1"
	resistance_flags = NONE
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship2/glasstwo
	icon_state = "shuttle_glass2"
	opacity = FALSE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship2/glasstwo/tadpole
	icon_state = "shuttle_glass2"
	resistance_flags = NONE
	allow_pass_flags = PASS_GLASS

/turf/closed/shuttle/dropship2/glassthree
	icon_state = "shuttle_glass3"

/turf/closed/shuttle/dropship2/glassfour
	icon_state = "shuttle_glass4"

/turf/closed/shuttle/dropship2/glassfive
	icon_state = "shuttle_glass5"

/turf/closed/shuttle/dropship2/glasssix
	icon_state = "shuttle_glass6"

/turf/closed/shuttle/dropship2/rearcorner/tadpole
	icon_state = "shuttle_rearcorner"
	resistance_flags = NONE

/turf/closed/shuttle/dropship2/rearcorner/alt
	icon_state = "shuttle_rearcorner_alt"

/turf/closed/shuttle/dropship2/rearcorner/alt/tadpole
	icon_state = "shuttle_rearcorner_alt"
	resistance_flags = NONE

/turf/closed/shuttle/dropship2/transparent
	opacity = FALSE

/turf/closed/shuttle/tadpole
	name = "\improper Tadpole"
	icon = 'icons/turf/dropship2.dmi'
	icon_state = "1"
	plane = GAME_PLANE

/turf/closed/shuttle/escapepod
	name = "wall"
	icon = 'icons/turf/escapepods.dmi'
	icon_state = "wall0"
	plane = GAME_PLANE

/turf/closed/shuttle/escapepod/wallone
	icon_state = "wall1"

/turf/closed/shuttle/escapepod/walltwo
	icon_state = "wall2"

/turf/closed/shuttle/escapepod/wallthree
	icon_state = "wall3"

/turf/closed/shuttle/escapepod/wallfour
	icon_state = "wall4"

/turf/closed/shuttle/escapepod/wallfive
	icon_state = "wall5"

/turf/closed/shuttle/escapepod/walleleven
	icon_state = "wall11"

/turf/closed/shuttle/escapepod/walltwelve
	icon_state = "wall12"

/turf/closed/shuttle/escapepod/cornerone
	icon_state = "corner1"

/turf/closed/shuttle/escapepod/cornertwo
	icon_state = "corner2"

/turf/closed/shuttle/escapeshuttle
	icon = 'icons/turf/walls/sulaco.dmi'
	icon_state = "sulaco-0"
	base_icon_state = "sulaco"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ESCAPESHUTTLE)
	canSmoothWith = list(
		SMOOTH_GROUP_ESCAPESHUTTLE,
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FULLTILE,
	)
	walltype = "sulaco"
	minimap_color = MINIMAP_FENCE

/turf/closed/shuttle/escapeshuttle/prison
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/banish_space //Brazil
	plane = PLANE_SPACE
	layer = SPACE_LAYER
	icon = 'icons/turf/space.dmi'
	name = "phantom zone"
	icon_state = "0"
	can_bloody = FALSE
	light_power = 0.25
