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

	var/obj/parent_object = parent //TODO: check if this canbe cleaned
	if(length(starting_attachments) && parent_object.loc) //Attaches starting attachments if the object is not instantiated in nullspace. If it is created in null space, such as in a loadout vendor. It wont create default attachments.
		for(var/starting_attachment_type in starting_attachments)
			try_attach_if_slot_free(new starting_attachment_type(parent_object))

	update_parent_overlay()

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/start_mob_attempt_attach) //For attaching.
	RegisterSignal(parent, list(COMSIG_MARINE_VENDOR_MODULE_VENDED, COMSIG_LOADOUT_VENDOR_VENDED_GUN_ATTACHMENT, COMSIG_LOADOUT_VENDOR_VENDED_ATTACHMENT_GUN, COMSIG_LOADOUT_VENDOR_VENDED_ARMOR_ATTACHMENT), .proc/attach_without_user)

	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/start_mob_attempt_detatch) //For Detaching
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/clean_references) //Dels attachments.
	RegisterSignal(parent, COMSIG_ITEM_APPLY_CUSTOM_OVERLAY, .proc/apply_custom)
	RegisterSignal(parent, COMSIG_ITEM_UNEQUIPPED, .proc/remove_overlay)

///Gets info about an attachment, can return null
/datum/component/attachment_handler/proc/get_attachment_data(obj/attachment) //can this actually return null? do we need to check for it every time we get it? will it crahs if we dont?
	var/list/attachment_data = list()
	SEND_SIGNAL(attachment, COMSIG_ITEM_IS_ATTACHING, attachment_data)
	return attachment_data

///Checks if this can receive the attachment, and if the attachment is attachable to this
/datum/component/attachment_handler/proc/attachment_is_compatible(obj/attachment, list/attachment_data, mob/attacher)
	if(can_attach && !can_attach.Invoke(attachment))
		return FALSE

	if(attachment_data[CAN_ATTACH])
		var/datum/callback/attachment_can_attach = CALLBACK(attachment, attachment_data[CAN_ATTACH])
		if(!attachment_can_attach.Invoke(parent, attacher))
			return FALSE

	//Is this an allowed attachment (or is the attachment supposed to bypass this check)
	if (!(attachment.type in attachables_allowed) && !CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_BYPASS_ALLOWED_LIST))
		return FALSE

	var/slot = attachment_data[SLOT]
	if(!(slot in slots)) //does this have an appropriate attachment slot for the attachment?
		return FALSE

	return TRUE

///Checks if there is an attachment in a slot that cannot be removed
/datum/component/attachment_handler/proc/has_unremovable_attachment(slot) //TODO: maybe needs better way to check
	var/list/attachment_data = attachment_data_by_slot[slot]
	if (!attachment_data)
		return TRUE //no attachment found

	return attachment_can_detatch(attachment_data)

///Is the attachment allowed to detatch?
/datum/component/attachment_handler/proc/attachment_can_detatch(attachment_data)
	return CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_REMOVABLE)

///Gives the player a UI where they can select an attachment, returns the selected attachment
/datum/component/attachment_handler/proc/player_select_attachment(mob/user, list/attachment_options)
	return tgui_input_list(user, "Choose an attachment", "Choose attachment", attachment_options)

///Attaches an attachment. This is an unsafe proc, check if the attachment is allowed to attach first.
/datum/component/attachment_handler/proc/attach(obj/item/attachment, list/attachment_data, mob/attacher) //TODO: this all looks ugly?
	var/slot = attachment_data[SLOT]
	var/obj/item/current_attachment = slots[slot]

	if(current_attachment) //If there is an attachment is the slot we are attaching to, detatch it
		var/list/current_attachment_data_by_slot = attachment_data_by_slot[slot]
		detach(current_attachment, current_attachment_data_by_slot, attacher)

	attachment.forceMove(parent) //TODO: What is this doing

	//Sets the new attachment
	slots[slot] = attachment
	attachment_data_by_slot[slot] = attachment_data

	RegisterSignal(attachment, COMSIG_ATOM_UPDATE_ICON, .proc/update_parent_overlay)

	var/obj/parent_obj = parent
	//The gun has another gun attached to it
	if(isgun(attachment) && isgun(parent))
		parent_obj:gunattachment = attachment

	on_attach?.Invoke(attachment, attacher)

	if(attachment_data[ON_ATTACH])
		var/datum/callback/attachment_on_attach = CALLBACK(attachment, attachment_data[ON_ATTACH])
		attachment_on_attach.Invoke(parent, attacher)
	SEND_SIGNAL(attachment, COMSIG_ATTACHMENT_ATTACHED, parent, attacher)
	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_ATTACHED_TO_ITEM, attachment, attacher)

	update_parent_overlay()

	var/mob/wearing_mob = parent_obj.loc
	if(ismob(wearing_mob) && CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_APPLY_ON_MOB))
		wearing_mob.regenerate_icons() //Theres probably a better way to do this.

