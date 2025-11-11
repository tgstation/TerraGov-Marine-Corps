/obj/machinery/unboxer/syndicate
	name = "Illicit Unboxer"
	desc = "An industrial resourcing unboxer. Seems to have had several restrictions lifted."
	icon = 'ntf_modular/icons/obj/factory/factory_machines.dmi'
	icon_state = "ebilunboxer_inactive"
	max_fill_amount = 150

/obj/machinery/unboxer/syndicate/update_icon_state()
	. = ..()
	if(datum_flags & DF_ISPROCESSING)
		icon_state = "ebilunboxer"
		return
	icon_state = "ebilunboxer_inactive"

/obj/machinery/unboxer/syndicate/attackby(obj/item/I, mob/living/user, def_zone)
	if(!isfactoryrefill(I) || user.a_intent == INTENT_HARM)
		return ..()
	var/obj/item/factory_refill/refill = I
	if(refill.antag_refill_type != production_type)
		if(production_amount_left)
			balloon_alert(user, "Filler incompatible")
			return
		production_type = refill.antag_refill_type
	var/to_refill = min(max_fill_amount - production_amount_left, refill.refill_amount)
	production_amount_left += to_refill
	refill.refill_amount -= to_refill
	visible_message(span_notice("[user] restocks \the [src] with \the [refill]!"), span_notice("You restock \the [src] with [refill]!"))
	if(!on)
		change_state()
	if(refill.refill_amount <= 0)
		qdel(refill)
		new /obj/item/stack/sheet/metal(user.loc)//simulates leftover trash


/obj/item/factory_refill/basic_assaultrifle
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/basic_rifle
	antag_refill_type = /obj/item/factory_part/basic_rifle/v31
	refill_amount = 3

/obj/item/factory_refill/basic_sniperrifle
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/basic_sniper
	antag_refill_type = /obj/item/factory_part/basic_sniper/svd
	refill_amount = 2

/obj/item/factory_refill/light_sentry
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/light_sentry
	antag_refill_type = /obj/item/factory_part/light_sentry/cope
	refill_amount = 2

/obj/item/factory_refill/drone_parts
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/automated_drone/nut
	refill_amount = 2
