#define FLYING_CRASH_DAMAGE 20	//Value used for dealing damage when a flying unit bumps/crashes into something

/obj/vehicle/sealed/helicopter
	name = "helicopter"
	desc = "Fast and nimble with only space for one pilot."
	icon_state = "engineering_pod"
	max_integrity = 50
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, FIRE = 0, ACID = 0)
	flags_atom = BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION
	generic_canpass = FALSE
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE|PLASMACUTTER_IMMUNE
	move_resist = MOVE_FORCE_OVERPOWERING
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	integrity_failure = 0.2
	coverage = 100
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_power = 3
	move_delay = 0.2 SECONDS
	///Total fuel capacity
	var/max_fuel = 100
	///How much fuel is in the tank
	var/current_fuel = 0
	///Time in BYOND ticks between weapon fires; time between volleys if burst fire
	var/fire_delay = 2
	///Time between each projectile in a burst
	var/burst_delay = 1
	///Shots per burst
	var/burst_amount = 3
	///Weapon that's attached
	var/obj/item/aircraft_weapon/attached_weapon
	///If the vehicle should spawn with a weapon allready installed
	var/obj/item/aircraft_weapon/starting_weapon = null
	///Bullet type we fire, declared as type but set to a reference in Initialize
	var/datum/ammo/bullet/ammo
	///The currently loaded and ready to fire projectile
	var/obj/projectile/aircraft/in_chamber = null
	///Max amount that can be loaded
	var/max_rounds = 0
	///Current ammo
	var/current_rounds = 0
	///Fire mode to use for autofire
	var/fire_mode = GUN_FIREMODE_AUTOMATIC
	///Sound file or string type played when shooting
	var/fire_sound = null
	///Sound played when reloading the attached weapon
	var/reload_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	///Sound played when ejecting the attached weapon's mag
	var/unload_sound = 'sound/weapons/guns/fire/tank_minigun_start.ogg'
	///Mob reference to the pilot; much easier than doing a for loop on every occupant
	var/mob/living/carbon/human/pilot = null
	///Who are we currently aiming/shooting at?
	var/current_target = null
	var/deployable = TRUE
	var/deployed = FALSE
	var/being_destroyed = FALSE
	COOLDOWN_DECLARE(enginesound_cooldown)

/obj/vehicle/sealed/helicopter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatedfire/autofire, fire_delay, fire_delay, burst_delay, burst_amount, fire_mode, CALLBACK(src, .proc/set_bursting), CALLBACK(src, .proc/reset_fire), CALLBACK(src, .proc/fire))
	prepare_huds()
	for(var/datum/atom_hud/squad/helicopter_hud in GLOB.huds) //Add to the squad HUD
		helicopter_hud.add_to_hud(src)
	current_fuel = max_fuel
	if(starting_weapon)
		var/obj/item/aircraft_weapon/holder = new starting_weapon
		attach_starting_weapon(holder)
	if(deployable && !deployed)
		deploy(null, TRUE)
	else
		update_icon()

/obj/vehicle/sealed/helicopter/update_icon()
	show_helicopter_health()
	show_helicopter_fuel()
	return ..()

/obj/vehicle/sealed/helicopter/examine(mob/user)
	. = ..()
	if(is_driver(user))
		. += "The fuel gauge reads [current_fuel/max_fuel*100]%"
	. += "It has [obj_integrity]/[max_integrity] HP"
	. += "[attached_weapon ? "[attached_weapon.name] is attached" : "No weapon is attached"]."

/obj/vehicle/sealed/helicopter/attack_hand(mob/living/user)
	if(CHECK_BITFIELD(flags_pass, FLYING) && !CHECK_BITFIELD(user.flags_pass, FLYING))	//Only another flying unit can reach us!
		return
	if(deployable)
		return deploy(user)
	return ..()

/obj/vehicle/sealed/helicopter/attackby(obj/item/I, mob/user, params)
	if(CHECK_BITFIELD(flags_pass, FLYING) && !CHECK_BITFIELD(user.flags_pass, FLYING))	//Only another flying unit can reach us!
		return
	. = ..()
	if(istype(I, /obj/item/reagent_containers/jerrycan))
		return refuel(I, user)
	if(istype(I, /obj/item/aircraft_weapon))
		return attach_weapon(I, user)
	if(istype(I, /obj/item/ammo_magazine))
		return reload(I, user)

