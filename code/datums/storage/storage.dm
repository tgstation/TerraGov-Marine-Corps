/*!
 * Datumized Storage
 * Eliminates the need for custom signals specifically for the storage component, and attaches a storage variable (storage_datum) to every atom.
 */

///Helper proc to give something storage
/atom/proc/create_storage(storage_type = /datum/storage, list/canhold, list/canthold, list/storage_type_limits)
	RETURN_TYPE(/datum/storage)

	if(storage_datum)
		QDEL_NULL(storage_datum)

	storage_datum = new storage_type(src)

	if(canhold || canthold)
		storage_datum.set_holdable(canhold, canthold, storage_type_limits)

	return storage_datum

// The parent and real_location variables are both weakrefs, so they must be resolved before they can be used.
/datum/storage
	/**
	 * A reference to the atom linked to this storage object
	 * If the parent goes, we go. Will never be null.
	 */
	VAR_FINAL/atom/parent
	/**
	 * A reference to the atom where the items are actually stored.
	 * By default this is parent. Should generally never be null.
	 * Sometimes it's not the parent, that's what is called "dissassociated storage".
	 *
	 * Do NOT set this directly, use set_real_location.
	 */
	VAR_FINAL/atom/real_location

	/// Typecache of items that can be inserted into this storage.
	/// By default, all item types can be inserted (assuming other conditions are met).
	/// Do not set directly, use set_holdable
	VAR_FINAL/list/obj/item/can_hold
	/// Typecache of items that cannot be inserted into this storage.
	/// By default, no item types are barred from insertion.
	/// Do not set directly, use set_holdable
	VAR_FINAL/list/obj/item/cant_hold
	/// Typecache of items that can always be inserted into this storage, regardless of size.
	VAR_FINAL/list/obj/item/storage_type_limits

	/**
	 * Associated list of types and their max count, formatted as
	 * 	storage_type_limits_max = list(
	 * 		/obj/A = 3,
	 * 	)
	 *
	 * Any inserted objects will decrement the allowed count of every listed type which matches or is a parent of that object.
	 * With entries for both /obj/A and /obj/A/B, inserting a B requires non-zero allowed count remaining for, and reduces, both.
	 */
	VAR_FINAL/list/storage_type_limits_max
	///Max size of objects that this object can store (in effect only if canhold isn't set)
	var/max_w_class = WEIGHT_CLASS_SMALL
	///The sum of the storage costs of all the items in this storage item.
	var/max_storage_space = 14
	///The number of storage slots in this container.
	var/storage_slots = 7
	///Defines how many versions of the sprites that gets progressively emptier as they get closer to "_0" in .dmi.
	var/sprite_slots = null

	///In slotless storage, stores areas where clicking will refer to the associated item
	var/list/click_border_start = list()
	///In slotless storage, stores areas where clicking will refer to the associated item
	var/list/click_border_end = list()
	///storage UI
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
	var/use_to_pickup = FALSE
	///Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_empty
	///Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/allow_quick_gather
	///whether this object can change its drawing method
	var/allow_drawing_method
	///FALSE = will open the inventory if you click on the storage container, TRUE = will draw from the inventory if you click on the storage container
	var/draw_mode = FALSE
	///FALSE = pick one at a time, TRUE = pick all on tile
	var/collection_mode = TRUE
	///BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	var/foldable = null
	///sound played when used. null for no sound.
	var/use_sound = SFX_RUSTLE
	///Has it been opened before?
	var/opened = FALSE
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
	///flags for special behaviours
	var/storage_flags = NONE

	//---- Holster vars
	///the sound produced when the special item is drawn
	var/draw_sound = null
	///the sound produced when the special item is sheathed
	var/sheathe_sound = null
	///the snowflake item(s) that will update the sprite.
	var/list/holsterable_allowed = list()
	///records the specific special item currently in the holster
	var/obj/holstered_item = null
	///Image that get's underlayed under the sprite of the holster
	var/image/holstered_item_underlay


