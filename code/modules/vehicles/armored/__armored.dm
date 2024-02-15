
/obj/vehicle/sealed/armored
	name = "\improper TAV - Shortstreet MK4"
	desc = "An adorable chunk of metal with an alarming amount of firepower designed to crush, immolate, destroy and maim anything that Nanotrasen wants it to. This model contains advanced Bluespace technology which allows a TARDIS-like amount of room on the inside."
	icon = 'icons/obj/armored/1x1/tinytank.dmi'
	icon_state = "tank"
	pixel_x = -16
	pixel_y = -8
	layer = ABOVE_MOB_LAYER
	max_drivers = 1
	move_resist = INFINITY
	flags_atom = BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION
	allow_pass_flags = PASS_TANK|PASS_AIR|PASS_WALKOVER
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE|PLASMACUTTER_IMMUNE|PORTAL_IMMUNE

	// placeholder, make skill check or similar later
	req_access = list(ACCESS_MARINE_MECH)
	move_delay = 0.7 SECONDS
	obj_integrity = 600
	max_integrity = 600
	light_range = 10
	///Tank bitflags
	var/flags_armored = ARMORED_HAS_PRIMARY_WEAPON|ARMORED_HAS_HEADLIGHTS
	///Sound file(s) to play when we drive around
	var/engine_sound = 'sound/ambience/tank_driving.ogg'
	///frequency to play the sound with
	var/engine_sound_length = 2 SECONDS
	/// How long it takes to rev (vrrm vrrm!) TODO: merge this up to /vehicle here and on tg because of cars
	COOLDOWN_DECLARE(enginesound_cooldown)

	///Cool and good turret overlay that allows independently swiveling guns
	var/atom/movable/vis_obj/turret_overlay/turret_overlay
	///Icon for the rotating turret icon. also should hold the icons for the weapon icons
	var/turret_icon = 'icons/obj/armored/1x1/tinytank_gun.dmi'
	///Iconstate for the rotating main turret
	var/turret_icon_state = "turret"
	/// offsets for the turret rotation dir = (pixelx, pixely) format
	var/list/turret_dir_offsets = list(NORTH_LOWERTEXT = list(0,0), SOUTH_LOWERTEXT = list(0,0), WEST_LOWERTEXT = list(0,0), EAST_LOWERTEXT = list(0,0))
	///secondary independently rotating overlay
	var/atom/movable/vis_obj/turret_overlay/secondary_weapon_overlay/secondary_weapon_overlay
	///Icon for the secondary rotating turret, should contain all possible icons. iconstate is fetched from the attached weapon
	var/secondary_turret_icon
	///Damage overlay for when the vehicle gets damaged
	var/atom/movable/vis_obj/tank_damage/damage_overlay
	///Icon file path for the damage overlay
	var/damage_icon_path
	///Overlay for larger vehicles that need under parts
	var/image/underlay

	///What weapon we have in our primary slot
	var/obj/item/armored_weapon/primary_weapon
	///What weapon we have in our secondary slot
	var/obj/item/armored_weapon/secondary_weapon
	///Our utility module
	var/obj/item/tank_module/utility_module
	//What kind of primary tank weaponry we start with. Defaults to a tank gun.
	var/primary_weapon_type = /obj/item/armored_weapon
	//What kind of secondary tank weaponry we start with. Default minigun as standard.
	var/secondary_weapon_type = /obj/item/armored_weapon/secondary_weapon
	///if true disables stops users from being able to shoot weapons
	var/weapons_safety = FALSE
	/// damage done by rams
	var/ram_damage = 20

