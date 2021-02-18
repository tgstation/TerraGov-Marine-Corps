/obj/item/unmanned_vehicle_remote
	name = "Handheld Vehicle Controller"
	desc = "Used to control an unmanned vehicle."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "multitool2"
	///reference to the unmanned vehicle that we're connected to or remote control
	var/obj/vehicle/unmanned/vehicle

/obj/item/unmanned_vehicle_remote/afterattack(atom/target, mob/user, flag)
	if(!istype(target, /obj/vehicle/unmanned))
		return ..()
	if(vehicle)
		if(vehicle == target)
			to_chat(user, "<span class='notice'>You unlink [target] from [src].</span>")
			SEND_SIGNAL(src, COMSIG_REMOTECONTROL_UNLINK)
			clear_vehicle()
		return ..()
	vehicle = target
	vehicle.on_link(src)
	AddComponent(/datum/component/remote_control, target, vehicle.turret_type)
	to_chat(user, "<span class='notice'>You link [target] to [src].</span>")
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clear_vehicle)
	return ..()

/obj/item/unmanned_vehicle_remote/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_REMOTECONTROL_TOGGLE, user))
		return
	return ..()

///Wrapper to clear reference on target vehicle deletion
/obj/item/unmanned_vehicle_remote/proc/clear_vehicle()
	SIGNAL_HANDLER
	vehicle.on_unlink(src)
	vehicle = null
