// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu

/obj/item/storage
	name = "storage"
	icon = 'icons/obj/items/storage/storage.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	var/flags_storage = STORAGE_FLAG_FULLNESS_VISIBLE

	/**
	 * A list of all things that WILL spawn inside of this storage object on creation.
	 * Can either be an assosciative list of items to add, or a simple list of singular items.
	 *
	 * Format:
	 * 	list(
	 *   /obj/item/XXX = 1,
	 *   /obj/item/XXX = 2,
	 * 	)
	 * OR
	 * 	list(
	 * 	 /obj/item/XXX,
	 *   /obj/item/XXX,
	 * 	)
	 *
	 * It is generally better to use the first format if you reduce four or more lines of code doing so.
	 * Remember that if an item would only be spawned once it takes a single list entry for the latter format but two for the former!
	 */
	var/list/spawns_with

	/**
	 * A list of all things that CAN spawn inside of this storage object on creation.
	 *
	 * Format:
	 *  list(
	 * 	 list(PROBABILITY, /obj/item/XXX, /obj/item/XXX),
	 * 	 list(PROBABILITY, /obj/item/XXX, /obj/item/XXX),
	 * 	)
	 */
	var/list/spawns_prob

	///The maxiumum number of lists that can roll upon creation. Lower probability will override higher, if they both roll
	var/spawns_prob_max = INFINITY
	///List of objects which this item can store (if set, it can't store anything else)
	var/list/can_hold = list()
	///List of objects which this item can't store (in effect only if can_hold isn't set)
	var/list/cant_hold = list()
	///a list of objects which this item can store despite not passing the w_class limit
	var/list/bypass_w_limit = list()
	///In slotless storage, stores areas where clicking will refer to the associated item
	var/list/click_border_start = list()
	///See click_border_start, where the area ends
	var/list/click_border_end = list()
	///Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/max_w_class = 2
	///The sum of the storage costs of all the items in this storage item.
	var/max_storage_space = 14
	//The number of storage slots in this container.
	var/storage_slots = 7

	// UI OBJECTS
	var/obj/screen/storage/boxes = null
	var/obj/screen/storage/storage_start = null
	var/obj/screen/storage/storage_continue = null
	var/obj/screen/storage/storage_end = null
	var/obj/screen/storage/stored_start = null
	var/obj/screen/storage/stored_continue = null
	var/obj/screen/storage/stored_end = null
	var/obj/screen/close/closer = null
	// UI OBJECTS

	/// BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	var/foldable = null
	///sound played when used. null for no sound.
	var/use_sound = "rustle"
	///List of all the mobs who are currently watching our storage
	var/list/content_watchers = list()
	///How long does it take to put items into or out of this, in ticks
	var/access_delay = 0

/obj/item/storage/MouseDrop(obj/over_object)
	if(!ishuman(usr))
		return

	if(usr.lying_angle)
		return

	if(istype(usr.loc, /obj/vehicle/multitile/root/cm_armored)) // stops inventory actions in a mech/tank
		return

	if(over_object == usr && Adjacent(usr)) // this must come before the screen objects only block
		open(usr)
		return

	if(!istype(over_object, /obj/screen))
		return ..()

	//Makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
	//There's got to be a better way of doing this.
	if(loc != usr || (loc && loc.loc == usr))
		return

	if(!usr.restrained() && !usr.stat)
		switch(over_object.name)
			if("r_hand")
				usr.dropItemToGround(src)
				usr.put_in_r_hand(src)
			if("l_hand")
				usr.dropItemToGround(src)
				usr.put_in_l_hand(src)

///Recursively gets all contents and sub-contents of this storage item
/obj/item/storage/proc/return_inv(recurse = TRUE)
	. = list()
	. += contents

	for(var/content in contents)
		if(isstorage(content))
			var/obj/item/storage/substorage = content
			. += substorage.return_inv(recurse)
			continue
		if(istype(content, /obj/item/gift))
			var/obj/item/gift/subgift = content
			. += subgift
			if(isstorage(subgift.gift))
				var/obj/item/storage/substorage = subgift.gift
				. += substorage.return_inv(recurse)

