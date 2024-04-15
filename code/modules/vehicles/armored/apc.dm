/obj/vehicle/sealed/armored/multitile/apc
	name = "\improper APC - Athena"
	desc = "An unarmed command APC designed to command and transport troops in the battlefield."
	icon = 'icons/obj/armored/3x3/apc.dmi'
	icon_state = "apc"
	damage_icon_path = 'icons/obj/armored/3x3/apc_damage_overlay.dmi'
	interior = /datum/interior/armored/transport
	armored_flags = ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_TRANSPORT
	permitted_weapons = list(/obj/item/armored_weapon/secondary_weapon)
	permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom, /obj/item/tank_module/interior/medical)
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	minimap_icon_state = null
	turret_icon = null
	pixel_x = -48
	pixel_y = -40
	obj_integrity = 2000
	max_integrity = 2000
	max_occupants = 20 //Clown car? Clown car.
	move_delay = 0.5 SECONDS
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
		/obj/structure/largecrate,
	)
