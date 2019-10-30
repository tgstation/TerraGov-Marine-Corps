

/obj/item/unmanned_vehicle_remote
	name = "Handheld Vehicle Remote Control"
	desc = "Used to control an unmanned vehicle."
	icon = 'icons/obj/det.dmi'
	icon_state = "detpack_on"
	var/obj/vehicle/unmanned/vehicle_controlled = null

/obj/item/unmanned_vehicle_remote/Initialize()
	. = ..()

/obj/item/unmanned_vehicle_remote/afterattack(atom/target, mob/user, flag)
	if(!istype(target, /obj/vehicle/unmanned))
		return

	if(vehicle_controlled)
		return

	to_chat(user, "Linking target vehicle.")
	vehicle_controlled = target
	AddComponent(/datum/component/remote_control, target)


/obj/item/unmanned_vehicle_remote/attack_self(mob/user)
	if(!vehicle_controlled)
		return
	if(SEND_SIGNAL(src, COMSIG_REMOTE_CONTROL_TOGGLE, user))
		return

/obj/item/unmanned_vehicle_remote/dropped(mob/user)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user))
		return
