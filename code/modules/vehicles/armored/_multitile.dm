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
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_HEADLIGHTS|ARMORED_PURCHASABLE_ASSAULT|ARMORED_WRECKABLE
	appearance_flags = PIXEL_SCALE
	pixel_x = -56
	pixel_y = -48
	max_integrity = 900
	soft_armor = list(MELEE = 50, BULLET = 100 , LASER = 90, ENERGY = 60, BOMB = 60, BIO = 100, FIRE = 50, ACID = 50)
	hard_armor = list(MELEE = 0, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 20, FIRE = 0, ACID = 0)
	permitted_mods = list(
		/obj/item/tank_module/overdrive,
		/obj/item/tank_module/ability/zoom,
		/obj/item/tank_module/ability/smoke_launcher,
	)
	permitted_weapons = list(
		/obj/item/armored_weapon,
		/obj/item/armored_weapon/ltaap,
		/obj/item/armored_weapon/bfg,
		/obj/item/armored_weapon/tank_autocannon,

		/obj/item/armored_weapon/secondary_weapon,
		/obj/item/armored_weapon/secondary_flamer,
		/obj/item/armored_weapon/tow,
		/obj/item/armored_weapon/microrocket_pod,
	)
	max_occupants = 4
	move_delay = 0.75 SECONDS
	glide_size = 2.5

	ram_damage = 100
	easy_load_list = list(
		/obj/item/ammo_magazine/tank,
	)
	///pass_flags given to desants, in addition to the vehicle's pass_flags
	var/desant_pass_flags = PASS_FIRE|PASS_LOW_STRUCTURE
	///particle holder for smoke effects
	var/obj/effect/abstract/particle_holder/smoke_holder
	///Holder for smoke del timer
	var/smoke_del_timer

/obj/vehicle/sealed/armored/multitile/Destroy()
	QDEL_NULL(smoke_holder)
	return ..()

/obj/vehicle/sealed/armored/multitile/update_name(updates)
	. = ..()
	name = initial(name)
	if(armored_flags & ARMORED_IS_WRECK)
		name = "wrecked " + name

/obj/vehicle/sealed/armored/multitile/update_desc(updates)
	. = ..()
	desc = initial(desc)
	if(armored_flags & ARMORED_IS_WRECK)
		desc += " Now just a smouldering ruin."

/obj/vehicle/sealed/armored/multitile/deconstruct(disassembled = TRUE, mob/living/blame_mob)
	if(!(armored_flags & ARMORED_WRECKABLE))
		return ..()
	if((armored_flags & ARMORED_IS_WRECK))
		return ..()
	wreck_vehicle()

/obj/vehicle/sealed/armored/multitile/update_icon_state()
	. = ..()
	if(armored_flags & ARMORED_IS_WRECK)
		icon_state = initial(icon_state) + "_wreck"
	else
		icon_state = initial(icon_state)

/obj/vehicle/sealed/armored/multitile/enter_locations(atom/movable/entering_thing)
	return list(get_step_away(get_step(src, REVERSE_DIR(dir)), src, 2))

/obj/vehicle/sealed/armored/multitile/exit_location(mob/M)
	return pick(enter_locations(M))

/obj/vehicle/sealed/armored/multitile/enter_checks(mob/entering_mob, loc_override = FALSE)
	if(armored_flags & ARMORED_IS_WRECK)
		return
	. = ..()
	if(!.)
		return
	return (loc_override || (entering_mob.loc in enter_locations(entering_mob)))

/obj/vehicle/sealed/armored/multitile/add_desant(mob/living/new_desant)
	new_desant.add_pass_flags(desant_pass_flags|pass_flags, VEHICLE_TRAIT)

/obj/vehicle/sealed/armored/multitile/remove_desant(mob/living/old_desant)
	old_desant.remove_pass_flags(desant_pass_flags|pass_flags, VEHICLE_TRAIT)

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

///Puts the vehicle into a wrecked state
/obj/vehicle/sealed/armored/multitile/proc/wreck_vehicle()
	if(armored_flags & ARMORED_IS_WRECK)
		return
	for(var/mob/occupant AS in occupants)
		mob_exit(occupant, FALSE, TRUE)
	armored_flags |= ARMORED_IS_WRECK
	obj_integrity = max_integrity
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC|UPDATE_NAME)
	smoke_holder = new(src, /particles/tank_wreck_smoke)
	smoke_del_timer = addtimer(CALLBACK(src, PROC_REF(del_smoke)), 10 MINUTES, TIMER_STOPPABLE)
	if(turret_overlay)
		RegisterSignal(turret_overlay, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_smoke_dir))
		update_smoke_dir(newdir = turret_overlay.dir)
		turret_overlay.icon_state += "_wreck"
		turret_overlay?.primary_overlay?.icon_state += "_wreck"
	update_minimap_icon()

///Returns the vehicle to an unwrecked state
/obj/vehicle/sealed/armored/multitile/proc/unwreck_vehicle(restore = FALSE)
	if(!(armored_flags & ARMORED_IS_WRECK))
		return
	armored_flags &= ~ARMORED_IS_WRECK
	obj_integrity = restore ? max_integrity : 50
	update_appearance(UPDATE_ICON_STATE|UPDATE_DESC|UPDATE_NAME)
	QDEL_NULL(smoke_holder)
	deltimer(smoke_del_timer)
	smoke_del_timer = null
	if(turret_overlay)
		UnregisterSignal(turret_overlay, COMSIG_ATOM_DIR_CHANGE)
		turret_overlay.icon_state = turret_overlay.base_icon_state
		turret_overlay?.primary_overlay?.icon_state = turret_overlay?.primary_overlay?.base_icon_state
	update_minimap_icon()

///Updates the wreck smoke position
/obj/vehicle/sealed/armored/multitile/proc/update_smoke_dir(datum/source, dir, newdir)
	SIGNAL_HANDLER
	switch(newdir)
		if(SOUTH)
			smoke_holder.particles.position = list(54, 88, 0)
		if(NORTH)
			smoke_holder.particles.position = list(54, 80, 0)
		if(EAST)
			smoke_holder.particles.position = list(54, 85, 0)
		if(WEST)
			smoke_holder.particles.position = list(60, 85, 0)

/obj/vehicle/sealed/armored/multitile/proc/del_smoke()
	QDEL_NULL(smoke_holder)
	UnregisterSignal(turret_overlay, COMSIG_ATOM_DIR_CHANGE)

//THe HvX tank is not balanced at all for HvH
/obj/vehicle/sealed/armored/multitile/campaign
	desc = "A gigantic wall of metal designed for maximum SOM destruction. Drag yourself onto it at an entrance to get inside."
	required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	max_integrity = 1400
	soft_armor = list(MELEE = 90, BULLET = 95 , LASER = 95, ENERGY = 95, BOMB = 80, BIO = 100, FIRE = 100, ACID = 75)
	hard_armor = list(MELEE = 10, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 40, BIO = 100, FIRE = 0, ACID = 0)
	facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 0.55, VEHICLE_SIDE_ARMOUR = 0.85, VEHICLE_BACK_ARMOUR = 1.6)
	armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_SECONDARY_WEAPON|ARMORED_HAS_UNDERLAY|ARMORED_HAS_HEADLIGHTS|ARMORED_WRECKABLE
	move_delay = 0.5 SECONDS
	glide_size = 2.8
	faction = FACTION_TERRAGOV
	ram_damage = 130

/obj/vehicle/sealed/armored/multitile/campaign/Initialize(mapload)
	. = ..()
	var/obj/item/tank_module/module = new /obj/item/tank_module/ability/smoke_launcher()
	module.on_equip(src)
