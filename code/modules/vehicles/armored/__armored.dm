/obj/vehicle/sealed/armored
	name = "\improper MT - Shortstreet MK4"
	desc = "An adorable chunk of metal with an alarming amount of firepower designed to crush, immolate, destroy and maim anything that Nanotrasen wants it to. This model contains advanced Bluespace technology which allows a TARDIS-like amount of room on the inside."
	icon = 'icons/obj/armored/1x1/tinytank.dmi'
	icon_state = "tank"
	pixel_x = -16
	pixel_y = -8
	layer = ABOVE_MOB_LAYER
	max_drivers = 1
	move_resist = INFINITY
	atom_flags = BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION|CRITICAL_ATOM
	allow_pass_flags = PASS_TANK|PASS_AIR|PASS_WALKOVER|PASS_THROW
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE|PLASMACUTTER_IMMUNE|PORTAL_IMMUNE

	move_delay = 0.7 SECONDS
	max_integrity = 600
	light_range = 10
	///Tank bitflags
	var/armored_flags = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_HEADLIGHTS

	///sound loop that plays when we are not moving with a driver present
	var/datum/looping_sound/idle_loop = /datum/looping_sound/tank_idle
	/// sound loop that plays inside the tank when driver is in but we're not moving
	var/datum/looping_sound/idle_inside_loop = /datum/looping_sound/tank_idle_interior
	/// sound loop that plays while we move around
	var/datum/looping_sound/drive_loop = /datum/looping_sound/tank_drive
	/// sound that plays inside when we drive around
	var/datum/looping_sound/drive_inside_loop = /datum/looping_sound/tank_drive_interior
	/// sound to play outside the tank after the driver leaves
	var/engine_off_sound = 'sound/vehicles/looping/tank_eng_interior_stop.ogg'
	/// sound to play inside the tank after the driver leaves
	var/engine_off_interior_sound = 'sound/vehicles/looping/tank_eng_stop.ogg'

	///Cool and good turret overlay that allows independently swiveling guns
	var/atom/movable/vis_obj/turret_overlay/turret_overlay = /atom/movable/vis_obj/turret_overlay
	///Icon for the rotating turret icon. also should hold the icons for the weapon icons
	var/turret_icon = 'icons/obj/armored/1x1/tinytank_gun.dmi'
	///Iconstate for the rotating main turret
	var/turret_icon_state = "turret"
	///secondary independently rotating overlay, if we only have a secondary weapon
	var/image/secondary_weapon_overlay
	///Damage overlay for when the vehicle gets damaged
	var/atom/movable/vis_obj/tank_damage/damage_overlay
	///Icon file path for the damage overlay
	var/damage_icon_path
	///Overlay for larger vehicles that need under parts
	var/image/underlay

	///reference to our interior datum if set, uses the typepath its set to
	var/datum/interior/armored/interior
	///Skill required to enter this vehicle
	var/required_entry_skill = SKILL_LARGE_VEHICLE_DEFAULT
	///What weapon we have in our primary slot
	var/obj/item/armored_weapon/primary_weapon
	///What weapon we have in our secondary slot
	var/obj/item/armored_weapon/secondary_weapon
	///Our driver utility module
	var/obj/item/tank_module/driver_utility_module
	///Our driver utility module
	var/obj/item/tank_module/gunner_utility_module
	///list of weapons we allow to attach
	var/list/permitted_weapons = list(
		/obj/item/armored_weapon,
		/obj/item/armored_weapon/ltaap,
		/obj/item/armored_weapon/secondary_weapon,
		/obj/item/armored_weapon/secondary_flamer,
	)
	///list of mods we allow to attach
	var/list/permitted_mods = list(
		/obj/item/tank_module/overdrive,
		/obj/item/tank_module/passenger,
		/obj/item/tank_module/ability/zoom
	)
	///Minimap flags to use for this vehcile
	var/minimap_flags = MINIMAP_FLAG_MARINE
	///minimap iconstate to use for this vehicle
	var/minimap_icon_state
	///if true disables stops users from being able to shoot weapons
	var/weapons_safety = FALSE
	//Bool for zoom on/off
	var/zoom_mode = FALSE
	/// damage done by rams
	var/ram_damage = 20
	/**
	 * List for storing all item typepaths that we may "easy load" into the tank by attacking its entrance
	 * This will be turned into a typeCache on  initialize
	*/
	var/list/easy_load_list
	///Wether we are strafing
	var/strafe = FALSE

