
/obj/structure/bed/chair/loader_seat
	name = "loader seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST

/obj/structure/bed/chair/vehicle_crew
	name = "driver seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner
	///The skill required to man this chair
	var/skill_req = SKILL_LARGE_VEHICLE_VETERAN

/obj/structure/bed/chair/vehicle_crew/Destroy()
	owner = null
	return ..()

/obj/structure/bed/chair/vehicle_crew/link_interior(datum/interior/link)
	if(!istype(link, /datum/interior/armored))
		CRASH("invalid interior [link.type] passed to [name]")
	var/datum/interior/armored/inside = link
	owner = inside.container

/obj/structure/bed/chair/vehicle_crew/buckle_mob(mob/living/buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	if(buckling_mob.skills.getRating(SKILL_LARGE_VEHICLE) < skill_req)
		return FALSE
	return ..()

/obj/structure/bed/chair/vehicle_crew/post_buckle_mob(mob/buckling_mob)
	. = ..()
	buckling_mob.reset_perspective(owner)
	buckling_mob.pixel_x = pixel_x
	buckling_mob.pixel_y = pixel_y
	if(vis_range_mod)
		buckling_mob.client.view_size.set_view_radius_to("[owner.vis_range_mod]x[owner.vis_range_mod]")

/obj/structure/bed/chair/vehicle_crew/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	buckled_mob.reset_perspective()
	buckled_mob.pixel_x = initial(buckled_mob.pixel_x)
	buckled_mob.pixel_y = initial(buckled_mob.pixel_y)
	if(vis_range_mod)
		buckled_mob.client.view_size.reset_to_default()

/obj/structure/bed/chair/vehicle_crew/relaymove(mob/living/user, direct)
	return owner.relaymove(arglist(args))

/obj/structure/bed/chair/vehicle_crew/driver
	name = "driver seat"

/obj/structure/bed/chair/vehicle_crew/driver/post_buckle_mob(mob/buckling_mob)
	. = ..()
	owner.add_control_flags(buckling_mob, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)

/obj/structure/bed/chair/vehicle_crew/driver/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	owner.remove_control_flags(buckled_mob, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)

/obj/structure/bed/chair/vehicle_crew/gunner
	name = "gunner seat"

/obj/structure/bed/chair/vehicle_crew/gunner/post_buckle_mob(mob/buckling_mob)
	. = ..()
	owner.add_control_flags(buckling_mob, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/structure/bed/chair/vehicle_crew/gunner/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	owner.remove_control_flags(buckled_mob, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/structure/bed/chair/vehicle_crew/driver_gunner
	name = "apc commander seat"
	skill_req = SKILL_LARGE_VEHICLE_EXPERIENCED

/obj/structure/bed/chair/vehicle_crew/driver_gunner/post_buckle_mob(mob/buckling_mob)
	. = ..()
	owner.add_control_flags(buckling_mob, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)

/obj/structure/bed/chair/vehicle_crew/driver_gunner/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	owner.remove_control_flags(buckled_mob, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