/datum/storage/New(atom/parent)
	. = ..()
	if(!istype(parent))
		stack_trace("Storage datum ([type]) created without a [isnull(parent) ? "null parent" : "invalid parent ([parent.type])"]!")
		qdel(src)
		return

	set_parent(parent)

	boxes = new()
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	SET_PLANE_EXPLICIT(boxes, HUD_PLANE, parent)

	storage_start = new /atom/movable/screen/storage()
	storage_start.name = "storage"
	storage_start.master = src
	storage_start.icon_state = "storage_start"
	storage_start.screen_loc = "7,7 to 10,8"
	SET_PLANE_EXPLICIT(storage_start, HUD_PLANE, parent)
	storage_continue = new /atom/movable/screen/storage()
	storage_continue.name = "storage"
	storage_continue.master = src
	storage_continue.icon_state = "storage_continue"
	storage_continue.screen_loc = "7,7 to 10,8"
	SET_PLANE_EXPLICIT(storage_continue, HUD_PLANE, parent)

	storage_end = new /atom/movable/screen/storage()
	storage_end.name = "storage"
	storage_end.master = src
	storage_end.icon_state = "storage_end"
	storage_end.screen_loc = "7,7 to 10,8"
	SET_PLANE_EXPLICIT(storage_end, HUD_PLANE, parent)

	stored_start = new /obj() //we just need these to hold the icon
	stored_start.icon_state = "stored_start"
	SET_PLANE_EXPLICIT(stored_start, HUD_PLANE, parent)

	stored_continue = new /obj()
	stored_continue.icon_state = "stored_continue"
	SET_PLANE_EXPLICIT(stored_continue, HUD_PLANE, parent)

	stored_end = new /obj()
	stored_end.icon_state = "stored_end"
	SET_PLANE_EXPLICIT(stored_end, HUD_PLANE, parent)

	closer = new()
	closer.master = src

/datum/storage/Destroy(force = FALSE, ...)
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
	if(holstered_item)
		QDEL_NULL(holstered_item)
	if(trash_item)
		new trash_item(get_turf(parent))
	parent = null
	return ..()

/// Set the passed atom as the parent
/datum/storage/proc/set_parent(atom/new_parent)
	PRIVATE_PROC(TRUE)

	ASSERT(isnull(parent))

	parent = new_parent

	register_storage_signals(parent) //Registers all our relevant signals, separate proc because some subtypes have conflicting signals

/// Registers signals to parent
/datum/storage/proc/register_storage_signals(atom/parent)
	//----Clicking signals
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby)) //Left click
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand)) //Left click empty hand
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self)) //Item clicking on itself
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, PROC_REF(on_attack_hand_alternate)) //Right click empty hand
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(on_alt_click)) //ALT + click
	RegisterSignal(parent, COMSIG_CLICK_ALT_RIGHT, PROC_REF(on_alt_right_click)) //ALT + right click
	RegisterSignal(parent, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click)) //CTRL + Left click
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_GHOST, PROC_REF(on_attack_ghost)) //Ghosts can see inside your storages
	RegisterSignal(parent, COMSIG_MOUSEDROP_ONTO, PROC_REF(on_mousedrop_onto)) //Click dragging

	//----Something is happening to our storage
	RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp)) //Getting EMP'd
	RegisterSignal(parent, COMSIG_CONTENTS_EX_ACT, PROC_REF(on_contents_explode)) //Getting exploded

	RegisterSignal(parent, COMSIG_ATOM_CONTENTS_DEL, PROC_REF(handle_atom_del))
	RegisterSignal(parent, ATOM_MAX_STACK_MERGING, PROC_REF(max_stack_merging))
	RegisterSignal(parent, ATOM_RECALCULATE_STORAGE_SPACE, PROC_REF(recalculate_storage_space))
	RegisterSignals(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), PROC_REF(update_verbs))
	RegisterSignal(parent, COMSIG_ITEM_QUICK_EQUIP, PROC_REF(on_quick_equip_request))
	RegisterSignal(parent, COMSIG_ATOM_INITIALIZED_ON, PROC_REF(item_init_in_parent))

///Unregisters our signals from parent. Used when parent loses storage but is not destroyed
/datum/storage/proc/unregister_storage_signals(atom/parent)
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ITEM_ATTACK_SELF,
		COMSIG_ATOM_ATTACK_HAND_ALTERNATE,
		COMSIG_CLICK_ALT,
		COMSIG_CLICK_ALT_RIGHT,
		COMSIG_CLICK_CTRL,
		COMSIG_ATOM_ATTACK_GHOST,
		COMSIG_MOUSEDROP_ONTO,

		COMSIG_ATOM_EMP_ACT,
		COMSIG_CONTENTS_EX_ACT,

		COMSIG_ATOM_CONTENTS_DEL,
		ATOM_MAX_STACK_MERGING,
		ATOM_RECALCULATE_STORAGE_SPACE,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_QUICK_EQUIP,
		COMSIG_ATOM_INITIALIZED_ON,
	))