/obj/vehicle/sealed/armored/Initialize(mapload)
	. = ..()
	if(flags_armored & ARMORED_HAS_UNDERLAY)
		underlay = new(icon, icon_state + "_underlay", layer = layer-0.1)
		add_overlay(underlay)
	if(damage_icon_path)
		damage_overlay = new()
		damage_overlay.icon = damage_icon_path
		damage_overlay.layer = layer+0.001
		vis_contents += damage_overlay
	if(flags_armored & ARMORED_HAS_PRIMARY_WEAPON)
		turret_overlay = new()
		turret_overlay.icon = turret_icon
		turret_overlay.icon_state = turret_icon_state
		turret_overlay.setDir(dir)
		turret_overlay.layer = layer+0.002
		turret_overlay.on_tank_turn(src, dir, dir)
		turret_overlay.RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, TYPE_PROC_REF(/atom/movable/vis_obj/turret_overlay, on_tank_turn))
		if(flags_armored & ARMORED_HAS_MAP_VARIANTS)
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
		if(primary_weapon_type)
			var/obj/item/armored_weapon/primary = new primary_weapon_type(src)
			primary.attach(src, TRUE)
	if(flags_armored & ARMORED_HAS_SECONDARY_WEAPON)
		secondary_weapon_overlay = new()
		secondary_weapon_overlay.icon = secondary_turret_icon
		secondary_weapon_overlay.layer = layer+0.003
		secondary_weapon_overlay.on_tank_turn(src, dir, dir)
		secondary_weapon_overlay.RegisterSignal(src, COMSIG_ATOM_DIR_CHANGE, TYPE_PROC_REF(/atom/movable/vis_obj/turret_overlay, on_tank_turn))
		vis_contents += secondary_weapon_overlay
		if(secondary_weapon_type)
			var/obj/item/armored_weapon/secondary = new secondary_weapon_type(src)
			secondary.attach(src, FALSE)
	if(flags_armored & ARMORED_HAS_MAP_VARIANTS)
		switch(SSmapping.configs[GROUND_MAP].armor_style)
			if(MAP_ARMOR_STYLE_JUNGLE)
				icon_state += "_jungle"
			if(MAP_ARMOR_STYLE_ICE)
				icon_state += "_snow"
			if(MAP_ARMOR_STYLE_PRISON)
				icon_state += "_urban"
			if(MAP_ARMOR_STYLE_DESERT)
				icon_state += "_desert"
	GLOB.tank_list += src

/obj/vehicle/sealed/armored/Destroy()
	QDEL_NULL(turret_overlay)
	QDEL_NULL(secondary_weapon_overlay)
	QDEL_NULL(primary_weapon)
	QDEL_NULL(secondary_weapon)
	QDEL_NULL(utility_module)
	QDEL_NULL(damage_overlay)
	underlay = null
	GLOB.tank_list -= src
	return ..()

/obj/vehicle/sealed/armored/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/armored/eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/armored/swap_seat)
	if(flags_armored & ARMORED_HAS_HEADLIGHTS)
		initialize_controller_action_type(/datum/action/vehicle/sealed/armored/toggle_lights, VEHICLE_CONTROL_SETTINGS)

/obj/vehicle/sealed/armored/obj_destruction(damage_amount, damage_type, damage_flag)
	. = ..()
	playsound(get_turf(src), 'sound/weapons/guns/fire/tank_cannon1.ogg', 100, TRUE)

/obj/vehicle/sealed/armored/update_icon()
	. = ..()
	if(!damage_overlay)
		return
	switch(PERCENT(obj_integrity / max_integrity))
		if(0 to 29)
			damage_overlay.icon_state = "damage_veryhigh"
		if(29 to 59)
			damage_overlay.icon_state = "damage_high"
		if(59 to 70)
			damage_overlay.icon_state = "damage_medium"
		if(70 to 90)
			damage_overlay.icon_state = "damage_small"
		else
			damage_overlay.icon_state = "null"

/obj/vehicle/sealed/armored/examine(mob/user)
	. = ..()
	if(!isxeno(user))
		. += "To fire its main cannon, left click a tile."
		. += "To fire its secondary weapon, right click a tile."
		. += "Middle click to toggle weapon safety."
		. += "It's currently holding [LAZYLEN(occupants)]/[max_occupants] crew."
	. += span_notice("There is [isnull(primary_weapon) ? "nothing" : "[primary_weapon]"] in the primary attachment point, [isnull(secondary_weapon) ? "nothing" : "[secondary_weapon]"] installed in the secondary slot and [isnull(utility_module) ? "nothing" : "[utility_module]"] in the utility slot.")
	if(!isxeno(user))
		. += "<b>It is currently at <u>[PERCENT(obj_integrity / max_integrity)]%</u> integrity.</b>"

