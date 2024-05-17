/////////////////////////
////// Mecha Parts //////
/////////////////////////
/obj/item/mecha_parts
	name = "mecha part"
	icon_state = "blank"
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/mecha_parts/proc/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M, attach_right = FALSE) //For attaching parts to a finished mech
	if(!user.transferItemToLoc(src, M))
		to_chat(user, span_warning("\The [src] is stuck to your hand, you cannot put it in \the [M]!"))
		return FALSE
	user.visible_message(span_notice("[user] attaches [src] to [M]."), span_notice("You attach [src] to [M]."))
	return TRUE

/obj/item/mecha_parts/part/try_attach_part(mob/user, obj/vehicle/sealed/mecha/M, attach_right = FALSE)
	return
