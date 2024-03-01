/obj/vehicle/sealed/armored/multitile
	name = "\improper MT - Ares"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Drag yourself onto it at an entrance to get inside."
	icon = 'icons/obj/armored/3x3/tank.dmi'
	turret_icon = 'icons/obj/armored/3x3/tank_gun.dmi'
	secondary_turret_icon = 'icons/obj/armored/3x3/tank_secondary_gun.dmi'
	damage_icon_path = 'icons/obj/armored/3x3/tank_damage.dmi'
	icon_state = "tank"
	hitbox = /obj/hitbox
	interior = /datum/interior/armored
	flags_atom = DIRLOCK|BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION
	flags_armored = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_MAP_VARIANTS|ARMORED_HAS_HEADLIGHTS
	pixel_x = -48
	pixel_y = -48
	max_integrity = 900
	soft_armor = list(MELEE = 50, BULLET = 100 , LASER = 90, ENERGY = 60, BOMB = 60, BIO = 60, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	max_occupants = 4
	move_delay = 0.9 SECONDS
	ram_damage = 70

///returns a list of possible locations that this vehicle may be entered from
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
