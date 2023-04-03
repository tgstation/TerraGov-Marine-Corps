//----- Marine ship walls ---//
/turf/closed/wall/mainship
	name = "hull"
	desc = "A huge chunk of metal used to seperate rooms and make up the ship."
	icon = 'icons/turf/walls/testwall.dmi'
	icon_state = "testwall-0"
	walltype = "testwall"

	max_integrity = 3000 //Wall will break down to girders if damage reaches this point

	max_temperature = 28000 //K, walls will take damage if they're next to a fire hotter than this

	opacity = TRUE
	density = TRUE

	base_icon_state = "testwall"

/turf/closed/wall/mainship/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	//icon_state = "testwall0_debug" //Uncomment to check hull in the map editor.
	walltype = "testwall"
	resistance_flags = RESIST_ALL //Impossible to destroy or even damage. Used for outer walls that would breach into space, potentially some special walls
	icon_state = "wall-invincible"

/turf/closed/wall/mainship/outer/reinforced
	name = "reinforced hull"

/turf/closed/wall/mainship/outer/canterbury
	smoothing_groups = list(SMOOTH_GROUP_CANTERBURY)
	canSmoothWith = list(
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FRAME,
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_SHUTTERS,
		SMOOTH_GROUP_CANTERBURY,
	)

/turf/closed/wall/mainship/white
	icon = 'icons/turf/walls/wwall.dmi'
	base_icon_state = "wwall"
	icon_state = "wwall-0"

/turf/closed/wall/mainship/gray
	walltype = "gwall"
	icon = 'icons/turf/walls/gwall.dmi'
	base_icon_state = "gwall"
	icon_state = "gwall-0"

/turf/closed/wall/mainship/gray/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	walltype = "gwall"
	resistance_flags = RESIST_ALL

/turf/closed/wall/mainship/white/canterbury //For ship smoothing.
	smoothing_groups = list(SMOOTH_GROUP_CANTERBURY)
	canSmoothWith = list(
		SMOOTH_GROUP_AIRLOCK,
		SMOOTH_GROUP_WINDOW_FRAME,
		SMOOTH_GROUP_WINDOW_FULLTILE,
		SMOOTH_GROUP_SHUTTERS,
		SMOOTH_GROUP_CANTERBURY,
	)



/turf/closed/wall/mainship/white/outer
	name = "outer hull"
	desc = "A huge chunk of metal used to seperate space from the ship"
	icon_state = "wall-invincible"
	resistance_flags = RESIST_ALL

/turf/closed/wall/mainship/research/can_be_dissolved()
	return FALSE

/turf/closed/wall/mainship/research/containment/wall
	icon = 'icons/turf/mainshipwalls.dmi'
	name = "cell wall"
	walltype = null
	smoothing_flags = NONE

/turf/closed/wall/mainship/research/containment/wall/corner
	icon_state = "containment_wall_corner"

/turf/closed/wall/mainship/research/containment/wall/divide
	icon_state = "containment_wall_divide"

/turf/closed/wall/mainship/research/containment/wall/south
	icon_state = "containment_wall_s"

/turf/closed/wall/mainship/research/containment/wall/west
	icon_state = "containment_wall_w"

/turf/closed/wall/mainship/research/containment/wall/connect_e
	icon_state = "containment_wall_connect_e"

/turf/closed/wall/mainship/research/containment/wall/connect3
	icon_state = "containment_wall_connect3"

/turf/closed/wall/mainship/research/containment/wall/connect_w
	icon_state = "containment_wall_connect_w"

/turf/closed/wall/mainship/research/containment/wall/connect_w2
	icon_state = "containment_wall_connect_w2"

/turf/closed/wall/mainship/research/containment/wall/east
	icon_state = "containment_wall_e"

/turf/closed/wall/mainship/research/containment/wall/north
	icon_state = "containment_wall_n"

/turf/closed/wall/mainship/research/containment/wall/connect_e2
	icon_state = "containment_wall_connect_e2"

/turf/closed/wall/mainship/research/containment/wall/connect_s1
	icon_state = "containment_wall_connect_s1"

/turf/closed/wall/mainship/research/containment/wall/connect_s2
	icon_state = "containment_wall_connect_s2"

/turf/closed/wall/mainship/research/containment/wall/purple
	name = "cell window"
	icon_state = "containment_window"
	opacity = FALSE


/turf/closed/wall/desert
	name = "wall"
	icon = 'icons/turf/walls/chigusa.dmi'
	icon_state = "chigusa-0"
	walltype = "chigusa"
	base_icon_state = "chigusa"

/turf/closed/wall/desert/invincible
	resistance_flags = RESIST_ALL

//tyson
/turf/closed/wall/tyson
	name = "outer wall"
	resistance_flags = RESIST_ALL

/turf/closed/wall/tyson/airlock
	name = "rusted airlock"
	icon = 'icons/obj/doors/Doorext.dmi'
	icon_state = "door_locked"

/turf/closed/wall/tyson/airlock/maint
	icon = 'icons/obj/doors/Doormaint.dmi'

/turf/closed/wall/tyson/poddoor
	name = "rusted poddoor"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"

/turf/closed/wall/tyson/r_wall
	icon_state = "rwall"

