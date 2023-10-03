/obj/item/tweezers
	name = "medical tweezers"
	desc = "Medical tweezers intended to remove shrapnel from patients."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "tweezers"
	item_state = "tweezers"
	flags_item = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tweezers/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/shrapnel_removal, 10 SECONDS)

/obj/item/tweezers_advanced
	name = "\improper ESR-12"
	desc = "The Energised Shrapnel Removal tool is designed to rapidly remove large quantities of shrapnel from a victim's body. Extremely painful."
	icon = 'icons/obj/items/surgery_tools.dmi'
	icon_state = "predator_bone-gel"
	item_state = "predator_bone-gel"
	flags_item = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL

/obj/item/tweezers_advanced/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/shrapnel_removal, 1 SECONDS, 12 SECONDS)