/obj/vehicle/sealed/helicopter/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(attached_weapon?.current_magazine)
		return unload(over)

///Proc for removing fuel from a jerry can and adding it to the aircraft
/obj/vehicle/sealed/helicopter/proc/refuel(obj/item/reagent_containers/jerrycan/J, mob/user)
	if(J.reagents.total_volume == 0)
		balloon_alert(user, "Empty!")
		return
	if(current_fuel >= max_fuel)
		balloon_alert(user, "Gas tank already full!")
		return
	//Refueling takes time so that doing it in the field leaves a window of vulnerability
	balloon_alert_to_viewers("Refueling!")
	if(!do_after(user, 5 SECONDS, TRUE, src))
		return
	//Just transfer it all in one go, no need to spam click
	var/fuel_transfer_amount = min(max_fuel - current_fuel, J.reagents.total_volume)
	J.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
	current_fuel += fuel_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	if(current_fuel >= max_fuel)
		balloon_alert(user, "Full!")

//Deploys and undeploys the heli
/obj/vehicle/sealed/helicopter/proc/deploy(mob/living/user, deployed_after_spawn = FALSE)
	if(LAZYLEN(occupants))	//Or else the people inside become paste
		return
	if(!deployed_after_spawn)
		deployed = !deployed
	if(deployed)
		var/area/deploying_area = get_area(src)
		if(!deploying_area.outside)
			deployed = !deployed
			balloon_alert(user, "Must be deployed in an open area!")
			return
		pulledby?.stop_pulling()
		playsound(src, 'sound/machines/hydraulics_1.ogg', 30)
		icon_state = initial(icon_state)
		move_resist = initial(move_resist)
	else
		playsound(src, 'sound/machines/hydraulics_2.ogg', 30)
		icon_state = "keys"
		move_resist = MOVE_RESIST_DEFAULT
	update_icon()

///Try to eject the current mag in the attached weapon
/obj/vehicle/sealed/helicopter/proc/unload(mob/user)
	if(!attached_weapon?.current_magazine)	//Safety check
		return
	attached_weapon.current_rounds = current_rounds
	attached_weapon.current_magazine.current_rounds = current_rounds
	balloon_alert_to_viewers("Unloading!")
	if(!do_after(user, attached_weapon.current_magazine.reload_delay, TRUE, src))
		return
	attached_weapon.unload(user, TRUE)
	current_rounds = 0
	balloon_alert_to_viewers("Unloaded!")
	playsound(loc, unload_sound, 25, 1)

///Try to insert a new mag into the attached weapon
/obj/vehicle/sealed/helicopter/proc/reload(obj/item/ammo_magazine/mag, mob/user)
	if(!attached_weapon)
		return
	if(mag.type != attached_weapon.magazine_type)
		balloon_alert(user, "Wrong type of ammunition!")
		return
	if(attached_weapon.current_magazine)	//Weapon must be empty first to load a new mag
		balloon_alert(user, "Unload [attached_weapon.name] first!")
		return
	balloon_alert_to_viewers("Reloading!")
	if(!do_after(user, mag.reload_delay, TRUE, src))
		return
	attached_weapon.reload(mag, user, TRUE)
	current_rounds = attached_weapon.current_rounds
	balloon_alert_to_viewers("Reloaded!")
	playsound(loc, reload_sound, 25, 1)

///Handles weapon attaching
/obj/vehicle/sealed/helicopter/proc/attach_weapon(obj/item/aircraft_weapon/gun, mob/user)
	if(attached_weapon)
		balloon_alert(user, "Weapon slot occupied!")
		return
	balloon_alert_to_viewers("Attaching weapon!")
	if(!do_after(user, 5 SECONDS, TRUE, src))
		return
	balloon_alert_to_viewers("Weapon attached!")
	user.temporarilyRemoveItemFromInventory(gun)
	attached_weapon = gun
	fire_mode = gun.fire_mode
	fire_delay = gun.fire_delay
	burst_delay = gun.burst_delay
	burst_amount = gun.burst_amount
	fire_sound = gun.fire_sound
	ammo = GLOB.ammo_list[gun.ammo]
	max_rounds = gun.max_rounds
	current_rounds = gun.current_rounds
	gun.forceMove(src)
	update_icon()
	modify_autofire()
	if(pilot?.client)
		change_mouse_pointer_icon(FALSE)

