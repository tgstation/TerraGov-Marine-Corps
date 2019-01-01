/obj/structure/closet/walllocker
	name = "wall locker"
	desc = "A wall mounted storage locker."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "wall-locker"
	density = FALSE
	anchored = TRUE
	icon_closed = "wall-locker"
	icon_opened = "wall-lockeropen"
	store_mobs = FALSE
	wall_mounted = TRUE

/obj/structure/closet/walllocker/update_icon()
	overlays.Cut()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += image(icon, "[icon_closed]welded")
	else
		icon_state = icon_opened

/obj/structure/closet/walllocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/emerglocker //wall mounted emergency closet
	name = "emergency locker"
	icon_state = "emerg"
	icon_closed = "emerg"
	icon_opened = "emergopen"
	desc = "A wall mounted locker with emergency supplies."

/obj/structure/closet/walllocker/emerglocker/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/east
	pixel_x = 32
	dir = EAST

/obj/structure/walllocker/emerglocker/full // spawners

/obj/structure/walllocker/emerglocker/full/New()
	. = ..()
	sleep(2)
	for(var/i in 1 to 2)
		new /obj/item/tank/emergency_oxygen/double(src)
		new /obj/item/clothing/mask/gas(src)

/obj/structure/closet/walllocker/emerglocker/full/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/emerglocker/full/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/emerglocker/full/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/emerglocker/full/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/hydrant //wall mounted fire closet
	name = "fire-safety locker"
	desc = "A wall mounted storage unit for fire-fighting supplies."
	icon_state = "hydrant"
	icon_closed = "hydrant"
	icon_opened = "hydrantopen"

/obj/structure/closet/walllocker/hydrant/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/hydrant/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/hydrant/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/hydrant/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/hydrant/full // spawners

/obj/structure/closet/walllocker/hydrant/full/New()
	. = ..()
	sleep(2)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/device/flashlight(src)
	new /obj/item/tank/oxygen/red(src)
	new /obj/item/tool/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/walllocker/hydrant/full/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/hydrant/full/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/hydrant/full/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/hydrant/full/east
	pixel_x = 32
	dir = EAST

/obj/structure/closet/walllocker/medical_wall //wall mounted medical closet
	name = "first-aid locker"
	desc = "A wall mounted storage unit for first aid supplies."
	icon_state = "medical_wall"
	icon_closed = "medical_wall"
	icon_opened = "medical_wallopen"

/obj/structure/closet/walllocker/medical_wall/north
	pixel_y = 32
	dir = SOUTH

/obj/structure/closet/walllocker/medical_wall/south
	pixel_y = -32
	dir = NORTH

/obj/structure/closet/walllocker/medical_wall/west
	pixel_x = -32
	dir = WEST

/obj/structure/closet/walllocker/medical_wall/east
	pixel_x = 32
	dir = EAST