/obj/vehicle/sealed/armored/Initialize(mapload)
	easy_load_list = typecacheof(easy_load_list)
	if(interior)
		interior = new interior(src, CALLBACK(src, PROC_REF(interior_exit)))
	. = ..()
	if(armored_flags & ARMORED_HAS_UNDERLAY)
		underlay = new(icon, icon_state + "_underlay", layer = layer-0.1)
		add_overlay(underlay)
	if(damage_icon_path)
		damage_overlay = new()
		damage_overlay.icon = damage_icon_path
		damage_overlay.layer = layer+0.001
		vis_contents += damage_overlay
	if(armored_flags & ARMORED_HAS_PRIMARY_WEAPON)
		turret_overlay = new turret_overlay(null, src)
		setDir(dir) //update turret offsets if needed
		if(armored_flags & ARMORED_HAS_MAP_VARIANTS)
			switch(SSmapping.configs[GROUND_MAP].armor_style)
				if(MAP_ARMOR_STYLE_JUNGLE)
					turret_overlay.icon_state += "_jungle"
				if(MAP_ARMOR_STYLE_ICE)
					turret_overlay.icon_state += "_snow"
				if(MAP_ARMOR_STYLE_PRISON)
					turret_overlay.icon_state += "_urban"
				if(MAP_ARMOR_STYLE_DESERT)
					turret_overlay.icon_state += "_desert"
		vis_contents += turret_overlay
	else
		turret_overlay = null
	if(armored_flags & ARMORED_HAS_MAP_VARIANTS)
		switch(SSmapping.configs[GROUND_MAP].armor_style)
			if(MAP_ARMOR_STYLE_JUNGLE)
				icon_state += "_jungle"
			if(MAP_ARMOR_STYLE_ICE)
				icon_state += "_snow"
			if(MAP_ARMOR_STYLE_PRISON)
				icon_state += "_urban"
			if(MAP_ARMOR_STYLE_DESERT)
				icon_state += "_desert"

	if(idle_loop)
		idle_loop = new idle_loop(list(src))
	if(idle_inside_loop)
		idle_inside_loop = new idle_inside_loop()
	if(drive_loop)
		drive_loop = new drive_loop(list(src))
	if(drive_inside_loop)
		drive_inside_loop = new drive_inside_loop()

	update_minimap_icon()
	GLOB.tank_list += src

/obj/vehicle/sealed/armored/Destroy()
	if(primary_weapon)
		QDEL_NULL(primary_weapon)
	if(secondary_weapon)
		QDEL_NULL(secondary_weapon)
	if(driver_utility_module)
		QDEL_NULL(driver_utility_module)
	if(gunner_utility_module)
		QDEL_NULL(gunner_utility_module)
	if(damage_overlay)
		QDEL_NULL(damage_overlay)

	// can be delled before init makes these due to globs
	if(isdatum(idle_loop))
		QDEL_NULL(idle_loop)
	if(isdatum(idle_inside_loop))
		QDEL_NULL(idle_inside_loop)
	if(isdatum(drive_loop))
		QDEL_NULL(drive_loop)
	if(isdatum(drive_inside_loop))
		QDEL_NULL(drive_inside_loop)
	if(isatom(turret_overlay))
		QDEL_NULL(turret_overlay)
	if(isdatum(interior))
		QDEL_NULL(interior)
	underlay = null
	GLOB.tank_list -= src
	return ..()

/obj/vehicle/sealed/armored/generate_actions()
	if(armored_flags & ARMORED_HAS_HEADLIGHTS)
		initialize_controller_action_type(/datum/action/vehicle/sealed/armored/toggle_lights, VEHICLE_CONTROL_SETTINGS)
	initialize_controller_action_type(/datum/action/vehicle/sealed/armored/horn, VEHICLE_CONTROL_SETTINGS)
	if(interior)
		return
	initialize_passenger_action_type(/datum/action/vehicle/sealed/armored/eject)
	if(max_occupants > 1)
		initialize_passenger_action_type(/datum/action/vehicle/sealed/armored/swap_seat)

///returns a list of possible locations that this vehicle may be entered from
/obj/vehicle/sealed/armored/proc/enter_locations(atom/movable/entering_thing)
	// from any adjacent position
	if(Adjacent(entering_thing, src))
		return list(get_turf(entering_thing))

