/obj/structure/closet/secure_closet/hydroponics
	name = "Botanist's locker"
	req_access = list(ACCESS_CIVILIAN_PUBLIC)
	icon_state = "hydrosecure1"
	icon_closed = "hydrosecure"
	icon_locked = "hydrosecure1"
	icon_opened = "hydrosecureopen"
	icon_broken = "hydrosecurebroken"
	icon_off = "hydrosecureoff"


/obj/structure/closet/secure_closet/hydroponics/Initialize(mapload, ...)
	. = ..()
	switch(rand(1,2))
		if(1)
			new /obj/item/clothing/suit/storage/apron(src)
		if(2)
			new /obj/item/clothing/suit/storage/apron/overalls(src)
	new /obj/item/storage/bag/plants(src)
	new /obj/item/clothing/under/rank/hydroponics(src)
	new /obj/item/tool/analyzer/plant_analyzer(src)
	new /obj/item/clothing/head/greenbandanna(src)
	new /obj/item/tool/minihoe(src)
	new /obj/item/tool/hatchet(src)
