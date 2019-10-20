

/obj/item/unmanned_vehicle_remote
	name = "Handheld Vehicle Remote Control"
	desc = "Used to control an unmanned vehicle."
	icon = 'icons/obj/det.dmi'
	icon_state = "detpack_on"
	var/obj/unmanned_vehicle/vehicle_controlled = null

/obj/item/unmanned_vehicle_remote/Initialize()
	. = ..()

/obj/item/unmanned_vehicle_remote/afterattack(atom/target, mob/user, flag)
	if(!istype(target, /obj/unmanned_vehicle))
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