/obj/machinery/exportpad
	name = "ASRS Bluespace Export Point"
	desc = "A bluespace telepad for sending valuble assets, such as valuble minerals and alien corpses. It needs to be wrenched down in a powered area to function."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcaster_off"
	density = FALSE
	anchored = FALSE
	use_power = IDLE_POWER_USE
	wrenchable = TRUE
	idle_power_usage = 50
	active_power_usage = 3000
	COOLDOWN_DECLARE(selling_cooldown)

/obj/machinery/exportpad/attack_hand(mob/living/user)
	. = ..()

	if (!anchored)
		to_chat(user, "<span class='warning'>Nothing happens. The [src] must be bolted to the ground first.</span>")
		return

	if (!powered())
		to_chat(user, "<span class='warning'>A red light flashes on the [src]. It seems it doesn't have enough power.</span>")
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		return

	if(!COOLDOWN_CHECK(src, selling_cooldown))
		to_chat(user, "<span class='warning'>The [src] is still recharging! It will be ready in [round(COOLDOWN_TIMELEFT(src, selling_cooldown) / 10)] seconds.</span>")
		return

	for(var/i in get_turf(src))
		var/atom/movable/onpad = i
		if(!isxeno(onpad) && !istype(onpad,/obj/structure/ore_box) && !istype(onpad, /obj/item/alien_embryo) && !istype(onpad, /obj/item/compactorebox))
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
	COOLDOWN_START(src, selling_cooldown, 30 SECONDS)
	use_power = ACTIVE_POWER_USE//takes a lot more power while cooling down
	addtimer(VARSET_CALLBACK(src, use_power, IDLE_POWER_USE), 30 SECONDS)


/obj/machinery/exportpad/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	if(anchored)
		to_chat(user, "You bolt the [src] to the ground, activating it.")
		playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
		icon_state = "broadcaster"
	else
		to_chat(user, "You unbolt the [src] from the ground, deactivating it.")
		playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
		icon_state = "broadcaster_off"
