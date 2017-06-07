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
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	item_state = "table_parts"
	matter = list("metal" = 3750)
	flags_atom = FPRINT|CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")
	var/table_type = /obj/structure/table //what type of table it creates when assembled

	attackby(obj/item/weapon/W, mob/user)
		..()
		if (istype(W, /obj/item/weapon/wrench))
			new /obj/item/stack/sheet/metal( user.loc )
			//SN src = null
			cdel(src)
		if (istype(W, /obj/item/stack/rods))
			var/obj/item/stack/rods/R = W
			if (R.use(4))
				new /obj/item/weapon/table_parts/reinforced(get_turf(loc))
				user << "<span class='notice'>You reinforce the [name].</span>"
				user.temp_drop_inv_item(src)
				cdel(src)
			else
				user << "<span class='warning'>You need at least four rods to reinforce the [name].</span>"

	attack_self(mob/user)
		if(locate(/obj/structure/table) in user.loc || locate(/obj/structure/barricade) in user.loc || locate(/obj/structure/rack) in user.loc)
			user << "<span class='warning'>There is already a structure here.</span>"
			return

		if(istype(get_area(src.loc),/area/shuttle || istype(get_area(src.loc),/area/sulaco/hangar)))  //HANGAR/SHUTTLE BUILDING
			user << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
			return

		var/obj/structure/table/T = new table_type( user.loc )
		T.add_fingerprint(user)
		user.drop_held_item()
		cdel(src)


/*
 * Reinforced Table Parts
 */


/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	matter = list("metal" = 7500)
	table_type = /obj/structure/table/reinforced

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/wrench))
			new /obj/item/stack/sheet/metal( get_turf(loc) )
			new /obj/item/stack/rods( get_turf(loc) )
			cdel(src)

/*
 * Wooden Table Parts
 */

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags_atom = null
	table_type = /obj/structure/table/woodentable

	attackby(obj/item/weapon/W as obj, mob/user as mob)
	//	..()
		if (istype(W, /obj/item/weapon/wrench))
			new /obj/item/stack/sheet/wood( get_turf(loc) )
			//SN src = null
			cdel(src)
		if (istype(W, /obj/item/stack/tile/carpet))
			var/obj/item/stack/tile/carpet/C = W
			if (C.use(1))
				new /obj/item/weapon/table_parts/gambling(get_turf(loc))
				user << "<span class='notice'>You put a layer of carpet on the table.</span>"
				cdel(src)

/*
 * Gambling Table Parts
 */

/obj/item/weapon/table_parts/gambling
	name = "gamble table parts"
	desc = "Keep away from security."
	icon_state = "gamble_tableparts"
	flags_atom = null
	table_type = /obj/structure/table/gamblingtable

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if (istype(W, /obj/item/weapon/wrench))
			new /obj/item/stack/sheet/wood( get_turf(loc) )
			new /obj/item/stack/tile/carpet( get_turf(loc) )
			cdel(src)
		if (istype(W, /obj/item/weapon/crowbar))
			new /obj/item/stack/tile/carpet( get_turf(loc) )
			new /obj/item/weapon/table_parts/wood( get_turf(loc) )
			user << "<span class='notice'>You pry the carpet out of the table.</span>"
			cdel(src)






/*
 * Rack Parts
 */

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags_atom = FPRINT|CONDUCT
	matter = list("metal" = 3750)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if (istype(W, /obj/item/weapon/wrench))
			new /obj/item/stack/sheet/metal( get_turf(loc) )
			cdel(src)
			return
		return

	attack_self(mob/user as mob)

		if(istype(get_area(src.loc),/area/shuttle || istype(get_area(src.loc),/area/sulaco/hangar)))  //HANGER/SHUTTLE BUILDING
			usr << "<span class='warning'>No. This area is needed for the dropships and personnel.</span>"
			return

		if(locate(/obj/structure/table) in user.loc || locate(/obj/structure/barricade) in user.loc)
			user << "<span class='warning'>There is already a structure here.</span>"
			return

		if(locate(/obj/structure/rack) in user.loc)
			user << "<span class='warning'>There is already a rack here.</span>"
			return

		var/obj/structure/rack/R = new /obj/structure/rack( user.loc )
		R.add_fingerprint(user)
		user.drop_held_item()
		cdel(src)

