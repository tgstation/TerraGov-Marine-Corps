/obj/item/unmanned_vehicle_remote
	name = "Handheld Vehicle Controller"
	desc = "Used to control an unmanned vehicle."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "multitool2"
	var/obj/vehicle/unmanned/vehicle = null
	var/controlling = FALSE

/obj/item/unmanned_vehicle_remote/afterattack(atom/target, mob/user, flag)
	if(!istype(target, /obj/vehicle/unmanned))
		return ..()
	if(!vehicle)
		vehicle = target
		AddComponent(/datum/component/remote_control, target, vehicle.type)
		to_chat(user, "<span class='notice'>You link [target] to [src]</span>.")
	return ..()

/obj/item/unmanned_vehicle_remote/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_REMOTECONTROL_TOGGLE, user))
		return
	return ..()
