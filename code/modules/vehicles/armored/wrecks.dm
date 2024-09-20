/obj/structure/prop/vehicle_wreck
	name = "\improper MT - Banteng"
	desc = "A giant piece of armor with a big gun, good for blowing stuff up. Now just a smouldering ruin."
	icon = 'icons/obj/armored/3x3/tank_wreck.dmi'
	icon_state = "tank"
	pixel_x = -56
	pixel_y = -48
	bound_height = 96
	bound_width = 96
	bound_x = -32
	bound_y = -32
	coverage = 85
	max_integrity = 800
	soft_armor = list(MELEE = 90, BULLET = 95 , LASER = 95, ENERGY = 95, BOMB = 85, BIO = 100, FIRE = 100, ACID = 75)
	hard_armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 0, ACID = 0)
	layer = BELOW_MOB_LAYER
	density = TRUE
	allow_pass_flags = PASSABLE|PASS_TANK|PASS_WALKOVER|PASS_LOW_STRUCTURE
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE|PLASMACUTTER_IMMUNE|PORTAL_IMMUNE
	///Overlay object for turret and main gun
	var/atom/movable/vis_obj/wrecked_turret_overlay/turret_overlay
	///Overlay type to use for turret obj
	var/turret_overlay_type = /atom/movable/vis_obj/wrecked_turret_overlay/tmgc_tank

/obj/structure/prop/vehicle_wreck/Initialize(mapload, obj/vehicle/sealed/armored/source_vehicle, main_dir, turret_dir)
	. = ..()
	setDir(main_dir)
	if(turret_overlay_type)
		turret_overlay = new turret_overlay_type(null, source_vehicle?.primary_weapon?.icon_state, turret_dir)
		vis_contents += turret_overlay
	if(source_vehicle)
		name = source_vehicle.name + " wreck"

	var/static/list/connections = list(
		COMSIG_OBJ_TRY_ALLOW_THROUGH = PROC_REF(can_climb_over),
		COMSIG_FIND_FOOTSTEP_SOUND = TYPE_PROC_REF(/atom/movable, footstep_override),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/structure/prop/vehicle_wreck/Destroy()
	QDEL_NULL(turret_overlay)
	return ..()

/obj/structure/prop/vehicle_wreck/footstep_override(atom/movable/source, list/footstep_overrides)
	footstep_overrides[FOOTSTEP_HULL] = 4.5

/obj/structure/prop/vehicle_wreck/som
	name = "\improper Malleus hover tank"
	desc = "A terrifying behemoth of a main battle tank, now just a smouldering wreck."
	icon = 'icons/obj/armored/3x4/som_tank_wreck.dmi'
	pixel_x = -55
	pixel_y = -80
	turret_overlay_type = /atom/movable/vis_obj/wrecked_turret_overlay/som_tank

/obj/structure/prop/vehicle_wreck/som/Initialize(mapload, obj/vehicle/sealed/armored/source_vehicle, main_dir, turret_dir)
	. = ..()
	add_filter("shadow", 2, drop_shadow_filter(0, -4, 1))

/obj/structure/prop/vehicle_wreck/som/setDir(newdir)
	. = ..()
	turret_overlay?.setDir(dir)
	switch(dir)
		if(NORTH)
			bound_height = 128
			bound_width = 96
			bound_x = -32
			bound_y = -32
			pixel_x = -75
			pixel_y = -48
		if(SOUTH)
			bound_height = 128
			bound_width = 96
			bound_x = -32
			bound_y = -64
			pixel_x = -75
			pixel_y = -80
		if(WEST)
			bound_height = 96
			bound_width = 128
			bound_x = -64
			bound_y = -32
			pixel_x = -58
			pixel_y = -56
		if(EAST)
			bound_height = 96
			bound_width = 128
			bound_x = -32
			bound_y = -32
			pixel_x = -58
			pixel_y = -56

/atom/movable/vis_obj/wrecked_turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon_state = "turret"
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_LAYER|VIS_INHERIT_ICON
	///particle holder for smoke effects
	var/obj/effect/abstract/particle_holder/smoke_holder
	///overlay icon_state for the attached gun
	var/primary_weapon_icon

/atom/movable/vis_obj/wrecked_turret_overlay/Initialize(mapload, weapon_icon_state, new_dir)
	. = ..()
	smoke_holder = new(src, /particles/tank_wreck_smoke)
	if(weapon_icon_state)
		primary_weapon_icon = weapon_icon_state
	update_appearance(UPDATE_OVERLAYS)
	setDir(new_dir)

/atom/movable/vis_obj/wrecked_turret_overlay/Destroy()
	QDEL_NULL(smoke_holder)
	return ..()

/atom/movable/vis_obj/wrecked_turret_overlay/update_overlays()
	. = ..()
	. += primary_weapon_icon

/atom/movable/vis_obj/wrecked_turret_overlay/tmgc_tank
	primary_weapon_icon = "ltb_cannon"

/atom/movable/vis_obj/wrecked_turret_overlay/tmgc_tank/setDir(newdir)
	. = ..()
	switch(dir)
		if(SOUTH)
			pixel_x = 0
			pixel_y = 0
			smoke_holder.particles.position = list(54, 85, 0)
		if(NORTH)
			pixel_x = 0
			pixel_y = 3
			smoke_holder.particles.position = list(54, 75, 0)
		if(EAST)
			pixel_x = 14
			pixel_y = 0
			smoke_holder.particles.position = list(38, 85, 0)
		if(WEST)
			pixel_x = -15
			pixel_y = 0
			smoke_holder.particles.position = list(72, 85, 0)

/atom/movable/vis_obj/wrecked_turret_overlay/som_tank
	primary_weapon_icon = "coilgun"

/atom/movable/vis_obj/wrecked_turret_overlay/som_tank/setDir(newdir)
	. = ..()
	switch(dir)
		if(SOUTH)
			smoke_holder.particles.position = list(75, 78, 0)
		if(NORTH)
			smoke_holder.particles.position = list(75, 98, 0)
		if(EAST)
			smoke_holder.particles.position = list(85, 75, 0)
		if(WEST)
			smoke_holder.particles.position = list(60, 75, 0)
