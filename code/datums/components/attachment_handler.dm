/datum/component/attachment_handler
	///Assoc list that stores the refs of the attachments to the parent. 'slot = reference'
	var/list/slots
	///Assoc list that stores the attachment data of an attachment in the slot.
	var/list/attachment_data_by_slot = list()
	///Typepath list that stores type data of allowed attachments. The attachment needs the attachment element to be able to attach regardless of what is stored here.
	var/list/attachables_allowed
	///Proc the parent calls on attach.
	var/datum/callback/on_attach
	///Proc the parent calls on detach.
	var/datum/callback/on_detach
	///Proc the parent calls to see if its eligable for attachment.
	var/datum/callback/can_attach
	///List of offsets for the parent that adjusts the attachment overlay. slot1_x = 1, slot1_y = 1, slot2_x = 3, slot2_y = 7, etc. Can be null, in that case the offsets for all the attachments default to 0.
	var/list/attachment_offsets
	///List of the attachment overlay images. This is so that we can easily swap overlays in and out.
	var/list/attachable_overlays

/datum/component/attachment_handler/Initialize(list/slots, list/attachables_allowed, list/attachment_offsets, list/starting_attachments, datum/callback/can_attach, datum/callback/on_attach, datum/callback/on_detach, list/overlays = list())
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.slots = slots
	attachment_data_by_slot += slots
	src.attachables_allowed = attachables_allowed
	src.on_attach = on_attach
	src.on_detach = on_detach
	src.can_attach = can_attach
	src.attachment_offsets = attachment_offsets
	attachable_overlays = overlays //This is incase the parent wishes to have a stored reference to this list.
	attachable_overlays += slots

	var/obj/parent_object = parent
	if(length(starting_attachments) && parent_object.loc) //Attaches starting attachments if the object is not instantiated in nullspace. If it is created in null space, such as in a loadout vendor. It wont create default attachments.
		for(var/starting_attachment_type in starting_attachments)
			attach_without_user(attachment = new starting_attachment_type(parent_object))

	update_parent_overlay()

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(start_handle_attachment)) //For attaching.
	RegisterSignals(parent, list(COMSIG_LOADOUT_VENDOR_VENDED_GUN_ATTACHMENT, COMSIG_LOADOUT_VENDOR_VENDED_ATTACHMENT_GUN, COMSIG_LOADOUT_VENDOR_VENDED_ARMOR_ATTACHMENT), PROC_REF(attach_without_user))

	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(start_detach)) //For Detaching
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(clean_references)) //Dels attachments.
	RegisterSignal(parent, COMSIG_ITEM_APPLY_CUSTOM_OVERLAY, PROC_REF(apply_custom))
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, PROC_REF(remove_overlay))

///Starts processing the attack, and whether or not the attachable can attack.
/datum/component/attachment_handler/proc/start_handle_attachment(datum/source, obj/attacking, mob/attacker)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(handle_attachment), attacking, attacker)

/datum/component/attachment_handler/proc/handle_attachment(obj/attachment, mob/attacher, bypass_checks = FALSE)

	var/list/attachment_data = list()
	SEND_SIGNAL(attachment, COMSIG_ITEM_IS_ATTACHING, attacher, attachment_data)

	if(!length(attachment_data)) //Something has to provide attaching data here to continue.
		return

	if(!bypass_checks)
		if(can_attach && !can_attach.Invoke(attachment))
			return
		if(attachment_data[CAN_ATTACH])
			var/datum/callback/attachment_can_attach = CALLBACK(attachment, attachment_data[CAN_ATTACH])
			if(!attachment_can_attach.Invoke(parent, attacher))
				return
		if(!do_attach(attachment, attacher, attachment_data))
			return

	var/slot = attachment_data[SLOT]
	if(!attacher && (!(slot in slots) || !(attachment.type in attachables_allowed))) //No more black market attachment combos.
		QDEL_NULL(attachment)
		return

	var/obj/item/old_attachment = slots[slot]

	finish_handle_attachment(attachment, attachment_data, attacher)

	if(!attacher)
		return
	attacher.temporarilyRemoveItemFromInventory(attachment)

	//Re-try putting old attachment into hands, now that we've cleared them
	if(old_attachment)
		attacher.put_in_hands(old_attachment)


