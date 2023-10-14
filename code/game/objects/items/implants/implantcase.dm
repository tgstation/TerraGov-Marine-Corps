/obj/item/implantcase
	name = "glass case"
	desc = "A case containing an implant."
	icon = 'icons/obj/items/implants.dmi'
	icon_state = "implantcase-0"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/medical_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/medical_right.dmi',
	)
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

/obj/item/implantcase/Destroy()
	QDEL_NULL(imp)
	return ..()

/obj/item/implantcase/update_icon_state()
	if(imp)
		icon_state = "implantcase-[imp.implant_color]"
	else
		icon_state = "implantcase-0"


/obj/item/implantcase/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/pen))
		var/label = stripped_input(user, "What would you like the label to be?", "[name]", null)
		if(user.get_active_held_item() != I)
			return
		if((!in_range(src, usr) && loc != user))
			return
		if(label)
			name = initial(name) + " - [label]"
		else
			name = initial(name)

	else if(istype(I, /obj/item/reagent_containers/syringe))
		if(!imp?.allow_reagents)
			return

		if(imp.reagents.total_volume >= imp.reagents.maximum_volume)
			to_chat(user, span_warning("[src] is full."))
			return

		I.reagents.trans_to(imp, 5)
		to_chat(user, span_notice("You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units."))

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
		M.update_icon()

	else if(istype(I, /obj/item/implant))
		user.temporarilyRemoveItemFromInventory(I)
		I.forceMove(src)
		imp = I
		update_icon()