/obj/vehicle/sealed/armored/obj_destruction(damage_amount, damage_type, damage_flag, mob/living/blame_mob)
	playsound(get_turf(src), SFX_EXPLOSION_LARGE, 100, TRUE) //destroy sound is normally very quiet
	new /obj/effect/temp_visual/explosion(get_turf(src), 7, LIGHT_COLOR_LAVA, FALSE, TRUE)
	for(var/mob/living/nearby_mob AS in occupants + cheap_get_living_near(src, 7))
		shake_camera(nearby_mob, 4, 2)
	if(istype(blame_mob) && blame_mob.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[blame_mob.ckey]
		if(faction == blame_mob.faction)
			personal_statistics.tanks_destroyed --
			personal_statistics.mission_tanks_destroyed --
		else
			personal_statistics.tanks_destroyed ++
			personal_statistics.mission_tanks_destroyed ++

	return ..()

/obj/vehicle/sealed/armored/update_icon_state()
	. = ..()
	if(!damage_overlay)
		return
	switch(PERCENT(obj_integrity / max_integrity))
		if(0 to 20)
			damage_overlay.icon_state = "damage_veryhigh"
		if(20 to 40)
			damage_overlay.icon_state = "damage_high"
		if(40 to 70)
			damage_overlay.icon_state = "damage_medium"
		if(70 to 90)
			damage_overlay.icon_state = "damage_small"
		else
			damage_overlay.icon_state = "null"

/obj/vehicle/sealed/armored/update_overlays()
	. = ..()
	if(secondary_weapon_overlay)
		. += secondary_weapon_overlay

/obj/vehicle/sealed/armored/setDir(newdir)
	. = ..()
	if(secondary_weapon_overlay)
		cut_overlay(secondary_weapon_overlay)
		secondary_weapon_overlay.icon_state = secondary_weapon.icon_state + "_" + "[newdir]"
		add_overlay(secondary_weapon_overlay)

/obj/vehicle/sealed/armored/examine(mob/user)
	. = ..()
	if(!isxeno(user))
		. += "To fire its main cannon, left click a tile."
		. += "To fire its secondary weapon, right click a tile."
		. += "Middle click to toggle weapon safety."
		. += "It's currently holding [LAZYLEN(occupants)]/[max_occupants] crew."
	. += span_notice("There is [isnull(primary_weapon) ? "nothing" : "[primary_weapon]"] in the primary attachment point, [isnull(secondary_weapon) ? "nothing" : "[secondary_weapon]"] installed in the secondary slot, [isnull(driver_utility_module) ? "nothing" : "[driver_utility_module]"] in the driver utility slot and [isnull(gunner_utility_module) ? "nothing" : "[gunner_utility_module]"] in the gunner utility slot.")
	if(!isxeno(user))
		. += "<b>It is currently at <u>[PERCENT(obj_integrity / max_integrity)]%</u> integrity.</b>"

/obj/vehicle/sealed/armored/get_mechanics_info()
	. = ..()
	var/list/named_paths = list()
	named_paths += "<b> You can easily load the following items by attacking the vehicle at its entrance or click dragging them </b>"
	for(var/obj/path AS in easy_load_list)
		named_paths.Add(initial(path:name))
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry?.mechanics_text)
		named_paths += general_entry.mechanics_text
	return jointext(named_paths, "<br>")

/obj/vehicle/sealed/armored/vehicle_move(mob/living/user, direction)
	. = ..()
	if(!.)
		return
	after_move(direction)
	forceMove(get_step(src, direction)) // still animates and calls moved() and all that stuff BUT we skip checks
	//we still need to handroll some parts of moved though since we skipped everything
	last_move = direction
	last_move_time = world.time
	if(currently_z_moving)
		var/turf/pitfall = get_turf(src)
		pitfall.zFall(src, falling_from_move = TRUE)

/obj/vehicle/sealed/armored/resisted_against(mob/living/user)
	balloon_alert(user, "exiting...")
	if(do_after(user, enter_delay, NONE, src))
		balloon_alert(user, "exited")
		mob_exit(user, TRUE)

/obj/vehicle/sealed/armored/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(.)
		return
	if((allow_pass_flags & PASS_TANK) && (mover.pass_flags & PASS_TANK))
		return TRUE

/obj/vehicle/sealed/armored/Bump(atom/A)
	. = ..()
	if(HAS_TRAIT(A, TRAIT_STOPS_TANK_COLLISION))
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_VEHICLE_CRUSHSOUND))
			visible_message(span_danger("[src] is stopped by [A]!"))
			playsound(A, 'sound/effects/metal_crash.ogg', 45)
			TIMER_COOLDOWN_START(src, COOLDOWN_VEHICLE_CRUSHSOUND, 1 SECONDS)
		return
	var/pilot
	var/list/drivers = return_drivers()
	if(length(drivers))
		pilot = drivers[1]
	A.vehicle_collision(src, get_dir(src, A), pilot)
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_VEHICLE_CRUSHSOUND))
		return
	visible_message(span_danger("[src] rams [A]!"))
	playsound(A, 'sound/effects/metal_crash.ogg', 45)
	TIMER_COOLDOWN_START(src, COOLDOWN_VEHICLE_CRUSHSOUND, 1 SECONDS)

