/*!
 * Datumized Storage
 * Eliminates the need for custom signals specifically for the storage component, and attaches a storage variable (atom_storage) to every atom.
 */

///Helper proc to give something storage
/atom/proc/create_storage(
	storage_type = /datum/storage,
	list/can_hold,
	list/cant_hold,
	list/bypass_w_limit,
	/*
	max_w_class,
	max_storage_space,
	storage_slots,
	list/storage_type_limits,
	draw_mode,
	collection_mode,
	*/
)
	if(atom_storage)
		QDEL_NULL(atom_storage)

	atom_storage = new storage_type(src, can_hold, cant_hold, bypass_w_limit)
	return atom_storage

// The parent and real_location variables are both weakrefs, so they must be resolved before they can be used.
/datum/storage
	/// the actual item we're attached to
	var/atom/parent

	///List of objects which this item can store (if set, it can't store anything else)
	var/list/can_hold = list()
	///List of objects which this item can't store (in effect only if can_hold isn't set)
	var/list/cant_hold = list()
	///a list of objects which this item can store despite not passing the w_class limit
	var/list/bypass_w_limit = list()
	/**
	 * Associated list of types and their max count, formatted as
	 * 	storage_type_limits = list(
	 * 		/obj/A = 3,
	 * 	)
	 *
	 * Any inserted objects will decrement the allowed count of every listed type which matches or is a parent of that object.
	 * With entries for both /obj/A and /obj/A/B, inserting a B requires non-zero allowed count remaining for, and reduces, both.
	 */
	var/list/storage_type_limits
	///In slotless storage, stores areas where clicking will refer to the associated item
	var/list/click_border_start = list()
	var/list/click_border_end = list()
	///Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_w_class = WEIGHT_CLASS_SMALL
	///The sum of the storage costs of all the items in this storage item.
	var/max_storage_space = 14
	///The number of storage slots in this container.
	var/storage_slots = 7
	///Defines how many versions of the sprites that gets progressively emptier as they get closer to "_0" in .dmi.
	var/sprite_slots = null
	var/atom/movable/screen/storage/boxes = null

	///storage UI
	var/atom/movable/screen/storage/storage_start = null
	///storage UI
	var/atom/movable/screen/storage/storage_continue = null
	///storage UI
	var/atom/movable/screen/storage/storage_end = null
	///storage UI
	var/atom/movable/screen/storage/stored_start = null
	///storage UI
	var/atom/movable/screen/storage/stored_continue = null
	///storage UI
	var/atom/movable/screen/storage/stored_end = null
	///storage UI
	var/atom/movable/screen/close/closer = null

	///whether our storage box on hud changes color when full.
	var/show_storage_fullness = TRUE
	///Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/use_to_pickup
	///Set this to make the storage item group contents of the same type and display them as a number.
	var/display_contents_with_number
	///Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_empty
	///Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/allow_quick_gather
	///whether this object can change its drawing method
	var/allow_drawing_method = FALSE
	///0 = will open the inventory if you click on the storage container, 1 = will draw from the inventory if you click on the storage container
	var/draw_mode = 0
	////0 = pick one at a time, 1 = pick all on tile
	var/collection_mode = 1;
	///BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	var/foldable = null
	///sound played when used. null for no sound.
	var/use_sound = "rustle"
	///Has it been opened before?
	var/opened = 0
	///list of mobs currently seeing the storage's contents
	var/list/content_watchers = list()
	///How long does it take to put items into or out of this, in ticks
	var/access_delay = 0
	///What item do you use to tactical refill this
	var/list/obj/item/refill_types
	///What sound gets played when the item is tactical refilled
	var/refill_sound = null
	///the item left behind when our parent is destroyed
	var/trash_item = null

/datum/storage/New(atom/parent, list/can_hold, list/cant_hold, list/bypass_w_limit)
	. = ..()
	if(!istype(parent))
		stack_trace("Storage datum ([type]) created without a [isnull(parent) ? "null parent" : "invalid parent ([parent.type])"]!")
		qdel(src)
		return

	if(length(can_hold))
		can_hold = typecacheof(can_hold)
	else if(length(cant_hold))
		cant_hold = typecacheof(cant_hold)
	if(length(bypass_w_limit))
		bypass_w_limit = typecacheof(bypass_w_limit)

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))