///Adds and opens the view of this storage for the given mob
/obj/item/storage/proc/show_to(mob/user)
	if(user.s_active != src)
		for(var/obj/item/content in contents)
			if(content.on_found(user))
				return
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen -= boxes
	user.client.screen -= storage_start
	user.client.screen -= storage_continue
	user.client.screen -= storage_end
	user.client.screen -= closer
	user.client.screen -= contents
	user.client.screen += closer
	user.client.screen += contents

	if(storage_slots)
		user.client.screen += boxes
	else
		user.client.screen += storage_start
		user.client.screen += storage_continue
		user.client.screen += storage_end

	user.s_active = src
	LAZYADD(content_watchers, user)

///Removes the view of this storage from the mob
/obj/item/storage/proc/hide_from(mob/user)
	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= storage_start
	user.client.screen -= storage_continue
	user.client.screen -= storage_end
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	if(user.s_active == src)
		user.s_active = null
	LAZYREMOVE(content_watchers, user)

///Returns a list of every mob who has this storage open
/obj/item/storage/proc/can_see_content()
	var/list/lookers = list()
	for(var/mob/watcher AS in content_watchers)
		if(watcher.s_active == src && watcher.client)
			lookers |= watcher
		else
			LAZYREMOVE(content_watchers, watcher)
	return lookers

///Opens the view of this storage for the given mob
/obj/item/storage/proc/open(mob/user)
	if(!(flags_storage & STORAGE_FLAG_OPENED))
		orient2hud()
		flags_storage |= STORAGE_FLAG_OPENED
	if (use_sound)
		playsound(src.loc, src.use_sound, 25, 1, 3)

	if (user.s_active)
		user.s_active.close(user)
	show_to(user)

///Closes the view of this storage for the given mob
/obj/item/storage/proc/close(mob/user)
	hide_from(user)
/**
 * This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
 * The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
 */
/obj/item/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	boxes.screen_loc = "[tx]:,[ty] to [mx],[my]"
	for(var/obj/content in contents)
		content.screen_loc = "[cx],[cy]"
		content.layer = ABOVE_HUD_LAYER
		content.plane = ABOVE_HUD_PLANE
		cx++
		if (cx > mx)
			cx = tx
			cy--
	closer.screen_loc = "[mx+1],[my]"
	if(flags_storage & STORAGE_FLAG_FULLNESS_VISIBLE)
		boxes.update_fullness(src)

///This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/storage/proc/slot_orient_objs(rows, cols, list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows

	if(!boxes)
		return

	boxes.screen_loc = "4:16,2:16 to [4+cols]:16,[2+rows]:16"

	if(flags_storage & STORAGE_FLAG_DISPLAY_NUMBERED)
		for(var/datum/numbered_display/display AS in display_contents)
			display.sample_object.mouse_opacity = 2
			display.sample_object.screen_loc = "[cx]:16,[cy]:16"
			display.sample_object.maptext = "<font color='white'>[(display.number > 1)? "[display.number]" : ""]</font>"
			display.sample_object.layer = ABOVE_HUD_LAYER
			display.sample_object.plane = ABOVE_HUD_PLANE
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/content in contents)
			content.mouse_opacity = 2 //So storage items that start with contents get the opacity trick.
			content.screen_loc = "[cx]:16,[cy]:16"
			content.maptext = ""
			content.layer = ABOVE_HUD_LAYER
			content.plane = ABOVE_HUD_PLANE
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	closer.screen_loc = "[4+cols+1]:16,2:16"
	if(flags_storage & STORAGE_FLAG_FULLNESS_VISIBLE)
		boxes.update_fullness(src)

/obj/item/storage/proc/space_orient_objs(list/obj/item/display_contents)

	var/baseline_max_storage_space = 21 //should be equal to default backpack capacity
	var/storage_cap_width = 2 //length of sprite for start and end of the box representing total storage space
	var/stored_cap_width = 4 //length of sprite for start and end of the box representing the stored item
	var/storage_width = min( round( 258 * max_storage_space/baseline_max_storage_space ,1) ,284) //length of sprite for the box representing total storage space

	click_border_start.Cut()
	click_border_end.Cut()
	storage_start.overlays.Cut()

	if(!(flags_storage & STORAGE_FLAG_OPENED)) //initialize background box
		var/matrix/matrix = matrix()
		matrix.Scale((storage_width-storage_cap_width*2+3)/32,1)
		storage_continue.transform = matrix
		storage_start.screen_loc = "4:16,2:16"
		storage_continue.screen_loc = "4:[round(storage_cap_width+(storage_width-storage_cap_width*2)/2+2)],2:16"
		storage_end.screen_loc = "4:[19+storage_width-storage_cap_width],2:16"

	var/startpoint = 0
	var/endpoint = 1

	for(var/obj/item/content in contents)
		startpoint = endpoint + 1
		endpoint += storage_width * content.w_class / max_storage_space

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

		content.screen_loc = "4:[round((startpoint+endpoint)/2)+2],2:16"
		content.maptext = ""
		content.layer = ABOVE_HUD_LAYER
		content.plane = ABOVE_HUD_PLANE

	closer.screen_loc = "4:[storage_width+19],2:16"

