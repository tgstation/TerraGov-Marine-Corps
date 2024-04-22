
/obj/item/honey_frame
	name = "honey frame"
	desc = ""
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "honey_frame"
	var/honeycomb_capacity = 10 //10 Honeycomb per frame by default, researchable frames perhaps?


/obj/item/honey_frame/Initialize()
	. = ..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)