/*	if(!allow_quick_gather)
		verbs -= /datum/storage/verb/toggle_gathering_mode

	if(!allow_drawing_method)
		verbs -= /datum/storage/verb/toggle_draw_mode*/

	boxes = new()
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE

	storage_start = new /atom/movable/screen/storage()
	storage_start.name = "storage"
	storage_start.master = src
	storage_start.icon_state = "storage_start"
	storage_start.screen_loc = "7,7 to 10,8"
	storage_start.layer = HUD_LAYER
	storage_start.plane = HUD_PLANE
	storage_continue = new /atom/movable/screen/storage()
	storage_continue.name = "storage"
	storage_continue.master = src
	storage_continue.icon_state = "storage_continue"
	storage_continue.screen_loc = "7,7 to 10,8"
	storage_continue.layer = HUD_LAYER
	storage_continue.plane = HUD_PLANE
	storage_end = new /atom/movable/screen/storage()
	storage_end.name = "storage"
	storage_end.master = src
	storage_end.icon_state = "storage_end"
	storage_end.screen_loc = "7,7 to 10,8"
	storage_end.layer = HUD_LAYER
	storage_end.plane = HUD_PLANE

	stored_start = new /obj() //we just need these to hold the icon
	stored_start.icon_state = "stored_start"
	stored_start.layer = HUD_LAYER
	stored_start.plane = HUD_PLANE
	stored_continue = new /obj()
	stored_continue.icon_state = "stored_continue"
	stored_continue.layer = HUD_LAYER
	stored_continue.plane = HUD_PLANE
	stored_end = new /obj()
	stored_end.icon_state = "stored_end"
	stored_end.layer = HUD_LAYER
	stored_end.plane = HUD_PLANE

	closer = new()
	closer.master = src

/datum/storage/Destroy()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACKBY))
	for(var/atom/movable/item in parent.contents)
		qdel(item)
	for(var/mob/M in content_watchers)
		hide_from(M)
	if(boxes)
		QDEL_NULL(boxes)
	if(storage_start)
		QDEL_NULL(storage_start)
	if(storage_continue)
		QDEL_NULL(storage_continue)
	if(storage_end)
		QDEL_NULL(storage_end)
	if(stored_start)
		QDEL_NULL(stored_start)
	if(stored_continue)
		QDEL_NULL(stored_continue)
	if(stored_end)
		QDEL_NULL(stored_end)
	if(closer)
		QDEL_NULL(closer)
	if(trash_item)
		new trash_item(get_turf(parent))
	. = ..()

/datum/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			to_chat(usr, "[src] now picks up all items in a tile at once.")
		if(0)
			to_chat(usr, "[src] now picks up one item at a time.")

/datum/storage/verb/toggle_draw_mode()
	set name = "Switch Storage Drawing Method"
	set category = "Object"
	draw_mode = !draw_mode
	if(draw_mode)
		to_chat(usr, "Clicking [src] with an empty hand now puts the last stored item in your hand.")
	else
		to_chat(usr, "Clicking [src] with an empty hand now opens the pouch storage menu.")

/**
 * Gets the inventory of a storage
 * if recursive = TRUE, this will also get the inventories of things within the inventory
 */
/datum/storage/proc/return_inv(recursive = TRUE)
	var/list/inventory = list()
	inventory += parent.contents
	if(recursive)
		for(var/item in parent.contents)
			var/atom/atom = item
			atom.atom_storage?.return_inv(recursive = TRUE)

	return inventory

/datum/storage/proc/show_to(mob/user as mob)
	if(user.s_active != src)
		for(var/obj/item/item in parent)
			if(item.on_found(user))
				return
	if(user.s_active == src)
		hide_from(user)
	user.client.screen -= boxes
	user.client.screen -= storage_start
	user.client.screen -= storage_continue
	user.client.screen -= storage_end
	user.client.screen -= closer
	user.client.screen -= parent.contents
	user.client.screen += closer
	user.client.screen += parent.contents

	if(storage_slots)
		user.client.screen += boxes
	else
		user.client.screen += storage_start
		user.client.screen += storage_continue
		user.client.screen += storage_end

	user.s_active = src
	content_watchers |= user


/datum/storage/proc/hide_from(mob/user as mob)

	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= storage_start
	user.client.screen -= storage_continue
	user.client.screen -= storage_end
	user.client.screen -= src.closer
	user.client.screen -= parent.contents
	if(user.s_active == src)
		user.s_active = null
	content_watchers -= user


