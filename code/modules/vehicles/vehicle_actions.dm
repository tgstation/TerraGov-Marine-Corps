//VEHICLE DEFAULT HANDLING

/**
 * ## generate_actions
 *
 * You override this with initialize_passenger_action_type and initialize_controller_action_type calls
 * To give passengers actions when they enter the vehicle.
 * Read the documentation on the aforementioned procs to learn the difference
 */
/obj/vehicle/proc/generate_actions()
	return

/**
 * ## generate_action_type
 *
 * A small proc to properly set up each action path.
 * args:
 * * actiontype: typepath of the action the proc sets up.
 * returns created and set up action instance
 */
/obj/vehicle/proc/generate_action_type(actiontype)
	var/datum/action/vehicle/A = new actiontype
	if(!istype(A))
		return
	A.vehicle_target = src
	return A

/**
 * ## initialize_passenger_action_type
 *
 * Gives any passenger that enters the mech this action.
 * They will lose it when they disembark.
 * args:
 * * actiontype: typepath of the action you want to give occupants.
 */
/obj/vehicle/proc/initialize_passenger_action_type(actiontype)
	autogrant_actions_passenger += actiontype
	for(var/i in occupants)
		grant_passenger_actions(i) //refresh

/**
 * ## initialize_controller_action_type
 *
 * Gives any passenger that enters the mech this action... IF they have the correct vehicle control flag.
 * This is used so passengers cannot press buttons only drivers should have, for example.
 * args:
 * * actiontype: typepath of the action you want to give occupants.
 */
/obj/vehicle/proc/initialize_controller_action_type(actiontype, control_flag)
	LAZYINITLIST(autogrant_actions_controller["[control_flag]"])
	autogrant_actions_controller["[control_flag]"] += actiontype
	for(var/i in occupants)
		grant_controller_actions(i) //refresh

/**
 * ## grant_action_type_to_mob
 *
 * As on the tin, it does all the annoying small stuff and sanity needed
 * to GRANT an action to a mob.
 * args:
 * * actiontype: typepath of the action you want to give to grant_to.
 * * grant_to: the mob we're giving actiontype to
 * returns TRUE if successfully granted
 */
