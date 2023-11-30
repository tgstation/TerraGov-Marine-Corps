// This file contains legacy mapped in objects that should be replaced where possible.

/obj/machinery/computer3
	name = "computer"
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "frame"
	density = TRUE
	anchored = TRUE

/obj/machinery/computer3/powermonitor
	icon_state = "frame-eng"

/obj/machinery/computer3/laptop
	name = "Laptop Computer"
	desc = "A clamshell portable computer. It is open."

	icon_state = "laptop"

/obj/machinery/computer3/laptop/secure_data
	icon_state = "laptop"

/obj/machinery/computer3/server
	name = "server"
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "serverframe"

/obj/machinery/computer3/server/rack
	name = "server rack"
	icon_state = "rackframe"

/obj/item/laptop
	name = "Laptop Computer"
	desc = "A clamshell portable computer.  It is closed."
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state =  "laptop-closed"
	item_state =  "laptop-inhand"
	pixel_x = 2
	pixel_y = -3
	w_class = WEIGHT_CLASS_NORMAL

/obj/machinery/lapvend
	name = "Laptop Vendor"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "robotics"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE
	density = TRUE

/obj/structure/computer3frame
	density = TRUE
	anchored = FALSE
	name = "computer frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"

/obj/machinery/computer/atmoscontrol
	name = "\improper Central Atmospherics Computer"
	icon_state = "computer"
	screen_overlay = "computer_generic"
	density = TRUE
	anchored = TRUE

/obj/item/computer3_part
	name = "computer part"
	desc = "Holy jesus you donnit now"
	gender = PLURAL
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "hdd1"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/computer3_part/storage
	name = "Storage Device"
	desc = "A device used for storing and retrieving digital information."

/obj/item/computer3_part/storage/hdd
	name = "Hard Drive"
	icon_state = "hdd1"

/obj/item/computer3_part/storage/hdd/big
	name = "Big Hard Drive"
	icon_state = "hdd2"

/obj/item/clothing/shoes/centcom
	name = "dress shoes"
	desc = "They appear impeccably polished."
	icon_state = "laceups"