/obj/vehicle/sealed/armored/auto_assign_occupant_flags(mob/new_occupant)
	if(interior) //handled by interior seats
		return
	if(max_occupants == 1)
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		return

	if(driver_amount() < max_drivers) //movement controllers
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else if(length(return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)) < 1)
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/armored/exit_location(mob/M)
	return get_step(src, REVERSE_DIR(dir))

/obj/vehicle/sealed/armored/emp_act(severity)
	. = ..()
	playsound(get_turf(src), 'sound/magic/lightningshock.ogg', 50, FALSE)
	take_damage(400 / severity, BURN, ENERGY)
	for(var/mob/living/living_occupant AS in occupants)
		living_occupant.Stagger((6 - severity) SECONDS)

/obj/vehicle/sealed/armored/process()
	if(cooldown_vehicle_move + 10 > world.time)
		return // tank is currently trying to move around
	if(drive_loop?.timer_id)
		drive_loop.stop()
		idle_loop?.start(skip_startsound=TRUE)
		drive_inside_loop?.stop(occupants)
		idle_inside_loop?.start(occupants.Copy(), TRUE)

///called when a mob tried to leave our interior
/obj/vehicle/sealed/armored/proc/interior_exit(mob/leaver, datum/interior/inside, teleport)
	if(!teleport)
		remove_occupant(leaver)
		return
	mob_exit(leaver, TRUE)

/// call to try easy_loading an item into the tank. Checks for all being in the list , interior existing and the user bieng at the enter loc
/obj/vehicle/sealed/armored/proc/try_easy_load(atom/movable/thing_to_load, mob/living/user)
	if(isgrabitem(thing_to_load))
		var/obj/item/grab/grab_item = thing_to_load
		thing_to_load = grab_item.grabbed_thing
	if(!isliving(thing_to_load) && !is_type_in_typecache(thing_to_load.type, easy_load_list))
		return FALSE
	if(!interior)
		user.balloon_alert(user, "no interior")
		return FALSE
	if(!interior.door)
		user.balloon_alert(user, "no door")
		return FALSE
	var/list/enter_locs = enter_locations(user)
	if(!((user.loc in enter_locs) || (thing_to_load.loc in enter_locs)))
		user.balloon_alert(user, "not at entrance")
		return FALSE
	if(isliving(thing_to_load))
		user.visible_message(span_notice("[user] starts to stuff [thing_to_load] into \the [src]!"))
		return mob_try_enter(thing_to_load, user, TRUE)
	if(isitem(thing_to_load))
		user.temporarilyRemoveItemFromInventory(thing_to_load)
	thing_to_load.forceMove(interior.door.get_enter_location())
	user.balloon_alert(user, "item thrown inside")
	return TRUE

/obj/vehicle/sealed/armored/mob_try_enter(mob/entering_mob, mob/user, loc_override = FALSE)
	if(isobserver(entering_mob))
		interior?.mob_enter(entering_mob)
		return FALSE
	if(!ishuman(entering_mob))
		return FALSE
	if(entering_mob.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		return FALSE
	if(!loc_override && !(entering_mob.loc in enter_locations(entering_mob)))
		balloon_alert(entering_mob, "not at entrance")
		return FALSE
	return ..()

/obj/vehicle/sealed/armored/enter_checks(mob/entering_mob, loc_override = FALSE)
	. = ..()
	if(!.)
		return
	if(LAZYLEN(entering_mob.buckled_mobs))
		balloon_alert(entering_mob, "remove riders first")
		return FALSE

/obj/vehicle/sealed/armored/add_occupant(mob/M, control_flags)
	if(!interior)
		RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(mob_exit), TRUE)
		RegisterSignal(M, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against), TRUE)
	. = ..()
	if(primary_weapon)
		var/list/primary_icons
		if(primary_weapon.ammo)
			primary_icons = list(primary_weapon.ammo.default_ammo.hud_state, primary_weapon.ammo.default_ammo.hud_state_empty)
		else
			primary_icons = list(primary_weapon.hud_state_empty, primary_weapon.hud_state_empty)
		M?.hud_used?.add_ammo_hud(primary_weapon, primary_icons, primary_weapon?.ammo?.current_rounds)
	if(secondary_weapon)
		var/list/secondary_icons
		if(secondary_weapon.ammo)
			secondary_icons = list(secondary_weapon.ammo.default_ammo.hud_state, secondary_weapon.ammo.default_ammo.hud_state_empty)
		else
			secondary_icons = list(secondary_weapon.hud_state_empty, secondary_weapon.hud_state_empty)
		M?.hud_used?.add_ammo_hud(secondary_weapon, secondary_icons, secondary_weapon?.ammo?.current_rounds)
	if(idle_inside_loop?.timer_id)
		idle_inside_loop.start(M, TRUE)
	else if(drive_inside_loop?.timer_id)
		drive_inside_loop.start(M, TRUE)

