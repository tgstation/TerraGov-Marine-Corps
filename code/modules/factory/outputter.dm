


/obj/item/factory_refill
	name = "generic refiller"
	desc = "you shouldnt be seeing this."
	icon = 'icons/obj/factory_refill.dmi'
	icon_state = "empty"
	///Typepath for the output machine we want to be ejecting
	var/refill_type = /obj/machinery/outputter
	///By how much we wan to refill the target machine
	var/refill_amount = 30

/obj/item/factory_refill/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It has [refill_amount] packages remaining.")

/obj/machinery/outputter
	name = "Unboxer"
	desc = "An industrial resourcing unboxer."
	icon = 'icons/obj/factory/factory_machines.dmi'
	icon_state = "unboxer_inactive"
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	anchored = FALSE
	///the amount of resouce we have left to output factory_parts
	var/production_amount_left = 0
	///Maximum amount of resource we can hold
	var/max_fill_amount = 100
	///Typepath for the result we want outputted
	var/obj/item/factory_part/production_type = /obj/item/factory_part
	///Bool for whether the outputter is producing things
	var/on = FALSE

/obj/machinery/outputter/examine(mob/user, distance, infix, suffix)
	. = ..()
	to_chat(user, "It is currently facing [dir2text(dir)], and is outputting [initial(production_type.name)]. It has [production_amount_left] resources remaining.")

/obj/machinery/outputter/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	balloon_alert("[anchored ? "" : "un"]anchored")

/obj/machinery/outputter/update_icon_state()
	if(datum_flags & DF_ISPROCESSING)
		icon_state = "unboxer"
	else
		icon_state = "unboxer_inactive"

/obj/machinery/outputter/attack_hand(mob/living/user)
	if(!anchored)
		balloon_alert(user, "Must be anchored!")
		return
	on = !on
	if(on)
		START_PROCESSING(SSmachines, src)
		balloon_alert_to_viewers("turns on!")
		update_icon()
	else
		STOP_PROCESSING(SSmachines, src)
		balloon_alert_to_viewers("turns off!")
		update_icon()

/obj/machinery/outputter/attack_ai(mob/living/silicon/ai/user)
	return attack_hand(user)

/obj/machinery/outputter/process()
	if(!production_amount_left)
		balloon_alert_to_viewers("No material left!")
		STOP_PROCESSING(SSmachines, src)
		update_icon()
		return
	new production_type(get_step(src, dir))
	production_amount_left--

/obj/machinery/outputter/attackby(obj/item/I, mob/living/user, def_zone)
	if(!isfactoryrefill(I) || user.a_intent == INTENT_HARM)
		return ..()
	var/obj/item/factory_refill/refill = I
	if(!istype(src, refill.refill_type))
		balloon_alert(user, "Filler incompatible")
		return
	var/to_refill = min(max_fill_amount - production_amount_left, refill.refill_amount)
	production_amount_left += to_refill
	refill.refill_amount -= to_refill
	visible_message(span_notice("[user] restocks \the [src] with \the [refill]!"), span_notice("You restock \the [src] with [refill]!"))
	if(refill.refill_amount <= 0)
		qdel(refill)
		new /obj/item/stack/sheet/metal(user.loc)//simulates leftover trash

/obj/machinery/outputter/phosnade
	name = "Phosphorus resistant plate outputter"
	desc = "A machine outputting large plates with phosphorus resistant laminate."
	max_fill_amount = 70
	production_type = /obj/item/factory_part/phosnade

/obj/item/factory_refill/phosnade
	name = "Phosphorus resistant laminate plates"
	desc = "A box with what seem to be strangely colored metal plates inside. Used to refill Outputters."
	icon_state = "phosphorus"
	refill_type = /obj/machinery/outputter/phosnade

/obj/machinery/outputter/bignade
	name = "rounded grenade plate outputter"
	desc = "A large machine that produces plating for grenade casings."
	max_fill_amount = 120
	production_type = /obj/item/factory_part/bignade

/obj/item/factory_refill/bignade
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Outputters."
	icon_state = "grenade"
	refill_type = /obj/machinery/outputter/bignade