/// Almost 100% of the time the lists passed into set_holdable are reused for each instance
/// Just fucking cache it 4head
/// Yes I could generalize this, but I don't want anyone else using it. in fact, DO NOT COPY THIS
/// If you find yourself needing this pattern, you're likely better off using static typecaches
/// I'm not because I do not trust implementers of the storage component to use them, BUT
/// IF I FIND YOU USING THIS PATTERN IN YOUR CODE I WILL BREAK YOU ACROSS MY KNEES
/// ~Lemon
GLOBAL_LIST_EMPTY(cached_storage_typecaches)

/datum/storage/proc/set_holdable(list/can_hold_list, list/cant_hold_list, list/storage_type_limits_list)
	if(!isnull(can_hold_list) && !islist(can_hold_list))
		can_hold_list = list(can_hold_list)
	if(!isnull(cant_hold_list) && !islist(cant_hold_list))
		cant_hold_list = list(cant_hold_list)
	if(!isnull(storage_type_limits_list) && !islist(storage_type_limits_list))
		storage_type_limits_list = list(storage_type_limits_list)

	if(!isnull(can_hold_list) && !isnull(storage_type_limits_list)) //Making sure can_hold_list also includes the things that bypass our w_class
		can_hold_list += storage_type_limits_list

	if(!isnull(can_hold_list)) //Limits what can be held to what is in this list
		var/unique_key = can_hold_list.Join("-")
		if(!GLOB.cached_storage_typecaches[unique_key])
			GLOB.cached_storage_typecaches[unique_key] = typecacheof(can_hold_list)
		can_hold = GLOB.cached_storage_typecaches[unique_key]

	if(!isnull(cant_hold_list)) //Sets what cannot be held, regardless of if it is on the other lists
		var/unique_key = cant_hold_list.Join("-")
		if(!GLOB.cached_storage_typecaches[unique_key])
			GLOB.cached_storage_typecaches[unique_key] = typecacheof(cant_hold_list)
		cant_hold = GLOB.cached_storage_typecaches[unique_key]

	if(!isnull(storage_type_limits_list)) //Permits items to bypass w_class
		var/unique_key = storage_type_limits_list.Join("-")
		if(!GLOB.cached_storage_typecaches[unique_key])
			GLOB.cached_storage_typecaches[unique_key] = typecacheof(storage_type_limits_list)
		storage_type_limits = GLOB.cached_storage_typecaches[unique_key]

///This proc is called when you want to place an attacking_item into the storage
/datum/storage/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER
	if(length(refill_types))
		for(var/typepath in refill_types)
			if(istype(attacking_item, typepath))
				INVOKE_ASYNC(src, PROC_REF(do_refill), attacking_item, user)
				return
	if(!can_be_inserted(attacking_item, user))
		if(user.s_active != src) //this would close the open storage otherwise
			open(user)
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), attacking_item, FALSE, user)
	return COMPONENT_NO_AFTERATTACK