/obj/screen/storage/Click(location, control, params)
	if(usr.incapacitated(TRUE))
		return

	if(istype(usr.loc, /obj/vehicle/multitile/root/cm_armored)) // stops inventory actions in a mech/tank
		return

	var/list/PL = params2list(params)

	if(!master)
		return

	var/obj/item/storage/S = master
	var/obj/item/held_item = usr.get_active_held_item()
	if(held_item)
		master.attackby(held_item, usr)
		return

	// Taking something out of the storage screen (including clicking on item border overlay)
	var/list/screen_loc_params = splittext(PL["screen-loc"], ",")
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")
	var/click_x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 144

	for(var/i = 1 to length(S.click_border_start))
		if(S.click_border_start[i] > click_x || click_x > S.click_border_end[i])
			continue
		if(length(S.contents) < i)
			continue
		held_item = S.contents[i]
		held_item.attack_hand(usr)
		return

/datum/numbered_display
	///The item we are 'tied' to
	var/obj/item/sample_object
	///The number actually bein displayed
	var/number

/datum/numbered_display/New(obj/item/sample)
	if(!istype(sample))
		qdel(src)
	sample_object = sample
	number = 1

/datum/numbered_display/Destroy()
	sample_object = null
	return ..()

///This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/storage/proc/orient2hud()

	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(flags_storage & STORAGE_FLAG_DISPLAY_NUMBERED)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/content in contents)
			if(!isitem(content))
				continue
			var/obj/item/item = content
			var/found = FALSE
			for(var/datum/numbered_display/ND in numbered_contents)
				if(ND.sample_object.type == item.type)
					ND.number++
					found = TRUE
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add(new/datum/numbered_display(item))

	if(isnull(storage_slots))
		src.space_orient_objs(numbered_contents)
	else
		var/row_num = 0
		var/col_count = min(7,storage_slots) -1
		if (adjusted_contents > 7)
			row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
		slot_orient_objs(row_num, col_count, numbered_contents)

/**
 * This proc returns TRUE if the item can be picked up and FALSE if it can't.
 * Set the warning to stop it from printing messages
 */
