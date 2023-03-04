/**
 * ## Savannah-Ivanov!
 *
 * A two person mecha that delegates moving to the driver and shooting to the pilot.
 * ...Hilarious, right?
 */
/obj/vehicle/sealed/mecha/combat/savannah_ivanov
	name = "\improper Savannah-Ivanov"
	desc = "An insanely overbulked mecha that handily crushes single-pilot opponents. The price is that you need two pilots to use it."
	icon = 'icons/mecha/coop_mech.dmi'
	base_icon_state = "savannah_ivanov"
	icon_state = "savannah_ivanov_0_0"
	//does not include mmi compatibility
	mecha_flags = ADDING_ACCESS_POSSIBLE | CANSTRAFE | IS_ENCLOSED | HAS_HEADLIGHTS
	mech_type = EXOSUIT_MODULE_SAVANNAH
	move_delay = 3
	max_integrity = 450 //really tanky, like damn
	soft_armor = list(MELEE = 45, BULLET = 40, LASER = 30, ENERGY = 30, BOMB = 40, BIO = 0, FIRE = 100, ACID = 100)
	max_temperature = 30000
	wreckage = /obj/structure/mecha_wreckage/savannah_ivanov
	max_occupants = 2
	max_equip_by_category = list(
		MECHA_UTILITY = 1,
		MECHA_POWER = 1,
		MECHA_ARMOR = 3,
	)
	//no tax on flying, since the power cost is in the leap itself.
	phasing_energy_drain = 0

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/get_mecha_occupancy_state()
	var/driver_present = driver_amount() != 0
	var/gunner_present = return_amount_of_controllers_with_flag(VEHICLE_CONTROL_EQUIPMENT) > 0
	var/list/mob/drivers = return_drivers()
	var/leap_state
	if(length(drivers))
		var/datum/action/vehicle/sealed/mecha/skyfall/action = LAZYACCESSASSOC(occupant_actions, drivers[1], /datum/action/vehicle/sealed/mecha/skyfall)
		leap_state = action.skyfall_charge_level > 2 ? "leap_" : ""
	return "[base_icon_state]_[leap_state][gunner_present]_[driver_present]"

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/auto_assign_occupant_flags(mob/new_occupant)
	if(driver_amount() < max_drivers) //movement
		add_control_flags(new_occupant, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	else //weapons
		add_control_flags(new_occupant, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)

/obj/vehicle/sealed/mecha/combat/savannah_ivanov/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/swap_seat)
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/skyfall, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/mecha/ivanov_strike, VEHICLE_CONTROL_EQUIPMENT)