/datum/storage/proc/can_see_content()
	var/list/lookers = list()
	for(var/i in content_watchers)
		var/mob/M = i
		if(M.s_active == src && M.client)
			lookers |= M
		else
			content_watchers -= M
	return lookers

/datum/storage/proc/open(mob/user)
	if(!opened)
		orient2hud()
		opened = 1
	if(use_sound && user.stat != DEAD)
		playsound(parent.loc, use_sound, 25, 1, 3)

	if(user.s_active == src)
		close(user)
	show_to(user)
	return TRUE


/datum/storage/proc/close(mob/user)
	hide_from(user)


///This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right. The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/datum/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/object in parent.contents)
		object.screen_loc = "[cx],[cy]"
		object.layer = ABOVE_HUD_LAYER
		object.plane = ABOVE_HUD_PLANE
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"
	if(show_storage_fullness)
		boxes.update_fullness(src)

/datum/numbered_display
	var/obj/item/sample_object
	var/number

/datum/numbered_display/New(obj/item/sample)
	if(!istype(sample))
		qdel(src)
	sample_object = sample
	number = 1

/datum/numbered_display/Destroy()
	sample_object = null
	return ..()

///This proc draws out the inventory and places the items on it. It uses the standard position.
/datum/storage/proc/slot_orient_objs(rows, cols, list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.mouse_opacity = 2
			ND.sample_object.screen_loc = "[cx]:16,[cy]:16"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.layer = ABOVE_HUD_LAYER
			ND.sample_object.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/object in parent.contents)
			object.mouse_opacity = 2 //So storage items that start with contents get the opacity trick.
			object.screen_loc = "[cx]:16,[cy]:16"
			object.maptext = ""
			object.layer = ABOVE_HUD_LAYER
			object.plane = ABOVE_HUD_PLANE
			cx++
			if(cx > (4+cols))
				cx = 4
				cy--
	closer.screen_loc = "[4+cols+1]:16,2:16"
	if(show_storage_fullness)
		boxes.update_fullness(src)

/datum/storage/proc/space_orient_objs(list/obj/item/display_contents)

	///should be equal to default backpack capacity
	var/baseline_max_storage_space = 21
	///length of sprite for start and end of the box representing total storage space
	var/storage_cap_width = 2
	///length of sprite for start and end of the box representing the stored item
	var/stored_cap_width = 4
	///length of sprite for the box representing total storage space
	var/storage_width = min( round( 258 * max_storage_space/baseline_max_storage_space ,1) ,284)

	click_border_start.Cut()
	click_border_end.Cut()
	storage_start.overlays.Cut()

	if(!opened) //initialize background box
		var/matrix/M = matrix()
		M.Scale((storage_width-storage_cap_width*2+3)/32,1)
		storage_continue.transform = M
		storage_start.screen_loc = "4:16,2:16"
		storage_continue.screen_loc = "4:[round(storage_cap_width+(storage_width-storage_cap_width*2)/2+2)],2:16"
		storage_end.screen_loc = "4:[19+storage_width-storage_cap_width],2:16"

	var/startpoint = 0
	var/endpoint = 1

	for(var/obj/item/object in parent.contents)
		startpoint = endpoint + 1
		endpoint += storage_width * object.w_class / max_storage_space

		click_border_start.Add(startpoint)
		click_border_end.Add(endpoint)

		var/matrix/M_start = matrix()
		var/matrix/M_continue = matrix()
		var/matrix/M_end = matrix()
		M_start.Translate(startpoint,0)
		M_continue.Scale((endpoint-startpoint-stored_cap_width*2)/32,1)
		M_continue.Translate(startpoint+stored_cap_width+(endpoint-startpoint-stored_cap_width*2)/2 - 16,0)
		M_end.Translate(endpoint-stored_cap_width,0)
		stored_start.transform = M_start
		stored_continue.transform = M_continue
		stored_end.transform = M_end
		storage_start.overlays += src.stored_start
		storage_start.overlays += src.stored_continue
		storage_start.overlays += src.stored_end

		object.screen_loc = "4:[round((startpoint+endpoint)/2)+2],2:16"
		object.maptext = ""
		object.layer = ABOVE_HUD_LAYER
		object.plane = ABOVE_HUD_PLANE

	closer.screen_loc = "4:[storage_width+19],2:16"

