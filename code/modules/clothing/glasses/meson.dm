
//meson goggles

/obj/item/clothing/glasses/meson
	name = "optical meson scanner"
	desc = "Used to shield the user's eyes from harmful electromagnetic emissions, also used as general safety goggles. Not adequate as welding protection."
	icon_state = "meson"
	item_state = "glasses"
	actions_types = list(/datum/action/item_action/toggle)
	origin_tech = "magnets=2;engineering=2"
	toggleable = 1
	fullscreen_vision = /obj/screen/fullscreen/meson
	vision_flags = SEE_TURFS|SEE_OBJS
	see_invisible = SEE_INVISIBLE_MINIMUM


/obj/item/clothing/glasses/meson/prescription
	name = "prescription optical meson scanner"
	desc = "Used for shield the user's eyes from harmful electromagnetic emissions, can also be used as safety googles. Contains prescription lenses."
	prescription = 1