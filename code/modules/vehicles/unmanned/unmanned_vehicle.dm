
/obj/vehicle/unmanned
	name = "UV-L Iguana"
	desc = "A small remote-controllable vehicle, usually owned by the TGMC and other major armies."
	icon = 'icons/obj/unmanned_vehicles.dmi'
	icon_state = "light_uv"
	anchored = FALSE
	buckle_flags = null
	light_range = 6
	light_power = 3
	light_system = MOVABLE_LIGHT
	move_delay = 2.5	//set this to limit the speed of the vehicle
	max_integrity = 150
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	flags_atom = BUMP_ATTACKABLE
	soft_armor = list(MELEE = 25, BULLET = 85, LASER = 50, ENERGY = 100, BOMB = 50, BIO = 100, FIRE = 25, ACID = 25)
	allow_pass_flags = PASS_AIR|PASS_LOW_STRUCTURE|PASS_THROW
	/// Needed to keep track of any slowdowns and/or diagonal movement
	var/next_move_delay = 0
	/// Path of "turret" attached
	var/obj/item/uav_turret/turret_path
	/// Type of the turret attached
	var/turret_type
	///Turret types we're allowed to attach
	var/turret_pattern = PATTERN_TRACKED
	/// If that vehicle can interact with cades
	var/can_interact = FALSE
	///Delay in byond ticks between weapon fires
	var/fire_delay = 5
	///Ammo remaining for the robot
	var/current_rounds = 0
	///max ammo the robot can hold
	var/max_rounds = 0
	///Buller type we fire, declared as type but set to a reference in Initialize
	var/datum/ammo/bullet/ammo
	///The currently loaded and ready to fire projectile
	var/obj/projectile/in_chamber = null
	///Sound file or string type for playing the shooting sound
	var/gunnoise = "gun_smartgun"
	/// Serial number of the vehicle
	var/static/serial = 1
	/// If the vehicle should spawn with a weapon allready installed
	var/obj/item/uav_turret/spawn_equipped_type = null
	/// If something is already controlling the vehicle
	var/controlled = FALSE
	/// Flags for unmanned vehicules
	var/unmanned_flags = OVERLAY_TURRET|HAS_LIGHTS
	/// Iff flags, to prevent friendly fire from sg and aiming marines
	var/iff_signal = TGMC_LOYALIST_IFF
	/// muzzleflash stuff
	var/atom/movable/vis_obj/effect/muzzle_flash/flash
	COOLDOWN_DECLARE(fire_cooldown)

/obj/vehicle/unmanned/Initialize(mapload)
	. = ..()
	ammo = GLOB.ammo_list[ammo]
	name += " " + num2text(serial)
	serial++
	flash = new /atom/movable/vis_obj/effect/muzzle_flash(src)
	GLOB.unmanned_vehicles += src
	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)
	hud_set_machine_health()
	if(spawn_equipped_type)
		turret_path = spawn_equipped_type
		turret_type = initial(spawn_equipped_type.turret_type)
		ammo = GLOB.ammo_list[initial(spawn_equipped_type.ammo_type)]
		fire_delay = initial(spawn_equipped_type.fire_delay)
		current_rounds = initial(spawn_equipped_type.max_rounds)
		max_rounds = initial(spawn_equipped_type.max_rounds)
		update_icon()
	hud_set_uav_ammo()
	SSminimaps.add_marker(src, MINIMAP_FLAG_MARINE, image('icons/UI_icons/map_blips.dmi', null, "uav"))

/obj/vehicle/unmanned/Destroy()
	GLOB.unmanned_vehicles -= src
	QDEL_NULL(flash)
	QDEL_NULL(in_chamber)
	return ..()

/obj/vehicle/unmanned/obj_destruction()
	robogibs(src)
	return ..()

/obj/vehicle/unmanned/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	hud_set_machine_health()

/obj/vehicle/unmanned/repair_damage(repair_amount)
	. = ..()
	hud_set_machine_health()

/obj/vehicle/unmanned/update_overlays()
	. = ..()
	if(!(unmanned_flags & OVERLAY_TURRET))
		return
	switch(turret_type)
		if(TURRET_TYPE_HEAVY)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "heavy_cannon")
		if(TURRET_TYPE_LIGHT)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "light_cannon")
		if(TURRET_TYPE_EXPLOSIVE)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "bomb")
		if(TURRET_TYPE_DROIDLASER)
			. += image('icons/obj/unmanned_vehicles.dmi', src, "droidlaser")

