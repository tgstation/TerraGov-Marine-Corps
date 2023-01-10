#define FLYING_CRASH_DAMAGE 20	//Value used for dealing damage when a flying unit bumps/crashes into something
#define ATTACHED_WEAPON_RELOAD_DELAY 50	//5 seconds	//Time it takes to reload/unload an attached weapon
#define WEAPON_ATTACH_AND_DETACH_DELAY 50	//5 seconds	//Time it takes to attach/detach a weapon
#define REFUELING_DELAY 50	//5 seconds	//Time it takes to refuel

/obj/vehicle/sealed/aircraft
	name = "helicopter"
	desc = "Fast and nimble with only space for one pilot."
	icon = 'icons/obj/vehicles/aircraft.dmi'
	icon_state = ""
	max_integrity = 50
	soft_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, FIRE = 0, ACID = 0)
	flags_atom = BUMP_ATTACKABLE|PREVENT_CONTENTS_EXPLOSION
	generic_canpass = FALSE
	resistance_flags = XENO_DAMAGEABLE|UNACIDABLE|PLASMACUTTER_IMMUNE
	layer = ABOVE_MOB_LAYER	//So that mobs don't clip above it
	move_resist = MOVE_FORCE_OVERPOWERING
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	coverage = 100
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_power = 3
	move_delay = 0.2 SECONDS
	///How long before the vehicle can change direction
	var/turn_delay = 0.1 SECONDS
	///pixel_x and pixel_y offset values; order is clockwise, starting from NORTH
	var/list/offsets = list()
	///Total fuel capacity
	var/max_fuel = 200
	///How much fuel is in the tank
	var/current_fuel = 0
	///How many weapon slots are available
	var/weapon_slots = 0
	///List of coordinates to offset gun sprites; every 2 elements are the X and Y, respectively
	var/list/weapon_slot_positions = list(0, 0)
	///List of references to displayed gun sprites
	var/list/weapon_overlays = list()
	///Weapon that's attached
	var/list/obj/item/weapon/gun/aircraft/attached_weapons = list()
	///If the vehicle should spawn with a weapon allready installed
	var/list/obj/item/weapon/gun/aircraft/starting_weapons = list()
	///To keep track of whichever weapon is currently selected by the gunner
	var/obj/item/weapon/gun/aircraft/current_weapon = null
	///Mob reference to the pilot; much easier than doing a for loop on every occupant
	var/mob/living/carbon/human/pilot = null
	///Mob reference to the gunner; needed for stat checks before firing
	var/mob/living/carbon/human/gunner = null
	///How many occupants can be given gunner permissions
	var/max_gunners = 0
	///Minimum skill requirement for piloting this craft
	var/required_pilot_skill = SKILL_PILOT_TRAINED
	///The preferred spots to dump occupants on when exiting, relative to the current direction
	var/list/exit_locations = list()
	var/deployable = TRUE
	var/deployed = FALSE
	var/being_destroyed = FALSE
	COOLDOWN_DECLARE(engine_cooldown)
	COOLDOWN_DECLARE(enginesound_cooldown)
	COOLDOWN_DECLARE(turning_cooldown)
	var/obj/effect/abstract/particle_holder/light_smoke_effect
	var/obj/effect/abstract/particle_holder/heavy_smoke_effect

/obj/vehicle/sealed/aircraft/Initialize(mapload)
	. = ..()
	prepare_huds()
	for(var/datum/atom_hud/squad/aircraft_hud in GLOB.huds) //Add to the squad HUD
		aircraft_hud.add_to_hud(src)
	current_fuel = max_fuel
	if(starting_weapons)
		attach_starting_weapon()
	if(deployable && !deployed)
		deploy(null, TRUE)
	integrity_failure = max_integrity/5	//20% of HP triggers damage alert
	light_smoke_effect = new(src, /particles/aircraft_smoke_light)
	heavy_smoke_effect = new(src, /particles/aircraft_smoke_heavy)
	light_smoke_effect.pixel_x = 16
	heavy_smoke_effect.pixel_x = 16
	update_icon()

/obj/vehicle/sealed/aircraft/update_icon()
	show_aircraft_health()
	show_aircraft_fuel()
	handle_offsets()
	if(obj_integrity > integrity_failure && obj_integrity < max_integrity * 0.8)	//From 20% to 70% HP, some smoke will emit
		light_smoke_effect.particles.spawning = initial(light_smoke_effect.particles.spawning)
		heavy_smoke_effect.particles.spawning = 0
	else if(obj_integrity <= integrity_failure)	//20% HP and under will produce thick, black smoke
		heavy_smoke_effect.particles.spawning = initial(heavy_smoke_effect.particles.spawning)
		light_smoke_effect.particles.spawning = 0
	else
		light_smoke_effect.particles.spawning = 0
		heavy_smoke_effect.particles.spawning = 0
	light_smoke_effect.pixel_z = pixel_z
	heavy_smoke_effect.pixel_z = pixel_z
	light_smoke_effect.layer = layer + 0.01
	heavy_smoke_effect.layer = layer + 0.01
	return ..()

///Proc for delayed turning
/obj/vehicle/sealed/aircraft/proc/turn_while_flying(direction)
	if(direction == dir)
		return
	if(!COOLDOWN_CHECK(src, turning_cooldown))
		return
	COOLDOWN_START(src, turning_cooldown, turn_delay)
	if(direction == REVERSE_DIR(dir))
		return setDir(turn(dir, pick(45, -45)))
	var/angle1 = dir2angle(direction)
	var/angle2 = dir2angle(dir)
	var/angle_to_turn = closer_angle_difference(angle1, angle2) > 0 ? 45 : -45
	setDir(turn(dir, angle_to_turn))
	if(direction != dir)
		addtimer(CALLBACK(src, .proc/turn_while_flying, direction), turn_delay)

/obj/vehicle/sealed/aircraft/setDir(newdir)
	. = ..()
	handle_offsets()

///Adjust the sprite positions when turning
/obj/vehicle/sealed/aircraft/proc/handle_offsets()
	switch(dir)
		if(NORTH)
			pixel_x = offsets[1]
			pixel_y = offsets[2]
		if(NORTHEAST)
			pixel_x = offsets[3]
			pixel_y = offsets[4]
		if(EAST)
			pixel_x = offsets[5]
			pixel_y = offsets[6]
		if(SOUTHEAST)
			pixel_x = offsets[7]
			pixel_y = offsets[8]
		if(SOUTH)
			pixel_x = offsets[9]
			pixel_y = offsets[10]
		if(SOUTHWEST)
			pixel_x = offsets[11]
			pixel_y = offsets[12]
		if(WEST)
			pixel_x = offsets[13]
			pixel_y = offsets[14]
		if(NORTHWEST)
			pixel_x = offsets[15]
			pixel_y = offsets[16]
	if(LAZYLEN(weapon_overlays))
		//Remove the overlays and re-apply them in the direction the aircraft is facing
		cut_overlays()
		weapon_overlays.Cut()
		for(var/obj/item/weapon/gun/aircraft/gun AS in attached_weapons)
			var/weapon_position_in_list = attached_weapons.Find(gun)
			var/x_offset
			var/y_offset
			switch(dir)
				if(NORTH)
					x_offset = -weapon_slot_positions[weapon_position_in_list * 2 - 1] + 32
					y_offset = -weapon_slot_positions[weapon_position_in_list * 2] + 32
				if(NORTHEAST)
					x_offset = -weapon_slot_positions[weapon_position_in_list * 2 - 1] + 48
					y_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1] + 16
				if(EAST)
					x_offset = -weapon_slot_positions[weapon_position_in_list * 2] + 32
					y_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1]
				if(SOUTHEAST)
					x_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1] + 16
					y_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1] - 16
				if(SOUTH)
					x_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1]
					y_offset = weapon_slot_positions[weapon_position_in_list * 2]
				if(SOUTHWEST)
					x_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1] - 16
					y_offset = -weapon_slot_positions[weapon_position_in_list * 2 - 1] + 16
				if(WEST)
					x_offset = weapon_slot_positions[weapon_position_in_list * 2]
					y_offset = -weapon_slot_positions[weapon_position_in_list * 2 - 1] + 32
				if(NORTHWEST)
					x_offset = -weapon_slot_positions[weapon_position_in_list * 2 - 1] + 16
					y_offset = -weapon_slot_positions[weapon_position_in_list * 2 - 1] + 48
			var/image/gun_overlay = image(gun.icon, gun.icon_state + "_a", pixel_x = x_offset, pixel_y = y_offset, layer = ABOVE_MOB_LAYER-0.01)
			add_overlay(gun_overlay)
			weapon_overlays += gun_overlay