///Called when you click on parent with an empty hand
/datum/storage/proc/on_attack_hand(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(parent.loc == user || parent.loc.loc == user)
		var/obj/item/item_to_attack = source
		if(item_to_attack.item_flags & IN_STORAGE)
			return //We don't want to open nested storage on left click, on_alt_click() should be the standard "Always open"
		if(holstered_item in parent.contents)
			item_to_attack = holstered_item
			INVOKE_ASYNC(item_to_attack, TYPE_PROC_REF(/atom/movable, attack_hand), user)
			return COMPONENT_NO_ATTACK_HAND
		if(draw_mode && ishuman(user) && length(parent.contents))
			item_to_attack = parent.contents[length(parent.contents)]
			INVOKE_ASYNC(item_to_attack, TYPE_PROC_REF(/atom/movable, attack_hand), user)
			return COMPONENT_NO_ATTACK_HAND
		else if(open(user))
			return COMPONENT_NO_ATTACK_HAND
	for(var/mob/M AS in content_watchers)
		close(M)
		return


/**
 * Called when you RIGHT click on parent with an empty hand
 * Attempts to draw an object from our storage
 */
/datum/storage/proc/on_attack_hand_alternate(datum/source, mob/living/user)
	SIGNAL_HANDLER
	if(parent.Adjacent(user))
		INVOKE_ASYNC(src, PROC_REF(attempt_draw_object), user)

/**
 * Called when you alt + left click on parent
 * Attempts to draw an object from our storage
 */

/datum/storage/proc/on_alt_click(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.Adjacent(user))
		INVOKE_ASYNC(src, PROC_REF(attempt_draw_object), user)

/**
 * Called when you alt + right click on parent
 * Opens the inventory of our storage
 */

/datum/storage/proc/on_alt_right_click(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.Adjacent(user))
		open(user)

/**
 * Called when you ctrl + left click on parent
 * Attempts to draw an object from out storage, but it draw from the left side instead of the right
 */
/datum/storage/proc/on_ctrl_click(datum/source, mob/user)
	SIGNAL_HANDLER
	if(parent.Adjacent(user))
		INVOKE_ASYNC(src, PROC_REF(attempt_draw_object), user, TRUE)

/datum/storage/proc/on_attack_ghost(datum/source, mob/user)
	SIGNAL_HANDLER
	open(user)

///Signal handler for when you click drag parent to something (usually ourselves or an inventory slot)
/datum/storage/proc/on_mousedrop_onto(datum/source, obj/over_object as obj, mob/user)
	SIGNAL_HANDLER
	if(!ishuman(user))
		return COMPONENT_NO_MOUSEDROP

	if(user.lying_angle)
		return COMPONENT_NO_MOUSEDROP

	if(over_object == user && parent.Adjacent(user)) // this must come before the screen objects only block
		open(user)
		return COMPONENT_NO_MOUSEDROP

	if(!istype(over_object, /atom/movable/screen))
		return //Don't cancel mousedrop

	if(HAS_TRAIT(src, TRAIT_NODROP))
		return COMPONENT_NO_MOUSEDROP

	//Makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
	if(parent.loc != user && parent.loc.loc != user) //loc.loc handles edge case of storage attached to an item attached to another item (modules/boots)
		return COMPONENT_NO_MOUSEDROP

	if(user.restrained() || user.stat)
		return COMPONENT_NO_MOUSEDROP

	put_storage_in_hand(source, over_object, user)
	return COMPONENT_NO_MOUSEDROP

///Wrapper that puts the storage into our chosen hand
/datum/storage/proc/put_storage_in_hand(datum/source, obj/over_object, mob/living/carbon/human/user)
	switch(over_object.name)
		if("r_hand")
			INVOKE_ASYNC(src, PROC_REF(put_item_in_r_hand), source, user)
		if("l_hand")
			INVOKE_ASYNC(src, PROC_REF(put_item_in_l_hand), source, user)

///Removes item_to_put_in_hand from the storage it's currently in, and then places it into our right hand
/datum/storage/proc/put_item_in_r_hand(obj/item/item_to_put_in_hand, mob/user)
	if(item_to_put_in_hand.item_flags & IN_STORAGE)
		if(!item_to_put_in_hand.loc.storage_datum.remove_from_storage(item_to_put_in_hand, user, user))
			return
	user.temporarilyRemoveItemFromInventory(item_to_put_in_hand)
	if(!user.put_in_r_hand(item_to_put_in_hand))
		user.dropItemToGround(item_to_put_in_hand)

///Removes item_to_put_in_hand from the storage it's currently in, and then places it into our left hand
/datum/storage/proc/put_item_in_l_hand(obj/item/item_to_put_in_hand, mob/user)
	if(item_to_put_in_hand.item_flags & IN_STORAGE)
		if(!item_to_put_in_hand.loc.storage_datum.remove_from_storage(item_to_put_in_hand, user, user))
			return
	user.temporarilyRemoveItemFromInventory(item_to_put_in_hand)
	if(!user.put_in_l_hand(item_to_put_in_hand))
		user.dropItemToGround(item_to_put_in_hand)

/datum/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "IC.Object"

	collection_mode = !collection_mode
	if(collection_mode)
		to_chat(usr, "[parent.name] now picks up all items in a tile at once.")
	else
		to_chat(usr, "[parent.name] now picks up one item at a time.")

/datum/storage/verb/toggle_draw_mode()
	set name = "Switch Storage Drawing Method"
	set category = "IC.Object"

	draw_mode = !draw_mode
	if(draw_mode)
		to_chat(usr, "Clicking [parent.name] with an empty hand now puts the last stored item in your hand.")
	else
		to_chat(usr, "Clicking [parent.name] with an empty hand now opens the pouch storage menu.")

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
			atom.storage_datum?.return_inv(recursive = TRUE)

	return inventory

///Shows our inventory to user, we become s_active and user is added to our content_watchers
/datum/storage/proc/show_to(mob/user)
	if(user.s_active != src)
		for(var/obj/item/item in parent)
			if(item.on_found(user))
				return
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

///Hides our inventory from user, sets s_active to null and removes user from content_watchers
/datum/storage/proc/hide_from(mob/user)
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

///Returns a list of lookers, basically any mob that can see our contents
/datum/storage/proc/can_see_content()
	var/list/lookers = list()
	for(var/mob/content_watcher_mob AS in content_watchers)
		if(!ismob(content_watcher_mob) || !content_watcher_mob.client || content_watcher_mob.s_active != src)
			content_watchers -= content_watcher_mob
			continue
		lookers |= content_watcher_mob
	return lookers

///Opens our storage, closes the storage if we are s_active
/datum/storage/proc/open(mob/user)
	if(!opened)
		orient2hud()
		opened = TRUE
	if(use_sound && user.stat != DEAD)
		playsound(parent.loc, use_sound, 25, 1, 3)

	if(user.s_active == src) //If active storage is already open, close it
		close(user)
		return TRUE
	if(user.s_active) //We can only have 1 active storage at once
		user.s_active.close(user)
	show_to(user)
	return TRUE

///Closes our storage
/datum/storage/proc/close(mob/user)
	hide_from(user)

/**
 * This proc draws out the inventory and places the items on it.
 * tx and ty are the upper left tile and
 * mx, my are the bottm right.
 * The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
 */
/datum/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/object in parent.contents)
		object.screen_loc = "[cx],[cy]"
		SET_PLANE_IMPLICIT(object, ABOVE_HUD_PLANE)
		cx++
		if(cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"
	if(show_storage_fullness)
		boxes.update_fullness(parent)

///This proc draws out the inventory and places the items on it. It uses the standard position.
/datum/storage/proc/slot_orient_objs(rows, cols)
	var/cx = 4
	var/cy = 2+rows
	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	for(var/obj/object in parent.contents)
		object.mouse_opacity = 2 //So storage items that start with contents get the opacity trick.
		object.screen_loc = "[cx]:16,[cy]:16"
		object.maptext = ""
		SET_PLANE_IMPLICIT(object, ABOVE_HUD_PLANE)
		cx++
		if(cx > (4+cols))
			cx = 4
			cy--
	closer.screen_loc = "[4+cols+1]:16,2:16"
	if(show_storage_fullness)
		boxes.update_fullness(parent)

///Generates a UI for slotless storage based on the objects inside of it
/datum/storage/proc/space_orient_objs()
	// should be equal to default backpack capacity
	var/baseline_max_storage_space = 21
	// length of sprite for start and end of the box representing total storage space
	var/storage_cap_width = 2
	// length of sprite for start and end of the box representing the stored item
	var/stored_cap_width = 4
	// length of sprite for the box representing total storage space
	var/storage_width = min(round(258 * max_storage_space/baseline_max_storage_space, 1), 284)

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

	// TODO: this is very inefficient. we should instead be adding 3 overlays offset with pixel_x to
	// the item and remove the click border code.
	// the matrix spam is prolly why this is one of our highest overtiming procs...
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
		SET_PLANE_IMPLICIT(object, ABOVE_HUD_PLANE)

	closer.screen_loc = "4:[storage_width+19],2:16"

///This proc determines the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/datum/storage/proc/orient2hud()
	var/adjusted_contents = length(parent.contents)

	if(storage_slots == null)
		space_orient_objs()
		return

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	slot_orient_objs(row_num, col_count)

///This proc return 1 if the item can be picked up and 0 if it can't. Set the warning to stop it from printing messages
/datum/storage/proc/can_be_inserted(obj/item/item_to_insert, mob/user, warning = TRUE)
	if(!istype(item_to_insert) || HAS_TRAIT(item_to_insert, TRAIT_NODROP))
		return //Not an item

	if(parent.loc == item_to_insert)
		return FALSE //Means the item is already in the storage item
	if(storage_slots != null && length(parent.contents) >= storage_slots)
		if(warning)
			to_chat(user, span_notice("\The [parent.name] is full, make some space."))
		return FALSE //Storage item is full

	if(length(can_hold) && !is_type_in_typecache(item_to_insert, typecacheof(can_hold)))
		if(warning)
			to_chat(user, span_notice("\The [parent.name] cannot hold [item_to_insert]."))
		return FALSE

	if(is_type_in_typecache(item_to_insert, typecacheof(cant_hold))) //Check for specific items which this container can't hold.
		if(warning)
			to_chat(user, span_notice("\The [parent.name] cannot hold [item_to_insert]."))
		return FALSE

	if(!is_type_in_typecache(item_to_insert, typecacheof(storage_type_limits)) && item_to_insert.w_class > max_w_class)
		if(warning)
			to_chat(user, span_notice("[item_to_insert] is too long for this [parent.name]."))
		return FALSE

	var/sum_storage_cost = item_to_insert.w_class
	for(var/obj/item/item in parent.contents)
		sum_storage_cost += item.w_class

	if(sum_storage_cost > max_storage_space)
		if(warning)
			to_chat(user, span_notice("\The [parent.name] is full, make some space."))
		return FALSE

	if(isitem(parent))
		var/obj/item/parent_storage = parent
		if(item_to_insert.w_class >= parent_storage.w_class && istype(item_to_insert, /obj/item/storage) && !is_type_in_typecache(item_to_insert.type, typecacheof(storage_type_limits)))
			if(!istype(src, /obj/item/storage/backpack/holding)) //bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
				if(warning)
					to_chat(user, span_notice("\The [parent.name] cannot hold \the [item_to_insert] as it's a storage item of the same size."))
				return FALSE //To prevent the stacking of same sized storage items.

	for(var/limited_type in storage_type_limits_max)
		if(!istype(item_to_insert, limited_type))
			continue
		if(storage_type_limits_max[limited_type] == 0)
			if(warning)
				to_chat(user, span_warning("\The [parent.name] can't fit any more of those.") )
			return FALSE

	if(istype(item_to_insert, /obj/item/tool/hand_labeler))
		var/obj/item/tool/hand_labeler/L = item_to_insert
		if(L.on)
			return FALSE

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
		return do_after(user, access_delay, IGNORE_USER_LOC_CHANGE, parent)

	to_chat(user, "<span class='notice'>You begin to [taking_out ? "take" : "put"] [accessed] [taking_out ? "out of" : "into"] \the [parent.name]")
	if(!do_after(user, access_delay, IGNORE_USER_LOC_CHANGE, parent))
		to_chat(user, span_warning("You fumble [accessed]!"))
		return FALSE
	return TRUE

/**
 * This proc checks to see if we should actually delay access in this scenario
 * This proc should return TRUE or FALSE
 */
/datum/storage/proc/should_access_delay(obj/item/accessed, mob/user, taking_out)
	return FALSE

///Stores an item properly if its spawned directly into parent
/datum/storage/proc/item_init_in_parent(datum/source, obj/item/new_item)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(handle_item_insertion), new_item)

