/obj/vehicle/sealed/armored/multitile/truck
	name = "\improper BIG BOBBA TRUCKA"
	desc = "An unarmed command APC designed to command and transport troops in the battlefield."
	icon = 'icons/obj/armored/2x3/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/armored/2x3/apc_damage_overlay.dmi'
	hitbox = /obj/hitbox/truck
	interior = /datum/interior/armored/transport
	armored_flags = ARMORED_HAS_HEADLIGHTS
	//permitted_weapons = list(/obj/item/armored_weapon/secondary_weapon, /obj/item/armored_weapon/secondary_flamer, /obj/item/armored_weapon/tow, /obj/item/armored_weapon/microrocket_pod)
	//permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom, /obj/item/tank_module/interior/medical, /obj/item/tank_module/interior/clone_bay)
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	minimap_icon_state = "apc"
	turret_icon = null
	pixel_x = -24
	pixel_y = -32
	max_integrity = 1200
	soft_armor = list(MELEE = 80, BULLET = 85 , LASER = 85, ENERGY = 85, BOMB = 75, BIO = 100, FIRE = 100, ACID = 75)
	hard_armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 0, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.75, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.6)
	max_occupants = 20 //Clown car? Clown car.
	enter_delay = 0.5 SECONDS
	ram_damage = 50
	move_delay = 0.3 SECONDS
	glide_size = 4.333
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
		/obj/structure/largecrate,
		/obj/structure/closet/crate,
	)
