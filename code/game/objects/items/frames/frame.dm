
//items that are frames or assembly used to construct something (table parts, camera assembly, etc...)

/obj/item/frame





// APC FRAME

/obj/item/frame/apc
	name = "APC frame"
	desc = "Used for repairing or building APCs"
	icon = 'icons/obj/apc_repair.dmi'
	icon_state = "apc_frame"
	flags_atom = CONDUCT

/obj/item/frame/apc/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), 2 )
		cdel(src)

/obj/item/frame/apc/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	var/area/A = get_area(loc)
	if (!istype(loc, /turf/open/floor))
		to_chat(usr, "<span class='warning'>APC cannot be placed on this spot.</span>")
		return
	if (A.requires_power == 0 || istype(A, /area/space))
		to_chat(usr, "<span class='warning'>APC cannot be placed in this area.</span>")
		return
	if (A.get_apc())
		to_chat(usr, "<span class='warning'>This area already has APC.</span>")
		return //only one APC per area
	if (A.always_unpowered)
		to_chat(usr, "<span class='warning'>This area is unsuitable for an APC.</span>")
		return
	for(var/obj/machinery/power/terminal/T in loc)
		if (T.master)
			to_chat(usr, "<span class='warning'>There is another network terminal here.</span>")
			return
		else
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(loc)
			C.amount = 10
			to_chat(usr, "You cut the cables and disassemble the unused power terminal.")
			cdel(T)
	new /obj/machinery/power/apc(loc, ndir, 1)
	cdel(src)



/obj/item/frame/apiary
	name = "moveable apiary"
	icon = 'icons/obj/apiary_bees_etc.dmi'
	icon_state = "apiary_item"
	item_state = "giftbag"
	w_class = 5