/**
 * This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted.
 * That's done by can_be_inserted()
 * The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
 * such as when picking up all the items on a tile with one click.
 * user can be null, it refers to the potential mob doing the insertion.
 */
/datum/storage/proc/handle_item_insertion(obj/item/item, prevent_warning = FALSE, mob/user) //todo: this isnt called when spawning some populated items. lacking INVOKE_ASYNC(storage_datum, TYPE_PROC_REF(/datum/storage, handle_item_insertion), new_item)
	if(!istype(item))
		return FALSE
	if(!handle_access_delay(item, user, taking_out = FALSE))
		item.forceMove(item.drop_location())
		return FALSE
	if(user && item.loc == user)
		if(!user.transferItemToLoc(item, parent))
			return FALSE
	else
		item.forceMove(parent)
	RegisterSignal(item, COMSIG_MOVABLE_MOVED, PROC_REF(item_removed_from_storage))
	item.on_enter_storage(parent)
	if(length(holsterable_allowed))
		for(var/holsterable_item in holsterable_allowed) //If our item is our snowflake item, it gets set as holstered_item
			if(!istype(item, holsterable_item))
				continue
			holstered_item = item
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
	for(var/limited_type in storage_type_limits_max)
		if(istype(item, limited_type))
			storage_type_limits_max[limited_type] -= 1
	return TRUE