/obj/vehicle/sealed/aircraft/examine(mob/user)
	. = ..()
	. += "There is [available_passenger_slots() ? "room for [available_passenger_slots()] passengers" : "no room for passengers"]."
	if(is_driver(user))
		. += "The fuel gauge reads: <b>[current_fuel]/[max_fuel]</b>"
	else
		. += "[pilot ? "It is being piloted by [pilot.name]" : "There is no pilot inside"]."
	. += "It has <b>[obj_integrity]/[max_integrity] HP</b>"
	if(attached_weapons)
		for(var/obj/item/weapon/gun/aircraft/gun AS in attached_weapons)
			. += "[gun.name] is attached."
	else
		. += "No weapon is attached."

/obj/vehicle/sealed/aircraft/attack_hand(mob/living/user)
	if(is_occupant(user))
		balloon_alert(user, "Must be outside!")
		return FALSE
	if(CHECK_BITFIELD(flags_pass, FLYING) && !CHECK_MULTIPLE_BITFIELDS(user.flags_pass, FLYING))	//Only another flying unit can reach us!
		balloon_alert(user, "Out of reach!")
		return
	if(LAZYLEN(occupants) && user.a_intent == INTENT_GRAB)	//For kicking someone out
		var/mob/evicted = LAZYLEN(occupants) == 1 ? occupants[1] : tgui_input_list(user, "Choose who to remove from [src]", "Occupant Eviction", occupants)
		if(!evicted)
			return
		visible_message(span_warning("[user.name] is attempting to remove [evicted] from [src]!"))	//Chat message for logging purposes
		if(!do_after(user, enter_delay * 2, TRUE, user))
			return
		return mob_try_exit(evicted)
	if(deployable)
		return deploy(user)
	return ..()

/obj/vehicle/sealed/aircraft/attackby(obj/item/I, mob/user, params)
	if(is_occupant(user))
		balloon_alert(user, "Must be outside!")
		return FALSE
	if(CHECK_BITFIELD(flags_pass, FLYING) && !CHECK_MULTIPLE_BITFIELDS(user.flags_pass, FLYING))	//Only another flying unit can reach us!
		balloon_alert(user, "Out of reach!")
		return
	. = ..()
	if(istype(I, /obj/item/reagent_containers/jerrycan))
		return refuel(I, user)
	if(istype(I, /obj/item/weapon/gun/aircraft))
		return attach_weapon(I, user)
	if(istype(I, /obj/item/ammo_magazine))
		return reload(I, user)

/obj/vehicle/sealed/aircraft/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(CHECK_BITFIELD(flags_pass, FLYING) && !CHECK_MULTIPLE_BITFIELDS(X.flags_pass, FLYING))	//Only another flying beno can hit us!
		balloon_alert(X, "Out of reach!")
		return
	return ..()

/obj/vehicle/sealed/aircraft/MouseDrop(atom/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(is_occupant(over))
		balloon_alert(over, "Must be outside!")
		return FALSE
	if(LAZYLEN(attached_weapons))
		return unload(over)

/obj/vehicle/sealed/aircraft/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(LAZYLEN(occupants))	//Aicraft is not perfectly sealed!
		for(var/mob/living/M in occupants)
			M.effect_smoke(S)

///Proc for removing fuel from a jerry can and adding it to the aircraft
/obj/vehicle/sealed/aircraft/proc/refuel(obj/item/reagent_containers/jerrycan/J, mob/user)
	if(J.reagents.total_volume == 0)
		balloon_alert(user, "Empty!")
		return
	if(current_fuel >= max_fuel)
		balloon_alert(user, "Gas tank already full!")
		return
	//Refueling takes time so that doing it in the field leaves a window of vulnerability
	balloon_alert_to_viewers("Refueling!")
	if(!do_after(user, REFUELING_DELAY, TRUE, user))
		return
	//Just transfer it all in one go, no need to spam click
	var/fuel_transfer_amount = min(max_fuel - current_fuel, J.reagents.total_volume)
	J.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
	current_fuel += fuel_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 5)
	if(current_fuel >= max_fuel)
		balloon_alert(user, "Full!")
	show_aircraft_fuel()

///Deploys and undeploys the vehicle
/obj/vehicle/sealed/aircraft/proc/deploy(mob/living/user, deployed_after_spawn = FALSE)
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
		playsound(src, 'sound/machines/hydraulics_1.ogg', 30, FALSE, 5)
		icon_state = initial(icon_state)
		move_resist = initial(move_resist)
	else
		playsound(src, 'sound/machines/hydraulics_2.ogg', 30, FALSE, 5)
		icon_state += "_undeployed"
		move_resist = MOVE_RESIST_DEFAULT
	update_icon()

///Try to eject the current mag in the attached weapon
/obj/vehicle/sealed/aircraft/proc/unload(mob/user)
	var/list/list_of_guns_to_unload = list()
	for(var/obj/item/weapon/gun/aircraft/gun AS in attached_weapons)
		if(!LAZYLEN(gun.chamber_items))
			continue
		list_of_guns_to_unload += gun
	if(!LAZYLEN(list_of_guns_to_unload))
		return
	var/obj/item/weapon/gun/aircraft/gun_to_unload = LAZYLEN(list_of_guns_to_unload) == 1 ? list_of_guns_to_unload[1] : tgui_input_list(user, "Pick a weapon to unload from [src]", "Currently Loaded Weapons", list_of_guns_to_unload)
	if(!gun_to_unload)
		return
	balloon_alert_to_viewers("Unloading!")
	if(!do_after(user, ATTACHED_WEAPON_RELOAD_DELAY, TRUE, user))
		return
	if(!attached_weapons.Find(gun_to_unload) || !LAZYLEN(gun_to_unload.chamber_items))	//Safety check
		return
	gun_to_unload.unload(user)
	balloon_alert_to_viewers("Unloaded!")

