/*!
 * Component for fuel storage objects
 */

/datum/component/fuel_storage
	var/datum/reagents/fuel_tank

	var/fuel_type

/datum/component/fuel_storage/Initialize(_max_fuel, _fuel_type = DEFAULT_FUEL_TYPE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/obj_parent = parent
	if(obj_parent.reagents)
		return COMPONENT_INCOMPATIBLE

	fuel_type = _fuel_type
	var/list/test = list(fuel_type)
	test[fuel_type] = _max_fuel
	obj_parent.create_reagents(_max_fuel, init_reagents = test)
	fuel_tank = obj_parent.reagents

/datum/component/fuel_storage/Destroy(force, silent)
	fuel_tank = null
	QDEL_NULL(fuel_tank)
	return ..()

/datum/component/fuel_storage/RegisterWithParent()
	RegisterSignals(parent, list(COMSIG_ATOM_ATTACKBY, COMSIG_MOUSEDROPPED_ONTO), PROC_REF(attempt_refuel))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_OBJ_GET_FUELTYPE, PROC_REF(return_fueltype))

/datum/component/fuel_storage/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_ATOM_EXAMINE,
		COMSIG_OBJ_GET_FUELTYPE,
	))

/obj/item/proc/get_fueltype()
	var/list/return_list = list()
	SEND_SIGNAL(src, COMSIG_OBJ_GET_FUELTYPE, return_list)
	if(length(return_list))
		return return_list[1]
	return DEFAULT_FUEL_TYPE

/obj/item/ammo_magazine/flamer_tank/get_fueltype()
	return fuel_type

/obj/item/proc/do_refuel(atom/refueler, fuel_type, mob/user)
	if(reagents?.total_volume == reagents?.maximum_volume)
		return FALSE
	if(fuel_type != get_fueltype()) //should this be in the component proc?
		return FALSE

	refueler.reagents.trans_to(src, reagents.maximum_volume)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("[src] refilled!"))
	return TRUE

/obj/item/tool/weldingtool/do_refuel(atom/refueler, fuel_type, mob/user)
	if(welding)
		to_chat(user, span_warning("That was close! However you realized you had the welder on and prevented disaster."))
		return FALSE
	return ..()

/obj/item/ammo_magazine/flamer_tank/do_refuel(atom/refueler, fuel_type, mob/user)
	if(fuel_type != get_fueltype())
		to_chat(user, span_warning("Not the right kind of fuel!"))
		return FALSE
	if(current_rounds == max_rounds)
		return FALSE

	var/fuel_transfer_amount = min(refueler.reagents.total_volume, (max_rounds - current_rounds))
	refueler.reagents.remove_reagent(fuel_type, fuel_transfer_amount)
	current_rounds += fuel_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	caliber = CALIBER_FUEL
	to_chat(user, span_notice("You refill [src] with [lowertext(caliber)]."))
	update_appearance(UPDATE_ICON)

/datum/component/fuel_storage/proc/return_fueltype(obj/source, list/return_list)
	SIGNAL_HANDLER
	return_list += fuel_type

/datum/component/fuel_storage/proc/attempt_refuel(obj/item/source, obj/item/attacking, mob/user)
	SIGNAL_HANDLER
	//todo: stop this sig from causing storing of attacking
	if(!fuel_tank.total_volume)
		user?.balloon_alert(user, "no fuel!")
		return
	attacking.do_refuel(parent, fuel_type, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/fuel_storage/proc/on_afterattack(obj/item/source, atom/target, mob/user, proximity, click_params)
	SIGNAL_HANDLER
	if(!proximity)
		return
	if(fuel_tank.total_volume >= fuel_tank.maximum_volume)
		user?.balloon_alert(user, "already full!")
		return
	if(!istype(target, /obj/structure/reagent_dispensers/fueltank))
		return
	if(target.reagents.get_reagent_amount(fuel_type) != target.reagents.total_volume)
		user?.balloon_alert(user, "wrong fuel!")
		return

	target.reagents.trans_to(source, fuel_tank.maximum_volume)
	to_chat(user, span_notice("You crack the cap off the top of the pack and fill it back up again from the tank."))
	playsound(source.loc, 'sound/effects/refill.ogg', 25, 1, 3)
	return

///Shows remaining fuel on examine
/datum/component/fuel_storage/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("[fuel_tank.total_volume] units of fuel left!")
