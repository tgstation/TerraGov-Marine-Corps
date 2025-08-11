/obj/item/attachable/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	attachment_action_type = /datum/action/item_action/toggle
	active = FALSE

/obj/item/attachable/motiondetector/Destroy()
	if(active)
		deactivate()
	return ..()

/obj/item/attachable/motiondetector/update_icon_state()
	. = ..()
	icon_state = initial(icon_state) + (!active ? "" : "_on")

/obj/item/attachable/motiondetector/activate(mob/user, turn_off)
	if(active)
		deactivate(user)
		return
	var/datum/component/motion_detector/motcomp = user.GetComponent(/datum/component/motion_detector)
	motcomp = user.AddComponent(/datum/component/motion_detector)
	RegisterSignal(user, COMSIG_COMPONENT_REMOVING, PROC_REF(deactivate_component))
	active = TRUE
	update_icon()

/// Turns off / reverts everything that comes with activating it.
/obj/item/attachable/motiondetector/proc/deactivate(mob/user)
	var/datum/component/motion_detector/motcomp = user.GetComponent(/datum/component/motion_detector)
	if(motcomp)
		UnregisterSignal(user, COMSIG_COMPONENT_REMOVING)
		qdel(motcomp)
	active = FALSE
	update_icon()

/// As the result of the removed component, turns off / reverts everything that comes with activating it.
/obj/item/attachable/motiondetector/proc/deactivate_component(datum/source, datum/component/removed_component)
	SIGNAL_HANDLER

	var/datum/component/motion_detector/motcomp = GetComponent(/datum/component/motion_detector)
	if(!motcomp || removed_component != motcomp)
		return

	UnregisterSignal(source, COMSIG_COMPONENT_REMOVING)
	active = FALSE
	update_icon()

/obj/item/attachable/motiondetector/on_detach(detaching_item, mob/user)
	. = ..()
	deactivate(user)

/obj/item/attachable/motiondetector/attack_self(mob/user)
	activate(user)

/obj/item/attachable/motiondetector/equipped(mob/user, slot)
	. = ..()
	if(!ishandslot(slot))
		deactivate(user)

/obj/item/attachable/motiondetector/removed_from_inventory(mob/user)
	. = ..()
	deactivate(user)