///SpacemanDMM hates that attach_weapon has a timer in it even if it's never accessed, so new snowflake proc for Initialize() purposes
/obj/vehicle/sealed/helicopter/proc/attach_starting_weapon(obj/item/aircraft_weapon/gun)
	attached_weapon = gun
	fire_mode = gun.fire_mode
	fire_delay = gun.fire_delay
	burst_delay = gun.burst_delay
	burst_amount = gun.burst_amount
	fire_sound = gun.fire_sound
	ammo = GLOB.ammo_list[gun.ammo]
	max_rounds = gun.max_rounds
	current_rounds = gun.current_rounds
	gun.forceMove(src)
	update_icon()
	modify_autofire()

/obj/vehicle/sealed/helicopter/wrench_act(mob/living/user, obj/item/I)
	. = ..()
	if(!attached_weapon)
		balloon_alert(user, "No weapon attached!")
		return
	attached_weapon.current_rounds = current_rounds
	attached_weapon.current_magazine.current_rounds = current_rounds
	balloon_alert_to_viewers("Detaching weapon!")
	if(!do_after(user, 5 SECONDS, TRUE, src))
		return
	balloon_alert_to_viewers("Weapon detached!")
	user.put_in_hands(attached_weapon)
	attached_weapon = null
	current_rounds = 0
	max_rounds = 0
	update_icon()

///Updates the autofire component's values with current ones
/obj/vehicle/sealed/helicopter/proc/modify_autofire()
	SEND_SIGNAL(src, COMSIG_HELI_AUTOFIREDELAY_MODIFIED, fire_delay)
	SEND_SIGNAL(src, COMSIG_HELI_AUTO_BURST_SHOT_DELAY_MODIFIED, fire_delay)
	SEND_SIGNAL(src, COMSIG_HELI_BURST_SHOT_DELAY_MODIFIED, burst_delay)
	SEND_SIGNAL(src, COMSIG_HELI_BURST_SHOTS_TO_FIRE_MODIFIED, burst_amount)
	SEND_SIGNAL(src, COMSIG_HELI_FIRE_MODE_TOGGLE, fire_mode)

/obj/vehicle/sealed/helicopter/mob_try_enter(mob/M)
	if(!deployed)
		to_chat(M, span_warning("[src] must be deployed to board!"))
		return FALSE
	if(CHECK_BITFIELD(flags_pass, FLYING))
		to_chat(M, span_warning("You can't board [src] mid-flight!"))
		return FALSE
	return ..()

/obj/vehicle/sealed/helicopter/mob_try_exit(mob/M, mob/user, silent, randomstep)
	if(CHECK_BITFIELD(flags_pass, FLYING) && !being_destroyed)
		to_chat(M, span_warning("You can't jump out of [src] mid-flight!"))
		return FALSE
	if(being_destroyed)	//Eligible for bailing out
		return mob_exit(M, TRUE, TRUE, TRUE)
	return ..()

/obj/vehicle/sealed/helicopter/mob_exit(mob/M, silent, randomstep, bailed = FALSE)
	. = ..()
	M.set_flying(FALSE)	//Just in case
	if(M == pilot)
		change_mouse_pointer_icon(TRUE)
		UnregisterSignal(pilot, COMSIG_MOB_MOUSEDOWN)
		UnregisterSignal(pilot, COMSIG_MOB_MOUSEUP)
		UnregisterSignal(pilot, COMSIG_MOB_MOUSEDRAG)
		pilot = null
	if(bailed && iscarbon(M))	//Jumping out of a flying heli can be dangerous
		var/mob/living/carbon/Carbon = M
		Carbon.Paralyze(20)
		Carbon.apply_damage(10)
		visible_message(span_danger("[Carbon.name] bailed from [src]!"))