/datum/storage/proc/orient2hud()

	var/adjusted_contents = length(parent.contents)

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/item in parent.contents)
			var/found = 0
			for(var/datum/numbered_display/ND in numbered_contents)
				if(ND.sample_object.type == item.type)
					ND.number++
					found = 1
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add( new/datum/numbered_display(item) )

	if(storage_slots == null)
		src.space_orient_objs(numbered_contents)
	else
		var/row_num = 0
		var/col_count = min(7,storage_slots) -1
		if(adjusted_contents > 7)
			row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
		slot_orient_objs(row_num, col_count, numbered_contents)

///This proc return 1 if the item can be picked up and 0 if it can't. Set the warning to stop it from printing messages
/datum/storage/proc/can_be_inserted(obj/item/item_to_insert as obj, warning = TRUE)
	if(!istype(item_to_insert) || HAS_TRAIT(item_to_insert, TRAIT_NODROP))
		return //Not an item

	if(parent.loc == item_to_insert)
		return FALSE //Means the item is already in the storage item
	if(storage_slots != null && length(parent.contents) >= storage_slots)
		if(warning)
			to_chat(usr, span_notice("[src] is full, make some space."))
		return FALSE //Storage item is full

	if(length(can_hold))
		if(!is_type_in_typecache(item_to_insert, can_hold))
			if(warning)
				to_chat(usr, span_notice("[src] cannot hold [item_to_insert]."))
			return FALSE

	if(is_type_in_typecache(item_to_insert, cant_hold)) //Check for specific items which this container can't hold.
		if(warning)
			to_chat(usr, span_notice("[src] cannot hold [item_to_insert]."))
		return FALSE

	if(!is_type_in_typecache(item_to_insert, bypass_w_limit) && item_to_insert.w_class > max_w_class)
		if(warning)
			to_chat(usr, span_notice("[item_to_insert] is too long for this [src]."))
		return FALSE

	var/sum_storage_cost = item_to_insert.w_class
	for(var/obj/item/item in parent.contents)
		sum_storage_cost += item.w_class

	if(sum_storage_cost > max_storage_space)
		if(warning)
			to_chat(usr, span_notice("[src] is full, make some space."))
		return FALSE

	if(item_to_insert.w_class >= max_w_class && istype(item_to_insert, /obj/item/storage) && !is_type_in_typecache(item_to_insert.type, bypass_w_limit))
		if(!istype(src, /obj/item/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(warning)
				to_chat(usr, span_notice("[src] cannot hold [item_to_insert] as it's a storage item of the same size."))
			return FALSE //To prevent the stacking of same sized storage items.

	for(var/limited_type in storage_type_limits)
		if(!istype(item_to_insert, limited_type))
			continue
		if(storage_type_limits[limited_type] == 0)
			if(warning)
				to_chat(usr, span_warning("[src] can't fit any more of those.") )
			return FALSE

	if(istype(item_to_insert, /obj/item/tool/hand_labeler))
		var/obj/item/tool/hand_labeler/L = item_to_insert
		if(L.on)
			return FALSE
		else
			return TRUE

	return TRUE

/**
 * This proc handles the delay associated with a storage object.
 * If there is no delay, or the delay is negative, it simply returns TRUE.
 * Should return true if the access delay is completed successfully.
 */
/datum/storage/proc/handle_access_delay(obj/item/accessed, mob/user, taking_out = TRUE, alert_user = TRUE)
	if(!access_delay || !should_access_delay(accessed, user, taking_out))
		return TRUE

	if(LAZYLEN(user.do_actions))
		to_chat(user, span_warning("You are busy doing something else!"))
		return FALSE

	if(!alert_user)
		return do_after(user, access_delay, IGNORE_USER_LOC_CHANGE, src)

	to_chat(user, "<span class='notice'>You begin to [taking_out ? "take" : "put"] [accessed] [taking_out ? "out of" : "into"] [src]")
	if(!do_after(user, access_delay, IGNORE_USER_LOC_CHANGE, src))
		to_chat(user, span_warning("You fumble [accessed]!"))
		return FALSE
	return TRUE

/**
 * This proc checks to see if we should actually delay access in this scenario
 * This proc should return TRUE or FALSE
 */
/datum/storage/proc/should_access_delay(obj/item/accessed, mob/user, taking_out)
	return FALSE

/**
 * This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted.
 * That's done by can_be_inserted()
 * The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
 * such as when picking up all the items on a tile with one click.
 * user can be null, it refers to the potential mob doing the insertion.
 */
/datum/storage/proc/handle_item_insertion(obj/item/item, prevent_warning = 0, mob/user)
	if(!istype(item))
		return FALSE
	if(!handle_access_delay(item, user, taking_out=FALSE))
		item.forceMove(item.drop_location())
		return FALSE
	if(user && item.loc == user)
		if(!user.transferItemToLoc(item, src))
			return FALSE
	else
		item.forceMove(src)
	item.on_enter_storage(src)
	if(user)
		if(user.s_active != src)
			user.client?.screen -= item
		if(!prevent_warning)
			insertion_message(item, user)
	orient2hud()
	for(var/mob/M in can_see_content())
		show_to(M)
	if(storage_slots)
		item.mouse_opacity = 2 //not having to click the item's tiny sprite to take it out of the storage.
	parent.update_icon()
	for(var/limited_type in storage_type_limits)
		if(istype(item, limited_type))
			storage_type_limits[limited_type] -= 1
	return TRUE

///Output a message when an item is inserted into a storage object
/datum/storage/proc/insertion_message(obj/item/item, mob/user)
	var/visidist = item.w_class >= WEIGHT_CLASS_NORMAL ? 3 : 1
	user.visible_message(span_notice("[user] puts \a [item] into \the [parent.name]."),\
						span_notice("You put \the [item] into \the [parent.name]."),\
						null, visidist)

///Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/datum/storage/proc/remove_from_storage(obj/item/item, atom/new_location, mob/user)
	if(!istype(item))
		return FALSE

	if(!handle_access_delay(item, user))
		return FALSE

	for(var/mob/M AS in can_see_content())
		if(!M.client)
			continue
		M.client.screen -= item

	if(new_location)
		if(ismob(new_location))
			item.layer = ABOVE_HUD_LAYER
			item.plane = ABOVE_HUD_PLANE
			item.pickup(new_location)
		else
			item.layer = initial(item.layer)
			item.plane = initial(item.plane)
		item.forceMove(new_location)
	else
		item.moveToNullspace()

	orient2hud()

	for(var/i in can_see_content())
		var/mob/M = i
		show_to(M)

	if(!QDELETED(item))
		item.on_exit_storage(src)
		item.mouse_opacity = initial(item.mouse_opacity)

	parent.update_icon()

	for(var/limited_type in storage_type_limits)
		if(istype(item, limited_type))
			storage_type_limits[limited_type] += 1

	return TRUE

///This proc is called when you want to place an attacking_item into the storage
/datum/storage/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(length(refill_types))
		for(var/typepath in refill_types)
			if(istype(attacking_item, typepath))
				INVOKE_ASYNC(src, PROC_REF(do_refill), attacking_item, user)
				return

	if(!can_be_inserted(attacking_item))
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), attacking_item, FALSE, user)
	return