///Try to insert a new mag into the attached weapon
/obj/vehicle/sealed/aircraft/proc/reload(obj/item/ammo_magazine/mag, mob/user)
	if(!LAZYLEN(attached_weapons))
		return
	var/list/list_of_guns_to_reload = list()
	for(var/obj/item/weapon/gun/aircraft/gun AS in attached_weapons)
		if(!(mag.type in gun.allowed_ammo_types))
			continue
		list_of_guns_to_reload += gun
	if(!LAZYLEN(list_of_guns_to_reload))
		balloon_alert(user, "Wrong type of ammunition!")
	var/obj/item/weapon/gun/aircraft/gun_to_reload = LAZYLEN(list_of_guns_to_reload) == 1 ? list_of_guns_to_reload[1] : tgui_input_list(user, "Pick a weapon from [src] to reload", "Currently Unloaded Weapons", list_of_guns_to_reload)
	if(!gun_to_reload)
		return
	if(LAZYLEN(gun_to_reload.chamber_items))	//Weapon must be empty first to load a new mag
		balloon_alert(user, "Unload [gun_to_reload.name] first!")
		return
	balloon_alert_to_viewers("Reloading!")
	if(!do_after(user, ATTACHED_WEAPON_RELOAD_DELAY, TRUE, user))
		return
	if(!attached_weapons.Find(gun_to_reload) || LAZYLEN(gun_to_reload.chamber_items))	//Safety check
		return
	gun_to_reload.reload(mag, user, TRUE)
	balloon_alert_to_viewers("Reloaded!")
	playsound(loc, gun_to_reload.reload_sound, 25, 1, FALSE, 5)

///Handles weapon attaching
/obj/vehicle/sealed/aircraft/proc/attach_weapon(obj/item/weapon/gun/aircraft/gun, mob/user)
	if(!weapon_slots)
		balloon_alert(user, "No available weapon slots!")
		return
	balloon_alert_to_viewers("Attaching weapon!")
	if(!do_after(user, WEAPON_ATTACH_AND_DETACH_DELAY, TRUE, user, BUSY_ICON_BUILD))
		return
	if(!weapon_slots)	//Safety check
		balloon_alert(user, "No available weapon slots!")
		return
	balloon_alert_to_viewers("Weapon attached!")
	user.transferItemToLoc(gun, src)
	attached_weapons += gun
	ENABLE_BITFIELD(gun.flags_item, IS_DEPLOYED)
	weapon_slots--
	//Find the position in the list the gun is in, then find the corresponding coordinates
	//Example: Gun that user just attached is element number 2 in the attached_weapons list, so it will use the 3rd and 4th numbers in weapon_slot_positions
	var/weapon_position_in_list = attached_weapons.Find(gun)
	var/x_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1]
	var/y_offset = weapon_slot_positions[weapon_position_in_list * 2]
	var/image/gun_overlay = image(gun.icon, gun.icon_state + "_a", pixel_x = x_offset, pixel_y = y_offset, layer = ABOVE_MOB_LAYER-0.01)
	add_overlay(gun_overlay)
	weapon_overlays += gun_overlay
	playsound(src, 'sound/weapons/guns/fire/tank_minigun_start.ogg', 50, FALSE, 5)
	update_icon()
	if(gunner)
		//If there was no weapon attached, that means we need to set_interaction to give the gunner proper flags and such
		if(LAZYLEN(attached_weapons) == 1)
			gunner.set_interaction(src)

///SpacemanDMM hates that attach_weapon has a timer in it even if it's never accessed, so new snowflake proc for Initialize() purposes
/obj/vehicle/sealed/aircraft/proc/attach_starting_weapon()
	for(var/obj/item/weapon/gun/aircraft/gun AS in starting_weapons)
		gun = new gun
		attached_weapons += gun
		gun.forceMove(src)
		ENABLE_BITFIELD(gun.flags_item, IS_DEPLOYED)
		weapon_slots--
		var/weapon_position_in_list = attached_weapons.Find(gun)
		var/x_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1]
		var/y_offset = weapon_slot_positions[weapon_position_in_list * 2]
		var/image/gun_overlay = image(gun.icon, gun.icon_state + "_a", pixel_x = x_offset, pixel_y = y_offset, layer = ABOVE_MOB_LAYER-0.01)
		add_overlay(gun_overlay)
		weapon_overlays += gun_overlay
	update_icon()

/obj/vehicle/sealed/aircraft/wrench_act(mob/living/user, obj/item/I)
	if(!LAZYLEN(attached_weapons))
		balloon_alert(user, "No weapon attached!")
		return
	var/list/list_of_guns_to_detach = list()
	for(var/obj/item/weapon/gun/aircraft/gun AS in attached_weapons)
		list_of_guns_to_detach += gun
	var/obj/item/weapon/gun/aircraft/gun_to_detach = LAZYLEN(list_of_guns_to_detach) == 1 ? list_of_guns_to_detach[1] : tgui_input_list(user, "Pick a weapon from [src] to detach", "Currently Attached Weapons", list_of_guns_to_detach)
	if(!gun_to_detach)
		return
	balloon_alert_to_viewers("Detaching weapon!")
	if(!do_after(user, WEAPON_ATTACH_AND_DETACH_DELAY, TRUE, user, BUSY_ICON_BUILD))
		return
	var/weapon_position_in_list = attached_weapons.Find(gun_to_detach)
	if(!weapon_position_in_list)	//Safety check
		balloon_alert(user, "No weapon attached!")
		return
	balloon_alert_to_viewers("Weapon detached!")
	if(gunner && LAZYLEN(attached_weapons) == 1)
		gunner.unset_interaction()
	else
		gun_to_detach.set_gun_user(null)
	user.put_in_hands(gun_to_detach)
	cut_overlays()
	weapon_overlays.Cut()
	attached_weapons -= gun_to_detach
	if(LAZYLEN(attached_weapons))	//Re-add all gun overlays because there is no easy way to make a system that keeps track of "open" overlay slots
		for(var/obj/item/weapon/gun/aircraft/gun AS in attached_weapons)
			weapon_position_in_list = attached_weapons.Find(gun)
			var/x_offset = weapon_slot_positions[weapon_position_in_list * 2 - 1]
			var/y_offset = weapon_slot_positions[weapon_position_in_list * 2]
			var/image/gun_overlay = image(gun.icon, gun.icon_state + "_a", pixel_x = x_offset, pixel_y = y_offset, layer = ABOVE_MOB_LAYER-0.01)
			add_overlay(gun_overlay)
			weapon_overlays += gun_overlay
	DISABLE_BITFIELD(gun_to_detach.flags_item, IS_DEPLOYED)
	weapon_slots++
	playsound(src, 'sound/weapons/guns/fire/tank_minigun_start.ogg', 50, FALSE, 5)
	update_icon()

/obj/vehicle/sealed/aircraft/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	var/obj/item/tool/weldingtool/WT = I
	if(!WT.isOn())
		balloon_alert(user, "Welder has to be lit!")
		return FALSE
	if(obj_integrity == max_integrity)
		balloon_alert(user, "[src] doesn't need repairs!")
		return TRUE
	if(!WT.get_fuel())
		balloon_alert(user, "No welding fuel!")
		return FALSE
	add_overlay(GLOB.welding_sparks)
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE, 5)
	///For calculating how fast the user repairs, with a bonus for pilots since they are trained on vehicle maintenance
	var/repair_skill = user.skills.getRating("engineer") + user.skills.getRating("pilot")
	///How long it takes to repair, depending on how low integrity is (every 1/10th of max_integrity); shortest possible time is 0.2 seconds
	var/welding_duration = max(round((10 - (((obj_integrity/max_integrity) * 100)/10))/(repair_skill ? ((repair_skill/5) + 1) : 1), 0.1), 0.2)
	visible_message(span_notice("[user] starts welding away the damage from [src]."))
	if(!do_after(user, welding_duration SECONDS, TRUE, user, repair_skill ? BUSY_ICON_BUILD : BUSY_ICON_UNSKILLED))
		cut_overlay(GLOB.welding_sparks)
		return FALSE
	playsound(loc, 'sound/items/welder.ogg', 25, TRUE, 5)
	cut_overlay(GLOB.welding_sparks)
	///How much fuel to remove from the welder; every 1 unit of fuel will repair 10% of integrity
	var/welding_fuel_cost = min(CEILING(-((obj_integrity - max_integrity)/(max_integrity/10)), 1), WT.get_fuel())
	if(!WT.remove_fuel(welding_fuel_cost, user))	//In case there is somehow not enough fuel
		balloon_alert(user, "Not enough welding fuel!")
		return FALSE
	///In the event where there is not enough fuel to fully repair, it will use up what fuel remains and repair it by that value
	var/repair_amount = welding_fuel_cost * (max_integrity/10)
	repair_damage(repair_amount)
	balloon_alert_to_viewers("[obj_integrity == max_integrity ? "Fully repaired!" : "Partially repaired!"]")
	update_icon()
	return TRUE

