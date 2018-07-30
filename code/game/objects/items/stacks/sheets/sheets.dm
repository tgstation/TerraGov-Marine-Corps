/obj/item/stack/sheet
	name = "sheet"
	layer = UPPER_ITEM_LAYER
	w_class = 3.0
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 3
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/perunit = 3750
	var/sheettype = null //this is used for girders in the creation of walls/false walls


// Since the sheetsnatcher was consolidated into weapon/storage/bag we now use
// item/attackby() properly, making this unnecessary

/*/obj/item/stack/sheet/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/storage/bag/sheetsnatcher))
		var/obj/item/storage/bag/sheetsnatcher/S = W
		if(!S.mode)
			S.add(src,user)
		else
			for (var/obj/item/stack/sheet/stack in locate(src.x,src.y,src.z))
				S.add(stack,user)
	..()*/