/particles/mecha_boosting
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("steam_1" = 1, "steam_2" = 1, "steam_3" = 2)
	width = 200
	height = 200
	count = 1000
	spawning = 0
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	velocity = list(0, -0.6, 0)
	position = list(5, 32, 0)
	color = "#85e1e1"
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.2
	gravity = list(0, -0.95)
	grow = 0.05

/**
 * Fast mechs. like from armored core
 */
/obj/vehicle/sealed/mecha/combat/greyscale/core
	pixel_x = -32
	pixel_y = -5
	light_pixel_x = 32
	ability_module_icon = 'icons/mecha/mech_core_overlays.dmi'
	use_damage_particles = FALSE
	use_gun_boost_prefix = TRUE
	equip_by_category = list(
		MECHA_L_ARM = null,
		MECHA_R_ARM = null,
		MECHA_L_BACK = null,
		MECHA_R_BACK = null,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/medium,
		MECH_GREY_HEAD = /datum/mech_limb/head/medium,
		MECH_GREY_LEGS = /datum/mech_limb/legs/medium,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/medium,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/medium,
	)
	///left boosting particles holder
	var/obj/effect/abstract/particle_holder/booster_left
	///right boosting particles holder
	var/obj/effect/abstract/particle_holder/booster_right

/obj/vehicle/sealed/mecha/combat/greyscale/core/Initialize(mapload)
	booster_left = new(src, /particles/mecha_boosting)
	booster_left.layer = layer+0.001
	booster_right = new(src, /particles/mecha_boosting)
	booster_right.layer = layer+0.001
	return ..()

/obj/vehicle/sealed/mecha/combat/greyscale/core/update_icon()
	. = ..()
	if(QDELING(src))
		return
	if(!leg_overload_mode)
		booster_left.particles.spawning = 0
		booster_right.particles.spawning = 0
		return
	booster_left.particles.spawning = 3
	booster_right.particles.spawning = 3
	if(dir & WEST)
		booster_left.particles.position = list(45, 37, 0)
		booster_right.particles.position = list(45, 42, 0)
		booster_left.particles.velocity = list(2, -0.6)
		booster_right.particles.velocity = list(2, -0.6)
		booster_left.layer = layer+0.002
	else if(dir & EAST)
		booster_left.particles.position = list(15, 32, 0)
		booster_right.particles.position = list(15, 37, 0)
		booster_left.particles.velocity = list(-2, -0.6)
		booster_right.particles.velocity = list(-2, -0.6)
		booster_left.layer = layer+0.001
	else
		booster_left.particles.position = list(22, 32, 0)
		booster_right.particles.position = list(41, 32, 0)
		booster_left.particles.velocity = list(0, -0.6)
		booster_right.particles.velocity = list(0, -0.6)
		if(dir & SOUTH)
			booster_left.layer = layer-0.001
			booster_right.layer = layer-0.001
		else
			booster_left.layer = layer+0.001
			booster_right.layer = layer+0.001

/obj/vehicle/sealed/mecha/combat/greyscale/core/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_controlled_weapons)

/obj/vehicle/sealed/mecha/combat/greyscale/core/deconstruct(disassembled, mob/living/blame_mob)
	if(is_wreck)
		return ..()
	for(var/mob/occupant AS in occupants)
		mob_exit(occupant, FALSE, TRUE)
	setDir(dir_in) // in case of no occupants we need to fix layering and dir
	is_wreck = TRUE
	obj_integrity = max_integrity
	update_appearance()

///swaps equipped back and arm weapons out
/obj/vehicle/sealed/mecha/combat/greyscale/core/proc/swap_weapons()
	var/obj/item/mecha_parts/mecha_equipment/old_r_hand = equip_by_category[MECHA_R_ARM]
	var/obj/item/mecha_parts/mecha_equipment/old_l_hand = equip_by_category[MECHA_L_ARM]
	var/obj/item/mecha_parts/mecha_equipment/old_r_back = equip_by_category[MECHA_R_BACK]
	var/obj/item/mecha_parts/mecha_equipment/old_l_back = equip_by_category[MECHA_L_BACK]

	old_r_hand?.detach(src)
	old_l_hand?.detach(src)
	old_r_back?.detach(src)
	old_l_back?.detach(src)

	old_r_hand?.equipment_slot = MECHA_BACK
	old_l_hand?.equipment_slot = MECHA_BACK
	old_r_back?.equipment_slot = MECHA_WEAPON
	old_l_back?.equipment_slot = MECHA_WEAPON

	old_r_hand?.attach(src, TRUE)
	old_l_hand?.attach(src, FALSE)
	old_r_back?.attach(src, TRUE)
	old_l_back?.attach(src, FALSE)
	swapped_to_backweapons = !swapped_to_backweapons
	update_appearance(UPDATE_OVERLAYS)

/obj/vehicle/sealed/mecha/combat/greyscale/core/medium
	name = "medium debug mech core"
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/assault_rifle,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/smg,
		MECHA_L_BACK = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/heavyrocket,
		MECHA_R_BACK = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/heavyrocket,
		MECHA_UTILITY = list(),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)
	limbs = list(
		MECH_GREY_TORSO = /datum/mech_limb/torso/medium,
		MECH_GREY_HEAD = /datum/mech_limb/head/medium,
		MECH_GREY_LEGS = /datum/mech_limb/legs/medium,
		MECH_GREY_R_ARM = /datum/mech_limb/arm/medium,
		MECH_GREY_L_ARM = /datum/mech_limb/arm/medium,
	)