/datum/storage/proc/do_refill(obj/item/storage/refiller, mob/user)
	if(!length(refiller.contents))
		user.balloon_alert(user, "[refiller] is empty.")
		return

	if(!can_be_inserted(refiller.contents[1]))
		user.balloon_alert(user, "[src] is full.")
		return

	user.balloon_alert(user, "Refilling.")

	if(!do_after(user, 15, NONE, src, BUSY_ICON_GENERIC))
		return

	playsound(user.loc, refill_sound, 15, 1, 6)
	for(var/obj/item/IM in refiller)
		if(!can_be_inserted(refiller.contents[1]))
			return

		remove_from_storage(IM)
		handle_item_insertion(IM, TRUE, user)

/datum/storage/proc/quick_empty()

	if((!ishuman(usr) && parent.loc != usr) || usr.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	for(var/obj/item/item in parent.contents)
		remove_from_storage(item, T, usr)

///Delete everything that's inside the storage
/datum/storage/proc/delete_contents()
	for(var/obj/item/item AS in parent.contents)
		item.on_exit_storage(src)
		qdel(item)

/**
 * Attempts to get the first possible object from this container
 *
 * Arguments:
 * * mob/living/user - The mob attempting to draw from this container
 * * start_from_left - If true we draw the leftmost object instead of the rightmost. FALSE by default.
 */
/datum/storage/proc/attempt_draw_object(mob/living/user, start_from_left = FALSE)
	if(!ishuman(user) || user.incapacitated() || isturf(parent.loc))
		return
	if(!length(parent.contents))
		return user.balloon_alert(user, "Empty")
	if(user.get_active_held_item())
		return //User is already holding something.
	var/obj/item/drawn_item = start_from_left ? parent.contents[1] : parent.contents[length(parent.contents)]
	drawn_item.attack_hand(user)



