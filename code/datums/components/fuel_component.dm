/*!
 * Component for making something capable of tactical reload via right click.
 */

// HEY, LISTEN. This component pre-dates the storage refactor so it may not be up to standards.
// I would love it if someone were to go ahead and give this a look for me, otherwise I'll get to it eventually... maybe

/datum/component/fuel_storage
	var/datum/reagents/fuel_tank

/datum/component/fuel_storage/Initialize(_max_fuel)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/obj_parent = parent
	if(obj_parent.reagents)
		return COMPONENT_INCOMPATIBLE

	obj_parent.create_reagents(_max_fuel, init_reagents = list(/datum/reagent/fuel = _max_fuel))
	fuel_tank = obj_parent.reagents

/datum/component/fuel_storage/Destroy(force, silent)
	fuel_tank = null
	QDEL_NULL(fuel_tank)
	return ..()

/datum/component/fuel_storage/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/fuel_storage/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_ATOM_EXAMINE,
	))

/obj/item/proc/do_refuel(atom/refueler, mob/user)
	if(reagents?.total_volume == reagents?.maximum_volume)
		return FALSE
	refueler.reagents.trans_to(src, reagents.maximum_volume)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("[src] refilled!"))
	return TRUE

/obj/item/tool/weldingtool/do_refuel(atom/refueler, mob/user)
	if(welding)
		to_chat(user, span_warning("That was close! However you realized you had the welder on and prevented disaster."))
		return FALSE
	return ..()

/obj/item/ammo_magazine/flamer_tank/do_refuel(atom/refueler, mob/user)
	if(default_ammo != /datum/ammo/flamethrower)
		to_chat(user, span_warning("Not the right kind of fuel!"))
		return FALSE
	if(current_rounds == max_rounds)
		return FALSE

	var/fuel_transfer_amount = min(refueler.reagents.total_volume, (max_rounds - current_rounds))
	refueler.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
	current_rounds += fuel_transfer_amount
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	caliber = CALIBER_FUEL
	to_chat(user, span_notice("You refill [src] with [lowertext(caliber)]."))
	update_appearance(UPDATE_ICON)


//if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACKBY, attacking_item, user, params) & COMPONENT_NO_AFTERATTACK)
/datum/component/fuel_storage/proc/on_attackby(obj/item/source, obj/item/attacking, mob/user, params)
	SIGNAL_HANDLER
	//todo: stop this sig from causing storing of attacking
	if(!fuel_tank.total_volume)
		return
	attacking.do_refuel(parent, user)
	return COMPONENT_NO_AFTERATTACK

//SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, has_proximity, click_parameters)
/datum/component/fuel_storage/proc/on_afterattack(obj/item/source, atom/target, mob/user, proximity, click_params)
	SIGNAL_HANDLER
	if(!proximity)
		return
	if(fuel_tank.total_volume >= fuel_tank.maximum_volume)
		user?.balloon_alert(user, "already full!")
		return
	if(!istype(target, /obj/structure/reagent_dispensers/fueltank))
		return
	if(target.reagents.get_reagent_amount(/datum/reagent/fuel) != target.reagents.total_volume)
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
