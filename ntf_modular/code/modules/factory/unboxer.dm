/obj/machinery/unboxer/syndicate
	name = "Illicit Unboxer"
	desc = "An industrial resourcing unboxer. Seems to have had several restrictions lifted."
	icon = 'icons/obj/factory/factory_machines.dmi'
	icon_state = "unboxer_inactive"

	var/obj/item/factory_part/production_type_antag = /obj/item/factory_part

/obj/machinery/unboxer/syndicate/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "It is currently facing [dir2text(dir)], and is outputting [initial(production_type_antag.name)]. It has [production_amount_left] resources remaining."

/obj/machinery/unboxer/syndicate/process()
	if(production_amount_left <= 0)
		change_state()
		return
	new production_type_antag (get_step(src, dir))
	production_amount_left--

/obj/machinery/unboxer/syndicate/attackby(obj/item/I, mob/living/user, def_zone)
	if(!isfactoryrefill(I) || user.a_intent == INTENT_HARM)
		return ..()
	var/obj/item/factory_refill/refill = I
	if(refill.antag_refill_type != production_type_antag)
		if(production_amount_left)
			balloon_alert(user, "Filler incompatible")
			return
		production_type_antag = refill.antag_refill_type
	var/to_refill = min(max_fill_amount - production_amount_left, refill.refill_amount)
	production_amount_left += to_refill
	refill.refill_amount -= to_refill
	visible_message(span_notice("[user] restocks \the [src] with \the [refill]!"), span_notice("You restock \the [src] with [refill]!"))
	if(!on)
		change_state()
	if(refill.refill_amount <= 0)
		qdel(refill)
		new /obj/item/stack/sheet/metal(user.loc)//simulates leftover trash
