
/obj/structure/bed/chair/loader_seat
	name = "loader seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST
	can_rotate = FALSE

/obj/structure/bed/chair/loader_seat/Initialize(mapload)
	. = ..()
	setDir(dir)

/obj/structure/bed/chair/loader_seat/handle_layer()
	return

/obj/structure/bed/chair/loader_seat/setDir(newdir)
	. = ..()
	buckling_z = pixel_z + 7
	switch(dir)
		if(NORTH)
			buckling_w = pixel_w
		if(SOUTH)
			buckling_w = pixel_w
		if(EAST)
			buckling_w = pixel_w + 1
		if(WEST)
			buckling_w = pixel_w - 1

/obj/structure/bed/chair/loader_seat/update_overlays()
	. = ..()
	if(buckled_mobs)
		. += mutable_appearance(icon, "[icon_state]_occupied", ABOVE_MOB_LAYER)

/obj/structure/bed/chair/loader_seat/officer
	name = "officer seat"
	can_rotate = TRUE

/obj/structure/bed/chair/loader_seat_som
	name = "loader seat"
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "chair"
	dir = NORTH
	resistance_flags = RESIST_ALL
	can_rotate = FALSE
	pixel_w = -5
	pixel_z = 6
	buckling_w = -5
	buckling_z = 15

/obj/structure/bed/chair/loader_seat_som/handle_layer()
	return

/obj/structure/bed/chair/vehicle_crew
	name = "driver seat"
	icon = 'icons/obj/armored/3x3/tank_interior.dmi'
	icon_state = "vehicle_chair"
	resistance_flags = RESIST_ALL
	dir = EAST
	buckling_w = -2
	buckling_z = 0
	can_rotate = FALSE
	///owner of this object, assigned during interior linkage
	var/obj/vehicle/sealed/armored/owner
	///The skill required to man this chair
	var/skill_req = SKILL_LARGE_VEHICLE_VETERAN
	///Control flags given to the mob on buckle
	var/control_flags = NONE

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

/obj/structure/bed/chair/vehicle_crew/proc/get_vis_range_mod()
	return 1

/obj/structure/bed/chair/vehicle_crew/post_buckle_mob(mob/buckling_mob)
	. = ..()
	buckling_mob.reset_perspective(owner)
	buckling_mob.client.view_size.add(get_vis_range_mod())
	if(control_flags)
		owner.add_control_flags(buckling_mob, control_flags)
	if(control_flags & VEHICLE_CONTROL_DRIVE) //set by last driver, not unset
		owner.faction = buckling_mob.faction

/obj/structure/bed/chair/vehicle_crew/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	buckled_mob.reset_perspective()
	buckled_mob.client.view_size.reset_to_default()
	if(control_flags)
		owner.remove_control_flags(buckled_mob, control_flags)

/obj/structure/bed/chair/vehicle_crew/relaymove(mob/living/user, direct)
	return owner.relaymove(arglist(args))

/obj/structure/bed/chair/vehicle_crew/driver
	name = "driver seat"
	buckling_w = 12
	control_flags = VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS

/obj/structure/bed/chair/vehicle_crew/driver/get_vis_range_mod()
	return 4

/obj/structure/bed/chair/vehicle_crew/driver/post_buckle_mob(mob/buckling_mob)
	. = ..()
	ADD_TRAIT(buckling_mob, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	buckling_mob.update_sight()

/obj/structure/bed/chair/vehicle_crew/driver/post_unbuckle_mob(mob/buckled_mob)
	. = ..()
	REMOVE_TRAIT(buckled_mob, TRAIT_SEE_IN_DARK, VEHICLE_TRAIT)
	buckled_mob.update_sight()

/obj/structure/bed/chair/vehicle_crew/gunner
	name = "gunner seat"
	control_flags = VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT

/obj/structure/bed/chair/vehicle_crew/gunner/get_vis_range_mod()
	return (SSticker.mode?.round_type_flags & MODE_HUMAN_ONLY) ? 4 : 1

/obj/structure/bed/chair/vehicle_crew/driver_gunner
	name = "apc commander seat"
	skill_req = SKILL_LARGE_VEHICLE_EXPERIENCED
	control_flags = VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT|VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS

/obj/structure/bed/chair/vehicle_crew/driver/som
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "driver_chair"
	dir = NORTH
	pixel_z = 3
	buckling_w = 0
	buckling_z = 10

/obj/structure/bed/chair/vehicle_crew/driver/som/handle_layer()
	return

/obj/structure/bed/chair/vehicle_crew/gunner/som
	icon = 'icons/obj/armored/3x4/som_interior_small_props.dmi'
	icon_state = "chair"
	dir = NORTH
	pixel_z = 1
	buckling_w = 0
	buckling_z = 9

/obj/structure/bed/chair/vehicle_crew/gunner/som/handle_layer()
	return
