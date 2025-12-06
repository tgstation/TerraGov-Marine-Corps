/*!
 * Component for fuel storage objects
 */

/datum/component/fuel_storage
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///ref to parents reagents
	var/datum/reagents/fuel_tank
	///The specific fueltype we use
	var/fuel_type

/datum/component/fuel_storage/Initialize(_max_fuel, _fuel_type = DEFAULT_FUEL_TYPE)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/obj_parent = parent
	if(obj_parent.reagents)
		return COMPONENT_INCOMPATIBLE

	fuel_type = _fuel_type
	var/list/reagent_list = list()
	reagent_list[fuel_type] = _max_fuel
	obj_parent.create_reagents(_max_fuel, init_reagents = reagent_list)
	fuel_tank = obj_parent.reagents

/datum/component/fuel_storage/Destroy(force, silent)
	QDEL_NULL(fuel_tank)
	return ..()

/datum/component/fuel_storage/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_ATOM_ATTACKBY, COMSIG_MOUSEDROPPED_ONTO), PROC_REF(attempt_refuel))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_OBJ_GET_FUELTYPE, PROC_REF(return_fueltype))

/datum/component/fuel_storage/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_OBJ_GET_FUELTYPE,
	))

///Returns the fueltype parent will accept
/datum/component/fuel_storage/proc/return_fueltype(obj/source, list/return_list)
	SIGNAL_HANDLER
	return_list += fuel_type

///Attempts to refuel something
/datum/component/fuel_storage/proc/attempt_refuel(obj/source, obj/item/attacking, mob/user)
	SIGNAL_HANDLER
	if(user.a_intent == INTENT_HARM)
		return
	if(!attacking.is_refuelable())
		return
	attacking.try_refuel(parent, fuel_type, user)
	return COMPONENT_NO_AFTERATTACK

///Shows remaining fuel on examine
/datum/component/fuel_storage/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("[fuel_tank.total_volume] units of fuel left!")


///Returns the fueltype that this obj uses
/obj/proc/get_fueltype()
	var/list/return_list = list()
	SEND_SIGNAL(src, COMSIG_OBJ_GET_FUELTYPE, return_list)
	if(length(return_list))
		return return_list[1]
	return DEFAULT_FUEL_TYPE

///Returns true if this can be refueled by the fuel component
/obj/proc/is_refuelable()
	return reagents

/obj/item/ammo_magazine/flamer_tank/is_refuelable()
	return TRUE

///Attempts to refuel src from a reagent container
/obj/proc/try_refuel(atom/refueler, fuel_type, mob/user)
	if(!can_refuel(refueler, fuel_type, user))
		return FALSE
	do_refuel(refueler, fuel_type, user)
	return TRUE

///Checks if src can be refueled by a container
/obj/proc/can_refuel(atom/refueler, fuel_type, mob/user)
	if(!refueler.reagents.total_volume)
		user?.balloon_alert(user, "no fuel!")
		return
	if(fuel_type != get_fueltype())
		user?.balloon_alert(user, "wrong fuel")
		return FALSE
	if(reagents.total_volume == reagents.maximum_volume)
		user?.balloon_alert(user, "full")
		return FALSE
	return TRUE

///Actually refills src with fuel from a container
/obj/proc/do_refuel(atom/refueler, fuel_type, mob/user)
	refueler.reagents.trans_to(src, reagents.maximum_volume)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	user?.balloon_alert(user, "refilled")
