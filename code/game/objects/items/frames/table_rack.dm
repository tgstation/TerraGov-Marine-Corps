


/*
 * Table Parts
 */

/obj/item/frame/table
	name = "table parts"
	desc = "A kit for a table, including a large, flat metal surface and four legs. Some assembly required."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "table_parts"
	item_state = "table_parts"
	matter = list("metal" = 7500) //A table, takes two sheets to build
	flags_atom = CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")
	var/table_type = /obj/structure/table //what type of table it creates when assembled
	var/deconstruct_type = /obj/item/stack/sheet/metal

/obj/item/frame/table/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new deconstruct_type(loc)
		qdel(src)

	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(!R.use(4))
			to_chat(user, "<span class='warning'>You need at least four rods to reinforce [src].</span>")
			return

		new /obj/item/frame/table/reinforced(loc)
		to_chat(user, "<span class='notice'>You reinforce [src].</span>")
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

	else if(istype(I, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/S = I

		if(!S.use(2))
			to_chat(user, "<span class='warning'>You need at least two wood sheets to swap the metal parts of [src].</span>")
			return

		new /obj/item/frame/table/wood(loc)
		new /obj/item/stack/sheet/metal(loc)
		to_chat(user, "<span class='notice'>You replace the metal parts of [src].</span>")
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

/obj/item/frame/table/attack_self(mob/user)



	if(istype(get_area(loc), /area/shuttle))  //HANGAR/SHUTTLE BUILDING
		to_chat(user, "<span class='warning'>No. This area is needed for the dropship.</span>")
		return

	new table_type(user.loc)
	user.drop_held_item()
	qdel(src)

/*
 * Reinforced Table Parts
 */

/obj/item/frame/table/reinforced
	name = "reinforced table parts"
	desc = "A kit for a table, including a large, flat metal surface and four legs. This kit has side panels. Some assembly required."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "reinf_tableparts"
	matter = list("metal" = 15000) //A reinforced table. Two sheets of metal and four rods
	table_type = /obj/structure/table/reinforced


/*
 * Wooden Table Parts
 */

/obj/item/frame/table/wood
	name = "wooden table parts"
	desc = "A kit for a table, including a large, flat wooden surface and four legs. Some assembly required."
	icon_state = "wood_tableparts"
	flags_atom = null
	table_type = /obj/structure/table/woodentable
	deconstruct_type = /obj/item/stack/sheet/wood

/obj/item/frame/table/wood/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/stack/tile/carpet))
		var/obj/item/stack/tile/carpet/C = I
		if(!C.use(1))
			return

		to_chat(user, "<span class='notice'>You put a layer of carpet on [src].</span>")
		new /obj/item/frame/table/gambling(get_turf(src))
		qdel(src)

/*
 * Gambling Table Parts
 */

/obj/item/frame/table/gambling
	name = "gamble table parts"
	desc = "A kit for a table, including a large, flat wooden and carpet surface and four legs. Some assembly required."
	icon_state = "gamble_tableparts"
	flags_atom = null
	table_type = /obj/structure/table/gamblingtable
	deconstruct_type = /obj/item/stack/sheet/wood

/obj/item/frame/table/gambling/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iscrowbar(I))
		to_chat(user, "<span class='notice'>You pry the carpet out of [src].</span>")
		new /obj/item/stack/tile/carpet(loc)
		new /obj/item/frame/table/wood(loc)
		qdel(src)






/*
 * Rack Parts
 */

/obj/item/frame/rack
	name = "rack parts"
	desc = "A kit for a storage rack with multiple metal shelves. Relatively cheap, useful for mass storage. Some assembly required."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "rack_parts"
	flags_atom = CONDUCT
	matter = list("metal" = 3750)


/obj/item/frame/rack/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc)
		qdel(src)

/obj/item/frame/rack/attack_self(mob/user as mob)

	if(istype(get_area(loc), /area/shuttle))  //HANGAR/SHUTTLE BUILDING
		to_chat(user, "<span class='warning'>No. This area is needed for the dropship.</span>")
		return

	if(locate(/obj/structure/table) in user.loc || locate(/obj/structure/barricade) in user.loc)
		to_chat(user, "<span class='warning'>There is already a structure here.</span>")
		return

	if(locate(/obj/structure/rack) in user.loc)
		to_chat(user, "<span class='warning'>There already is a rack here.</span>")
		return

	new /obj/structure/rack(user.loc)
	user.drop_held_item()
	qdel(src)
