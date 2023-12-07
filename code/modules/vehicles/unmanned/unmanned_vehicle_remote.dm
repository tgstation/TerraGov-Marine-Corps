/obj/item/unmanned_vehicle_remote
	name = "handheld vehicle controller"
	desc = "Used to control an unmanned vehicle.<br>Tap the vehicle you want to control with the controller to link it."
	icon = 'icons/obj/device.dmi'
	icon_state = "multitool2"
	///reference to the unmanned vehicle that we're connected to or remote control
	var/obj/vehicle/unmanned/vehicle

/obj/item/unmanned_vehicle_remote/Destroy()
	. = ..()
	clear_vehicle()

/obj/item/unmanned_vehicle_remote/afterattack(atom/target, mob/user, flag)
	if(!istype(target, /obj/vehicle/unmanned))
		return ..()
	if(vehicle)
		SEND_SIGNAL(src, COMSIG_REMOTECONTROL_UNLINK)
		if(vehicle == target)
			to_chat(user, span_notice("You unlink [target] from [src]."))
			clear_vehicle()
			return
		clear_vehicle()
	vehicle = target
	if(vehicle.controlled)
		to_chat(user, "<span class='warning'>Something is already controlling this vehicle</span>")
		vehicle = null
		return
	vehicle.on_link(src)
	AddComponent(/datum/component/remote_control, target, vehicle.turret_type, vehicle.can_interact)
	to_chat(user, span_notice("You link [target] to [src]."))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(clear_vehicle))
	return ..()

/obj/item/unmanned_vehicle_remote/attack_self(mob/user)
	if(SEND_SIGNAL(src, COMSIG_REMOTECONTROL_TOGGLE, user))
		return
	return ..()

///Wrapper to clear reference on target vehicle deletion
/obj/item/unmanned_vehicle_remote/proc/clear_vehicle()
	SIGNAL_HANDLER
	if(!vehicle)
		return
	UnregisterSignal(vehicle, COMSIG_QDELETING)
	vehicle.on_unlink(src)
	vehicle = null
