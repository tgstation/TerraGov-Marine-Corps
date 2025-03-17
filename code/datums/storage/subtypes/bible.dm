/datum/storage/bible
	storage_slots = 1

/datum/storage/bible/alcoholic
	storage_slots = 7

/datum/storage/bible/alcoholic/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/reagent_containers/food/drinks/cans,
		/obj/item/spacecash,
	))
