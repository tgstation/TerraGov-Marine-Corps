///This component allows gun mounting on vehicle types
/datum/component/vehicle_mounted_weapon
	///The gun mounted on a vehicle
	var/obj/item/weapon/gun/mounted_gun

/datum/component/vehicle_mounted_weapon/Initialize(gun_type)
	. = ..()
	if(!istype(parent, /obj/vehicle))
		return COMPONENT_INCOMPATIBLE
	if(!(gun_type in subtypesof(/obj/item/weapon/gun)))
		return COMPONENT_INCOMPATIBLE
	mounted_gun = new gun_type(parent)
	//NODROP so that you can't just drop the gun or have someone take it off your hands
	ADD_TRAIT(mounted_gun, TRAIT_NODROP, MOUNTED_TRAIT)

/datum/component/vehicle_mounted_weapon/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, PROC_REF(on_buckle))
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, PROC_REF(on_unbuckle))
	RegisterSignal(parent, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mounted_gun, COMSIG_ITEM_DROPPED, PROC_REF(on_weapon_drop))

/datum/component/vehicle_mounted_weapon/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE,
	COMSIG_MOVABLE_UNBUCKLE,
	COMSIG_MOUSEDROP_ONTO,
	COMSIG_ATOM_ATTACKBY,
	COMSIG_ATOM_EXAMINE,
	COMSIG_ATOM_ATTACK_HAND,
	))
	QDEL_NULL(mounted_gun)
	return ..()

///Behaviour on buckle. Puts the gun in the buckled mob's hands.
/datum/component/vehicle_mounted_weapon/proc/on_buckle(datum/source, mob/living/buckling_mob, force = FALSE, check_loc = TRUE, lying_buckle = FALSE, hands_needed = 0, target_hands_needed = 0, silent)
	SIGNAL_HANDLER
	var/obj/vehicle/parent_vehicle = source
	if(!parent_vehicle.is_equipment_controller(buckling_mob))	
		return
	if(!buckling_mob.put_in_active_hand(mounted_gun) && !buckling_mob.put_in_inactive_hand(mounted_gun))
		to_chat(buckling_mob, span_warning("Could not equip weapon! Click [parent] with a free hand to equip."))
		return

///Behaviour on unbuckle. Force drops the gun from the unbuckled mob's hands.
/datum/component/vehicle_mounted_weapon/proc/on_unbuckle(datum/source, mob/living/unbuckled_mob, force = FALSE)
	SIGNAL_HANDLER
	unbuckled_mob.dropItemToGround(mounted_gun, TRUE)

///Behaviour on mouse drop. If the user has clickdragged the chair to themselves they will unload it.
/datum/component/vehicle_mounted_weapon/proc/on_mousedrop(datum/source, atom/over, mob/user)
	SIGNAL_HANDLER
	if(!isliving(user) || over != usr || !in_range(source, user))
		return

	mounted_gun.unload(user)

///Behaviour on attackby. When a user clicks the wheelchair with an ammo magazine they reload the mounted weapon.
/datum/component/vehicle_mounted_weapon/proc/on_attackby(datum/source, obj/item/I, mob/user, params)
	SIGNAL_HANDLER
	if(isammomagazine(I))
		INVOKE_ASYNC(mounted_gun, TYPE_PROC_REF(/obj/item/weapon/gun, reload), I, user)
		return COMPONENT_NO_AFTERATTACK

///Behaviour on attack hand. Puts the gun in the user's hands if they're riding the vehicle and don't have the gun in their hands.
/datum/component/vehicle_mounted_weapon/proc/on_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	var/obj/vehicle/parent_vehicle = source
	if(parent_vehicle.is_equipment_controller(user) && !user.is_holding(mounted_gun))
		user.put_in_active_hand(mounted_gun)
		return COMPONENT_NO_ATTACK_HAND

///Adds stuff to the examine of the vehicle.
/datum/component/vehicle_mounted_weapon/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("It has a [mounted_gun.name] attached.")
	if(mounted_gun.rounds)
		examine_list += span_notice("Ammo: [span_bold("[mounted_gun.rounds]/[mounted_gun.max_rounds]")]")
		examine_list += span_notice("Drag to yourself to unload the mounted weapon.")
	else
		examine_list += span_notice("Reload it by clicking it with the appropriate ammo type.")

///Handles the weapon being dropped. The only way this should happen is if they unbuckle, and this makes sure they can't just take the gun and run off with it.
/datum/component/vehicle_mounted_weapon/proc/on_weapon_drop(obj/item/dropped, mob/user)
	SIGNAL_HANDLER
	var/obj/vehicle/vehicle_parent = parent
	vehicle_parent.visible_message(span_warning("[dropped] violently snaps back into it's place in [parent]!"))
	dropped.forceMove(vehicle_parent)