/obj/item/storage/proc/can_be_inserted(obj/item/item, mob/user, warning = TRUE)
	if(!istype(item) || (item.flags_item & NODROP))
		return //Not an item

	if(loc == item)
		return FALSE //Means the item is already in the storage item
	if(storage_slots != null && contents.len >= storage_slots)
		if(warning)
			to_chat(user, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE //Storage item is full

	if(length(can_hold))
		if(!is_type_in_typecache(item, can_hold))
			if(warning)
				to_chat(user, "<span class='notice'>[src] cannot hold [item].</span>")
			return FALSE

	if(is_type_in_typecache(item, cant_hold)) //Check for specific items which this container can't hold.
		if(warning)
			to_chat(user, "<span class='notice'>[src] cannot hold [item].</span>")
		return FALSE

	if(!is_type_in_typecache(item, bypass_w_limit) && item.w_class > max_w_class)
		if(warning)
			to_chat(user, "<span class='notice'>[item] is too long for this [src].</span>")
		return FALSE

	var/sum_storage_cost = item.w_class
	for(var/obj/item/I in contents)
		sum_storage_cost += I.w_class

	if(sum_storage_cost > max_storage_space)
		if(warning)
			to_chat(user, "<span class='notice'>[src] is full, make some space.</span>")
		return FALSE

	if(item.w_class >= w_class && istype(item, /obj/item/storage) && !is_type_in_typecache(item.type, bypass_w_limit))
		if(!istype(src, /obj/item/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(warning)
				to_chat(user, "<span class='notice'>[src] cannot hold [item] as it's a storage item of the same size.</span>")
			return FALSE //To prevent the stacking of same sized storage items.

	if(istype(item, /obj/item/tool/hand_labeler))
		var/obj/item/tool/hand_labeler/labeler = item
		if(labeler.on)
			return FALSE
		else
			return TRUE

	return TRUE

/**
 * This proc handles the delay associated with a storage object.
 * If there is no delay, or the delay is negative, it simply returns TRUE.
 * Should return true if the access delay is completed successfully.
 */
/obj/item/storage/proc/handle_access_delay(obj/item/accessed, mob/user, taking_out = TRUE, alert_user = TRUE)
	if(!access_delay || !user || !should_access_delay(accessed, user, taking_out))
		return TRUE

	if(!alert_user)
		return do_after(user, access_delay, TRUE, src, ignore_turf_checks=TRUE)

	to_chat(user, "<span class='notice'>You begin to [taking_out ? "take" : "put"] [accessed] [taking_out ? "out of" : "into"] [src]")
	if(!do_after(user, access_delay, TRUE, src, ignore_turf_checks=TRUE))
		to_chat(user, "<span class='warning'>You fumble [accessed]!</span>")
		return FALSE
	return TRUE

/**
 * This proc checks to see if we should actually delay access in this scenario
 * This proc should return TRUE or FALSE
 */
/obj/item/storage/proc/should_access_delay(obj/item/accessed, mob/user, taking_out)
	return FALSE

/**
 * This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted.
 * That's done by can_be_inserted()
 * The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
 * such as when picking up all the items on a tile with one click.
 * user can be null, it refers to the potential mob doing the insertion.
 */
/obj/item/storage/proc/handle_item_insertion(obj/item/item, mob/user, prevent_warning = FALSE)
	if(!istype(item))
		return FALSE
	if(!handle_access_delay(item, user, taking_out=FALSE))
		item.forceMove(item.drop_location())
		return FALSE
	if(item.loc == user)
		if(!user.transferItemToLoc(item, src))
			return FALSE
	else
		item.forceMove(src)
	item.on_enter_storage(src)
	if(user)
		if (user.client && user.s_active != src)
			user.client.screen -= item
		if(!prevent_warning)
			var/visidist = item.w_class >= 3 ? 3 : 1
			user.visible_message("<span class='notice'>[usr] puts [item] into [src].</span>",\
								"<span class='notice'>You put \the [item] into [src].</span>",\
								null, visidist)
	update_watchers(TRUE)
	if (storage_slots)
		item.mouse_opacity = 2 //not having to click the item's tiny sprite to take it out of the storage.
	update_icon()
	return TRUE

///Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/storage/proc/remove_from_storage(obj/item/item, atom/new_location, mob/user)
	if(!istype(item))
		return FALSE

	for(var/mob/watcher AS in can_see_content())
		if(!watcher.client)
			continue
		watcher.client.screen -= item

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

	update_watchers(TRUE)

	if(!QDELETED(item))
		item.on_exit_storage(src)
		item.mouse_opacity = initial(item.mouse_opacity)

	update_icon()

	return handle_access_delay(item, user)

///This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/item, mob/user, params)
	. = ..()

	if(!can_be_inserted(item, user))
		return

	return handle_item_insertion(item, user, FALSE)

/obj/item/storage/proc/update_watchers(recalculate = FALSE)
	if(recalculate)
		orient2hud()
	for(var/mob/watcher AS in SANITIZE_LIST(content_watchers))
		show_to(watcher)

/obj/item/storage/proc/close_watchers()
	for(var/mob/watcher AS in SANITIZE_LIST(content_watchers))
		close(watcher)

/obj/item/storage/attack_hand(mob/living/user)
	if (loc == user)
		if((flags_storage & STORAGE_FLAG_QUICKDRAW_ENABLED) && ishuman(user) && contents.len)
			var/obj/item/item = contents[contents.len]
			item.attack_hand(user)
		else
			open(user)
	else
		. = ..()
		close_watchers()

/obj/item/storage/attack_ghost(mob/user)
	open(user)

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	flags_storage ^= STORAGE_FLAG_COLLECTION_TOGGLED
	if(flags_storage & STORAGE_FLAG_COLLECTION_TOGGLED)
		to_chat(usr, "[src] now picks up all items in a tile at once.")
	else
		to_chat(usr, "[src] now picks up one item at a time.")

/obj/item/storage/verb/toggle_draw_mode()
	set name = "Switch Storage Drawing Method"
	set category = "Object"


	flags_storage ^= STORAGE_FLAG_QUICKDRAW_ENABLED
	if(flags_storage & STORAGE_FLAG_QUICKDRAW_ENABLED)
		to_chat(usr, "Clicking [src] with an empty hand now puts the last stored item in your hand.")
		return

	to_chat(usr, "Clicking [src] with an empty hand now opens the pouch storage menu.")

///Quickly removes everything from this storage onto our current turf
/obj/item/storage/proc/quick_empty()

	if((!ishuman(usr) && loc != usr) || usr.restrained())
		return

	var/turf/droploc = get_turf(src)
	hide_from(usr)
	for(var/obj/item/item in contents)
		remove_from_storage(item, droploc, usr)

/obj/item/storage/Initialize(mapload, ...)
	. = ..()
	PopulateContents()
	if(length(can_hold))
		can_hold = typecacheof(can_hold)
	else if(length(cant_hold))
		cant_hold = typecacheof(cant_hold)
	if(length(bypass_w_limit))
		bypass_w_limit = typecacheof(bypass_w_limit)

	if(!(flags_storage & STORAGE_FLAG_QUICK_GATHER))
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	if(!(flags_storage & STORAGE_FLAG_QUICKDRAW_ALLOWED))
		verbs -= /obj/item/storage/verb/toggle_draw_mode

	boxes = new
	boxes.name = "storage"
	boxes.master = src
	boxes.icon_state = "block"
	boxes.screen_loc = "7,7 to 10,8"
	boxes.layer = HUD_LAYER
	boxes.plane = HUD_PLANE

	storage_start = new /obj/screen/storage(  )
	storage_start.name = "storage"
	storage_start.master = src
	storage_start.icon_state = "storage_start"
	storage_start.screen_loc = "7,7 to 10,8"
	storage_start.layer = HUD_LAYER
	storage_start.plane = HUD_PLANE
	storage_continue = new /obj/screen/storage(  )
	storage_continue.name = "storage"
	storage_continue.master = src
	storage_continue.icon_state = "storage_continue"
	storage_continue.screen_loc = "7,7 to 10,8"
	storage_continue.layer = HUD_LAYER
	storage_continue.plane = HUD_PLANE
	storage_end = new /obj/screen/storage(  )
	storage_end.name = "storage"
	storage_end.master = src
	storage_end.icon_state = "storage_end"
	storage_end.screen_loc = "7,7 to 10,8"
	storage_end.layer = HUD_LAYER
	storage_end.plane = HUD_PLANE

	stored_start = new /obj //we just need these to hold the icon
	stored_start.icon_state = "stored_start"
	stored_start.layer = HUD_LAYER
	stored_start.plane = HUD_PLANE
	stored_continue = new /obj
	stored_continue.icon_state = "stored_continue"
	stored_continue.layer = HUD_LAYER
	stored_continue.plane = HUD_PLANE
	stored_end = new /obj
	stored_end.icon_state = "stored_end"
	stored_end.layer = HUD_LAYER
	stored_end.plane = HUD_PLANE

	closer = new
	closer.master = src

/obj/item/storage/Destroy()
	for(var/item in contents)
		qdel(item)
	for(var/mob/mob AS in SANITIZE_LIST(content_watchers))
		hide_from(mob)
	if(boxes)
		qdel(boxes)
		boxes = null
	if(storage_start)
		qdel(storage_start)
		storage_start = null
	if(storage_continue)
		qdel(storage_continue)
		storage_continue = null
	if(storage_end)
		qdel(storage_end)
		storage_end = null
	if(stored_start)
		qdel(stored_start)
		stored_start = null
	if(src.stored_continue)
		qdel(src.stored_continue)
		src.stored_continue = null
	if(stored_end)
		qdel(stored_end)
		stored_end = null
	if(closer)
		qdel(closer)
		closer = null
	. = ..()

/obj/item/storage/emp_act(severity)
	if(!isliving(loc))
		for(var/obj/object in contents)
			object.emp_act(severity)
	return ..()

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if it has the verb to do that.
	if(flags_storage & STORAGE_FLAG_QUICK_EMPTY)
		quick_empty()
		return

	//Otherwise we'll try to fold it.
	if(contents.len || !ispath(foldable))
		return

	// Close any open UI windows first
	for(var/mob/M AS in SANITIZE_LIST(content_watchers))
		close(M)

	// Now make the cardboard
	to_chat(user, "<span class='notice'>You fold [src] flat.</span>")
	new foldable(get_turf(src))
	qdel(src)

/**
 * Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
 * Returns -1 if the atom was not found on container.
 */
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !(cur_atom in container.contents))
		if(isarea(cur_atom))
			return -1
		if(isstorage(cur_atom.loc))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.
	return depth

/**
 * Like storage depth, but returns the depth to the nearest turf
 * Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
 */
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !isturf(cur_atom))
		if(isarea(cur_atom))
			return -1
		if(isstorage(cur_atom.loc))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.
	return depth

/obj/item/storage/handle_atom_del(atom/movable/AM)
	if(isitem(AM))
		remove_from_storage(AM)

/obj/item/storage/max_stack_merging(obj/item/stack/stack)
	if(is_type_in_typecache(stack, bypass_w_limit))
		return FALSE //No need for limits if we can bypass it.
	var/weight_diff = initial(stack.w_class) - max_w_class
	if(weight_diff <= 0)
		return FALSE //Nor if the limit is not higher than what we have.
	var/max_amt = round((stack.max_amount / STACK_WEIGHT_STEPS) * (STACK_WEIGHT_STEPS - weight_diff)) //How much we can fill per weight step times the valid steps.
	if(max_amt <= 0 || max_amt > stack.max_amount)
		stack_trace("[src] tried to max_stack_merging([stack]) with [max_w_class] max_w_class and [weight_diff] weight_diff, resulting in [max_amt] max_amt.")
	return max_amt

/obj/item/storage/contents_explosion(severity)
	for(var/atom/content AS in contents)
		content.ex_act(severity)

/obj/item/storage/AltClick(mob/user)
	attempt_draw_object(user)

/obj/item/storage/attack_hand_alternate(mob/living/user)
	attempt_draw_object(user)

///attempts to get the first possible object from this container
/obj/item/storage/proc/attempt_draw_object(mob/living/user)
	if(!ishuman(user) || user.incapacitated() || !length(contents) || isturf(loc))
		return
	if(user.get_active_held_item())
		return //User is already holding something.
	var/obj/item/drawn_item = contents[length(contents)]
	drawn_item.attack_hand(user)

///Called during Initialize this will iterate over spawns_with and spawns_prob to create our initial contents
/obj/item/storage/proc/PopulateContents()
	if(LAZYLEN(spawns_with))
		for(var/tospawn in spawns_with)
			if(!ispath(tospawn))
				CRASH("Illegal spawns_with entry: '[tospawn]'. Must be a path")
			if(spawns_with[tospawn]) // Are we assosciative?
				for(var/iteration = 1; iteration < spawns_with[tospawn]; iteration += 1)
					new tospawn(src)
			else new tospawn(src)

	if(LAZYLEN(spawns_prob) && spawns_prob_max)
		var/list/spawnlists = list()
		var/list/spawnprobs = list()
		var/index = 1
		for(var/list/spawnlist AS in spawns_prob)
			var/listprob = spawnlist[1]
			if(!prob(listprob))
				continue
			//remove the probability entry from the list
			spawnlist -= listprob
			// increment holder list size and store list at new index
			spawnlists.len += 1
			spawnlists[index] = spawnlist
			// add probability to cache list for later index analysis
			spawnprobs += listprob
			index += 1

		var/spawnleft = min(spawns_prob_max, spawnlists.len)
		while(spawnleft > 0) // This is ugly but needed, byond is fucky
			spawnleft--
			var/lowestprob = INFINITY
			for(var/listprob in spawnprobs)
				lowestprob = min(lowestprob, listprob)
			var/index_lowest = spawnprobs.Find(lowestprob)
			var/listspawn = spawnlists[index_lowest]
			spawnlists -= listspawn
			spawnprobs -= lowestprob
			var/tospawn = pick(listspawn)
			new tospawn(src)

	//Done populating; clear spawn lists for memory optimization
	spawns_with = null
	spawns_prob = null

	update_icon()