///Finishes setting up the attachment. This is where the attachment actually attaches. This can be called directly to bypass any checks to directly attach an object.
/datum/component/attachment_handler/proc/finish_handle_attachment(obj/item/attachment, list/attachment_data, mob/attacker)
	var/slot = attachment_data[SLOT]

	if(slots[slot]) //Checks for an attachment in the current slot.
		var/obj/item/current_attachment = slots[slot]
		finish_detach(current_attachment, attachment_data_by_slot[slot], attacker) //Removes the current attachment.

	attachment.forceMove(parent)
	slots[slot] = attachment
	attachment_data_by_slot[slot] = attachment_data

	RegisterSignal(attachment, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_parent_overlay))

	var/obj/parent_obj = parent
	///The gun has another gun attached to it
	if(isgun(attachment) && isgun(parent) )
		parent_obj:gunattachment = attachment

	on_attach?.Invoke(attachment, attacker)

	if(attachment_data[ON_ATTACH])
		var/datum/callback/attachment_on_attach = CALLBACK(attachment, attachment_data[ON_ATTACH])
		attachment_on_attach.Invoke(parent, attacker)
	SEND_SIGNAL(attachment, COMSIG_ATTACHMENT_ATTACHED, parent, attacker)
	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_ATTACHED_TO_ITEM, attachment, attacker)

	update_parent_overlay()
	if(!CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_APPLY_ON_MOB))
		return

	if(!ismob(parent_obj.loc))
		return
	var/mob/wearing_mob = parent_obj.loc
	wearing_mob.regenerate_icons() ///Theres probably a better way to do this.

///This is the do_after and user checks for attaching.
/datum/component/attachment_handler/proc/do_attach(obj/item/attachment, mob/attacher, list/attachment_data)
	if(!isliving(attacher))
		return FALSE

	var/mob/living/user = attacher

	if(!can_attach(attachment, user, attachment_data))
		return FALSE

	if(!CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_NO_HANDS))
		var/obj/item/in_hand = user.get_inactive_held_item()
		if(in_hand != parent)
			to_chat(user, span_warning("You have to hold [parent] to do that!"))
			return FALSE

	var/do_after_icon_type = BUSY_ICON_GENERIC
	var/attach_delay = attachment_data[ATTACH_DELAY]

	var/skill_used = attachment_data[ATTACH_SKILL]
	var/skill_upper_threshold = attachment_data[ATTACH_SKILL_UPPER_THRESHOLD]

	if(skill_used) //This is so we can make many attachments with different skills used to attach.
		if(user.skills.getRating(skill_used))
			user.visible_message(span_notice("[user] begins attaching [attachment] to [parent]."),
			span_notice("You begin attaching [attachment] to [parent]."), null, 4)
			if(skill_upper_threshold && user.skills.getRating(skill_used) >= skill_upper_threshold) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
				attach_delay *= 0.5
		else //If the user has no training, attaching takes twice as long and they fumble about.
			attach_delay *= 2
			user.visible_message(span_notice("[user] begins fumbling about, trying to attach [attachment] to [parent]."),
			span_notice("You begin fumbling about, trying to attach [attachment] to [parent]."), null, 4)
			do_after_icon_type = BUSY_ICON_UNSKILLED

	if(!do_after(user, attach_delay, NONE, parent, do_after_icon_type))
		return FALSE
	user.visible_message(span_notice("[user] attaches [attachment] to [parent]."),
	span_notice("You attach [attachment] to [parent]."), null, 4)
	playsound(user, attachment_data[ATTACH_SOUND], 15, 1, 4)
	return TRUE

///Checks the current slots of the parent and if there are attachments that can be removed in those slots. Basically it makes sure theres room for the attachment.
/datum/component/attachment_handler/proc/can_attach(obj/item/attachment, mob/living/user, list/attachment_data)
	if(!length(slots)) //If there is no slots, it cannot be attached to. Currently this has no use. But I had a thought about making attachments that can add/remove slots.
		return FALSE

	var/slot = attachment_data[SLOT]

	if(!(slot in slots) || (!(attachment.type in attachables_allowed) && !CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_BYPASS_ALLOWED_LIST))) //If theres no slot on parent, or if the attachment type isnt allowed, returns FALSE.
		to_chat(user, span_warning("You cannot attach [attachment] to [parent]!"))
		return FALSE

	if(!slots[slot]) //If the slot is empty theres room.
		return TRUE

	var/list/current_attachment_data = attachment_data_by_slot[slot]

	if(!CHECK_BITFIELD(current_attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_REMOVABLE)) //If the slots attachment is unremovable.
		to_chat(user, span_warning("You cannot remove [slots[slot]] from [parent] to make room for [attachment]!"))
		return FALSE

	return TRUE //Removal of a current attachment is done in finish_handle_attachment.

///Starts with the detach, is called when the user Alt-Clicks the parent.
/datum/component/attachment_handler/proc/start_detach(datum/source, mob/user)
	SIGNAL_HANDLER
	var/mob/living/living_user = user

	if(!detach_check(living_user))
		return

	var/list/attachments_to_remove = list()
	for(var/key in slots) //Gets a list of the attachments that can be removed.
		var/obj/item/current_attachment = slots[key]
		if(!current_attachment)
			continue
		var/list/current_attachment_data = attachment_data_by_slot[key]
		if(!CHECK_BITFIELD(current_attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_REMOVABLE))
			continue
		attachments_to_remove += current_attachment

	if(!length(attachments_to_remove))
		to_chat(living_user, span_warning("There are no attachments that can be removed from [parent]!"))
		return

	INVOKE_ASYNC(src, PROC_REF(do_detach), living_user, attachments_to_remove)