///Detatches an attachment. This is an unsafe proc, check if the attachment is allowed to detatch first.
/datum/component/attachment_handler/proc/detach(obj/item/attachment, list/attachment_data, mob/living/user) //TODO: this all looks ugly?
	var/slot = attachment_data[SLOT]
	slots[slot] = null //Sets the slot the attachment is being removed from to null.
	attachment_data_by_slot[slot] = null

	on_detach?.Invoke(attachment, user)

	if(attachment_data[ON_DETACH])
		var/datum/callback/attachment_on_detach = CALLBACK(attachment, attachment_data[ON_DETACH])
		attachment_on_detach.Invoke(parent, user)

	UnregisterSignal(attachment, COMSIG_ATOM_UPDATE_ICON)
	update_parent_overlay()

	if(!user) //TODO: Why??
		QDEL_NULL(attachment)
		return

	user.put_in_hands(attachment)

	SEND_SIGNAL(attachment, COMSIG_ATTACHMENT_DETACHED, parent, user)
	SEND_SIGNAL(parent, COMSIG_ATTACHMENT_DETACHED_FROM_ITEM, attachment, user)

/datum/component/attachment_handler/proc/play_attach_sound(mob/attacher, list/attachment_data)
	playsound(attacher, attachment_data[ATTACH_SOUND], 15, 1, 4)

///Run when parent is attacked by an attachment, starts mob's attempt to attach
/datum/component/attachment_handler/proc/start_mob_attempt_attach(datum/source, obj/attacking, mob/attacker)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/mob_attempt_attach, attacking, attacker)

///Makes a mob attempt to attach an attachment, replacing the current if able
/datum/component/attachment_handler/proc/mob_attempt_attach(obj/attachment, mob/attacher)
	var/list/attachment_data = get_attachment_data(attachment)
	if(!length(attachment_data))
		return

	if(!attachment_is_compatible(attachment, attachment_data))
		to_chat(attacher, span_warning("You cannot attach [attachment] to [parent]!"))
		return

	var/slot = attachment_data[SLOT]
	var/obj/item/old_attachment = slots[slot]

	if(has_unremovable_attachment(slot))
		to_chat(attacher, span_warning("You cannot remove [old_attachment] from [parent] to make room for [attachment]!"))
		return

	if(!CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_NO_HANDS))
		var/obj/item/in_hand = attacher.get_inactive_held_item()
		if(in_hand != parent)
			to_chat(attacher, span_warning("You have to hold [parent] to do that!"))
			return

	if(!do_attach(attachment, attacher, attachment_data))
		return

	attacher.visible_message(span_notice("[attacher] attaches [attachment] to [parent]."),
	span_notice("You attach [attachment] to [parent]."), null, 4)
	play_attach_sound(attacher, attachment_data) //TODO: should sound be played here or in attach()

	attach(attachment, attachment_data, attacher)
	attacher.temporarilyRemoveItemFromInventory(attachment) //TODO: What is this doing?

	//Re-try putting old attachment into hands, now that we've cleared them
	if(old_attachment)
		attacher.put_in_hands(old_attachment)

///This is the do_after for attaching.
/datum/component/attachment_handler/proc/do_attach(obj/item/attachment, mob/attacher, list/attachment_data)
	var/do_after_icon_type = BUSY_ICON_GENERIC
	var/attach_delay = attachment_data[ATTACH_DELAY]

	var/skill_used = attachment_data[ATTACH_SKILL]
	var/skill_upper_threshold = attachment_data[ATTACH_SKILL_UPPER_THRESHOLD]

	if(skill_used) //This is so we can make many attachments with different skills used to attach.
		var/attacher_skill = attacher.skills.getRating(skill_used)
		if(attacher_skill)
			attacher.visible_message(span_notice("[attacher] begins attaching [attachment] to [parent]."),
			span_notice("You begin attaching [attachment] to [parent]."), null, 4)
			if(skill_upper_threshold && attacher_skill >= skill_upper_threshold) //See if the attacher is super skilled/panzerelite born to defeat never retreat etc
				attach_delay *= 0.5
		else //If the attacher has no training, attaching takes twice as long and they fumble about.
			attach_delay *= 2
			attacher.visible_message(span_notice("[attacher] begins fumbling about, trying to attach [attachment] to [parent]."),
			span_notice("You begin fumbling about, trying to attach [attachment] to [parent]."), null, 4)
			do_after_icon_type = BUSY_ICON_UNSKILLED

	return do_after(attacher, attach_delay, TRUE, parent, do_after_icon_type)

