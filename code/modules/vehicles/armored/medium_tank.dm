/obj/vehicle/sealed/armored/multitile/medium //Its a smaller tank, we had sprites for it so whoo
	name = "THV - Hades"
	desc = "A metal behemoth which is designed to cleave through enemy lines. It comes pre installed with a main tank cannon capable of deploying heavy payloads, as well as a minigun which can tear through multiple targets in quick succession."
	icon = 'icons/obj/armored/2x2/medium_vehicles.dmi'
	turret_icon = 'icons/obj/armored/2x2/medium_vehicles.dmi'
	turret_icon_state = "tank_turret"
	hitbox = /obj/hitbox/medium
	damage_icon_path = null
//	interior = /datum/interior/armored
	icon_state = "tank"
	permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom)
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_ASSAULT
	pixel_x = -16
	pixel_y = -32
	obj_integrity = 700
	max_integrity = 700
	max_occupants = 4
	move_delay = 0.75 SECONDS

/obj/vehicle/sealed/armored/multitile/medium/enter_locations(atom/movable/entering_thing)
	return list(get_step(src, REVERSE_DIR(dir)))
