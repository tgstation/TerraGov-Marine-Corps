
/obj/item/unmanned_vehicle_remote
	name = "Handheld Vehicle Controller"
	desc = "Used to control an unmanned vehicle."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "multitool2"
	var/obj/vehicle/unmanned/vehicle = null
	var/controlling = FALSE

/obj/item/unmanned_vehicle_remote/Initialize()
	. = ..()

/obj/item/unmanned_vehicle_remote/afterattack(atom/target, mob/user, flag)
	if(istype(target, /obj/vehicle/unmanned))
		if(!vehicle)
			vehicle = target
			AddComponent(/datum/component/remote_control, target)
			to_chat(user, "<span class='notice'>You link [target] to [src]</span>.")

	if(SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user))
		return

/obj/item/unmanned_vehicle_remote/attack_self(mob/user)
	if(!vehicle)
		return
	if(SEND_SIGNAL(src, COMSIG_REMOTECONTROL_TOGGLE, user))
		return

/obj/item/unmanned_vehicle_remote/dropped(mob/user)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ITEM_DROPPED, user))
		return