/obj/vehicle/sealed/armored/vehicle_move(mob/living/user, direction)
	. = ..()
	if(!.)
		return
	if(COOLDOWN_CHECK(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, engine_sound_length)
		playsound(get_turf(src), engine_sound, 100, TRUE, 20)
	after_move(direction)
	forceMove(get_step(src, direction)) // still animates and calls moved() and all that stuff BUT we skip checks

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
		if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_VEHICLE_CRUSHSOUND))
			visible_message(span_danger("[src] is stopped by [A]!"))
			playsound(src, 'sound/effects/metal_crash.ogg', 45)
			TIMER_COOLDOWN_START(src, COOLDOWN_VEHICLE_CRUSHSOUND, 1 SECONDS)
		return
	var/pilot
	var/list/drivers = return_drivers()
	if(length(drivers))
		pilot = drivers[1]
	A.vehicle_collision(src, get_dir(src, A), get_turf(loc), get_turf(loc), pilot)

/obj/vehicle/sealed/armored/auto_assign_occupant_flags(mob/new_occupant)
	if(max_occupants == 1)
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		return

	if(driver_amount() < max_drivers) //movement controllers
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else if(length(return_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)) < 1)
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/armored/exit_location(mob/M)
	return get_step(src, REVERSE_DIR(dir))

/obj/vehicle/sealed/armored/mob_try_enter(mob/M)
	if(!ishuman(M))
		return FALSE
	return ..()

/obj/vehicle/sealed/armored/add_occupant(mob/M, control_flags)
	RegisterSignal(M, COMSIG_MOB_DEATH, PROC_REF(mob_exit), TRUE)
	RegisterSignal(M, COMSIG_MOB_MOUSEDOWN, PROC_REF(on_mouseclick), TRUE)
	RegisterSignal(M, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against), TRUE)
	. = ..()
	if(primary_weapon)
		var/list/primary_icons
		if(primary_weapon.ammo)
			primary_icons = list(primary_weapon.ammo.default_ammo.hud_state, primary_weapon.ammo.default_ammo.hud_state_empty)
		else
			primary_icons = list(primary_weapon.hud_state_empty, primary_weapon.hud_state_empty)
		M.hud_used.add_ammo_hud(primary_weapon, primary_icons, primary_weapon.ammo.current_rounds)
	if(secondary_weapon)
		var/list/secondary_icons
		if(secondary_weapon.ammo)
			secondary_icons = list(secondary_weapon.ammo.default_ammo.hud_state, secondary_weapon.ammo.default_ammo.hud_state_empty)
		else
			secondary_icons = list(secondary_weapon.hud_state_empty, secondary_weapon.hud_state_empty)
		M.hud_used.add_ammo_hud(secondary_weapon, secondary_icons, secondary_weapon.ammo.current_rounds)

/obj/vehicle/sealed/armored/remove_occupant(mob/M)
	M.hud_used.remove_ammo_hud(primary_weapon)
	M.hud_used.remove_ammo_hud(secondary_weapon)
	UnregisterSignal(M, COMSIG_MOB_DEATH)
	UnregisterSignal(M, COMSIG_MOB_MOUSEDOWN)
	UnregisterSignal(M, COMSIG_LIVING_DO_RESIST)
	if(M.client)
		M.update_mouse_pointer()
		M.client.view_size.reset_to_default()
	return ..()

/obj/vehicle/sealed/armored/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	for(var/mob/living/carbon/human/crew AS in occupants)
		if(crew.wear_id?.iff_signal & proj.iff_signal)
			return FALSE
	return ..()

/obj/vehicle/sealed/armored/attack_hand(mob/living/user)
	. = ..()
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
	if(istype(I, /obj/item/armored_weapon))
		var/obj/item/armored_weapon/gun = I
		if(!(gun.weapon_slot & MODULE_PRIMARY))
			balloon_alert(user, "not a primary weapon")
			return
		if(!do_after(user, 2 SECONDS, NONE, src))
			return
		user.temporarilyRemoveItemFromInventory(I)
		gun.attach(src, TRUE)
		return
	if(istype(I, /obj/item/ammo_magazine))
		if(!primary_weapon)
			balloon_alert(user, "no primary weapon")
			return
		if(!(I.type in primary_weapon.accepted_ammo))
			balloon_alert(user, "not accepted ammo")
			return
		if(length(primary_weapon.ammo_magazine) >= primary_weapon.maximum_magazines)
			balloon_alert(user, "magazine already full")
			return
		user.temporarilyRemoveItemFromInventory(I)
		I.forceMove(primary_weapon)
		if(!primary_weapon.ammo)
			primary_weapon.ammo = src
			balloon_alert(user, "primary gun loaded")
			for(var/mob/occupant AS in occupants)
				occupant.hud_used.update_ammo_hud(src, list(primary_weapon.ammo.default_ammo.hud_state, primary_weapon.ammo.default_ammo.hud_state_empty), primary_weapon.ammo.current_rounds)
		else
			primary_weapon.ammo_magazine += I
			balloon_alert(user, "magazines [length(primary_weapon.ammo_magazine)]/[primary_weapon.maximum_magazines]")
		return
	if(istype(I, /obj/item/tank_module))
		var/obj/item/tank_module/mod = I
		mod.on_equip(src)

