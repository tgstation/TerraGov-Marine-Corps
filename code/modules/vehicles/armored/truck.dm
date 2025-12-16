/obj/vehicle/sealed/armored/multitile/mrap
	name = "\improper MRAP - Sambar"
	desc = "An unarmed MRAP designed to transport troops across the battlefield quickly and safely."
	icon = 'icons/obj/armored/2x3/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/armored/2x3/apc_damage_overlay.dmi'
	hitbox = /obj/hitbox/two_three
	interior = /datum/interior/armored/mrap
	permitted_weapons = NONE
	permitted_mods = list(/obj/item/tank_module/ability/tesla)
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_HAS_UNDERLAY|ARMORED_WRECKABLE|ARMORED_PURCHASABLE_TRANSPORT|ARMORED_SELF_WALL_DAMAGE
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	minimap_icon_state = "apc"
	turret_icon = null
	pixel_x = -24
	pixel_y = -32
	max_integrity = 900
	soft_armor = list(MELEE = 50, BULLET = 100 , LASER = 90, ENERGY = 60, BOMB = 60, BIO = 100, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 20, FIRE = 0, ACID = 0)
	max_occupants = 12
	enter_delay = 0.4 SECONDS
	ram_damage = 200
	move_delay = 0.15 SECONDS
	glide_size = 8.5
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
		/obj/structure/largecrate,
		/obj/structure/closet/crate,
	)

/obj/vehicle/sealed/armored/multitile/mrap/Initialize(mapload)
	. = ..()
	var/obj/item/tank_module/module = new /obj/item/tank_module/ability/tesla()
	module.on_equip(src)

/obj/vehicle/sealed/armored/multitile/mrap/setDir(newdir)
	. = ..()
	if(armored_flags & ARMORED_IS_WRECK)
		update_smoke_dir(null, null, newdir)

/obj/vehicle/sealed/armored/multitile/mrap/enter_locations(atom/movable/entering_thing)
	var/first_turf = get_step_away(get_step(src, REVERSE_DIR(dir)), src, 2)
	return list(
		first_turf,
		get_step(first_turf, turn(dir, -90)),
	)

/obj/vehicle/sealed/armored/multitile/mrap/wreck_vehicle()
	. = ..()
	update_smoke_dir(newdir = dir)

/obj/vehicle/sealed/armored/multitile/mrap/update_smoke_dir(datum/source, dir, newdir)
	switch(newdir)
		if(SOUTH)
			smoke_holder.particles.position = list(20, 16, 0)
		if(NORTH)
			smoke_holder.particles.position = list(-4, 73, 0)
		if(EAST)
			smoke_holder.particles.position = list(70, 35, 0)
		if(WEST)
			smoke_holder.particles.position = list(10, 35, 0)

/obj/vehicle/sealed/armored/multitile/mrap/campaign
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_HAS_UNDERLAY|ARMORED_WRECKABLE
	max_integrity = 1100
	soft_armor = list(MELEE = 90, BULLET = 90 , LASER = 90, ENERGY = 90, BOMB = 85, BIO = 100, FIRE = 100, ACID = 75)
	hard_armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 100, FIRE = 0, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.7, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)