//Sulaco walls.
/turf/closed/wall/sulaco
	name = "hull"
	desc = "A huge chunk of metal used to separate rooms on spaceships from the cold void of space."
	icon = 'icons/turf/walls/sulaco.dmi'
	icon_state = "sulaco-0"
	base_icon_state = "sulaco"
	color = "#616161"

	max_integrity = 3000
	max_temperature = 28000 //K, walls will take damage if they're next to a fire hotter than this
	walltype = "sulaco" //Changes all the sprites and icons.


/turf/closed/wall/sulaco/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			ChangeTurf(/turf/open/floor/plating)
		if(EXPLODE_HEAVY)
			if(prob(75))
				take_damage(rand(100, 250))
			else
				dismantle_wall(1, 1)
		if(EXPLODE_LIGHT)
			take_damage(rand(0, 250))


/turf/closed/wall/sulaco/hull
	name = "outer hull"
	desc = "A reinforced outer hull, probably to prevent breaches"
	walltype = "sulaco"
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/wall/sulaco/unmeltable
	resistance_flags = RESIST_ALL
	icon_state = "wall-invincible"

/turf/closed/wall/sulaco/unmeltable/ex_act(severity) //Should make it indestructable
	return

/turf/closed/wall/sulaco/unmeltable/fire_act(exposed_temperature, exposed_volume)
	return

/turf/closed/wall/sulaco/unmeltable/attackby(obj/item/I, mob/user, params) //This should fix everything else. No cables, etc
	return

/turf/closed/wall/sulaco/unmeltable/can_be_dissolved()
	return FALSE



/turf/closed/wall/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = TRUE
	resistance_flags = RESIST_ALL
	smoothing_flags = NONE

/turf/closed/wall/indestructible/ex_act(severity)
	return

/turf/closed/wall/indestructible/fire_act(exposed_temperature, exposed_volume)
	return

/turf/closed/wall/indestructible/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tool/pickaxe/plasmacutter)) //needed for user feedback, if not included the user will not receive a message when trying plasma cutter wall/indestructible turfs
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		to_chat(user, span_warning("[P] can't cut through this!"))
	return

/turf/closed/wall/indestructible/can_be_dissolved()
	return 0

/turf/closed/wall/indestructible/mineral
	name = "impenetrable rock"
	icon_state = "rock_dark"

/turf/closed/wall/indestructible/bulkhead
	name = "bulkhead"
	desc = "It is a large metal bulkhead."
	icon_state = "hull"

/turf/closed/wall/indestructible/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = FALSE

/turf/closed/wall/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/title.dmi'
	icon_state = "title_painting1"
//	icon_state = "title_holiday"
	layer = FLY_LAYER
	pixel_x = -64

/turf/closed/wall/indestructible/splashscreen/New()
	..()
	if(icon_state == "title_painting1")
		icon_state = "title_painting[rand(0,33)]"

/turf/closed/wall/indestructible/other
	icon_state = "r_wall"

// Mineral Walls

/turf/closed/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/mineral
	var/last_event = 0
	var/active = null

/turf/closed/wall/mineral/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon_state = "gold0"
	walltype = "gold"
	mineral = "gold"

/turf/closed/wall/mineral/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny!"
	icon_state = "silver0"
	walltype = "silver"
	mineral = "silver"
	//var/electro = 0.75
	//var/shocked = null

/turf/closed/wall/mineral/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon_state = "diamond0"
	walltype = "diamond"
	mineral = "diamond"


/turf/closed/wall/mineral/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon_state = "sandstone0"
	walltype = "sandstone"
	mineral = "sandstone"

/turf/closed/wall/mineral/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon_state = "uranium0"
	walltype = "uranium"
	mineral = "uranium"

/turf/closed/wall/mineral/phoron
	name = "phoron wall"
	desc = "A wall with phoron plating. This is definately a bad idea."
	icon_state = "phoron0"
	walltype = "phoron"
	mineral = "phoron"





//Misc walls

/turf/closed/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon = 'icons/turf/walls/cult.dmi'
	icon_state = "cult-0"
	walltype = "cult"
	base_icon_state = "cult"
	color = "#88574b"

/turf/closed/wall/clock
	name = "brass wall"
	desc = "An intricate pattern of brass masterfully crafted into a sturdy wall. Looking at it instills a strange sense of pride in you."
	icon_state = "clockwork_wall"

/turf/closed/wall/vault
	icon_state = "rockvault"

/turf/closed/wall/vault/New(location,type)
	..()
	icon_state = "[type]vault"

/turf/closed/wall/desertcavewall
	name = "cave wall"
	icon = 'icons/turf/desertdam_map.dmi'
	icon_state = "cavewall0"
	walltype = "cavewall"


//Prison wall

/turf/closed/wall/prison
	name = "metal wall"
	icon = 'icons/turf/walls/gorg_prison_wall_two.dmi'
	icon_state = "metal-0"
	walltype = "metal"
	base_icon_state = "metal"



//Wood wall

/turf/closed/wall/wood
	name = "wood wall"
	icon = 'icons/turf/walls/woodwall.dmi'
	icon_state = "woodwall-0"
	base_icon_state = "woodwall"
	walltype = "woodwall"
	explosion_block = 1

// Reinforced Wood Wall

/turf/closed/wall/wood/reinforced
	name = "reinforced wood wall"
	desc = "A reinforced wooden wall"
	icon = 'icons/turf/walls/woodrwall.dmi'
	icon_state = "woodrwall-0"
	base_icon_state = "woodrwall"
	walltype = "woodrwall"
	max_integrity = 3000
	explosion_block = 4
