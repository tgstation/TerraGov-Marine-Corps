//Use turfs for solid parts BUT use structures otherwise so we can see through
/turf/closed/shuttle/cas
	name = "\improper Condor Jet"
	icon = 'icons/Marine/casship.dmi'
	icon_state = "1"
	appearance_flags = TILE_BOUND|KEEP_TOGETHER
	layer = OBJ_LAYER
	plane = GAME_PLANE
	opacity = FALSE
	resistance_flags = RESIST_ALL

/turf/closed/shuttle/cas/one
	icon_state = "cas_plane_trim_one"
/turf/closed/shuttle/cas/two
	icon_state = "cas_plane_trim_two"

/turf/closed/shuttle/cas/three
	icon_state = "cas_plane_engine_trim_one"

/turf/closed/shuttle/cas/four
	icon_state = "cas_plane_wing_engine_one"

/turf/closed/shuttle/cas/five
	icon_state = "cas_plane_wing_engine_two"

/turf/closed/shuttle/cas/six
	icon_state = "cas_plane_wing_engine_two"

/turf/closed/shuttle/cas/seven
	icon_state = "cas_plane_engine_misc"

/turf/closed/shuttle/cas/eight
	icon_state = "cas_plane_wing_one"

/turf/closed/shuttle/cas/nine
	icon_state = "cas_plane_wing_two"

/turf/closed/shuttle/cas/ten
	icon_state = "cas_plane_wing_three"

/turf/closed/shuttle/cas/eleven
	icon_state = "cas_plane_wing_four"

/turf/closed/shuttle/cas/twelve
	icon_state = "cas_plane_wing_five"

/turf/closed/shuttle/cas/thirteen
	icon_state = "cas_plane_wing_six"

/turf/closed/shuttle/cas/fourteen
	icon_state = "cas_plane_engine_misc_two"

/turf/closed/shuttle/cas/fifteen
	icon_state = "cas_plane_engine_misc_five"

/turf/closed/shuttle/cas/sixteen
	icon_state = "cas_plane_wing_engine_three"

/turf/closed/shuttle/cas/seventeen
	icon_state = "cas_plane_engine_misc_three"

/turf/closed/shuttle/cas/eighteen
	icon_state = "cas_plane_engine_misc_four"

/turf/closed/shuttle/cas/nineteen
	icon_state = "cas_plane_engine_backtrim"

/turf/closed/shuttle/cas/twenty
	icon_state = "nose"

/turf/closed/shuttle/cas/twentyone
	icon_state = "cas_plane_cockpit_piece_two"

/turf/closed/shuttle/cas/twentytwo
	icon_state = "cas_plane_backpiece"

/turf/closed/shuttle/cas/computer
	name = "Condor piloting computer"
	desc = "Does not support Pinball."
	icon_state = "cockpit"

/turf/closed/shuttle/cas/computer/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "7", ABOVE_MOB_LAYER)
	overlay.pixel_x = -32
	add_overlay(overlay)
	overlay = image('icons/Marine/casship.dmi', src, "2", ABOVE_MOB_LAYER)
	overlay.pixel_x = 32
	add_overlay(overlay)

/turf/closed/shuttle/cas/centertop
	icon_state = "10"

/turf/closed/shuttle/cas/centertop/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "5", ABOVE_MOB_LAYER)
	overlay.pixel_x = -32
	add_overlay(overlay)
	overlay = image('icons/Marine/casship.dmi', src, "4", ABOVE_MOB_LAYER)
	overlay.pixel_x = 32
	add_overlay(overlay)

/turf/closed/shuttle/cas/centertop2
	icon_state = "11"

/turf/closed/shuttle/cas/centertop2/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "27", ABOVE_MOB_LAYER)
	overlay.pixel_x = -32
	add_overlay(overlay)
	overlay = image('icons/Marine/casship.dmi', src, "12", ABOVE_MOB_LAYER)
	overlay.pixel_x = 32
	add_overlay(overlay)

/turf/closed/shuttle/cas/leftwingfar
	icon_state = "33"

/turf/closed/shuttle/cas/leftwingfar/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "32", ABOVE_MOB_LAYER)
	overlay.pixel_y = 32
	add_overlay(overlay)
	overlay = image('icons/Marine/casship.dmi', src, "34", ABOVE_MOB_LAYER)
	overlay.pixel_y = -32
	add_overlay(overlay)

/turf/closed/shuttle/cas/leftwingmid
	icon_state = "39"

/turf/closed/shuttle/cas/leftwingmid/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "35", ABOVE_MOB_LAYER)
	overlay.pixel_y = -32
	add_overlay(overlay)

/turf/closed/shuttle/cas/leftwingclose
	icon_state = "40"

/turf/closed/shuttle/cas/leftwingclose/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "36", ABOVE_MOB_LAYER)
	overlay.pixel_y = -32
	add_overlay(overlay)

/turf/closed/shuttle/cas/rightwingfar
	icon_state = "18"

/turf/closed/shuttle/cas/rightwingfar/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "17", ABOVE_MOB_LAYER)
	overlay.pixel_y = 32
	add_overlay(overlay)
	overlay = image('icons/Marine/casship.dmi', src, "76", ABOVE_MOB_LAYER)
	overlay.pixel_y = -32
	add_overlay(overlay)