/obj/vehicle/sealed/helicopter/auto_assign_occupant_flags(mob/M)
	if(driver_amount() < max_drivers)
		add_control_flags(M, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)
		pilot = M
		RegisterSignal(pilot, COMSIG_MOB_MOUSEDOWN, .proc/auto_fire)
		RegisterSignal(pilot, COMSIG_MOB_MOUSEUP, .proc/stop_fire)
		RegisterSignal(pilot, COMSIG_MOB_MOUSEDRAG, .proc/change_target)
		if(attached_weapon)
			change_mouse_pointer_icon(FALSE)

///Toggle between the default cursor and crosshairs
/obj/vehicle/sealed/helicopter/proc/change_mouse_pointer_icon(default)
	if(default)
		pilot?.client?.mouse_pointer_icon = initial(pilot.client.mouse_pointer_icon)
	else
		pilot?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

///Code for toggling the engine on and off, easier to have it separated than as part of the action button
/obj/vehicle/sealed/helicopter/proc/toggle_engine()
	if(!CHECK_BITFIELD(flags_pass, FLYING) && current_fuel)
		if(!pilot)
			return
		set_flying(TRUE)
		animate(src, 3 SECONDS, loop = -1, pixel_z = 20)
		add_filter("flight_shadow", 2, drop_shadow_filter(y = -10, color = "#000000", size = 10))
		coverage = 0
		layer = FLY_LAYER
		for(var/mob/M in occupants)
			M.set_flying(TRUE)
		START_PROCESSING(SSobj, src)
	else if(CHECK_BITFIELD(flags_pass, FLYING))
		animate(src, 1 SECONDS, pixel_z = 0)
		STOP_PROCESSING(SSobj, src)
		addtimer(CALLBACK(src, .proc/shutdown_procedures), 1 SECONDS)
	else
		to_chat(pilot, span_warning("Out of fuel!"))

///Easier to keep all of these together instead of separate timer procs
/obj/vehicle/sealed/helicopter/proc/shutdown_procedures()
	set_flying(FALSE)
	coverage = initial(coverage)
	layer = initial(layer)
	remove_filter("flight_shadow")
	for(var/mob/M in occupants)
		M.set_flying(FALSE)
	var/turf/landing_zone = get_turf(src)
	if(landing_zone.density)
		var/no_valid_turf = TRUE
		for(var/turf/target in get_adjacent_open_turfs(src))
			if(!is_blocked_turf(target))	//Try to find a valid open turf
				throw_at(target, 2, 3, spin = TRUE)	//Throw the heli at this open turf
				take_damage(FLYING_CRASH_DAMAGE)
				no_valid_turf = FALSE
				break
		if(no_valid_turf)
			obj_destruction()	//If no valid open turfs nearby, heli goes up in flames

//Heli burns fuel at all times while flying, even if only hovering
/obj/vehicle/sealed/helicopter/process()
	current_fuel--
	update_icon()
	if(current_fuel <= 0)
		toggle_engine()
	if(COOLDOWN_CHECK(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, 35)
		playsound(get_turf(src), 'sound/effects/tadpolehovering.ogg', 100, TRUE)
	if(being_destroyed)
		setDir(pick(LeftAndRightOfDir(dir, TRUE)))

/obj/vehicle/sealed/helicopter/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!LAZYLEN(occupants))
		return
	current_fuel--

/obj/vehicle/sealed/helicopter/relaymove(mob/living/user, direction)
	if(!CHECK_BITFIELD(flags_pass, FLYING))
		if(!TIMER_COOLDOWN_CHECK(src, "helicopter anti spam"))
			balloon_alert(user, "Engine offline!")
			TIMER_COOLDOWN_START(src, "helicopter anti spam", 2 SECONDS)
		return FALSE
	if(current_fuel <= 0)
		if(!TIMER_COOLDOWN_CHECK(src, "helicopter anti spam"))
			balloon_alert(user,"No fuel left!")
			TIMER_COOLDOWN_START(src, "helicopter anti spam", 2 SECONDS)
		return FALSE
	return ..()

