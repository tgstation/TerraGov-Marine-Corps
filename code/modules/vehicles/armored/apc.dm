/obj/vehicle/sealed/armored/multitile/apc
	name = "\improper APC - Athena"
	desc = "An unarmed command APC designed to command and transport troops in the battlefield."
	icon = 'icons/obj/armored/3x3/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/armored/3x3/apc_damage_overlay.dmi'
	interior = /datum/interior/armored/transport
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_TRANSPORT|ARMORED_ALLOW_DECALS
	permitted_weapons = list(/obj/item/armored_weapon/secondary_weapon, /obj/item/armored_weapon/secondary_flamer, /obj/item/armored_weapon/tow, /obj/item/armored_weapon/microrocket_pod)
	permitted_mods = list(/obj/item/tank_module/interior/medical, /obj/item/tank_module/interior/clone_bay)
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	minimap_icon_state = "apc"
	turret_icon = null
	pixel_x = -48
	pixel_y = -40
	max_integrity = 600
	soft_armor = list(MELEE = 40, BULLET = 100 , LASER = 90, ENERGY = 60, BOMB = 60, BIO = 100, FIRE = 40, ACID = 40)
	max_occupants = 20 //Clown car? Clown car.
	enter_delay = 0.5 SECONDS
	ram_damage = 20
	move_delay = 0.35 SECONDS
	larva_value = 0
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
		/obj/structure/largecrate,
		/obj/structure/closet/crate,
	)

/obj/vehicle/sealed/armored/multitile/apc/update_decal_offsets()
	if(!user_decal)
		return

	switch(dir)
		if(NORTH)
			user_decal.transform = matrix().Turn(180)
			user_decal.pixel_z = 83
			user_decal.pixel_w = 54
		if(SOUTH)
			user_decal.transform = matrix()
			user_decal.pixel_z = 43
			user_decal.pixel_w = 54
		if(EAST)
			var/matrix/newtransform = matrix().Turn(-90)
			user_decal.transform = newtransform.Scale(1, 0.75)
			user_decal.pixel_z = 50
			user_decal.pixel_w = 75
		if(WEST)
			var/matrix/newtransform = matrix().Turn(90)
			user_decal.transform = newtransform.Scale(1, 0.75)
			user_decal.pixel_z = 50
			user_decal.pixel_w = 20

