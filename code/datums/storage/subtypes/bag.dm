/datum/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 0 // UNStABLE AS FuCK, turn on when it stops crashing clients
	use_to_pickup = 1

/datum/storage/bag/trash
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 21
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

/datum/storage/bag/plasticbag
	max_w_class = WEIGHT_CLASS_SMALL
	storage_slots = 21
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

/datum/storage/bag/ore
	storage_slots = 50
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * ore.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(/obj/item/ore)

/datum/storage/bag/plants
	storage_slots = 50; //the number of plant pieces it can carry.
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * plants.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/seeds,
		/obj/item/grown,
	)

/datum/storage/bag/cash
	storage_slots = 50; //the number of cash pieces it can carry.
	max_storage_space = 200 //Doesn't matter what this is, so long as it's more or equal to storage_slots * cash.w_class
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/coin,
		/obj/item/spacecash,
	)
