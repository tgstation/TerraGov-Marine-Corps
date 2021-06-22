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
	flags_storage = STORAGE_FLAG_PICKUP|STORAGE_FLAG_QUICK_EMPTY|STORAGE_FLAG_QUICK_GATHER
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
	///The number of sheets we can carry.
	var/max_capacity = 300

/obj/item/storage/bag/sheetsnatcher/proc/get_used_capacity()
	var/capacity = 0
	for(var/obj/item/stack/sheet/sheet AS in contents)
		capacity += sheet.amount
	return capacity

/obj/item/storage/bag/sheetsnatcher/can_be_inserted(obj/item/item, mob/user, warning = TRUE)
	if(!istype(item, /obj/item/stack/sheet) || (item.type in list(/obj/item/stack/sheet/wood, /obj/item/stack/sheet/mineral/sandstone)))
		if(warning)
			to_chat(user, "<span class='warning'>[src] does not accept [item].</span>")
		return FALSE
	if(get_used_capacity() >= max_capacity)
		if(warning)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		return FALSE
	return TRUE

/obj/item/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/stack/sheet/sheet, mob/user, prevent_warning)
	var/maximum_allowed = max_capacity - get_used_capacity()
	if(!maximum_allowed)
		CRASH("handle_item_insertion called on [src] despite being at or above maximum capacity")
	for(var/obj/item/stack/sheet/subsheet AS in contents)
		if(subsheet.type != sheet.type || subsheet.amount >= subsheet.max_amount)
			continue
		var/canadd = min(sheet.amount, maximum_allowed)
		subsheet.amount += canadd
		sheet.amount -= canadd
		if(!sheet.amount)
			qdel(sheet)
		break // Regardless of what we've done, we've added all we can
	update_watchers(TRUE)

/obj/item/storage/bag/sheetsnatcher/remove_from_storage(obj/item/stack/sheet/sheet, atom/new_location, mob/user)
	if(!istype(sheet))
		return FALSE // This should probably be a crash instead

	if(sheet.amount > sheet.max_amount) // We're trying to remove a stack of more than the max stack
		var/excess = sheet.amount - sheet.max_amount
		new sheet.type(src, excess)
		sheet.amount = sheet.max_amount

	return ..()

/obj/item/storage/bag/sheetsnatcher/quick_empty()
	var/turf/droploc = get_turf(src)

	for(var/obj/item/stack/sheet/sheet AS in contents)
		while(sheet.amount > sheet.max_amount)
			new sheet.type(droploc, sheet.max_amount)
			sheet.amount -= sheet.max_amount
		sheet.forceMove(droploc)

	update_watchers()

/obj/item/storage/bag/sheetsnatcher/orient2hud()
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(flags_storage & STORAGE_FLAG_DISPLAY_NUMBERED)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/sheet AS in contents)
			adjusted_contents++
			var/datum/numbered_display/display = new(sheet)
			display.number = sheet.amount
			numbered_contents.Add(display)

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	slot_orient_objs(row_num, col_count, numbered_contents)

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "Sheet Snatcher 9000"
	desc = ""
	max_capacity = 500//Borgs get more because >specialization

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
