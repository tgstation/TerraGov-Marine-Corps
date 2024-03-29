/datum/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 0 // UNStABLE AS FuCK, turn on when it stops crashing clients
	use_to_pickup = 1

/datum/storage/bag/trash
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 21
	canhold = list() // any
	canthold = list(/obj/item/disk/nuclear)

/datum/storage/bag/plasticbag
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 21
	canhold = list() // any
	canthold = list(/obj/item/disk/nuclear)

/datum/storage/bag/ore
	storage_slots = 50
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	canhold = list(/obj/item/ore)

/datum/storage/bag/plants
	storage_slots = 50; //the number of plant pieces it can carry.
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	canhold = list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/seeds,
		/obj/item/grown,
	)

/datum/storage/bag/cash
	storage_slots = 50; //the number of cash pieces it can carry.
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * cash.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	canhold = list(
		/obj/item/coin,
		/obj/item/spacecash,
	)

/datum/storage/bag/sheetsnatcher
	allow_quick_empty = 1 // this function is superceded

/datum/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	var/obj/item/storage/bag/sheetsnatcher/sheetsnatcher = parent
	if(!istype(W,/obj/item/stack/sheet) || istype(W,/obj/item/stack/sheet/mineral/sandstone) || istype(W,/obj/item/stack/sheet/wood))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0 //I don't care, but the existing code rejects them for not being "sheets" *shrug* -Sayu
	var/current = 0
	for(var/obj/item/stack/sheet/S in parent.contents)
		current += S.amount
	if(sheetsnatcher.capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, span_warning("The snatcher is full."))
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/datum/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W, prevent_warning = 0, mob/user)
	var/obj/item/storage/bag/sheetsnatcher/sheetsnatcher = parent
	var/obj/item/stack/sheet/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/sheet/S2 in sheetsnatcher.contents)
		current += S2.amount
	if(sheetsnatcher.capacity < current + S.amount)//If the stack will fill it up
		amount = sheetsnatcher.capacity - current
	else
		amount = S.amount

	for(var/obj/item/stack/sheet/sheet in sheetsnatcher.contents)
		if(S.type == sheet.type) // we are violating the amount limitation because these are not sane objects
			sheet.amount += amount	// they should only be removed through procs in this file, which split them up.
			S.amount -= amount
			inserted = 1
			break

	if(!inserted || !S.amount)
		if(user && W.loc == user)
			user.temporarilyRemoveItemFromInventory(S)
		if(!S.amount)
			qdel(S)
		else
			S.forceMove(src)

	orient2hud()
	for(var/mob/M in can_see_content())
		show_to(M)

	sheetsnatcher.update_icon()
	return 1


// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/datum/storage/bag/sheetsnatcher/orient2hud()
	var/obj/item/storage/bag/sheetsnatcher/sheetsnatcher = parent
	var/adjusted_contents = length(sheetsnatcher.contents)

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/sheet/I in sheetsnatcher.contents)
			adjusted_contents++
			var/datum/numbered_display/D = new/datum/numbered_display(I)
			D.number = I.amount
			numbered_contents.Add( D )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	slot_orient_objs(row_num, col_count, numbered_contents)



// Modified quick_empty verb drops appropriate sized stacks
/datum/storage/bag/sheetsnatcher/quick_empty()
	var/obj/item/storage/bag/sheetsnatcher/sheetsnatcher = parent
	var/location = get_turf(src)
	for(var/obj/item/stack/sheet/S in sheetsnatcher.contents)
		while(S.amount)
			var/obj/item/stack/sheet/N = new S.type(location)
			var/stacksize = min(S.amount,N.max_amount)
			N.amount = stacksize
			S.amount -= stacksize
		if(!S.amount)
			qdel(S) // todo: there's probably something missing here
	orient2hud(usr)
	if(usr.s_active)
		show_to(usr)
	sheetsnatcher.update_icon()

// Instead of removing
/datum/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	var/obj/item/stack/sheet/S = W
	if(!istype(S))
		return FALSE

	//I would prefer to drop a new stack, but the item/attack_hand(mob/living/user)
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.amount > S.max_amount)
		var/obj/item/stack/sheet/temp = new S.type(src)
		temp.amount = S.amount - S.max_amount
		S.amount = S.max_amount

	return ..(S,new_location,user)
