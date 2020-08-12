/obj/machinery/sellingpad
	name = "ASRS Bluespace Selling Point"
	desc = "A bluespace telepad for sending valuble assets, such as valuble minerals and alien corpses. It needs to be wrenched down in a powered area to function."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster_off"
	density = FALSE
	anchored = FALSE
	use_power = IDLE_POWER_USE
	wrenchable = TRUE
	idle_power_usage = 300
	active_power_usage = 300
	var/selling_cooldown = 0


/obj/machinery/sellingpad/attack_hand(mob/living/user)
	. = ..()

	if (!anchored)
		to_chat(user, "<span class='warning'>Nothing happens. The [src] must be bolted to the ground first.</span>")
		return

	if (!powered())
		to_chat(user, "<span class='warning'>A red light flashes on the [src]. It seems it doesn't have enough power.</span>")
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		return

	if(selling_cooldown > world.time)
		to_chat(user, "<span class='warning'>The [src] is not ready to send yet!</span>")
		return

	for(var/i in get_turf(src))
		var/atom/movable/onpad = i
		if(!isxeno(onpad) && !istype(onpad,/obj/structure/ore_box))
			continue
		if(isxeno(onpad))
			var/mob/living/carbon/xenomorph/sellxeno = onpad
			if(sellxeno.stat != DEAD)
				to_chat(user, "<span class='warning'>The [src] buzzes: Live animals cannot be sold.</span>")
				continue

		. = onpad.supply_export()
		visible_message("<span class='notice'>The [src] buzzes: The [onpad] has been sold for [. ? . : "no"] point[. == 1 ? "" : "s"].</span>")
		qdel(onpad)

	do_sparks(5, TRUE, src)
	playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
	selling_cooldown = world.time + 15 SECONDS


/obj/machinery/sellingpad/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return

	if(iswrench(I))
		anchored = !anchored
		if(anchored)
			to_chat(user, "You bolt the [src] to the ground, activating it.")
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			icon_state = "broadcaster"
		else
			to_chat(user, "You unbolt the [src] from the ground, deactivating it.")
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			icon_state = "broadcaster_off"
