/datum/interior/armored
	template = /datum/map_template/interior/medium_tank
	///main cannon ammo management
	var/obj/structure/gun_breech/breech
	///secondary gun ammo management
	var/obj/structure/gun_breech/secondary_breech
	///door to enter and leave the tank. TODO: make this support multiple doors
	var/turf/closed/interior/tank/door/door

/datum/interior/armored/Destroy(force, ...)
	breech = null
	secondary_breech = null
	door = null
	return ..()

/datum/interior/armored/mob_enter(mob/enterer)
	if(door)
		enterer.forceMove(door.get_enter_location())
		enterer.setDir(EAST)
		return ..()
	to_chat(enterer, span_userdanger("AN ERROR OCCURED PUTTING YOU INTO AN INTERIOR"))
	stack_trace("a [enterer.type] could not find a door when entering an interior")
	enterer.forceMove(pick(loaded_turfs))
	return ..()

/turf/closed/interior/tank
	name = "\improper Ares tank interior"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'

/turf/closed/interior/tank/one
	icon_state = "tank_interior_1"
/turf/closed/interior/tank/two
	icon_state = "tank_interior_2"
/turf/closed/interior/tank/three
	icon_state = "tank_interior_3"
/turf/closed/interior/tank/four
	icon_state = "tank_interior_4"
/turf/closed/interior/tank/five
	icon_state = "tank_interior_5"
/turf/closed/interior/tank/six
	icon_state = "tank_interior_6"
/turf/closed/interior/tank/twelve
	icon_state = "tank_interior_12"
/turf/closed/interior/tank/thirteen
	icon_state = "tank_interior_13"
/turf/closed/interior/tank/seventeen
	icon_state = "tank_interior_17"
/turf/closed/interior/tank/eighteen
	icon_state = "tank_interior_18"
/turf/closed/interior/tank/nineteen
	icon_state = "tank_interior_19"
	layer = ABOVE_ALL_MOB_LAYER
/turf/closed/interior/tank/twenty
	icon_state = "tank_interior_20"
	layer = ABOVE_ALL_MOB_LAYER
/turf/closed/interior/tank/twentyone
	icon_state = "tank_interior_21"
	layer = ABOVE_ALL_MOB_LAYER
/turf/closed/interior/tank/twentythree
	icon_state = "tank_interior_23"
/turf/closed/interior/tank/twentyfour
	icon_state = "tank_interior_24"
/turf/closed/interior/tank/twentyfive
	icon_state = "tank_interior_25"
	layer = ABOVE_ALL_MOB_LAYER
/turf/closed/interior/tank/twentysix
	icon_state = "tank_interior_26"
	layer = ABOVE_ALL_MOB_LAYER
/turf/closed/interior/tank/twentyseven
	icon_state = "tank_interior_27"
	layer = ABOVE_ALL_MOB_LAYER
/turf/closed/interior/tank/twentyeight
	icon_state = "tank_interior_28"

/turf/closed/interior/tank/door
	name = "exit hatch"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "tank_interior_7"
	resistance_flags = RESIST_ALL
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner

/turf/closed/interior/tank/door/Destroy()
	owner = null
	return ..()

/turf/closed/interior/tank/door/link_interior(datum/interior/link)
	if(!istype(link, /datum/interior/armored))
		CRASH("invalid interior [link.type] passed to [name]")
	var/datum/interior/armored/inside = link
	inside.door = src
	owner = inside.container

/turf/closed/interior/tank/door/attack_hand(mob/living/user)
	. = ..()
	owner.interior.mob_leave(user)

/turf/closed/interior/tank/door/attack_ghost(mob/dead/observer/user)
	. = ..()
	owner.interior.mob_leave(user)

///returns where we want to spit out new enterers
/turf/closed/interior/tank/door/proc/get_enter_location()
	return get_step(src, EAST)

/turf/open/interior/tank
	name = "\improper Ares tank interior"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'

/turf/open/interior/tank/eight
	icon_state = "tank_interior_8"
/turf/open/interior/tank/nine
	icon_state = "tank_interior_9"
/turf/open/interior/tank/ten
	icon_state = "tank_interior_10"
/turf/open/interior/tank/eleven
	icon_state = "tank_interior_11"
/turf/open/interior/tank/fourteen
	icon_state = "tank_interior_14"
/turf/open/interior/tank/fifteen
	icon_state = "tank_interior_15"
/turf/open/interior/tank/sixteen
	icon_state = "tank_interior_16"
/turf/open/interior/tank/twentytwo
	icon_state = "tank_interior_22"

/area/interior/tank
	name = "Tank Interior"
	icon_state = "shuttle"