///Checks if you are actually able to detach an item or not
/datum/component/attachment_handler/proc/detach_check(mob/user)
	if(user.get_active_held_item() != parent && user.get_inactive_held_item() != parent)
		to_chat(user, span_warning("You must be holding [parent] to field strip it!"))
		return FALSE
	if((user.get_active_held_item() == parent && user.get_inactive_held_item()) || (user.get_inactive_held_item() == parent && user.get_active_held_item()))
		to_chat(user, span_warning("You need a free hand to field strip [parent]!"))
		return FALSE
	return TRUE

///Does the detach, shows the user the removable attachments and handles the do_after.
/datum/component/attachment_handler/proc/do_detach(mob/living/user, list/attachments_to_remove)
	//If there is only one attachment to remove, then that will be the attachment_to_remove. If there is more than one it gives the user a list to select from.
	var/obj/item/attachment_to_remove = length(attachments_to_remove) == 1 ? attachments_to_remove[1] : tgui_input_list(user, "Choose an attachment", "Choose attachment", attachments_to_remove)
	if(!attachment_to_remove)
		return

	if(!detach_check(user))
		return

	var/list/attachment_data
	for(var/key in slots)
		if(slots[key] != attachment_to_remove)
			continue
		attachment_data = attachment_data_by_slot[key]
		break

	var/do_after_icon_type = BUSY_ICON_GENERIC
	var/detach_delay = attachment_data[DETACH_DELAY]

	var/skill_used = attachment_data[ATTACH_SKILL]
	var/skill_upper_threshold = attachment_data[ATTACH_SKILL_UPPER_THRESHOLD]

	if(skill_used) //Same as up in do_attach
		if(user.skills.getRating(skill_used))
			user.visible_message(span_notice("[user] begins detaching [attachment_to_remove] from [parent]."),
			span_notice("You begin detaching [attachment_to_remove] from [parent]."), null, 4)
			if(skill_upper_threshold && user.skills.getRating(skill_used) >= skill_upper_threshold)
				detach_delay *= 0.5
		else
			detach_delay *= 2
			user.visible_message(span_notice("[user] begins fumbling about, trying to detach [attachment_to_remove] from [parent]."),
			span_notice("You begin fumbling about, trying to detach [attachment_to_remove] from [parent]."), null, 4)
			do_after_icon_type = BUSY_ICON_UNSKILLED

	if(!do_after(user, detach_delay, NONE, parent, do_after_icon_type))
		return

	user.visible_message(span_notice("[user] detaches [attachment_to_remove] to [parent]."),
	span_notice("You detach [attachment_to_remove] to [parent]."), null, 4)
	playsound(user, attachment_data[ATTACH_SOUND], 15, 1, 4)

	finish_detach(attachment_to_remove, attachment_data, user)

///Actually detaches the attachment. This can be called directly to bypass checks.
/datum/component/attachment_handler/proc/finish_detach(obj/item/attachment, list/attachment_data, mob/living/user)
	slots[attachment_data[SLOT]] = null //Sets the slot the attachment is being removed from to null.
	attachment_data_by_slot[attachment_data[SLOT]] = null
	on_detach?.Invoke(attachment, user)
	UnregisterSignal(attachment, COMSIG_ATOM_UPDATE_OVERLAYS)
	update_parent_overlay()

	if(!user)
		QDEL_NULL(attachment)
		return

	if(attachment_data[ON_DETACH])
		var/datum/callback/attachment_on_detach = CALLBACK(attachment, attachment_data[ON_DETACH])
		attachment_on_detach.Invoke(parent, user)

	user.put_in_hands(attachment)

	SEND_SIGNAL(attachment, COMSIG_ATTACHMENT_DETACHED, parent, user)
	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_DETACHED_FROM_ITEM, attachment, user)

///This is for other objects to be able to attach things without the need for a user.
/datum/component/attachment_handler/proc/attach_without_user(datum/source, obj/item/attachment)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(handle_attachment), attachment, null, TRUE)