/obj/vehicle/sealed/aircraft/enter_checks(mob/M)
	//If the mob is a pilot, check for driver seats
	if(M.skills.getRating("pilot") >= required_pilot_skill && driver_amount() < max_drivers)
		return TRUE
	//If mob is not a pilot or the pilot seats are full, check for how many passenger seats we got
	if(available_passenger_slots())
		return TRUE
	balloon_alert_to_viewers("Max occupancy!")
	return FALSE

//Overwriting because this proc ran enter_checks every tick which was very inefficient
/obj/vehicle/sealed/aircraft/mob_try_enter(mob/M)
	if(!istype(M))
		return FALSE
	if(!deployed)
		to_chat(M, span_warning("[src] must be deployed to board!"))
		return FALSE
	if(CHECK_BITFIELD(flags_pass, FLYING))
		to_chat(M, span_warning("You can't board [src] mid-flight!"))
		return FALSE
	if(!enter_checks(M))	//Only run enter checks before and after the timer
		return FALSE
	if(!do_after(M, enter_delay, FALSE, M))
		return FALSE
	if(enter_checks(M))
		mob_enter(M)
		return TRUE
	return FALSE

/obj/vehicle/sealed/aircraft/mob_try_exit(mob/M, mob/user, silent, randomstep)
	if(CHECK_BITFIELD(flags_pass, FLYING) && !being_destroyed)
		to_chat(M, span_warning("You can't jump out of [src] mid-flight!"))
		return FALSE
	if(being_destroyed)	//Eligible for bailing out
		return mob_exit(M, FALSE, TRUE, TRUE)
	return ..()

/obj/vehicle/sealed/aircraft/mob_exit(mob/M, silent, randomstep, bailed = FALSE)
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	M.set_flying(FALSE)	//Just in case
	if(bailed && iscarbon(M))	//Jumping out of a flying vehicle can be dangerous
		var/mob/living/carbon/Carbon = M
		Carbon.Paralyze(20)
		Carbon.apply_damage(10)
		if(!silent)
			visible_message(span_danger("[Carbon.name] bailed from [src]!"))
	if(randomstep)
		M.forceMove(drop_location())
		var/turf/target_turf = get_step(M.loc, pick(GLOB.cardinals))
		M.throw_at(target_turf, 5, 10)
	else
		var/turf/target_turf = exit_location(M)
		if(!target_turf)	//If no available turfs found, just dump them on the source tile
			return M.forceMove(drop_location())
		return M.forceMove(target_turf)

/obj/vehicle/sealed/aircraft/remove_occupant(mob/M)
	//Placing this check here before the rest of the proc and not in mob_exit because by then the occupant control flags are cleared
	if(!is_occupant(M))	//Needed because Exit() also calls this proc and causes runtimes when it tries to find the non-existent occupant
		return ..()
	if(occupants[M] & VEHICLE_CONTROL_DRIVE || occupants[M] & VEHICLE_CONTROL_EQUIPMENT)	//Check if this mob has perms
		M.unset_interaction()
		if(M == pilot)
			UnregisterSignal(M, COMSIG_MOB_MOUSEDRAG)
			pilot = null
		if(M == gunner)
			gunner = null
	return ..()

/obj/vehicle/sealed/aircraft/exit_location(M)
	if(LAZYLEN(exit_locations))	//Check if there any preferred locations to dump stuff
		for(var/exit_direction in exit_locations)
			var/turf/exit_turf = get_step(loc, turn(dir, dir2angle(exit_direction)))
			if(turf_block_check(M, exit_turf))
				continue
			return exit_turf
	//No preferred location exists or they are not available, so let's pick at random
	for(var/turf/exit_turf in get_adjacent_open_turfs(M))
		if(turf_block_check(M, exit_turf))	//Turf may be open, but we still need to check if there are any blockers on it
			continue
		return exit_turf
	return FALSE

//Removing the hand blocking traits from these two procs so that passengers aren't paralyzed while inside
//However, guns are very buggy when used inside so removing dexterity to prevent gun usage and other exploitables like binoculars
/obj/vehicle/sealed/aircraft/after_add_occupant(mob/M)
	if(auto_assign_occupant_flags(M))
		if(occupants[M] & VEHICLE_CONTROL_DRIVE)	//Pilots turn the vehicle
			RegisterSignal(M, COMSIG_MOB_MOUSEDRAG, .proc/turn_vehicle)
		if(occupants[M] & VEHICLE_CONTROL_EQUIPMENT && LAZYLEN(attached_weapons))	//Gunners have fire controls
			M.set_interaction(src)
	else
		to_chat(M, span_notice("You board as a passenger."))
	M.dextrous = FALSE

/obj/vehicle/sealed/aircraft/after_remove_occupant(mob/M)
	if(ishuman(M))	//Humans by default don't have dexterity, it is based on species
		var/mob/living/carbon/human/H = M
		H.dextrous = H.species.has_fine_manipulation
		return
	M.dextrous = initial(M.dextrous)

/*
Vehicle occupant permissions:
At the moment, there is only (bug-free) support for one pilot and one gunner, or one pilot and multiple passengers
Ideally the system would be more modular for accommodating multiple pilots and gunners in one vehicle
However, that's a whole other mountain to climb, trying to keep it simple for the moment

VEHICLE_CONTROL_DRIVE: Mob with this flag moves the vehicle when any movement key is pressed, should only be used by pilots
VEHICLE_CONTROL_SETTINGS: Used for any misc actions that both pilots and gunners make sense to have access to (though none use it yet)
VEHICLE_CONTROL_EQUIPMENT: Will be the flag for weapon-related controls, should only be given to pilots if no gunner slot exists
*/
/obj/vehicle/sealed/aircraft/auto_assign_occupant_flags(mob/M)
	//Are driver slots filled and does this mob have the necessary pilot training to be eligible for driver seats?
	if(driver_amount() < max_drivers && M.skills.getRating("pilot") >= required_pilot_skill)
		if(max_gunners)	//If the vehicle has no gunner slots, it means the pilot controls the guns too
			add_control_flags(M, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		else
			add_control_flags(M, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)
			gunner = M	//Since the pilot is also the gunner
		pilot = M	//Register the mob as our pilot!
		return TRUE
	if(gunner_amount() < max_gunners)
		add_control_flags(M, VEHICLE_CONTROL_SETTINGS|VEHICLE_CONTROL_EQUIPMENT)
		gunner = M	//Register the mob as our gunner!
		return TRUE
	return FALSE

///Returns how many occupants have VEHICLE_CONTROL_EQUIPMENT, which is for weapons permissions
/obj/vehicle/sealed/aircraft/proc/gunner_amount()
	return return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/aircraft/on_set_interaction(mob/user)
	if(!user)
		return
	RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, .proc/start_fire)
	if(occupants[user] & VEHICLE_CONTROL_DRIVE)	//Give the user the pilot-gunner combo proc
		UnregisterSignal(user, COMSIG_MOB_MOUSEDRAG)	//In case they already have the signal registered with turn_vehicle()
		RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, .proc/change_target)
	else
		RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, .proc/turn_gun)
	//By default will select the first weapon
	if(!current_weapon)
		current_weapon = attached_weapons[1]
	for(var/datum/action/action AS in current_weapon.actions)
		action.give_action(user)
	current_weapon.set_gun_user(user)