/obj/vehicle/sealed/helicopter/vehicle_move(direction)
	if(!COOLDOWN_CHECK(src, cooldown_vehicle_move))
		return FALSE
	if(!direction)
		return FALSE
	if(direction in reverse_nearby_direction(dir))
		COOLDOWN_START(src, cooldown_vehicle_move, move_delay * 1.5)	//Backpedaling is slower than going forward or strafing
		set_glide_size(DELAY_TO_GLIDE_SIZE(move_delay * 1.5))
	else
		COOLDOWN_START(src, cooldown_vehicle_move, move_delay)
		set_glide_size(DELAY_TO_GLIDE_SIZE(move_delay))
	var/old_dir = dir
	step(src,direction, dir)
	setDir(old_dir)	//Don't want the heli to turn when moving

/obj/vehicle/sealed/helicopter/Bump(atom/A)
	. = ..()
	if(is_blocked_turf(A) && CHECK_BITFIELD(flags_pass, FLYING))	//Watch where you're flying!
		take_damage(FLYING_CRASH_DAMAGE)
		for(var/mob/M in occupants)
			shake_camera(M, 5, 3)
		playsound(A, 'sound/effects/metal_crash.ogg', 100, TRUE)
		update_icon()

/obj/vehicle/sealed/helicopter/obj_break(damage_flag)
	playsound(src, 'sound/machines/beepalert.ogg', 100)
	balloon_alert_to_viewers("Severe damage taken!")

//BLACK HAWK GOING DOWN
/obj/vehicle/sealed/helicopter/obj_destruction(damage_amount, damage_type, damage_flag)
	being_destroyed = TRUE
	if(CHECK_BITFIELD(flags_pass, FLYING))
		playsound(src, 'sound/effects/alert.ogg', 100)
		animate(src, 5 SECONDS, pixel_z = 0)
		addtimer(CALLBACK(src, .proc/death_crash), 5 SECONDS)
	else
		explosion(src, 0, 0, 1, 1, 1, smoke = TRUE)	//Smaller explosion since it didn't crash into the ground
		return ..()

//Proc for convenience
/obj/vehicle/sealed/helicopter/proc/death_crash()
	explosion(src, 0, 1, 2, 2, 2, 1, smoke = TRUE)
	deconstruct(FALSE)

///Proc that grabs a new target for firing at and changes the helicopter's direction to face the cursor
/obj/vehicle/sealed/helicopter/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(over_object, pilot, params))
	if(CHECK_BITFIELD(flags_pass, FLYING))	//Heli can't turn around if it's not flying!
		face_atom(current_target)

/* Weapon fire and autofire component related code below; firing code taken from unmanned vehicles and autofire from gun, spitter, and mech code */
///Sets the current target and registers for qdel to prevent hardels; taken from mech autofire code
/obj/vehicle/sealed/helicopter/proc/set_target(atom/object)
	if(object == current_target || object == src || object == loc)	//Prevent shooting yourself
		return
	if(current_target)
		UnregisterSignal(current_target, COMSIG_PARENT_QDELETING)
	current_target = object
	if(current_target)
		RegisterSignal(current_target, COMSIG_PARENT_QDELETING, .proc/clean_target)

///Cleans the current target in case of Hardel; also from mech code
/obj/vehicle/sealed/helicopter/proc/clean_target()
	SIGNAL_HANDLER
	current_target = get_turf(current_target)

///Checks if we can or already have a bullet loaded that we can shoot
/obj/vehicle/sealed/helicopter/proc/load_into_chamber()
	if(in_chamber)
		return TRUE //Already set!
	if(current_rounds <= 0)
		return FALSE
	in_chamber = new /obj/projectile/aircraft(src) //New bullet!
	in_chamber.generate_bullet(ammo)
	return TRUE

///Check if we have/create a new bullet and fire it at an atom target
/obj/vehicle/sealed/helicopter/proc/fire()
	if(being_destroyed)
		stop_fire()
		return NONE
	if(istype(current_target, /atom/movable/screen))
		return NONE
	if(load_into_chamber())
		//Setup projectile
		in_chamber.original_target = current_target
		in_chamber.def_zone = pick("chest","chest","chest","head")
		//Shoot at the thing
		playsound(loc, fire_sound, 65, 1)
		in_chamber.fire_at(current_target, pilot, src, min(ammo.max_range, get_dist(src, current_target)), ammo.shell_speed)
		in_chamber = null
		current_rounds--
	return AUTOFIRE_CONTINUE

