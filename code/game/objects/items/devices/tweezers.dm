/obj/item/tweezers
	name = "medical tweezers"
	desc = "Medical tweezers intended to remove shrapnel from patients."
	icon_state = "tweezers"
	item_state = "tweezers"
	flags_item = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tweezers/Initialize()
	. = ..()
	AddElement(/datum/element/shrapnel_removal, 10 SECONDS)
