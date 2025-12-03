/obj/vehicle/sealed/armored/apc
	name = "TAV - Nike"
	desc = "A miniaturized replica of a popular personnel carrier. For ages 5 and up."
	icon = 'icons/obj/armored/1x1/tinytank.dmi'
	turret_icon = 'icons/obj/armored/1x1/tinytank_gun.dmi'
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_ASSAULT
	turret_icon_state = "apc_turret"
	icon_state = "apc"
	move_delay = 0.3 SECONDS
	obj_integrity = 150
	max_integrity = 150 // How about we don't have the itty bitty guy have 600 hp
	pixel_x = -16
	pixel_y = -8
	max_occupants = 3
	permitted_mods = list(
		/obj/item/tank_module/passenger,
		/obj/item/tank_module/ability/zoom,
		/obj/item/tank_module/ability/smoke_launcher
	)