///Output a message when an item is inserted into a storage object
/datum/storage/proc/insertion_message(obj/item/item, mob/user)
	var/visidist = item.w_class >= WEIGHT_CLASS_NORMAL ? 3 : 1
	user.visible_message(span_notice("[user] puts \a [item] into \the [parent.name]."),\
						span_notice("You put \the [item] into \the [parent.name]."),\
						null, visidist)

/**
 * Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
 *
 * Arguments:
 * * item: the item that is getting removed
 * * new_location: where the item is being sent to
 * * user: whoever/whatever is calling this proc
 * * silent: defaults to FALSE, on subtypes this is used to prevent a sound from being played
 * * bypass_delay: if TRUE, will bypass draw delay
 */
/datum/storage/proc/remove_from_storage(obj/item/item, atom/new_location, mob/user, silent = FALSE, bypass_delay = FALSE, move_item = TRUE)
	if(!istype(item))
		return FALSE

	if(!bypass_delay && !handle_access_delay(item, user))
		return FALSE

	for(var/mob/M AS in can_see_content())
		if(!M.client)
			continue
		M.client.screen -= item

	if(!QDELETED(item))
		UnregisterSignal(item, COMSIG_MOVABLE_MOVED)
		item.on_exit_storage(src)
		item.mouse_opacity = initial(item.mouse_opacity)

	if(new_location)
		if(ismob(new_location))
			SET_PLANE_EXPLICIT(item, ABOVE_HUD_PLANE, user)
			item.pickup(new_location)
		else
			item.layer = initial(item.layer)
			SET_PLANE_IMPLICIT(item, initial(item.plane))
		if(move_item)
			item.forceMove(new_location)
	else if(move_item)
		item.moveToNullspace()

	orient2hud()

	for(var/i in can_see_content())
		var/mob/M = i
		show_to(M)

	for(var/limited_type in storage_type_limits_max)
		if(istype(item, limited_type))
			storage_type_limits_max[limited_type] += 1

	parent.update_icon()

	return TRUE