/obj/vehicle/sealed/aircraft/on_unset_interaction(mob/user)
	if(!user)
		return
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
	if(occupants[user] & VEHICLE_CONTROL_DRIVE)
		UnregisterSignal(user, COMSIG_MOB_MOUSEDRAG)
		RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, .proc/turn_vehicle)	//Give the pilot back the flight controls signal
	else
		UnregisterSignal(user, COMSIG_MOB_MOUSEDRAG)
	current_weapon.UnregisterSignal(user, COMSIG_MOB_MOUSEUP)
	for(var/datum/action/action AS in current_weapon.actions)
		action.remove_action(user)
	current_weapon.set_gun_user(null)
	current_weapon = null

/*
The three procs below were originally going to have one proc to run the stat checks but that would have caused problems; is also why we need the gunner var
The reason they are also three separate procs is because operation_checks is run if the pilot is also the gunner, the rest are for their respective roles
*/
///Check if the user is alive and the target is valid
/obj/vehicle/sealed/aircraft/proc/operation_checks(atom/object)
	if(!object.loc || get_turf(object) == loc)	//Prevents shooting yourself if you click on something in your inventory too!
		return FALSE
	if(pilot.stat)	//The dead can't fly or shoot!
		if(!TIMER_COOLDOWN_CHECK(src, "aircraft anti spam"))
			to_chat(pilot, span_warning(span_alert("You can't fly the [src] in your current state!")))
			TIMER_COOLDOWN_START(src, "aircraft anti spam", 2 SECONDS)
		if(current_weapon?.gun_user)
			to_chat(pilot, span_warning(span_alert("You lost gun control! Click [src] to regain control.")))	//To let the user know what to do if they regain consciousness
			pilot.unset_interaction()
		return FALSE
	return TRUE

///Check if the pilot is alive and if the target is valid
/obj/vehicle/sealed/aircraft/proc/flight_operation_checks(atom/object)
	if(!object.loc || get_turf(object) == loc)
		return FALSE
	if(pilot.stat)	//The dead can't fly!
		to_chat(pilot, span_warning(span_alert("You can't fly the [src] in your current state!")))
		return FALSE
	return TRUE

///Check if the gunner is alive and if the target is valid
/obj/vehicle/sealed/aircraft/proc/gun_operation_checks(atom/object)
	if(!object.loc || get_turf(object) == loc)
		return FALSE
	if(gunner.stat)	//The dead can't shoot!
		to_chat(gunner, span_warning(span_alert("You lost gun control!")))
		gunner.unset_interaction()
		return FALSE
	return TRUE

/*
A problem encountered was that you cannot register two different procs to the same signal (in the event where pilot is also the gunner)
So there are now three different procs that can be called by COMSIG_MOB_MOUSEDOWN
That way pilots and gunners have their respective procs, but if the pilot is the gunner, they call change_target() to change direction and gun target
*/
///Proc that grabs a new target for firing/looking at if the pilot is also a gunner
/obj/vehicle/sealed/aircraft/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!operation_checks(over_object))
		return FALSE
	current_weapon.change_target(source, src_object, over_object, src_location, over_location, src_control, over_control, params)
	if(CHECK_BITFIELD(flags_pass, FLYING))	//Can't turn around if it's not flying!
		turn_while_flying(angle_to_dir(Get_Angle(source, over_object)))

///Proc for turning the vehicle to wherever the cursor is
/obj/vehicle/sealed/aircraft/proc/turn_vehicle(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!flight_operation_checks(over_object))
		return FALSE
	if(CHECK_BITFIELD(flags_pass, FLYING))
		turn_while_flying(angle_to_dir(Get_Angle(source, over_object)))