///Autofire component takes over
/obj/vehicle/sealed/helicopter/proc/auto_fire(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	set_target(get_turf_on_clickcatcher(object, pilot, params))
	if(!current_target)
		return
	if(fire_mode == GUN_FIREMODE_SEMIAUTO)
		if(!INVOKE_ASYNC(src, .proc/fire))
			return
		reset_fire()
		return
	SEND_SIGNAL(src, COMSIG_HELI_FIRE)

///Resets the autofire component
/obj/vehicle/sealed/helicopter/proc/reset_fire()
	set_target(null)

///End autofiring
/obj/vehicle/sealed/helicopter/proc/stop_fire()
	SIGNAL_HANDLER
	if(!HAS_TRAIT(src, TRAIT_GUN_BURST_FIRING))
		reset_fire()
	SEND_SIGNAL(src, COMSIG_HELI_STOP_FIRE)

/obj/vehicle/sealed/helicopter/proc/set_bursting(bursting)
	if(bursting)
		ADD_TRAIT(src, TRAIT_GUN_BURST_FIRING, VEHICLE_TRAIT)
		return
	REMOVE_TRAIT(src, TRAIT_GUN_BURST_FIRING, VEHICLE_TRAIT)

/* Action button related code below */
/obj/vehicle/sealed/helicopter/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/helicopter/exit)
	initialize_controller_action_type(/datum/action/vehicle/sealed/helicopter/engine, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/helicopter/spotlight, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/helicopter/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/helicopter))
		var/datum/action/vehicle/sealed/helicopter/heli_holder = .
		heli_holder.helicopter = src

/datum/action/vehicle/sealed/helicopter
	action_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/helicopter/helicopter

/datum/action/vehicle/sealed/helicopter/Destroy()
	helicopter = null
	return ..()

/datum/action/vehicle/sealed/helicopter/exit
	name = "Exit Helicopter"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "71"

/datum/action/vehicle/sealed/helicopter/exit/action_activate()
	. = ..()
	helicopter.mob_try_exit(owner)

/datum/action/vehicle/sealed/helicopter/engine
	name = "Start Helicopter Engine"
	action_icon_state = "mech_internals_off"

/datum/action/vehicle/sealed/helicopter/engine/action_activate()
	. = ..()
	helicopter.toggle_engine()
	if(CHECK_BITFIELD(helicopter.flags_pass, FLYING))
		name = "Shut Down Helicopter Engine"
		action_icon_state = "mech_internals_on"
	else
		name = initial(name)
		action_icon_state = initial(action_icon_state)
	update_button_icon()

/datum/action/vehicle/sealed/helicopter/spotlight
	name = "Turn On Spotlight"
	action_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/helicopter/spotlight/action_activate()
	. = ..()
	vehicle_entered_target.headlights_toggle = !vehicle_entered_target.headlights_toggle
	vehicle_entered_target.set_light_on(vehicle_entered_target.headlights_toggle)
	vehicle_entered_target.update_icon()
	playsound(owner, vehicle_entered_target.headlights_toggle ? 'sound/vehicles/magin.ogg' : 'sound/vehicles/magout.ogg', 40, TRUE)
	if(vehicle_entered_target.headlights_toggle)
		name = "Turn Off Spotlight"
		action_icon_state = "mech_lights_on"
	else
		name = initial(name)
		action_icon_state = initial(action_icon_state)
	update_button_icon()

/* Helicopter variants */
/obj/vehicle/sealed/helicopter/attack
	name = "attack helicopter"
	desc = "Ultralight helicopter with a single weapon attachment point."
	icon_state = "engineering_pod"
	max_integrity = 200
	soft_armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, FIRE = 10, ACID = 0)
	move_delay = 0.3 SECONDS

