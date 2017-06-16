/* Table parts and rack parts
 * Contains:
 *		Table Parts
 *		Reinforced Table Parts
 *		Wooden Table Parts
 *		Rack Parts
 */


/*
 * Table Parts
 */

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "A kit for a table, including a large, flat metal surface and four legs. Some assembly required."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	item_state = "table_parts"
	matter = list("metal" = 7500) //A table, takes two sheets to build
	flags_atom = FPRINT|CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")
	var/table_type = /obj/structure/table //what type of table it creates when assembled

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W, mob/user)

	..()
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal(user.loc)
		cdel(src)

	if(istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = W
		if(R.use(4))
			new /obj/item/weapon/table_parts/reinforced(get_turf(src))
			user << "<span class='notice'>You reinforce [src].</span>"
			user.temp_drop_inv_item(src)
			cdel(src)
		else
			user << "<span class='warning'>You need at least four rods to reinforce [src].</span>"

	if(istype(W, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/S = W
		if(S.use(2))
			new /obj/item/weapon/table_parts/wood(get_turf(src))
			new /obj/item/stack/sheet/metal(get_turf(src))
			user << "<span class='notice'>You replace the metal parts of [src].</span>"
			user.temp_drop_inv_item(src)
			cdel(src)
		else
			user << "<span class='warning'>You need at least two wood sheets to swap the metal parts of [src].</span>"

/obj/item/weapon/table_parts/attack_self(mob/user)



	if(istype(get_area(loc), /area/shuttle))  //HANGAR/SHUTTLE BUILDING
		user << "<span class='warning'>No. This area is needed for the dropship.</span>"
		return

	var/obj/structure/table/T = new table_type(user.loc)
	T.add_fingerprint(user)
	user.drop_held_item()
	cdel(src)

/*
 * Reinforced Table Parts
 */

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "A kit for a table, including a large, flat metal surface and four legs. This kit has side panels. Some assembly required."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	matter = list("metal" = 15000) //A reinforced table. Two sheets of metal and four rods
	table_type = /obj/structure/table/reinforced

/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal(get_turf(src))
		new /obj/item/stack/rods(get_turf(src))
		cdel(src)

/*
 * Wooden Table Parts
 */

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "A kit for a table, including a large, flat wooden surface and four legs. Some assembly required."
	icon_state = "wood_tableparts"
	flags_atom = null
	table_type = /obj/structure/table/woodentable

/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood(get_turf(src))
		cdel(src)

	if(istype(W, /obj/item/stack/tile/carpet))
		var/obj/item/stack/tile/carpet/C = W
		if(C.use(1))
			user << "<span class='notice'>You put a layer of carpet on [src].</span>"
			new /obj/item/weapon/table_parts/gambling(get_turf(src))
			cdel(src)

/*
 * Gambling Table Parts
 */

/obj/item/weapon/table_parts/gambling
	name = "gamble table parts"
	desc = "A kit for a table, including a large, flat wooden and carpet surface and four legs. Some assembly required."
	icon_state = "gamble_tableparts"
	flags_atom = null
	table_type = /obj/structure/table/gamblingtable

/obj/item/weapon/table_parts/gambling/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood(get_turf(src))
		new /obj/item/stack/tile/carpet(get_turf(src))
		cdel(src)

	if(istype(W, /obj/item/weapon/crowbar))
		user << "<span class='notice'>You pry the carpet out of [src].</span>"
		new /obj/item/stack/tile/carpet(get_turf(src))
		new /obj/item/weapon/table_parts/wood(get_turf(src))
		cdel(src)






/*
 * Rack Parts
 */

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "A kit for a storage rack with multiple metal shelves. Relatively cheap, useful for mass storage. Some assembly required."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags_atom = FPRINT|CONDUCT
	matter = list("metal" = 18750) //A big storage shelf, takes five sheets to build

/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal(get_turf(src))
		cdel(src)

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)

	if(istype(get_area(loc), /area/shuttle))  //HANGAR/SHUTTLE BUILDING
		user << "<span class='warning'>No. This area is needed for the dropship.</span>"
		return

	if(locate(/obj/structure/table) in user.loc || locate(/obj/structure/barricade) in user.loc)
		user << "<span class='warning'>There is already a structure here.</span>"
		return

	if(locate(/obj/structure/rack) in user.loc)
		user << "<span class='warning'>There already is a rack here.</span>"
		return

	var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
	R.add_fingerprint(user)
	user.drop_held_item()
	cdel(src)