///Proc that grabs a new target for firing at
/obj/vehicle/sealed/aircraft/proc/turn_gun(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(!gun_operation_checks(over_object))
		return FALSE
	current_weapon.change_target(source, src_object, over_object, src_location, over_location, src_control, over_control, params)

///Autofire component takes over
/obj/vehicle/sealed/aircraft/proc/start_fire(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(!gun_operation_checks(object))
		return FALSE
	current_weapon.start_fire(source, object, location, control, params, TRUE)

///Code for toggling the engine on and off, easier to have it separated than as part of the action button
/obj/vehicle/sealed/aircraft/proc/toggle_engine()
	if(!CHECK_BITFIELD(flags_pass, FLYING) && current_fuel > 0)
		if(!pilot)
			return
		if(!COOLDOWN_CHECK(src, engine_cooldown))
			balloon_alert(pilot, "Engine is not ready!")
			return
		COOLDOWN_START(src, engine_cooldown, 10 SECONDS)
		set_flying(TRUE)
		animate(src, 3 SECONDS, pixel_z = 20)
		add_filter("flight_shadow", 2, drop_shadow_filter(y = 0, size = 0, color = "#000000"))
		animate(get_filter("flight_shadow"), 3 SECONDS, y = -10, size = 10, flags = ANIMATION_PARALLEL)
		coverage = 0
		layer = FLY_LAYER
		icon_state += "_flying"
		for(var/mob/M in occupants)
			M.set_flying(TRUE)
		START_PROCESSING(SSobj, src)
	else if(CHECK_BITFIELD(flags_pass, FLYING))
		animate(src, 1 SECONDS, pixel_z = 0)
		animate(get_filter("flight_shadow"), 1 SECONDS, y = 0, size = 0, flags = ANIMATION_PARALLEL)
		STOP_PROCESSING(SSobj, src)
		addtimer(CALLBACK(src, .proc/shutdown_procedures), 1 SECONDS)
	else
		balloon_alert(pilot, "Out of fuel!")

///Series of actions taken when the aircraft is no longer flying
/obj/vehicle/sealed/aircraft/proc/shutdown_procedures()
	set_flying(FALSE)
	coverage = initial(coverage)
	layer = initial(layer)
	remove_filter("flight_shadow")
	icon_state = initial(icon_state)
	for(var/mob/M in occupants)
		M.set_flying(FALSE)
	if(pilot)
		pilot.update_action_buttons()	//For updating the toggle engine button
	var/turf/landing_zone = get_turf(src)
	if(landing_zone.density)
		var/no_valid_turf = TRUE
		for(var/turf/target in get_adjacent_open_turfs(src))
			if(!is_blocked_turf(target))	//Try to find a valid open turf
				throw_at(target, 2, 3, spin = TRUE)	//Throw the vehicle at this open turf
				take_damage(FLYING_CRASH_DAMAGE)
				no_valid_turf = FALSE
				break
		if(no_valid_turf)
			obj_destruction()	//If no valid open turfs nearby, aircraft goes up in flames
	if(LAZYLEN(landing_zone.contents))	//Let's crush anything this lands on!
		for(var/atom/A in landing_zone.contents)
			if(A == src)	//Don't splat ourselves!
				continue
			if(ismob(A))
				var/mob/living/victim = A
				victim.apply_damage(40)
				victim.Stun(2 SECONDS)
				visible_message(span_alert("[victim.name] was crushed under the weight of [src]!"))	//Important to keep as a message for logging
				playsound(src, 'sound/effects/clownstep2.ogg', 100, FALSE, 7)	//Funny, but placeholder until I find a proper squish/splat sound
			else if(isobj(A))
				var/obj/victim = A
				if(!CHECK_BITFIELD(victim.resistance_flags, INDESTRUCTIBLE))
					victim.obj_destruction()
					visible_message(span_alert("[victim.name] was crushed under the weight of [src]!"))	//Important to keep as a message for logging

//Aircraft burn fuel at all times while flying, even if only hovering
/obj/vehicle/sealed/aircraft/process()
	current_fuel--
	update_icon()
	if(current_fuel <= 0)
		playsound(src, 'sound/mecha/lowpower.ogg', 100, FALSE, 7)	//Should play only to the pilot but we have no aircraft descending sound yet
		toggle_engine()
	if(pilot.stat)	//The dead can't fly!
		balloon_alert_to_viewers("Pilot control lost!")	//To let people know the pilot isn't awake
		toggle_engine()
	if(COOLDOWN_CHECK(src, enginesound_cooldown))
		COOLDOWN_START(src, enginesound_cooldown, 3.5 SECONDS)
		playsound(src, 'sound/effects/tadpolehovering.ogg', 60, TRUE, 10)
	if(being_destroyed)
		setDir(pick(LeftAndRightOfDir(dir, TRUE)))

/obj/vehicle/sealed/aircraft/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(!LAZYLEN(occupants))
		return
	if(current_fuel > 0)
		current_fuel--

/obj/vehicle/sealed/aircraft/relaymove(mob/living/user, direction)
	if(!CHECK_BITFIELD(flags_pass, FLYING))
		if(!TIMER_COOLDOWN_CHECK(src, "aircraft anti spam"))
			balloon_alert(user, "Engine offline!")
			TIMER_COOLDOWN_START(src, "aircraft anti spam", 2 SECONDS)
		return FALSE
	if(current_fuel <= 0)
		if(!TIMER_COOLDOWN_CHECK(src, "aircraft anti spam"))
			balloon_alert(user,"No fuel left!")
			TIMER_COOLDOWN_START(src, "aircraft anti spam", 2 SECONDS)
	if(!canmove || !(user in return_drivers()))
		return FALSE
	vehicle_move(direction)

/obj/vehicle/sealed/aircraft/vehicle_move(direction)
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
	setDir(old_dir)	//Don't want aircraft to turn when moving

/obj/vehicle/sealed/aircraft/Bump(atom/A)
	. = ..()
	if(is_blocked_turf(A) && CHECK_BITFIELD(flags_pass, FLYING))	//Watch where you're flying!
		take_damage(FLYING_CRASH_DAMAGE)
		for(var/mob/M in occupants)
			shake_camera(M, 5, 3)
		playsound(A, 'sound/effects/metal_crash.ogg', 75, TRUE, 7)
		update_icon()

/obj/vehicle/sealed/aircraft/obj_break(damage_flag)
	playsound(src, 'sound/machines/beepalert.ogg', 100, FALSE, 7)
	balloon_alert_to_viewers("Severe damage taken!")

//BLACK HAWK GOING DOWN
/obj/vehicle/sealed/aircraft/obj_destruction(damage_amount, damage_type, damage_flag)
	being_destroyed = TRUE
	if(CHECK_BITFIELD(flags_pass, FLYING))
		playsound(src, 'sound/effects/alert.ogg', 100, FALSE, 7)
		animate(src, 5 SECONDS, pixel_z = 0)
		addtimer(CALLBACK(src, .proc/death_crash), 5 SECONDS)
	else
		explosion(src, 0, 0, 1, 1, 1, smoke = TRUE)	//Smaller explosion since it didn't crash into the ground
		return ..()

//Proc for convenience
/obj/vehicle/sealed/aircraft/proc/death_crash()
	explosion(src, 0, 1, 2, 2, 2, 1, smoke = TRUE)
	deconstruct(FALSE)

/* Action button related code below */
/obj/vehicle/sealed/aircraft/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/aircraft/exit)
	initialize_controller_action_type(/datum/action/vehicle/sealed/aircraft/engine, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/aircraft/spotlight, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/aircraft/change_weapon, VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/aircraft/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/aircraft))
		var/datum/action/vehicle/sealed/aircraft/holder = .
		holder.aircraft = src

/datum/action/vehicle/sealed/aircraft
	action_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/aircraft/aircraft

/datum/action/vehicle/sealed/aircraft/Destroy()
	aircraft = null
	return ..()

/datum/action/vehicle/sealed/aircraft/exit
	name = "Exit aircraft"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "71"

/datum/action/vehicle/sealed/aircraft/exit/action_activate()
	. = ..()
	if(!.)
		return FALSE
	aircraft.mob_try_exit(owner)

/datum/action/vehicle/sealed/aircraft/engine
	name = "Start aircraft Engine"
	action_icon_state = "mech_internals_off"

/datum/action/vehicle/sealed/aircraft/engine/action_activate()
	. = ..()
	if(!.)
		return FALSE
	aircraft.toggle_engine()
	update_button_icon()

/datum/action/vehicle/sealed/aircraft/engine/update_button_icon()
	if(CHECK_BITFIELD(aircraft.flags_pass, FLYING))
		name = "Shut Down aircraft Engine"
		action_icon_state = "mech_internals_on"
	else
		name = initial(name)
		action_icon_state = initial(action_icon_state)
	return ..()

/datum/action/vehicle/sealed/aircraft/spotlight
	name = "Turn On Spotlight"
	action_icon_state = "mech_lights_off"

//For when you enter and the lights are already on
/datum/action/vehicle/sealed/aircraft/spotlight/give_action(mob/M)
	. = ..()
	if(vehicle_entered_target.headlights_toggle)
		name = "Turn Off Spotlight"
		action_icon_state = "mech_lights_on"

/datum/action/vehicle/sealed/aircraft/spotlight/action_activate()
	. = ..()
	if(!.)
		return FALSE
	vehicle_entered_target.headlights_toggle = !vehicle_entered_target.headlights_toggle
	vehicle_entered_target.set_light_on(vehicle_entered_target.headlights_toggle)
	vehicle_entered_target.update_icon()
	playsound(owner, vehicle_entered_target.headlights_toggle ? 'sound/vehicles/magin.ogg' : 'sound/vehicles/magout.ogg', 25, FALSE, 5)
	if(vehicle_entered_target.headlights_toggle)
		name = "Turn Off Spotlight"
		action_icon_state = "mech_lights_on"
	else
		name = initial(name)
		action_icon_state = initial(action_icon_state)
	update_button_icon()

/datum/action/vehicle/sealed/aircraft/change_weapon
	name = "Change Weapon"
	action_icon_state = "mech_cycle_equip_off"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_CYCLE_WEAPON,
	)

/datum/action/vehicle/sealed/aircraft/change_weapon/action_activate()
	. = ..()
	if(!LAZYLEN(aircraft.attached_weapons))
		to_chat(owner, span_warning("No weapons attached!"))
		return FALSE
	///The position in the list the current weapon is at; used to cycle to the next weapon in the list, or loop back to the first
	var/position_in_list
	if(aircraft.current_weapon)
		position_in_list = aircraft.attached_weapons.Find(aircraft.current_weapon)
		owner.unset_interaction()
	else
		position_in_list = 0	//current_weapon was null, so the first gun in the list will be equipped
	//The new current_weapon becomes either the next one in the list, or deselects the current weapon
	aircraft.current_weapon = position_in_list < LAZYLEN(aircraft.attached_weapons) ? aircraft.attached_weapons[position_in_list + 1] : null
	if(aircraft.current_weapon)
		owner.set_interaction(aircraft)
	to_chat(owner, span_notice("Current weapon: [span_boldnotice("[aircraft.current_weapon ? "[aircraft.current_weapon.name]" : "NONE"]")]"))