/obj/vehicle/sealed/armored/after_add_occupant(mob/M)
	. = ..()
	if(interior)
		REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/vehicle/sealed/armored/grant_controller_actions_by_flag(mob/M, flag)
	. = ..()
	if(. && (flag & VEHICLE_CONTROL_EQUIPMENT))
		RegisterSignal(M, COMSIG_MOB_MOUSEDOWN, PROC_REF(on_mouseclick), TRUE)
	if(. && (flag & VEHICLE_CONTROL_DRIVE) && !(datum_flags & DF_ISPROCESSING))
		START_PROCESSING(SSfastprocess, src)
		idle_loop.start()
		idle_inside_loop.start(occupants.Copy())

/obj/vehicle/sealed/armored/remove_controller_actions_by_flag(mob/M, flag)
	. = ..()
	if(. && (flag & VEHICLE_CONTROL_EQUIPMENT))
		UnregisterSignal(M, COMSIG_MOB_MOUSEDOWN)
	if(. && (flag & VEHICLE_CONTROL_DRIVE) && (driver_amount() == 0))
		STOP_PROCESSING(SSfastprocess, src)
		idle_loop?.stop()
		drive_loop?.stop()
		idle_inside_loop?.stop(occupants)
		drive_inside_loop?.stop(occupants)
		play_interior_sound(null, engine_off_interior_sound, 10, TRUE)
		playsound(src, engine_off_sound, 30)

/obj/vehicle/sealed/armored/remove_occupant(mob/M)
	M?.hud_used?.remove_ammo_hud(primary_weapon)
	M?.hud_used?.remove_ammo_hud(secondary_weapon)
	UnregisterSignal(M, COMSIG_MOB_DEATH)
	UnregisterSignal(M, COMSIG_LIVING_DO_RESIST)
	idle_inside_loop?.output_atoms -= M
	drive_inside_loop?.output_atoms -= M
	return ..()

/obj/vehicle/sealed/armored/relaymove(mob/living/user, direction)
	. = ..()
	if(is_driver(user))
		if(!drive_loop?.timer_id)
			idle_loop?.stop()
			drive_loop.start()
			drive_inside_loop?.start(occupants.Copy())
			idle_inside_loop?.stop(occupants)
		return
	if(is_equipment_controller(user))
		swivel_turret(null, direction)

/obj/vehicle/sealed/armored/onZImpact(turf/impacted_turf, levels, impact_flags)
	. = ..()
	if(pass_flags & HOVERING)
		return
	var/obj/hitboxtouse = hitbox ? hitbox : src
	for(var/turf/landingzone in hitboxtouse.locs)
		for(var/mob/living/crushed in landingzone)
			crushed.gib()

/obj/vehicle/sealed/armored/projectile_hit(atom/movable/projectile/proj, cardinal_move, uncrossing)
	for(var/mob/living/carbon/human/crew AS in occupants)
		if(crew.wear_id?.iff_signal & proj.iff_signal)
			return FALSE
	if(src == proj.shot_from)
		return FALSE
	if(src == proj.original_target)
		return TRUE
	if(!hitbox)
		return ..()
	if(proj.firer in hitbox.tank_desants)
		return FALSE
	if(proj.original_target in hitbox.tank_desants)
		return FALSE
	return ..()

/obj/vehicle/sealed/armored/attack_hand(mob/living/user)
	. = ..()
	if(interior?.breech) // handled by gun breech
		return
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		balloon_alert(user, "not enough skill")
		return
	if(!primary_weapon)
		balloon_alert(user, "no primary")
		return
	if(!length(primary_weapon.ammo_magazine))
		balloon_alert(user, "magazine empty")
		return
	var/choice
	if(length(primary_weapon.ammo_magazine) == 1)
		choice = primary_weapon.ammo_magazine[1]
	else
		choice = tgui_input_list(user, "Select a magazine to take out", primary_weapon.name, primary_weapon.ammo_magazine)
	if(!choice)
		return
	if(!do_after(user, 1 SECONDS, NONE, src))
		return
	balloon_alert(user, "magazine removed")
	primary_weapon.ammo_magazine -= choice
	user.put_in_hands(choice)

