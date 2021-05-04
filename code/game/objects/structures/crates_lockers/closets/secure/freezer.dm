/obj/structure/closet/secure_closet/freezer
	name = "Fridge"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/structure/closet/secure_closet/freezer/update_icon_state()
	if(broken)
		icon_state = icon_broken
		return
	if(opened)
		icon_state = icon_opened
		return
	if(locked)
		icon_state = icon_locked
	else
		icon_state = icon_closed

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "Kitchen Cabinet"
	req_access = list(ACCESS_CIVILIAN_PUBLIC)

/obj/structure/closet/secure_closet/freezer/kitchen/Initialize()
	. = ..()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/snacks/flour(src)
	new /obj/item/reagent_containers/food/condiment/sugar(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/meat/monkey(src)

/obj/structure/closet/secure_closet/freezer/meat/Initialize()
	. = ..()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/food/snacks/meat/monkey(src)

/obj/structure/closet/secure_closet/freezer/fridge/Initialize()
	. = ..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/food/drinks/milk(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/drinks/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/money
	name = "Freezer"
	req_access = list(ACCESS_CIVILIAN_PUBLIC)

/obj/structure/closet/secure_closet/freezer/money/Initialize()
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/spacecash/c500(src)
	for(var/i in 1 to 5)
		new /obj/item/spacecash/c200(src)
	for(var/i in 1 to 6)
		new /obj/item/spacecash/c100(src)
