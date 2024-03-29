/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"
	max_integrity = 40
	anchored = FALSE

/obj/structure/closet/coffin/update_icon_state()
	. = ..()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened

/obj/structure/closet/coffin/open
	density = 0;
	icon_state = "coffin_open";
	opened = 1
