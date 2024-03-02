
/obj/structure/bed/chair/loader_seat
	name = "loader seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST


/obj/structure/bed/chair/vehicle_driver_seat
	name = "driver seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner

/obj/structure/bed/chair/vehicle_driver_seat/Destroy()
	owner = null
	return ..()

/obj/structure/bed/chair/vehicle_driver_seat/link_interior(datum/interior/link)
	if(!istype(link, /datum/interior/armored))
		CRASH("invalid interior [link.type] passed to [name]")
	var/datum/interior/armored/inside = link
	inside.drive_seat = src
	owner = inside.container

/obj/structure/bed/chair/vehicle_driver_seat/post_buckle_mob(mob/buckling_mob)
	. = ..()
	owner.add_control_flags(buckling_mob, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	buckling_mob.reset_perspective(owner)
	buckling_mob.pixel_x = pixel_x
	buckling_mob.pixel_y = pixel_y

/obj/structure/bed/chair/vehicle_driver_seat/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	owner.remove_control_flags(buckled_mob, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	buckled_mob.reset_perspective()
	buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)

/obj/structure/bed/chair/vehicle_driver_seat/relaymove(mob/living/user, direct)
	return owner.relaymove(arglist(args))


/obj/structure/bed/chair/vehicle_gunner_seat
	name = "gunner seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner

/obj/structure/bed/chair/vehicle_gunner_seat/link_interior(datum/interior/link)
	if(!istype(link, /datum/interior/armored))
		CRASH("invalid interior [link.type] passed to [name]")
	var/datum/interior/armored/inside = link
	inside.gun_seat = src
	owner = inside.container

/obj/structure/bed/chair/vehicle_gunner_seat/post_buckle_mob(mob/buckling_mob)
	. = ..()
	owner.add_control_flags(buckling_mob, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	buckling_mob.reset_perspective(owner)
	buckling_mob.pixel_x = pixel_x
	buckling_mob.pixel_y = pixel_y

/obj/structure/bed/chair/vehicle_gunner_seat/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	owner.remove_control_flags(buckled_mob, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	buckled_mob.reset_perspective()
	buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)