/obj/vehicle/sealed/armored/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/armored_weapon))
		var/obj/item/armored_weapon/gun = I
		if(!(gun.weapon_slot & MODULE_SECONDARY))
			balloon_alert(user, "not a secondary weapon")
			return
		if(!do_after(user, 2 SECONDS, NONE, src))
			return
		user.temporarilyRemoveItemFromInventory(I)
		gun.attach(src, FALSE)
		return
	if(istype(I, /obj/item/ammo_magazine))
		if(!secondary_weapon)
			balloon_alert(user, "no primary weapon")
			return
		if(!(I.type in secondary_weapon.accepted_ammo))
			balloon_alert(user, "not accepted ammo")
			return
		if(length(secondary_weapon.ammo_magazine) >= secondary_weapon.maximum_magazines)
			balloon_alert(user, "magazine already full")
			return
		user.temporarilyRemoveItemFromInventory(I)
		I.forceMove(secondary_weapon)
		if(!secondary_weapon.ammo)
			secondary_weapon.ammo = I
			balloon_alert(user, "secondary gun loaded")
			for(var/mob/occupant AS in occupants)
				occupant.hud_used.update_ammo_hud(src, list(secondary_weapon.ammo.default_ammo.hud_state, secondary_weapon.ammo.default_ammo.hud_state_empty), secondary_weapon.ammo.current_rounds)
		else
			secondary_weapon.ammo_magazine += I
			balloon_alert(user, "magazines [length(secondary_weapon.ammo_magazine)]/[secondary_weapon.maximum_magazines]")
		return

/obj/vehicle/sealed/armored/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 120, 5 SECONDS, 0, SKILL_ENGINEER_METAL, 5, 2 SECONDS)

/obj/vehicle/sealed/armored/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
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
	if(!utility_module)
		balloon_alert(user, "no utility module")
		return
	balloon_alert(user, "detaching utility")
	if(!do_after(user, 2 SECONDS, NONE, src))
		return
	utility_module.on_unequip()
	balloon_alert(user, "detached")

/atom/movable/vis_obj/turret_overlay
	name = "Tank gun turret"
	desc = "The shooty bit on a tank."
	icon = 'icons/obj/armored/3x3/tank_gun.dmi' //set by owner
	icon_state = "turret"
	layer = ABOVE_ALL_MOB_LAYER
	///overlay for the attached gun
	var/image/gun_overlay

///updates the gun overlay with a new image
/atom/movable/vis_obj/turret_overlay/proc/update_gun_overlay(image/new_overlay)
	cut_overlay(gun_overlay)
	gun_overlay = new_overlay
	if(gun_overlay)
		add_overlay(gun_overlay)

///updates the turret pixel offsets when the tank turns
/atom/movable/vis_obj/turret_overlay/proc/on_tank_turn(obj/vehicle/sealed/armored/source, old_dir, new_dir)
	SIGNAL_HANDLER
	var/list/offsets = source.turret_dir_offsets[dir2text(new_dir)]
	pixel_x = offsets[1]
	pixel_y = offsets[2]

/atom/movable/vis_obj/turret_overlay/secondary_weapon_overlay
	name = "Tank gun secondary turret"
	desc = "The other shooty bit on a tank."
	icon = 'icons/obj/armored/3x3/tank_secondary_gun.dmi' //set by owner
	icon_state = "m56cupola_2"

/atom/movable/vis_obj/tank_damage
	name = "Tank damage overlay"
	desc = "ow."
	icon = 'icons/obj/armored/3x3/tank_damage.dmi' //set by owner
	icon_state = "null" // set on demand
	vis_flags = VIS_INHERIT_DIR