/obj/vehicle/sealed/armored/attack_hand_alternate(mob/living/user)
	. = ..()
	if(interior?.secondary_breech) // handled by gun breech
		return
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		balloon_alert(user, "not enough skill")
		return
	if(!secondary_weapon)
		balloon_alert(user, "no secondary")
		return
	if(!length(secondary_weapon.ammo_magazine))
		balloon_alert(user, "magazine empty")
		return
	var/choice
	if(length(secondary_weapon.ammo_magazine) == 1)
		choice = secondary_weapon.ammo_magazine[1]
	else
		choice = tgui_input_list(user, "Select a magazine to take out", secondary_weapon.name, secondary_weapon.ammo_magazine)
	if(!choice)
		return
	if(!do_after(user, 1 SECONDS, NONE, src))
		return
	balloon_alert(user, "magazine removed")
	secondary_weapon.ammo_magazine -= choice
	user.put_in_hands(choice)

/obj/vehicle/sealed/armored/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return
	if(istype(I, /obj/item/armored_weapon))
		var/obj/item/armored_weapon/gun = I
		if(!(gun.type in permitted_weapons))
			balloon_alert(user, "cannot attach")
			return
		if(!(gun.armored_weapon_flags & MODULE_PRIMARY))
			balloon_alert(user, "not a primary weapon")
			return
		if(!do_after(user, 2 SECONDS, NONE, src))
			return
		user.temporarilyRemoveItemFromInventory(I)
		gun.attach(src, TRUE)
		return
	if(istype(I, /obj/item/tank_module))
		if(!(I.type in permitted_mods))
			balloon_alert(user, "cannot attach")
			return
		var/obj/item/tank_module/mod = I
		mod.on_equip(src, user)
		return
	if(!istype(I, /obj/item/ammo_magazine))
		try_easy_load(I, user)
		return
	var/obj/item/armored_weapon/weapon_to_load
	if(!interior?.breech && primary_weapon && (I.type in primary_weapon.accepted_ammo))
		weapon_to_load = primary_weapon
	else if(!interior?.secondary_breech && secondary_weapon && (I.type in secondary_weapon.accepted_ammo))
		weapon_to_load = secondary_weapon
	else
		try_easy_load(I, user)
		return
	if((length(weapon_to_load.ammo_magazine) >= weapon_to_load.maximum_magazines) && weapon_to_load.ammo)
		balloon_alert(user, "magazine already full")
		return
	user.temporarilyRemoveItemFromInventory(I)
	I.forceMove(weapon_to_load)
	if(!weapon_to_load.ammo)
		weapon_to_load.ammo = I
		balloon_alert(user, "weapon loaded")
		for(var/mob/occupant AS in occupants)
			occupant?.hud_used?.update_ammo_hud(weapon_to_load, list(weapon_to_load.ammo.default_ammo.hud_state, weapon_to_load.ammo.default_ammo.hud_state_empty), weapon_to_load.ammo.current_rounds)
	else
		weapon_to_load.ammo_magazine += I
		balloon_alert(user, "magazines [length(weapon_to_load.ammo_magazine)]/[weapon_to_load.maximum_magazines]")

/obj/vehicle/sealed/armored/MouseDrop_T(atom/movable/dropping, mob/M)
	// Bypass to parent to handle mobs entering the vehicle.
	if(dropping == M)
		return ..()
	if(!isliving(M))
		return
	try_easy_load(dropping, M)

/obj/vehicle/sealed/armored/grab_interact(obj/item/grab/grab, mob/user, base_damage, is_sharp)
	return try_easy_load(grab.grabbed_thing, user)

/obj/vehicle/sealed/armored/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		balloon_alert(user, "not enough skill")
		return
	if(istype(I, /obj/item/armored_weapon))
		var/obj/item/armored_weapon/gun = I
		if(!(gun.type in permitted_weapons))
			balloon_alert(user, "cannot attach")
			return
		if(!(gun.armored_weapon_flags & MODULE_SECONDARY))
			balloon_alert(user, "not a secondary weapon")
			return
		if(!do_after(user, 2 SECONDS, NONE, src))
			return
		user.temporarilyRemoveItemFromInventory(I)
		gun.attach(src, FALSE)
		return
	if(isscrewdriver(I))
		if(!gunner_utility_module)
			balloon_alert(user, "no gunner utility module")
			return
		balloon_alert(user, "detaching gunner utility")
		if(!do_after(user, 2 SECONDS, NONE, src))
			return
		gunner_utility_module.on_unequip(user)
		balloon_alert(user, "detached")
		return

/obj/vehicle/sealed/armored/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 50, 5 SECONDS, 0, SKILL_ENGINEER_METAL, 5, 2 SECONDS)

