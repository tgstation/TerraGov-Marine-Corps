/obj/item/attachable/motiondetector
	name = "tactical sensor"
	desc = "A device that detects hostile movement. Hostiles appear as red blips. Friendlies with the correct IFF signature appear as green, and their bodies as blue, unrevivable bodies as dark blue. It has a mode selection interface."
	icon_state = "minidetector"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	attachment_action_type = /datum/action/item_action/toggle
	/// The motion detector component that we will enable/disable on demand.
	var/datum/component/motion_detector/motion_detector_component

/obj/item/attachable/motiondetector/Initialize(mapload)
	. = ..()
	motion_detector_component = AddComponent(/datum/component/motion_detector)

/obj/item/attachable/motiondetector/Destroy()
	if(active)
		deactivate()
	return ..()

/obj/item/attachable/motiondetector/update_icon_state()
	icon_state = initial(icon_state) + (!active ? "" : "_on")

/obj/item/attachable/motiondetector/activate(mob/user, turn_off, forced = FALSE)
	. = ..()
	if(!forced && (active || turn_off))
		deactivate(user)
		return
	motion_detector_component.set_detecting_mob(user)
	active = TRUE
	update_icon()

/// Turns off / reverts everything that comes with activating it.
/obj/item/attachable/motiondetector/proc/deactivate(mob/user)
	SIGNAL_HANDLER
	motion_detector_component.set_detecting_mob(null)
	active = FALSE
	update_icon()

/// Activates/deactivates the attachment based on where the attached item's new item slot.
/obj/item/attachable/motiondetector/proc/equipped_attached_item(attached_item, mob/user, slot)
	SIGNAL_HANDLER
	if(ishandslot(slot))
		activate(user, forced = TRUE) // Catches if it equipped from a handslot to an another handslot.
		return
	if(!active)
		return
	deactivate(user)

/obj/item/attachable/motiondetector/on_attach(attaching_item, mob/user)
	. = ..()
	RegisterSignal(attaching_item, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped_attached_item))
	RegisterSignal(attaching_item, COMSIG_ITEM_REMOVED_INVENTORY, PROC_REF(deactivate))

/obj/item/attachable/motiondetector/on_detach(detaching_item, mob/user)
	. = ..()
	UnregisterSignal(detaching_item, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(detaching_item, COMSIG_ITEM_REMOVED_INVENTORY)

/obj/item/attachable/motiondetector/attack_self(mob/user)
	activate(user)

/obj/item/attachable/motiondetector/equipped(mob/user, slot)
	. = ..()
	if(!ishandslot(slot))
		deactivate(user)

/obj/item/attachable/motiondetector/removed_from_inventory(mob/user)
	. = ..()
	deactivate(user) // Handheld motion detectors should be only active while it is in their hand.
