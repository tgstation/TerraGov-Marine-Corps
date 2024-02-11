/**
 *TANK MODULES
 *
 * Attached to the tank and provide abilities/ passive upgrades
 */
/obj/item/tank_module
	name = "Tank Module"
	desc = "Yell at the admin that spawned this in please."
	icon = 'icons/obj/vehicles/hardpoint_modules.dmi'
	icon_state = "ltb_cannon"
	var/image/overlay
	var/obj/vehicle/sealed/armored/owner

///Called to apply modules to a vehicle
/obj/item/tank_module/proc/on_equip(obj/vehicle/sealed/armored/vehicle)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(vehicle))
		return FALSE
	if(vehicle.utility_module)
		return FALSE
	vehicle.utility_module = src
	overlay = image(vehicle.icon, null, icon_state)
	vehicle.add_overlay(overlay)
	return TRUE

///called to remove this module from its vehicle
/obj/item/tank_module/proc/on_unequip()
	SHOULD_CALL_PARENT(TRUE)
	owner.utility_module = null
	owner.cut_overlay(overlay)
	overlay = null
	return TRUE

/obj/item/tank_module/Destroy()
	if(owner)
		on_unequip()
	return ..()


/obj/item/tank_module/overdrive
	name = "Overdrive Module"
	desc = "A module that enhances the speed of armored combat vehicles by increasing fuel efficiency."
	icon_state = "odrive_enhancer"

/obj/item/tank_module/overdrive/on_equip(target)
	. = ..()
	var/obj/vehicle/sealed/armored/vehicle = target
	vehicle.move_delay -= 0.15 SECONDS

/obj/item/tank_module/overdrive/on_unequip()
	owner.move_delay += 0.15 SECONDS
	return ..()

/obj/item/tank_module/passenger
	name = "Passenger Module"
	desc = "A module that increases the carrying capacity of a vehicle with extra seats."
	icon_state = "uninstalled APC frieght carriage"

/obj/item/tank_module/passenger/on_equip(target)
	. = ..()
	var/obj/vehicle/sealed/armored/vehicle = target
	vehicle.max_occupants += 4

/obj/item/tank_module/passenger/on_unequip(target)
	owner.max_occupants -= 4
	return ..()
