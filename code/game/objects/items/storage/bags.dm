/*
*	These absorb the functionality of the plant bag, ore satchel, etc.
*	They use the use_to_pickup, quick_gather, and quick_empty functions
*	that were already defined in weapon/storage, but which had been
*	re-implemented in other classes.
*
*	Contains:
*		Trash Bag
*		Mining Satchel
*		Plant Bag
*		Sheet Snatcher
*		Cash Bag
*
*	-Sayu
*/

//  Generic non-item
/obj/item/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 0 // UNStABLE AS FuCK, turn on when it stops crashing clients
	use_to_pickup = 1
	flags_equip_slot = ITEM_SLOT_BELT

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag0"
	item_state = "trashbag"

	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 2
	storage_slots = 21
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

/obj/item/storage/bag/trash/update_icon_state()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 12)
		icon_state = "trashbag1"
	else if(contents.len < 21)
		icon_state = "trashbag2"
	else
		icon_state = "trashbag3"

// -----------------------------
//        Plastic Bag
// -----------------------------

/obj/item/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/items/trash.dmi'
	icon_state = "plasticbag"
	item_state = "plasticbag"

	w_class = WEIGHT_CLASS_BULKY
	max_w_class = 2
	storage_slots = 21
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

// -----------------------------
//        Mining Satchel
// -----------------------------

/obj/item/storage/bag/ore
	name = "Mining Satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	storage_slots = 50
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = 3
	can_hold = list(/obj/item/ore)

// -----------------------------
//          Plant bag
// -----------------------------

/obj/item/storage/bag/plants
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "plantbag"
	name = "Plant Bag"
	storage_slots = 50; //the number of plant pieces it can carry.
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = 3
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/seeds,
		/obj/item/grown,
	)

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/storage/bag/sheetsnatcher
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	name = "Sheet Snatcher"
	desc = "A patented Nanotrasen storage system designed for any kind of mineral sheet."
	w_class = WEIGHT_CLASS_NORMAL
	allow_quick_empty = TRUE // this function is superceded
	///The number of sheets we can carry.
	var/capacity = 300

/obj/item/storage/bag/sheetsnatcher/can_be_inserted(obj/item/item, stop_messages = FALSE)
	if(!istype(item,/obj/item/stack/sheet) || istype(item,/obj/item/stack/sheet/mineral/sandstone) || istype(item,/obj/item/stack/sheet/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [item].")
		return FALSE //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/sheet in contents)
		current += sheet.amount
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, "<span class='warning'>The snatcher is full.</span>")
		return FALSE
	return TRUE

// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/item, prevent_warning = 0, mob/user)
	if(!item || !istype(item, /obj/item/stack/sheet))
		return FALSE
	var/obj/item/stack/sheet/sheet = item
	var/amount
	var/inserted = FALSE
	var/current = 0

	for(var/content in contents)
		if(!istype(content, /obj/item/stack/sheet))
			continue
		var/obj/item/stack/sheet/sheet_sub = content
		current += sheet_sub.amount
	if(capacity < current + sheet.amount)//If the stack will fill it up
		amount = capacity - current
	else amount = sheet.amount

	for(var/content in contents)
		if(!istype(content, /obj/item/stack/sheet))
			continue
		var/obj/item/stack/sheet/sheet_sub = content
		if(istype(sheet_sub, sheet.type)) // we are violating the amount limitation because these are not sane objects
			sheet_sub.amount += amount	// they should only be removed through procs in this file, which split them up.
			sheet.amount -= amount
			inserted = TRUE
			break

	if(!inserted || !sheet.amount)
		if(user && item.loc == user)
			user.temporarilyRemoveItemFromInventory(sheet)
		if(!sheet.amount)
			qdel(sheet)
		else
			sheet.forceMove(src)

	orient2hud()
	for(var/mob/watcher AS in can_see_content())
		show_to(watcher)

	update_icon()
	return TRUE

// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/obj/item/storage/bag/sheetsnatcher/orient2hud()
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/content in contents)
			if(!istype(content, /obj/item/stack/sheet))
				continue
			var/obj/item/stack/sheet/sheet = content
			adjusted_contents++
			var/datum/numbered_display/display = new(sheet)
			display.number = sheet.amount
			numbered_contents.Add(display)

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	slot_orient_objs(row_num, col_count, numbered_contents)

// Modified quick_empty verb drops appropriate sized stacks
/obj/item/storage/bag/sheetsnatcher/quick_empty(mob/user)
	var/location = get_turf(src)
	for(var/content in contents)
		if(!istype(content, /obj/item/stack/sheet))
			continue
		var/obj/item/stack/sheet/sheet = content
		while(sheet.amount)
			var/obj/item/stack/sheet/sheet_new = new sheet.type(location)
			var/stacksize = min(sheet.amount,sheet_new.max_amount)
			sheet_new.amount = stacksize
			sheet.amount -= stacksize
		if(!sheet.amount)
			qdel(sheet) // todo: there's probably something missing here
	orient2hud()
	if(user?.s_active)
		user.s_active.show_to(user)
	update_icon()

// Instead of removing
/obj/item/storage/bag/sheetsnatcher/remove_from_storage(obj/item/item, atom/new_location)
	if(!istype(item, /obj/item/stack/sheet))
		return FALSE
	var/obj/item/stack/sheet/sheet = item
	//I would prefer to drop a new stack, but the item/attack_hand(mob/living/user)
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(sheet.amount > sheet.max_amount)
		var/obj/item/stack/sheet/temp = new sheet.type(src)
		temp.amount = sheet.amount - sheet.max_amount
		sheet.amount = sheet.max_amount

	return ..()

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	capacity = 500//Borgs get more because >specialization

// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/storage/bag/cash
	icon = 'icons/obj/items/storage/storage.dmi'
	icon_state = "cashbag"
	name = "Cash bag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	storage_slots = 50; //the number of cash pieces it can carry.
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * cash.w_class
	max_w_class = 3
	w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/coin,
		/obj/item/spacecash,
	)
