/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon_state = "glass_wire"
	w_class = 3.0
	force = 3.0
	throwforce = 5.0
	throw_speed = 5
	throw_range = 20
	max_amount = 60



/obj/item/stack/light_w/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/wirecutters))
		var/obj/item/stack/cable_coil/CC = new(user.loc)
		CC.amount = 5
		amount--
		new /obj/item/stack/sheet/glass(user.loc)
		if(amount <= 0)
			user.temporarilyRemoveItemFromInventory(src)
			qdel(src)

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(!M.use(1))
			to_chat(user, "<span class='warning'>You need one metal sheet to finish the light tile.</span>")
			return

		new /obj/item/stack/tile/light(user.loc, 1)
		use(1)
		to_chat(user, "<span class='notice'>You make a light tile.</span>")