/obj/vehicle/unmanned/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(current_rounds > 0)
		. += "It has [current_rounds] shots left."
	switch(turret_type)
		if(TURRET_TYPE_LIGHT)
			. += "It is equipped with a light weapon system. It uses 11x35mm ammo."
		if(TURRET_TYPE_HEAVY)
			. += "It is equipped with a heavy weapon system. It uses 12x40mm ammo."
		if(TURRET_TYPE_EXPLOSIVE)
			. += "It is equipped with an explosive weapon system. "
		if(TURRET_TYPE_DROIDLASER)
			. += "It is equipped with a droid weapon system. It uses 11x35mm ammo."

/obj/vehicle/unmanned/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/uav_turret) || istype(I, /obj/item/explosive/plastique))
		return equip_turret(I, user)
	if(istype(I, /obj/item/ammo_magazine))
		return reload_turret(I, user)

/obj/vehicle/unmanned/relaymove(mob/living/user, direction)
	if(user.incapacitated())
		return FALSE

	if(world.time < last_move_time + next_move_delay)
		return

	. = Move(get_step(src, direction))

	if(ISDIAGONALDIR(direction)) //moved diagonally successfully
		next_move_delay = move_delay * DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER
	else
		next_move_delay = move_delay

///Try to desequip the turret
/obj/vehicle/unmanned/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!turret_path)
		to_chat(user,"<span class='warning'>There is nothing to remove from [src]!</span>")
		return
	user.visible_message(span_notice("[user] starts to remove [initial(turret_path.name)] from [src]"),	span_notice("You start to remove [initial(turret_path.name)] from [src]"))
	if(!do_after(user, 3 SECONDS, NONE, src))
		return
	var/obj/item/equipment = new turret_path
	user.visible_message(span_notice("[user] removes [equipment] from [src]."),
	span_notice("You remove [equipment] from [src]."))
	user.put_in_hands(equipment)
	if(istype(equipment, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = equipment
		turret.current_rounds = current_rounds
	turret_path = null
	turret_type = null
	current_rounds = 0
	max_rounds = 0
	update_icon()
	hud_set_uav_ammo()
	return

///Try to reload the turret of our vehicule
/obj/vehicle/unmanned/proc/reload_turret(obj/item/ammo_magazine/reload_ammo, mob/user)
	if(!ispath(reload_ammo.type, initial(turret_path.magazine_type)))
		to_chat(user, span_warning("This is not the right ammo!"))
		return
	if(max_rounds == current_rounds)
		to_chat(user, span_warning("The [src] ammo storage is already full!"))
		return
	user.visible_message(span_notice("[user] starts to reload [src] with [reload_ammo]."), span_notice("You start to reload [src] with [reload_ammo]."))
	if(!do_after(user, 3 SECONDS, NONE, src))
		return
	current_rounds = current_rounds + reload_ammo.current_rounds
	if(current_rounds > max_rounds)
		var/extra_rounds = current_rounds - max_rounds
		reload_ammo.current_rounds = extra_rounds
		current_rounds = max_rounds
	user.visible_message(span_notice("[user] reloads [src] with [reload_ammo]."), span_notice("You reload [src] with [reload_ammo]. It now has [current_rounds] shots left out of a maximum of [max_rounds]."))
	playsound(loc, 'sound/weapons/guns/interact/smartgun_unload.ogg', 25, 1)
	if(reload_ammo.current_rounds < 1)
		qdel(reload_ammo)
	update_icon()
	hud_set_uav_ammo()

/// Try to equip a turret on the vehicle
/obj/vehicle/unmanned/proc/equip_turret(obj/item/I, mob/user)
	if(turret_path)
		to_chat(user, span_notice("There's already something attached!"))
		return
	if(istype(I, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = I
		if(turret_pattern != turret.turret_pattern)
			to_chat(user, span_notice("You can't attach that type of turret!"))
			return
	user.visible_message(span_notice("[user] starts to attach [I] to [src]."),
	span_notice("You start to attach [I] to [src]."))
	if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_GENERIC))
		return
	turret_path = I.type
	if(istype(I, /obj/item/uav_turret))
		var/obj/item/uav_turret/turret = I
		ammo = GLOB.ammo_list[turret.ammo_type]
		turret_type = turret.turret_type
		fire_delay = turret.fire_delay
		current_rounds = turret.current_rounds
		max_rounds = turret.max_rounds
		hud_set_uav_ammo()
	else
		turret_type = TURRET_TYPE_EXPLOSIVE
	user.visible_message(span_notice("[user] attaches [I] to [src]."),
	span_notice("You attach [I] to [src]."))
	update_icon()
	SEND_SIGNAL(src, COMSIG_UNMANNED_TURRET_UPDATED, turret_type)
	qdel(I)

/**
 * Called when the drone is linked from a remote control
 */
/obj/vehicle/unmanned/proc/on_link(atom/remote_controller)
	SHOULD_CALL_PARENT(TRUE)
	RegisterSignal(src, COMSIG_REMOTECONTROL_CHANGED, PROC_REF(on_remote_toggle))
	controlled = TRUE

/**
 * Called when the drone is unlinked to a remote control
 */
/obj/vehicle/unmanned/proc/on_unlink(atom/remote_controller)
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(src, COMSIG_REMOTECONTROL_CHANGED)
	controlled = FALSE

///Called when remote control is taken
/obj/vehicle/unmanned/proc/on_remote_toggle(datum/source, is_on, mob/user)
	SIGNAL_HANDLER
	if(unmanned_flags & HAS_LIGHTS)
		set_light_on(is_on)
	if(unmanned_flags & GIVE_NIGHT_VISION)
		if(is_on)
			ADD_TRAIT(user, TRAIT_SEE_IN_DARK, UNMANNED_VEHICLE)
		else
			REMOVE_TRAIT(user, TRAIT_SEE_IN_DARK, UNMANNED_VEHICLE)

///Checks if we can or already have a bullet loaded that we can shoot
/obj/vehicle/unmanned/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(current_rounds <= 0)
		return FALSE
	in_chamber = new /obj/projectile(src) //New bullet!
	in_chamber.generate_bullet(ammo)
	return TRUE


///Check if we have/create a new bullet and fire it at an atom target
/obj/vehicle/unmanned/proc/fire_shot(atom/target, mob/user)
	if(!COOLDOWN_CHECK(src, fire_cooldown))
		return FALSE
	if(load_into_chamber() && istype(in_chamber, /obj/projectile))
		//Setup projectile
		in_chamber.original_target = target
		in_chamber.def_zone = pick("chest","chest","chest","head")
		//Shoot at the thing
		var/angle = Get_Angle(src, target)
		playsound(loc, gunnoise, 65, 1)
		in_chamber.fire_at(target, src, null, ammo.max_range, ammo.shell_speed)
		in_chamber = null
		COOLDOWN_START(src, fire_cooldown, fire_delay)
		current_rounds--
		flash.transform = null
		flash.transform = turn(flash.transform, angle)
		vis_contents += flash
		addtimer(CALLBACK(src, PROC_REF(delete_muzzle_flash)), 0.2 SECONDS)
		hud_set_uav_ammo()
	return TRUE

///Removes muzzle flash from unmanned vehicles
/obj/vehicle/unmanned/proc/delete_muzzle_flash()
	vis_contents -= flash

/obj/vehicle/unmanned/flamer_fire_act(burnlevel)
	take_damage(burnlevel / 2, BURN, FIRE)

/obj/vehicle/unmanned/fire_act()
	take_damage(20, BURN, FIRE)

/obj/vehicle/unmanned/welder_act(mob/living/user, obj/item/I)
	return welder_repair_act(user, I, 35, 2 SECONDS, 0, SKILL_ENGINEER_ENGI, 1, 4 SECONDS)

/obj/vehicle/unmanned/medium
	name = "UV-M Gecko"
	icon_state = "medium_uv"
	move_delay = 3
	max_rounds = 200
	max_integrity = 200

/obj/vehicle/unmanned/heavy
	name = "UV-H Komodo"
	icon_state = "heavy_uv"
	move_delay = 4
	max_rounds = 200
	max_integrity = 250

/obj/structure/closet/crate/uav_crate
	name = "\improper UV-L Iguana Crate"
	desc = "A crate containing an unmanned vehicle with a controller and some spare ammo."
	icon = 'icons/obj/structures/crates.dmi'
	icon_state = "closed_weapons"
	icon_opened = "open_weapons"
	icon_closed = "closed_weapons"

/obj/structure/closet/crate/uav_crate/PopulateContents()
	new /obj/vehicle/unmanned(src)
	new /obj/item/uav_turret(src)
	new /obj/item/ammo_magazine/box11x35mm(src)
	new /obj/item/ammo_magazine/box11x35mm(src)
	new /obj/item/ammo_magazine/box11x35mm(src)
	new /obj/item/unmanned_vehicle_remote(src)
