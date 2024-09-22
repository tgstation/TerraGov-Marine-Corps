/obj/vehicle/sealed/armored/multitile
	name = "\improper MT - Banteng"
	desc = "A gigantic wall of metal designed for maximum Xeno destruction. Drag yourself onto it at an entrance to get inside."
	icon = 'icons/obj/armored/3x3/tank.dmi'
	turret_icon = 'icons/obj/armored/3x3/tank_gun.dmi'
	damage_icon_path = 'icons/obj/armored/3x3/tank_damage.dmi'
	icon_state = "tank"
	hitbox = /obj/hitbox
	interior = /datum/interior/armored
	minimap_icon_state = "tank"
	required_entry_skill = SKILL_LARGE_VEHICLE_TRAINED
	atom_flags = DIRLOCK|BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION|CRITICAL_ATOM
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_ASSAULT
	appearance_flags = PIXEL_SCALE
	pixel_x = -56
	pixel_y = -48
	max_integrity = 900
	soft_armor = list(MELEE = 50, BULLET = 100 , LASER = 90, ENERGY = 60, BOMB = 60, BIO = 60, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	permitted_mods = list(/obj/item/tank_module/overdrive, /obj/item/tank_module/ability/zoom, /obj/item/tank_module/ability/smoke_launcher)
	permitted_weapons = list(/obj/item/armored_weapon, /obj/item/armored_weapon/ltaap, /obj/item/armored_weapon/secondary_weapon, /obj/item/armored_weapon/secondary_flamer)
	max_occupants = 4
	move_delay = 0.75 SECONDS
	glide_size = 2.5
	ram_damage = 100
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
	)
	///pass_flags given to desants, in addition to the vehicle's pass_flags
	var/desant_pass_flags = PASS_FIRE|PASS_LOW_STRUCTURE

/obj/vehicle/sealed/armored/multitile/enter_locations(atom/movable/entering_thing)
	return list(get_step_away(get_step(src, REVERSE_DIR(dir)), src, 2))

/obj/vehicle/sealed/armored/multitile/exit_location(mob/M)
	return pick(enter_locations(M))

/obj/vehicle/sealed/armored/multitile/enter_checks(mob/entering_mob, loc_override = FALSE)
	. = ..()
	if(!.)
		return
	return (loc_override || (entering_mob.loc in enter_locations(entering_mob)))

/obj/vehicle/sealed/armored/multitile/add_desant(mob/living/new_desant)
	new_desant.pass_flags |= (desant_pass_flags|pass_flags)

/obj/vehicle/sealed/armored/multitile/remove_desant(mob/living/old_desant)
	old_desant.pass_flags &= ~(desant_pass_flags|pass_flags)

/obj/vehicle/sealed/armored/multitile/ex_act(severity)
	if(QDELETED(src))
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(500, BRUTE, BOMB, 0)
		if(EXPLODE_HEAVY)
			take_damage(80, BRUTE, BOMB, 0)
		if(EXPLODE_LIGHT)
			take_damage(10, BRUTE, BOMB, 0)
		//weak explosions do nothing

/obj/vehicle/sealed/armored/multitile/lava_act()
	if(QDELETED(src))
		return
	take_damage(30, BURN, FIRE)

/obj/vehicle/sealed/armored/multitile/Shake(pixelshiftx = 2, pixelshifty = 2, duration = 2.5 SECONDS, shake_interval = 0.02 SECONDS)
	. = ..()
	for(var/mob/living/occupant AS in occupants)
		var/strength = 1
		if(occupant.buckled)
			strength = 0.5
		shake_camera(occupant, duration, strength)
	for(var/atom/movable/desant AS in hitbox?.tank_desants)
		desant.Shake(pixelshiftx, pixelshifty, duration, shake_interval)

//THe HvX tank is not balanced at all for HvH
/obj/vehicle/sealed/armored/multitile/campaign
	desc = "A gigantic wall of metal designed for maximum SOM destruction. Drag yourself onto it at an entrance to get inside."
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	max_integrity = 1400
	soft_armor = list(MELEE = 90, BULLET = 95 , LASER = 95, ENERGY = 95, BOMB = 85, BIO = 100, FIRE = 100, ACID = 75)
	hard_armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 35, BIO = 100, FIRE = 0, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.6, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1.6)
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_HEADLIGHTS
	move_delay = 0.6 SECONDS
	glide_size = 2.5
	vis_range_mod = 4
	faction = FACTION_TERRAGOV
	ram_damage = 130

/obj/vehicle/sealed/armored/multitile/campaign/Initialize(mapload)
	. = ..()
	var/obj/item/tank_module/module = new /obj/item/tank_module/ability/smoke_launcher()
	module.on_equip(src)
