
/obj/structure/bed/chair/loader_seat
	name = "loader seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST

/obj/structure/bed/chair/loader_seat/update_overlays()
	. = ..()
	if(buckled_mobs)
		. += mutable_appearance(icon, "[icon_state]_occupied", ABOVE_MOB_LAYER)

/obj/structure/bed/chair/loader_seat/som
	name = "loader seat"
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "chair"
	dir = NORTH
	pixel_x = -5
	pixel_y = 6
	buckling_x = -5
	buckling_y = 15

/obj/structure/bed/chair/loader_seat/som/handle_layer()
	return

/obj/structure/bed/chair/vehicle_crew
	name = "driver seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST
	buckling_x = -2
	buckling_y = 0
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

/obj/structure/bed/chair/vehicle_crew/update_overlays()
	. = ..()
	if(buckled_mobs)
		. += mutable_appearance(icon, "[icon_state]_occupied", ABOVE_MOB_LAYER)

/obj/structure/bed/chair/vehicle_crew/buckle_mob(mob/living/buckling_mob, force, check_loc, lying_buckle, hands_needed, target_hands_needed, silent)
	if(buckling_mob.skills.getRating(SKILL_LARGE_VEHICLE) < skill_req)
		return FALSE
	return ..()

/obj/structure/bed/chair/vehicle_crew/post_buckle_mob(mob/buckling_mob)
	. = ..()
	buckling_mob.reset_perspective(owner)
	if(owner.vis_range_mod)
		buckling_mob.client.view_size.set_view_radius_to("[owner.vis_range_mod]x[owner.vis_range_mod]")

/obj/structure/bed/chair/vehicle_crew/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	buckled_mob.reset_perspective()
	if(owner.vis_range_mod)
		buckled_mob.client.view_size.reset_to_default()

/obj/structure/bed/chair/vehicle_crew/relaymove(mob/living/user, direct)
	return owner.relaymove(arglist(args))

/obj/structure/bed/chair/vehicle_crew/driver
	name = "driver seat"
	buckling_x = 12

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

/obj/structure/bed/chair/vehicle_crew/driver/som
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "driver_chair"
	dir = NORTH
	pixel_y = 3
	buckling_x = 0
	buckling_y = 10

/obj/structure/bed/chair/vehicle_crew/driver/som/handle_layer()
	return

/obj/structure/bed/chair/vehicle_crew/gunner/som
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "chair"
	dir = NORTH
	pixel_y = 1
	buckling_x = 0
	buckling_y = 9

/obj/structure/bed/chair/vehicle_crew/gunner/som/handle_layer()
	return
