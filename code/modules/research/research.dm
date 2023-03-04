/obj/item/disk/tech_disk
	name = "Technology Disk"
	desc = "A disk for storing technology data for further research."
	icon_state = "datadisk2"
	item_state = "card-id"
	w_class = WEIGHT_CLASS_TINY

/obj/item/disk/tech_disk/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