/obj/vehicle/sealed/helicopter/attack/minigun
	desc = "Ultralight helicopter with a single weapon attachment point. Comes equipped with a BZ-22 minigun."
	starting_weapon = /obj/item/aircraft_weapon/minigun

/obj/vehicle/sealed/helicopter/attack/cannon
	desc = "Ultralight helicopter with a single weapon attachment point. Comes equipped with a GAN-36 cannon."
	starting_weapon = /obj/item/aircraft_weapon/cannon

/obj/vehicle/sealed/helicopter/attack/predator
	desc = "Ultralight helicopter with a single weapon attachment point. Comes equipped with a Predator missile pod."
	starting_weapon = /obj/item/aircraft_weapon/predator

/obj/vehicle/sealed/helicopter/attack/swarm
	desc = "Ultralight helicopter with a single weapon attachment point. Comes equipped with a Swarm missile launcher."
	starting_weapon = /obj/item/aircraft_weapon/swarm

/obj/vehicle/sealed/helicopter/transport
	name = "transport helicopter"
	desc = "Heavily armored and designed to carry 4 passengers."
	icon_state = "atv"
	max_integrity = 500	//Beefy boi
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 20, FIRE = 40, ACID = 20)
	move_delay = 0.4 SECONDS
	max_occupants = 5

/* Aircraft weapons */
/obj/item/aircraft_weapon
	name = "heli glock"
	desc = "Square up."
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "placeholderprop"
	///Fire mode to use for autofire
	var/fire_mode = GUN_FIREMODE_AUTOMATIC
	///Time in BYOND ticks between weapon fires; time between volleys if burst fire
	var/fire_delay = 5
	///Time between each projectile in a burst
	var/burst_delay = 5
	///Shots per burst
	var/burst_amount = 5
	///Ammo typepath we use when attached
	var/ammo = /datum/ammo/bullet
	///Max ammo this gun can carry
	var/max_rounds = 1000
	///Current ammo in this gun
	var/current_rounds = 0
	///Typepath of the ammo to reload it
	var/magazine_type = /obj/item/ammo_magazine
	///Reference to the inserted magazine
	var/obj/item/ammo_magazine/current_magazine = null
	///Sound file or string type played when shooting
	var/fire_sound = null
	///Sound played when inserting a mag
	var/reload_sound = 'sound/weapons/guns/interact/t42_unload.ogg'
	///Sound played when ejecting a mag
	var/unload_sound = 'sound/weapons/guns/interact/t42_unload.ogg'

/obj/item/aircraft_weapon/Initialize()
	. = ..()
	current_magazine = new magazine_type
	current_rounds = max_rounds

/obj/item/aircraft_weapon/examine(mob/user)
	. = ..()
	. += "[current_magazine ? "Ammo: [current_rounds]/[max_rounds]" : "It is empty."]"

/obj/item/aircraft_weapon/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(current_magazine)
		return unload(user)

/obj/item/aircraft_weapon/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/ammo_magazine))
		return reload(I, user)

/obj/item/aircraft_weapon/proc/unload(mob/user, unloaded_while_attached = FALSE)
	if(!unloaded_while_attached)
		if(!current_magazine)	//Safety check
			return
		balloon_alert(user, "Unloading!")
		if(!do_after(user, current_magazine.reload_delay, TRUE, src))
			return
		balloon_alert(user, "Unloaded!")
		playsound(loc, unload_sound, 25, 1)
	user.put_in_active_hand(current_magazine)
	current_magazine = null
	current_rounds = 0

/obj/item/aircraft_weapon/proc/reload(obj/item/ammo_magazine/mag, mob/user, reloaded_while_attached = FALSE)
	if(!reloaded_while_attached)
		if(mag.type != magazine_type)
			balloon_alert(user, "Wrong type of ammunition!")
			return
		if(current_magazine)	//Weapon must be empty first to load a new mag
			balloon_alert(user, "Unload [src] first!")
			return
		balloon_alert(user, "Reloading!")
		if(!do_after(user, mag.reload_delay, TRUE, src))
			return
		balloon_alert(user, "Reloaded!")
		playsound(loc, reload_sound, 25, 1)
	current_magazine = mag
	current_rounds = mag.current_rounds
	user.temporarilyRemoveItemFromInventory(mag)
	mag.forceMove(src)

