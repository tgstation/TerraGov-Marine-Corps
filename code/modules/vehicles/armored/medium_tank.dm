/obj/vehicle/sealed/armored/multitile/medium //Its a smaller tank, we had sprites for it so whoo
	name = "THV - Hades"
	desc = "A metal behemoth which is designed to cleave through enemy lines. It comes pre installed with a main tank cannon capable of deploying heavy payloads, as well as a minigun which can tear through multiple targets in quick succession."
	icon = 'icons/obj/armored/2x2/medium_vehicles.dmi'
	turret_icon = 'icons/obj/armored/2x2/medium_vehicles.dmi'
	turret_icon_state = "tank_turret"
	turret_dir_offsets = list(NORTH_LOWERTEXT = list(0,0), SOUTH_LOWERTEXT = list(0,0), WEST_LOWERTEXT = list(0,0), EAST_LOWERTEXT = list(0,0))
	hitbox = /obj/hitbox/medium
	secondary_turret_icon = null
	damage_icon_path = null
	icon_state = "tank"
	flags_armored = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_UNDERLAY
	pixel_x = -16
	pixel_y = -32
	obj_integrity = 1300
	max_integrity = 1300
	max_occupants = 3

/obj/vehicle/sealed/armored/multitile/medium/enter_locations(mob/M)
	return list(get_step(src, REVERSE_DIR(dir)))