/* Aircraft variants */
/obj/vehicle/sealed/aircraft/attack
	name = "\improper V-LRN attack VTOL"
	desc = "Ultralight aircraft with a single weapon attachment point."
	icon_state = "attack"
	max_integrity = 100
	soft_armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 0, FIRE = 10, ACID = 0)
	move_delay = 0.3 SECONDS
	weapon_slots = 1
	weapon_slot_positions = list(16, -4)
	offsets = list(-16, -24, -20, -20, -24, -16, -20, -12, -16, -8, -12, -12, -8, -16, -12, -20)
	exit_locations = list(WEST, EAST, NORTH)

/obj/vehicle/sealed/aircraft/transport
	name = "\improper ATT \"Beluga\""
	desc = "Heavily armored and designed to carry 4 passengers. \nAnd don't forget, this troop carrier is in the top 1% of all troop carriers out there!"
	icon_state = "transport"
	max_integrity = 250	//Beefy boi
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 20, FIRE = 40, ACID = 20)
	move_delay = 0.4 SECONDS
	turn_delay = 0.2 SECONDS
	max_occupants = 5
	max_fuel = 500
	offsets = list(-16, -20, -20, -20, -20, -16, -20, -12, -16, -12, -12, -12, -12, -16, -12, -20)
	exit_locations = list(SOUTH, WEST, EAST)

/obj/vehicle/sealed/aircraft/gunship
	name = "\improper Pelican gunship"	//Too on the nose?
	desc = "A flying tank. This bad boy features tough armor and 2 weapon mounts. However, it needs a separate pilot and gunner to operate."
	icon_state = "gunship"
	max_integrity = 200	//Also a beefy boi
	soft_armor = list(MELEE = 60, BULLET = 60, LASER = 60, ENERGY = 60, BOMB = 20, FIRE = 40, ACID = 20)
	move_delay = 0.5 SECONDS
	turn_delay = 0.3 SECONDS
	max_occupants = 2
	max_gunners = 1
	max_fuel = 400
	weapon_slots = 2
	weapon_slot_positions = list(8, -10, 24, -10)
	offsets = list(-16, -24, -24, -16, -24, -16, -24, -8, -16, -8, -8, -8, -8, -16, -8, -24)
	exit_locations = list(NORTH, EAST, WEST)

/* Aircraft weapons */
/obj/item/weapon/gun/aircraft
	name = "heli glock"
	desc = "Square up."
	icon = 'icons/obj/vehicles/aircraft_munitions.dmi'
	icon_state = ""
	reload_sound = 'sound/weapons/guns/interact/t42_unload.ogg'
	unload_sound = 'sound/weapons/guns/interact/t42_unload.ogg'
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_UNUSUAL_DESIGN
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE
	w_class = WEIGHT_CLASS_HUGE
	scatter = 0
	scatter_unwielded = 0

//Removing stuff not needed from the examine like safety text
/obj/item/weapon/gun/aircraft/examine(mob/user)
	var/examine_string = get_examine_string(user, thats = TRUE)
	if(examine_string)
		. = list("[examine_string].")
	else
		. = list()
	if(desc)
		. += desc
	if(user.can_use_codex() && SScodex.get_codex_entry(get_codex_value()))
		. += span_notice("The codex has <a href='?_src_=codex;show_examined_info=[REF(src)];show_to=[REF(user)]'>relevant information</a> available.")
	. += "[gender == PLURAL ? "They are" : "It is"] a [weight_class_to_text(w_class)] item."
	if(LAZYLEN(chamber_items))
		if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_MAGAZINES))
			. += "Ammo: <b>[rounds]/[max_rounds]</b>"
		else	//Don't have any current plans for non-mag based weapons yet, so just leaving it at this
			. += "It is loaded."
	else
		. += "It is empty."
	if(!.)	//Just to satisfy an error because it demands parent be called
		return ..()

//Overriding code so that it spawns /aircraft/ projectiles, which have special behaviors
/obj/item/weapon/gun/aircraft/get_ammo_object()
	var/datum/ammo/new_ammo = get_ammo()
	if(!new_ammo)
		return
	var/projectile_type = CHECK_BITFIELD(initial(new_ammo.flags_ammo_behavior), AMMO_HITSCAN) ? /obj/projectile/hitscan : CHECK_BITFIELD(gun_user?.flags_pass, FLYING) ? /obj/projectile/aircraft : /obj/projectile
	var/obj/projectile/aircraft/projectile = new projectile_type(null, initial(new_ammo.hitscan_effect_icon))
	projectile.generate_bullet(new_ammo)
	return projectile

//I think it looks more cinematic if the user always has the targeting reticule if they have a weapon attached
/obj/item/weapon/gun/aircraft/set_gun_user(mob/user)
	. = ..()
	gun_user?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

/obj/item/weapon/gun/aircraft/stop_fire()
	. = ..()
	gun_user?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

/obj/item/weapon/gun/aircraft/reset_fire()
	. = ..()
	gun_user?.client?.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'

/obj/item/weapon/gun/aircraft/reload(obj/item/new_mag, mob/living/user, force = TRUE)
	return ..()