/obj/vehicle/sealed/armored/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		balloon_alert(user, "not enough skill")
		return
	if(!primary_weapon)
		balloon_alert(user, "no primary weapon")
		return
	balloon_alert(user, "detaching primary")
	if(!do_after(user, 2 SECONDS, NONE, src))
		return
	var/obj/item/armored_weapon/gun = primary_weapon
	primary_weapon.detach(loc)
	user.put_in_hands(gun)
	balloon_alert(user, "detached")

/obj/vehicle/sealed/armored/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		balloon_alert(user, "not enough skill")
		return
	if(!secondary_weapon)
		balloon_alert(user, "no secondary weapon")
		return
	balloon_alert(user, "detaching secondary")
	if(!do_after(user, 2 SECONDS, NONE, src))
		return
	var/obj/item/armored_weapon/gun = secondary_weapon
	secondary_weapon.detach(loc)
	user.put_in_hands(gun)
	balloon_alert(user, "detached")

/obj/vehicle/sealed/armored/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(user.skills.getRating(SKILL_LARGE_VEHICLE) < required_entry_skill)
		balloon_alert(user, "not enough skill")
		return
	if(!driver_utility_module)
		balloon_alert(user, "no driver utility module")
		return
	balloon_alert(user, "detaching driver utility")
	if(!do_after(user, 2 SECONDS, NONE, src))
		return
	driver_utility_module.on_unequip(user)
	balloon_alert(user, "detached")

/obj/vehicle/sealed/armored/plastique_act(mob/living/plastique_user)
	take_damage(500, BRUTE, BOMB, TRUE, REVERSE_DIR(dir), 50, plastique_user)

/**
 * Toggles Weapons Safety
 *
 * Handles enabling or disabling the safety function.
 */
/obj/vehicle/sealed/armored/proc/set_safety(mob/user)
	weapons_safety = !weapons_safety
	SEND_SOUND(user, sound('sound/machines/beep.ogg', volume = 25))
	balloon_alert(user, "equipment [weapons_safety ? "safe" : "ready"]")
	// todo maybe make tanks also update the mouse icon?

///Rotates the cannon overlay
/obj/vehicle/sealed/armored/proc/swivel_turret(atom/A, new_weapon_dir)
	if(!new_weapon_dir)
		new_weapon_dir = angle_to_cardinal_dir(Get_Angle(get_turf(src), get_turf(A)))
	if(turret_overlay.dir == new_weapon_dir)
		return FALSE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_TANK_SWIVEL)) //Slight cooldown to avoid spam
		return FALSE
	playsound(src, 'sound/vehicles/tankswivel.ogg', 80, TRUE)
	play_interior_sound(null, 'sound/vehicles/turret_swivel_interior.ogg', 60, TRUE)
	TIMER_COOLDOWN_START(src, COOLDOWN_TANK_SWIVEL, 3 SECONDS)
	if(primary_weapon)
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_EQUIPMENT(primary_weapon.type), new_weapon_dir == REVERSE_DIR(turret_overlay.dir) ? 1 SECONDS : 0.5 SECONDS)
	turret_overlay.setDir(new_weapon_dir)
	return TRUE

///playsound_local identical args, use this when a sound should be played for the occupants.
/obj/vehicle/sealed/armored/proc/play_interior_sound(turf/turf_source, soundin, vol, vary, frequency, falloff, is_global, channel, sound/sound_to_use, distance_multiplier)
	if(!interior)
		return
	for(var/mob/crew AS in interior.occupants)
		if(!crew.client)
			continue
		crew.playsound_local(arglist(args))

///handles mouseclicks by a user in the vehicle
/obj/vehicle/sealed/armored/proc/on_mouseclick(mob/user, atom/target, turf/location, control, list/modifiers)
	SIGNAL_HANDLER
	modifiers = params2list(modifiers)
	if(isnull(location) && target.plane == CLICKCATCHER_PLANE) //Checks if the intended target is in deep darkness and adjusts target based on params.
		target = params2turf(modifiers["screen-loc"], get_turf(src), user.client)
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
	if(modifiers[SHIFT_CLICK]) //Allows things to be examined.
		return
	if(!isturf(target) && !isturf(target.loc)) // Prevents inventory from being drilled
		return
	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		return
	if(src == target)
		return
	if(!is_equipment_controller(user))
		balloon_alert(user, "wrong seat for equipment!")
		return COMSIG_MOB_CLICK_CANCELED
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		set_safety(user)
		return COMSIG_MOB_CLICK_CANCELED
	var/dir_to_target = get_cardinal_dir(src, target)
	var/obj/item/armored_weapon/selected
	if(modifiers[BUTTON] == RIGHT_CLICK)
		selected = secondary_weapon
	else
		if(!turret_overlay)
			return COMSIG_MOB_CLICK_CANCELED
		if(turret_overlay.dir != dir_to_target)
			swivel_turret(target)
			return COMSIG_MOB_CLICK_CANCELED
		selected = primary_weapon
	if(!selected)
		return
	if(weapons_safety || zoom_mode)
		return
	INVOKE_ASYNC(selected, TYPE_PROC_REF(/obj/item/armored_weapon, begin_fire), user, target, modifiers)

