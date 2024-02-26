/**
 *TANK MODULES
 *
 * Attached to the tank and provide abilities/ passive upgrades
 */
/obj/item/tank_module
	name = "Tank Module"
	desc = "Yell at the admin that spawned this in please."
	icon = 'icons/obj/armored/hardpoint_modules.dmi'
	icon_state = "ltb_cannon"
	///reference to current overlay added to owner
	var/image/overlay
	///vehicle this overlay is attached to
	var/obj/vehicle/sealed/armored/owner
	///Bool whether this module is a driver module or not
	var/is_driver_module = TRUE

///Called to apply modules to a vehicle
/obj/item/tank_module/proc/on_equip(obj/vehicle/sealed/armored/vehicle, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(vehicle))
		return FALSE
	var/slot = is_driver_module ? vehicle.driver_utility_module : vehicle.gunner_utility_module
	if(slot)
		user?.balloon_alert(user, "module slot full")
		return FALSE
	user?.temporarilyRemoveItemFromInventory(src)
	forceMove(vehicle)
	if(is_driver_module)
		vehicle.driver_utility_module = src
	else
		vehicle.gunner_utility_module = src
	if(!vehicle.turret_overlay)
		overlay = image(vehicle.icon, null, icon_state)
		vehicle.add_overlay(overlay)
	else
		overlay = image(vehicle.turret_overlay.icon, null, icon_state)
		vehicle.turret_overlay.add_overlay(overlay)
	owner = vehicle
	return TRUE

///called to remove this module from its vehicle
/obj/item/tank_module/proc/on_unequip(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(owner.driver_utility_module == src)
		owner.driver_utility_module = null
	else
		owner.gunner_utility_module = null
	forceMove(owner.drop_location())
	owner.cut_overlay(overlay)
	owner.turret_overlay?.cut_overlay(overlay)
	owner = null
	overlay = null
	user?.put_in_hands(src)
	return TRUE

/obj/item/tank_module/Destroy()
	if(owner)
		on_unequip()
	return ..()


/obj/item/tank_module/overdrive
	name = "overdrive module"
	desc = "A module that enhances the speed of armored combat vehicles by increasing fuel efficiency."
	icon_state = "overdrive"

/obj/item/tank_module/overdrive/on_equip(target)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/armored/vehicle = target
	vehicle.move_delay -= 0.15 SECONDS

/obj/item/tank_module/overdrive/on_unequip()
	owner.move_delay += 0.15 SECONDS
	return ..()

/obj/item/tank_module/passenger
	name = "passenger module"
	desc = "A module that increases the carrying capacity of a vehicle with extra seats."
	icon_state = "uninstalled APC frieght carriage"

/obj/item/tank_module/passenger/on_equip(target)
	. = ..()
	if(!.)
		return
	var/obj/vehicle/sealed/armored/vehicle = target
	vehicle.max_occupants += 4

/obj/item/tank_module/passenger/on_unequip(target)
	owner.max_occupants -= 4
	return ..()


/obj/item/tank_module/ability
	name = "Ability Module"
	desc = "You shouldnt be seeing this."
	icon_state = "overdrive"
	///typepaths for the ability we want to grant
	var/ability_to_grant
	///if given, a single flag of who we want this ability to be granted to
	var/flag_controller = NONE

/obj/item/tank_module/ability/on_equip(obj/vehicle/sealed/armored/vehicle, attach_right)
	. = ..()
	if(!.)
		return
	if(flag_controller)
		vehicle.initialize_controller_action_type(ability_to_grant, flag_controller)
	else
		vehicle.initialize_passenger_action_type(ability_to_grant)

/obj/item/tank_module/ability/on_unequip(atom/moveto)
	if(flag_controller)
		owner.destroy_controller_action_type(ability_to_grant, flag_controller)
	else
		owner.destroy_passenger_action_type(ability_to_grant)
	return ..()

/obj/item/tank_module/ability/zoom
	name = "zoom module"
	desc = "Allows gunners to see further while looking through it. Weapons cannot be used while looking through it."
	icon_state = "zoom"
	is_driver_module = FALSE
	flag_controller = VEHICLE_CONTROL_EQUIPMENT
	ability_to_grant = /datum/action/vehicle/sealed/armored/zoom
