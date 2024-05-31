/obj/item/vehicle_module/mounted_gun
	icon = 'icons/obj/vehicles.dmi'
	icon_state = ""
	slot = ATTACHMENT_SLOT_WEAPON
	w_class = WEIGHT_CLASS_BULKY
	attach_features_flags = ATTACH_ACTIVATION
	///The gun mounted on a vehicle
	var/obj/item/weapon/gun/mounted_gun

/obj/item/vehicle_module/mounted_gun/Initialize(mapload)
	. = ..()
	mounted_gun = new mounted_gun(src)
	//NODROP so that you can't just drop the gun or have someone take it off your hands
	ADD_TRAIT(mounted_gun, TRAIT_NODROP, MOUNTED_TRAIT)
	RegisterSignal(mounted_gun, COMSIG_ITEM_DROPPED, PROC_REF(on_weapon_drop))

/obj/item/vehicle_module/mounted_gun/on_unbuckle(datum/source, mob/living/unbuckled_mob, force = FALSE)
	unbuckled_mob.dropItemToGround(mounted_gun, TRUE)
	return ..()

///Handles the weapon being dropped. The only way this should happen is if they unbuckle, and this makes sure they can't just take the gun and run off with it.
/obj/item/vehicle_module/mounted_gun/proc/on_weapon_drop(obj/item/dropped, mob/user)
	SIGNAL_HANDLER
	dropped.forceMove(src)

/obj/item/vehicle_module/mounted_gun/activate(mob/living/user)
	if(mounted_gun.loc == user)
		user.dropItemToGround(mounted_gun, TRUE)
		return FALSE
	if(!user.put_in_active_hand(mounted_gun) && !user.put_in_inactive_hand(mounted_gun))
		to_chat(user, span_warning("Could not equip weapon! Click [parent] with a free hand to equip."))
		return FALSE
	return TRUE

/obj/item/vehicle_module/mounted_gun/volkite
	name = "mounted demi-culverin"
	icon = 'icons/obj/vehicles/hover_bike.dmi'
	icon_state = "bike_volkite"
	should_use_obj_appeareance = FALSE
	mounted_gun = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/bike_mounted

/obj/item/vehicle_module/mounted_gun/volkite/Initialize(mapload)
	. = ..()
	action_icon = mounted_gun.icon
	action_icon_state = mounted_gun.icon_state

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/bike_mounted
	icon = 'icons/obj/items/guns/energy.dmi'
	icon_state = "bike_volkite"
	worn_icon_state = null
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite/turret/hover_bike)
	default_ammo_type = /obj/item/cell/lasgun/volkite/turret/hover_bike
	attachable_allowed = null
	item_flags = NONE
	gun_features_flags = GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE|AMMO_RECIEVER_CLOSED|AMMO_RECIEVER_AUTO_EJECT_LOCKED
	accuracy_mult_unwielded = 0.9
	scatter_unwielded = 5
	recoil_unwielded = 0
	damage_mult = 0.9

//smelly test minigun
/obj/item/vehicle_module/mounted_gun/minigun
	name = "mounted minigun"
	icon = 'icons/obj/vehicles/hover_bike.dmi'
	icon_state = "minigun"
	should_use_obj_appeareance = FALSE
	mounted_gun = /obj/item/weapon/gun/minigun/one_handed

/obj/item/vehicle_module/mounted_gun/minigun/Initialize(mapload)
	. = ..()
	action_icon = mounted_gun.icon
	action_icon_state = mounted_gun.icon_state