/obj/vehicle/proc/grant_action_type_to_mob(actiontype, mob/grant_to)
	if(isnull(LAZYACCESS(occupants, grant_to)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[grant_to])
	if(occupant_actions[grant_to][actiontype])
		return TRUE
	var/datum/action/action = generate_action_type(actiontype)
	action.give_action(grant_to)
	occupant_actions[grant_to][action.type] = action
	return TRUE

/**
 * ## remove_action_type_from_mob
 *
 * As on the tin, it does all the annoying small stuff and sanity needed
 * to REMOVE an action to a mob.
 * args:
 * * actiontype: typepath of the action you want to give to grant_to.
 * * take_from: the mob we're taking actiontype to
 * returns TRUE if successfully removed
 */
/obj/vehicle/proc/remove_action_type_from_mob(actiontype, mob/take_from)
	if(isnull(LAZYACCESS(occupants, take_from)) || !actiontype)
		return FALSE
	LAZYINITLIST(occupant_actions[take_from])
	if(occupant_actions[take_from][actiontype])
		var/datum/action/action = occupant_actions[take_from][actiontype]
		action.remove_action(take_from)
		occupant_actions[take_from] -= actiontype
	return TRUE

/**
 * ## grant_passenger_actions
 *
 * Called on every passenger that enters the vehicle, goes through the list of actions it needs to give...
 * and does that.
 * args:
 * * grant_to: mob that needs to get every action the vehicle grants
 */
/obj/vehicle/proc/grant_passenger_actions(mob/grant_to)
	for(var/v in autogrant_actions_passenger)
		grant_action_type_to_mob(v, grant_to)

/**
 * ## remove_passenger_actions
 *
 * Called on every passenger that exits the vehicle, goes through the list of actions it needs to remove...
 * and does that.
 * args:
 * * take_from: mob that needs to get every action the vehicle grants
 */
/obj/vehicle/proc/remove_passenger_actions(mob/take_from)
	for(var/v in autogrant_actions_passenger)
		remove_action_type_from_mob(v, take_from)

/obj/vehicle/proc/grant_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		if(occupants[M] & i)
			grant_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/remove_controller_actions(mob/M)
	if(!istype(M) || isnull(LAZYACCESS(occupants, M)))
		return FALSE
	for(var/i in GLOB.bitflags)
		remove_controller_actions_by_flag(M, i)
	return TRUE

/obj/vehicle/proc/grant_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		grant_action_type_to_mob(v, M)
	return TRUE

/obj/vehicle/proc/remove_controller_actions_by_flag(mob/M, flag)
	if(!istype(M))
		return FALSE
	for(var/v in autogrant_actions_controller["[flag]"])
		remove_action_type_from_mob(v, M)
	return TRUE

/obj/vehicle/proc/cleanup_actions_for_mob(mob/M)
	if(!istype(M))
		return FALSE
	for(var/path in occupant_actions[M])
		stack_trace("Leftover action type [path] in vehicle type [type] for mob type [M.type] - THIS SHOULD NOT BE HAPPENING!")
		var/datum/action/action = occupant_actions[M][path]
		action.remove_action(M)
		occupant_actions[M] -= path
	occupant_actions -= M
	return TRUE

/***************** ACTION DATUMS *****************/

/datum/action/vehicle
	action_icon = 'icons/mob/actions/actions_vehicle.dmi'
	action_icon_state = "vehicle_eject"
	var/obj/vehicle/vehicle_target

/datum/action/vehicle/action_activate()
	if(HAS_TRAIT(owner, TRAIT_IMMOBILE))
		return FALSE
	if(!owner.stat)
		return FALSE
	return ..()


/datum/action/vehicle/sealed
	var/obj/vehicle/sealed/vehicle_entered_target

/datum/action/vehicle/sealed/climb_out
	name = "Climb Out"
	desc = "Climb out of your vehicle!"
	action_icon_state = "car_eject"

/datum/action/vehicle/sealed/climb_out/action_activate()
	if(..() && istype(vehicle_entered_target))
		vehicle_entered_target.mob_try_exit(owner, owner)

/datum/action/vehicle/ridden
	var/obj/vehicle/ridden/vehicle_ridden_target

/datum/action/vehicle/sealed/remove_key
	name = "Remove key"
	desc = "Take your key out of the vehicle's ignition."
	action_icon_state = "car_removekey"

/datum/action/vehicle/sealed/remove_key/action_activate()
	. = ..()
	vehicle_entered_target.remove_key(owner)

/datum/action/vehicle/sealed/horn
	name = "Honk Horn"
	desc = "Honk your classy horn."
	action_icon_state = "car_horn"
	///sound file to play
	var/hornsound = 'sound/mecha/fog_horn.ogg'

/datum/action/vehicle/sealed/horn/action_activate(trigger_flags)
	. = ..()
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CAR_HONK))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_CAR_HONK, 10 SECONDS)
	vehicle_target.balloon_alert(owner, "Honks horn")
	vehicle_entered_target.visible_message(span_danger("[vehicle_entered_target] honks it's horn!"))
	if(istype(vehicle_target.inserted_key, /obj/item/toy/bikehorn))
		vehicle_target.inserted_key.attack_self(owner) //The bikehorn plays a sound instead
		return
	playsound(vehicle_entered_target, hornsound, 75)

/datum/action/vehicle/sealed/headlights
	name = "Toggle Headlights"
	desc = "Turn on your brights!"
	action_icon_state = "car_headlights"

/datum/action/vehicle/sealed/headlights/action_activate()
	. = ..()
	to_chat(owner, span_notice("You flip the switch for the vehicle's headlights."))
	vehicle_entered_target.headlights_toggle = !vehicle_entered_target.headlights_toggle
	vehicle_entered_target.set_light_on(vehicle_entered_target.headlights_toggle)
	vehicle_entered_target.update_icon()
	playsound(owner, vehicle_entered_target.headlights_toggle ? 'sound/vehicles/magin.ogg' : 'sound/vehicles/magout.ogg', 40, TRUE)