///Starts a mob's attempt to detach something from the parent, is called when the user Alt-Clicks the parent.
/datum/component/attachment_handler/proc/start_mob_attempt_detatch(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/mob_attempt_detatch, user)

///Makes a mob attempt to detatch an attachment, based on a menu selection
/datum/component/attachment_handler/proc/mob_attempt_detatch(mob/user)
	if(!user.is_holding(parent))
		to_chat(user, span_warning("You must be holding [parent] to field strip it!"))
		return

	if(user.get_active_held_item() && user.get_inactive_held_item()) //Check if both hands are full
		to_chat(user, span_warning("You need a free hand to field strip [parent]!"))
		return

	var/list/removable_attachments = list()
	for(var/slot in slots) //TODO: can we directly iterate through attachments here?
		var/current_attachment = slots[slot]
		if(current_attachment && !has_unremovable_attachment(slot))
			removable_attachments += current_attachment

	if(!length(removable_attachments))
		to_chat(user, span_warning("There are no attachments that can be removed from [parent]!"))
		return

	//If there is only 1 attachment, default to removing it, otherwise ask player to select one
	var/obj/attachment_to_remove = length(removable_attachments) == 1 ? removable_attachments[1] : player_select_attachment(user, removable_attachments)

	if(!attachment_to_remove)
		return

	var/attachment_data = get_attachment_data(attachment_to_remove)
	if (!do_detach(attachment_to_remove, user, attachment_data))
		return


	if (!length(attachment_data)) //TODO: can this ever actually run? will it crash if we skip this check?
		return

	user.visible_message(span_notice("[user] detaches [attachment_to_remove] to [parent]."),
	span_notice("You detach [attachment_to_remove] to [parent]."), null, 4)
	play_attach_sound(user, attachment_data)

	detach(attachment_to_remove, attachment_data, user)

///This is the do_after for detatching
/datum/component/attachment_handler/proc/do_detach(obj/item/attachment, mob/attacher, list/attachment_data)
	var/do_after_icon_type = BUSY_ICON_GENERIC
	var/detach_delay = attachment_data[DETACH_DELAY]

	var/skill_used = attachment_data[ATTACH_SKILL]
	var/skill_upper_threshold = attachment_data[ATTACH_SKILL_UPPER_THRESHOLD]

	if(skill_used) //Same as up in do_attach
		var/attacher_skill = attacher.skills.getRating(skill_used)
		if(attacher_skill)
			attacher.visible_message(span_notice("[attacher] begins detaching [attachment] from [parent]."),
			span_notice("You begin detaching [attachment] from [parent]."), null, 4)
			if(skill_upper_threshold && attacher_skill >= skill_upper_threshold)
				detach_delay *= 0.5
		else
			detach_delay *= 2
			attacher.visible_message(span_notice("[attacher] begins fumbling about, trying to detach [attachment] from [parent]."),
			span_notice("You begin fumbling about, trying to detach [attachment] from [parent]."), null, 4)
			do_after_icon_type = BUSY_ICON_UNSKILLED

	return do_after(attacher, detach_delay, TRUE, parent, do_after_icon_type)

///This is for other objects to be able to attach things without the need for a user.
/datum/component/attachment_handler/proc/attach_without_user(datum/source, obj/item/attachment)
	SIGNAL_HANDLER
	try_attach_if_slot_free(attachment)

///Attaches attachment if compatible and the slot is empty
/datum/component/attachment_handler/proc/try_attach_if_slot_free(obj/attachment) //TODO: this may need fixing w/ new helpers after refactor
	var/list/attachment_data = get_attachment_data(attachment)
	if(!length(attachment_data))
		return

	if (!attachment_is_compatible(attachment, attachment_data))
		return

	var/slot = attachment_data[SLOT]
	var/current_attachment = slots[slot]
	if(current_attachment)
		return

	attach(attachment, attachment_data, null) //TODO: does this break stuff if attacher is null?

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
		if(attachment_data[OVERLAY_ICON] == attachment.icon)
			icon_state = attachment.icon_state + "_a"
		if(CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_SAME_ICON))
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
		if(!CHECK_BITFIELD(attachment_data[FLAGS_ATTACH_FEATURES], ATTACH_SAME_ICON))
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

