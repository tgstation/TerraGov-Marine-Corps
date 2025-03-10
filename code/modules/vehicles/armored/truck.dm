/obj/vehicle/sealed/armored/multitile/truck
	name = "\improper BIG BOBBA TRUCKA"
	desc = "An unarmed command APC designed to command and transport troops in the battlefield."
	icon = 'icons/obj/armored/2x3/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/armored/2x3/apc_damage_overlay.dmi'
	hitbox = /obj/hitbox/truck
	interior = /datum/interior/armored/transport
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_HAS_UNDERLAY|ARMORED_WRECKABLE
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	minimap_icon_state = "apc"
	turret_icon = null
	pixel_w = -24
	pixel_z = -32
	max_integrity = 900
	soft_armor = list(MELEE = 90, BULLET = 90 , LASER = 90, ENERGY = 90, BOMB = 85, BIO = 100, FIRE = 100, ACID = 75)
	hard_armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 100, FIRE = 0, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.7, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.5)
	max_occupants = 10
	enter_delay = 0.4 SECONDS
	ram_damage = 50
	move_delay = 0.3 SECONDS
	glide_size = 4.333
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
		/obj/structure/largecrate,
		/obj/structure/closet/crate,
	)
