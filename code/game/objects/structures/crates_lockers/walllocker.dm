/obj/structure/closet/walllocker
	name = "wall locker"
	desc = "A wall mounted storage locker."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "walllocker"
	pixel_x = -16
	pixel_y = -16
	density = FALSE
	anchored = TRUE
	icon_closed = "walllocker"
	icon_opened = "walllockeropen"
	store_mobs = FALSE
	wall_mounted = TRUE
	storage_capacity = 20
	overlay_welded = "walllockerwelded"

/obj/structure/closet/walllocker/Initialize(mapload, ndir)
	. = ..()
	if(ndir)
		dir = ndir
	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32

/obj/structure/closet/walllocker/emerglocker //wall mounted emergency closet
	name = "emergency locker"
	icon_state = "emerg"
	icon_closed = "emerg"
	icon_opened = "emergopen"
	desc = "A wall mounted locker with emergency supplies."
	overlay_welded = "emergwelded"

/obj/structure/closet/walllocker/emerglocker/full // spawners

/obj/structure/closet/walllocker/emerglocker/full/New()
	. = ..()
	sleep(2)
	for(var/i in 1 to 2)
		new /obj/item/tank/emergency_oxygen/double(src)
		new /obj/item/clothing/mask/gas(src)

/obj/structure/closet/walllocker/hydrant //wall mounted fire closet
	name = "fire-safety locker"
	desc = "A wall mounted storage unit for fire-fighting supplies."
	icon_state = "hydrant"
	icon_closed = "hydrant"
	icon_opened = "hydrantopen"
	overlay_welded = "hydrant-medical_welded"

/obj/structure/closet/walllocker/hydrant/full // spawners

/obj/structure/closet/walllocker/hydrant/full/New()
	. = ..()
	sleep(2)
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/tank/oxygen/red(src)
	new /obj/item/tool/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/walllocker/medical_wall //wall mounted medical closet
	name = "first-aid locker"
	desc = "A wall mounted storage unit for first aid supplies."
	icon_state = "medical_wall"
	icon_closed = "medical_wall"
	icon_opened = "medical_wallopen"
	overlay_welded = "hydrant-medical_welded"

/obj/structure/closet/walllocker/medical_wall/full // spawners

/obj/structure/closet/walllocker/medical_wall/full/New()
	. = ..()
	sleep(2)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dylovene(src)
	new /obj/item/reagent_container/hypospray/autoinjector/inaprovaline(src)

///////// SECURE WALL LOCKERS /////////

/obj/structure/closet/secure_closet/walllocker
	name = "secure wall locker"
	desc = "It's an immobile card-locked storage unit."
	icon = 'icons/obj/wallframes.dmi'
	pixel_x = -16
	pixel_y = -16
	icon_state = "sec_locker1"
	icon_closed = "secure"
	icon_locked = "sec_locker1"
	icon_opened = "sec_locker_opened"
	icon_broken = "sec_locker_broken"
	icon_off = "sec_locker_off"
	overlay_welded = "emergwelded"
	density = FALSE
	anchored = TRUE
	store_mobs = FALSE
	wall_mounted = TRUE
	large = FALSE
	storage_capacity = 20

/obj/structure/closet/secure_closet/walllocker/Initialize(mapload, ndir)
	. = ..()
	if(ndir)
		dir = ndir
	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32

/obj/structure/closet/secure_closet/walllocker/medical
	name = "first aid closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall_sec1"
	icon_closed = "medical_wall_sec"
	icon_locked = "medical_wall_sec1"
	icon_opened = "medical_wall_sec_open"
	icon_broken = "medical_wall_sec_broken"
	icon_off = "medical_wall_sec_off"
	overlay_welded = "hydrant-medical_welded"
	req_access = list(ACCESS_MARINE_MEDBAY)

/obj/structure/closet/secure_closet/walllocker/medical/full // spawners

/obj/structure/closet/secure_closet/walllocker/medical/full/New()
	. = ..()
	sleep(2)
	new /obj/item/storage/syringe_case/tox(src)
	new /obj/item/storage/syringe_case/oxy(src)
	new /obj/item/storage/firstaid/adv(src)
	new /obj/item/reagent_container/hypospray/autoinjector/quickclot(src)
	new /obj/item/reagent_container/hypospray/autoinjector/dexalinplus(src)
	new /obj/item/reagent_container/hypospray/autoinjector/oxycodone(src)

///////////PERSONAL SECURE WALL LOCKER///////////////

/obj/structure/closet/secure_closet/personal/walllocker // different path.
	name = "personal wall locker"
	desc = "It's a secure wall locker for personnel. The first card swiped gains control."
	icon = 'icons/obj/wallframes.dmi'
	icon_state = "sec_locker1"
	pixel_x = -16
	pixel_y = -16
	icon_closed = "secure"
	icon_locked = "sec_locker1"
	icon_opened = "sec_locker_opened"
	icon_broken = "sec_locker_broken"
	icon_off = "sec_locker_off"
	overlay_welded = "emergwelded"
	density = FALSE
	anchored = TRUE
	store_mobs = FALSE
	wall_mounted = TRUE
	large = FALSE
	storage_capacity = 20

/obj/structure/closet/secure_closet/personal/walllocker/Initialize(mapload, ndir)
	. = ..()
	if(ndir)
		dir = ndir
	switch(dir)
		if(NORTH)
			pixel_y -= 32
		if(SOUTH)
			pixel_y += 32
		if(EAST)
			pixel_x -= 32
		if(WEST)
			pixel_x += 32