///Refills the storage from the refill_types item
/datum/storage/proc/do_refill(obj/item/storage/refiller, mob/user)
	if(!length(refiller.contents))
		user.balloon_alert(user, "refilling container is empty!")
		return

	if(!can_be_inserted(refiller.contents[1], user))
		user.balloon_alert(user, "receiving container is full!")
		return

	user.balloon_alert(user, "refilling...")

	if(!do_after(user, 1.5 SECONDS, NONE, user, BUSY_ICON_GENERIC))
		return

	playsound(user.loc, refill_sound, 15, 1, 6)
	for(var/obj/item/IM in refiller)
		if(!can_be_inserted(refiller.contents[1], user))
			return

		refiller.storage_datum.remove_from_storage(IM)
		handle_item_insertion(IM, TRUE, user)

///Dumps out the contents of our inventory onto our turf
/datum/storage/proc/quick_empty(datum/source, mob/user)
	if((!ishuman(user) && parent.loc != user) || user.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(user)
	for(var/obj/item/item in parent.contents)
		remove_from_storage(item, T, user)

///Delete everything that's inside the storage
/datum/storage/proc/delete_contents()
	for(var/obj/item/item in parent.contents)
		if(item.item_flags & IN_STORAGE)
			item.on_exit_storage(src)
			qdel(item)

///Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area). Returns -1 if the atom was not found on container.
/datum/storage/proc/storage_depth(atom/container)
	var/depth = 0
	var/obj/item/current_item = src

	while(current_item && !(current_item in container.contents))
		if(isarea(current_item))
			return -1
		if(current_item.item_flags & IN_STORAGE)
			depth++
		current_item = current_item.loc

	if(!current_item)
		return -1	//inside something with a null loc.

	return depth

///Like storage depth, but returns the depth to the nearest turf. Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/datum/storage/proc/storage_depth_turf()
	var/depth = 0
	var/obj/item/current_item = src

	while(current_item && !isturf(current_item))
		if(isarea(current_item))
			return -1
		if(current_item.item_flags & IN_STORAGE)
			depth++
		current_item = current_item.loc

	if(!current_item)
		return -1	//inside something with a null loc.

	return depth

///Equips an item from our storage, returns signal COMSIG_QUICK_EQUIP_HANDLED to prevent standard quick equip behaviour
/datum/storage/proc/on_quick_equip_request(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!length(parent.contents)) //we don't want to equip the storage item itself
		return COMSIG_QUICK_EQUIP_BLOCKED
	INVOKE_ASYNC(src, PROC_REF(attempt_draw_object), user)
	return COMSIG_QUICK_EQUIP_HANDLED

///Called whenever parent is hit by an EMP, effectively EMPs everything inside your storage
/datum/storage/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER
	for(var/obj/stored_object in parent.contents)
		stored_object.emp_act(severity)

///BubbleWrap - Called when the parent clicks on itself. Used mostly to fold empty boxes
/datum/storage/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	if(allow_quick_empty)
		INVOKE_ASYNC(src, PROC_REF(quick_empty), user)
		return

	if(!foldable) //Gotta be foldable to be folded obviously
		return

	if(length(parent.contents)) //Can't fold, box not empty
		return

	// Close any open UI windows first
	for(var/mob/watcher_mob AS in content_watchers)
		close(watcher_mob)

	// Now make the cardboard
	to_chat(user, span_notice("You break down the [parent]."))
	new foldable(get_turf(parent))
	qdel(parent)
//BubbleWrap END

///signal sent from /atom/proc/handle_atom_del(atom/A)
/datum/storage/proc/handle_atom_del(datum/source, atom/movable/movable_atom)
	SIGNAL_HANDLER
	if(isitem(movable_atom))
		INVOKE_ASYNC(src, PROC_REF(remove_from_storage), movable_atom, null, usr, silent = TRUE, bypass_delay = TRUE)

///Handles if the item is forcemoved out of storage
/datum/storage/proc/item_removed_from_storage(obj/item/item)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(remove_from_storage), item, item.loc, null, FALSE, TRUE, FALSE)