///This updates the overlays of the parent and apllies the right ones.
/datum/component/attachment_handler/proc/update_parent_overlay(datum/source)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	for(var/slot in slots) //Cycles through all the slots.
		var/obj/item/attachment = slots[slot]
		var/image/overlay = attachable_overlays[slot]
		parent_item.overlays -= overlay //First removes the existing overlay that occupies the slots overlay.

		if(!attachment) //No attachment, no overlay.
			attachable_overlays[slot] = null
			continue

		var/list/attachment_data = attachment_data_by_slot[slot]

		var/icon = attachment_data[OVERLAY_ICON]
		var/icon_state = attachment.icon_state
		if(attachment.greyscale_colors && attachment.greyscale_config)
			icon = attachment.icon
			icon_state = attachment.icon_state + "_a"
		else if(attachment_data[OVERLAY_ICON] == attachment.icon)
			icon_state = attachment.icon_state + "_a"
		if(CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_SAME_ICON) || CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_DIFFERENT_MOB_ICON_STATE))
			icon_state = attachment.icon_state
			icon = attachment.icon
			overlay = image(icon, parent_item, icon_state)
			overlay.overlays += attachment.overlays
		else
			overlay = image(icon, parent_item, icon_state)
		var/slot_x = 0 //This and slot_y are for the event that the parent did not have an overlay_offsets. In that case the offsets default to 0
		var/slot_y = 0
		for(var/attachment_slot in attachment_offsets)
			if("[slot]_x" == attachment_slot)
				slot_x = attachment_offsets["[slot]_x"]
				continue
			if("[slot]_y" == attachment_slot)
				slot_y = attachment_offsets["[slot]_y"]
				continue

		var/pixel_shift_x = attachment_data[PIXEL_SHIFT_X] ? attachment_data[PIXEL_SHIFT_X] : 0 //This also is incase the attachments pixel_shift_x and y are null. If so it defaults to 0.
		var/pixel_shift_y = attachment_data[PIXEL_SHIFT_Y] ? attachment_data[PIXEL_SHIFT_Y] : 0

		overlay.pixel_x = slot_x - pixel_shift_x
		overlay.pixel_y = slot_y - pixel_shift_y

		attachable_overlays[slot] = overlay
		parent_item.overlays += overlay

///Updates the mob sprite of the attachment.
/datum/component/attachment_handler/proc/apply_custom(datum/source, mutable_appearance/standing)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	if(!ismob(parent_item.loc))
		return
	var/mob/living/carbon/human/wearer = parent_item.loc
	for(var/slot in slots)
		var/obj/item/attachment = slots[slot]
		if(!attachment)
			continue
		var/list/attachment_data = attachment_data_by_slot[slot]
		if(!CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_APPLY_ON_MOB))
			continue
		if(attachment_data[ATTACHMENT_LAYER])
			wearer.remove_overlay(attachment_data[ATTACHMENT_LAYER])
		var/icon = attachment.icon
		var/icon_state = attachment.icon_state
		var/suffix = ""
		if(CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_DIFFERENT_MOB_ICON_STATE))
			suffix = "_m"
		else if(!CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_SAME_ICON))
			if(CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_SEPERATE_MOB_OVERLAY))
				if(attachment_data[MOB_OVERLAY_ICON] != attachment_data[OVERLAY_ICON])
					icon = attachment_data[MOB_OVERLAY_ICON]
				else
					suffix = "_m"
			else
				icon = attachment_data[OVERLAY_ICON]
				suffix = attachment.icon == icon ? "_a" : ""
		var/mutable_appearance/new_overlay = mutable_appearance(icon, icon_state + suffix, -attachment_data[ATTACHMENT_LAYER])
		if(CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_SAME_ICON))
			new_overlay.overlays += attachment.overlays
		if(attachment_data[MOB_PIXEL_SHIFT_X])
			new_overlay.pixel_x += attachment_data[MOB_PIXEL_SHIFT_X]
		if(attachment_data[MOB_PIXEL_SHIFT_Y])
			new_overlay.pixel_y += attachment_data[MOB_PIXEL_SHIFT_Y]
		if(!attachment_data[ATTACHMENT_LAYER])
			standing.overlays += new_overlay
			continue
		wearer.overlays_standing[attachment_data[ATTACHMENT_LAYER]] = new_overlay
		wearer.apply_overlay(attachment_data[ATTACHMENT_LAYER])

///Handles the removal of attachment overlays when the item is unequipped
/datum/component/attachment_handler/proc/remove_overlay()
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	if(!ismob(parent_item.loc))
		return
	var/mob/living/carbon/human/wearer = parent_item.loc
	for(var/slot in slots)
		var/obj/item/attachment = slots[slot]
		if(!attachment)
			continue
		var/list/attachment_data = attachment_data_by_slot[slot]
		if(attachment_data[ATTACHMENT_LAYER])
			wearer.remove_overlay(attachment_data[ATTACHMENT_LAYER])

///Deletes the attachments when the parent deletes.
/datum/component/attachment_handler/proc/clean_references()
	SIGNAL_HANDLER
	QDEL_LIST_ASSOC_VAL(slots)