/turf/closed/shuttle/cas/rightwingmid
	icon_state = "19"

/turf/closed/shuttle/cas/rightwingmid/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "23", ABOVE_MOB_LAYER)
	overlay.pixel_y = -32
	add_overlay(overlay)

/turf/closed/shuttle/cas/rightwingclose
	icon_state = "20"

/turf/closed/shuttle/cas/rightwingclose/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "24", ABOVE_MOB_LAYER)
	overlay.pixel_y = -32
	add_overlay(overlay)


///Base cas plane structure, we use this instead of turfs if we want to peek onto the turfs below
/obj/structure/caspart
	name = "\improper Condor Jet"
	icon = 'icons/Marine/casship.dmi'
	icon_state = "2"
	layer = OBJ_LAYER
	resistance_flags = RESIST_ALL
	density = TRUE
	appearance_flags = TILE_BOUND|KEEP_TOGETHER
	opacity = FALSE
	///you can't shoot it to death
	coverage = 15

/obj/structure/caspart/leftprong
	icon_state = "28"

/obj/structure/caspart/leftprong/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "29")
	overlay.pixel_y = 32
	add_overlay(overlay)

/obj/structure/caspart/rightprong
	icon_state = "13"

/obj/structure/caspart/rightprong/Initialize(mapload)
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "14")
	overlay.pixel_y = 32
	add_overlay(overlay)

/obj/structure/caspart/minigun
	name = "\improper Condor Jet minigun"
	desc = " A terrifying radial-mounted GAU-30mm minigun. You don't want to be on the wrong end of this."
	icon_state = "1"
	///static weapon we start with at the tip
	var/static_weapon_type = /obj/structure/dropship_equipment/cas/weapon/heavygun/radial_cas
	///ref to the static weapon
	var/obj/structure/dropship_equipment/cas/weapon/static_weapon

/obj/structure/caspart/minigun/examine(mob/user)
	. = ..()
	if(static_weapon.ammo_equipped)
		. += static_weapon.ammo_equipped.show_loaded_desc(user)
	else
		. += "It's empty."

/obj/structure/caspart/minigun/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(!istype(port, /obj/docking_port/mobile/marine_dropship/casplane))
		return
	var/obj/docking_port/mobile/marine_dropship/casplane/plane = port
	static_weapon = new static_weapon_type(plane)
	plane.equipments += static_weapon

/obj/structure/caspart/minigun/Destroy()
	static_weapon = null
	return ..()

/obj/structure/caspart/minigun/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	return static_weapon.attack_powerloader(user, attached_clamp)

/obj/structure/caspart/minigun/attackby(obj/item/I, mob/user, params)
	return static_weapon.attackby(I, user, params)

/obj/structure/caspart/internalengine
	var/image/engine_overlay
	var/x_offset = 0

/obj/structure/caspart/internalengine/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(!istype(port, /obj/docking_port/mobile/marine_dropship/casplane))
		return
	var/obj/docking_port/mobile/marine_dropship/casplane/planeport = port
	planeport.engines += src
	return ..()

/obj/structure/caspart/internalengine/right
	icon_state = "50"
	x_offset = -12

/obj/structure/caspart/internalengine/left
	icon_state = "54"
	x_offset = 11

//damn plane is a jigsaw puzzle, naming reflects this
/obj/structure/caspart/one
	icon_state = "cas_plane_trim_one"
/obj/structure/caspart/two
	icon_state = "cas_plane_trim_two"

/obj/structure/caspart/three
	icon_state = "cas_plane_engine_trim_one"

/obj/structure/caspart/four
	icon_state = "cas_plane_wing_engine_one"

/obj/structure/caspart/five
	icon_state = "cas_plane_wing_engine_two"

/obj/structure/caspart/six
	icon_state = "cas_plane_wing_engine_two"

/obj/structure/caspart/seven
	icon_state = "cas_plane_engine_misc"

/obj/structure/caspart/eight
	icon_state = "cas_plane_wing_one"

/obj/structure/caspart/nine
	icon_state = "cas_plane_wing_two"

/obj/structure/caspart/ten
	icon_state = "cas_plane_wing_three"

/obj/structure/caspart/eleven
	icon_state = "cas_plane_wing_four"

/obj/structure/caspart/twelve
	icon_state = "cas_plane_wing_five"

/obj/structure/caspart/thirteen
	icon_state = "cas_plane_wing_six"

/obj/structure/caspart/fourteen
	icon_state = "cas_plane_engine_misc_two"

/obj/structure/caspart/fifteen
	icon_state = "cas_plane_engine_misc_five"

/obj/structure/caspart/sixteen
	icon_state = "cas_plane_wing_engine_three"

/obj/structure/caspart/seventeen
	icon_state = "cas_plane_engine_misc_three"

/obj/structure/caspart/eighteen
	icon_state = "cas_plane_engine_misc_four"

/obj/structure/caspart/nineteen
	icon_state = "cas_plane_engine_backtrim"

/obj/structure/caspart/twenty
	icon_state = "nose"

/obj/structure/caspart/twentyone
	icon_state = "cas_plane_cockpit_piece_two"

/obj/structure/caspart/twentytwo
	icon_state = "cas_plane_backpiece"
