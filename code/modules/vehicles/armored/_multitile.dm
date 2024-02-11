/obj/vehicle/sealed/armored/multitile
	name = "TAV - Rhino"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Click it with an open hand to enter as a pilot or a gunner."
	icon = 'icons/obj/armored/3x3/tank.dmi'
	turret_icon = 'icons/obj/armored/3x3/tank_gun.dmi'
	secondary_turret_icon = 'icons/obj/armored/3x3/tank_secondary_gun.dmi'
	damage_icon_path = 'icons/obj/armored/3x3/tank_damage.dmi'
	icon_state = "tank"
	turret_dir_offsets = list(NORTH_LOWERTEXT = list(0,-48), SOUTH_LOWERTEXT = list(0,4), WEST_LOWERTEXT = list(32,-5), EAST_LOWERTEXT = list(-28,-8))
	hitbox = /obj/hitbox
	flags_armored = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_MAP_VARIANTS
	pixel_x = -48
	pixel_y = -48
	obj_integrity = 2000
	max_integrity = 2000
	max_occupants = 4
	move_delay = 0.5 SECONDS

/obj/vehicle/sealed/armored/multitile/proc/enter_locations(mob/M)
	return list(get_step_away(get_step(src, REVERSE_DIR(dir)), src, 2))

/obj/vehicle/sealed/armored/multitile/exit_location(mob/M)
	return pick(enter_locations(M))

/obj/vehicle/sealed/armored/multitile/mob_try_enter(mob/M)
	if(!(M.loc in enter_locations(M)))
		balloon_alert(M, "Not at entrance")
		return FALSE
	return ..()

/obj/vehicle/sealed/armored/multitile/enter_checks(mob/M)
	. = ..()
	if(!.)
		return
	return (M.loc in enter_locations(M))