//For some reason the calculation in get_angle_with_scatter() breaks aircraft mounted guns and makes them only able to fire northeast
//Tried to override the proc but it didn't do anything, so have to override do_fire() to use Get_Angle()
/obj/item/weapon/gun/aircraft/do_fire(obj/object_to_fire)
	var/firer = (istype(loc, /obj/machinery/deployable/mounted/sentry) && !gun_user) ? loc : gun_user
	var/obj/projectile/projectile_to_fire = object_to_fire
	if(CHECK_BITFIELD(reciever_flags, AMMO_RECIEVER_HANDFULS))
		projectile_to_fire = get_ammo_object()
	apply_gun_modifiers(projectile_to_fire, target, firer)
	setup_bullet_accuracy(projectile_to_fire, gun_user, shots_fired) //User can be passed as null.
	var/firing_angle = Get_Angle((gun_user || get_turf(src)), target)
	if(!isobj(projectile_to_fire))
		stack_trace("projectile malfunctioned while firing. User: [gun_user]")
		return
	play_fire_sound(loc)
	if(muzzle_flash && !muzzle_flash.applied)
		var/atom/movable/flash_loc = (master_gun || !istype(loc, /obj/machinery/deployable/mounted)) ? gun_user : loc
		var/prev_light = light_range
		if(!light_on && (light_range <= muzzle_flash_lum))
			set_light_range(muzzle_flash_lum)
			set_light_color(muzzle_flash_color)
			set_light_on(TRUE)
			addtimer(CALLBACK(src, .proc/reset_light_range, prev_light), 1 SECONDS)
		switch(firing_angle)
			if(0, 360)
				muzzle_flash.pixel_x = 0
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(1 to 44)
				muzzle_flash.pixel_x = round(4 * ((firing_angle) / 45))
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(45)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(46 to 89)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = round(4 * ((90 - firing_angle) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(90)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = 0
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(91 to 134)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = round(-3 * ((firing_angle - 90) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(135)
				muzzle_flash.pixel_x = 4
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(136 to 179)
				muzzle_flash.pixel_x = round(4 * ((180 - firing_angle) / 45))
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = ABOVE_MOB_LAYER
			if(180)
				muzzle_flash.pixel_x = 0
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = ABOVE_MOB_LAYER
			if(181 to 224)
				muzzle_flash.pixel_x = round(-3 * ((firing_angle - 180) / 45))
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = ABOVE_MOB_LAYER
			if(225)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = -3
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(226 to 269)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = round(-3 * ((270 - firing_angle) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(270)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = 0
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(271 to 314)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = round(4 * ((firing_angle - 270) / 45))
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(315)
				muzzle_flash.pixel_x = -3
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
			if(316 to 359)
				muzzle_flash.pixel_x = round(-3 * ((360 - firing_angle) / 45))
				muzzle_flash.pixel_y = 4
				muzzle_flash.layer = initial(muzzle_flash.layer)
		muzzle_flash.transform = null
		muzzle_flash.transform = turn(muzzle_flash.transform, firing_angle)
		flash_loc.vis_contents += muzzle_flash
		muzzle_flash.applied = TRUE
		addtimer(CALLBACK(src, .proc/remove_muzzle_flash, flash_loc, muzzle_flash), 0.2 SECONDS)
	simulate_recoil(dual_wield, firing_angle)
	projectile_to_fire.fire_at(target, master_gun ? gun_user : loc, src, projectile_to_fire.ammo.max_range, projectile_to_fire.projectile_speed, firing_angle, suppress_light = HAS_TRAIT(src, TRAIT_GUN_SILENCED))
	shots_fired++
	if(fire_animation) //Fires gun firing animation if it has any. ex: rotating barrel
		flick("[fire_animation]", src)
	return TRUE

/obj/item/weapon/gun/aircraft/minigun
	name = "\improper BZ-22 minigun"
	desc = "Classic minigun with some modifications done by the TerraGov Air Corp. This aircraft-mounted assembly features lots of space for stored ammunition."
	icon_state = "minigun"
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	fire_delay = 1.5
	max_rounds = 300
	default_ammo_type = /obj/item/ammo_magazine/aircraft/minigun
	allowed_ammo_types = list(/obj/item/ammo_magazine/aircraft/minigun)
	fire_sound = 'sound/weapons/guns/fire/minigun.ogg'

/obj/item/weapon/gun/aircraft/cannon
	name = "\improper GAN-36 cannon"
	desc = "Slow-firing, heavy cannon. Can turn a man into mush."
	icon_state = "cannon"
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	fire_delay = 0.6 SECONDS
	max_rounds = 100
	default_ammo_type = /obj/item/ammo_magazine/aircraft/cannon
	allowed_ammo_types = list(/obj/item/ammo_magazine/aircraft/cannon)
	fire_sound = 'sound/weapons/guns/fire/autocannon_fire.ogg'

/obj/item/weapon/gun/aircraft/predator
	name = "\improper Predator missile pod"	//For the AvP and CoD fans out there
	desc = "Low-capacity missile pod for the lethal Predator."
	icon_state = "predator"
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_UNUSUAL_DESIGN|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	fire_delay = 4 SECONDS
	max_rounds = 4
	default_ammo_type = /obj/item/ammo_magazine/rocket/aircraft/predator
	allowed_ammo_types = list(/obj/item/ammo_magazine/rocket/aircraft/predator)
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'

/obj/item/weapon/gun/aircraft/swarm
	name = "\improper Swarm missile launcher"	//For the Starsector fans
	desc = "Small and quick, Swarm rockets are designed for saturation bombing rather than precision lethality. Fires in bursts of 3."
	icon_state = "swarm"
	flags_gun_features = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_UNUSUAL_DESIGN|GUN_NO_PITCH_SHIFT_NEAR_EMPTY
	gun_firemode = GUN_FIREMODE_AUTOBURST
	gun_firemode_list = list(GUN_FIREMODE_AUTOBURST)
	fire_delay = 3 SECONDS
	burst_delay = 2
	burst_amount = 3
	max_rounds = 36	//12 bursts
	default_ammo_type = /obj/item/ammo_magazine/rocket/aircraft/swarm
	allowed_ammo_types = list(/obj/item/ammo_magazine/rocket/aircraft/swarm)
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'

/* Aircraft weapon magazines */
/obj/item/ammo_magazine/aircraft
	name = "generic aircraft magazine box"
	desc = "Standard issue."
	icon = 'icons/obj/vehicles/aircraft_munitions.dmi'
	icon_state = ""
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = null
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER|MAGAZINE_REFILLABLE

/obj/item/ammo_magazine/aircraft/minigun
	name = "\improper BZ-22 ammunition case"
	desc = "A large case containing of ammo that can be slotted into the BZ-22 minigun assembly."
	icon_state = "minigun_box"
	max_rounds = 300
	default_ammo = /datum/ammo/bullet/aircraft_minigun

/obj/item/ammo_magazine/aircraft/cannon
	name = "\improper GAN-36 cannon ammunition case"
	desc = "A heavy container for the large GAN-36 cannon rounds."
	icon_state = "cannon_box"
	max_rounds = 100
	default_ammo = /datum/ammo/bullet/aircraft_cannon

/obj/item/ammo_magazine/rocket/aircraft
	name = "generic aircraft missile rack"
	desc = "Standard issue."
	icon = 'icons/obj/vehicles/aircraft_munitions.dmi'
	icon_state = ""
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = null
	flags_magazine = MAGAZINE_REFUND_IN_CHAMBER|MAGAZINE_REFILLABLE
	reload_delay = 0

/obj/item/ammo_magazine/rocket/aircraft/predator
	name = "\improper Predator missile rack"
	desc = "Handy assembly for easy loading of Predator missiles."
	icon_state = "predator_rack"
	max_rounds = 4
	default_ammo = /datum/ammo/rocket/predator

/obj/item/ammo_magazine/rocket/aircraft/swarm
	name = "\improper Swarm rocket case"
	desc = "Houses the small swarm rockets in neat little rows."
	icon_state = "swarm_rack"
	max_rounds = 36
	default_ammo = /datum/ammo/rocket/swarm

//Better to run it on a child than on every single bullet in the game
/obj/projectile/aircraft/scan_a_turf(turf/turf_to_scan, cardinal_move)
	if(CHECK_BITFIELD(shot_from.flags_pass, FLYING) && turf_to_scan != original_target_turf)	//Do nothing if it's not the turf the pilot clicked on when firing
		return FALSE
	. = ..()
	if(!.)	//If nothing is eligible to be hit, just impact the ground
		ammo.on_hit_turf(turf_to_scan, src)
		turf_to_scan.bullet_act(src)
		return TRUE

/particles/aircraft_smoke_light
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 200
	count = 1000
	spawning = 0.5
	lifespan = 2 SECONDS
	fade = 1 SECONDS
	fadein = 0.5 SECONDS
	scale = 0.25
	grow = 0.1
	drift = generator(GEN_SPHERE, 0, 1, NORMAL_RAND)
	friction = 0.5
	gravity = list(0, 2)

/particles/aircraft_smoke_heavy
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	color = "#303030"
	width = 100
	height = 100
	count = 1000
	spawning = 5
	lifespan = 8
	fade = 5
	fadein = 3
	grow = -0.01
	position = generator(GEN_BOX, list(-12, -12), list(12, 12),  NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, 1.5)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(0.9,0.9), NORMAL_RAND)
	spin = generator(GEN_NUM, -10, 10)
	friction = 0.3