///Updates the vehicles minimap icon
/obj/vehicle/sealed/armored/proc/update_minimap_icon()
	if(!minimap_icon_state)
		return
	SSminimaps.remove_marker(src)
	minimap_icon_state = initial(minimap_icon_state)
	if(armored_flags & ARMORED_IS_WRECK)
		minimap_icon_state += "_wreck"
	SSminimaps.add_marker(src, minimap_flags, image('icons/UI_icons/map_blips_large.dmi', null, minimap_icon_state, MINIMAP_BLIPS_LAYER))

/atom/movable/vis_obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/armored/3x3/tank_gun.dmi' //set by owner
	icon_state = "turret"
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_ID|VIS_INHERIT_PLANE
	///overlay obj for for the attached gun
	var/atom/movable/vis_obj/tank_gun/primary_overlay
	///icon state for the secondary
	var/image/secondary_overlay

/atom/movable/vis_obj/turret_overlay/Initialize(mapload, obj/vehicle/sealed/armored/parent)
	. = ..()
	icon = parent.turret_icon
	base_icon_state = parent.turret_icon_state
	icon_state = parent.turret_icon_state
	layer = parent.layer + 0.002
	setDir(parent.dir)

/atom/movable/vis_obj/turret_overlay/Destroy()
	QDEL_NULL(primary_overlay)
	return ..()

/atom/movable/vis_obj/turret_overlay/proc/update_gun_overlay(gun_icon_state)
	if(!gun_icon_state)
		QDEL_NULL(primary_overlay)
		return

	primary_overlay = new()
	primary_overlay.icon = icon //VIS_INHERIT_ICON doesn't work with flick
	primary_overlay.base_icon_state = gun_icon_state
	primary_overlay.icon_state = gun_icon_state
	vis_contents += primary_overlay

/atom/movable/vis_obj/turret_overlay/update_overlays()
	. = ..()
	if(secondary_overlay)
		secondary_overlay.icon_state = copytext(secondary_overlay.icon_state, 1, length(secondary_overlay.icon_state)) + "[dir]"
		. += secondary_overlay

/atom/movable/vis_obj/turret_overlay/setDir(newdir)
	. = ..()
	if(secondary_overlay)
		update_appearance(UPDATE_OVERLAYS)

/atom/movable/vis_obj/turret_overlay/offset
	/**
	 * in case snowflake offsets are needed of the turret, set this var to list(dir = list(x, y)) in initialize
	 * when the parent vehicle rotates, we apply these snowflake offsets seperately. useful primarily for non-centered turrets
	 */
	var/list/turret_offsets

/atom/movable/vis_obj/turret_overlay/offset/Initialize(mapload, obj/vehicle/sealed/armored/parent)
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_offsets))
	turret_offsets = list(TEXT_NORTH = list(10, 10), TEXT_EAST = list(-10, -10), TEXT_SOUTH = list(-100, -100), TEXT_WEST = list(100, 100))

///sighandler for updating offsets on owning vehicle move
/atom/movable/vis_obj/turret_overlay/offset/proc/update_offsets(obj/vehicle/sealed/armored/source, old_dir, new_dir)
	SIGNAL_HANDLER
	if(!turret_offsets["[new_dir]"])
		return
	pixel_x = turret_offsets["[new_dir]"][1]
	pixel_y = turret_offsets["[new_dir]"][2]

/atom/movable/vis_obj/tank_damage
	name = "Tank damage overlay"
	desc = "ow."
	icon = 'icons/obj/armored/3x3/tank_damage.dmi' //set by owner
	icon_state = "null" // set on demand
	vis_flags = VIS_INHERIT_DIR|VIS_INHERIT_LAYER|VIS_INHERIT_ID|VIS_INHERIT_PLANE

/atom/movable/vis_obj/tank_gun
	name = "Tank weapon"
	vis_flags = VIS_INHERIT_DIR|VIS_INHERIT_LAYER|VIS_INHERIT_ID|VIS_INHERIT_PLANE
	pixel_x = -70
	pixel_y = -69
