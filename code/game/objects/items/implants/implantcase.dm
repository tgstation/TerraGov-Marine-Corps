/obj/item/implantcase
	name = "glass case"
	desc = "A case containing an implant."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/obj/item/implant/imp


/obj/item/implantcase/Initialize(mapload, imp)
	. = ..()
	if(imp)
		imp = new imp(src)
		update_icon()


/obj/item/implantcase/update_icon()
	if(imp)
		icon_state = "implantcase-[imp.implant_color]"
	else
		icon_state = "implantcase-0"


/obj/item/implantcase/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen))
		var/t = stripped_input(user, "What would you like the label to be?", text("[]", name), null)
		if(user.get_active_held_item() != I)
			return
		if((!in_range(src, usr) && loc != user))
			return
		if(t)
			name = text("glass case - '[]'", t)
		else
			name = "glass case"

	else if(istype(I, /obj/item/reagent_container/syringe))
		if(!imp?.allow_reagents)
			return

		if(imp.reagents.total_volume >= imp.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
			return

		I.reagents.trans_to(imp, 5)
		to_chat(user, "<span class='notice'>You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.</span>")

	else if(istype(I, /obj/item/implanter))
		var/obj/item/implanter/M = I
		if(M.imp)
			if((imp || M.imp.implanted))
				return
			M.imp.forceMove(src)
			imp = M.imp
			M.imp = null

		else if(imp)
			if(M.imp)
				return
			imp.forceMove(M)
			M.imp = imp
			imp = null
			
		update_icon()
		M.update()