///signal sent from /atom/proc/max_stack_merging()
/datum/storage/proc/max_stack_merging(datum/source, obj/item/stack/stacks)
	if(is_type_in_typecache(stacks, typecacheof(storage_type_limits)))
		return FALSE //No need for limits if we can bypass it.
	var/weight_diff = initial(stacks.w_class) - max_w_class
	if(weight_diff <= 0)
		return FALSE //Nor if the limit is not higher than what we have.
	var/max_amt = round((stacks.max_amount / STACK_WEIGHT_STEPS) * (STACK_WEIGHT_STEPS - weight_diff)) //How much we can fill per weight step times the valid steps.
	if(max_amt <= 0 || max_amt > stacks.max_amount)
		stack_trace("[parent.name] tried to max_stack_merging([stacks]) with [max_w_class] max_w_class and [weight_diff] weight_diff, resulting in [max_amt] max_amt.")
	return max_amt

///Called from signal in order to update the color of our storage, it's "fullness" basically
/datum/storage/proc/recalculate_storage_space(datum/source)
	SIGNAL_HANDLER
	var/list/lookers = can_see_content()
	if(!length(lookers))
		return
	orient2hud()
	for(var/X AS in lookers)
		var/mob/looker_mob = X //There is no need to typecast here, really, but for clarity.
		show_to(looker_mob)

///handles explosions on parent exploding the things in storage
/datum/storage/proc/on_contents_explode(datum/source, severity)
	SIGNAL_HANDLER
	for(var/stored_items AS in parent.contents)
		var/atom/atom = stored_items
		atom.ex_act(severity)

///Updates our verbs if we are equipped
/datum/storage/proc/update_verbs(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	var/obj/item/parent_item = parent
	if(allow_quick_gather)
		if(parent_item.item_flags & IN_INVENTORY)
			parent.verbs += /datum/storage/verb/toggle_gathering_mode
		else
			parent.verbs -= /datum/storage/verb/toggle_gathering_mode

	if(allow_drawing_method)
		if(parent_item.item_flags & IN_INVENTORY)
			parent.verbs += /datum/storage/verb/toggle_draw_mode
		else
			parent.verbs -= /datum/storage/verb/toggle_draw_mode

/**
 * Attempts to get the first possible object from this container
 *
 * Arguments:
 * * mob/living/user - The mob attempting to draw from this container
 * * start_from_left - If true we draw the leftmost object instead of the rightmost. FALSE by default.
 */
/datum/storage/proc/attempt_draw_object(mob/living/user, start_from_left = FALSE)
	if(!ishuman(user) || user.incapacitated())
		return
	if(!length(parent.contents))
		return user.balloon_alert(user, "empty!")
	if(user.get_active_held_item())
		return //User is already holding something.
	if(holsterable_allowed && holstered_item) //If we have a holstered item in parent contents
		if(holstered_item in parent.contents)
			holstered_item.attack_hand(user)
			return
	var/obj/item/drawn_item = start_from_left ? parent.contents[1] : parent.contents[length(parent.contents)]
	drawn_item.attack_hand(user)