/obj/item/aircraft_weapon/minigun
	name = "\improper BZ-22 minigun"
	desc = "Classic minigun with some modifications done by the TerraGov Air Corp. This aircraft-mounted assembly features lots of space for stored ammunition."
	icon_state = "30mm_crate"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 1.5
	max_rounds = 500
	ammo = /datum/ammo/bullet/aircraft_minigun
	magazine_type = /obj/item/ammo_magazine/aircraft/minigun
	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'

/obj/item/aircraft_weapon/cannon
	name = "\improper GAN-36 cannon"
	desc = "Slow-firing, heavy cannon. Can turn a man into mush."
	icon_state = "sentry_system"
	fire_mode = GUN_FIREMODE_AUTOMATIC
	fire_delay = 3
	max_rounds = 150
	ammo = /datum/ammo/bullet/aircraft_cannon
	magazine_type = /obj/item/ammo_magazine/aircraft/cannon
	fire_sound = 'sound/weapons/guns/fire/autocannon_fire.ogg'

/obj/item/aircraft_weapon/predator
	name = "\improper Predator missile pod"	//For the AvP and CoD fans out there
	desc = "Low-capacity missile pod for the lethal Predator."
	icon_state = "minirocket_pod"
	fire_delay = 4 SECONDS
	max_rounds = 4
	ammo = /datum/ammo/rocket/predator
	magazine_type = /obj/item/ammo_magazine/rocket/aircraft/predator
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'

/obj/item/aircraft_weapon/swarm
	name = "\improper Swarm missile launcher"	//For the Starsector fans
	desc = "Small and quick, Swarm missiles are designed for saturation bombing rather than precision lethality. Fires in bursts of 5."
	icon_state = "minirocket"
	fire_mode = GUN_FIREMODE_AUTOBURST
	fire_delay = 4 SECONDS
	burst_delay = 2
	burst_amount = 5
	max_rounds = 50
	ammo = /datum/ammo/rocket/swarm
	magazine_type = /obj/item/ammo_magazine/rocket/aircraft/swarm
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'

/* Aircraft weapon magazines */
/obj/item/ammo_magazine/aircraft
	name = "generic aircraft magazine box"
	desc = "Standard issue."
	icon = 'icons/Marine/marine-hmg.dmi'
	icon_state = "heavylaser"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = null
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER
	reload_delay = 5 SECONDS

/obj/item/ammo_magazine/aircraft/minigun
	name = "\improper BZ-22 ammunition case"
	desc = "A large case containing of ammo that can be slotted into the BZ-22 minigun assembly."
	icon_state = "crate"
	max_rounds = 500
	default_ammo = /datum/ammo/bullet/aircraft_minigun

/obj/item/ammo_magazine/aircraft/cannon
	name = "\improper GAN-36 cannon ammunition case"
	desc = "A heavy container for the large GAN-36 cannon rounds."
	icon_state = "ac_mag"
	max_rounds = 150
	default_ammo = /datum/ammo/bullet/aircraft_cannon

/obj/item/ammo_magazine/rocket/aircraft
	name = "generic aircraft missile rack"
	desc = "Standard issue."
	icon_state = ""
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = null
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER
	reload_delay = 5 SECONDS

/obj/item/ammo_magazine/rocket/aircraft/predator
	name = "\improper Predator missile rack"
	desc = "Handy assembly for easy loading of Predator missiles."
	icon_state = "ltbcannon_4"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/predator

/obj/item/ammo_magazine/rocket/aircraft/swarm
	name = "\improper Swarm missile case"
	desc = "Houses the small swarm missiles in neat little rows."
	icon_state = "glauncher_2"
	max_rounds = 50
	default_ammo = /datum/ammo/rocket/swarm

//Making a child for our special scan_a_turf code so that it is not run on every single bullet in the game
/obj/projectile/aircraft/scan_a_turf(turf/turf_to_scan, cardinal_move)
	if(turf_to_scan != original_target_turf)	//Do nothing if it's not the turf the pilot clicked on when firing
		return FALSE
	return ..()
