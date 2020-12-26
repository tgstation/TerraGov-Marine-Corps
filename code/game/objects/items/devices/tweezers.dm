/obj/item/tweezers
	name = "medical tweezers"
	desc = "Medical tweezers intended to remove shrapnel from patients."
	icon_state = "tweezers"
	item_state = "tweezers"
	flags_item = NOBLUDGEON

/obj/item/tweezers/Initialize()
	. = ..()
	AddElement(/datum/element/shrapnel_removal, 10 SECONDS)
