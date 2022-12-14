//Use turfs for solid parts BUT use structures otherwise so we can see through
/turf/closed/shuttle/cas
	name = "\improper Condor Jet"
	icon = 'icons/Marine/casship.dmi'
	icon_state = "1"
	appearance_flags = TILE_BOUND|KEEP_TOGETHER
	layer = OBJ_LAYER
	plane = GAME_PLANE
	opacity = FALSE
	resistance_flags = PLASMACUTTER_IMMUNE

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

/obj/structure/caspart/leftprong/Initialize()
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "29")
	overlay.pixel_y = 32
	add_overlay(overlay)

/obj/structure/caspart/rightprong
	icon_state = "13"

/obj/structure/caspart/rightprong/Initialize()
	. = ..()
	var/image/overlay = image('icons/Marine/casship.dmi', src, "14")
	overlay.pixel_y = 32
	add_overlay(overlay)

/obj/structure/caspart/minigun
	name = "\improper Condor Jet minigun"
	desc = " A terrifying radial-mounted GAU-30mm minigun. You don't want to be on the wrong end of this."
	icon_state = "1"
	///static weapon we start with at the tip
	var/static_weapon_type = /obj/structure/dropship_equipment/weapon/heavygun/radial_cas
	///ref to the static weapon
	var/obj/structure/dropship_equipment/weapon/static_weapon

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
