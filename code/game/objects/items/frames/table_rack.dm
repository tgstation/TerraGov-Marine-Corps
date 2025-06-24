


/*
* Table Parts
*/

/obj/item/frame/table
	name = "table parts"
	desc = "A kit for a table, including a large, flat metal surface and four legs. Some assembly required."
	gender = PLURAL
	icon = 'icons/obj/items/items.dmi'
	icon_state = "table_parts"
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	worn_icon_state = "table_parts"
	atom_flags = CONDUCT
	attack_verb = list("slams", "bashes", "batters", "bludgeons", "thrashes", "whacks")
	var/table_type = /obj/structure/table //what type of table it creates when assembled
	var/deconstruct_type = /obj/item/stack/sheet/metal
	/// How much of `deconstruct_type` will be spawned on wrench?
	var/deconstruct_amount = 1

/obj/item/frame/table/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	var/turf/table_turf = get_turf(src)
	if(iswrench(I) && deconstruct_type)
		new deconstruct_type(table_turf, deconstruct_amount)
		qdel(src)

	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if(!R.use(4))
			to_chat(user, span_warning("You need at least four rods to reinforce [src]."))
			return

		new /obj/item/frame/table/reinforced(table_turf)
		to_chat(user, span_notice("You reinforce [src]."))
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

	else if(istype(I, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/S = I

		if(!S.use(2))
			to_chat(user, span_warning("You need at least two wood sheets to swap the metal parts of [src]."))
			return

		new /obj/item/frame/table/wood(table_turf)
		new /obj/item/stack/sheet/metal(table_turf)
		to_chat(user, span_notice("You replace the metal parts of [src]."))
		user.temporarilyRemoveItemFromInventory(src)
		qdel(src)

/obj/item/frame/table/attack_self(mob/user)
	if(locate(/obj/structure/table) in get_turf(user))
		to_chat(user, span_warning("There is another table built in here already."))
		return
	if(istype(get_area(loc), /area/shuttle))  //HANGAR/SHUTTLE BUILDING
		to_chat(user, span_warning("No. This area is needed for the dropship."))
		return

	new table_type(user.loc)
	user.drop_held_item()
	qdel(src)

/obj/item/frame/table/nometal
	deconstruct_type = null

/*
* Mainship Table Parts
*/

/obj/item/frame/table/mainship
	table_type = /obj/structure/table/mainship

/obj/item/frame/table/mainship/nometal
	deconstruct_type = null
	table_type = /obj/structure/table/mainship/nometal

/*
* Reinforced Table Parts
*/

/obj/item/frame/table/reinforced
	name = "reinforced table parts"
	desc = "A kit for a table, including a large, flat metal surface and four legs. This kit has side panels. Some assembly required."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "reinf_tableparts"
	table_type = /obj/structure/table/reinforced
	deconstruct_amount = 2

/*
* Wooden Table Parts
*/

/obj/item/frame/table/wood
	name = "wooden table parts"
	desc = "A kit for a table, including a large, flat wooden surface and four legs. Some assembly required."
	icon_state = "wood_tableparts"
	atom_flags = null
	table_type = /obj/structure/table/wood
	deconstruct_type = /obj/item/stack/sheet/wood

/obj/item/frame/table/wood/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/stack/tile/carpet))
		var/obj/item/stack/tile/carpet/C = I
		if(!C.use(1))
			return

		to_chat(user, span_notice("You put a layer of carpet on [src]."))
		new /obj/item/frame/table/gambling(get_turf(src))
		qdel(src)

/obj/item/frame/table/fancywood
	icon_state = "fwood_tableparts"

/obj/item/frame/table/rusticwood
	icon_state = "pwood_tableparts"

/*
* Gambling Table Parts
*/

/obj/item/frame/table/gambling
	name = "gamble table parts"
	desc = "A kit for a table, including a large, flat wooden and carpet surface and four legs. Some assembly required."
	icon_state = "gamble_tableparts"
	atom_flags = null
	table_type = /obj/structure/table/wood/gambling
	deconstruct_type = /obj/item/stack/sheet/wood

/obj/item/frame/table/gambling/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iscrowbar(I))
		to_chat(user, span_notice("You pry the carpet out of [src]."))
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
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/engineering_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/engineering_right.dmi',
	)
	icon_state = "rack_parts"
	atom_flags = CONDUCT


/obj/item/frame/rack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc)
		qdel(src)

/obj/item/frame/rack/attack_self(mob/user as mob)

	if(locate(/obj/structure/table) in user.loc || locate(/obj/structure/barricade) in user.loc)
		to_chat(user, span_warning("There is already a structure here."))
		return

	if(locate(/obj/structure/rack) in user.loc)
		to_chat(user, span_warning("There already is a rack here."))
		return

	new /obj/structure/rack(user.loc)
	user.drop_held_item()
	qdel(src)
